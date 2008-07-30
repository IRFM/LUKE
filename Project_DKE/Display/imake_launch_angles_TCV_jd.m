function launch = imake_launch_angles_TCV_jd(angles,P0);
%
% This function creates a launch structure based on the launched angles and
% posision in TCV.
%
if nargin < 2,
    P0 = angles.P0;
end
%
id = angles.id;
P1_R = angles.P1_R;
P1_Z = angles.P1_Z;
P1_theta = angles.P1_theta;
P2_R = angles.P2_R;
P2_Z = angles.P2_Z;
P2_d = angles.P2_d;
P3_Z = angles.P3_Z;
phi = angles.phi;
theta = angles.theta;
%
P4_theta = (theta - P1_theta)/2;
%
xp2 = P2_R - P1_R;
yp2 = P2_Z - P1_Z;
%
yp4 = (yp2 - P2_d*cos(P4_theta) - tan(P4_theta)*(xp2 + P2_d*sin(P4_theta)))./...
      (1 + tan(P4_theta)*cot(P1_theta));
xp4 = - yp4*cot(P1_theta);  
%
P4_R = P1_R + xp4; 
P4_Z = P1_Z + yp4;
%
Pr4_X = P4_R;
Pr4_Y =        (P4_Z - P3_Z)*sin(phi);
Pr4_Z = P3_Z + (P4_Z - P3_Z)*cos(phi);
%
yR_L = sqrt(Pr4_X^2 + Pr4_Y^2);
yZ_L = Pr4_Z;
yphi_L = - atan(Pr4_Y./Pr4_X);
%
alpha_inv = atan(tan(theta)*sin(phi));
yalpha_L = pi + alpha_inv + yphi_L;
if yalpha_L > pi,
    yalpha_L = yalpha_L - 2*pi;
end
beta_inv = asin(sin(theta)*cos(phi));
ybeta_L = pi/2 + beta_inv;
%
launch.id = id;
launch.yR_L = yR_L;
launch.yZ_L = yZ_L;
launch.yphi_L = yphi_L;
launch.yalpha_L = yalpha_L;
launch.ybeta_L = ybeta_L;
%
if isfield(angles,'freq'),
    launch.omega_rf = angles.freq*2*pi;
end
%
launch.yP_L = P0;
%
launch.w0 = angles.w0;
launch.z_L = angles.z_L;
%