function dp = dp_rho(rho,equil)

%dp = dp_rho_input(rho,equil);

[d2p_0, d4p_0, d6p_0, d8p_0] = pressureCoeffs(equil);
dp = d2p_0.*rho + d4p_0./6.*rho.^3 + d6p_0./120.*rho.^5 + d8p_0./5040.*rho.^7;


end