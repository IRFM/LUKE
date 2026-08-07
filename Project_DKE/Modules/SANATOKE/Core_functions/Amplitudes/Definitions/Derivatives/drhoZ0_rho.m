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
function drhoZ0 = drhoZ0_rho(rho,equil,amplitudes)

amps = num2cell(amplitudes);
a = amps{1};
[Zm,d2Z0_0,d4Z0_0] = amps{5:7};
[Z0_a,dZ0_a,d2Z0_a,d3Z0_a] = amps{23:26};

rho_star = equil.rho_star;

drhoZ0 = drhoR0_like_rho(rho,rho_star,a,Zm,d2Z0_0,d4Z0_0,Z0_a,dZ0_a,d2Z0_a,d3Z0_a) ;

end