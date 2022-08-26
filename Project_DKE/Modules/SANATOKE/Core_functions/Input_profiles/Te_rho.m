function Te = Te_rho(rho,equil)
%ZEFF_RHO Summary of this function goes here
%   Detailed explanation goes here

a = equil.a;

if isfield(equil.temperature.electron,'profile')
    Te = interp1(equil.rhos,equil.temperature.electron.profile,rho,"spline","extrap");
else
    Te_0 = equil.temperature.electron.Te_0;
    Te_a = equil.temperature.electron.Te_a;
    eTe = equil.temperature.electron.eTe;

    Te = (Te_0-Te_a).*(1-rho.^2./a.^2).^eTe + Te_a;
end

end
