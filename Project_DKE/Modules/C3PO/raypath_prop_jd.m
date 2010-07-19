function [sysh,sysZ,syR,syZ,syphi,syalpha,sybeta,sygR,sygZ,sygphi] = raypath_prop_jd(yR_L,yZ_L,yphi_L,yalpha_L,ybeta_L,s);
%
% This function calculates a ray trajectory in a torus assuming straight propagation along unit vector g. 
%
% INPUTS
%
%       - yR_L: launching toroidal major radius (m) [0...infty] [1,nb]
%       - yZ_L: launching vertical position (m) [-infty...infty] [1,nb]
%       - yphi_L: launching angular position (m) [-pi...pi] [1,nb]
%       - yalpha_L: launching horizontal angle (with respect to R) [-pi...pi] [1,nb]
%       - ybeta_L: launching vertical angle (with respect to Z) [0...pi] [1,nb]
%       - s: curvilinear positions along ray path (m) [1,ns]
%
% OUTPUTS
%       
%       - sysh: horizontal distance along trajectory (sh > 0) [ns,nb]
%       - sysZ: vertical distance along trajectory [ns,nb] 
%       - syR: toroidal major radius [ns,nb]
%       - syZ: vertical position [ns,nb] 
%       - syphi: toroidal angle [ns,nb]  
%       - syalpha: horizontal angle (with respect to R) [-pi...pi] [ns,nb] 
%       - sybeta: vertical angle (with respect to Z) [0...pi] [ns,nb] 
%       - sygR: component of g along R [ns,nb] 
%       - sygZ: component of g along Z [ns,nb] 
%       - sygphi: component of g along phi [ns,nb] 
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 6
    error('not enough arguments')
end
if min(yR_L) < 0
    error('R_L must be positive')
end
if min(yphi_L) <= -pi | max(yphi_L) > pi
    error('need -pi < phi_L <= pi')
end
if min(yalpha_L) <= -pi | max(yalpha_L) > pi
    error('need -pi < alpha_L <= pi')
end
if min(ybeta_L) < 0 | max(ybeta_L) > pi
    error('need 0 <= beta_L <= pi')
end    
%
ns = length(s);
nb = length(yR_L);
%
if length(yZ_L) ~= nb | length(yphi_L) ~= nb | length(yalpha_L) ~= nb | length(ybeta_L) ~= nb
    error('Launching inputs must have the same dimension')
end
%
sysZ = s'*cos(ybeta_L);
sysh = s'*sin(ybeta_L);
%
syR_L = ones(ns,1)*yR_L;
syZ_L = ones(ns,1)*yZ_L;
syphi_L = ones(ns,1)*yphi_L;
syalpha_L = ones(ns,1)*yalpha_L;
sybeta = ones(ns,1)*ybeta_L;
%
syR = sqrt(syR_L.^2 + sysh.^2 + 2*syR_L.*sysh.*cos(syalpha_L));
syZ = syZ_L + sysZ;
syphi = syphi_L + acos((syR.^2 + syR_L.^2 - sysh.^2)./(2*syR.*syR_L)).*sign(syalpha_L);
syphi = real(syphi);
%
syalpha = syalpha_L - syphi + syphi_L;
%
sygR = sin(sybeta).*cos(syalpha);
sygZ = cos(sybeta);
sygphi = sin(sybeta).*sin(syalpha);