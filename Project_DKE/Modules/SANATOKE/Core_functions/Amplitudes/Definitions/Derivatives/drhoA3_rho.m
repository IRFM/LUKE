function drhoA3 = drhoA3_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dA3_0,d3A3_0] = amps{17:18};
[A3_a,dA3_a,d2A3_a,d3A3_a] = amps{43:46};

rho_star = equil.rho_star;

drhoA3 = drhoS2_like_rho(rho,rho_star,a,dA3_0,d3A3_0,A3_a,dA3_a,d2A3_a,d3A3_a);
end