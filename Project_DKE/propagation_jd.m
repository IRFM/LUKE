function [xyvray,xyfinc,xyprop,yb] = propagation_jd(vsrays,xpsin,xdpsin,xpsin_S,theta,ppsin,ptR,ptBP,psia,method,display_mode);
%
% This function couples the DKE code with a ray-tracing code. Ray
% caracteristics are evaluated at the DKE radial positions and the incidence
% factors are calculated. Rays that "turn back" are divided into several
% rays. 
% 
%   INPUTS: 
%
%       - vsrays: list of RF rays. {1,nb_rf}. vsrays{ib} = ray [nv,ns] is an
%           array of nv variables evaluated at ns propagation steps. It is
%           requires that nv=1 is "ss", distance along the ray, nv=2 is "spsin" 
%           normalized poloidal flux and nv=3 is "stheta" poloidal angle.  
%       - xpsin: distribution radial grid [1,nx]
%       - xdpsin: radial grid steps [1,nx]
%       - xpsin_S: flux radial grid [1,nx_S]
%       - method: interpolation method in psi (default = spline)
%
%   OUTPUTS
%
%       - xyvray: RF rays characteristics evaluated at radial grid positions
%       - xyfinc: RF rays incidence factor
%       - xyprop: RF rays propagation factor (1 if increasing psin, -1 if
%       decreasing psin, 0 if flux-surface (FS) is not visited by the ray)
%       - yb: list of ray starts in y grid and corresponding ray number. [2,nbb]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 9
    method = 'spline';%interpolation technique in psi
end
if length(xpsin) == 1,
    xpsin_S = [0,1];
    xdpsin = 1;
end
%
nb_rf = length(vsrays);
nr = length(xpsin);
%
xyvray = zeros(nr,0,13); %ray properties
xyfinc = zeros(nr,0); %incidence factor
xyprop = zeros(nr,0); %propagation factor (NaN is ray start, +1 is increasing psi, -1 is decreasing psi, 0 is non-applicable)
yb = []; %list of ray starts
%
ibb = 0; %counting global number of ray
%
% Each ray has to be treated separately, because their lengths differ.
%
time0 = clock;
%
for ib = 1:nb_rf
%
    vsray = vsrays{ib};
    ss = vsray(1,:);
    spsin = vsray(2,:);
    ns = length(ss);
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
    ibb = ibb + 1;%starting a new ray in xy matrices
%    
    is = max([1,min(find(spsin < 1)) - 1]);
%
    ipsin = max(find(xpsin_S < spsin(is)));%initial FS on ray trajectory (generally last FS, but not necessarily (ex: EBW))
    yb = [yb,[ibb;ib]];
    bdir = -1;
    bdir_new = bdir; 
    going = 1;
%
% distribution of the ray on flux-surfaces
%
    if ns == 1%test case with local calculation on one flux-surface - no ray-tracing
        xyprop(ipsin,ibb) = NaN;
        xyfinc(ipsin,ibb) = 1;
        xyvray(ipsin,ibb,:) = reshape(vsray(:,is),[1,1,12]);
        going = 0;
    end
    while going == 1 
        bpsinm = xpsin_S(ipsin); % lower bound of the current FS
        bpsin = xpsin(ipsin); % center of the current FS
        bpsinp = xpsin_S(ipsin + 1); % upper bound of the current FS
%        
% position where ray exits the current FS (or last point on the ray path if last visited FS is reached)
%
        islim = min([find((ss > ss(is)) & (spsin < bpsinm | spsin > bpsinp)),ns]); 
%        
        maskfs = is:islim; %ray trajectory within current FS
%
% dealing with extremums of spsin: if ray turns around, it is split at the extremum. 
%    
        is_f_0 = is - 1 + min(find((spsin(maskfs) - bpsin)*bdir_new > 0));
%        
        if isempty(is_f_0),%ray turns before the fs center
            isint = find(abs(spsin(maskfs) - bpsin) == min(abs(spsin(maskfs) - bpsin)));
            is_f = is - 1 + max(isint);
            islim = is_f;
            is_f_1 = [];
%            
        elseif is_f_0 == is,%ray has started or turned before the fs center
            isint = find(abs(spsin(maskfs) - bpsin) == min(abs(spsin(maskfs) - bpsin)));
            is_f = is - 1 + max(isint);
            is_f_1 = [];
%            
        else,%ray goes past the fs center
            is_f_1 = is_f_0 - 1 + min(find((spsin(is_f_0:islim) - bpsin)*bdir_new < 0));           
        end
%        
        if ~isempty(is_f_1),%ray goes "around" the fs center
            isext = find((spsin(is_f_0:is_f_1) - bpsin)*bdir_new == max((spsin(is_f_0:is_f_1) - bpsin)*bdir_new));
            islim = is_f_0 - 1 + max(isext);
        end        
%        
% propagation factor        
%        
        bdir_new = sign(spsin(islim) - spsin(is));
        if bdir_new*bdir == -1 %change of direction in psi leads to splitting of ray
            ibb = ibb + 1;
        end
        xyprop(ipsin,ibb) = bdir_new;
%
        bdir = bdir_new;
%        
        if is_f_0 > is & ~isempty(is_f_0),%ray goes past the fs center
%        
% interpolation for the center of the FS   
%
            vsray_f = interp1(spsin(is_f_0-1:is_f_0),vsray(:,is_f_0-1:is_f_0).',bpsin);
            xyvray(ipsin,ibb,:) = reshape(vsray_f,[1,1,13]); %parameters vrays at center of FS
%
        else% ray turns around before center
            xyvray(ipsin,ibb,:) = reshape(vsray(:,is_f),[1,1,13]); %parameters vrays at center of FS   
        end
%
% remove ray path outside FS
%
        if spsin(is) > bpsinp,
            bds_0 = (ss(is+1) - ss(is))*(spsin(is) - bpsinp)/(spsin(is) - spsin(is+1));
        elseif spsin(is) < bpsinm,
            bds_0 = (ss(is+1) - ss(is))*(bpsinm - spsin(is))/(spsin(is+1) - spsin(is));
        else
            bds_0 = 0;
        end
%            
        if spsin(islim) < bpsinm,
            bds_1 = (ss(islim) - ss(islim-1))*(bpsinm - spsin(islim))/(spsin(islim-1) - spsin(islim));
        elseif spsin(islim) > bpsinp,
            bds_1 = (ss(islim) - ss(islim-1))*(spsin(islim) - bpsinp)/(spsin(islim) - spsin(islim-1));
        else
            bds_1 = 0;
        end        
%
        bds = ss(islim) - ss(is) - bds_0 - bds_1;%path length of ray within the current FS
%
% local width of the FS: |dl| = |dpsi|/|grad psi| = |dpsin.psia|/|R.BP|
%
        thetab_f = xyvray(ipsin,ibb,3);
        Rb_f = interp2(theta,ppsin,ptR,thetab_f,bpsin,method);
        BPb_f = interp2(theta,ppsin,ptBP,thetab_f,bpsin,method);
%
        bdl = abs(xdpsin(ipsin)*psia./Rb_f./BPb_f); %width of the FS at theta = thetab
        xyfinc(ipsin,ibb) = bds/bdl; %incidence factor
%
% test for stopping
%
        if islim == ns & spsin(ns) >= bpsinm & spsin(ns) <= bpsinp,
            going = 0;
        end
%
% next FS
%
        if ~isempty(is_f_0) & isempty(is_f_1) % ray is not split at an extremum in psi: it either reaches another FS or stops
            if bdir_new < 0 %reaches a more inward FS
                ipsin = ipsin - 1;
            else %reaches a more outward FS
                ipsin = ipsin + 1;
            end
            is = islim - 1; 
        else
            is = islim;
            bdir_new = - bdir;
        end
    end
%
	if display_mode >= 1,info_dke_yp(2,['Preprocessing of launched ray #',int2str(ib),'/',int2str(nb_rf),' done. Elapsed time : ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end

end
%
