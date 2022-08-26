function A2 = A2_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dA2_0,d3A2_0] = amps{13:14};
[A2_a,dA2_a,d2A2_a,d3A2_a] = amps{35:38};

rho_star = equil.rho_star;

A2 = S2_like_rho(rho,rho_star,a,dA2_0,d3A2_0,A2_a,dA2_a,d2A2_a,d3A2_a);

end