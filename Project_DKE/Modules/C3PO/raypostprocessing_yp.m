function [psin_ray,theta_ray,phi_ray,R_ray,Z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,D_ray] = raypostprocessing_yp(tout,yout,rayparam,equil_fit,omega)
%
% Post processing of the ray calculation
%
% INPUT
%    - tout: ray time (w*t) [1,nray)
%    - yout: ray coordinate (psin,theta,phi,kpsin,m,n) [6,nray) (Nota:   kpsin = kspi*psia,psin = psi/psia)
%    - rayparam: ray-tracing parameter
%    - equil_fit: interpolated magnetic equilibrium structure
%    - omega: wave frequency (s-1) [1,1]
%
% OUTPUT: none yet
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
psin_ray = yout(:,1);
theta_ray = yout(:,2);
phi_ray = yout(:,3); 
%
Te_ray = ppval(equil_fit.Te_fit.pp_f,yout(:,1));
ne_ray = ppval(equil_fit.ne_fit.pp_f,yout(:,1));
zTi_ray = ppval(equil_fit.zTi_fit.pp_f,yout(:,1));
zni_ray = ppval(equil_fit.zni_fit.pp_f,yout(:,1));
%
R_a0_ray = ppval(equil_fit.R_fit.pp_a0,yout(:,1));
R_an_ray = ppval(equil_fit.R_fit.pp_an,yout(:,1));
R_bn_ray = ppval(equil_fit.R_fit.pp_bn,yout(:,1));
%
Z_a0_ray = ppval(equil_fit.Z_fit.pp_a0,yout(:,1));
Z_an_ray = ppval(equil_fit.Z_fit.pp_an,yout(:,1));
Z_bn_ray = ppval(equil_fit.Z_fit.pp_bn,yout(:,1));
%
r_a0_ray = ppval(equil_fit.r_fit.pp_a0,yout(:,1));
r_an_ray = ppval(equil_fit.r_fit.pp_an,yout(:,1));
r_bn_ray = ppval(equil_fit.r_fit.pp_bn,yout(:,1));
%
calpha_a0_ray = ppval(equil_fit.calpha_fit.pp_a0,yout(:,1));
calpha_an_ray = ppval(equil_fit.calpha_fit.pp_an,yout(:,1));
calpha_bn_ray = ppval(equil_fit.calpha_fit.pp_bn,yout(:,1));
%
salpha_a0_ray = ppval(equil_fit.salpha_fit.pp_a0,yout(:,1));
salpha_an_ray = ppval(equil_fit.salpha_fit.pp_an,yout(:,1));
salpha_bn_ray = ppval(equil_fit.salpha_fit.pp_bn,yout(:,1));
%
BP_a0_ray = ppval(equil_fit.BP_fit.pp_a0,yout(:,1));
BP_an_ray = ppval(equil_fit.BP_fit.pp_an,yout(:,1));
BP_bn_ray = ppval(equil_fit.BP_fit.pp_bn,yout(:,1));
%
BPHI_a0_ray = ppval(equil_fit.BPHI_fit.pp_a0,yout(:,1));
BPHI_an_ray = ppval(equil_fit.BPHI_fit.pp_an,yout(:,1));
BPHI_bn_ray = ppval(equil_fit.BPHI_fit.pp_bn,yout(:,1));
%
R_ray = zeros(length(tout),1);
Z_ray = zeros(length(tout),1);
r_ray = zeros(length(tout),1);
calpha_ray = zeros(length(tout),1);
salpha_ray = zeros(length(tout),1);
BP_ray = zeros(length(tout),1);
BPHI_ray = zeros(length(tout),1);
%
for ii = 1:length(tout),
   R_ray(ii) = R_a0_ray(ii) + R_an_ray(ii,:)*cos(equil_fit.R_fit.n*yout(ii,2)) + R_bn_ray(ii,:)*sin(equil_fit.R_fit.n*yout(ii,2));
   Z_ray(ii) = Z_a0_ray(ii) + Z_an_ray(ii,:)*cos(equil_fit.Z_fit.n*yout(ii,2)) + Z_bn_ray(ii,:)*sin(equil_fit.Z_fit.n*yout(ii,2));
   r_ray(ii) = r_a0_ray(ii) + r_an_ray(ii,:)*cos(equil_fit.r_fit.n*yout(ii,2)) + r_bn_ray(ii,:)*sin(equil_fit.r_fit.n*yout(ii,2));
   calpha_ray(ii) = calpha_a0_ray(ii) + calpha_an_ray(ii,:)*cos(equil_fit.calpha_fit.n*yout(ii,2)) + calpha_bn_ray(ii,:)*sin(equil_fit.calpha_fit.n*yout(ii,2));
   salpha_ray(ii) = salpha_a0_ray(ii) + salpha_an_ray(ii,:)*cos(equil_fit.salpha_fit.n*yout(ii,2)) + salpha_bn_ray(ii,:)*sin(equil_fit.salpha_fit.n*yout(ii,2));
   BP_ray(ii) = BP_a0_ray(ii) + BP_an_ray(ii,:)*cos(equil_fit.BP_fit.n*yout(ii,2)) + BP_bn_ray(ii,:)*sin(equil_fit.BP_fit.n*yout(ii,2));
   BPHI_ray(ii) = BPHI_a0_ray(ii) + BPHI_an_ray(ii,:)*cos(equil_fit.BPHI_fit.n*yout(ii,2)) + BPHI_bn_ray(ii,:)*sin(equil_fit.BPHI_fit.n*yout(ii,2));
end
B_ray = sqrt(BP_ray.^2 + BPHI_ray.^2);
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
Npar_ray = clum*(yout(:,5).*calpha_ray.*BP_ray./r_ray./B_ray + yout(:,6).*BPHI_ray./R_ray./B_ray)/omega;
Nperp_ray = sqrt(clum*clum*(yout(:,4).*yout(:,4).*R_ray.*R_ray.*BP_ray.*BP_ray/equil_fit.psia^2 - 2*yout(:,4).*yout(:,5).*R_ray.*BP_ray.*salpha_ray./r_ray/equil_fit.psia + (yout(:,5)./r_ray).^2 + (yout(:,6)./R_ray).^2)/omega/omega - Npar_ray.^2);
%
ntheta_fit= 65;
psin_fit = linspace(0,1,15);
theta_fit = linspace(0,2*pi,ntheta_fit);
R_a0_fit = ppval(equil_fit.R_fit.pp_a0,psin_fit);
R_an_fit = ppval(equil_fit.R_fit.pp_an,psin_fit);
R_bn_fit = ppval(equil_fit.R_fit.pp_bn,psin_fit);
Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,psin_fit);
Z_an_fit = ppval(equil_fit.Z_fit.pp_an,psin_fit);
Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,psin_fit);
%
for ii = 1:ntheta_fit,
   R_fit(:,ii) = R_a0_fit.' + R_an_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
   Z_fit(:,ii) = Z_a0_fit.' + Z_an_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
end
%
Rmin = min(min(R_fit));
Rmax = max(max(R_fit));
Zmin = min(min(Z_fit));
Zmax = max(max(Z_fit));
%
figure('Name','Ray trajectory')
[ax] = graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
[ax] = graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
[ax] = graph1D_jd(R_ray,Z_ray,0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','k',2);hold on
axis('equal');drawnow  
%
figure('Name','Refractive index')
graph1D_jd(abs(yout(:,3)/2/pi),Npar_ray,0,0,'','','',NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(yout(:,3)/2/pi),Nperp_ray,0,0,'abs(\phi)/2\pi','Wave refractive index','',NaN,'','','-','none','b',2);drawnow;hold off
legend('N_{||}','N_{\perp}')
%
figure('Name','Poloidal mode number')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,5),0,0,'abs(\phi)/2\pi','m','Poloidal mode number',NaN,'','','-','none','r',2);drawnow;hold on
%
figure('Name','Poloidal angle')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,2)/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi','Poloidal angle',NaN,'','','-','none','r',2);drawnow;hold on
%
figure('Name','Normalized radial wavenumber')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,4),0,0,'abs(\phi)/2\pi','kpsi*psia','Normalized radial wavenumber',NaN,'','','-','none','r',2);drawnow;hold on
%
D_ray = zeros(length(tout),1);
epol_pmz_ray = zeros(length(tout),3);
phi_xyz_ray = zeros(length(tout),3);
%
for ii = 1:length(tout),
    if rayparam.tensortype == 0,
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
            = colddisp_dke_jd(Npar_ray(ii),omega,ne_ray(ii),zni_ray(ii,:)',equil_fit.zZi,equil_fit.zmi,B_ray(ii),Nperp_ray(ii));
    else
        error('not yet implemented')
    end
%        
    N = [Nperp_ray(ii);0;Npar_ray(ii)];
    N2 = Npar_ray(ii)^2+Nperp_ray(ii)^2;
    D_ray(ii) = det(N*N.'- eye(3)*N2 + Kxyz);
%    
    epol_pmz_ray(ii,:) = ep_pmz.';
    phi_xyz_ray(ii,:) = phip_xyz.';
end
figure('Name','Dispersion relation'),graph1D_jd(abs(yout(:,3)/2/pi),D_ray,0,0,'abs(\phi)/2\pi','Dispersion relation','',NaN,'','','-','none','r',2);drawnow
