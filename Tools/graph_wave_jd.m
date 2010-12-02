function graph_wave_jd(equil,waves,nr_dep,opt,rho_disp,ymask,xvar,yabs,colors,styles)
%
% This function plots the characteristics of wave data
%
% by J. Decker 02/04/03
%
if nargin < 10
    styles = {'-','-','-','-','-','-'};
end
if nargin < 9
    colors = {'b','r',[0,0.5,0],'m','c','y'};
end
if nargin < 8
    yabs = NaN;
end
if nargin < 7
    xvar = 's';
end
if nargin < 6
    ymask = NaN;
end
if nargin < 5
    rho_disp = 0:0.1:1;
end
%
nw = length(waves);
%
if ~iscell(ymask),
    ymask = '';
    for iw = 1:nw,
        ymask{iw} = 1:length(waves{iw}.rays);
    end
end
%
nymask = zeros(1,nw);
%
for iw = 1:nw,
    nymask(iw) = length(ymask{iw});
    %
    if opt.TeNpar && waves{iw}.omega_rf/(2*pi*1e9) < 10,%isfield(waves{iw},'info') && isfield(waves{iw}.info,'ftype') && strcmp(waves{iw}.info.ftype,'LF'),
        %
        waves{iw}.opt_TeNpar = 1;
        %
    else
        %
        waves{iw}.opt_TeNpar = 0;
        %
    end        
end
%
%[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
method = 'cubic';
%format
%n_ec = 2;% to be automatized
%N = 5;
%vparn = 6;
%
% Equilibrium
%
Rp = equil.Rp;
Zp = equil.Zp;
ptx = equil.ptx;
pty = equil.pty;
%ptBx = equil.ptBx;
%ptBy = equil.ptBy;
%ptBPHI = equil.ptBPHI;
theta = equil.theta;
psi_apRp = equil.psi_apRp;
%
%[np,nt] = size(ptx);
psin = psi_apRp/psi_apRp(end);
%
ap =  ptx(end,1);%Plasma minor radius on the LFS midplane 
%
prho_g = ptx(:,1)/ap;
%
equilDKE = equilibrium_jd(equil);
%
if xvar == 'g',%rho defined as r/a on LFS midplane
    prho = prho_g;
    plab = 'r/a';
elseif xvar == 'p',%rho defined as square root of poloidal flux
    prho = sqrt(psin);
    plab = '\rho_{\psi_P}';
elseif xvar == 't',%rho defined as square root of toroidal flux
    prho = equilDKE.xrhoT;
    plab = '\rho_{\psi_T}';
elseif xvar == 'v',%rho defined as square root of toroidal flux
    prho = equilDKE.xrhoV;
    plab = '\rho_V';
end
%
%ptB = sqrt(ptBx.^2 + ptBy.^2 + ptBPHI.^2);% total magnetic field
%ptr = sqrt(ptx.^2 + pty.^2); %minor radius on the (psi,stheta) grid
%
ptx_disp = interp1(prho,ptx,rho_disp,method);  
pty_disp = interp1(prho,pty,rho_disp,method); 
%
xmin = min(min(ptx));
xmax = max(max(ptx));
ymin = min(min(pty));
ymax = max(max(pty));
%
PHI_disp = linspace(0,2*pi,361);
X_disp = [(Rp + xmin)*cos(PHI_disp);(Rp + xmax)*cos(PHI_disp)];
Y_disp = [(Rp + xmin)*sin(PHI_disp);(Rp + xmax)*sin(PHI_disp)];
%
Xmin = min(min(X_disp));
Xmax = max(max(X_disp));
Ymin = min(min(Y_disp));
Ymax = max(max(Y_disp));
%
% Wave
%
iy = 0;
rays = '';
for iw = 1:nw,
    ibb = 0;
    for ib = ymask{iw},
        ibb = ibb + 1;
        iy = iy + 1; 
        rays{iy} = waves{iw}.rays{ib};
		%
        rays{iy}.omega_rf = waves{iw}.omega_rf;
        rays{iy}.color = colors{mod(iw-1,length(colors))+1};
        %rays{iy}.color = colors{mod(iy-1,length(colors))+1};
        rays{iy}.style = styles{mod(iw-1,length(styles))+1};
        rays{iy}.sX = (Rp + rays{iy}.sx).*cos(-rays{iy}.sphi);
        rays{iy}.sY = (Rp + rays{iy}.sx).*sin(-rays{iy}.sphi);
		%
        if iscell(yabs),
            rays{iy}.mask_abs = yabs{iw}(1,ibb):yabs{iw}(2,ibb);
		else
			rays{iy}.mask_abs = [];
        end
        if ~isfield(rays{iy},'rayinits') || ~strcmp(rays{iy}.rayinits{1}.type,'EC'),
            rays{iy}.refs = '';
        else
            for iref = 1:length(rays{iy}.rayinits),% for each reflection
                %
                rayinit = rays{iy}.rayinits{iref};
                %
                launch = rayinit.launch;
                %
                rays{iy}.refs{iref}.x = launch.yR_L - Rp;
                rays{iy}.refs{iref}.y = launch.yZ_L - Zp;
                rays{iy}.refs{iref}.phi = launch.yphi_L;
                %
                while isfield(launch,'launch_back') && ~isempty(launch.launch_back),
                    %
                    launch = launch.launch_back;
                    %
                    rays{iy}.refs{iref}.x = [launch.yR_L - Rp,rays{iy}.refs{iref}.x];
                    rays{iy}.refs{iref}.y = [launch.yZ_L - Zp,rays{iy}.refs{iref}.y];
                    rays{iy}.refs{iref}.phi = [launch.yphi_L,rays{iy}.refs{iref}.phi];
                    %
                end
                %
                is = find(rays{iy}.ss == rayinit.ss0);
                %
                if is > 1 && is < length(rays{iy}.ss),
                    %
                    rays{iy}.refs{iref}.x = [rays{iy}.sx(is),rays{iy}.refs{iref}.x,rays{iy}.sx(is+1)];
                    rays{iy}.refs{iref}.y = [rays{iy}.sy(is),rays{iy}.refs{iref}.y,rays{iy}.sy(is+1)];
                    rays{iy}.refs{iref}.phi = [rays{iy}.sphi(is),rays{iy}.refs{iref}.phi,rays{iy}.sphi(is+1)];
                    %
                elseif is ==1,
                    %
                    rays{iy}.refs{iref}.x = [rays{iy}.refs{iref}.x,rays{iy}.sx(is)];
                    rays{iy}.refs{iref}.y = [rays{iy}.refs{iref}.y,rays{iy}.sy(is)];
                    rays{iy}.refs{iref}.phi = [rays{iy}.refs{iref}.phi,rays{iy}.sphi(is)];
                    %
                else
                    %
                    rays{iy}.refs{iref}.x = [rays{iy}.sx(is),rays{iy}.refs{iref}.x];
                    rays{iy}.refs{iref}.y = [rays{iy}.sy(is),rays{iy}.refs{iref}.y];
                    rays{iy}.refs{iref}.phi = [rays{iy}.sphi(is),rays{iy}.refs{iref}.phi];
                    %
                end
                %
                rays{iy}.refs{iref}.R = rays{iy}.refs{iref}.x + Rp;
                rays{iy}.refs{iref}.Z = rays{iy}.refs{iref}.y + Zp;
                rays{iy}.refs{iref}.X = rays{iy}.refs{iref}.R.*cos(-rays{iy}.refs{iref}.phi);
                rays{iy}.refs{iref}.Y = rays{iy}.refs{iref}.R.*sin(-rays{iy}.refs{iref}.phi);
                %
                xmin = min([xmin,rays{iy}.refs{iref}.x]);	
                xmax = max([xmax,rays{iy}.refs{iref}.x]);	
                ymin = min([ymin,rays{iy}.refs{iref}.y]);	
                ymax = max([ymax,rays{iy}.refs{iref}.y]);	
                %
                Xmin = min([Xmin,rays{iy}.refs{iref}.X]);	
                Xmax = max([Xmax,rays{iy}.refs{iref}.X]);	
                Ymin = min([Ymin,rays{iy}.refs{iref}.Y]);	
                Ymax = max([Ymax,rays{iy}.refs{iref}.Y]);	
                %
            end
            %     
        end
        %    
    end
end
ny = iy;
%
% Damping
%
yrho_abs = zeros(1,ny);
yPtot_abs = zeros(1,ny);
yNpar_abs = zeros(1,ny);
%
dPdrho = 0;
%
for iy = 1:ny,
    ns = length(rays{iy}.ss);
    %
    if isfield(rays{iy},'sP_2piRp'),
        sP_2piRp_norm = rays{iy}.sP_2piRp/rays{iy}.sP_2piRp(1);
        sdP_2piRp_ds_norm = rays{iy}.sdP_2piRp_ds/max(rays{iy}.sdP_2piRp_ds+eps).*(1 - sP_2piRp_norm(end)/sP_2piRp_norm(1));
        if ~iscell(yabs),
            rays{iy}.mask_abs = find(sdP_2piRp_ds_norm > 0.01);
        end
        if opt.abs_max == 1,
            rays{iy}.is_abs_max = min([ns,find(sP_2piRp_norm < 0.001)]);        
        else
            rays{iy}.is_abs_max = ns;
        end
        rays{iy}.is_abs = min(find(sdP_2piRp_ds_norm == max(sdP_2piRp_ds_norm))); 
        %
        yrho_abs(iy) = rays{iy}.srho(rays{iy}.is_abs);
        yNpar_abs(iy) = real(rays{iy}.sNpar(rays{iy}.is_abs));
        yPtot_abs(iy) = 1 - sP_2piRp_norm(end);
        %
        rays{iy} = radialdampingprofile_jd(rays{iy},nr_dep);
        %
        dPdrho = dPdrho + rays{iy}.dPnormdrho*rays{iy}.P0_2piRp*2*pi*Rp;
        %
    else
        rays{iy}.is_abs_max = ns;
        rays{iy}.is_abs = NaN;
        rays{iy}.rho_dep = NaN;
        rays{iy}.dPnormdrho = NaN;
        yrho_abs(iy) = NaN;
        yNpar_abs(iy) = NaN;
        yPtot_abs(iy) = NaN;
    end
    %
    disp(['Ray # ',num2str(iy),': fraction of power absorbed: ',num2str(yPtot_abs(iy)*100),' %'])  
    % 
end
%
rhog_dep = rays{1}.rho_dep;
rho_dep = interp1(prho_g,prho,rhog_dep);
%
drhog_dep = diff([0,(rhog_dep(1:end-1) + rhog_dep(2:end))/2,1]);
drho_dep = diff([0,(rho_dep(1:end-1) + rho_dep(2:end))/2,1]);
%
dPdrho = dPdrho.*drhog_dep./drho_dep;
%
% %
% % Resonance
% %
% if opt(2) >= 1 | opt(3) >= 1 | opt(4) >= 1,
%     if isempty(sypsin) | isempty(sytheta),
%         for ib = 1:ny
%         %
%         % ray position in (r,theta) coordinates
%         %
%             sR = syR(:,ib) + eps*(syR(:,ib) == Rp); %to avoid singularities
%             sZ = syZ(:,ib) + eps*(syZ(:,ib) == Zp); %to avoid singularities
%             sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2); %minor radius
%             stheta = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp); %poloidal angle [0,2*pi]
%         %
%         % interpolation for r at ray poloidal locations    
%         %
%             psr = interp1(theta,r',stheta,method)';%r(psi,st)
%         %
%         % interpolation for psi at ray position (along cst theta lines)
%         %
%         %spsin = interp1(pstr,ppsin,sr,method);%psi(s)
%             method2 = 'linear';
%             for is = 1:ns 
%                 spsin(is,1) = interp1(psr(:,is),ppsin,sr(is),method2);%psi(s)
%             end
%         %
%             imask_1 = min(find(~isnan(spsin)));
%             imask_2 = min(find(isnan(spsin(imask_1:ns))));
%             mask = [1:(imask_1 - 1),(imask_1 + imask_2 - 1):ns];
%         %
%             spsin(mask) = 1;%part of ray outside the last flux-surface
%         %
%             sypsin(1:ns,ib) = spsin;
%             sytheta(1:ns,ib) = stheta;
%         end
%     end
%     for ib = 1:ny
%     %
%         spsin = sypsin(:,ib);
%         stheta = sytheta(:,ib);        
%     %
%         syB(:,ib) = interp2(theta,ppsin,B,stheta,spsin,method);
%         if opt(4) >= 1,
%             syBR(:,ib) = interp2(theta,ppsin,BR,stheta,spsin,method);
%             syBZ(:,ib) = interp2(theta,ppsin,BZ,stheta,spsin,method);
%             syBPHI(:,ib) = interp2(theta,ppsin,BPHI,stheta,spsin,method);
%         end
%     %
%         syne(:,ib) = interp1(ppsin,equil.pne,spsin,method);
%         siyzni(:,:,ib) = interp1(ppsin,equil.pzni',spsin,method);
%         syTe(:,ib) = interp1(ppsin,equil.pTe,spsin,method);
%         siyzTi(:,:,ib) = interp1(ppsin,equil.pzTi',spsin,method);
%     %
%     end
% %
%   sybetath = sqrt(syTe/mc2);
% %    
%   omega_ce = qe*B/me;
%   yres = omega_rf./omega_ce;  
% %
%   syomega_ce = qe*syB/me;
%   syres = omega_rf./syomega_ce;
%   is_syres = find(abs(diff(floor(syres))) == 1);
%   if exist('wave_s','var') == 1, 
% %
%     sybetath_s = sqrt(syTe_s/mc2);
% %
%     syomega_ce_s = qe*syB_s/me;
%     syres_s = omega_rf./syomega_ce_s;
% %        
%   end    
% end 
% %
% % Absorption coefficient
% %
% if opt(3) >= 1,
% %
%     if isempty(syepol_pmz) | isempty(syphi_pmz),    
%         for ib = 1:ny
%             for is = 1:ns
%               if ~isnan(syNpar(is,ib))  
%                 [sNperpp,sNperpm,sKxyz,sep_xyz,sem_xyz,sep_pmz,sem_pmz,sep_pyk,sem_pyk,sphip_xyz,sphim_xyz,sphip_pmz,sphim_pmz] = ...
%                     colddisp_dke_jd(syNpar(is,ib),omega_rf,syne(is,ib),siyzni(is,:,ib),equil.zZi,equil.zmi,syB(is,ib));
%                 maskp = (abs(sNperpp - syNperp(is,ib)) <= abs(sNperpm - syNperp(is,ib)));
%                 syNperp_cold(is,ib) = sNperpp.*maskp + sNperpm.*~maskp;
%                 syepol_pmz(is,1:3,ib) = sep_pmz'.*maskp + sem_pmz'.*~maskp;
%                 syphi_pmz(is,1:3,ib) = sphip_pmz'.*maskp + sphim_pmz'.*~maskp;
%               else
%                 syNperp_cold(is,ib) = NaN;
%                 syepol_pmz(is,1:3,ib) = NaN;
%                 syphi_pmz(is,1:3,ib) = NaN;         
%               end    
%             end
%         end
%     end
%     %
%     if id_wave(1) == 'S' & exist('syNperp_cold'),
%         syNperp = syNperp_cold;
%     end
%     %
%     sywpe = sqrt(syne*qe^2/e0/me);
%     syabsphi = squeeze(sqrt(abs(syphi_pmz(:,1,:)).^2 + abs(syphi_pmz(:,2,:)).^2 + abs(syphi_pmz(:,3,:)).^2));
%     %
%     syalpha = 2^(1-n_ec)*n_ec/sqrt(2*pi)/fact_dke_jd(n_ec - 1).*sywpe.^2.*syres.^(2*(n_ec - 1))...
%         .*sybetath.^(2*n_ec - 3)*pi/clum/omega_rf./syabsphi.*syNperp.^(2*(n_ec - 1)).*squeeze(abs(syepol_pmz(:,2,:)).^2)./abs(syNpar).*exp(-((1-n_ec./syres)./sybetath./syNpar).^2/2);
%     %
%     syalpha(isnan(syalpha)) = 0;
%     syds = [zeros(1,ny);diff(sys)];
%     syds(isnan(syds)) = 0;
%     %
%     syPinc = ones(ns,1)*yP0.*exp(-cumsum(syalpha.*syds));
%     sydPincds = syPinc.*syalpha;
%     %
%     if exist('wave_s','var') == 1, 
%         %
%         sywpe_s = sqrt(syne_s*qe^2/e0/me);
%         syabsphi_s = squeeze(sqrt(abs(syphi_pmz_s(:,1,:)).^2 + abs(syphi_pmz_s(:,2,:)).^2 + abs(syphi_pmz_s(:,3,:)).^2));
%         %
%         syalpha_s = 2^(1-n_ec)*n_ec/sqrt(2*pi)/fact_dke_jd(n_ec - 1).*sywpe_s.^2.*syres_s.^(2*(n_ec - 1))...
%             .*sybetath_s.^(2*n_ec - 3)*pi/clum/omega_rf./syabsphi_s.*syNperp_s.^(2*(n_ec - 1)).*squeeze(abs(syepol_pmz_s(:,2,:)).^2)./abs(syNpar_s).*exp(-((1-n_ec./syres_s)./sybetath_s./syNpar_s).^2/2);
%         %
%         syPinc_s = ones(ns_s,1)*yP0_s.*exp(-cumsum(syalpha_s.*[zeros(1,ny);diff(sys_s)]));
%         sydPincds_s = syPinc_s.*syalpha_s;
%         %        
%     end
%     %
% end
% %
% % frequencies
% %
% if (opt(2) >=1 | opt(3) >= 1) & ny == 1% only one ray
%     %
%     syrho = interp1(ppsin,prho,sypsin,method);
%     %
%     omega_rf_ghz = omega_rf/(2*pi*1e9);
%     somega_ce_ghz = syomega_ce/(2*pi*1e9);
%     %
%     Nsomega_ce_ghz = somega_ce_ghz*(1:N);
%     NsNpar = repmat(syNpar,[1,N]);
%     NsdNpar = repmat(sydNpar,[1,N]);
%     Nsybetath = repmat(sybetath,[1,N]);
%     %
%     Nsomega_ce_ghz_m = Nsomega_ce_ghz - (abs(NsNpar) - NsdNpar)*vparn.*Nsybetath*omega_rf_ghz;
%     Nsomega_ce_ghz_p = Nsomega_ce_ghz + (abs(NsNpar) - NsdNpar)*vparn.*Nsybetath*omega_rf_ghz;
%     %
%     [imask_res,Nmask_res] = find(omega_rf_ghz > Nsomega_ce_ghz_m & omega_rf_ghz < Nsomega_ce_ghz_p);
%     %
%     for iN = 1:N
%         mask_N = find(Nmask_res == iN);
%         if ~isempty(mask_N),
%             rhomin_res(iN) = min(syrho(imask_res(mask_N)));
%             rhomax_res(iN) = max(syrho(imask_res(mask_N)));
%             disp(['Harmonic: ',num2str(iN),', rho_min = ',num2str(rhomin_res(iN)),', rho_max = ',num2str(rhomax_res(iN))])
%         else
%             rhomin_res(iN) = NaN;
%             rhomax_res(iN) = NaN;
%             disp(['No resonance at harmonic: ',num2str(iN)])
%         end
%     end
%     disp(['===> global grid: rho_min = ',num2str(min(rhomin_res)),', rho_max = ',num2str(max(rhomax_res))]) 
% end
% %
% % beam size - gaussian width
% %
% % Note, we assume that the first ray is the central ray
% %
% if opt(4) >= 1,
%     syispsin = NaN*zeros(ns,ny);
%     %
%     scsign = [-1;sign(diff(sypsin(:,1)))];
%     sysign = [ones(1,ny);sign(diff(sypsin))];
%     %
%     for is=1:ns,
%         scpsin = sypsin(is,1);%central ray
%         %
%         sysignmask = scsign(is) ~= sysign;
%         %
%         [isy,iyy] = find(abs(sypsin - scpsin) == repmat(min(abs(sypsin - scpsin) + sysignmask),[ns,1]));
%         for iy = 1:length(isy),
%             syispsin(is,iyy(iy)) = isy(iy);
%         end
%     end
%     %
%     sycR = repmat(syR(:,1),[1,ny]);
%     sycZ = repmat(syZ(:,1),[1,ny]);
%     sycphi = repmat(syphi(:,1),[1,ny]);
%     %
%     scBR = syBR(:,1);
%     scBZ = syBZ(:,1);
%     scBPHI = syBPHI(:,1);
%     scB = syB(:,1);
%     %
%     % unit vector in the field direction
%     %
%     sycbR = repmat(scBR./scB,[1,ny]);
%     sycbZ = repmat(scBZ./scB,[1,ny]);
%     sycbPHI = repmat(scBPHI./scB,[1,ny]);
%     %
%     mask = isnan(syispsin);
%     syispsin(mask) = 1;
%     %
%     syispsin = syispsin + repmat((0:ny-1)*ns,[ns,1]);
%     %
%     sydpar = (syR(syispsin) - sycR).*sycbR + (syZ(syispsin) - sycZ).*sycbZ + (syphi(syispsin) - sycphi).*sycR.*sycbPHI;
%     %
%     sydpar(mask) = NaN;
%     %
%     sdpar = (max(sydpar') - min(sydpar'))/2;
%     sdNpar = 2*clum/omega_rf./sdpar;
% end
%
% Display
%
style = '-';
style2 = 'none';
style3 = '--';
marker = 'none';
marker1 = '+';
marker2 = '.';
marker3 = 'o';
color1 = 'r';
color2 = 'b';
color3 = 'm';
color4 = 'g';
color5 = 'k';
width1 = 2;
width2 = 0.5;
siz = 20+14i;
red = 0.9;
lspace = 0.7;
bspace = 0.7;
%
figure(1),clf,set(1,'name','Poloidal trajectories')
% Add vessel and tiles if TCV
if strfind(equil.id,'TCV') & strcmp(opt.vessel_opt,'y')
    tcvview('avt'); % Plot axes, vessel and tiles
    tcvview('color','t',[0.75 0.75 0.75]); % Tiles in light gray
    title(''); % Remove title
    hold on;
    Rpdisp = Rp; % Centering of flux surfaces and rays on the magnetic axis
    Zpdisp = Zp;
else
    Rpdisp = 0;
    Zpdisp = 0;
end
%
xlim = [xmin + Rpdisp,xmax + Rpdisp];
ylim = [ymin + Zpdisp,ymax + Zpdisp];
xlab = 'x (m)';
ylab = 'y (m)';
tit = '';
%
[ax] = graph1D_jd(ptx_disp'+Rpdisp,pty_disp'+Zpdisp,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color5,width2,siz,gca,red,lspace,bspace);
for iy = 1:ny,
    mask_max = 1:rays{iy}.is_abs_max;
    graph1D_jd(rays{iy}.sx(mask_max) + Rpdisp,rays{iy}.sy(mask_max) + Zpdisp,0,0,'','','',NaN,xlim,ylim,style2,marker2,rays{iy}.color,width2,siz);
	mask_abs = rays{iy}.mask_abs;
    graph1D_jd(rays{iy}.sx(mask_abs) + Rpdisp,rays{iy}.sy(mask_abs) + Zpdisp,0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    if ~isempty(rays{iy}.refs),
        for iref = 1:length(rays{iy}.refs),
            graph1D_jd(rays{iy}.refs{iref}.x + Rpdisp,rays{iy}.refs{iref}.y + Zpdisp,0,0,'','','',NaN,xlim,ylim,style,marker3,rays{iy}.color,width2,siz);
        end
    end 
end
if 0,%opt.res >= 1,
    [ax] = graph2D_jd(R + Rpdisp,Z + Zpdisp,yres','','','',xlim,ylim,0,NaN,[1:10],0,style,color5,width1,siz);
end
axis('equal');
axis([xlim,ylim]);
if strfind(equil.id,'TCV') & strcmp(opt.vessel_opt,'y')
   axis auto;
   set(gca,'XTick',[0:0.2:1.4],'YTick',[-0.8:0.2:0.8]);
end
%
figname = [waves{1}.equil_id,'-'];
for ii = 1:length(waves)
	figname = [figname,waves{ii}.id,'-'];
end
print_jd(opt.print,[figname,'Pol_traj'],'figures_WAVE');
%
if isfield(opt,'pol') && opt.pol == 1,
    return
end
%
figure(2),clf,set(2,'name','Toroidal trajectories')
%
xlim = [Xmin,Xmax];
ylim = [Ymin,Ymax];
xlab = 'X (m)';
ylab = 'Y (m)';
tit = '';
%
[ax] = graph1D_jd(X_disp',Y_disp',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color5,width2,siz,gca,red,lspace,bspace);
for iy = 1:ny,
    mask_max = 1:rays{iy}.is_abs_max;
    graph1D_jd(rays{iy}.sX(mask_max),rays{iy}.sY(mask_max),0,0,'','','',NaN,xlim,ylim,style2,marker2,rays{iy}.color,width2,siz);
	mask_abs = rays{iy}.mask_abs;
    graph1D_jd(rays{iy}.sX(mask_abs),rays{iy}.sY(mask_abs),0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    if ~isempty(rays{iy}.refs),
        for iref = 1:length(rays{iy}.refs),
            graph1D_jd(rays{iy}.refs{iref}.X,rays{iy}.refs{iref}.Y,0,0,'','','',NaN,xlim,ylim,style,marker3,rays{iy}.color,width2,siz);
        end
    end 
end
axis('equal');
axis([xlim,ylim]);
%
print_jd(opt.print,[figname,'Tor_traj'],'figures_WAVE');
%
smax = 0;
Nmax = 0;
Spmax = 0;
for iy = 1:ny,
    smax = max(smax,rays{iy}.ss(end));
    Nmax = max([Nmax,abs(real(rays{iy}.sNpar))]);
    Spmax = max([Spmax,abs(rays{iy}.sphi_xyz(1,:))]);
end
%
figure(3),clf,set(3,'name','Radius of deposition peak')
xlim = [0,ny+1];
ylim = [0,1];
xlab = 'ray #';
ylab = '\rho^{abs}';
tit = '';
%
graph1D_jd(1:ny,yrho_abs,0,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker1,color2,width1,siz,gca,red,lspace,bspace);
%
print_jd(opt.print,[figname,'Rad_dep_peak'],'figures_WAVE');
%
figure(4),clf,set(4,'name','N// of deposition peak')
xlim = [0,ny+1];
ylim = [0,Nmax];
xlab = 'ray #';
ylab = 'N_{||}^{abs}';
tit = '';
%
graph1D_jd(1:ny,abs(yNpar_abs),0,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker1,color2,width1,siz,gca,red,lspace,bspace);
%
print_jd(opt.print,[figname,'Npar_dep_peak'],'figures_WAVE');
%
figure(5),clf,set(5,'name','Total deposition profile')
xlim = [0,1];
ylim = NaN;
xlab = plab;
ylab = 'dPd\rho (MW)';
tit = '';
%
graph1D_jd(rho_dep,dPdrho/1e6,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width1,siz,gca,red,lspace,bspace);
%
print_jd(opt.print,[figname,'Tot_dep_prof'],'figures_WAVE');
%
% Ray specific figures
%
disp(' ')
disp('-----> Display specific ray information')
disp(' ')
%
iw = NaN;
ibb = NaN;
ib = 0;
iwdef = 1;
%
if isfield(opt,'nospec') && opt.nospec == 1,
    iw = 0;% no specific ray display
end
%
while iw ~= 0 && ibb ~= 0
    %
    ib = ib + 1;
    %
    iw = input_dke_yp('wave index (0 to return)',iwdef,0:nw,'',[1,1]);
    %
    if iw == 0,
        continue
    end
    %
    ibb = input_dke_yp('ray index (0 to return)',1,0:nymask(iw),'',[1,1]);
    %
    if ibb == 0,
        continue
    end
    %
    iwdef = 0;
    %
    iy = sum(nymask(1:iw - 1)) + ibb;
    %
    ray = rays{iy};
    %
    f_opt = input_dke_yp('single figure with subplots (0) or multiple figures (1)',0,0:1,'',[1,1]);
    %
    figlab = ['wave #',num2str(iw),'; ray #',num2str(ibb)];
    %
    if waves{iw}.opt_TeNpar == 1,
        %
        NparsTe = input_dke_yp('Value for N//*sqrt(Te)',6.5);
        %
    end
    %
    % poloidal ray trajectory
    %
    setfig(f_opt,ib,1,figlab)
    %
    xlim = [xmin,xmax];
    ylim = [ymin,ymax];
    xlab = 'x (m)';
    ylab = 'y (m)';
    tit = 'poloidal ray trajectory';
    %
    mask_max = 1:ray.is_abs_max;
    mask_abs = ray.mask_abs;
    %
    graph1D_jd(ptx_disp',pty_disp',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color5,width2,siz);
    graph1D_jd(ray.sx(mask_max),ray.sy(mask_max),0,0,'','','',NaN,xlim,ylim,style,marker,ray.color,width1,siz);
    graph1D_jd(ray.sx(mask_abs),ray.sy(mask_abs),0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    if ~isempty(ray.refs),
        for iref = 1:length(ray.refs),
            graph1D_jd(ray.refs{iref}.x,ray.refs{iref}.y,0,0,'','','',NaN,xlim,ylim,style,marker3,color5,width2,siz);
        end
    end 
    %
    axis('equal');
    axis([xlim,ylim]);
    %
    % toroidal ray trajectory
    %
    setfig(f_opt,ib,2,figlab)
    %
    xlim = [Xmin,Xmax];
    ylim = [Ymin,Ymax];
    xlab = 'X (m)';
    ylab = 'Y (m)';
    tit = 'toroidal ray trajectory';
    %
    graph1D_jd(X_disp',Y_disp',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color5,width2,siz);
    graph1D_jd(ray.sX(mask_max),ray.sY(mask_max),0,0,'','','',NaN,xlim,ylim,style,marker,ray.color,width1,siz);
    graph1D_jd(ray.sX(mask_abs),ray.sY(mask_abs),0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    if ~isempty(rays{iy}.refs),
        for iref = 1:length(ray.refs),
            graph1D_jd(ray.refs{iref}.X,ray.refs{iref}.Y,0,0,'','','',NaN,xlim,ylim,style,marker3,color5,width2,siz);
        end
    end 
    %
    axis('equal');
    axis([xlim,ylim]);
    %
    % parallel index of refraction
    %
    setfig(f_opt,ib,3,figlab)
    %
    xlim = [0,max(ray.ss)];
    ylim = [0,ceil(1.5*max(abs(real(ray.sNpar))))];
    xlab = 's (m)';
    ylab = 'N_{||}';
    tit = '';
    %
    graph1D_jd(ray.ss,abs(real(ray.sNpar)),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz);
    if waves{iw}.opt_TeNpar == 1,
        graph1D_jd(ray.ss,NparsTe./sqrt(ray.sTe),0,0,'','','',NaN,xlim,ylim,style3,marker,color2,width1,siz);
        leg = {'N_{||}',[num2str(NparsTe),'/Te^{1/2}'],'N_{||acc}'};
    else
        leg = {'N_{||}','N_{||acc}'};
    end
    graph1D_jd(ray.ss,abs(imag(ray.sNpar)),0,0,'','','',leg,xlim,ylim,style3,marker,color3,width2,siz);
    graph1D_jd(ray.ss(mask_abs),abs(real(ray.sNpar(mask_abs))),0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    %
    % perpendicular index of refraction
    %
    setfig(f_opt,ib,4,figlab)
    %
    ylab = 'N_{\perp}';
    ylim = NaN;
    %
    graph1D_jd(ray.ss,real(ray.sNperp),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz);
    graph1D_jd(ray.ss(mask_abs),real(ray.sNperp(mask_abs)),0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    %    
    % perpendicular normalized energy flow
    %
    setfig(f_opt,ib,5,figlab)
    %
    ylab = 'S_{\perp}';
    %
    %sphi_abs = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
    sphi_abs = abs(ray.sphi_xyz(1,:));
    %
    graph1D_jd(ray.ss,sphi_abs,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz);
    graph1D_jd(ray.ss(mask_abs),sphi_abs(mask_abs),0,0,'','','',NaN,xlim,ylim,style2,marker2,color5,width2,siz);
    %    
    % power deposition
    %
    setfig(f_opt,ib,6,figlab)
    %
    xlim = [0,1];
    xlab = plab;
    ylab = 'dP/d\rho/P_0';
    %
    graph1D_jd(rho_dep,ray.dPnormdrho.*drhog_dep./drho_dep,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color2,width1,siz);
    %
    if ~f_opt && opt.print >= 0,
        %
        figure(2000 + ib - 1);
        cpaxlist = copyobj(get(1000 + ib - 1,'children'),2000 + ib - 1);
        %
        set(2000 + ib - 1,'position',[0,0,600,900]),
        set(cpaxlist(1),'units','normalized','position',[0.65,0.1,0.3,0.2])
        set(cpaxlist(2),'units','normalized','position',[0.15,0.1,0.3,0.2])
        set(cpaxlist(3),'units','normalized','position',[0.65,0.4,0.3,0.2])
        set(cpaxlist(4),'units','normalized','position',[0.35,0.525,0.1,0.1])
        set(cpaxlist(5),'units','normalized','position',[0.15,0.4,0.3,0.2])
        set(cpaxlist(6),'units','normalized','position',[0.65,0.7,0.3,0.2])
        set(cpaxlist(7),'units','normalized','position',[0.15,0.7,0.3,0.2])    
        %
    	print_jd(opt.print,[figname,'Wave_',num2str(iw),'_Ray_',num2str(ibb)],'figures_WAVE');	
    end
end
%
return
%
function setfig(f_opt,ib,ifig,figlab)
%
if f_opt == 1,
    %
    fignum = 10*(ib - 1) + 9 + ifig;
    figure(fignum),clf,set(fignum,'name',[figlab,'; fig ',num2str(ifig)])
    %
else
    %
    fignum = 1000 + ib - 1;
    figure(fignum)
    if ifig == 1,
        clf,
        set(gcf,'resize','on'),
        set(gcf,'units','normalized'),
        %
        set(gcf,'position',[0,0,1,1]),
        set(fignum,'name',figlab)
    end    
    %
    subplot(2,3,ifig),%cla
    %
end
%
return


















% figure(2),clf
% %
% xlim = [-Rmax,Rmax];
% ylim = [-Rmax,Rmax];
% xlab = 'X (m)';
% ylab = 'Y (m)';
% tit = '';
% %
% [ax] = graph1D_jd(syX,syY,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz);
% if exist('launch','var') == 1,
%     [ax] = graph1D_jd(yX_L,yY_L,0,0,'','','',NaN,xlim,ylim,style2,marker2,color3,width2,siz);
%     [ax] = graph1D_jd([yX_L;yX_L + ydX_L],[yY_L;yY_L + ydY_L],0,0,'','','',NaN,xlim,ylim,style,marker,color3,width2,siz);
% end
% if exist('wave_s','var') == 1,
%     [ax] = graph1D_jd(syX_s,syY_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
% end
% if opt(2) >= 1,
%     [ax] = graph1D_jd(syX(is_syres),syY(is_syres),0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
% end
% [ax] = graph1D_jd(X_disp',Y_disp',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
% axis('equal');
% axis([xlim,ylim])
% %
% % ------------------------
% %
% if xvar == 's',
%     xlab = 's (m)';
%     x_disp = sys;
%     if exist('wave_s','var') == 1,
%         x_disp_s = sys_s;
%     end
%     xlim = [0,smax];
% elseif xvar == 'R',
%     xlab = 'R (m)';
%     x_disp = syR;
%     if exist('wave_s','var') == 1,
%         x_disp_s = syR_s;
%     end
%     xlim = [Rmin,Rmax];
% elseif xvar == 'p',
%     xlab = '(\psi/\psi_a)^{1/2}';
%     x_disp = sqrt(sypsin);
%     if exist('wave_s','var') == 1,
%         x_disp_s = sqrt(sypsin_s);
%     end
%     xlim = [0,1];
% elseif xvar == 'r',
%     xlab = '\rho';
%     x_disp = syrho;
%     if exist('wave_s','var') == 1,
%         x_disp_s = syrho_s;
%     end
%     xlim = [0,1];
% end
% %
% figure(3),clf
% %
% ylim = NaN;
% ylab = 'N_{||}';
% tit = '';
% %
% if opt(1) == 1 & ~isempty(sydNpar)
%     [ax] = graph1D_jd([x_disp,x_disp],[syNpar + sydNpar,syNpar - sydNpar],0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz);
% end
% if exist('wave_s','var') == 1,
%     [ax] = graph1D_jd(x_disp_s,syNpar_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
% end
% if opt(2) >= 1,
%     [ax] = graph1D_jd(x_disp(is_syres),syNpar(is_syres),0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
% end
% [ax] = graph1D_jd(x_disp,syNpar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);    
% %
% figure(4),clf
% %
% ylim = NaN;
% ylab = 'N_{\perp}';
% tit = '';
% %
% if exist('wave_s','var') == 1,
%     [ax] = graph1D_jd(x_disp_s,syNperp_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
% end
% if opt(2) >= 1,
%     [ax] = graph1D_jd(x_disp(is_syres),syNperp(is_syres),0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
% end
% [ax] = graph1D_jd(x_disp,syNperp,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
% %
% if exist('launch','var') == 1,
%     figure(5),clf
% %
%     xlim_L = [min([yphi_L,0]),max([yphi_L,0])]*1.1*180/pi;
%     ylim_L = [min([yZ_L,0]),max([yZ_L,0])]*1.1;
%     xlab_L = '\phi_L (deg.)';
%     ylab = 'Z_L (m)';
%     tit = '';
% %
%     [ax] = graph1D_jd(yphi_L*180/pi,yZ_L,0,0,xlab_L,ylab,tit,NaN,xlim_L,ylim_L,style2,marker2,color3,width2,siz,gca,red,lspace,bspace);
%     for iy = 1:ny
%         text(yphi_L(iy)*180/pi,yZ_L(iy),['\alpha_L = ',num2str(round(yalpha_L(iy)*180/pi)),'\newline\beta_L = ',num2str(round(ybeta_L(iy)*180/pi))],'fontsize',10);
%     end
% end
% %
% if opt(3) >= 1,
%     figure(6),clf
%     %
%     ylim = [0,1.1];
%     ylab = 'P^b/P_0^b';
%     tit = '';
%     %
%     if exist('wave_s','var') == 1,
%         [ax] = graph1D_jd(x_disp_s,syPinc_s./(ones(ns_s,1)*yP0_s),0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
%     end
%     if opt(2) >= 1,
%         [ax] = graph1D_jd(x_disp(is_syres),syPinc(is_syres)./missing,0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
%     end
%     [ax] = graph1D_jd(x_disp,syPinc./(ones(ns,1)*yP0),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
%     %
%     figure(7),clf
%     %
%     ylim = NaN;
%     ylab = 'dP^b/ds/P_0^b (m^{-1})';
%     tit = '';
%     %
%     if exist('wave_s','var') == 1,
%         [ax] = graph1D_jd(x_disp_s,sydPincds_s./(ones(ns_s,1)*yP0_s),0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
%     end
%     if opt(2) >= 1,
%         [ax] = graph1D_jd(x_disp(is_syres),sydPincds(is_syres)./missing,0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
%     end
%     [ax] = graph1D_jd(x_disp,sydPincds./(ones(ns,1)*yP0),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
%     %
% end
% %
% if (opt(2) >=1 | opt(3) >= 1) & ny == 1% only one ray
%     %
%     figure(8),clf
%     %
%     ylim = [0,(ceil(omega_rf_ghz/10) + 1)*10];
%     ylab = '\omega/(2\pi) (GHz)';
%     tit = '';
%     str_vparn = [num2str(vparn),'  '];
%     leg = ['n\omega_{ce}                         ';...
%            'n\omega_{ce} \pm ',str_vparn(1:3),'v_{Te}\cdotk_{//}'];
%     %
%     graph1D_jd(x_disp,Nsomega_ce_ghz(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width1,siz,gca,red,lspace,bspace);
%     graph1D_jd(x_disp,Nsomega_ce_ghz_m(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1);
%     graph1D_jd(x_disp,Nsomega_ce_ghz(:,2:N),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width1);
%     graph1D_jd(x_disp,Nsomega_ce_ghz_m(:,2:N),0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1);
%     graph1D_jd(x_disp,Nsomega_ce_ghz_p,0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1);
%     graph1D_jd(xlim,[omega_rf_ghz,omega_rf_ghz],0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color1,width1);
%     %
% end
% %
% if opt(4) >=1
%     %
%     figure(9),clf
%     %
%     ylim = NaN;
%     ylab = 'N_{||}';
%     tit = '';
% %
%     [ax] = graph1D_jd(x_disp(:,1),syNpar(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width1,siz);
%     [ax] = graph1D_jd([x_disp(:,1),x_disp(:,1)],[syNpar(:,1)-sdNpar',syNpar(:,1)+sdNpar'],0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1,siz);
%     [ax] = graph1D_jd(x_disp,syNpar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width2,siz,gca,red,lspace,bspace);    
%     %
% end


