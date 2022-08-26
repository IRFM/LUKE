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