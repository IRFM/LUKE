function dp = dp_rho_input(rho,equil)

qe = pc_dke_yp;

if isfield(equil.temperature.electron,'eTe') && isfield(equil.density.electron,'ene')
    [d2p_0, d4p_0, d6p_0, d8p_0] = pressureCoeffs(equil);
    dp = d2p_0.*rho + d4p_0./6.*rho.^3 + d6p_0./120.*rho.^5 + d8p_0./5040.*rho.^7;
else
    dp = 1e3.*qe.*(dne_rho(rho,equil).*Te_rho(rho,equil) + ne_rho(rho,equil).*dTe_rho(rho,equil) ...
        + sum(dni_rho(rho,equil).*Ti_rho(rho,equil) + ni_rho(rho,equil).*dTi_rho(rho,equil),2));
end

end
