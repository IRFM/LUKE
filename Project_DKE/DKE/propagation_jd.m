function [waveparam,xyprop,xys,xyPinc_2piRp_lin,yb] = propagation_jd(rays,xpsin_S,xpsin,method,display_mode);
%
% This function couples the DKE code with a ray-tracing code.
% RF rays are distributed onto the DKE flux surfaces.
% Rays that "turn back" are divided into several subrays. 
% 
%   INPUTS: 
%
%       - rays: list of RF rays. {1,nb_rf}. rays{ib} = ray is a structure 
%                   that includes all characteristics along the ray path  
%       - xpsin_S: flux radial grid [1,nr+1]
%       - xpsin: distribution radial grid [1,nr]
%       - method: interpolation method in psi (default = spline)
%       - display_mode: (1) display calculation result
%
%   OUTPUTS:
%
%       - waveparam: strucure for all ray fragments
%       - xyprop: RF rays propagation factor (1 if increasing psin, -1 if
%                   decreasing psin, 0 if flux-surface (FS) is not visited by the ray)
%       - xys: RF rays path length at center of FS
%       - xys: RF rays linear power flow at center of FS
%       - yb: list of ray starts in y grid and corresponding ray number. [2,nbb]
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 5
    display_mode = 0;
end
if nargin < 4
    method = 'linear';%interpolation technique in psi
end
%
nb = length(rays);
nr = length(xpsin_S) - 1;
%
xyprop = zeros(nr,0); %propagation factor (NaN is ray start, +1 is increasing psi, -1 is decreasing psi, 0 is non-applicable)
xyPinc_2piRp_lin = zeros(nr,0);% power flow in the ray based on linear absorption calculation at center of flux-surface
xys = zeros(nr,0);% ray path length at center of flux-surface
yb = []; %list of ray starts
%
iy = 0; %counting global number of ray
%
yiy_rf = [];%Index of the ray number ray fragment belongs to
yir_rf = [];%Index of the flux surface the ray fragment belongs to
%ys_rf = [];%Ray path length coordinate at center of the ray fragment
yds_rf = [];%incremental length of the ray fragment
yomega_rf = [];%RF wave frequency
yopt_rf = [];%Options for Larmor radius effects and/or EBW calc. 
ythetab_rf = [];%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
yB_rf =  [];%Magnetic field
yNpar_rf = [];%Gaussian N// spectrum: peak n//
ydNpar_rf = [];%Gaussian N// spectrum: width in n//
yNperp_rf = [];%RF wave : n_perp
yepolp_rf = [];%RF wave : polarization plus
yepolm_rf = [];%RF wave : polarization minus
yepolz_rf = [];%RF wave : polarization parallel
yphinorm_rf = [];%RF wave : amplitude of the normalized energy flow density
%
% Each ray has to be treated separately, because their lengths differ.
%
time0 = clock;
%
for ib = 1:nb
    %
    ray = rays{ib};
    ss = ray.ss;
    spsin = ray.spsin;
    %
    dsmin = ray.dsmin;
    %
    ns = length(ss);
    %
    if ns > 1,
        sphinorm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
    else
        sphinorm = abs(ray.sphi_xyz(1,:));% only the perpendicular contribution if to ray direction is given
    end
    %    
    if isempty(find(spsin < 1)), 
        disp('Warning: one ray did not enter the plasma and was rejected')
        continue
    end
    %
    if min(spsin) < 0 | max(isnan(spsin)), 
        disp('Warning: one ray is ill defined (spsin < 0 or NaN) and was rejected')
        continue
    end
    %
    if max(spsin) > 1, 
        disp('Warning: ray positions outside the last FS are projected on that last FS')
        spsin(find(spsin > 1)) = 1;
    end
    %    
    %is = max([1,min(find(spsin < 1)) - 1]);
    %
    yb = [yb,[iy+1;ib]];%keeps track of new ray indices.
%
% Find ray subdivisions
%
    sdpsin = diff(spsin);
    %
    svar = sign(sdpsin);
    srelvar = sign(sdpsin(1:ns-2).*sdpsin(2:ns-1));%relative psin variations between two consecutive steps
    %
    islim = find(srelvar == -1) + 1;% positions where ray turns around
%
% Treatment of stretches with constant psin
%
    islim0 = find(srelvar == 0) + 1;% positions where ray stay at constant psin
    %
    start = 1;
    finish = 0;
    %
    for iislim0 = 1:length(islim0),
        %
        if start == 1,% beginning of stretch
            bdir_before = svar(islim0(iislim0) - 1);% 0 if ray start with constant psin stretch
            finish = 0;
            start = 0;
        end
        %
        if (iislim0 == length(islim0))...
         | (islim0(iislim0 + 1) > islim0(iislim0) + 1),%find end of stretch
            finish = 1;
        end
        %
        if finish == 1 & islim0(iislim0),% end of stretch
            bdir_after = svar(islim0(iislim0));% 0 if ray finishes with constant psin stretch
            if bdir_after*bdir_before == -1,
                islim = [islim,islim0(iislim0)];% add this position to turning positions
            end
            start = 1;
        end
        %
    end
    %
    islim = sort([1,islim,ns]);
%
% Distribute subrays onto flux-surfaces
%
    ny = length(islim) - 1;%number of subrays
    %
    for iiy = 1:ny,% for each subray
        %
        iy = iy + 1;
        %
        % stretch of ray that belongs to the subray
        %
        is0 = islim(iiy);
        is1 = islim(iiy+1);
        %
        ismask = is0:is1;
        ns_mask = length(ismask);
        %
        % find what flux-surface each fragment belongs to
        %
        xspsin_S = repmat(xpsin_S.',[1,ns_mask]);
        xspsin_ray = repmat(spsin(ismask),[nr,1]);
        %
        [sir,check] = find(xspsin_S(1:nr,:) < xspsin_ray & xspsin_S(2:nr+1,:) >= xspsin_ray);
        %
        sir = sir(:).';
        check = check(:).';
        %
        if length(check) ~= ns_mask | check ~= 1:ns_mask,
            error('The subray distribution failed');
        end
        %
        % find fragments that cross flux-surface limits
        %
        iscross = find(diff(sir) ~= 0);
        %
        % determines the limit of ray fragments
        %
        ir_cross = max([sir(iscross);sir(iscross + 1)]);%index of flux-surfaces being crossed
        %
        ssiscross = ss(iscross + is0 - 1) + (ss(iscross + is0) - ss(iscross + is0 - 1)).*...
            (xspsin_S(ir_cross) - spsin(iscross + is0 - 1))./...
            (spsin(iscross + is0) - spsin(iscross + is0 - 1));        
        %
%         ssiscross = interp1([spsin(iscross + is0 - 1);spsin(iscross + is0)],...
%                             [ss(iscross + is0 - 1);ss(iscross + is0)],...
%                             xspsin_S(sir(iscross)+1),method);
        %
        % reduce number of fragments based on dsmin
        %
        if dsmin > 0,
            is_red = is0;
            ismask_red = [is0];
            while is_red < is1,
                ss_red = ss(is_red);
                is_red = min([is1,find(ss >= ss_red + dsmin)]);
                ismask_red = [ismask_red,is_red];
            end
        else
            ismask_red = ismask;
        end
        %
        ss_S = [ss(ismask_red),ssiscross];%vector of fragment limits
        spsin_S = [spsin(ismask_red),xspsin_S(ir_cross)];%corresponding psin values
        %
        [ss_S,iss_S] = sort(ss_S);
        spsin_S = spsin_S(iss_S);
        %
        mask_S = [1,1+find(diff(ss_S) ~= 0)];
        ys_S = ss_S(mask_S);
        ypsin_S = spsin_S(mask_S);
        %
        if ns_mask > 1,
            ys = (ys_S(1:end-1) + ys_S(2:end))/2;
            ypsin = (ypsin_S(1:end-1) + ypsin_S(2:end))/2;
        else
            ys = ys_S;
            ypsin = ypsin_S;
        end            
        %
        npsin = length(ys);
        %
        xypsin_S = repmat(xpsin_S.',[1,npsin]);
        xypsin_ray = repmat(ypsin,[nr,1]);
        %
        [yir,check] = find(xypsin_S(1:nr,:) < xypsin_ray & xypsin_S(2:nr+1,:) >= xypsin_ray);
        %
        yir = yir(:).';
        check = check(:).';
        %
        if length(check) ~= npsin | check ~= 1:npsin,
            error('The subray fragmentation failed');
        end
        %
        yir_rf = [yir_rf,yir];
%        ys_rf = [ys_rf,ys];
        %
        yds_rf = [yds_rf,diff(ys_S)];%incremental length of the ray path
        %
        yiy_rf = [yiy_rf,iy*ones(1,npsin)];%RF wave frequency
        yomega_rf = [yomega_rf,ray.omega_rf*ones(1,npsin)];%RF wave frequency
        yopt_rf = [yopt_rf,ray.opt_rf*ones(1,npsin)];%Options for Larmor radius effects and/or EBW calc. 
        %
        % interpolation for the center of each fragment.
        %
        if ns_mask > 1,
            ythetab_rf = [ythetab_rf,interp1(ss(ismask),ray.stheta(ismask),ys,method)];%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
            yB_rf = [yB_rf,interp1(ss(ismask),ray.sB(ismask),ys,method)];%Magnetic field
            yNpar_rf = [yNpar_rf,interp1(ss(ismask),ray.sNpar(ismask),ys,method)];%Gaussian N// spectrum: peak n//
            ydNpar_rf = [ydNpar_rf,interp1(ss(ismask),ray.sdNpar(ismask),ys,method)];%Gaussian N// spectrum: width in n//
            yNperp_rf = [yNperp_rf,interp1(ss(ismask),ray.sNperp(ismask),ys,method)];%RF wave : n_perp
            yepolp_rf = [yepolp_rf,interp1(ss(ismask),ray.sepol_pmz(1,ismask),ys,method)];%RF wave : polarization plus
            yepolm_rf = [yepolm_rf,interp1(ss(ismask),ray.sepol_pmz(2,ismask),ys,method)];%RF wave : polarization minus
            yepolz_rf = [yepolz_rf,interp1(ss(ismask),ray.sepol_pmz(3,ismask),ys,method)];%RF wave : polarization parallel
            yphinorm_rf = [yphinorm_rf,interp1(ss(ismask),sphinorm(ismask),ys,method)];%RF wave : amplitude of the normalized energy flow density
        else
            ythetab_rf = [ythetab_rf,ray.stheta(ismask)];%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
            yB_rf = [yB_rf,ray.sB(ismask)];%Magnetic field
            yNpar_rf = [yNpar_rf,ray.sNpar(ismask)];%Gaussian N// spectrum: peak n//
            ydNpar_rf = [ydNpar_rf,ray.sdNpar(ismask)];%Gaussian N// spectrum: width in n//
            yNperp_rf = [yNperp_rf,ray.sNperp(ismask)];%RF wave : n_perp
            yepolp_rf = [yepolp_rf,ray.sepol_pmz(1,ismask)];%RF wave : polarization plus
            yepolm_rf = [yepolm_rf,ray.sepol_pmz(2,ismask)];%RF wave : polarization minus
            yepolz_rf = [yepolz_rf,ray.sepol_pmz(3,ismask)];%RF wave : polarization parallel
            yphinorm_rf = [yphinorm_rf,sphinorm(ismask)];%RF wave : amplitude of the normalized energy flow density            
        end
        %
        % build xyprop and xyPinc_lin
        %
        ir0 = max(find(xpsin_S < spsin(is0)));%initial FS on ray trajectory
        ir1 = max(find(xpsin_S < spsin(is1)));%final FS on ray trajectory
        %
        xmask = min([ir0,ir1]):max([ir0,ir1]);
        %
        if spsin(is0) < spsin(is1),%ray propagating outward
            bdir = 1;
        else%ray propagating inward
            bdir = -1;
        end
        %
        xyprop(xmask,iy) = bdir;
        %
        mask_interp = [1,1 + find(diff(spsin(ismask)) ~= 0)];
        if ns_mask > 1,
            xys(xmask,iy) = interp1(spsin(ismask(mask_interp)),ss(ismask(mask_interp)),xpsin(xmask),method);
        else
            xys(xmask,iy) = ray.ss(ismask);
        end
        %
        if isnan(xys(ir0,iy)),
            if ~isempty(ssiscross),
                xys(ir0,iy) = (ss(is0) + ssiscross(1))/2;
            else
                xys(ir0,iy) = (ss(is0) + ss(is1))/2;
            end
            %xyPinc_2piRp_lin(ir0,iy) = ray.sP_2piRp(is0);
        end
        if isnan(xys(ir1,iy)),
            xys(ir1,iy) = (ssiscross(end) + ss(is1))/2;
            %xyPinc_2piRp_lin(ir1,iy) = ray.sP_2piRp(is1); 
        end
        %
        if isfield(ray,'sP_2piRp'),
            xyPinc_2piRp_lin(xmask,iy) = interp1(ss(ismask),ray.sP_2piRp(ismask),xys(xmask,iy),method);
        else
            xyPinc_2piRp_lin(xmask,iy) = ray.P0_2piRp;
        end
        %
    end
    if display_mode >= 1,info_dke_yp(2,['Preprocessing of launched ray #',int2str(ib),'/',int2str(nb),' done. Elapsed time : ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
end
%  
waveparam.model = 'RT';
waveparam.biy_rf = yiy_rf;%Index of the ray the ray fragment belongs to
waveparam.bir_rf = yir_rf;%Index of the flux surface the ray fragment belongs to
%waveparam.bs_rf = ys_rf;%Ray path length coordinate at center of the ray fragment
waveparam.bds_rf = yds_rf;%incremental length of the ray fragment
waveparam.bomega_rf = yomega_rf;%RF wave frequency
waveparam.bopt_rf = yopt_rf;%Options for Larmor radius effects and/or EBW calc. 
waveparam.bthetab_rf = ythetab_rf;%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
waveparam.bB_rf = yB_rf;%Magnetic field
waveparam.bNpar_rf = yNpar_rf;%Gaussian N// spectrum: peak n//
waveparam.bdNpar_rf = ydNpar_rf;%Gaussian N// spectrum: width in n//
waveparam.bNperp_rf = yNperp_rf;%RF wave : n_perp
waveparam.bepolp_rf = yepolp_rf;%RF wave : polarization plus
waveparam.bepolm_rf = yepolm_rf;%RF wave : polarization minus
waveparam.bepolz_rf = yepolz_rf;%RF wave : polarization parallel
waveparam.bphinorm_rf = yphinorm_rf;%RF wave : amplitude of the normalized energy flow density
%
