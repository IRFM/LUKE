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