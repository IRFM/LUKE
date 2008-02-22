function rayinit = main_rayinit_launch_jd(equil,launch)
%
% This function creates the rayinit structure based on ray launching parameters. Straight ray
% propagation is assumed up to the last closed flux-surface.
%
% INPUTS:
%Launch structure fields:
%
%       - type = Type of wave (LH or EC;
%       - omega_rf = [4.6]*2*pi*1e9;%wave angular frequency (rad/s)
%
%Specific to LH wave
%
%       - bPlhtot: initial power in the ray (W) [1,n_lobe]
%       - bNpar0: Initial Npar value [1,n_lobe]
%       - bdNpar0: Initial dNpar value [1,n_lobe]
%       - rZ0: vertical launching positions [m_pol,1]
%
%       - m0: initial poloidal mode number
%       - n0: initial toroidal mode number
%       - phi0: toroidal angle position
%       - i_ref: Initial radial position index
%       - LFS: (-1) high field side launching, (1) low field side launching
%
%Specific to EC wave
%
%       - yR_L : major radius position of launching (m)
%       - yZ_L : vertical position of launching (m)
%       - yphi_L : toroidal angle position of launching (rad), (R,Z,phi) right handed
%       - yalpha_L : horizontal angle with respect to R (rad)
%       - ybeta_L : vertical angle with respect to Z (rad) 
%       - yP_L : power launched in the ray (W)
%       - dNpar0 :  initial power spectrum width. May be NaN
%       - ns : (1000)
%       - method: ('cubic')
%
% by J. Decker (CEA-DRFC) <joan.decker@cea.fr> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 2,
    error('Not enough input arguments in main_rayinit_launch_jd');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
if isfield(launch,'m0') == 0,launch.m0 = NaN;end
if isfield(launch,'n0') == 0,launch.n0 = NaN;end
%
if launch.type == 'EC',
   dNpar0 = launch.dNpar0;
   ns = launch.ns;
   method = launch.method;
%
%
   ny = length(launch.yP_L);
%
   ptr = sqrt(equil.ptx.^2 + equil.pty.^2);
   smax = 2*max(max(ptr));
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
      rayinit.yn0(iy) = launch.n0;%Initial toroidal mode number
      rayinit.yNpar0(iy) = Npar0;%Initial index of refraction
      rayinit.ydNpar0(iy) = dNpar0;%initial Ray spectral width
      rayinit.yP0_2piRp(iy) = yP0_2piRp(iy);%Lineic initial power density initial power in the ray (W/m)
%
   end
elseif launch.type == 'LH',
   bP0 = launch.bPlhtot;%initial power in the ray (W) [1,n_lobe]
   bNpar0 = launch.bNpar0;%Initial Npar value [1,n_lobe]
   bdNpar0 = launch.bdNpar0;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
   ry0 = launch.rZ0 - equil.Zp;
   rby0 = [ry0(:)*ones(1,length(bP0))];%[m_pol,n_lobe]
%
% Ray initial characteristics
%
   tmask = diff(equil.pty(launch.i_ref,:))*launch.LFS > 0;
%
   rbx0 = interp1(equil.pty(launch.i_ref,tmask),equil.ptx(launch.i_ref,tmask),rby0,'spline');
   rbx0(rbx0 == 0) = eps;
   rbtheta0 = atan(rby0./rbx0) + pi*(rbx0 < 0) + 2*pi*(rbx0 > 0 & rby0 < 0);
%
   rho0 = psi2rho_jd(equil,equil.psi_apRp(launch.i_ref)/equil.psi_apRp(end),'spline');%Initial radial position at launch%
%
   rayinit.omega_rf = launch.omega_rf;%wave frequency 
%
   nb = size(rby0,2);% number of beams
   nr = size(rby0,1);% number of poloidal locations
%
   bP0_2piRp = bP0/(2*pi*equil.Rp);
%
   iy = 0;
%
   for ib = 1:nb,
      for ir = 1:nr,
         iy = iy + 1;
%
         rayinit.yrho0(iy) = rho0;%Initial radial position at launch
         rayinit.ytheta0(iy) = rbtheta0(ir,ib);%Initial poloidal position at launch
         rayinit.yphi0(iy) = launch.phi0;%Initial toroidal position at launch
         rayinit.ym0(iy) = launch.m0;%Initial poloidal mode number
         rayinit.yn0(iy) = launch.n0;%Initial toroidal mode number
         rayinit.yNpar0(iy) = bNpar0(ib);%Initial index of refraction
         rayinit.ydNpar0(iy) = bdNpar0(ib);%initial Ray spectral width
         rayinit.yP0_2piRp(iy) = bP0_2piRp(ib)/nr;%Lineic initial power density initial power in the ray (W/m)
%
      end
   end
end
