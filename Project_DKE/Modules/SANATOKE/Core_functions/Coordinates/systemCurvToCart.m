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
function system = systemCurvToCart(curv,cart,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

curv = num2cell(curv);
[rho,theta] = curv{:};

cart = num2cell(cart);
[R,Z] = cart{:};


system(1) = R_rho_theta(rho,theta,equil,amplitudes) - R ;
system(2) = Z_rho_theta(rho,theta,equil,amplitudes) - Z ;

end

