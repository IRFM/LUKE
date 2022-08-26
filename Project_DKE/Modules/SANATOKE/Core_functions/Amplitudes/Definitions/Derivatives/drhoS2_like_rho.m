function drhoS2 = drhoS2_like_rho(rho,rho_star,a,dS2_0,d3S2_0,S2_a,dS2_a,d2S2_a,d3S2_a)
%S2_LIKE_RHO Summary of this function goes here
%   Detailed explanation goes here

rho1 = rho(rho<=rho_star);
rho2 = rho(rho>rho_star);

drhoS2_1 = dS2_0 + 1./2.*d3S2_0.*rho1.^2 ;
drhoS2_2 = dS2_a - d2S2_a.*(a-rho2) + 1./2.*d3S2_a.*(a-rho2).^2;

drhoS2 = cat(1,drhoS2_1,drhoS2_2) ;

end

