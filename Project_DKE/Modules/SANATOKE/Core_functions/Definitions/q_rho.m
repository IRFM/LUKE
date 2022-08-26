function q = q_rho(rho,equil,amplitudes)

rho(rho==0) = 1e-10;

q = I_rho(rho,equil,amplitudes)./IT_rho(rho,equil) ...
    .*K_rho(rho,equil,amplitudes).*dL_rho(rho,equil,amplitudes);

end

