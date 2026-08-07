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
function dp = dp_rho(rho,equil)

%dp = dp_rho_input(rho,equil);

[d2p_0, d4p_0, d6p_0, d8p_0] = pressureCoeffs(equil);
dp = d2p_0.*rho + d4p_0./6.*rho.^3 + d6p_0./120.*rho.^5 + d8p_0./5040.*rho.^7;


end