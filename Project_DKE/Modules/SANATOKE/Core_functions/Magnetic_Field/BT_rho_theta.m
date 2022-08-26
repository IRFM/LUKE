function BT = BT_rho_theta(rho,theta,equil,amplitudes)
% Toroidal magnetic field

[~,~,~,~,~,mu0] = pc_dke_yp;

rho(rho==0) = amplitudes(1)/1e8;

BT = mu0.*I_rho(rho,equil,amplitudes) ./ (2.*pi.*h_zeta(rho,theta,equil,amplitudes)) ;
end
