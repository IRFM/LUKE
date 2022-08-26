function jp = jp_rho_theta(rho,theta,equil,amplitudes)
%JP_RHO_THETA Summary of this function goes here
%   Detailed explanation goes here

rho(rho==0) = 1e-10;

jp = -h_theta(rho,theta,equil,amplitudes)./(2.*pi.*sqrt_g(rho,theta,equil,amplitudes)).*dI_rho(rho,equil,amplitudes);


end

