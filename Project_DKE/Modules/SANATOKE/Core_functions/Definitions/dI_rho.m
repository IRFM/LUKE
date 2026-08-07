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
function dI = dI_rho(rho,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


rhos = (0:equil.a/200:equil.a)';
I_rhos = I_rho(rhos,equil,amplitudes);
dI_rhos = gradient(I_rhos,rhos);
dI = interp1(rhos,dI_rhos,rho,"spline","extrap");

end