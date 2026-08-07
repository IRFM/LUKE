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
function gradrho = grad_rho(rho,theta,equil,amplitudes)

rho(rho==0) = 1e-10;

gradrho = h_theta(rho,theta,equil,amplitudes) ...
    .*h_zeta(rho,theta,equil,amplitudes) ...
    ./sqrt_g(rho,theta,equil,amplitudes);


end

