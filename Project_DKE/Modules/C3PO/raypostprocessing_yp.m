function [iabs_out,rho_ray,theta_ray,x_ray,y_ray,z_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,pmode_ray,D_ray,s_ray,alphaphi_ray,B_ray,BRHO_ray,BP_ray,Bz_ray,Te_ray,ne_ray,zTi_ray,zni_ray,r_ray,salpha_ray,gradrhon_ray,tau_ray,eikval_ray,krho_ray,m_ray,kz_ray,n_ray,wpe2,wce2] = raypostprocessing_yp(tout,yout,yproc,rayparam,equil_fit,fluct_fit,display_text,display_mode,p_opt,filename,subtitle)
%C3PO - Post processing of the ray calculation
%
% Post processing of the ray calculation
%
% INPUT :
%    - tout: ray time (w*t) [1,nray)
%    - yout: ray coordinate (psin,theta,phi,kpsin,m,n,omega,s) [8,nray] (Nota: krho = krho*ap, rho = (R(:,1)-Rp)/ap
%    - yproc: ray coordinate (psin,theta,phi,kpsin,m,n,omega,s) [8,nray] (Nota: krho = krho*ap, rho = (R(:,1)-Rp)/ap
%    - rayparam: ray-tracing parameter
%    - equil_fit: interpolated magnetic equilibrium structure
%	 - fluct_fit: interpolated plasma fluctuation structure
%
% OUTPUT : 
%
% By Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/IRFM, joan.decker@cea.fr)
%
if nargin < 5,
    error('Not enough input arguments in raypostprocessing_yp.m');
end
if nargin < 6,
    fluct_fit = [];
end
if nargin < 7,
    display_text = 0;
end
if nargin < 8,
    display_mode = 0;
end
if nargin < 9,
    p_opt = -1;
end
if nargin < 10,
    filename = '';
end
if nargin < 11,
    subtitle = '';
end
if ~isstruct(fluct_fit),
	fluct_fit = [];
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
tn_ray = tout;
rho_ray = yout(:,1);
theta_ray = yout(:,2);
z_ray = yout(:,3);
krho_ray = yout(:,4); 
m_ray = yout(:,5); 
kz_ray = yout(:,6);
%
if ~isinf(equil_fit.Rp),%for backward compatibility
    phi_ray = yout(:,2)/equil_fit.Rp;
    n_ray = yout(:,6)*equil_fit.Rp;
else
    phi_ray = NaN(size(yout(:,3)));%cylindral magnetic configuration
    n_ray = NaN(size(yout(:,6)));%cylindral magnetic configuration
end
%
omega_ray = yout(:,7);
s_ray = yout(:,8)*equil_fit.ap;
%
omega = yout(1,7);
%
if ~isempty(yproc) & size(yproc,2) >= 26,
    D_ray = yproc(:,1);
    Npar_ray = yproc(:,2);
    Nperp_ray = yproc(:,3);
    epol_pmz_ray = [yproc(:,4) + i*yproc(:,5),yproc(:,6)+i*yproc(:,7),yproc(:,8)+i*yproc(:,9)];
    phi_xyz_ray = [yproc(:,10),yproc(:,11),yproc(:,12)];
    alphaphi_ray = yproc(:,13)*omega/clum;
    x_ray = yproc(:,14)*equil_fit.ap;
    y_ray = yproc(:,15)*equil_fit.ap;
    B_ray = yproc(:,16);
    BRHO_ray = yproc(:,17).*B_ray;
    BP_ray = yproc(:,18).*B_ray;
    Bz_ray = yproc(:,19).*B_ray;
    r_ray = yproc(:,20)*equil_fit.ap;
    salpha_ray = yproc(:,21);
    gradrhon_ray = yproc(:,22);
    eikval_ray = yproc(:,23);
    Upsilonn_ray = yproc(:,24);%(1 + x/Rp)/ap where Upsilon = 1 + x/Rp
    Te_ray = yproc(:,25);
    ne_ray = yproc(:,26);
    %
    ns = length(equil_fit.zZi);
    %
    for is = 1:ns,
        zTi_ray(:,is) = yproc(:,26+is);
        zni_ray(:,is) = yproc(:,26+ns+is);
    end  
    %
    tau_ray = yproc(:,27+2*ns);
    %
    for ii=1:length(Npar_ray),
        [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk,sigmap,sigmam,Dp,Dm,ps,ys] = colddisp_dke_jd(Npar_ray(ii),omega,ne_ray(ii),zni_ray(ii,:),equil_fit.zZi,equil_fit.zmi,B_ray(ii));
        %
        pmode_ray(ii,1) = abs(Nperpp - Nperp_ray(ii)) <= abs(Nperpm - Nperp_ray(ii)); 
		%
		Npar_acc = colddisp_dke_jd(NaN,omega,ne_ray(ii),zni_ray(ii,:),equil_fit.zZi,equil_fit.zmi,B_ray(ii));%accessibility value
		%
		Npar_ray(ii) = Npar_ray(ii) + i*real(Npar_acc);
        %
        wpe2(ii) = ps(1)^2;
        wce2(ii) = ys(1)^2;
    end
    %
    iabs_out = length(Npar_ray);
    %
else
    %
    [x_ray,y_ray,Npar_ray,Nperp_ray,epol_pmz_ray,phi_xyz_ray,D_ray,Te_ray,ne_ray,zTi_ray,zni_ray,BRHO_ray,BP_ray,Bz_ray,B_ray,r_ray,salpha_ray,gradrho_ray,Upsilon_ray,pmode_ray,wpe2,wce2] = rayparameters_yp(rayparam,equil_fit,fluct_fit,omega_ray,rho_ray,theta_ray,z_ray,krho_ray,m_ray,kz_ray);
    %
    alphaphi_ray = [];
    tau_ray = [];
    eikval_ray = [];
    Upsilonn_ray = Upsilon_ray/equil_fit.ap;
    gradrhon_ray = gradrho_ray*equil_fit.ap;
    %
end
%
if ~isempty(yproc) & rayparam.tau_lim > 0,
    %
    iabs_out = length(Npar_ray);% ray stopped after absorption
    %
else
    %
    iabs_out = min([min(find(6.5./sqrt(Te_ray) < abs(Npar_ray))),length(Npar_ray)]);
    %
end
%
pmode_ray = logical(pmode_ray);
%
if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation. Calculate the exact theoretical solution 
    cnorm = clum/omega_ray(1)/equil_fit.ap;
    %
    if isinf(equil_fit.Rp),
        Rpn = Inf;
    else
        Rpn = equil_fit.Rp/equil_fit.ap;%Normalized major radius
    end
    %
    s = linspace(0,10,1001);%Ray length
    omega_vac = ones(length(s),1)*omega_ray(1);
    %
    Mrot0 = [cos(theta_ray(1))*cos(z_ray(1)/equil_fit.Rp),-sin(theta_ray(1))*cos(z_ray(1)/equil_fit.Rp),-sin(z_ray(1)/equil_fit.Rp);cos(theta_ray(1))*sin(z_ray(1)/equil_fit.Rp),-sin(theta_ray(1))*sin(z_ray(1)/equil_fit.Rp),cos(z_ray(1)/equil_fit.Rp);sin(theta_ray(1)),cos(theta_ray(1)),0];
    N_ray0 = cnorm*[krho_ray(1);m_ray(1)*equil_fit.ap/r_ray(1);kz_ray(1)*equil_fit.ap/Upsilon_ray(1)];%Initial wave vector in contravariant coordinates
    N_vac0_c = Mrot0*N_ray0;%Initial wave vector in cartesian coordinates
    %
    z_vac(1) = z_ray(1)/equil_fit.ap;
    rho_vac(1) = rho_ray(1);
    theta_vac(1) = theta_ray(1);
    rn_vac(1) = r_ray(1)/equil_fit.ap;
    xn_vac(1) = x_ray(1)/equil_fit.ap;
    krho_vac(1) = krho_ray(1);
    m_vac(1) = m_ray(1);
    kz_vac(1) = kz_ray(1);
    %
    if isinf(equil_fit.Rp),
        n_vac(1) = NaN;
    else
        n_vac(1) = kz_vac(1)*equil_fit.Rp;
    end    
    %
    if isinf(equil_fit.Rp),
        X_vac0_c = [rho_vac(1)*cos(theta_vac(1));z_vac(1);rho_vac(1)*sin(theta_vac(1))];%Initial ray position in Cartesian coordinates
    else
        X_vac0_c = [(Rpn + rho_vac(1)*cos(theta_vac(1)))*cos(z_vac(1)/Rpn);(Rpn + rho_vac(1)*cos(theta_vac(1)))*sin(z_vac(1)/Rpn);rho_vac(1)*sin(theta_vac(1))];%Initial ray position in Cartesian coordinates
    end    
    %
    for ii = 2:length(s),
        X_vac_c = X_vac0_c(:,ii-1) + N_vac0_c*(s(ii) - s(ii-1));%Ray equation in cartesian coordinates at next position
        %
        if isinf(equil_fit.Rp),
            z_vac(ii,1) = X_vac_c(ii,2);%New ray equation in toroidal coordinates
            rho_vac(ii,1) = sqrt(X_vac_c(1)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
            theta_vac(ii,1) = asin(X_vac_c(3)/rho_vac(ii));%New ray equation in toroidal coordinates
        else
            z_vac(ii,1) = Rpn*(atan(X_vac_c(2)/X_vac_c(1)) + pi*(X_vac_c(1) < 0));%New ray equation in toroidal coordinates
            rho_vac(ii,1) = sqrt((X_vac_c(1)/cos(z_vac(ii)/Rpn) - Rpn)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
            theta_vac(ii,1) = asin(X_vac_c(3)/rho_vac(ii))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) > Rpn) + (pi*sign(theta_vac(ii-1)) - asin(X_vac_c(3)/rho_vac(ii)))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) < Rpn);%New ray equation in toroidal coordinates
        end
        %   
        if rho_vac(ii) >=1,%Specular reflexion is enforced at plasma boundary
            Mrot0 = [cos(theta_vac(ii-1))*cos(z_vac(ii-1)/Rpn),cos(theta_vac(ii-1))*sin(z_vac(ii-1)/Rpn),+sin(theta_vac(ii-1));-sin(theta_vac(ii-1))*cos(z_vac(ii-1)/Rpn),-sin(theta_vac(ii-1))*sin(z_vac(ii-1)/Rpn),cos(theta_vac(ii-1));sin(z_vac(ii-1)/Rpn),-cos(z_vac(ii-1)/Rpn),0];
            Mrot1 = [-cos(theta_vac(ii-1))*cos(z_vac(ii-1)/Rpn),-cos(theta_vac(ii-1))*sin(z_vac(ii-1)/Rpn),-sin(theta_vac(ii-1));-sin(theta_vac(ii-1))*cos(z_vac(ii-1)/Rpn),-sin(theta_vac(ii-1))*sin(z_vac(ii-1)/Rpn),cos(theta_vac(ii-1));sin(z_vac(ii-1)/Rpn),-cos(z_vac(ii-1)/Rpn),0];
            N_vac0_c = inv(Mrot0)*(Mrot1*N_vac0_c);%Ray direction is updated
            X_vac_c = X_vac0_c(:,ii-1) + N_vac0_c*(s(ii) - s(ii-1));%Ray equation in cartesian coordinates 
            %
            if isinf(equil_fit.Rp),
                z_vac(ii,1) = X_vac_c(ii,2);%New ray equation in toroidal coordinates
                rho_vac(ii,1) = sqrt(X_vac_c(1)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
                theta_vac(ii,1) = asin(X_vac_c(3)/rho_vac(ii));%New ray equation in toroidal coordinates
            else
                r_vac(ii) = Rpn*(atan(X_vac_c(2)/X_vac_c(1)) + pi*(X_vac_c(1) < 0));%New ray equation in toroidal coordinates
                rho_vac(ii) = sqrt((X_vac_c(1)/cos(z_vac(ii)/Rpn) - Rpn)^2 + X_vac_c(3)^2);%New ray equation in toroidal coordinates
                theta_vac(ii) = asin(X_vac_c(3)/rho_vac(ii))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) > Rpn) + (pi*sign(theta_vac(ii-1)) - asin(X_vac_c(3)/rho_vac(ii)))*(sqrt(X_vac_c(1)^2+X_vac_c(2)^2) < Rpn);%New ray equation in toroidal coordinates
            end
        end
        %      
        rn_vac(ii,1) = rho_vac(ii);%circular concentric magnetic flux surfaces
        %
        invMrot = inv([cos(theta_vac(ii))*cos(z_vac(ii)/Rpn),-sin(theta_vac(ii))*cos(z_vac(ii)/Rpn),-sin(z_vac(ii)/Rpn);cos(theta_vac(ii))*sin(z_vac(ii)/Rpn),-sin(theta_vac(ii))*sin(z_vac(ii)/Rpn),cos(z_vac(ii)/Rpn);sin(theta_vac(ii)),cos(theta_vac(ii)),0]);
        N_vac = invMrot*N_vac0_c;
        %
        krho_vac(ii,1) = N_vac(1)/cnorm;
        m_vac(ii,1) = N_vac(2)*rn_vac(ii,1)/cnorm;       
        %
        if ~isinf(equil_fit.Rp),
            Rn_vac(ii,1) = sqrt(X_vac_c(1)^2 + X_vac_c(2)^2);
            kz_vac(ii,1) = N_vac(3)*Rn_vac(ii,1)/cnorm/equil_fit.Rp;
            n_vac(ii,1) = kz_vac(ii,1)*equil_fit.Rp;
            phi_vac(ii,1) = z_vac(ii,1)/Rpn;
        else
            kz_vac(ii,1) = N_vac(3)/cnorm/equil_fit.ap;
            n_vac(ii,1) = NaN;
            phi_vac(ii,1) = NaN;
        end
        %
        X_vac0_c(:,ii) = X_vac_c;
    end
    %
    [dummy,dummy,Npar_vac,Nperp_vac,epol_pmz_vac,phi_xyz_vac,D_vac,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy] = rayparameters_yp(rayparam,equil_fit,fluct_fit,omega_vac,rho_vac,theta_vac,z_vac*equil_fit.ap,krho_vac,m_vac,kz_vac);
    %
    eikval_vac = [];
    %
end
%
% Build magnetic equilibrium for display
%
if display_mode,
    %
    ntheta_fit = 65;
    rho_fit = linspace(0,1,15);
    theta_fit = linspace(0,2*pi,ntheta_fit);
    x_a0_fit = ppval(equil_fit.x_fit.pp_a0,rho_fit);
    x_an_fit = ppval(equil_fit.x_fit.pp_an,rho_fit);
    x_bn_fit = ppval(equil_fit.x_fit.pp_bn,rho_fit);
    y_a0_fit = ppval(equil_fit.y_fit.pp_a0,rho_fit);
    y_an_fit = ppval(equil_fit.y_fit.pp_an,rho_fit);
    y_bn_fit = ppval(equil_fit.y_fit.pp_bn,rho_fit);
    %
	if ~isinf(equil_fit.Rp),% For toroidal display
        %
        phi_fit = linspace(0,2*pi,ntheta_fit);
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
        phi_ray = z_ray/equil_fit.Rp;
        %
        X_ray = (x_ray + equil_fit.Rp).*cos(phi_ray);
        Y_ray = - (x_ray  + equil_fit.Rp).*sin(phi_ray);%Note : phi is clockwise from top
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
        flag_vacuum = 0;
        figure('Name','Poloidal ray trajectory')
        [ax] = graph1D_jd(x_ray(pmode_ray) + equil_fit.Rp,y_ray(pmode_ray) + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'none','.','r',2);hold on
        [ax] = graph1D_jd(x_ray(~pmode_ray) + equil_fit.Rp,y_ray(~pmode_ray) + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'none','.','b',2);hold on
    % 
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(sqrt(X_vac0_c(1,:).^2+X_vac0_c(2,:).^2)*equil_fit.ap,X_vac0_c(3,:)*equil_fit.ap,0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
           flag_vacuum = 1;
        else
           [ax] = graph1D_jd(x_ray(iabs_out:end) + equil_fit.Rp,y_ray(iabs_out:end) + equil_fit.Zp,0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','k',2);hold on 
        end
        [ax] = graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
        [ax] = graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)',['Ray trajectory',subtitle],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
    %
        if display_text & flag_vacuum == 0,
          for ii = 1:length(x_ray)-2,
             if (ss(ii) ~= ss(ii+1)),
                text(x_ray(ii) + equil_fit.Rp,x_ray(ii) + equil_fit.Zp,num2str(ii));
             end
          end
        end
        %
        axis('equal');drawnow  
        print_jd(p_opt,[filename,'_RayPoloidal']);
        %
        figure('Name','Toroidal ray trajectory')
        [ax] = graph1D_jd(X_ray(pmode_ray),Y_ray(pmode_ray),0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'none','.','r',2);hold on
        [ax] = graph1D_jd(X_ray(~pmode_ray),Y_ray(~pmode_ray),0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'none','.','b',2);hold on
        %
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
            [ax] = graph1D_jd(X_vac0_c(1,:)*equil_fit.ap,-X_vac0_c(2,:)*equil_fit.ap,0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'--','none','r',2);hold on
            legend('Ray-tracing','Straight lines model');
        else
            [ax] = graph1D_jd(X_ray(iabs_out:end),Y_ray(iabs_out:end),0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','k',2);hold on 
        end
        [ax] = graph1D_jd(Xmin_fit,Ymin_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','b',1);drawnow
        [ax] = graph1D_jd(Xmax_fit,Ymax_fit,0,0,'X(m)','Y(m)','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','b',1);hold on
        [ax] = graph1D_jd(Xp_fit,Yp_fit,0,0,'X(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'--','none','b',1);hold on
        %
        if display_text & flag_vacuum == 0,
            for ii = 1:length(X_ray)-2,
                if (ss(ii) ~= ss(ii+1)),
                    text(X_ray(ii),Y_ray(ii),num2str(ii));
                end
            end
        end
        %
        axis('equal');drawnow  
        print_jd(p_opt,[filename,'_RayToroidal']);
        %
    else,% for cylindrical display
        %
        theta_fit = linspace(0,2*pi,ntheta_fit);
        %
        for ii = 1:ntheta_fit,
            x_fit(:,ii) = x_a0_fit.' + x_an_fit*cos(equil_fit.x_fit.n*theta_fit(ii)) + x_bn_fit*sin(equil_fit.x_fit.n*theta_fit(ii));
            y_fit(:,ii) = y_a0_fit.' + y_an_fit*cos(equil_fit.y_fit.n*theta_fit(ii)) + y_bn_fit*sin(equil_fit.y_fit.n*theta_fit(ii));
        end
        %
        xmin = min(min(x_fit));
        xmax = max(max(x_fit)); 
        Zmin = min(min(y_fit)) + equil_fit.Zp;
        Zmax = max(max(y_fit)) + equil_fit.Zp;
        %
        %phi_ray = z_ray/equil_fit.Rp;
        %
        X_ray = x_ray;
        Y_ray = - y_ray;%Note : phi is clockwise from top
        Xmin_fit = -equil_fit.ap*cos(theta_fit);   
        Ymin_fit = -equil_fit.ap*sin(theta_fit); 
        Xmax_fit = equil_fit.ap*cos(theta_fit);   
        Ymax_fit = equil_fit.ap*sin(theta_fit); 
        Zmin_fit = linspace(-equil_fit.ap,equil_fit.ap,ntheta_fit);
        Xp_fit = 0*cos(theta_fit);   
        Yp_fit = 0*sin(theta_fit);
        Zp_fit = 0*sin(theta_fit); 
        ss = sign(diff(rho_ray));
        %
        % Display results 
        %
        flag_vacuum = 0;
        figure('Name','Poloidal ray trajectory')
        [ax] = graph1D_jd(x_ray(pmode_ray),y_ray(pmode_ray) + equil_fit.Zp,0,0,'x(m)','Z(m)',['Poloidal Ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[Zmin,Zmax],'none','.','r',2);hold on
        [ax] = graph1D_jd(x_ray(~pmode_ray),y_ray(~pmode_ray) + equil_fit.Zp,0,0,'x(m)','Z(m)',['Poloidal Ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[Zmin,Zmax],'none','.','b',2);hold on
        % 
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(sqrt(X_vac0_c(1,:).^2+X_vac0_c(2,:).^2)*equil_fit.ap,X_vac0_c(3,:)*equil_fit.ap,0,0,'x(m)','Z(m)',['Ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[Zmin,Zmax],'--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
           flag_vacuum = 1;
        else
           [ax] = graph1D_jd(x_ray(iabs_out:end),y_ray(iabs_out:end) + equil_fit.Zp,0,0,'x(m)','Z(m)',['Ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[Zmin,Zmax],'-','none','k',2);hold on 
        end
        [ax] = graph1D_jd(x_fit,y_fit + equil_fit.Zp,0,0,'','','',NaN,[-equil_fit.ap,equil_fit.ap],[Zmin,Zmax],'-','none','b',1);drawnow
        [ax] = graph1D_jd(x_fit',y_fit' + equil_fit.Zp,0,0,'x(m)','Z(m)',['Ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[Zmin,Zmax],'-','none','b',1);hold on
        %
        if display_text & flag_vacuum == 0,
            for ii = 1:length(x_ray)-2,
                if (ss(ii) ~= ss(ii+1)),
                    text(x_ray(ii),x_ray(ii) + equil_fit.Zp,num2str(ii));
                end
            end
        end
        %
        axis('equal');drawnow  
        print_jd(p_opt,[filename,'_RayPoloidal']);
        %    
        figure('Name','Axial ray trajectory')
        [ax] = graph1D_jd(x_ray(pmode_ray),-z_ray(pmode_ray),0,0,'x(m)','Y(m)',['Axial ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[min(-z_ray),max(-z_ray)],'none','.','r',2);hold on
        [ax] = graph1D_jd(x_ray(~pmode_ray),-z_ray(~pmode_ray),0,0,'x(m)','Y(m)',['Axial ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[min(-z_ray),max(-z_ray)],'none','.','b',2);hold on
        %
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
            [ax] = graph1D_jd(X_vac0_c(1,:)*equil_fit.ap,-X_vac0_c(2,:)*equil_fit.ap,0,0,'x(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[min(z_ray),max(z_ray)],'--','none','r',2);hold on
            legend('Ray-tracing','Straight lines model');
        else
            [ax] = graph1D_jd(X_ray(iabs_out:end),Y_ray(iabs_out:end),0,0,'x(m)','Y(m)',['Axial ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[min(-z_ray),max(-z_ray)],'-','none','k',2);hold on 
        end
        %
        for ii = 1:ntheta_fit,
            [ax] = graph1D_jd([Xmin_fit(ii),Xmin_fit(ii)],[min(-z_ray),max(-z_ray)],0,0,'x(m)','Y(m)',['Toroidal ray trajectory',subtitle],NaN,[-equil_fit.ap,equil_fit.ap],[min(-z_ray),max(-z_ray)],'-','none','b',1);drawnow        
        end
        %
        if display_text & flag_vacuum == 0,
            for ii = 1:length(X_ray)-2,
                if (ss(ii) ~= ss(ii+1)),
                    text(x_ray(ii),z_ray(ii),num2str(ii));
                end
            end
        end
        %
        drawnow  
        print_jd(p_opt,[filename,'_RayAxial']);
        %
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Parallel wave refractive index')
        graph1D_jd(abs(phi_ray)/2/pi,[real(Npar_ray),imag(Npar_ray)*sign(real(Npar_ray(1)))],0,0,'(2*\phi_0+|\phi|)/2\pi','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(real(Npar_ray)),max(real(Npar_ray))],'-','none',NaN,2);drawnow;hold off
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
          [ax] = graph1D_jd(phi_vac/2/pi,Npar_vac,0,0,'\phi/2\pi','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(real(Npar_ray)),max(real(Npar_ray))],'--','none','r',2);hold on
          legend('Ray-tracing','Straight lines model');
        else
          graph1D_jd(abs(phi_ray)/2/pi,sign(real(Npar_ray(1)))*6.5./sqrt(Te_ray),0,0,'(2*\phi_0+|\phi|)/2\pi','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(real(Npar_ray)),max(real(Npar_ray))],'-','none','r',2);drawnow;hold off
          legend('Ray-tracing','Accessibility','Landau damping');
        end
        print_jd(p_opt,[filename,'_Npar']);
    else,% for cylindrical display
        figure('Name','Parallel wave refractive index')
        graph1D_jd(abs(z_ray),[real(Npar_ray),imag(Npar_ray)*sign(real(Npar_ray(1)))],0,0,'|z|(m)','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(real(Npar_ray)),max(real(Npar_ray))],'-','none',NaN,2);drawnow;hold off
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
          [ax] = graph1D_jd(abs(z_ray),Npar_vac,0,0,'z(m)','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(real(Npar_ray)),max(real(Npar_ray))],'--','none','r',2);hold on
          legend('Ray-tracing','Straight lines model');
        else
          graph1D_jd(abs(z_ray),sign(real(Npar_ray(1)))*6.5./sqrt(Te_ray),0,0,'|z|(m)','N_{||}',['Parallel wave refractive index',subtitle],NaN,'',[min(real(Npar_ray)),max(real(Npar_ray))],'-','none','r',2);drawnow;hold off
          legend('Ray-tracing','Accessibility','Landau damping');
        end
        print_jd(p_opt,[filename,'_Npar']);
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Perpendicular wave refractive index')
        graph1D_jd(abs(phi_ray)/2/pi,Nperp_ray,0,0,'|\phi|/(2\pi)','N_{perp}',['Perpendicular wave refractive index',subtitle],NaN,'','','-','none','k',2);drawnow;hold off
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(phi_vac/2/pi,Nperp_vac,0,0,'\phi/2\pi','N_{perp}',['Perpendicular wave refractive index',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Nperp']);
    else,% for cylindrical display
        figure('Name','Perpendicular wave refractive index')
        graph1D_jd(abs(z_ray),Nperp_ray,0,0,'z(m)','N_{perp}',['Perpendicular wave refractive index',subtitle],NaN,'','','-','none','k',2);drawnow;hold off
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(abs(z_ray),Nperp_vac,0,0,'|z|(m)','N_{perp}',['Perpendicular wave refractive index',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model','location','NorthWest');
        end
        print_jd(p_opt,[filename,'_Nperp']);    
    end   
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Poloidal mode number')
        graph1D_jd(abs(phi_ray)/2/pi,yout(:,5),0,0,'|\phi|/(2\pi)','m',['Poloidal mode number',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(phi_vac/2/pi,m_vac,0,0,'\phi/2\pi','m',['Poloidal mode number',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_PoloidalMode']);
    else,% for cylindrical display
        figure('Name','Poloidal mode number')
        graph1D_jd(abs(z_ray),yout(:,5),0,0,'z(m)','m',['Poloidal mode number',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(abs(z_ray),m_vac,0,0,'|z|(m)','m',['Poloidal mode number',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_PoloidalMode']);        
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Toroidal mode number')
        graph1D_jd(abs(phi_ray)/2/pi,yout(:,6)*equil_fit.Rp,0,0,'|\phi|/(2\pi)','n',['Toroidal mode number',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(phi_vac/2/pi,n_vac,0,0,'\phi/2\pi','n',['Toroidal mode number',subtitle],NaN,'',[0,max(yout(1,6))*1.1],'--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_ToroidalMode']);
    else,% for cylindrical display
        figure('Name','Axial wave vector')
        graph1D_jd(abs(z_ray),yout(:,6),0,0,'|z|(m)','kz (m-1)',['Axial wave vector',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(abs(z_ray),kz_vac,0,0,'|z|(m)','kz (m-1)',['Axial wave vector',subtitle],NaN,'',[0,max(yout(1,6))*1.1],'--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_AxialWaveVector']); 
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Poloidal angle')
        graph1D_jd(abs(phi_ray)/2/pi,yout(:,2)/2/pi,0,0,'|\phi|/(2\pi)','\theta/2\pi',['Poloidal angle',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(phi_vac/2/pi,theta_vac/2/pi,0,0,'\phi/2\pi','(\theta/2\pi)',['Poloidal angle',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Theta']);
    else,% for cylindrical display
        figure('Name','Poloidal angle')
        graph1D_jd(abs(z_ray),yout(:,2)/2/pi,0,0,'|z|(m)','\theta/2\pi',['Poloidal angle',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(abs(z_ray),theta_vac/2/pi,0,0,'|z|(m)','\theta/(2\pi)',['Poloidal angle',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Theta']);
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Radial position')
        graph1D_jd(abs(phi_ray)/2/pi,yout(:,1),0,0,'|\phi|/(2\pi)','rho',['Normalized radial position',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(phi_vac/2/pi,rho_vac,0,0,'\phi/(2\pi)','rho',['Normalized radial position',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Rho']);
    else,% for cylindrical display
        figure('Name','Radial position')
        graph1D_jd(abs(z_ray),yout(:,1),0,0,'|z|(m)','rho',['Normalized radial position',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(abs(z_ray),rho_vac,0,0,'|z|(m)','rho',['Normalized radial position',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Rho']);   
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Normalized radial wave vector')
        graph1D_jd(abs(phi_ray)/2/pi,yout(:,4),0,0,'|\phi|/(2\pi)','krho*ap',['Normalized radial wavenumber',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(phi_vac/2/pi,krho_vac,0,0,'\phi/2\pi','krho*ap',['Normalized radial wavenumber',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_RadialWaveVector']);
    else,% for cylindrical display
        figure('Name','Normalized radial wave vector')
        graph1D_jd(abs(z_ray),yout(:,4),0,0,'|z|(m)','krho*ap',['Normalized radial wave vector',subtitle],NaN,'','','-','none','k',2);drawnow;hold on
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
           [ax] = graph1D_jd(abs(z_ray),krho_vac,0,0,'|z|(m)','krho*ap',['Normalized radial wave vector',subtitle],NaN,'','','--','none','r',2);hold on
           legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_RadialWaveVector']);    
    end
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        figure('Name','Dispersion relation'),
        graph1D_jd(abs(phi_ray(pmode_ray))/2/pi,abs(D_ray(pmode_ray)),0,1,'|\phi|/(2\pi)','D',['Dispersion relation',subtitle],NaN,'','','none','.','r',2);
        graph1D_jd(abs(phi_ray(~pmode_ray))/2/pi,abs(D_ray(~pmode_ray)),0,1,'|\phi|/(2\pi)','D',['Dispersion relation',subtitle],NaN,'','','none','.','b',2);drawnow
        if isempty(phi_ray(pmode_ray))
           legend({'mode m'})
        elseif isempty(phi_ray(~pmode_ray))
           legend({'mode p'})
        else
           legend({'mode p','mode m'})
        end
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
          [ax] = graph1D_jd(phi_vac/2/pi,D_vac,0,0,'\phi/2\pi','D',['Dispersion relation',subtitle],NaN,'','','--','none','r',2);hold on
          legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Disp']);
    else,% for cylindrical display
        figure('Name','Dispersion relation'),
        graph1D_jd(abs(z_ray(pmode_ray)),abs(D_ray(pmode_ray)),0,1,'|z|(m)','D',['Dispersion relation',subtitle],NaN,'','','none','.','r',2);
        graph1D_jd(abs(z_ray(~pmode_ray)),abs(D_ray(~pmode_ray)),0,1,'|z|(m)','D',['Dispersion relation',subtitle],NaN,'','','none','.','b',2);drawnow
        if isempty(z_ray(pmode_ray))
           legend({'mode m'})
        elseif isempty(z_ray(~pmode_ray))
           legend({'mode p'})
        else
           legend({'mode p','mode m'})
        end
        if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
          [ax] = graph1D_jd(abs(z_vac),D_vac,0,0,'|z|(m)','D',['Dispersion relation',subtitle],NaN,'','','--','none','r',2);hold on
          legend('Ray-tracing','Straight lines model');
        end
        print_jd(p_opt,[filename,'_Disp']);        
    end      
    %
    if ~isinf(equil_fit.Rp),% For toroidal display    
        if ~isempty(eikval_ray),
            figure('Name','Validity of the eikonal approximation'),
            graph1D_jd(abs(phi_ray(pmode_ray))/2/pi,abs(eikval_ray(pmode_ray)),0,1,'|\phi|/(2\pi)','\nabla\cdotN/N^2',['Validity of the eikonal approximation (< 1)',subtitle],NaN,'','','none','.','r',2);
            graph1D_jd(abs(phi_ray(~pmode_ray))/2/pi,abs(eikval_ray(~pmode_ray)),0,1,'|\phi|/(2\pi)','\nabla\cdotN/N^2',['Validity of the eikonal approximation (< 1)',subtitle],NaN,'','','none','.','b',2);drawnow
            if isempty(phi_ray(pmode_ray))
                legend({'mode m'})
            elseif isempty(phi_ray(~pmode_ray))
                legend({'mode p'})
            else
                legend({'mode p','mode m'})
            end
            print_jd(p_opt,[filename,'_Eikval']);
        end
        %
        if exist('eikval_vac'),
           if ~isempty(eikval_vac),
                if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
                    [ax] = graph1D_jd(phi_vac/2/pi,eikval_vac,0,0,'\phi/2\pi','\nabla\cdotN/N^2',['\nabla\cdotN/N^2',subtitle],NaN,'','','--','none','r',2);hold on
                    legend('Ray-tracing','Straight lines model');
                end
                print_jd(p_opt,[filename,'_Eikval']);
           end
        end
    else,% for cylindrical display
        if ~isempty(eikval_ray),
            figure('Name','Validity of the eikonal approximation'),
            graph1D_jd(abs(z_ray(pmode_ray)),abs(eikval_ray(pmode_ray)),0,1,'|z|(m)','\nabla\cdotN/N^2',['Validity of the eikonal approximation (< 1)',subtitle],NaN,'','','none','.','r',2);
            graph1D_jd(abs(z_ray(~pmode_ray)),abs(eikval_ray(~pmode_ray)),0,1,'|z|(m)','\nabla\cdotN/N^2',['Validity of the eikonal approximation (< 1)',subtitle],NaN,'','','none','.','b',2);drawnow
            if isempty(z_ray(pmode_ray))
                legend({'mode m'})
            elseif isempty(z_ray(~pmode_ray))
                legend({'mode p'})
            else
                legend({'mode p','mode m'})
            end
            print_jd(p_opt,[filename,'_Eikval']);
        end
        %
        if exist('eikval_vac'),
           if ~isempty(eikval_vac),
                if rem(abs(1-real(Npar_ray(1))^2-Nperp_ray(1)^2),1) <= 100*eps,% Vacuum propagation.
                    [ax] = graph1D_jd(abs(z_vac),eikval_vac,0,0,'|z|(m)','\nabla\cdotN/N^2',['\nabla\cdotN/N^2',subtitle],NaN,'','','--','none','r',2);hold on
                    legend('Ray-tracing','Straight lines model');
                end
                print_jd(p_opt,[filename,'_Eikval']);
           end
        end
        
    end
end