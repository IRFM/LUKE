function Z0 = Z0_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[Zm,d2Z0_0,d4Z0_0] = amps{5:7};
[Z0_a,dZ0_a,d2Z0_a,d3Z0_a] = amps{23:26};

rho_star = equil.rho_star;

Z0 = R0_like_rho(rho,rho_star,a,Zm,d2Z0_0,d4Z0_0,Z0_a,dZ0_a,d2Z0_a,d3Z0_a) ;

end