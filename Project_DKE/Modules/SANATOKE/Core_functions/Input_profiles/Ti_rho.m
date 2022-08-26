function Ti = Ti_rho(rho,equil)
%ZEFF_RHO Summary of this function goes here
%   Detailed explanation goes here

a = equil.a;

if isfield(equil.temperature.ion,'profile')
    Ti = interp1(equil.rhos,equil.temperature.ion.profile,rho,"spline","extrap");
else
    Ti_0 = equil.temperature.ion.Ti_0;
    Ti_a = equil.temperature.ion.Ti_a;
    eTi = equil.temperature.ion.eTi;

    Ti = (Ti_0-Ti_a).*(1-rho.^2./a.^2).^eTi + Ti_a;
end

end
