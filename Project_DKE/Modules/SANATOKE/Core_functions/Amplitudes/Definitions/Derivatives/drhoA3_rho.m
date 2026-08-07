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
function drhoA3 = drhoA3_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[dA3_0,d3A3_0] = amps{17:18};
[A3_a,dA3_a,d2A3_a,d3A3_a] = amps{43:46};

rho_star = equil.rho_star;

drhoA3 = drhoS2_like_rho(rho,rho_star,a,dA3_0,d3A3_0,A3_a,dA3_a,d2A3_a,d3A3_a);
end