function S2 = S2_like_rho(rho,rho_star,a,dS2_0,d3S2_0,S2_a,dS2_a,d2S2_a,d3S2_a)
%S2_LIKE_RHO Summary of this function goes here
%   Detailed explanation goes here

rho1 = rho(rho<=rho_star);
rho2 = rho(rho>rho_star);

S2_1 = dS2_0.*rho1 + 1./6.*d3S2_0.*rho1.^3 ;
S2_2 = S2_a - dS2_a.*(a-rho2) + 1./2.*d2S2_a.*(a-rho2).^2  - 1./6.*d3S2_a.*(a-rho2).^3;

S2 = cat(1,S2_1,S2_2) ;

end

