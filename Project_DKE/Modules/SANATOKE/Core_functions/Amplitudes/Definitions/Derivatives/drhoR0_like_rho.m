function drhoR0 = drhoR0_like_rho(rho,rho_star,a,Rm,d2R0_0,d4R0_0,R0_a,dR0_a,d2R0_a,d3R0_a)
%S2_LIKE_RHO Summary of this function goes here
%   Detailed explanation goes here

rho1 = rho(rho<=rho_star);
rho2 = rho(rho>rho_star);

drhoR0_1 = d2R0_0.*rho1 + 1./6.*d4R0_0.*rho1.^3 ;
drhoR0_2 = dR0_a - d2R0_a.*(a-rho2) + 1./2.*d3R0_a.*(a-rho2).^2;

drhoR0 = cat(1,drhoR0_1,drhoR0_2) ;

end
