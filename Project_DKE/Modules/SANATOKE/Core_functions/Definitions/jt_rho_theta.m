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
function jt = jt_rho_theta(rho,theta,equil,amplitudes)
%JT_RHO_THETA Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,~,~,mu0] = pc_dke_yp;

rho(rho==0) = 1e-10;

if isfield(equil.current,'jt') && isfield(equil.current.jt,'profile')
    jt = jt_rho_theta_input(rho,theta,equil);
else
    jt = mu0.*dIT_rho(rho,equil)./(2.*pi.*h_zeta(rho,theta,equil,amplitudes).*dL_rho(rho,equil,amplitudes))...
        -K_rho(rho,equil,amplitudes)./IT_rho(rho,equil).*dp_rho(rho,equil)...
        .*(2.*pi.*h_zeta(rho,theta,equil,amplitudes)-mu0.*dV_rho(rho,equil,amplitudes) ...
        ./(2.*pi.*h_zeta(rho,theta,equil,amplitudes).*dL_rho(rho,equil,amplitudes)));
end

end
