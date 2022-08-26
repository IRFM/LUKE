function drhoR0 = drhoR0_rho(rho,equil,amplitudes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes);
a = amps{1};
[Rm,d2R0_0,d4R0_0] = amps{2:4};
[R0_a,dR0_a,d2R0_a,d3R0_a] = amps{19:22};

rho_star = equil.rho_star;

drhoR0 = drhoR0_like_rho(rho,rho_star,a,Rm,d2R0_0,d4R0_0,R0_a,dR0_a,d2R0_a,d3R0_a) ;

end
