function alpha = alpha_rho_theta(rho,theta,equil,amplitudes,theta_g)
% alpha = (psi,rho) = (s,theta)
% theta_g is optional : if it is already computed it can be entered as
% input to fasten the execution of the function

dthetaR = dthetaR_rho_theta(rho,theta,equil,amplitudes);
dthetaZ = dthetaZ_rho_theta(rho,theta,equil,amplitudes);
dtheta = sqrt(dthetaR.^2 + dthetaZ.^2);

% calculation of the geometrical angle
if nargin < 5
    theta_g = theta_geometrical_R_Z(R_rho_theta(rho,theta,equil,amplitudes),Z_rho_theta(rho,theta,equil,amplitudes),rho,equil,amplitudes);
end
cos_alpha = (-sin(theta_g).*dthetaR+cos(theta_g).*dthetaZ)./dtheta;
sin_alpha = (cos(theta_g).*dthetaR+sin(theta_g).*dthetaZ)./dtheta;

alpha = acos(cos_alpha).*(1-2.*(sin_alpha<0));
alpha(dtheta==0) = 0;

end

