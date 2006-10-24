function [iabs_out,rho_ray,theta_ray,phi_ray,R_ray,Z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,D_ray] = raypostprocessing_yp(tout,yout,rayparam,equil_fit,omega,display_mode,p_opt,filename,subtitle)
%
% Post processing of the ray calculation
%
% INPUT
%    - tout: ray time (w*t) [1,nray)
%    - yout: ray coordinate (psin,theta,phi,kpsin,m,n) [6,nray) (Nota: krho = krho*ap, rho = (R(:,0)-Rp)/ap
%    - rayparam: ray-tracing parameter
%    - equil_fit: interpolated magnetic equilibrium structure
%    - omega: wave frequency (s-1) [1,1]
%
% OUTPUT: none yet
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 5,
    error('Not enough input arguments in raypostprocessing_yp.m');
end
if nargin < 6,
    display_mode = 0;
end
if nargin < 7,
    p_opt = -1;
end
if nargin < 8,
    filename = '';
end
if nargin < 9,
    subtitle = '';
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
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
if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation. Calculate the exact theoretical solution 
    cnorm = clum/omega_ray(1)/equil_fit.ap;
    Rpn = equil_fit.Rp/equil_fit.ap;%Normlized major radius
    s = linspace(0,10,1001);%Ray length
    omega_vac = ones(length(s),1)*omega_ray(1);
%
    Mrot0 = [cos(theta_ray(1))*cos(phi_ray(1)),-sin(theta_ray(1))*cos(phi_ray(1)),-sin(phi_ray(1));cos(theta_ray(1))*sin(phi_ray(1)),-sin(theta_ray(1))*sin(phi_ray(1)),cos(phi_ray(1));sin(theta_ray(1)),cos(theta_ray(1)),0];
    N_ray0 = cnorm*[krho_ray(1);m_ray(1)*equil_fit.ap/r_ray(1);n_ray(1)*equil_fit.ap/R_ray(1)];%Initial wave vector in contravariant coordinates
    N_vac0_c = Mrot0*N_ray0;%Initial wave vector in cartesian coordinates
%
    phi_vac(1) = phi_ray(1);
    rho_vac(1) = rho_ray(1);
    theta_vac(1) = theta_ray(1);
    rn_vac(1) = r_ray(1)/equil_fit.ap;
    Rn_vac(1) = R_ray(1)/equil_fit.ap;
    krho_vac(1) = krho_ray(1);
    m_vac(1) = m_ray(1);
    n_vac(1) = n_ray(1);        
    X_vac0_c = [(Rpn + rho_vac(1)*cos(theta_vac(1)))*cos(phi_vac(1));(Rpn + rho_vac(1)*cos(theta_vac(1)))*sin(phi_vac(1));rho_vac(1)*sin(theta_vac(1))];%Initial ray position in Cartesian coordinates
%   
    for i = 2:length(s),
       X_vac_c = X_vac0_c(:,i-1) + N_vac0_c*(s(i) - s(i-1));%Ray equation in cartesian coordinates at next position
%
       phi_vac(i,1) = atan(X_vac_c(2)/X_vac_c(1)) + pi*(X_vac_c(1) < 0);%New ray equation in toroidal coordinates
       rho_vac(i,1) = sqrt((X_vac_c(1)/cos(phi_vac(i)) - Rpn)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
       theta_vac(i,1) = asin(X_vac_c(3)/rho_vac(i))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) > Rpn) + (pi*sign(theta_vac(i-1)) - asin(X_vac_c(3)/rho_vac(i)))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) < Rpn);%New ray equation in toroidal coordinates
%       
       if rho_vac(i) >=1,%Specular reflexion is enforced at plasma boundary
           Mrot0 = [cos(theta_vac(i-1))*cos(phi_vac(i-1)),cos(theta_vac(i-1))*sin(phi_vac(i-1)),+sin(theta_vac(i-1));-sin(theta_vac(i-1))*cos(phi_vac(i-1)),-sin(theta_vac(i-1))*sin(phi_vac(i-1)),cos(theta_vac(i-1));sin(phi_vac(i-1)),-cos(phi_vac(i-1)),0];
           Mrot1 = [-cos(theta_vac(i-1))*cos(phi_vac(i-1)),-cos(theta_vac(i-1))*sin(phi_vac(i-1)),-sin(theta_vac(i-1));-sin(theta_vac(i-1))*cos(phi_vac(i-1)),-sin(theta_vac(i-1))*sin(phi_vac(i-1)),cos(theta_vac(i-1));sin(phi_vac(i-1)),-cos(phi_vac(i-1)),0];
           N_vac0_c = inv(Mrot0)*(Mrot1*N_vac0_c);%Ray direction is updated
           X_vac_c = X_vac0_c(:,i-1) + N_vac0_c*(s(i) - s(i-1));%Ray equation in cartesian coordinates 
%
           phi_vac(i) = atan(X_vac_c(2)/X_vac_c(1)) + pi*(X_vac_c(1) < 0);%New ray equation in toroidal coordinates
           rho_vac(i) = sqrt((X_vac_c(1)/cos(phi_vac(i)) - Rpn)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
           theta_vac(i) = asin(X_vac_c(3)/rho_vac(i))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) > Rpn) + (pi*sign(theta_vac(i-1)) - asin(X_vac_c(3)/rho_vac(i)))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) < Rpn);%New ray equation in toroidal coordinates
       end
%      
       rn_vac(i,1) = rho_vac(i);%circular concentric magnetic flux surfaces
       Rn_vac(i,1) = sqrt(X_vac_c(1)^2 + X_vac_c(2)^2);
%
       invMrot = inv([cos(theta_vac(i))*cos(phi_vac(i)),-sin(theta_vac(i))*cos(phi_vac(i)),-sin(phi_vac(i));cos(theta_vac(i))*sin(phi_vac(i)),-sin(theta_vac(i))*sin(phi_vac(i)),cos(phi_vac(i));sin(theta_vac(i)),cos(theta_vac(i)),0]);
       N_vac = invMrot*N_vac0_c;
%
       krho_vac(i,1) = N_vac(1)/cnorm;
       m_vac(i,1) = N_vac(2)*rn_vac(i,1)/cnorm;
       n_vac(i,1) = N_vac(3)*Rn_vac(i,1)/cnorm;
%
       X_vac0_c(:,i) = X_vac_c;
    end
%
    [dummy,dummy,Npar_vac,Nperp_vac,epol_pmz_vac,phi_xyz_vac,D_vac,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy] = rayparameters_yp(rayparam,equil_fit,omega_vac,rho_vac,theta_vac,phi_vac,krho_vac,m_vac,n_vac);
end
%
% Build magnetic equilibrium for display
%
ntheta_fit= 65;
rho_fit = linspace(0,1,15);
theta_fit = linspace(0,2*pi,ntheta_fit);
x_a0_fit = ppval(equil_fit.x_fit.pp_a0,rho_fit);
x_an_fit = ppval(equil_fit.x_fit.pp_an,rho_fit);
x_bn_fit = ppval(equil_fit.x_fit.pp_bn,rho_fit);
y_a0_fit = ppval(equil_fit.y_fit.pp_a0,rho_fit);
y_an_fit = ppval(equil_fit.y_fit.pp_an,rho_fit);
y_bn_fit = ppval(equil_fit.y_fit.pp_bn,rho_fit);
%
for ii = 1:ntheta_fit,
   R_fit(:,ii) = equil_fit.Rp + x_a0_fit.' + x_an_fit*cos(equil_fit.x_fit.n*theta_fit(ii)) + x_bn_fit*sin(equil_fit.x_fit.n*theta_fit(ii));
   Z_fit(:,ii) = equil_fit.Zp + y_a0_fit.' + y_an_fit*cos(equil_fit.y_fit.n*theta_fit(ii)) + y_bn_fit*sin(equil_fit.y_fit.n*theta_fit(ii));
end
%
Rmin = min(min(R_fit));
Rmax = max(max(R_fit));
Zmin = min(min(Z_fit));
Zmax = max(max(Z_fit));
%
if sum(Te_ray) > 0,iabs = find(6.5./sqrt(Te_ray) < abs(Npar_ray));else iabs= [];end
if isempty(iabs), iabs = length(Npar_ray);end
iabs_out = iabs(1);
%
% Display results
%
if display_mode,
   figure('Name','Ray trajectory')
   [ax] = graph1D_jd(R_ray,Z_ray,0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','k',2);hold on
%
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(sqrt(X_vac0_c(1,:).^2+X_vac0_c(2,:).^2)*equil_fit.ap,X_vac0_c(3,:)*equil_fit.ap,0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   else
      [ax] = graph1D_jd(R_ray(1:iabs(1)),Z_ray(1:iabs(1)),0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','m',2);hold on 
   end
   [ax] = graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
   axis('equal');drawnow  
   print_jd(p_opt,[filename,'_Ray']);
%
   figure('Name','Parallel wave refractive index')
   graph1D_jd(abs(phi_ray/2/pi),Npar_ray,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(Npar_ray),max(Npar_ray)]','-','none','k',2);drawnow;hold off
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,Npar_vac,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(Npar_ray),max(Npar_ray)],'--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   else
      graph1D_jd(abs(phi_ray/2/pi),sign(Npar_ray(1))*6.5./sqrt(Te_ray),0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(Npar_ray),max(Npar_ray)],'-','none','b',2);drawnow;hold off
      legend('Ray-tracing','Landau damping');
   end
   print_jd(p_opt,[filename,'_Npar']);
%
   figure('Name','Perpendicular wave refractive index')
   graph1D_jd(abs(phi_ray/2/pi),Nperp_ray,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index',subtitle],NaN,'','','-','none','k',2);drawnow;hold off
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,Nperp_vac,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_Nperp']);
%
   figure('Name','Poloidal mode number')
   graph1D_jd(abs(phi_ray/2/pi),yout(:,5),0,0,'abs(\phi)/2\pi','m',['Poloidal mode number',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,m_vac,0,0,'abs(\phi)/2\pi','m',['Poloidal mode number',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_PoloidalMode']);
%
   figure('Name','Toroidal mode number')
   graph1D_jd(abs(phi_ray/2/pi),yout(:,6),0,0,'abs(\phi)/2\pi','n',['Toroidal mode number',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,n_vac,0,0,'abs(\phi)/2\pi','n',['Toroidal mode number',subtitle],NaN,'',[0,max(yout(1,6))*1.1],'--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_ToroidalMode']);

%
   figure('Name','Poloidal angle')
   graph1D_jd(abs(phi_ray/2/pi),yout(:,2)/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,theta_vac/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_Theta']);
%
   figure('Name','Radial position')
   graph1D_jd(abs(phi_ray/2/pi),yout(:,1),0,0,'abs(\phi)/2\pi','rho',['Normalized radial position',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,rho_vac,0,0,'abs(\phi)/2\pi','rho',['Normalized radial position',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_Rho']);
%
   figure('Name','Normalized radial wavenumber')
   graph1D_jd(abs(phi_ray/2/pi),yout(:,4),0,0,'abs(\phi)/2\pi','krho*ap',['Normalized radial wavenumber',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,krho_vac,0,0,'abs(\phi)/2\pi','krho*ap',['Normalized radial wavenumber',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_Radialwavenumber']);
%
   figure('Name','Dispersion relation'),graph1D_jd(abs(phi_ray/2/pi),abs(D_ray),0,1,'abs(\phi)/2\pi','D',['Dispersion relation',subtitle],NaN,'','','-','none','k',2);drawnow
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,D_vac,0,0,'abs(\phi)/2\pi','D',['Dispersion relation',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_Disp']);
%
end