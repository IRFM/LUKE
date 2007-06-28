function [iabs_out,rho_ray,theta_ray,phi_ray,R_ray,Z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,pmode_ray,D_ray,s_ray,alphaphi_ray,B_ray,BP_ray,BPHI_ray,Te_ray,ne_ray,zTi_ray,zni_ray,r_ray,salpha_ray,gradrhon_ray,tau_ray] = raypostprocessing_yp(tout,yout,yproc,rayparam,equil_fit,display_mode,p_opt,filename,subtitle)
%
% Post processing of the ray calculation
%
% INPUT :
%    - tout: ray time (w*t) [1,nray)
%    - yout: ray coordinate (psin,theta,phi,kpsin,m,n,omega,s) [8,nray] (Nota: krho = krho*ap, rho = (R(:,1)-Rp)/ap
%    - yproc: ray coordinate (psin,theta,phi,kpsin,m,n,omega,s) [8,nray] (Nota: krho = krho*ap, rho = (R(:,1)-Rp)/ap
%    - rayparam: ray-tracing parameter
%    - equil_fit: interpolated magnetic equilibrium structure
%
% OUTPUT : 
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
omega = yout(1,7);
s_ray = yout(:,8);
%
if ~isempty(yproc),
    D_ray = yproc(:,1);
    Npar_ray = yproc(:,2);
    Nperp_ray = yproc(:,3);
    epol_pmz_ray = [yproc(:,4) + i*yproc(:,5),yproc(:,6)+i*yproc(:,7),yproc(:,8)+i*yproc(:,9)];
    phi_xyz_ray = [yproc(:,10),yproc(:,11),yproc(:,12)];
    alphaphi_ray = yproc(:,13)*omega/clum;
    R_ray = yproc(:,14)*equil_fit.ap;
    Z_ray = yproc(:,15)*equil_fit.ap;
    B_ray = yproc(:,16);
    BP_ray = yproc(:,17).*B_ray;
    BPHI_ray = yproc(:,18).*B_ray;
    r_ray = yproc(:,19)*equil_fit.ap;
    salpha_ray = yproc(:,20);
    gradrhon_ray = yproc(:,21);
    Te_ray = yproc(:,22);
    ne_ray = yproc(:,23);
    %
    ns = length(equil_fit.zZi);
    %
    for is = 1:ns,
        zTi_ray(:,is) = yproc(:,23+is);
        zni_ray(:,is) = yproc(:,23+ns+is);
    end  
    %
    tau_ray = yproc(:,24+2*ns);
    %
    for ii=1:length(Npar_ray),
        [Nperpp,Nperpm] = colddisp_dke_jd(Npar_ray(ii),omega,ne_ray(ii),zni_ray(ii,:),equil_fit.zZi,equil_fit.zmi,B_ray(ii));
        %
        pmode_ray(ii,1) = abs(Nperpp - Nperp_ray(ii)) <= abs(Nperpm - Nperp_ray(ii)); 
    end
    %
    iabs_out = length(Npar_ray);
    %
else
    %
    omega_ray = yout(:,7);
    %
   [R_ray,Z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,D_ray,Te_ray,ne_ray,zTi_ray,zni_ray,BP_ray,BPHI_ray,B_ray,r_ray,salpha_ray,gradrho_ray,pmode_ray] = rayparameters_yp(rayparam,equil_fit,omega_ray,rho_ray,theta_ray,phi_ray,krho_ray,m_ray,n_ray);
    %
    s_ray = [];
    alphaphi_ray = [];
    tau_ray = [];
    %
end
%
if ~isempty(yproc) & rayparam.tau_lim > 0,
    %
    iabs_out = length(Npar_ray);% ray stopped after absorption
    %
else
    %
    iabs_out = min([find(6.5./sqrt(Te_ray) < abs(Npar_ray)),length(Npar_ray)]);
    %
end
%
pmode_ray = logical(pmode_ray);
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
    for ii = 2:length(s),
       X_vac_c = X_vac0_c(:,ii-1) + N_vac0_c*(s(ii) - s(ii-1));%Ray equation in cartesian coordinates at next position
%
       phi_vac(ii,1) = atan(X_vac_c(2)/X_vac_c(1)) + pi*(X_vac_c(1) < 0);%New ray equation in toroidal coordinates
       rho_vac(ii,1) = sqrt((X_vac_c(1)/cos(phi_vac(ii)) - Rpn)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
       theta_vac(ii,1) = asin(X_vac_c(3)/rho_vac(ii))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) > Rpn) + (pi*sign(theta_vac(ii-1)) - asin(X_vac_c(3)/rho_vac(ii)))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) < Rpn);%New ray equation in toroidal coordinates
%       
       if rho_vac(ii) >=1,%Specular reflexion is enforced at plasma boundary
           Mrot0 = [cos(theta_vac(ii-1))*cos(phi_vac(ii-1)),cos(theta_vac(ii-1))*sin(phi_vac(ii-1)),+sin(theta_vac(ii-1));-sin(theta_vac(ii-1))*cos(phi_vac(ii-1)),-sin(theta_vac(ii-1))*sin(phi_vac(ii-1)),cos(theta_vac(ii-1));sin(phi_vac(ii-1)),-cos(phi_vac(ii-1)),0];
           Mrot1 = [-cos(theta_vac(ii-1))*cos(phi_vac(ii-1)),-cos(theta_vac(ii-1))*sin(phi_vac(ii-1)),-sin(theta_vac(ii-1));-sin(theta_vac(ii-1))*cos(phi_vac(ii-1)),-sin(theta_vac(ii-1))*sin(phi_vac(ii-1)),cos(theta_vac(ii-1));sin(phi_vac(ii-1)),-cos(phi_vac(ii-1)),0];
           N_vac0_c = inv(Mrot0)*(Mrot1*N_vac0_c);%Ray direction is updated
           X_vac_c = X_vac0_c(:,ii-1) + N_vac0_c*(s(ii) - s(ii-1));%Ray equation in cartesian coordinates 
%
           phi_vac(ii) = atan(X_vac_c(2)/X_vac_c(1)) + pi*(X_vac_c(1) < 0);%New ray equation in toroidal coordinates
           rho_vac(ii) = sqrt((X_vac_c(1)/cos(phi_vac(ii)) - Rpn)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
           theta_vac(ii) = asin(X_vac_c(3)/rho_vac(ii))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) > Rpn) + (pi*sign(theta_vac(ii-1)) - asin(X_vac_c(3)/rho_vac(ii)))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) < Rpn);%New ray equation in toroidal coordinates
       end
%      
       rn_vac(ii,1) = rho_vac(ii);%circular concentric magnetic flux surfaces
       Rn_vac(ii,1) = sqrt(X_vac_c(1)^2 + X_vac_c(2)^2);
%
       invMrot = inv([cos(theta_vac(ii))*cos(phi_vac(ii)),-sin(theta_vac(ii))*cos(phi_vac(ii)),-sin(phi_vac(ii));cos(theta_vac(ii))*sin(phi_vac(ii)),-sin(theta_vac(ii))*sin(phi_vac(ii)),cos(phi_vac(ii));sin(theta_vac(ii)),cos(theta_vac(ii)),0]);
       N_vac = invMrot*N_vac0_c;
%
       krho_vac(ii,1) = N_vac(1)/cnorm;
       m_vac(ii,1) = N_vac(2)*rn_vac(ii,1)/cnorm;
       n_vac(ii,1) = N_vac(3)*Rn_vac(ii,1)/cnorm;
%
       X_vac0_c(:,ii) = X_vac_c;
    end
%
    [dummy,dummy,Npar_vac,Nperp_vac,epol_pmz_vac,phi_xyz_vac,D_vac,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy] = rayparameters_yp(rayparam,equil_fit,omega_vac,rho_vac,theta_vac,phi_vac,krho_vac,m_vac,n_vac);
end
%
% Build magnetic equilibrium for display
%
if display_mode,
    ntheta_fit= 65;
    rho_fit = linspace(0,1,15);
    theta_fit = linspace(0,2*pi,ntheta_fit);
    phi_fit = linspace(0,2*pi,ntheta_fit);
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
    % For toroidal display
    %
    X_ray = R_ray.*cos(phi_ray);
    Y_ray = - R_ray.*sin(phi_ray);%Note : phi is clockwise from top
    Xmin_fit = Rmin*cos(phi_fit);   
    Ymin_fit = Rmin*sin(phi_fit); 
    Xmax_fit = Rmax*cos(phi_fit);   
    Ymax_fit = Rmax*sin(phi_fit); 
    Xp_fit = equil_fit.Rp*cos(phi_fit);   
    Yp_fit = equil_fit.Rp*sin(phi_fit); 
    ss = sign(diff(rho_ray));
    %
    % Display results 
    %
   figure('Name','Poloidal ray trajectory')
   [ax] = graph1D_jd(R_ray(pmode_ray),Z_ray(pmode_ray),0,0,'R(m)','Z(m)',['Poloidal Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'none','.','r',2);hold on
   [ax] = graph1D_jd(R_ray(~pmode_ray),Z_ray(~pmode_ray),0,0,'R(m)','Z(m)',['Poloidal Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'none','.','b',2);hold on
%
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(sqrt(X_vac0_c(1,:).^2+X_vac0_c(2,:).^2)*equil_fit.ap,X_vac0_c(3,:)*equil_fit.ap,0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   else
      [ax] = graph1D_jd(R_ray(iabs_out:end),Z_ray(iabs_out:end),0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','k',2);hold on 
   end
   [ax] = graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
%
   for ii = 1:length(R_ray)-2,
      if (ss(ii) ~= ss(ii+1)),
         text(R_ray(ii),Z_ray(ii),num2str(ii));
      end
   end
%
   axis('equal');drawnow  
   print_jd(p_opt,[filename,'_RayPoloidal']);
%
   figure('Name','Toroidal ray trajectory')
   [ax] = graph1D_jd(X_ray(pmode_ray),Y_ray(pmode_ray),0,0,'X(m)','y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'none','.','r',2);hold on
   [ax] = graph1D_jd(X_ray(~pmode_ray),Y_ray(~pmode_ray),0,0,'X(m)','y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'none','.','b',2);hold on
%
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(X_vac0_c(1,:)*equil_fit.ap,X_vac0_c(2,:)*equil_fit.ap,0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   else
      [ax] = graph1D_jd(X_ray(iabs_out:end),Y_ray(iabs_out:end),0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','k',2);hold on 
   end
   [ax] = graph1D_jd(Xmin_fit,Ymin_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','b',1);drawnow
   [ax] = graph1D_jd(Xmax_fit,Ymax_fit,0,0,'X(m)','Y(m)','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','b',1);hold on
   [ax] = graph1D_jd(Xp_fit,Yp_fit,0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'--','none','b',1);hold on
%
   for ii = 1:length(X_ray)-2,
      if (ss(ii) ~= ss(ii+1)),
         text(X_ray(ii),Y_ray(ii),num2str(ii));
      end
   end
%
   axis('equal');drawnow  
   print_jd(p_opt,[filename,'_RayToroidal']);  
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
   figure('Name','Dispersion relation'),
   graph1D_jd(abs(phi_ray(pmode_ray)/2/pi),abs(D_ray(pmode_ray)),0,1,'abs(\phi)/2\pi','D',['Dispersion relation',subtitle],NaN,'','','none','.','r',2);
   graph1D_jd(abs(phi_ray(~pmode_ray)/2/pi),abs(D_ray(~pmode_ray)),0,1,'abs(\phi)/2\pi','D',['Dispersion relation',subtitle],NaN,'','','none','.','b',2);drawnow
   if isempty(phi_ray(pmode_ray))
       legend({'mode m'})
   elseif isempty(phi_ray(~pmode_ray))
       legend({'mode p'})
   else
       legend({'mode p','mode m'})
   end
   if rem(abs(1-Npar_ray(1)^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
      [ax] = graph1D_jd(phi_vac/2/pi,D_vac,0,0,'abs(\phi)/2\pi','D',['Dispersion relation',subtitle],NaN,'','','--','none','r',2);hold on
      legend('Ray-tracing','Analytic');
   end
   print_jd(p_opt,[filename,'_Disp']);
%
end