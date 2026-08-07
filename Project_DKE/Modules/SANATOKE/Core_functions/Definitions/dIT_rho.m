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
function dIT = dIT_rho(rho,equil)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[d2IT_0, d4IT_0, d6IT_0, d8IT_0] = ITCoeffs(equil) ;
dIT = d2IT_0.*rho + d4IT_0./6.*rho.^3 + d6IT_0./120.*rho.^5 + d8IT_0./5040.*rho.^7;


%{
dIT = dK_rho(rho,a_amplitudes).*dphi_p_rho(rho,equil,a_amplitudes) ...
    + K_rho(rho,a_amplitudes).*d2phi_p_rho(rho,equil,a_amplitudes);
%}

end
