function drhoe = drhoe_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[kappam,d2e_0,d4e_0] = amps{8:10};
[e_a,de_a,d2e_a,d3e_a] = amps{27:30};

rho_star = equil.rho_star;

drhoe = drhoR0_like_rho(rho,rho_star,a,kappam,d2e_0,d4e_0,e_a,de_a,d2e_a,d3e_a) ;

end
