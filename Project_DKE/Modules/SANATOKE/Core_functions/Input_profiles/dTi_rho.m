function dTi = dTi_rho(rho,equil)


a = equil.a;

if isfield(equil.temperature.ion,'profile')
    dTi = interp1(equil.rhos,equil.temperature.ion.derivative_profile,rho,"spline","extrap");
else
    Ti_0 = equil.temperature.ion.Ti_0;
    Ti_a = equil.temperature.ion.Ti_a;
    eTi = equil.temperature.ion.eTi;

    dTi = -2.*rho./a.^2.*eTi.*(Ti_0-Ti_a).*(1-rho.^2./a.^2).^(eTi-1);
end

end