function BP = BP_rho_theta(rho,theta,equil,amplitudes)
% Poloidal magnetic field

BP = h_theta(rho,theta,equil,amplitudes).*dphi_p_rho(rho,equil,amplitudes)./ ...
    (2.*pi.*sqrt_g(rho,theta,equil,amplitudes)) ;

rho_zero = repmat(rho==0,1,length(theta));
BP(rho_zero) = 0;

end
