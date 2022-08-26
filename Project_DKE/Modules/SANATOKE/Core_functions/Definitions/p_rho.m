function p = p_rho(rho,equil)

%p = p_rho_input(rho,equil);


[d2p_0, d4p_0, d6p_0, d8p_0,p0] = pressureCoeffs(equil);

p = p0 + d2p_0./2.*rho.^2 + d4p_0./24.*rho.^4 + d6p_0./720.*rho.^6 + d8p_0./40320.*rho.^8;

end