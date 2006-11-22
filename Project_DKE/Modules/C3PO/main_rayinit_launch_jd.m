function rayinit = main_rayinit_launch_jd(equil,launch,dNpar0,ns,method)
%
% This function creates the rayinit structure based on ray launching parameters. Straight ray
% propagation is assumed up to the last closed flux-surface.
%
% INPUTS:
%
%   -structure launch:
%       - omega_rf : wave angular frequency (rad/s)
%       - yR_L : major radius position of launching (m)
%       - yZ_L : vertical position of launching (m)
%       - yphi_L : toroidal angle position of launching (rad), (R,Z,phi) right handed
%       - yalpha_L : horizontal angle with respect to R (rad)
%       - ybeta_L : vertical angle with respect to Z (rad) 
%       - yP_L : power launched in the ray (W)
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 5,
    method = 'cubic';
end
if nargin < 4,
    ns = 1000;
end
if nargin < 3,
    dNpar0 = NaN;
end

%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
ny = length(launch.yP_L);
%
ptr = sqrt(equil.ptx.^2 + equil.pty.^2);
smax = max(max(ptr));
s = linspace(0,smax,ns);
%
% Straight ray propagation to reach first closed flux surface
%
[sysh,sysZ,syR,syZ,syphi,syalpha,sybeta,sygR,sygZ,sygphi] = raypath_prop_jd(launch.yR_L,launch.yZ_L,-launch.yphi_L,launch.yalpha_L,launch.ybeta_L,s);
% The definition of phi in raypath_prop_jd is opposite from the definition in DKE
syx = syR - equil.Rp;
syy = syZ - equil.Zp;
syphi = - syphi;
sygphi = - sygphi;
%
syr = sqrt(syx.^2 + syy.^2);
syx(syx == 0) = eps;
sytheta = atan(syy./syx) + pi*(syx < 0) + 2*pi*(syx > 0 & syy < 0);
%
% In vacuum N = g; 
%
syNx = sygR;
syNy = sygZ;
syNphi = sygphi;
%
yP0_2piRp = launch.yP_L/(2*pi*equil.Rp);
%
psi_apRp = equil.psi_apRp;
psin = psi_apRp/psi_apRp(end);
%
rayinit.omega_rf = launch.omega_rf;
%
for iy = 1:ny,    
    %
    % interpolation for r at ray poloidal locations    
    %
    pstr = interp1(equil.theta,ptr.',sytheta(:,iy),method).';%r(psi,st)
    %
    % interpolation for psi at ray position (along cst theta lines)
    %
    %spsin = interp1(pstr,ppsin,sr,method);%psi(s)
    for is = 1:ns 
        spsin(is) = interp1(pstr(:,is),psin,syr(is,iy),method,NaN);%psi(s)
    end
    %
    is0 = min(find(~isnan(spsin)));
    %
    psin0 = spsin(is0);
    %
    r0 = syr(is0,iy);
    theta0 = sytheta(is0,iy);
    phi0 = syphi(is0,iy);
    Nx0 = syNx(is0,iy);
    Ny0 = syNy(is0,iy);
    Nphi0 = syNphi(is0,iy);
    %
    rho0 = psi2rho_jd(equil,psin0);
    %
    Bx0 = interp2(psin,equil.theta,equil.ptBx.',psin0,theta0,method);
    By0 = interp2(psin,equil.theta,equil.ptBy.',psin0,theta0,method);
    BPHI0 = interp2(psin,equil.theta,equil.ptBPHI.',psin0,theta0,method);    
    %
    Npar0 = (Nx0*Bx0 + Ny0*By0 + Nphi0*BPHI0)/sqrt(Bx0.^2 + By0.^2 + BPHI0.^2);
    %
    Bp0 = sqrt(Bx0.^2 + By0.^2);
    cosalpha = (By0*syx(is0,iy) - Bx0*syy(is0,iy))/r0/Bp0;
    Ns0 = (Nx0*Bx0 + Ny0*By0)/Bp0;
    m0 = r0*Ns0*rayinit.omega_rf/clum/cosalpha;
    %
    rayinit.yrho0(iy) = rho0;%Initial radial position at launch
    rayinit.ytheta0(iy) = theta0;%Initial poloidal position at launch
    rayinit.yphi0(iy) = phi0;%Initial toroidal position at launch
    rayinit.ym0(iy) = m0;%Initial poloidal mode number
    rayinit.yNpar0(iy) = Npar0;%Initial index of refraction
    rayinit.ydNpar0(iy) = dNpar0;%initial Ray spectral width
    rayinit.yP0_2piRp(iy) = yP0_2piRp(iy);%Lineic initial power density initial power in the ray (W/m)
    %
end
%
