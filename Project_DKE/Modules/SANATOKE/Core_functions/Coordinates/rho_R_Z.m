function rho = rho_R_Z(R,Z,equil,amplitudes)
% R and Z must have the same size

[rho,~] = cart2curv(R,Z,equil,amplitudes);

end