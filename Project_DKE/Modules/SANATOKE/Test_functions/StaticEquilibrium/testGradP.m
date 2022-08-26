function [gradP_kin,gradP_mag] = testGradP(rhos,thetas,equil,amplitudes)
% comparison between the kinetic and the magnetic pressure gradient
% see eq 4 and eq 35 of "Consistency of the toroidal MHD equilibrium" (Y. Peysson)
% in fact we compute <gradP,psi>/grad_rho

[~,~,~,~,~,mu0] = pc_dke_yp;

ni = length(rhos);
nj = length(thetas);
gradP_kin = zeros(ni,nj);
gradP_mag = zeros(ni,nj);

for i=1:ni
    rho = rhos(i);
    if rho==0
        rho = 1e-5;
    end
    
    if rho==equil.a
        rho = equil.a-1e-5;
    end
    
    for j=1:nj
        theta = thetas(j);
        
        % Geometrical values
        R = R_rho_theta(rho,theta,equil,amplitudes);
        Z = Z_rho_theta(rho,theta,equil,amplitudes);
        Rm = amplitudes(2);
        Zm = amplitudes(5);
        r = sqrt((R-Rm).^2+(Z-Zm).^2);
        ap = R_rho_theta(equil.a,0,equil,amplitudes)-Rm;
        gamma = R/Rm;
        cos_alpha_luke = cos(alpha_luke_rho_theta(rho,theta,equil,amplitudes));

        drho = equil.a/100;
        if drho>=rho % namely if rho==1e-5
            drho = rho/2;
        end
        if rho + drho> equil.a
            drho = (equil.a-rho)/2;
        end
        
        rrhos = [rho-drho,rho+drho]';        
        dtheta = pi/100;
        tthetas = [theta-dtheta,theta+dtheta];
        psis_bar = phi_p_rho(rrhos,equil,amplitudes)./Rm;
        rhos_luke = (R_rho_theta(rrhos,0,equil,amplitudes)-Rm)./ap;        
        R_rhos = R_rho_theta(rrhos,theta,equil,amplitudes);
        Z_rhos = Z_rho_theta(rrhos,theta,equil,amplitudes);
        R_rhos_theta0 = R_rho_theta(rrhos,0,equil,amplitudes);
        Z_rhos_theta0 = Z_rho_theta(rrhos,0,equil,amplitudes);
        r_rhos_theta0 = sqrt((R_rhos_theta0-Rm).^2+(Z_rhos_theta0-Zm).^2);
        BP = BP_rho_theta(rho,theta,equil,amplitudes);
        BT = BT_rho_theta(rho,theta,equil,amplitudes);
        grad_rho = abs(gamma.*BP./ap.*(r_rhos_theta0(end)-r_rhos_theta0(1))./(psis_bar(end)-psis_bar(1))); % eq 5

        
        % computation of the kinetic pressure gradient term (eq 4)
        p_rhos = p_rho(rrhos,equil);   
        gradP_kin(i,j) = (p_rhos(end)-p_rhos(1))./(rhos_luke(end)-rhos_luke(1));

        
        % computation of the magnetic pressure gradient (eq 35)
        BP_rhos = BP_rho_theta(rrhos,theta,equil,amplitudes);
        BT_rhos = BT_rho_theta(rrhos,theta,equil,amplitudes);
        cos_alpha_rhos = cos(alpha_luke_rho_theta(rrhos,theta,equil,amplitudes));
        gamma_rhos = R_rhos./Rm;
        r_rhos = sqrt((R_rhos-Rm).^2+(Z_rhos-Zm).^2);

        R_thetas = R_rho_theta(rho,tthetas,equil,amplitudes);
        Z_thetas = Z_rho_theta(rho,tthetas,equil,amplitudes);
        thetas_luke = theta_geometrical_luke_R_Z(R_thetas,Z_thetas,amplitudes);
        gammas_thetas = R_thetas./Rm;
        cos_alpha_thetas = cos(alpha_luke_rho_theta(rho,tthetas,equil,amplitudes));
        sin_alpha_thetas = sqrt(1-cos_alpha_thetas.^2);

        % computation of the three partial derivatives appearing in eq 35
        fun1 = r_rhos.*BP_rhos./cos_alpha_rhos;
        grad1 = (fun1(end)-fun1(1))./(rhos_luke(end)-rhos_luke(1));

        fun2 = sin_alpha_thetas./(gammas_thetas.*cos_alpha_thetas);
        grad2 = (fun2(end)-fun2(1))./(thetas_luke(end)-thetas_luke(1));
        
        fun3 = gamma_rhos.*BT_rhos;
        grad3 = (fun3(end)-fun3(1))./(rhos_luke(end)-rhos_luke(1));

        gradP_mag(i,j) = 1./mu0.*(-BP.*cos_alpha_luke./r.*grad1 ...
            + BP.^2.*gamma.*cos_alpha_luke./(r.*grad_rho).*grad2 ...
            - BT./gamma.*grad3);
        
        term1 = -BP.*cos_alpha_luke./r.*grad1;
        term2 = BP.^2.*gamma.*cos_alpha_luke./(r.*grad_rho).*grad2;
        term3 = - BT./gamma.*grad3;
    end
end

gradP_kin = real(gradP_kin);
gradP_mag = real(gradP_mag);

end

