% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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