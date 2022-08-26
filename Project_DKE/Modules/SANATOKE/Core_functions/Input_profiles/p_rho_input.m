function p = p_rho_input(rho,equil)
% p = kB * (ne*Te + sum(ni*Ti))

qe = pc_dke_yp;

if isfield(equil.temperature.electron,'eTe') && isfield(equil.density.electron,'ene')
    [d2p_0, d4p_0, d6p_0, d8p_0,p0] = pressureCoeffs(equil);
    p = p0 + d2p_0./2.*rho.^2 + d4p_0./24.*rho.^4 + d6p_0./720.*rho.^6 + d8p_0./40320.*rho.^8;
else
    p = 1e3.*qe.*(ne_rho(rho,equil).*Te_rho(rho,equil) + sum(ni_rho(rho,equil).*Ti_rho(rho,equil),2));
end

end