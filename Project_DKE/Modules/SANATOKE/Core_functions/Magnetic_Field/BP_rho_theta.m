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
function BP = BP_rho_theta(rho,theta,equil,amplitudes)
% Poloidal magnetic field

BP = h_theta(rho,theta,equil,amplitudes).*dphi_p_rho(rho,equil,amplitudes)./ ...
    (2.*pi.*sqrt_g(rho,theta,equil,amplitudes)) ;

rho_zero = repmat(rho==0,1,length(theta));
BP(rho_zero) = 0;

end
