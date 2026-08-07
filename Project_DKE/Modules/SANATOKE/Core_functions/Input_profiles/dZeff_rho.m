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
function dZeff = dZeff_rho(rho,equil)

a = equil.a;
Zeff_0 = equil.Zeff.Zeff_0;
Zeff_a = equil.Zeff.Zeff_a;
eZeff = equil.Zeff.eZeff;

dZeff = -2.*rho./a.^2.*eZeff.*(Zeff_0-Zeff_a).*(1-rho.^2./a.^2).^(eZeff-1);

end