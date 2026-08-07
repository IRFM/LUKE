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