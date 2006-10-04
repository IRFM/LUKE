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
dRstardpsin_ray = ppval(equil_fit.dRstardpsin_fit.pp_f,yout(:,1));
Te_ray = ppval(equil_fit.Te_fit.pp_f,yout(:,1));
ne_ray = ppval(equil_fit.ne_fit.pp_f,yout(:,1));
zTi_ray = ppval(equil_fit.zTi_fit.pp_f,yout(:,1));
zni_ray = ppval(equil_fit.zni_fit.pp_f,yout(:,1));
%
R_a0_ray = ppval_yp(equil_fit.R_fit.pp_a0,yout(:,1));
R_an_ray = ppval_yp(equil_fit.R_fit.pp_an,yout(:,1));
R_bn_ray = ppval_yp(equil_fit.R_fit.pp_bn,yout(:,1));
%
Z_a0_ray = ppval_yp(equil_fit.Z_fit.pp_a0,yout(:,1));
Z_an_ray = ppval_yp(equil_fit.Z_fit.pp_an,yout(:,1));
Z_bn_ray = ppval_yp(equil_fit.Z_fit.pp_bn,yout(:,1));
%
BR_a0_ray = ppval(equil_fit.BR_fit.pp_a0,yout(:,1));
BR_an_ray = ppval(equil_fit.BR_fit.pp_an,yout(:,1));
BR_bn_ray = ppval(equil_fit.BR_fit.pp_bn,yout(:,1));
%
BZ_a0_ray = ppval(equil_fit.BZ_fit.pp_a0,yout(:,1));
BZ_an_ray = ppval(equil_fit.BZ_fit.pp_an,yout(:,1));
BZ_bn_ray = ppval(equil_fit.BZ_fit.pp_bn,yout(:,1));
%
BPHI_a0_ray = ppval(equil_fit.BPHI_fit.pp_a0,yout(:,1));
BPHI_an_ray = ppval(equil_fit.BPHI_fit.pp_an,yout(:,1));
BPHI_bn_ray = ppval(equil_fit.BPHI_fit.pp_bn,yout(:,1));
%
R_ray = zeros(length(tout),1);
Z_ray = zeros(length(tout),1);
BR_ray = zeros(length(tout),1);
BZ_ray = zeros(length(tout),1);
BPHI_ray = zeros(length(tout),1);
dRdtheta_ray = zeros(length(tout),1);
dZdtheta_ray = zeros(length(tout),1);
%
for ii = 1:length(tout),
   R_ray(ii) = R_a0_ray(ii) + R_an_ray(ii,:)*cos(equil_fit.R_fit.n*yout(ii,2)) + R_bn_ray(ii,:)*sin(equil_fit.R_fit.n*yout(ii,2));
   Z_ray(ii) = Z_a0_ray(ii) + Z_an_ray(ii,:)*cos(equil_fit.Z_fit.n*yout(ii,2)) + Z_bn_ray(ii,:)*sin(equil_fit.Z_fit.n*yout(ii,2));
   dRdtheta_ray(ii) = -R_an_ray(ii,:)*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*yout(ii,2))) + R_bn_ray(ii,:)*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*yout(ii,2)));
   dZdtheta_ray(ii) = -Z_an_ray(ii,:)*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*yout(ii,2))) + Z_bn_ray(ii,:)*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*yout(ii,2)));   
   BR_ray(ii) = BR_a0_ray(ii) + BR_an_ray(ii,:)*cos(equil_fit.BR_fit.n*yout(ii,2)) + BR_bn_ray(ii,:)*sin(equil_fit.BR_fit.n*yout(ii,2));
   BZ_ray(ii) = BZ_a0_ray(ii) + BZ_an_ray(ii,:)*cos(equil_fit.BZ_fit.n*yout(ii,2)) + BZ_bn_ray(ii,:)*sin(equil_fit.BZ_fit.n*yout(ii,2));
   BPHI_ray(ii) = BPHI_a0_ray(ii) + BPHI_an_ray(ii,:)*cos(equil_fit.BPHI_fit.n*yout(ii,2)) + BPHI_bn_ray(ii,:)*sin(equil_fit.BPHI_fit.n*yout(ii,2));
end
%
BP_ray = sqrt(BR_ray.^2 + BZ_ray.^2);
B_ray = sqrt(BR_ray.^2 + BZ_ray.^2 + BPHI_ray.^2);
r_ray = sqrt((R_ray - equil_fit.Rp).^2 + (Z_ray - equil_fit.Zp).^2);
salpha_ray = ((R_ray - equil_fit.Rp).*dRdtheta_ray + (Z_ray - equil_fit.Zp).*dZdtheta_ray)./r_ray./sqrt(dRdtheta_ray.^2 + dZdtheta_ray.^2);
calpha_ray = sqrt(1.0 - salpha_ray.^2);
gradrho_ray = R_ray.*BP_ray.*dRstardpsin_ray/equil_fit.psia;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
Npar_ray = clum*(yout(:,5).*calpha_ray.*BP_ray./r_ray./B_ray + yout(:,6).*BPHI_ray./R_ray./B_ray)/omega;
Nperp_ray = sqrt(clum*clum*(yout(:,4).*yout(:,4).*gradrho_ray.*gradrho_ray/equil_fit.ap^2 - 2*yout(:,4).*yout(:,5).*gradrho_ray.*salpha_ray./r_ray/equil_fit.ap + (yout(:,5)./r_ray).^2 + (yout(:,6)./R_ray).^2)/omega/omega - Npar_ray.^2);
%
ntheta_fit= 65;
rho_fit = linspace(0,1,15);
theta_fit = linspace(0,2*pi,ntheta_fit);
R_a0_fit = ppval(equil_fit.R_fit.pp_a0,rho_fit);
R_an_fit = ppval(equil_fit.R_fit.pp_an,rho_fit);
R_bn_fit = ppval(equil_fit.R_fit.pp_bn,rho_fit);
Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,rho_fit);
Z_an_fit = ppval(equil_fit.Z_fit.pp_an,rho_fit);
Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,rho_fit);
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
figure('Name','Parallel wave refractive index')
graph1D_jd(abs(yout(:,3)/2/pi),Npar_ray,0,0,'abs(\phi)/2\pi','Parallel wave refractive index','',NaN,'','','-','none','r',2);drawnow;hold off
graph1D_jd(abs(yout(:,3)/2/pi),6.5./sqrt(Te_ray),0,0,'abs(\phi)/2\pi','Parallel wave refractive index','',NaN,'','','-','none','b',2);drawnow;hold off
legend('Ray-tracing','Landau damping');
%
figure('Name','Perpendicular wave refractive index')
graph1D_jd(abs(yout(:,3)/2/pi),Nperp_ray,0,0,'abs(\phi)/2\pi','Perpendicular wave refractive index','',NaN,'','','-','none','r',2);drawnow;hold off
%
figure('Name','Poloidal mode number')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,5),0,0,'abs(\phi)/2\pi','m','Poloidal mode number',NaN,'','','-','none','r',2);drawnow;hold on
%
figure('Name','Poloidal angle')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,2)/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi','Poloidal angle',NaN,'','','-','none','r',2);drawnow;hold on
%
%
figure('Name','Radial position')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,1),0,0,'abs(\phi)/2\pi','rho','Normalized radial position',NaN,'','','-','none','r',2);drawnow;hold on
%
figure('Name','Normalized radial wavenumber')
graph1D_jd(abs(yout(:,3)/2/pi),yout(:,4),0,0,'abs(\phi)/2\pi','krho*ap','Normalized radial wavenumber',NaN,'','','-','none','r',2);drawnow;hold on
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
    D_ray(ii) = det(N*N.'/N2- eye(3) + Kxyz/N2);
%    
    epol_pmz_ray(ii,:) = ep_pmz.';
    phi_xyz_ray(ii,:) = phip_xyz.';
end
figure('Name','Dispersion relation'),graph1D_jd(abs(yout(:,3)/2/pi),abs(D_ray),0,1,'abs(\phi)/2\pi','Dispersion relation','',NaN,'','','-','none','r',2);drawnow
%
