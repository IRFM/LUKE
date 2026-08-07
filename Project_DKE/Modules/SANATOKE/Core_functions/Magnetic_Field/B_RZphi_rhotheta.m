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
function [B_R,B_Z,B_phi] = B_RZphi_rhotheta(rhos,thetas,equil,amplitudes)
%B_R_Z_PHI Summary of this function goes here
%   cf eq (45)

BP = BP_rho_theta(rhos,thetas,equil,amplitudes);
BT = BT_rho_theta(rhos,thetas,equil,amplitudes);

%{
dthetaR = dthetaR_rho_theta(rho,theta,equil,amplitudes);
dthetaZ = dthetaZ_rho_theta(rho,theta,equil,amplitudes);
dtheta = sqrt(dthetaR.^2 + dthetaZ.^2);

B_R = BP.*dthetaR./dtheta;
B_Z = BP.*dthetaZ./dtheta;
%}

R = R_rho_theta(rhos,thetas,equil,amplitudes);
Z = Z_rho_theta(rhos,thetas,equil,amplitudes);
theta_g = theta_geometrical_R_Z(R,Z,rhos,equil,amplitudes);
alpha = alpha_rho_theta(rhos,thetas,equil,amplitudes,theta_g);

B_R = -sin(theta_g-alpha).*BP;
B_Z = cos(theta_g-alpha).*BP;
B_phi = BT ;

B_R(BP==0) = 0;
B_Z(BP==0) = 0;

end