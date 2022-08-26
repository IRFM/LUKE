function drhoS2 = drhoS2_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dS2_0,d3S2_0] = amps{11:12};
[S2_a,dS2_a,d2S2_a,d3S2_a] = amps{31:34};

rho_star = equil.rho_star;

drhoS2 = drhoS2_like_rho(rho,rho_star,a,dS2_0,d3S2_0,S2_a,dS2_a,d2S2_a,d3S2_a);
end