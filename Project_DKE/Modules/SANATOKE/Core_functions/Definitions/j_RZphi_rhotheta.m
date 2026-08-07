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
function [j_R,j_Z,j_phi] = j_RZphi_rhotheta(rhos,thetas,equil,amplitudes)
%B_R_Z_PHI Summary of this function goes here
%   cf eq (45)

jp = jp_rho_theta(rhos,thetas,equil,amplitudes);
jt = jt_rho_theta(rhos,thetas,equil,amplitudes);

R = R_rho_theta(rhos,thetas,equil,amplitudes);
Z = Z_rho_theta(rhos,thetas,equil,amplitudes);
theta_g = theta_geometrical_R_Z(R,Z,rhos,equil,amplitudes);
alpha = alpha_rho_theta(rhos,thetas,equil,amplitudes,theta_g);

j_R = -sin(theta_g-alpha).*jp;
j_Z = cos(theta_g-alpha).*jp;
j_phi = jt ;

end