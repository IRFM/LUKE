function gradrho = grad_rho(rho,theta,equil,amplitudes)

rho(rho==0) = 1e-10;

gradrho = h_theta(rho,theta,equil,amplitudes) ...
    .*h_zeta(rho,theta,equil,amplitudes) ...
    ./sqrt_g(rho,theta,equil,amplitudes);


end

