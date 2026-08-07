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
function Ua = U_a(equil,amplitudes)
% Computation of the internal energy

a = equil.a;
n = 500;
rho = linspace(1e-10,equil.a,n+1)';

fun = IT_rho(rho,equil)./(2.*K_rho(rho,equil,amplitudes)).*(IT_rho(rho,equil)+2.*L_rho(rho,equil,amplitudes)...
    ./dL_rho(rho,equil,amplitudes).*dIT_rho(rho,equil)) + dV_rho(rho,equil,amplitudes).*(p_rho(rho,equil)+...
    L_rho(rho,equil,amplitudes)./dL_rho(rho,equil,amplitudes).*dp_rho(rho,equil)) ;

Ua = a./n.*sum(fun(1:end));

end