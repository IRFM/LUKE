function [dS2_0,d3S2_0,d2S2_a,d3S2_a] = boundaryCondition_S2_like(a,S2_a,dS2_a,rho_star)

d2S2_a = -6.*(S2_a-a.*dS2_a) ./ (3.*a.^2-rho_star.^2);

dS2_0 = (6.*S2_a - 2.*(2.*a-rho_star).*dS2_a + a.*(a-rho_star).*d2S2_a) ./ (2.*(a+rho_star));

d3S2_0 = (-6.*S2_a + 6.*a.*dS2_a - (2.*a.^2-a.*rho_star-rho_star.^2).*d2S2_a) ./ (a.*rho_star*(a+rho_star));

d3S2_a = (6.*S2_a - 6.*a.*dS2_a + (3.*a.^2-rho_star.^2).*d2S2_a) ./ (a.*(a.^2-rho_star.^2));

end