function graph_wave_jd(equil,waves,rayinits,n_rf_list,opt,rho_disp,ymask,xvar,colors)
%
% This function plots the characteristics of wave data
%
% by J. Decker 02/04/03
%
if nargin < 9
    colors = {'b','r',[0,0.5,0],'m','c'};
end
if nargin < 8
    xvar = 's';
end
if nargin < 7
    ymask = NaN;
end
if nargin < 6
    rho_disp = [0:0.1:1];
end
%
%clear all
%load toto
%
nr_dep = 100;
%
if isnan(ymask),
    ymask = '';
    for iw = length(waves),
        ymask{iw} = 1:length(waves{iw}.rays);
    end
end
%
if isnumeric(n_rf_list),
    n_rf_list_gen = n_rf_list;
    n_rf_list = '';
    for iw = length(waves),
        n_rf_list{iw} = n_rf_list_gen;
    end
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
method = 'cubic';
format
n_ec = 2;% to be automatized
N = 5;
vparn = 6;
%
% Equilibrium
%
Rp = equil.Rp;
Zp = equil.Zp;
ptx = equil.ptx;
pty = equil.pty;
ptBx = equil.ptBx;
ptBy = equil.ptBy;
ptBPHI = equil.ptBPHI;
theta = equil.theta;
psi_apRp = equil.psi_apRp;
%
[np,nt] = size(ptx);
psin = psi_apRp/psi_apRp(end);
%
ap =  ptx(end,1);%Plasma minor radius on the LFS midplane 
%
if xvar == 's',%rho defined as r/a on LFS midplane
    prho = ptx(:,1)/ap;
    plab = 'r/a';
elseif xvar == 'p',%rho defined as square root of poloidal flux
    prho = sqrt(ppsin);
    plab = '\psi_n^{1/2}';
elseif xvar == 't',%rho defined as square root of toroidal flux
    %
end
%
ptB = sqrt(ptBx.^2 + ptBy.^2 + ptBPHI.^2);% total magnetic field
ptr = sqrt(ptx.^2 + pty.^2); %minor radius on the (psi,stheta) grid
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
% Wave
%
iy = 0;
rays = '';
for iw = 1:length(waves),
    for ib = ymask{iw},
        iy = iy + 1; 
        rays{iy} = waves{iw}.rays{ib};
        rays{iy}.omega_rf = waves{iw}.omega_rf;
        rays{iy}.color = colors{iw};
        if isempty(rayinits{iw}),
            rays{iy}.init = '';
        else
            rays{iy}.init.rho0 = rayinits{iw}.yrho0(ib);
            rays{iy}.init.theta0 = rayinits{iw}.ytheta0(ib);
            rays{iy}.init.phi0 = rayinits{iw}.yphi0(ib);
            rays{iy}.init.m0 = rayinits{iw}.ym0(ib);
            rays{iy}.init.Npar0 = rayinits{iw}.yNpar0(ib);
            rays{iy}.init.dNpar0 = rayinits{iw}.ydNpar0(ib);
            rays{iy}.init.P0_2piRp = rayinits{iw}.yP0_2piRp(ib);
        end
        %    
    end
end
ny = iy;
      

% omega_rf = wave.omega_rf;
% nb = length(wave.rays);
% if isnan(ymask),
%     ymask = 1:nb;
% end
% %
% ny = length(ymask);
% %
% for ib = 1:ny
%     ray = wave.rays{ymask(ib)};
%     yP0(ib) = ray.P0;
%     syR(1:length(ray.sR),ib) = ray.sR';
%     syphi(1:length(ray.sphi),ib) = ray.sphi';
%     syZ(1:length(ray.sZ),ib) = ray.sZ';
%     sys(1:length(ray.ss),ib) = ray.ss';
%     sypsin(1:length(ray.spsin),ib) = ray.spsin';
%     sytheta(1:length(ray.stheta),ib) = ray.stheta';
%     sykR(1:length(ray.skR),ib) = ray.skR';
%     syn(1:length(ray.sn),ib) = ray.sn';
%     sykZ(1:length(ray.skZ),ib) = ray.skZ';
%     syNpar(1:length(ray.sNpar),ib) = ray.sNpar';
%     syNperp(1:length(ray.sNperp),ib) = ray.sNperp';
%     sydNpar(1:length(ray.sdNpar),ib) = ray.sdNpar';
%     syepol_pmz(1:length(ray.sepol_pmz),:,ib) = ray.sepol_pmz';
%     syphi_pmz(1:length(ray.sphi_pmz),:,ib) = ray.sphi_pmz';
% end
% %
% if ~isempty(syR) & ~isempty(syphi) & ~isempty(syZ),
%     ns = size(syR,1);
%     syX = syR.*cos(syphi);
%     syY = syR.*sin(syphi);
%     if isempty(sys)
%         sys(1,:) = 0;
%         syRh = (syR(1:ns-1,:) + syR(2:ns,:))/2;
%         dsys = sqrt(diff(syR).^2 + (syRh.*diff(syphi)).^2 + diff(syZ).^2);
%         sys(2:ns) = cumsum(dsys);
%     end
% elseif ~isempty(sypsin) & ~isempty(sytheta) & ~isempty(sys)
%     ns = size(sypsin,1);
%     syR = interp2(theta,ppsin,R,sytheta,sypsin,method);
%     syZ = interp2(theta,ppsin,Z,sytheta,sypsin,method);
%     if ~isempty(syNpar)
%         sysigmah = sign((syNpar(1:ns-1,:) + syNpar(2:ns,:))/2);
%     elseif ~isempty(syn)
%         sysigmah = sign((syn(1:ns-1,:) + syn(2:ns,:))/2);
%     else
%         error('propagation data is imcomplete')
%     end
%     syphi(1,:) = 0;
%     syRh = (syR(1:ns-1,:) + syR(2:ns,:))/2;
%     dsyphi = sqrt(diff(sys).^2 - diff(syRh).^2 - diff(syZ).^2)./syRh.*sysigmah;
%     syphi(2:ns) = cumsum(dsyphi);
%     syX = syR.*cos(syphi);
%     syY = syR.*sin(syphi);
% else
%     error('propagation data is imcomplete')
% end
% %
% smax = max(max(sys));
% %
% if isempty(syNpar) | isempty(syNperp),
%     if isempty(sykR) | isempty(syn) | isempty(sykZ) 
%         error('Ray-tracing data incomplete')
%     end
%     if ~isempty(sytheta) & ~isempty(sypsin)        
%         syBR = interp2(theta,ppsin,BR,sytheta,sypsin,method);
%         syBphi = interp2(theta,ppsin,BPHI,sytheta,sypsin,method);
%         syBZ = interp2(theta,ppsin,BZ,sytheta,sypsin,method);
%     else
%       for ib = 1:ny
%         %
%         % ray position in (r,theta) coordinates
%         %
%         sR = syR(:,ib) + eps*(syR(:,ib) == Rp); %to avoid singularities
%         sZ = syZ(:,ib) + eps*(syZ(:,ib) == Zp); %to avoid singularities
%         sr = sqrt((sR - Rp).^2 + (sZ - Zp).^2); %minor radius
%         stheta = atan((sZ - Zp)./(sR - Rp)) + pi - pi*(sR > Rp).*sign(sZ - Zp); %poloidal angle [0,2*pi]
%         %
%         % interpolation for r at ray poloidal locations    
%         %
%         psr = interp1(theta,r',stheta,method)';%r(psi,st)
%         %
%         % interpolation for psi at ray position (along cst theta lines)
%         %
%         %spsin = interp1(pstr,ppsin,sr,method);%psi(s)
%         method2 = 'linear';
%         for is = 1:ns 
%             spsin(is,1) = interp1(psr(:,is),ppsin,sr(is),method2);%psi(s)
%         end
%         %
%         imask_1 = min(find(~isnan(spsin)));
%         imask_2 = min(find(isnan(spsin(imask_1:ns))));
%         mask = [1:(imask_1 - 1),(imask_1 + imask_2 - 1):ns];
%         %
%         spsin(mask) = 1;%part of ray outside the last flux-surface
%         %
%         sBR = interp2(theta,ppsin,BR,stheta,spsin,method);
%         sBphi = interp2(theta,ppsin,BPHI,stheta,spsin,method);
%         sBZ = interp2(theta,ppsin,BZ,stheta,spsin,method);
%         %
%         %sne = interp1(ppsin,equil.pne,spsin,method);
%         %szni = interp1(ppsin,equil.pzni',spsin,method)';
%         %sTe = interp1(ppsin,equil.pTe,spsin,method);
%         %szTi = interp1(ppsin,equil.pzTi',spsin,method)';
%         %
%         sypsin(1:ns,ib) = spsin;
%         sytheta(1:ns,ib) = stheta;
%         syBR(:,ib) = sBR;
%         syBphi(:,ib) = sBphi;
%         syBZ(:,ib) = sBZ;
%         %syne(:,ib) = sne;
%         %syTe(:,ib) = sTe;
%         %siyzni(:,:,ib) = szni';
%         %
%         syR(mask,ib) = NaN;
%         syphi(mask,ib) = NaN;
%         syZ(mask,ib) = NaN;
%         sys(mask,ib) = NaN;
%         sys(:,ib) = sys(:,ib) - sys(imask_1,ib);
%         sykR(mask,ib) = NaN;
%         syn(mask,ib) = NaN;
%         sykZ(mask,ib) = NaN;
%         syNperp(mask,ib) = NaN;
%         sydNpar(mask,ib) = NaN;
%         syX(mask,ib) = NaN;
%         syY(mask,ib) = NaN;
%         syr(mask,ib) = NaN;
%         sytheta(mask,ib) = NaN;
%         sypsin(mask,ib) = NaN;
%         syBR(mask,ib) = NaN;
%         syBphi(mask,ib) = NaN;
%         syBZ(mask,ib) = NaN;
%         %syne(mask,ib) = NaN;
%         %syTe(mask,ib) = NaN;
%         %siyzni(mask,:,ib) = NaN;
%         %    
%       end
%     end
%     %
%     sykpar = (sykR.*syBR + syn.*syBphi./syR + sykZ.*syBZ)./sqrt(syBR.^2 + syBphi.^2 + syBZ.^2);
%     sykperp = sqrt(sykR.^2 + (syn./syR).^2 + sykZ.^2 - sykpar.^2);
%     %
%     syNpar = sykpar*clum/omega_rf;
%     %syNperp = sykperp*clum/omega_rf;
% end  
% %
% % Wave with straight ray propagation
% %
% if exist('wave_s','var') == 1, 
%     omega_rf_s = wave_s.omega_rf;
%     if omega_rf_s ~= omega_rf
%         error('The wave frequencies do not match')
%     end
%     nb_s = length(wave_s.rays);
%     if nb_s ~= nb
%         error('The wave number of rays do not match')
%     end
%     for ib = 1:ny
%         ray_s = wave_s.rays{ymask(ib)};
%         yP0_s(ib) = ray_s.P0;
%         syR_s(1:length(ray_s.sR),ib) = ray_s.sR';
%         syphi_s(1:length(ray_s.sphi),ib) = ray_s.sphi';
%         syZ_s(1:length(ray_s.sZ),ib) = ray_s.sZ';
%         sys_s(1:length(ray_s.ss),ib) = ray_s.ss';
%         sykR_s(1:length(ray_s.skR),ib) = ray_s.skR';
%         syn_s(1:length(ray_s.sn),ib) = ray_s.sn';
%         sykZ_s(1:length(ray_s.skZ),ib) = ray_s.skZ';
%         syNperp_s(1:length(ray_s.sNperp),ib) = ray_s.sNperp';
%         sydNpar_s(1:length(ray_s.sdNpar),ib) = ray_s.sdNpar';
%     end
%     %
%     ns_s= size(syR_s,1);
%     syX_s = syR_s.*cos(syphi_s);
%     syY_s = syR_s.*sin(syphi_s);
%     %
%     for ib = 1:ny
%         %
%         % ray position in (r,theta) coordinates
%         %
%         sR_s = syR_s(:,ib) + eps*(syR_s(:,ib) == Rp); %to avoid singularities
%         sZ_s = syZ_s(:,ib) + eps*(syZ_s(:,ib) == Zp); %to avoid singularities
%         sr_s = sqrt((sR_s - Rp).^2 + (sZ_s - Zp).^2); %minor radius
%         stheta_s = atan((sZ_s - Zp)./(sR_s - Rp)) + pi - pi*(sR_s > Rp).*sign(sZ_s - Zp); %poloidal angle [0,2*pi]
%         %
%         % interpolation for r at ray poloidal locations    
%         %
%         psr_s = interp1(theta,r',stheta_s,method)';%r(psi,st)
%         %
%         % interpolation for psi at ray position (along cst theta lines)
%         %
%         %spsin = interp1(pstr,ppsin,sr,method);%psi(s)
%         method2 = 'linear';
%         for is = 1:ns_s 
%             spsin_s(is,1) = interp1(psr_s(:,is),ppsin,sr_s(is),method2);%psi(s)
%         end
%         %
%         imask_s_1 = min(find(~isnan(spsin_s)));
%         imask_s_2 = min(find(isnan(spsin_s(imask_s_1:ns_s))));
%         mask_s = [1:(imask_s_1 - 1),(imask_s_1 + imask_s_2 - 1):ns_s];
%         %
%         spsin_s(mask_s) = 1;%part of ray outside the last flux-surface
%         %
%         sBR_s = interp2(theta,ppsin,BR,stheta_s,spsin_s,method);
%         sBphi_s = interp2(theta,ppsin,BPHI,stheta_s,spsin_s,method);
%         sBZ_s = interp2(theta,ppsin,BZ,stheta_s,spsin_s,method);
%         %
%         sne_s = interp1(ppsin,equil.pne,spsin_s,method);
%         szni_s = interp1(ppsin,equil.pzni',spsin_s,method)';
%         sTe_s = interp1(ppsin,equil.pTe,spsin_s,method);
%         %szTi_s = interp1(ppsin,equil.pzTi',spsin_s,method)';
%         %
%         sypsin_s(:,ib) = spsin_s;
%         sytheta_s(:,ib) = stheta_s;
%         syBR_s(:,ib) = sBR_s;
%         syBphi_s(:,ib) = sBphi_s;
%         syBZ_s(:,ib) = sBZ_s;
%         syne_s(:,ib) = sne_s;
%         syTe_s(:,ib) = sTe_s;
%         siyzni_s(:,:,ib) = szni_s';
%         %
%         syR_s(mask_s,ib) = NaN;
%         syphi_s(mask_s,ib) = NaN;
%         syZ_s(mask_s,ib) = NaN;
%         sys_s(mask_s,ib) = NaN;
%         sys_s(:,ib) = sys_s(:,ib) - sys_s(imask_s_1,ib);
%         sykR_s(mask_s,ib) = NaN;
%         syn_s(mask_s,ib) = NaN;
%         sykZ_s(mask_s,ib) = NaN;
%         syNperp_s(mask_s,ib) = NaN;
%         sydNpar_s(mask_s,ib) = NaN;
%         syX_s(mask_s,ib) = NaN;
%         syY_s(mask_s,ib) = NaN;
%         syr_s(mask_s,ib) = NaN;
%         sytheta_s(mask_s,ib) = NaN;
%         sypsin_s(mask_s,ib) = NaN;
%         syBR_s(mask_s,ib) = NaN;
%         syBphi_s(mask_s,ib) = NaN;
%         syBZ_s(mask_s,ib) = NaN;
%         syne_s(mask_s,ib) = NaN;
%         syTe_s(mask_s,ib) = NaN;
%         siyzni_s(mask_s,:,ib) = NaN;
%         %    
%     end
%     sykpar_s = (sykR_s.*syBR_s + syn_s.*syBphi_s./syR_s + sykZ_s.*syBZ_s)./sqrt(syBR_s.^2 + syBphi_s.^2 + syBZ_s.^2);
%     syNpar_s = sykpar_s*clum/omega_rf_s;
%     %
%     syB_s = sqrt(syBR_s.^2 + syBphi_s.^2 + syBZ_s.^2);
%     for ib = 1:ny
%         %
%         % cold plasma dispersion tensor for sepol_pmz, sNperp and phi_pmz (colddisp_dke_jd)
%         %
%         for is = 1:ns_s
%             if ~isnan(syNpar_s(is,ib))
%                 [Nperpp_s,Nperpm_s,sKxyz_s,sep_xyz_s,sem_xyz_s,sep_pmz_s,sem_pmz_s,sep_pyk_s,sem_pyk_s,sphip_xyz_s,sphim_xyz_s,sphip_pmz_s,sphim_pmz_s] = colddisp_dke_jd(syNpar_s(is,ib),omega_rf_s,syne_s(is,ib),siyzni_s(is,:,ib),equil.zZi,equil.zmi,syB_s(is,ib));
%                 maskp_s = (abs(Nperpp_s - syNperp_s(is,ib)) <= abs(Nperpm_s - syNperp_s(is,ib)));
%                 syNperp_s(is,ib) = Nperpp_s.*maskp_s + Nperpm_s.*~maskp_s;
%                 syepol_pmz_s(is,1:3,ib) = sep_pmz_s'.*maskp_s + sem_pmz_s'.*~maskp_s;
%                 syphi_pmz_s(is,1:3,ib) = sphip_pmz_s'.*maskp_s + sphim_pmz_s'.*~maskp_s;
%             else
%                 syNperp_s(is,ib) = NaN;
%                 syepol_pmz_s(is,1:3,ib) = NaN;
%                 syphi_pmz_s(is,1:3,ib) = NaN;                
%             end
%         end
%         
%     end
% %
% end
%
% Launching
%
for iy = 1:ny,
    init = rays{iy}.init;
    if ~isempty(init),
        psin0 = rho2psi_jd(equil,init.rho0);
        init.x0 = interp2(psin,theta,ptx.',psin0,init.theta0,method);
        init.y0 = interp2(psin,theta,pty.',psin0,init.theta0,method);
    end
    rays{iy}.init = init;
end
    
%
% Damping
%
rho_dep_S = linspace(0,1,nr_dep+1);
rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
drho_dep = diff(rho_dep_S);
%
yrho_abs = zeros(1,ny);
yPtot_abs = zeros(1,ny);
yNpar_abs = zeros(1,ny);
%
for iy = 1:ny,
    ns = length(rays{iy}.ss);
    if isfield(rays{iy},'sP_2piRp'),
        sP_2piRp_norm = rays{iy}.sP_2piRp/rays{iy}.sP_2piRp(1);
        sdP_2piRp_ds_norm = rays{iy}.sdP_2piRp_ds/max(rays{iy}.sdP_2piRp_ds+eps);
        rays{iy}.mask_abs = find(sdP_2piRp_ds_norm > 0.01);
        if opt.abs_max == 1,
            rays{iy}.is_abs_max = min([ns,find(sP_2piRp_norm < 0.001)]);        
        else
            rays{iy}.is_abs_max = ns;
        end
        rays{iy}.is_abs = find(sdP_2piRp_ds_norm == max(sdP_2piRp_ds_norm)); 
        rays{iy}.is_abs = rays{iy}.is_abs(1);
        srho = psi2rho_jd(equil,rays{iy}.spsin);
        yrho_abs(iy) = srho(rays{iy}.is_abs);
        yNpar_abs(iy) = rays{iy}.sNpar(rays{iy}.is_abs);
        yPtot_abs(iy) = 1 - sP_2piRp_norm(end);
        %
        rays{iy}.dPnormdrho = zeros(1,nr_dep);
        srhop = srho(1);
        irho_depp = find(srhop > rho_dep_S(1:end-1) & srhop <= rho_dep_S(2:end));
        for is = 2:ns,
            srhom = srhop;
            irho_depm = irho_depp;
            srhop = srho(is);
            irho_depp = find(srhop > rho_dep_S(1:end-1) & srhop <= rho_dep_S(2:end));
            sPm = sP_2piRp_norm(is-1);
            sPp = sP_2piRp_norm(is);
            %
            if is == 302,
                is = 302;
            end
            
            %
            if irho_depm == irho_depp,
                rays{iy}.dPnormdrho(irho_depm) = rays{iy}.dPnormdrho(irho_depm) + ...
                    (sPm - sPp)/drho_dep(irho_depm);
            elseif srhop > srhom,
                rays{iy}.dPnormdrho(irho_depm) = rays{iy}.dPnormdrho(irho_depm) + ...
                    (sPm - sPp)*(rho_dep_S(irho_depm + 1) - srhom)/(srhop - srhom)/drho_dep(irho_depm);
                rays{iy}.dPnormdrho(irho_depm+1:irho_depp-1) = rays{iy}.dPnormdrho(irho_depm+1:irho_depp-1) + ...
                    (sPm - sPp)*(rho_dep_S(irho_depm+2:irho_depp) - rho_dep_S(irho_depm+1:irho_depp-1))/(srhop - srhom)./drho_dep(irho_depm+1:irho_depp-1);
                rays{iy}.dPnormdrho(irho_depp) = rays{iy}.dPnormdrho(irho_depp) + ...
                    (sPm - sPp)*(srhop - rho_dep_S(irho_depp))/(srhop - srhom)/drho_dep(irho_depm);
            else
                rays{iy}.dPnormdrho(irho_depm) = rays{iy}.dPnormdrho(irho_depm) + ...
                    (sPm - sPp)*(srhom - rho_dep_S(irho_depm))/(srhom - srhop)/drho_dep(irho_depm);
                rays{iy}.dPnormdrho(irho_depp+1:irho_depm-1) = rays{iy}.dPnormdrho(irho_depp+1:irho_depm-1) + ...
                    (sPm - sPp)*(rho_dep_S(irho_depp+2:irho_depm) - rho_dep_S(irho_depp+1:irho_depm-1))/(srhom - srhop)./drho_dep(irho_depp+1:irho_depm-1);
                rays{iy}.dPnormdrho(irho_depp) = rays{iy}.dPnormdrho(irho_depp) + ...
                    (sPm - sPp)*(rho_dep_S(irho_depp + 1) - srhop)/(srhom - srhop)/drho_dep(irho_depm);
            end     
        end
        %
        info_dke_yp(2,['radial damping of ray #',num2str(iy),' calculated']);
    else
        rays{iy}.is_abs_max = ns
    end
end
yPtot_abs  
%     rho0
%     theta0
%     phi0
%     m0
%     Npar0
%     dNpar0
%     P0_2piRp
% 
%     yX_L = launch.yX_L(ymask);
%     yY_L = launch.yY_L(ymask);
%     yZ_L = launch.yZ_L(ymask);
%     ybeta_L = launch.ybeta_L(ymask);
%     yalpha_L = launch.yalpha_L(ymask);
%     %
%     yR_L = sqrt(yX_L.^2 + yY_L.^2);
%     yphi_L = atan(yY_L./yX_L);
%     %
%     for ib=1:ny,
%         yis = min(find(~isnan(sypsin(:,ib))));
%         if isempty(yis)
%             yis = 1;
%         end
%         ydX_L = syX(yis,:) - yX_L;
%         ydY_L = syY(yis,:) - yY_L;
%         ydZ_L = syZ(yis,:) - yZ_L;
%     end
%     %
%     yd_L = sqrt((ydX_L).^2 + (ydY_L).^2 + (ydZ_L).^2);
%     ydR_L = yd_L.*sin(ybeta_L).*cos(yalpha_L);
%     ydphi_L = yd_L.*sin(ybeta_L).*sin(yalpha_L);
%     %
%     Rmin = min([Rmin,yR_L]);
%     Rmax = max([Rmax,yR_L]);
%     Zmin = min([Zmin,yZ_L]);
%     Zmax = max([Zmax,yZ_L]);

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
siz = 20;
red = 0.9;
lspace = 0.7;
bspace = 0.7;
%
figure(1),clf
%
xlim = [xmin,xmax];
ylim = [ymin,ymax];
xlab = 'x (m)';
ylab = 'y (m)';
tit = '';
%
[ax] = graph1D_jd(ptx_disp',pty_disp',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color5,width2,siz,gca,red,lspace,bspace);
for iy = 1:ny,
    mask_max = 1:rays{iy}.is_abs_max;
    graph1D_jd(rays{iy}.sx(mask_max),rays{iy}.sy(mask_max),0,0,'','','',NaN,xlim,ylim,style,marker,rays{iy}.color,width1,siz);
    if isfield(rays{iy},'mask_abs'),
        mask_abs = rays{iy}.mask_abs;
        graph1D_jd(rays{iy}.sx(mask_abs),rays{iy}.sy(mask_abs),0,0,'','','',NaN,xlim,ylim,style,marker,color5,width1,siz);
    end
    if ~isempty(rays{iy}.init),
        graph1D_jd(rays{iy}.init.x0,rays{iy}.init.y0,0,0,'','','',NaN,xlim,ylim,style2,marker3,rays{iy}.color,width2,siz);
    end        
end
if exist('launch','var') == 1,
    [ax] = graph1D_jd([yR_L;yR_L + ydR_L],[yZ_L;yZ_L + ydZ_L],0,0,'','','',NaN,xlim,ylim,style,marker,color3,width2,siz);
end
if exist('wave_s','var') == 1,
    [ax] = graph1D_jd(syR_s,syZ_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
end
if 0,opt.res >= 1,
    [ax] = graph2D_jd(R,Z,yres','','','',xlim,ylim,0,NaN,[1:10],0,style,color5,width1,siz);
end
axis('equal');
axis([xlim,ylim]);
%
%
% subplot frame
%
if ny == 1,nl = 1;nc = 1;
elseif ny == 2,nl = 1;nc = 2;
elseif ny <= 4,nl = 2;nc = 2;
elseif ny <= 6,nl = 2;nc = 3;
elseif ny <= 8,nl = 2;nc = 4;
elseif ny == 9,nl = 3;nc = 3;
elseif ny <= 12,nl = 3;nc = 4;
elseif ny <= 15,nl = 3;nc = 5;
elseif ny == 16,nl = 4;nc = 4;
elseif ny <= 18,nl = 3;nc = 6;
elseif ny <= 20,nl = 4;nc = 5;
elseif ny <= 24,nl = 4;nc = 6;
elseif ny == 25,nl = 5;nc = 5;
elseif ny <= 28,nl = 4;nc = 7;
elseif ny <= 30,nl = 5;nc = 6;
elseif ny <= 32,nl = 4;nc = 8;
elseif ny <= 35,nl = 5;nc = 7;end
%
smax = 0;
Nmax = 0;
for iy = 1:ny,
    smax = max(smax,rays{iy}.ss(end));
    Nmax = max([Nmax,abs(rays{iy}.sNpar(end))]);
end
%
figure(2),clf
xlim = [0,smax];
ylim = [0,Nmax];
xlab = 's (m)';
ylab = '';
tit = '';
%
for iy = 1:ny,
    txt = ['ray #',num2str(iy)];
    subplot(nl,nc,iy),
    graph1D_jd(rays{iy}.ss,abs(rays{iy}.sNpar),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz);
    text(0,0,txt)
    if opt.TeNpar == 1,
        graph1D_jd(rays{iy}.ss,6.5./sqrt(rays{iy}.sTe),0,0,'','','',NaN,xlim,ylim,style3,marker,color2,width1,siz);
    end
    if isfield(rays{iy},'mask_abs'),
        mask_abs = rays{iy}.mask_abs;
        graph1D_jd(rays{iy}.ss(mask_abs),abs(rays{iy}.sNpar(mask_abs)),0,0,'','','',NaN,xlim,ylim,style,marker,color5,width1,siz);
    end
end
%
set(gcf,'resize','on')
%
figure(3),clf
xlim = [0,1];
ylim = NaN;
xlab = '\rho';
ylab = '';%'dP/d\rho/P_0';
tit = '';
%
for iy = 1:ny,
    txt = ['ray #',num2str(iy)];
    subplot(nl,nc,iy),
    graph1D_jd(rho_dep,rays{iy}.dPnormdrho,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color2,width1,siz);
    text(0,0,txt)
end
%
set(gcf,'resize','on')
%
figure(4),clf
xlim = [0,ny+1];
ylim = [0,1];
xlab = 'ray #';
ylab = '\rho^{abs}';
tit = '';
%
graph1D_jd(1:ny,yrho_abs,0,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker1,color2,width1,siz,gca,red,lspace,bspace);
%
figure(5),clf
xlim = [0,ny+1];
ylim = [0,Nmax];
xlab = 'ray #';
ylab = 'N_{||}^{abs}';
tit = '';
%
graph1D_jd(1:ny,abs(yNpar_abs),0,0,xlab,ylab,tit,NaN,xlim,ylim,style2,marker1,color2,width1,siz,gca,red,lspace,bspace);

return
%
figure(2),clf
%
xlim = [-Rmax,Rmax];
ylim = [-Rmax,Rmax];
xlab = 'X (m)';
ylab = 'Y (m)';
tit = '';
%
[ax] = graph1D_jd(syX,syY,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz);
if exist('launch','var') == 1,
    [ax] = graph1D_jd(yX_L,yY_L,0,0,'','','',NaN,xlim,ylim,style2,marker2,color3,width2,siz);
    [ax] = graph1D_jd([yX_L;yX_L + ydX_L],[yY_L;yY_L + ydY_L],0,0,'','','',NaN,xlim,ylim,style,marker,color3,width2,siz);
end
if exist('wave_s','var') == 1,
    [ax] = graph1D_jd(syX_s,syY_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
end
if opt(2) >= 1,
    [ax] = graph1D_jd(syX(is_syres),syY(is_syres),0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
end
[ax] = graph1D_jd(X_disp',Y_disp',0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
axis('equal');
axis([xlim,ylim])
%
% ------------------------
%
if xvar == 's',
    xlab = 's (m)';
    x_disp = sys;
    if exist('wave_s','var') == 1,
        x_disp_s = sys_s;
    end
    xlim = [0,smax];
elseif xvar == 'R',
    xlab = 'R (m)';
    x_disp = syR;
    if exist('wave_s','var') == 1,
        x_disp_s = syR_s;
    end
    xlim = [Rmin,Rmax];
elseif xvar == 'p',
    xlab = '(\psi/\psi_a)^{1/2}';
    x_disp = sqrt(sypsin);
    if exist('wave_s','var') == 1,
        x_disp_s = sqrt(sypsin_s);
    end
    xlim = [0,1];
elseif xvar == 'r',
    xlab = '\rho';
    x_disp = syrho;
    if exist('wave_s','var') == 1,
        x_disp_s = syrho_s;
    end
    xlim = [0,1];
end
%
figure(3),clf
%
ylim = NaN;
ylab = 'N_{||}';
tit = '';
%
if opt(1) == 1 & ~isempty(sydNpar)
    [ax] = graph1D_jd([x_disp,x_disp],[syNpar + sydNpar,syNpar - sydNpar],0,0,'','','',NaN,xlim,ylim,style,marker,color2,width2,siz);
end
if exist('wave_s','var') == 1,
    [ax] = graph1D_jd(x_disp_s,syNpar_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
end
if opt(2) >= 1,
    [ax] = graph1D_jd(x_disp(is_syres),syNpar(is_syres),0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
end
[ax] = graph1D_jd(x_disp,syNpar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);    
%
figure(4),clf
%
ylim = NaN;
ylab = 'N_{\perp}';
tit = '';
%
if exist('wave_s','var') == 1,
    [ax] = graph1D_jd(x_disp_s,syNperp_s,0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
end
if opt(2) >= 1,
    [ax] = graph1D_jd(x_disp(is_syres),syNperp(is_syres),0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
end
[ax] = graph1D_jd(x_disp,syNperp,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
%
if exist('launch','var') == 1,
    figure(5),clf
%
    xlim_L = [min([yphi_L,0]),max([yphi_L,0])]*1.1*180/pi;
    ylim_L = [min([yZ_L,0]),max([yZ_L,0])]*1.1;
    xlab_L = '\phi_L (deg.)';
    ylab = 'Z_L (m)';
    tit = '';
%
    [ax] = graph1D_jd(yphi_L*180/pi,yZ_L,0,0,xlab_L,ylab,tit,NaN,xlim_L,ylim_L,style2,marker2,color3,width2,siz,gca,red,lspace,bspace);
    for iy = 1:ny
        text(yphi_L(iy)*180/pi,yZ_L(iy),['\alpha_L = ',num2str(round(yalpha_L(iy)*180/pi)),'\newline\beta_L = ',num2str(round(ybeta_L(iy)*180/pi))],'fontsize',10);
    end
end
%
if opt(3) >= 1,
    figure(6),clf
    %
    ylim = [0,1.1];
    ylab = 'P^b/P_0^b';
    tit = '';
    %
    if exist('wave_s','var') == 1,
        [ax] = graph1D_jd(x_disp_s,syPinc_s./(ones(ns_s,1)*yP0_s),0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
    end
    if opt(2) >= 1,
        [ax] = graph1D_jd(x_disp(is_syres),syPinc(is_syres)./missing,0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
    end
    [ax] = graph1D_jd(x_disp,syPinc./(ones(ns,1)*yP0),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
    %
    figure(7),clf
    %
    ylim = NaN;
    ylab = 'dP^b/ds/P_0^b (m^{-1})';
    tit = '';
    %
    if exist('wave_s','var') == 1,
        [ax] = graph1D_jd(x_disp_s,sydPincds_s./(ones(ns_s,1)*yP0_s),0,0,'','','',NaN,xlim,ylim,style,marker,color4,width2,siz);
    end
    if opt(2) >= 1,
        [ax] = graph1D_jd(x_disp(is_syres),sydPincds(is_syres)./missing,0,0,'','','',NaN,xlim,ylim,style2,marker3,color5,width1,siz);
    end
    [ax] = graph1D_jd(x_disp,sydPincds./(ones(ns,1)*yP0),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width1,siz,gca,red,lspace,bspace);
    %
end
%
if (opt(2) >=1 | opt(3) >= 1) & ny == 1% only one ray
    %
    figure(8),clf
    %
    ylim = [0,(ceil(omega_rf_ghz/10) + 1)*10];
    ylab = '\omega/(2\pi) (GHz)';
    tit = '';
    str_vparn = [num2str(vparn),'  '];
    leg = ['n\omega_{ce}                         ';...
           'n\omega_{ce} \pm ',str_vparn(1:3),'v_{Te}\cdotk_{//}'];
    %
    graph1D_jd(x_disp,Nsomega_ce_ghz(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width1,siz,gca,red,lspace,bspace);
    graph1D_jd(x_disp,Nsomega_ce_ghz_m(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1);
    graph1D_jd(x_disp,Nsomega_ce_ghz(:,2:N),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width1);
    graph1D_jd(x_disp,Nsomega_ce_ghz_m(:,2:N),0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1);
    graph1D_jd(x_disp,Nsomega_ce_ghz_p,0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1);
    graph1D_jd(xlim,[omega_rf_ghz,omega_rf_ghz],0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color1,width1);
    %
end
%
if opt(4) >=1
    %
    figure(9),clf
    %
    ylim = NaN;
    ylab = 'N_{||}';
    tit = '';
%
    [ax] = graph1D_jd(x_disp(:,1),syNpar(:,1),0,0,'','','',NaN,xlim,ylim,style,marker,color2,width1,siz);
    [ax] = graph1D_jd([x_disp(:,1),x_disp(:,1)],[syNpar(:,1)-sdNpar',syNpar(:,1)+sdNpar'],0,0,'','','',NaN,xlim,ylim,style,marker,color3,width1,siz);
    [ax] = graph1D_jd(x_disp,syNpar,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width2,siz,gca,red,lspace,bspace);    
    %
end


