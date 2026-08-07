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
function KT = KT_rho_theta(rho,theta,equil,amplitudes)
%KT_RHO Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,~,~,mu0] = pc_dke_yp;

rho(rho==0) = 1e-10;

KT = 1./mu0.*h_theta(rho,theta,equil,amplitudes)./(2.*pi.*sqrt_g(rho,theta,equil,amplitudes)) ...
    .*IT_rho(rho,equil)./K_rho(rho,equil,amplitudes) ;

end

