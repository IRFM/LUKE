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
function BT = BT_rho_theta(rho,theta,equil,amplitudes)
% Toroidal magnetic field

[~,~,~,~,~,mu0] = pc_dke_yp;

rho(rho==0) = amplitudes(1)/1e8;

BT = mu0.*I_rho(rho,equil,amplitudes) ./ (2.*pi.*h_zeta(rho,theta,equil,amplitudes)) ;
end
