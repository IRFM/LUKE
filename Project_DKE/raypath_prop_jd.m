function [s,sh,sZ,R,Z,phi,alpha,beta,gR,gZ,gphi] = raypath_prop_jd(R_L,Z_L,alpha_L,beta_L,ds,smax);
%
% This function calculates a ray trajectory in a torus assuming straight propagation along unit vector g. 
%
% INPUTS
%
%       - R_L: launching toroidal major radius (m) [0...infty]
%       - Z_L: launching vertical position (m) [-infty...infty]
%       - alpha_L: launching horizontal angle (with respect to R) [-pi...pi]
%       - beta_L: launching vertical angle (with respect to Z) [0...pi]
%       - ds: increment along ray path (m)
%       - smax: length of calculated ray path (m)
%
% OUTPUTS
%       
%       - s: distance along trajectory (s > 0)
%       - sh: horizontal distance along trajectory (sh > 0)
%       - sZ: vertical distance along trajectory 
%       - R: toroidal major radius 
%       - Z: vertical position
%       - phi: toroidal angle 
%       - alpha: horizontal angle (with respect to R) [-pi...pi]
%       - beta: vertical angle (with respect to Z) [0...pi]
%       - gR: component of g along R
%       - gZ: component of g along Z
%       - gphi: component of g along phi
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 6
    error('not enough arguments')
end
if R_L < 0
    error('R_L must be positive')
end
if ds < 0
    error('ds must be positive')
end
if smax < ds
    error('smax must be larger than ds')
end
if alpha_L <= -pi | alpha_L > pi
    error('need -pi < alpha_L <= pi')
end
if beta_L < 0 | beta_L > pi
    error('need 0 <= alpha_L <= pi')
end    
%
s = 0:ds:smax;
ns = length(s);
%
sZ = s*cos(beta_L);
sh = s*sin(beta_L);
%
R = sqrt(R_L^2 + sh.^2 + 2*R_L*sh*cos(alpha_L));
Z = Z_L + sZ;
phi = acos((R.^2 + R_L^2 - sh.^2)./(2*R*R_L)).*sign(alpha_L);
%
alpha = alpha_L - phi;
beta = repmat(beta_L,[1,ns]);
%
gR = sin(beta).*cos(alpha);
gZ = cos(beta);
gphi = sin(beta).*sin(alpha);