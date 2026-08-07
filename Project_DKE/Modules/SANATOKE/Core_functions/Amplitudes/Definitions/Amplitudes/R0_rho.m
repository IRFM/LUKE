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
function R0 = R0_rho(rho,equil,amplitudes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes);
a = amps{1};
[Rm,d2R0_0,d4R0_0] = amps{2:4};
[R0_a,dR0_a,d2R0_a,d3R0_a] = amps{19:22};

rho_star = equil.rho_star;

R0 = R0_like_rho(rho,rho_star,a,Rm,d2R0_0,d4R0_0,R0_a,dR0_a,d2R0_a,d3R0_a) ;

end
