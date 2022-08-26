function dTe = dTe_rho(rho,equil)

a = equil.a;

if isfield(equil.temperature.electron,'profile')
    dTe = interp1(equil.rhos,equil.temperature.electron.derivative_profile,rho,"spline","extrap");
else
    Te_0 = equil.temperature.electron.Te_0;
    Te_a = equil.temperature.electron.Te_a;
    eTe = equil.temperature.electron.eTe;

    dTe = -2.*rho./a.^2.*eTe.*(Te_0-Te_a).*(1-rho.^2./a.^2).^(eTe-1);
end

end