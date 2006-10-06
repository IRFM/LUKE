function [rho_ray,theta_ray,phi_ray,R_ray,Z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,D_ray] = raypostprocessing_yp(tout,yout,rayparam,equil_fit,omega)
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
tn_ray = tout;
rho_ray = yout(:,1);
theta_ray = yout(:,2);
phi_ray = yout(:,3); 
krho_ray = yout(:,4); 
m_ray = yout(:,5); 
n_ray = yout(:,6);
omega_ray = yout(:,7);
%
[R_ray,Z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,D_ray,Te_ray,ne_ray,zTi_ray,zni_ray,BP_ray,BPHI_ray,B_ray,r_ray,salpha_ray,gradrho_ray] = rayparameters_yp(rayparam,equil_fit,omega_ray,rho_ray,theta_ray,phi_ray,krho_ray,m_ray,n_ray);
%
if rem(Npar_ray(1)^2+Nperp_ray(1)^2,1) == eps,% Vacuum propagation. Calculate the exact theoretical solution
    rho_vac =  rho_ray(1,1) + tn_ray.*krho_ray(1,1).*gradrho_ray;
    theta_vac = theta_ray(1,1) + tn_ray.*m_ray(1,1)./r_ray./r_ray/equil_fit.ap^2;
    phi_vac = phi_ray(1,1) + tn_ray.*n_ray(1,1)./R_ray./R_ray/equil_fit.ap^2;
    krho_vac = krho_ray(1,1) + tn_ray.*0.0;
    m_vac = m_ray(1,1) + tn_ray.*0.0;
    n_vac = n_ray(1,1) + tn_ray.*0.0;
%
keyboard
    [R_vac,Z_vac,Npar_vac,Nperp_vac,epol_pmz_vac,phi_xyz_vac,D_vac] = rayparameters_yp(rayparam,equil_fit,omega_ray,rho_vac,theta_vac,phi_vac,krho_vac,m_vac,n_vac);    
end
%
% Build magnetic equilibrium for display
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
% Display results
%
figure('Name','Ray trajectory')
[ax] = graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
[ax] = graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
[ax] = graph1D_jd(R_ray,Z_ray,0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','k',2);hold on
if rem(Npar_ray(1)^2+Nperp_ray(1)^2,1) == eps,% Vacuum propagation.
   [ax] = graph1D_jd(R_vac,Z_vac,0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','r',1);hold on
   legend('Ray-tracing','Analytic');
end
axis('equal');drawnow  
%
figure('Name','Parallel wave refractive index')
graph1D_jd(abs(phi_ray/2/pi),Npar_ray,0,0,'abs(\phi)/2\pi','Parallel wave refractive index','',NaN,'','','-','none','r',2);drawnow;hold off
graph1D_jd(abs(phi_ray/2/pi),6.5./sqrt(Te_ray),0,0,'abs(\phi)/2\pi','Parallel wave refractive index','',NaN,'','','-','none','b',2);drawnow;hold off
legend('Ray-tracing','Landau damping');
%
figure('Name','Perpendicular wave refractive index')
graph1D_jd(abs(phi_ray/2/pi),Nperp_ray,0,0,'abs(\phi)/2\pi','Perpendicular wave refractive index','',NaN,'','','-','none','r',2);drawnow;hold off
%
figure('Name','Poloidal mode number')
graph1D_jd(abs(phi_ray/2/pi),yout(:,5),0,0,'abs(\phi)/2\pi','m','Poloidal mode number',NaN,'','','-','none','r',2);drawnow;hold on
%
figure('Name','Poloidal angle')
graph1D_jd(abs(phi_ray/2/pi),yout(:,2)/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi','Poloidal angle',NaN,'','','-','none','r',2);drawnow;hold on
%
%
figure('Name','Radial position')
graph1D_jd(abs(phi_ray/2/pi),yout(:,1),0,0,'abs(\phi)/2\pi','rho','Normalized radial position',NaN,'','','-','none','r',2);drawnow;hold on
%
figure('Name','Normalized radial wavenumber')
graph1D_jd(abs(phi_ray/2/pi),yout(:,4),0,0,'abs(\phi)/2\pi','krho*ap','Normalized radial wavenumber',NaN,'','','-','none','r',2);drawnow;hold on

figure('Name','Dispersion relation'),graph1D_jd(abs(phi_ray/2/pi),abs(D_ray),0,1,'abs(\phi)/2\pi','Dispersion relation','',NaN,'','','-','none','r',2);drawnow
%
