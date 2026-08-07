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
function A2 = A2_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dA2_0,d3A2_0] = amps{13:14};
[A2_a,dA2_a,d2A2_a,d3A2_a] = amps{35:38};

rho_star = equil.rho_star;

A2 = S2_like_rho(rho,rho_star,a,dA2_0,d3A2_0,A2_a,dA2_a,d2A2_a,d3A2_a);

end