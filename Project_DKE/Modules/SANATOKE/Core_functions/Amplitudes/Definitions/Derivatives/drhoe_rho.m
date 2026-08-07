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
function drhoe = drhoe_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[kappam,d2e_0,d4e_0] = amps{8:10};
[e_a,de_a,d2e_a,d3e_a] = amps{27:30};

rho_star = equil.rho_star;

drhoe = drhoR0_like_rho(rho,rho_star,a,kappam,d2e_0,d4e_0,e_a,de_a,d2e_a,d3e_a) ;

end
