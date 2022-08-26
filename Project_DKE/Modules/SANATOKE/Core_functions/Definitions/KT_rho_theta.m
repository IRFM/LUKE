function KT = KT_rho_theta(rho,theta,equil,amplitudes)
%KT_RHO Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,~,~,mu0] = pc_dke_yp;

rho(rho==0) = 1e-10;

KT = 1./mu0.*h_theta(rho,theta,equil,amplitudes)./(2.*pi.*sqrt_g(rho,theta,equil,amplitudes)) ...
    .*IT_rho(rho,equil)./K_rho(rho,equil,amplitudes) ;

end

