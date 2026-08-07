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
function [B_R,B_Z,B_phi] = B_RZphi_RZ(R,Z,equil,amplitudes)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if length(R)>1 || length(Z)>1
attention risque de ne pas fonctionner, car rho_R_Z(R,Z) et theta_R_Z(R,Z) donnent des matrices
Or B_RZphi_rhotheta a besoin de vecteurs rho et theta
end

[B_R,B_Z,B_phi] = B_RZphi_rhotheta(rho_R_Z(R,Z,equil,amplitudes),theta_R_Z(R,Z,equil,amplitudes),equil,amplitudes);

end

