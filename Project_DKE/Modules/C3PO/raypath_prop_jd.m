function [sysh,sysy,syx,syy,syz,syalpha,sybeta,sygx,sygy,sygz] = raypath_prop_jd(Rp,yx_L,yy_L,yz_L,yalpha_L,ybeta_L,s)
%
% This function calculates a ray trajectory in a torus assuming straight propagation along unit vector g. 
%
% INPUTS
%
%       - Rp: Plasma major radius (m) [1,1]
%       - yx_L: launching toroidal major radius (m) [0...infty] [1,nb]
%       - yy_L: launching vertical position (m) [-infty...infty] [1,nb]
%       - yz_L: launching axial position (m) [-pi...pi] [1,nb]
%       - yalpha_L: launching horizontal angle (with respect to x) [-pi...pi] [1,nb]
%       - ybeta_L: launching vertical angle (with respect to y) [0...pi] [1,nb]
%       - s: curvilinear positions along ray path (m) [1,ns]
%
% OUTPUTS
%       
%       - sysh: horizontal distance along trajectory (sh > 0) [ns,nb]
%       - sysy: vertical distance along trajectory [ns,nb] 
%       - syx: toroidal major radius [ns,nb]
%       - syy: vertical position [ns,nb] 
%       - syz: axial position [ns,nb]  
%       - syalpha: horizontal angle (with respect to R) [-pi...pi] [ns,nb] 
%       - sybeta: vertical angle (with respect to Z) [0...pi] [ns,nb] 
%       - sygx: component of g along x [ns,nb] 
%       - sygy: component of g along y [ns,nb] 
%       - sygz: component of g along z [ns,nb] 
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 7
    error('not enough arguments')
end
if min(yx_L) < 0
    error('x_L must be positive')
end
if min(yalpha_L) <= -pi || max(yalpha_L) > pi
    error('need -pi < alpha_L <= pi')
end
if min(ybeta_L) < 0 || max(ybeta_L) > pi
    error('need 0 <= beta_L <= pi')
end    
%
ns = length(s);
nb = max([length(yx_L),length(yy_L),length(yz_L),length(yalpha_L),length(ybeta_L)]);
%
if ~any(length(yx_L) == [1,nb]) || ~any(length(yy_L) == [1,nb]) || ~any(length(yz_L) == [1,nb]) || ~any(length(yalpha_L) == [1,nb]) || ~any(length(ybeta_L) == [1,nb])
    error('Launching inputs must have the same dimension')
end
%
yx_L = repmat(yx_L,[1,nb/length(yx_L)]);
yy_L = repmat(yy_L,[1,nb/length(yy_L)]);
yz_L = repmat(yz_L,[1,nb/length(yz_L)]);
yalpha_L = repmat(yalpha_L,[1,nb/length(yalpha_L)]);
ybeta_L = repmat(ybeta_L,[1,nb/length(ybeta_L)]);
%
sysy = s'*cos(ybeta_L);
sysh = s'*sin(ybeta_L);
%
syx_L = ones(ns,1)*yx_L;
syy_L = ones(ns,1)*yy_L;
syz_L = ones(ns,1)*yz_L;
syalpha_L = ones(ns,1)*yalpha_L;
sybeta = ones(ns,1)*ybeta_L;
%
syy = syy_L + sysy;
%
if isinf(Rp),
    syx = syx_L + sysh.*cos(syalpha_L);
    syz = syz_L + sysh.*sin(syalpha_L);
    syalpha = syalpha_L; 
else
    syR_L = syx_L + Rp;
    syR = sqrt(syR_L.^2 + sysh.^2 + 2*syR_L.*sysh.*cos(syalpha_L));
    syx = syR - Rp;
    %
    syphi = acos((syR.^2 + syR_L.^2 - sysh.^2)./(2*syR.*syR_L)).*sign(syalpha_L);
    syphi = real(syphi);
    %
    syz = Rp*syphi + syz_L;
    %
    syalpha = syalpha_L - syphi + syz_L/Rp;
end
%
sygx = sin(sybeta).*cos(syalpha);
sygy = cos(sybeta);
sygz = sin(sybeta).*sin(syalpha);