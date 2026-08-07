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
function alpha = alpha_luke_rho_theta(rho,theta,equil,amplitudes)
% alpha = (psi,rho) = (s,theta)

rho(rho==0) = 1e-5;

dthetaR = dthetaR_rho_theta(rho,theta,equil,amplitudes);
dthetaZ = dthetaZ_rho_theta(rho,theta,equil,amplitudes);
dtheta = sqrt(dthetaR.^2 + dthetaZ.^2);

% calculation of the geometrical angle
theta_g = theta_geometrical_luke_R_Z(R_rho_theta(rho,theta,equil,amplitudes),Z_rho_theta(rho,theta,equil,amplitudes),amplitudes);

cos_alpha = (-sin(theta_g).*dthetaR+cos(theta_g).*dthetaZ)./dtheta;
sin_alpha = (cos(theta_g).*dthetaR+sin(theta_g).*dthetaZ)./dtheta;

alpha = acos(cos_alpha).*(1-2.*(sin_alpha<0));

end