function [XXheaviside,...
    XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,...
    XXDrf_ij,XXDrf_tp_ij,XXFrf_tp_ij,...
    Znorm,Znorm_fsav,...
    Zcurr,Zcurr_fsav,...
    ZP0_fsav,...
    ZSp0,...
    XxRR_fsav,xMRR_flux_ref,xMRR_tau_ref,...
    xTe_out_norm,xft_fsav,xfteff_fsav,xmhubounce2,xepsi_rdke,...
    memoryLU_f,memoryLU_g] = ... 
dke_1_4yp(it_rf,tokname,theta,...
    XR,XZ,XBR,XBZ,XBphi,...
    xB0,xR0,xBT0,xBp0,Rp,Zp,ap,...
    mhu,dmhu,mhum,dmhum,mhup,dmhup,mhu_S,...
    xmhubounce2,xrho,xpsin,xdpsin,xpsinm,xdpsinm,xpsinp,xdpsinp,rdke,xpsin_S,...
    pn,dpn,pnm,dpnm,pnp,dpnp,pn_S,spfac,...
    xTe_norm,xne_norm,zZi,zmi,xzni_norm,xzTi_norm,...
    betath_ref,xepsi_fsav,waveparam,nmax_rf,...
    XXDr,XXVr,...
    XXnhuloss,delta,...
    xftp_norm,bounce,Dqlmax,coll_mode,...
    norm_mode,boundary_mode,dtn,prec0,nit,invproc,param_inv,display,store_mode,temppath,snumber,XXfinit)
%
%
%   Self-consistent 3-D relativistic solver of the drift kinetic equation in momentum space with Beliaev-Budker collision integrals 
%   Includes toroidal magnetic losses for the Fokker-Planck equation only for circular plasma cross-section (TS)
%   Fully implicit or Crank-Nicholson time differencing schemes
%   LH and EC wave quasilinear diffusion calculations + ohmic electric field 
%   IMPORTANT: All input quantities are defined on the distribution function grid: half grid
%
%   Version 4: non-uniform momentum and pitch-angle grids + fully implicit 3D calculations
%
%   See references: 
%
%       - C. Karney, Comput. Phys. Rep. 4 (1986) 183.
%       - B. Braams, C. Karney, Phys.fluids B1 (1989) 1355
%       - M. Shoucri and I. Shkarofsky, Comp. Phys. Comm. 82 (1994) 287
%       - I. Shkarofsky and M. Shoucri, Nuclear Fusion, 37 (1997) 539
%       - J.P.S. Bizarro and P. Rodrigues, Nuclear Fusion, 37 (1997) 1509
%       - Y. Peysson and M. Shoucri, Comp. Phys. Comm. 109 (1998) 55
%       - S.D. Schultz, A. Bers and A.B. Rahm, AIP Proc. of the 12th Conf. Radio Frequency Power in Plasmas, Savannah (USA), 403 1997,327
%       - M. Ju et al., Phys. Plasmas, 9 (2002) 493
%
%   (see test_dke_1yp.m)
%
%   Input:
%
%       - betath: Normalized reference thermal velocity (vth/c) [1,1]
%       - Rp_norm: Normalized plasma major radius (ap) [1,1]
%       - xTe_norm: normalized electron temperature (Te/Te_ref) [1,nr]
%       - xne_norm: normalized electron density (ne/ne_ref) [1,nr]
%       - Zi: ion charges [1,m]
%       - mi: ion masses (u.m.a.) [1,m]
%       - xni_norm: normalized ion density (ni/ne_ref) [m,nr]
%       - pn: normalized electron momentum space grid (pth_ref) [1,np]
%       - mhu: cos(theta) angular grid [1,nmhu]
%       - XXDlh: LH normalized quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2) [np,nmhu,nr]
%       - XXDcy: EC normalized quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2) [np,nmhu,nr]
%       - param_cy: *******************normalized EC frequency [1,nr]
%       - XXnhuloss: normalized loss frequency (nhuth_ref) [np,nmhu,nr]
%       - xepsi_fsav: flux surface averaged normalized ohmic electric field (pth_ref*nhuth_ref/e) [1,nr]
%       - rdke: list of radial positions indexes at which FP or DKE are solved [1,nr_dke].  
%		- bounce: First argument: bounce averaged option, (0) no trapping, (1) trapping full implicit calculations, second argument: Fokker-Planck (0) or Drift Kinetic Equation (1 or 2) [1,2]
%       - ia: inverse aspect ratio [1,nr]
%       - xftp_norm: normalization factor for the drift kinetic equation [1,nr]
%       - XXDr: Fast electron radial diffusion (nhuth_ref*ap^2) [np,nmhu,nr]
%       - XXVr: Fast electron radial pinch (nhuth_ref*ap) [np,nmhu,nr]
%       - delta: Toroidal magnetic ripple depth [1,nr]
%       - Nq: Number of toroidal magnetic coils * local safety factor [1,nr]
%       - coll_mode: 0 -> Maxwellian relativistic collision operator, 1 -> High-velocity limit  [1,1], 2 -> linearizeded Belaiev-Budker , 3 -> Non relativistic Lorentz model
%           (default = 2)
%       - dtn: normalized integration time step (dtn > 0: fully implicit time differencing scheme, dtn < 0: Crank-Nicholson time differencing scheme) (1/nhu_th) [1,1]
%           (default = 1000)
%       - prec0: required accuracy on the residu for f and for g (%) [1,2]
%           (default = [1e-10,1e-10])
%       - nit: maximum number of iterations  for f and g [1,2]
%           (default = [20,20])
%       - invproc: matrix inversion procedure (1: LU decomposition, 2-4: Iterative method) [1,1]
%           (default = 1)
%       - param_inv: parameter for the matrix inversion procedure [1,2]
%           (default = [1e-3,20])
%       - display: display mode parameter (full: 2, partial: 1, no: = 0) index of the radial position where results are displayed
%           (default = [0,1])
%       - store_mode: Temporary storing option for sparse matrices calculations (in RAM: 0, in disk file 1)
%           (default = 0)
%       - XXfinit: initial guess for the 2D electron momentum distribution function [np,nmhu,nr]
%           (default = Maxwellian)
%
%   Output:
%       - XXf0: 2D electron momentum distribution function normalized to the normalized density [np,nmhu,nr]
%       - XXf0_tp: First neoclassical correction (f_tp) [np,nmhu,nr]
%       - XXf0_g: Second neoclassical correction (g) [np,nmhu,nr]
%       - XXSp0: p-component of the 2D electron momentum flux for f0 [np,nmhu,nr]
%       - XXSmhu0: mhu-component of the 2D electron momentum flux for f0 [np,nmhu,nr]
%       - XXSp0_g: p-component of the 2D electron momentum flux for g [np,nmhu,nr]
%       - XXSmhu0_g: mhu-component of the 2D electron momentum flux for g [np,nmhu,nr]
%       - XXSp0_tp: p-component of the 2D electron momentum flux for ftp [np,nmhu,nr]
%       - XXSmhu0_tp: mhu-component of the 2D electron momentum flux for ftp [np,nmhu,nr]
%       - Pcoll_tot: Power loss on collisions (me*ne*nhuth*vth^2) [1,nr]
%       - Pcoll_tot_fsav: FS averaged power loss on collisions from f0+g+f_tp(me*ne*nhuth*vth^2) [1,nr]
%       - Pabs0_fsav: FS averaged  RF absorbed power from f0(me*ne*nhuth*vth^2) [1,nr]
%       - Pabs_tot_fsav: FS averaged  RF absorbed power from f0+g+f_tp(me*ne*nhuth*vth^2) [1,nr]
%       - curr_0: RF + ohmic current density [1,nr]
%       - curr_tot: Total current density (RF + ohmic + boostrap current) [1,nr]
%       - curr_0_fsav:  FS averaged  RF + ohmic current density [1,nr]
%       - curr_tot_fsav:  FS averaged  Total current density (RF + ohmic + boostrap current) [1,nr]
%       - currB: Bulk current (RF + ohmic + boostrap - runway current) [1,nr]
%       - RR: Runaway rate through the surface of a sphere of radius p [nr,np]
%       - xepsi: normalized ohmic electric field at Bmin (pth_ref*nhuth_ref/e) [1,nr]
%	- trapped_fraction: exact fraction of trapped electrons ft [1,nr]
%       - Ten_out: New temperature of the bulk (mec2) [1,nr]
%       - normf_tot_fsav: Flux surface averaged norm of the distribution function [1,nr]
%       - curr0_fsav: Flux surface averaged RF + ohmic current density [1,nr]
%       - curr_tot_fsav: Total flux surface averaged current density (RF + ohmic + boostrap current)
%       - Xpn: Momentum grid normalized to the reference momentum value [np,nmhu]
%       - Xmhu: Angular grid [np,nmhu]
%       - mhubounce2: Square of the bounce averaged cosine angle [1,1]
%       - memoryLU: memory size of the L+U matrices for f0 in MBytes[1,1]
%  
%   Warning: none
%
%
%Fokker-Planck part originally done by Y. Peysson 
%Drift kinetic calculations for arbitrary magnetic equilibrium done by J. Decker (MIT-RLE) <jodecker@mit.edu> and Y. Peysson (CEA-DRFC) <yves.peysson@cea.fr>
%
if nargin < 57,
	error('Wrong number of input arguments in dke_1_4yp')
elseif nargin == 57,
   Dqlmax = 1;
	coll_mode = 2;
	norm_mode = 0;
	boundary_mode = [1,1];
	dtn = 1000;
	prec0 = [1e-10,1e-10];
	nit = [50,200];
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 58,
	norm_mode = 0;
	boundary_mode = [1,1];
	dtn = 1000;
	prec0 = [1e-10,1e-10];
	nit = [50,200];
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 59,
	boundary_mode = [1,1];
	prec0 = [1e-10,1e-10];
	nit = [50,200];
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 60,
	dtn = 1000;
	prec0 = [1e-10,1e-10];
	nit = [50,200];
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 61,
	prec0 = [1e-10,1e-10];
	nit = [50,200];
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 62,
	nit = [50,200];
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 63,
	invproc = 1;
	param_inv = [1e-3,20];
	display = [0,1,1];
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 64,
	param_inv = [1e-3,20];	
	display = [0,1,1];
	store_mode = 0;
	snumber = 1;
elseif nargin == 65,
	display = [0,1,1];	
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 66,	
	store_mode = 0;
	temppath = '';
	snumber = 1;
elseif nargin == 67,	
   temppath = '';
	snumber = 1;
elseif nargin == 68,	
	snumber = 1;
end
%
narginmax = 68;
%
timeCPU0 = cputime;
%
if it_rf == 1,
%
%************************************************** Set grid and various parameters ******************************************************** 
%
me = 1/1860;%Electron mass (u.m.a.)
%
time00 = clock;%For overall matrix calculation
time0 = clock;
%
if dtn > 0,
	time_scheme = 1;%Implicit differencing scheme
elseif dtn < 0,
	dtn  = abs(dtn);
	time_scheme = 2;%Crank-Nicholson differencing scheme
end 
%
spparms('default');%Set parameters for sparse matrix ordering algorithms and direct linear equation solver
spparms('supernd',4);
spparms('rreduce',4);
%
npn = length(pn);%Size of the momentum grid for the distribution function (half grid)
nmhu = length(mhu);%Size of the pitch-angle grid for the distribution function (half grid)
nr = length(xpsin);%Size of the radial grid for the distribution function (half grid)
nr_dke = length(rdke);%Size of the effective radial grid for the drift kinetic equation (nr_dke = nr for FPE equation only)
%
prec0_f = prec0(1);
prec0_g = prec0(2);
boundary_mode_f = boundary_mode(1);
boundary_mode_g = boundary_mode(2);
display_mode = display(1);
ir_display = display(2);
time_pause = display(3);%Pause delay for figure display (s)
nit_f = nit(1);
nit_g = nit(2);
bounce_mode = bounce(1);
dke_mode = bounce(2);
equil_mode = bounce(3);
prec_inv = param_inv(1);
prec_inv_recommanded = min([param_inv(1),1/nr/dtn]);
maxit_inv = param_inv(2);
xbetath = betath_ref*sqrt(xTe_norm);
%
if bounce_mode == 0,dke_mode = 0;end
if dke_mode == 1,bounce_mode = 1;end
%
testDrVr = sum(sum(sum(abs(XXDr)))) + sum(sum(sum(abs(XXVr))));
if length(rdke) >= 4 & testDrVr > 0,
	radial_mode = 1;
elseif length(rdke) < 4 & testDrVr > 0,
	radial_mode = -1;
elseif testDrVr == 0,
	radial_mode = 0;
end 
%
%************************************************** Simulation parameter display ******************************************************** 
%
if display_mode >=1,
	disp('Kinetic calculation parameters: ');
%Numerical transient operation
	if (store_mode == 0), disp('   - Matrices storage in RAM (fast mode)');
	else                  disp('   - Matrices storage in disk file (slow mode)');end
%Numerical matrix inversion procedure
	if (invproc == 1),  disp('   - CGS iterative matrix inversion method');
	elseif (invproc == 2),  disp('   - BICG iterative matrix inversion method');
	elseif (invproc == 3),  disp('   - QMR iterative matrix inversion method');end
	disp(['   - Recommended drop tolerance: ',num2str(prec_inv_recommanded),' [input: ',num2str(param_inv(1)),']']);
	disp(['   - Maximum number of iterations for the matrix inversion method: ',num2str(maxit_inv)]);	
%Boundary and normalization conditions
	if (norm_mode == 1),    disp('   - Normalization of f0 at each iteration and radius');
	elseif (norm_mode == 0),disp('   - No normalization of f0 at each iteration and radius: fully natural conservative mode');end
	if (boundary_mode_f >= 1),    disp(['   - Maxwellian distribution for FPE enforced on ',int2str(boundary_mode_f),' momentum grid point around p = 0']);
	elseif (boundary_mode_f == 0),disp('   - No Maxwellian distribution for FPE enforced around p = 0');end
	if (boundary_mode_g >= 1) & (dke_mode == 1),    disp(['   - Lorentz model distribution for DKE enforced on ',int2str(boundary_mode_g),' momentum grid point around p = 0']);
	elseif (boundary_mode_g == 0) & (dke_mode == 1),disp('   - No Lorentz model distribution for DKE enforced around p = 0');end
%Time scheme
	if (time_scheme == 1),    disp(['   - Implicit time differencing scheme']);
	elseif (time_scheme == 2),disp(['   - Crank-Nicholson time differencing scheme']);end
	disp(['   - Normalized time step: ',int2str(dtn)]);
%Momentum dynamics
	if (coll_mode == 0),     disp(['   - Relativistic Maxwellian background']);
	elseif (coll_mode == 1), disp(['   - High velocity limit']);	
	elseif (coll_mode == 2), disp(['   - Linearized relativistic Belaiev-Budker']);
	elseif (coll_mode == 3), disp(['   - Non-relativistic Lorentz model']);
	elseif (coll_mode == 4), disp(['   - Non-relativistic Maxwellian background']);end
	if (bounce_mode == 0),      disp(['   - No bounce averaging']);
	elseif (bounce_mode == 1),  disp(['   - Bounce averaging + implicit symmetrization in the bounce domain (15 diagonals operator) for f0']);end
	if (dke_mode == 0),       disp(['   - Resolution of the electron Fokker-Planck Equation']);
	elseif (dke_mode == 1),   disp(['   - Resolution of the electron Drift Kinetic Equation']);end
%Spatial dynamics
	if (radial_mode == 1),      disp(['   - Fast electron radial diffusion or pinch']);
	elseif (radial_mode == -1), disp(['   - No fast electron radial diffusion or pinch: radial grid too coarse !']);
	elseif (radial_mode == 0),  disp(['   - No fast electron radial diffusion or pinch']);end
%
	disp(['   - Momentum grid: ',int2str(npn)]);
	disp(['   - Angular grid: ',int2str(nmhu)]);
	disp(['   - Total radial grid: ',int2str(nr)]);
	disp(['   - Effective radial grid: ',int2str(nr_dke)]);
	disp('-------------------------------------------------------------------------------------------------------------------');
end
%
%Masks for collision integrals
%
masku = triu(ones(npn,npn)) - 0.5*diag(ones(1,npn));
maskl = tril(ones(npn,npn)) - 0.5*diag(ones(1,npn));
%
%Angular grid
%
mhu2 = mhu.*mhu;
Xmhu = ones(npn,1)*mhu;
XXmhu = repmat(Xmhu,[1,1,nr]);
Xmhu2 = ones(npn,1)*mhu2;
XXmhu2 = repmat(Xmhu2,[1,1,nr]);
X1mmhu2 = 1 - Xmhu2;
XX1mmhu2 = repmat(X1mmhu2,[1,1,nr]);
Xdmhu = ones(npn,1)*dmhu;
XXdmhu = repmat(Xdmhu,[1,1,nr]);
Xmhum = ones(npn,1)*mhum;
Xmhum(find(Xmhum==0)) = eps;
XXmhum = repmat(Xmhum,[1,1,nr]);
Xmhumm = ones(npn,1)*[mhu(1),mhu(1:nmhu-1)];
Xmhu2m = Xmhum.*Xmhum;
XXmhu2m = repmat(Xmhu2m,[1,1,nr]);
X1mmhu2m = 1 - Xmhu2m;
X1mmhu2m(find(X1mmhu2m==0)) = eps;
XX1mmhu2m = repmat(X1mmhu2m,[1,1,nr]);
Xdmhum = ones(npn,1)*dmhum;
XXdmhum = repmat(Xdmhum,[1,1,nr]);
Xdmhumm = ones(npn,1)*[dmhu(1),dmhu(1:nmhu-1)];
Xmhup = ones(npn,1)*mhup;
Xmhup(find(Xmhup==0)) = eps;
XXmhup = repmat(Xmhup,[1,1,nr]);
Xmhupp= ones(npn,1)*[mhu(2:nmhu),mhu(nmhu)];
Xmhu2p = Xmhup.*Xmhup;
XXmhu2p = repmat(Xmhu2p,[1,1,nr]);
X1mmhu2p = 1 - Xmhu2p;
X1mmhu2p(find(X1mmhu2p==0)) = eps;
XX1mmhu2p = repmat(X1mmhu2p,[1,1,nr]);
Xdmhup = ones(npn,1)*dmhup;
XXdmhup = repmat(Xdmhup,[1,1,nr]);
Xdmhupp= ones(npn,1)*[dmhu(2:nmhu),dmhu(nmhu)];
%
%Momentum grid
%
pth = betath_ref;
ip_th_ref = min(find(pn >= 1));
Xdpn = dpn'*ones(1,nmhu);
pn2 = pn.*pn;
pn3 = pn2.*pn;
xpn = pn'*ones(1,npn);
xpn2 = xpn.*xpn;
xpn3 = xpn2.*xpn;
Xpn = pn'*ones(1,nmhu);
Xdpn = dpn'*ones(1,nmhu);
Xpn2 = Xpn.*Xpn;
Xpn3 = Xpn2.*Xpn;
Xdpnm = dpnm'*ones(1,nmhu);
XXdpnm = repmat(Xdpnm,[1,1,nr]);
pn2m = pnm.*pnm;
Xpnm = pnm'*ones(1,nmhu);
XXpnm = repmat(Xpnm,[1,1,nr]);
Xpn2m = Xpnm.*Xpnm;
XXpn2m = XXpnm.*XXpnm;
Xdpnp	= dpnp'*ones(1,nmhu);
XXdpnp = repmat(Xdpnp,[1,1,nr]);
pn2p = pnp.*pnp;  
Xpnp = pnp'*ones(1,nmhu);
XXpnp = repmat(Xpnp,[1,1,nr]);
Xpn2p = Xpnp.*Xpnp;
XXpn2p = XXpnp.*XXpnp;
pnmm = [eps,pn(1:npn-1)];
Xpnmm = pnmm'*ones(1,nmhu);
Xdpnmm	= [dpn(1),dpn(1:npn-1)]'*ones(1,nmhu);
pnpp = [pn(2:npn),pn(npn)];
Xpnpp = pnpp'*ones(1,nmhu);
Xdpnpp	= [dpn(2:npn),dpn(npn)]'*ones(1,nmhu);
XXpn = repmat(Xpn,[1,1,nr]);
XXpn2 = repmat(Xpn2,[1,1,nr]);
%   
z = betath_ref*pn;
z2 = z.*z;
z3 = z2.*z;
zm = betath_ref*pnm;
z2m = zm.*zm;
zp = betath_ref*pnp;
z2p = zp.*zp;
xz = z'*ones(1,length(z));
xz2 = xz.*xz;
xz3 = xz2.*xz;
%
gamma = sqrt(1 + z2);
gamma2 = gamma.*gamma;
gammam = sqrt(1 + z2m);
gamma2m = gammam.*gammam;
gammap = sqrt(1 + z2p);
gamma2p = gammap.*gammap;
xgamma = gamma'*ones(1,length(gamma));
xgamma2 = xgamma.*xgamma;
Xgamma = gamma'*ones(1,nmhu);
XXgamma = repmat(Xgamma,[1,1,nr]);
Xgammam = gammam'*ones(1,nmhu);
XXgammam = repmat(Xgammam,[1,1,nr]);
Xgammap = gammap'*ones(1,nmhu);
XXgammap = repmat(Xgammap,[1,1,nr]);
%
gammamm = [1,gamma(1:npn-1)];
gammapp = [gamma(2:npn),gamma(npn)];
Xgammamm = gammamm'*ones(1,nmhu);
Xgammapp = gammapp'*ones(1,nmhu);
%
sigma = asinh(z);
sigmam = asinh(zm);
sigmap = asinh(zp);
xsigma = sigma'*ones(1,length(sigma));
%
J1 = -3*gamma + sigma.*(3.0./z + 2*z);
J2 = gamma - sigma./z -2*gamma.*z2/3;
J3 = -3*gamma.*sigma./z2 + 3.0./z + z - 2*z2.*z/5;
J4 = gamma.*sigma.*(15.0./z2 + 6) - 15.0./z - 11*z;
xJ1 = -3*xgamma + xsigma.*(3.0./xz + 2*xz);
xJ2 = xgamma - xsigma./xz - 2*xgamma.*xz2/3;
xJ3 = -3*xgamma.*xsigma./xz2 + 3.0./xz + xz - 2*xz2.*xz/5;
xJ4 = xgamma.*xsigma.*(15.0./xz2 + 6) - 15.0./xz - 11*xz;
%
v = pn./gamma;
v2 = v.*v;
vm = pnm./gammam;
v2m = vm.*vm;
vp = pnp./gammap;
v2p = vp.*vp;
xv = v'*ones(1,length(v));
xv2 = xv.*xv;
%
%Super momentum grid definitions for collision integrals
%
spnm = linspace(pn(1)/spfac,pnm(2),spfac);%In order to start from a point not to close to zero
for ip=3:npn,
	spnm = [spnm(1:length(spnm)-1),linspace(pnm(ip-1),pnm(ip),spfac)];	
end
%
spn = linspace(pn(1)/spfac,pn(1),spfac);
spnp = linspace(pn(1)/spfac,pnp(1),spfac);
for ip=2:npn,
	spn = [spn(1:length(spn)-1),linspace(pn(ip-1),pn(ip),spfac)];	
	spnp = [spnp(1:length(spnp)-1),linspace(pnp(ip-1),pnp(ip),spfac)];	
end
%
spnm = spnm(:);%for numerical integration by trapz_dke_yp subroutine
spn = spn(:);%for numerical integration by trapz_dke_yp subroutine
spnp = spnp(:);%for numerical integration by trapz_dke_yp subroutine
%
spn2m = spnm.*spnm;
spn2 = spn.*spn;
spn2p = spnp.*spnp;
spn3 = spn2.*spn;
%
szm = betath_ref*spnm;
sz = betath_ref*spn;
szp = betath_ref*spnp;
sz2m = szm.*szm;
sz2 = sz.*sz;
sz2p = szp.*szp;
%
sgammam = sqrt(1 + sz2m);
sgamma = sqrt(1 + sz2);
sgammap = sqrt(1 + sz2p);
sgamma2 = sgamma.*sgamma;
%
ssigmam = asinh(szm);
ssigma = asinh(sz);
ssigmap = asinh(szp);
%
svm = spnm./sgammam;
sv = spn./sgamma;
svp = spnp./sgammap;
sv2 = sv.*sv;
%
sJ1 = -3*sgamma + ssigma.*(3.0./sz + 2*sz);
sJ2 = sgamma - ssigma./sz - 2*sgamma.*sz2/3;
%
%Radial grid
%
if radial_mode == 1,
	xdpsinmm = [0,xdpsin(1:nr-1)];
	xdpsinpp = [xdpsin(2:nr),0];
%
	XXpsin = reshape(repmat(xpsin,[npn*nmhu,1]),[npn,nmhu,nr]);
	XXdpsin = reshape(repmat(xdpsin,[npn*nmhu,1]),[npn,nmhu,nr]);	
	XXpsinm = reshape(repmat(xpsinm,[npn*nmhu,1]),[npn,nmhu,nr]);	
	XXdpsinm = reshape(repmat(xdpsinm,[npn*nmhu,1]),[npn,nmhu,nr]);	
	XXpsinp = reshape(repmat(xpsinp,[npn*nmhu,1]),[npn,nmhu,nr]);	
	XXdpsinp = reshape(repmat(xdpsinp,[npn*nmhu,1]),[npn,nmhu,nr]);	
	XXdpsinmm = reshape(repmat(xdpsinmm,[npn*nmhu,1]),[npn,nmhu,nr]);	
	XXdpsinpp = reshape(repmat(xdpsinpp,[npn*nmhu,1]),[npn,nmhu,nr]);
end
%
%Bounce average coefficients
%
time0 = clock;
%
[xq,xqtilde,xqbar,xqhat,...
   XXheaviside,XXheaviside_p,XXheaviside_m,...
   Xxlambda,Xxlambda_p,Xxlambda_m,...
   XXlambda,XXRlambda_m,XXRlambda_p,...
   XXlambda_p2m1,XXRlambda_p2m1_m,XXRlambda_p2m1_p,...
   XXlambda_p2m2p2,...
   XXRlambda_b_p1p1,...
   XXlambda_b_p1m1p2,XXRlambda_b_p1m1p2,XXRlambda_b_p1m1p2_m,XXRlambda_b_p1m1p2_p,...
   XXlambda_b_p1m1,XXRlambda_b_p1m1,XXRlambda_b_p1m1_m,XXRlambda_b_p1m1_p,...
   XXRlambda_b_p1m2_m,XXRlambda_b_p1m2_p,...
   XXlambda_b_p2m2p2,XXRlambda_b_p2m2p2,XXRlambda_b_p2m2p2_m,XXRlambda_b_p2m2p2_p,...
   XXlambda_b_p3m2,XXRlambda_b_p3m2_m,XXRlambda_b_p3m2_p,...
   XXlambda_b_p2,...
   XXlambda_b_p1m3p4]...
=  bounceparam_dke_yp(bounce_mode,equil_mode,...
   mhu,mhum,mhup,Xmhu,Xmhum,Xmhup,...
   XR,XZ,XBR,XBZ,XBphi,...
   xmhubounce2,xB0,xR0,xBT0,xBp0,Rp,Zp,ap);
%
if display_mode >= 1,info_dke_yp(2,['Bounce integrals calculations done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
%
%Super matrices size definition and masks calculations for trapped electrons in the bounce mode
%
MMXP_f_t = [];	
MMXT_f_t = [];
sm_f = zeros(1,nr+1);
sm_T_f = zeros(1,nr+1);
normf0 = zeros(nr,nit_f);
normf1 = zeros(nr,nit_f);
curr0 = zeros(nr,nit_f);
curr1 = zeros(nr,nit_f);
prec_curr = zeros(nr,nit_f);
prec_normf = zeros(nr,nit_f);
residu_f = ones(nr,nit_f);
prec_residu_f = ones(nr,nit_f);
%
for ir = 1:nr,
	if bounce_mode == 1,
		Zmask_f0_P{ir} = logical(XXheaviside(1,:,ir));%Passing electrons are selected
		Zmask_f0_Tm{ir} = logical(~XXheaviside(1,:,ir)) & (mhu < 0);%Trapped electrons with mhu>0 are selected                          
		Zmask_f0_Tp{ir} = logical(~XXheaviside(1,:,ir)) & (mhu > 0);%Trapped electrons with mhu<0 are selected  
		Zmask_f0_t{ir} = (Zmask_f0_P{ir} + Zmask_f0_Tp{ir}) > 0;%Passing and half of trapped electrons are selected
		Zmask_f0_t_P{ir} = Zmask_f0_P{ir}(Zmask_f0_t{ir});%For matrix symmetrization
		Zmask_f0_t_Tp{ir} = Zmask_f0_Tp{ir}(Zmask_f0_t{ir});%For matrix symmetrization	
		jmhut_min(ir) = min(find(Zmask_f0_Tm{ir}));	
		jmhut_max(ir) = max(find(Zmask_f0_Tp{ir}));	
		djmhut(ir) = (jmhut_max(ir) - jmhut_min(ir) + 1)/2;
		ns_f(ir) = djmhut(ir);		
	else
		Zmask_f0_t{ir} = logical(ones(1,nmhu));%All electrons are selected
		ns_f(ir) = 0;%Number of mhu values that are removed for implicit bounce averaged calculations		
	end
%
	blocksize_f_t(ir) = (nmhu-ns_f(ir))*npn;%For supermatrix construction
	blocksize_T_f_t(ir) = (nmhu-ns_f(ir))*npn;%For supermatrix construction
end
%
nMMXP_f_t = max(cumsum(blocksize_f_t));
MMXR_f_t = sparse(nMMXP_f_t,nMMXP_f_t);
%
if dke_mode == 1,
	for ir_dke = 1:nr_dke,
		jr2 = rdke(ir_dke);
		Zmask_g{ir_dke} = Zmask_f0_P{jr2};%Passing electrons are selected
		ns_g(ir_dke)= max(find(~Zmask_g{ir_dke})) - min(find(~Zmask_g{ir_dke})) + 1;%number of mhu values that are removed
%
		blocksize_tp(ir_dke) = nmhu*npn;	
		blocksize_g_t(ir_dke) = (nmhu-ns_g(ir_dke))*npn;
	end
%
	nMMXP_tp = max(cumsum(blocksize_tp));
	nMMH_tp = npn*nmhu*nr;
	nMMXP_g_t = max(cumsum(blocksize_g_t));
%
	MMXP_tp = [];
	MMH_tp = sparse(nMMH_tp,nMMH_tp);
	MMXP_g_t = [];
%
	sm_tp = zeros(1,nr_dke+1);
	sm_g = zeros(1,nr_dke+1);
	residu_g = ones(nr_dke,nit_g);
	prec_residu_g = ones(nr_dke,nit_g);
end
%	
%Pitch-angle integral for the Lorentz model (test mode only and initial guess for the drift kinetic equation, see documentation)
%	
XXILor =  zeros(npn,nmhu,nr);
for ir_dke = 1:nr_dke,
	jr2 = rdke(ir_dke);
	if bounce_mode == 1
		ILor_p = Zmask_f0_P{jr2}.*sum(((dmhu.*(mhu>=0).*XXlambda_b_p3m2(1,:,jr2)./XXlambda_p2m1(1,:,jr2))'*ones(1,nmhu)).*triu(ones(nmhu,nmhu)));
		ILor_m = fliplr(ILor_p);
		ILor = ILor_m + ILor_p;
		XXILor(:,:,jr2) = ones(npn,1)*ILor;
	else
		XXILor(:,:,jr2) = zeros(npn,nmhu);
	end	
end	
%
if nargin < narginmax,XXfinit = zeros(np,nmhu,nr);end;%For the initial guess of f0
%
Pabs = zeros(1,nr);
Pcoll = zeros(1,nr);
trapped_fraction = NaN*ones(1,nr);
curr_0_fsav = NaN*ones(1,nr);
normf = NaN*ones(1,nr);
Te_out_norm = NaN*ones(1,nr);
RR = NaN*ones(nr,npn);	
RR_fsav = NaN*ones(nr,npn);
normf_fsav = NaN*ones(1,nr);
curr_tot = NaN*ones(1,nr);
curr_tot_fsav = NaN*ones(1,nr);
curr_0 = NaN*ones(1,nr);
Pcoll_tot_fsav = NaN*ones(1,nr);	
Pabs_tot_fsav = NaN*ones(1,nr);
currB = NaN*ones(1,nr);
currB_fsav = NaN*ones(1,nr);
%
XXI = zeros(npn,nmhu,nr);
XXI_g = zeros(npn,nmhu,nr);
XXf0 = zeros(npn,nmhu,nr);
XXf0_tp = zeros(npn,nmhu,nr);
XXf0_g = zeros(npn,nmhu,nr);
XXf0_L_tp = zeros(npn,nmhu,nr);
XXf0_L_g = zeros(npn,nmhu,nr);	
XXSp = zeros(npn,nmhu,nr);
XXSmhu = zeros(npn,nmhu,nr);
XXfM = zeros(npn,nmhu,nr);
XXf0_g_th = zeros(npn,nmhu,nr);
XXFee = zeros(npn,nmhu,nr);
XXFeem = zeros(npn,nmhu,nr);
XXFeep = zeros(npn,nmhu,nr);
XXAee = zeros(npn,nmhu,nr);
XXAeem = zeros(npn,nmhu,nr);
XXAeep = zeros(npn,nmhu,nr);
XXBtee = zeros(npn,nmhu,nr);
XXFei = zeros(npn,nmhu,nr);
XXFeim = zeros(npn,nmhu,nr);
XXFeip = zeros(npn,nmhu,nr);
XXAei = zeros(npn,nmhu,nr);
XXAeim = zeros(npn,nmhu,nr);
XXAeip = zeros(npn,nmhu,nr);
XXBtei = zeros(npn,nmhu,nr);
XXddeltaimdrho_tp_c = zeros(npn,nmhu,nr);
XXMrm = zeros(nmhu,npn,nr);
XXMr = zeros(nmhu,npn,nr);
XXMrp = zeros(nmhu,npn,nr);
XXH_tp_mm = zeros(npn,nmhu,nr);
XXH_tp_mp = zeros(npn,nmhu,nr);
XXH_tp_m = zeros(npn,nmhu,nr);
XXH_tp_pm = zeros(npn,nmhu,nr);
XXH_tp_pp = zeros(npn,nmhu,nr);		
XXH_tp_p = zeros(npn,nmhu,nr);
XXa = zeros(npn,nmhu,nr);
XXb = zeros(npn,nmhu,nr);
XXc = zeros(npn,nmhu,nr);
XXd = zeros(npn,nmhu,nr);
XXe = zeros(npn,nmhu,nr);
XXf = zeros(npn,nmhu,nr);
XXg = zeros(npn,nmhu,nr);
XXh = zeros(npn,nmhu,nr);
XXi = zeros(npn,nmhu,nr);
%
%Radial coefficients
%
etime_radial = 0;
time0 = clock;
%
if radial_mode == 1,
%
	XXdeltalp = XXdpsinpp./(XXdpsinpp + XXdpsin);
	XXdeltalm = XXdpsin./(XXdpsinmm + XXdpsin);
%
	XXDrmm = zeros(npn,nmhu,nr);
	XXDrmm(:,:,2:nr) = XXDr(:,:,1:nr-1);
	XXDrpp = zeros(npn,nmhu,nr);
	XXDrpp(:,:,1:nr-1) = XXDr(:,:,2:nr);
%
	XXDrp = (1 - XXdeltalp).*XXDrpp + XXdeltalp.*XXDr;%Evaluation of the diffusion rate on the flux grid (linear interpolation)
	XXDrm = (1 - XXdeltalm).*XXDr + XXdeltalm.*XXDrmm;%Evaluation of the diffusion rate on the flux grid (linear interpolation)
%
	XXVrmm = zeros(npn,nmhu,nr);
	XXVrmm(:,:,2:nr) = XXVr(:,:,1:nr-1);
	XXVrpp = zeros(npn,nmhu,nr);
	XXVrpp(:,:,1:nr-1) = XXVr(:,:,2:nr);
%
	XXVrp = (1 - XXdeltalp).*XXVrpp + XXdeltalp.*XXVr;%Evaluation of the convection on the flux grid (linear interpolation)
	XXVrm = (1 - XXdeltalm).*XXVr + XXdeltalm.*XXVrmm;%Evaluation of the convection on the flux grid (linear interpolation)
%
	XXR0 = repmat(reshape(xR0',[1,1,nr]),[npn,nmhu,1]);
	XXR0mm = zeros(npn,nmhu,nr);
	XXR0mm(:,:,2:nr) = XXR0(:,:,1:nr-1);
	XXR0pp = zeros(npn,nmhu,nr);
	XXR0pp(:,:,1:nr-1) = XXR0(:,:,2:nr);
%
	XXR0p = (1 - XXdeltalp).*XXR0pp + XXdeltalp.*XXR0;%Evaluation on the flux grid (linear interpolation)
	XXR0m = (1 - XXdeltalm).*XXR0 + XXdeltalm.*XXR0mm;%Evaluation on the flux grid (linear interpolation)
%
	XXqtilde = repmat(reshape(xqtilde',[1,1,nr]),[npn,nmhu,1]);
	XXqtildemm = zeros(npn,nmhu,nr);
	XXqtildemm(:,:,2:nr) = XXqtilde(:,:,1:nr-1);
	XXqtildepp = zeros(npn,nmhu,nr);
	XXqtildepp(:,:,1:nr-1) = XXqtilde(:,:,2:nr);
%
	XXqtildep = (1 - XXdeltalp).*XXqtildepp + XXdeltalp.*XXqtilde;%Evaluation on the flux grid (linear interpolation)
	XXqtildem = (1 - XXdeltalm).*XXqtilde + XXdeltalm.*XXqtildemm;%Evaluation on the flux grid (linear interpolation)
%	
	XXBp0 = repmat(reshape(xBp0',[1,1,nr]),[npn,nmhu,1]);
	XXBp0mm = zeros(npn,nmhu,nr);
	XXBp0mm(:,:,2:nr) = XXBp0(:,:,1:nr-1);
	XXBp0pp = zeros(npn,nmhu,nr);
	XXBp0pp(:,:,1:nr-1) = XXBp0(:,:,2:nr);
%
	XXBp0p = (1 - XXdeltalp).*XXBp0pp + XXdeltalp.*XXBp0;%Evaluation on the flux grid (linear interpolation)
	XXBp0m = (1 - XXdeltalm).*XXBp0 + XXdeltalm.*XXBp0mm;%Evaluation on the flux grid (linear interpolation)
%
	XXB0 = repmat(reshape(xB0',[1,1,nr]),[npn,nmhu,1]);
	XXB0mm = zeros(npn,nmhu,nr);
	XXp0mm(:,:,2:nr) = XXB0(:,:,1:nr-1);
	XXB0pp = zeros(npn,nmhu,nr);
	XXB0pp(:,:,1:nr-1) = XXB0(:,:,2:nr);
%
	XXB0p = (1 - XXdeltalp).*XXB0pp + XXdeltalp.*XXB0;%Evaluation on the flux grid (linear interpolation)
	XXB0m = (1 - XXdeltalm).*XXB0 + XXdeltalm.*XXB0mm;%Evaluation on the flux grid (linear interpolation)
%
	XXlambdamm = zeros(npn,nmhu,nr);
	XXlambdamm(:,:,2:nr) = XXlambda(:,:,1:nr-1);
	XXlambdapp = zeros(npn,nmhu,nr);
	XXlambdapp(:,:,1:nr-1) = XXlambda(:,:,2:nr);
%
	XXlambdap = (1 - XXdeltalp).*XXlambdapp + XXdeltalp.*XXlambda;%Evaluation on the flux grid (linear interpolation)
	XXlambdam = (1 - XXdeltalm).*XXlambda + XXdeltalm.*XXlambdamm;%Evaluation on the flux grid (linear interpolation)
%	
	XXalpharp = XXR0p.*XXqtildep.*XXBp0p.*XXlambdap./XXB0p;%Evaluation on the flux grid (linear interpolation)
	XXalpharm = XXR0m.*XXqtildem.*XXBp0m.*XXlambdam./XXB0m;%Evaluation on the flux grid (linear interpolation)
	XXalpharm(:,:,1) = 0;%Force zero at the plasma center, which is the natural analytical limit (In cylindrical geometry, r=0)
	XXalpharp(:,:,nr) = 0;%Avoid NaN
%
%************************************************** Matrices calculation ******************************************************** 
%
	XXMrm = -(XXalpharm.*XXR0m.*XXBp0m./XXdpsinm./XXdpsin).*XXDrm - (XXalpharm./XXdpsin).*XXVrm.*XXdeltalm;
	XXMr = (XXalpharp.*XXR0p.*XXBp0p./XXdpsinp./XXdpsin).*XXDrp + (XXalpharp./XXdpsin).*XXVrp.*XXdeltalp +...
	       (XXalpharm.*XXR0m.*XXBp0m./XXdpsinm./XXdpsin).*XXDrm - (XXalpharm./XXdpsin).*XXVrm.*(1 - XXdeltalm);				       
	XXMrp = -(XXalpharp.*XXR0p.*XXBp0p./XXdpsinp./XXdpsin).*XXDrp + (XXalpharp./XXdpsin).*XXVrp.*(1 - XXdeltalp);
%
	XXMrm = XXMrm.*XXpn2./XXlambda;%Partial Jacobian multiplication
	XXMr = XXMr.*XXpn2./XXlambda;%Partial Jacobian multiplication
	XXMrp = XXMrp.*XXpn2./XXlambda;%Partial Jacobian multiplication
%
% Radial off-diagonal terms for fast electron transport
%
	if bounce_mode == 0,
		XXMrm = permute(XXMrm,[2,1,3]);
		MMrm_t = reshape(XXMrm,npn*nmhu*nr,1,1);
		XXMr = permute(XXMr,[2,1,3]);
		MMr_t = reshape(XXMr,npn*nmhu*nr,1,1);
		XXMrp = permute(XXMrp,[2,1,3]);
		MMrp_t = reshape(XXMrp,npn*nmhu*nr,1,1);
%
		MMXR_f_t = MMXR_f_t + sparse([1+nmhu*npn:nMMXP_f_t],[1:nMMXP_f_t-nmhu*npn],MMrm_t(1+npn*nmhu:nMMXP_f_t),nMMXP_f_t,nMMXP_f_t);
		MMXR_f_t = MMXR_f_t + sparse([1:nMMXP_f_t],[1:nMMXP_f_t],MMr_t,nMMXP_f_t,nMMXP_f_t);	
		MMXR_f_t = MMXR_f_t + sparse([1:nMMXP_f_t-nmhu*npn],[1+npn*nmhu:nMMXP_f_t],MMrp_t(1:nMMXP_f_t-nmhu*npn),nMMXP_f_t,nMMXP_f_t);
		if display_mode >= 1,info_dke_yp(2,['Configuration space matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
	elseif bounce_mode == 1,	
		ir = 1;
		ib0 = 0;
		ibp = max(cumsum(blocksize_f_t(1:ir)));
%
		Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
		Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
		Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
		Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
%	
		imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir)));	
		imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
%
		XMr = XXMr(:,:,ir);
		XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
		MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
		MMXR_f_t = MMXR_f_t + sparse([1+ib0:ibp],[1+ib0:ibp],MMr_t,nMMXP_f_t,nMMXP_f_t);
%			
		XMrp = XXMrp(:,:,ir);
		XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
		XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));
		XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
		XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);
%			
		for ip = 1:npn,	
			MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup],XMrp1_t(ip,[1:imhup]),nMMXP_f_t,nMMXP_f_t);
			MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip],XMrp3_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);
			MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],...
			[ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1],XMrp2_t(ip,[imhup+1:imhu0]),nMMXP_f_t,nMMXP_f_t);
		end	
%
		if display_mode >= 1,info_dke_yp(2,['D and F tensor calculations for fast electron radial transport at radius number (',int2str(ir),'/',int2str(nr),') done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
%
		for ir = 2:nr-1,
			if ir == 2,
				ibm = 0;
			else
				ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
			end
			ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
			ibp = max(cumsum(blocksize_f_t(1:ir)));
%
			Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
			Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
			Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
			Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
			Xmask_f0p = (Xmhu2 < xmhubounce2(ir+1)) & (Xmhu < 0);%Only the half-bounce region is removed
			Xmask_f0p = nonzeros(~(Xmask_f0p(2,:)==1).*cumsum(ones(1,nmhu)))';
%	
			imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
			imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir)));	
			imhup = sum((Xmhu(1,Xmask_f0p) < 0).*(Xmhu2(1,Xmask_f0p) > xmhubounce2(ir+1)));
%
			XMr = XXMr(:,:,ir);
			XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
			MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
			MMXR_f_t = MMXR_f_t + sparse([1+ib0:ibp],[1+ib0:ibp],MMr_t,nMMXP_f_t,nMMXP_f_t);
%			
			XMrp = XXMrp(:,:,ir);
			XMrp_t = XMrp(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
			XMrp1_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir+1));
			XMrp2_t = XMrp_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) < xmhubounce2(ir+1)).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
			XMrp3_t = XMrp_t.*(Xmhu(:,Xmask_f0) > 0);			
%			
			XMrm = XXMrm(:,:,ir);
			XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
			XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
			XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
%	
			for ip = 1:npn,	
				MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhup],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup],XMrp1_t(ip,[1:imhup]),nMMXP_f_t,nMMXP_f_t);
				MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibp+(nmhu-ns_f(ir+1))*(ip-1)+imhup+1:ibp+(nmhu-ns_f(ir+1))*ip],XMrp3_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);
				MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhup+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],...
				[ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhup):-1:ibp+(nmhu-ns_f(ir+1))*(ip-1)+((nmhu-ns_f(ir+1))-imhu0)+1],XMrp2_t(ip,[imhup+1:imhu0]),nMMXP_f_t,nMMXP_f_t);
%
				MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0],XMrm1_t(ip,[1:imhu0]),nMMXP_f_t,nMMXP_f_t);				
				MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*ip],XMrm2_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);				
			end	
%
    		if display_mode >= 1,info_dke_yp(2,['Configuration space matrix calculations (',int2str(ir),'/',int2str(nr),') done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
		end
%
		ir = nr;
		ibm = max(cumsum(blocksize_f_t(1:ir-2)));%Block index reference
		ib0 = max(cumsum(blocksize_f_t(1:ir-1)));%Block index reference
		ibp = max(cumsum(blocksize_f_t(1:ir)));
%
		Xmask_f0m = (Xmhu2 < xmhubounce2(ir-1)) & (Xmhu < 0);%Only the half-bounce region is removed
		Xmask_f0m = nonzeros(~(Xmask_f0m(2,:)==1).*cumsum(ones(1,nmhu)))';
		Xmask_f0 = (Xmhu2 < xmhubounce2(ir)) & (Xmhu < 0);%Only the half-bounce region is removed
		Xmask_f0 = nonzeros(~(Xmask_f0(2,:)==1).*cumsum(ones(1,nmhu)))';
%	
		imhum = sum((Xmhu(1,Xmask_f0m) < 0).*(Xmhu2(1,Xmask_f0m) > xmhubounce2(ir-1)));
		imhu0 = sum((Xmhu(1,Xmask_f0) < 0).*(Xmhu2(1,Xmask_f0) > xmhubounce2(ir)));	
%
		XMr = XXMr(:,:,ir);
		XMr_t = XMr(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
		MMr_t = reshape(XMr_t',npn*(nmhu-ns_f(ir)),1,1);
		MMXR_f_t = MMXR_f_t + sparse([1+ib0:ibp],[1+ib0:ibp],MMr_t,nMMXP_f_t,nMMXP_f_t);
%			
		XMrm = XXMrm(:,:,ir);
		XMrm_t = XMrm(:,Xmask_f0);%Matrix reduction along the angular direction (half-bounce region is removed)
		XMrm1_t = XMrm_t.*(Xmhu(:,Xmask_f0) < 0).*(Xmhu2(:,Xmask_f0) > xmhubounce2(ir));
		XMrm2_t = XMrm_t.*(Xmhu(:,Xmask_f0) > 0);
%	
		for ip = 1:npn,	
			MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+1:ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+1:ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhu0],XMrm1_t(ip,[1:imhu0]),nMMXP_f_t,nMMXP_f_t);				
			MMXR_f_t = MMXR_f_t + sparse([ib0+(nmhu-ns_f(ir))*(ip-1)+imhu0+1:ib0+(nmhu-ns_f(ir))*ip],[ibm+(nmhu-ns_f(ir-1))*(ip-1)+imhum+1:ibm+(nmhu-ns_f(ir-1))*ip],XMrm2_t(ip,[imhu0+1:nmhu-ns_f(ir)]),nMMXP_f_t,nMMXP_f_t);				
		end
%
		if display_mode >= 1,info_dke_yp(2,['D and F tensor calculations for fast electron radial transport at radius number (',int2str(ir),'/',int2str(nr),') done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
		etime_radial = etime_radial + etime(clock,time0);
		time0 = clock;
%
	end
	if display_mode >= 1,info_dke_yp(2,['Zero order configuration space matrix calculations done in ',num2str(etime_radial),' (s)']);end
end
%
% Collisions
%
time0 = clock;%Timer
for ir = 1:nr,
%
%Relativistic Maxwellian distribution function for collision integrals
%
	fM = exp(-pn2./(1 + gamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
	normfM = 4*pi*integral_dke_jd(dpn,pn.*pn.*fM,2);
	fM = fM*xne_norm(ir)/normfM;
	xfM = fM'*ones(1,length(fM));
	XXfM(:,:,ir) = fM'*ones(1,nmhu);
	if nargin < narginmax,
		XXfinit(:,:,ir) = fM'*ones(1,nmhu);%Initial guess (normalized to xne_norm)
	end
%
	fMm = exp(-pn2m./(1 + gammam)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
	normfMm = 4*pi*integral_dke_jd(dpnm,pnm.*pnm.*fMm,2);
	fMm = fMm*xne_norm(ir)/normfMm;
%
	fMp = exp(-pn2p./(1 + gammap)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
	normfMp = 4*pi*integral_dke_jd(dpnp,pnp.*pnp.*fMp,2);
	fMp = fMp*xne_norm(ir)/normfMp;
%
%Collision integrals
%	
	sfMm = exp(-spn2m./(1 + sgammam)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
	snormfMm = 4*pi*trapz_dke_yp([spnm,spn2m.*sfMm]);
	sfMm = sfMm*xne_norm(ir)/snormfMm;
%	
	sfM = exp(-spn2./(1 + sgamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
	snormfM = 4*pi*trapz_dke_yp([spn,spn2.*sfM]);
	sfM = sfM*xne_norm(ir)/snormfM;
%
	sfMp = exp(-spn2p./(1 + sgammap)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
	snormfMp = 4*pi*trapz_dke_yp([spnp,spn2p.*sfMp]);
	sfMp = sfMp*xne_norm(ir)/snormfMp;
%
	for ip = 1:npn,%Loop for very accurate collision integral calculation close to p = 0 especially (crucial for numerical conservative scheme)
		smasku = spn <= pn(ip);
		smaskl = spn >= pn(ip);
		smaskup = spnp <= pnp(ip);
		smasklp = spnp >= pnp(ip);
		smaskum = spnm <= pnm(ip);
		smasklm = spnm >= pnm(ip);
%
		F1_1(1,ip) = trapz_dke_yp([spn,sfM.*spn.*sv.*smasku])';
		F1_2(1,ip) = trapz_dke_yp([spn,sfM.*spn.*sv.*(1 - sgamma.*ssigma./sz).*smasku])';
		F2_1(1,ip) = trapz_dke_yp([spn,sfM.*spn.*smaskl])';
%		
		F1_1m(1,ip) = trapz_dke_yp([spnm,sfMm.*spnm.*svm.*smaskum])';
		F1_2m(1,ip) = trapz_dke_yp([spnm,sfMm.*spnm.*svm.*(1 - sgammam.*ssigmam./szm).*smaskum])';
		F2_1m(1,ip) = trapz_dke_yp([spnm,sfMm.*spnm.*smasklm])';
%		
		F1_1p(1,ip) = trapz_dke_yp([spnp,sfMp.*spnp.*svp.*smaskup])';
		F1_2p(1,ip) = trapz_dke_yp([spnp,sfMp.*spnp.*svp.*(1 - sgammap.*ssigmap./szp).*smaskup])';
		F2_1p(1,ip) = trapz_dke_yp([spnp,sfMp.*spnp.*smasklp])';
%
		B1_1(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2])';
		B1_2(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*spn2])';
		B1_3(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ1./sgamma])';
		B1_4(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*sJ2./sgamma])';
		B1_5(1,ip) = trapz_dke_yp([spn,sfM.*smasku.*spn2.*((sgamma - ssigma./sz)./sgamma)])';
		B2_1(1,ip) = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv])';
		B2_2(1,ip) = trapz_dke_yp([spn,sfM.*smaskl.*spn2./sv./sgamma2])';
		B2_3(1,ip) = trapz_dke_yp([spn,sfM.*smaskl.*spn2.*sv])';  
	end
%
%Electron-ion collision term (non-relativistic limit)
%
	[Fei,Aei,Btei] = eicoll_dke_yp(v,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode);
	[Feim,Aeim] = eicoll_dke_yp(vm,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode);
	[Feip,Aeip] = eicoll_dke_yp(vp,zZi,zmi,xzni_norm,xzTi_norm,ir,coll_mode);
%	
	Feim(1) = 1;%Avoid singularity at p = 0, but the value is not used	
	Feimm = [0,Fei(1:npn-1)];
	Feipp = [Fei(2:npn),0];
%		
	XXFeimm(:,:,ir) = Feimm'*ones(1,nmhu);
	XXFeim(:,:,ir) = Feim'*ones(1,nmhu);
	XXFei(:,:,ir) = Fei'*ones(1,nmhu);
	XXFeip(:,:,ir) = Feip'*ones(1,nmhu);
	XXFeipp(:,:,ir) = Feipp'*ones(1,nmhu);
%
	Aeim(1) = 1;%Avoid singularity at p = 0, but the value is not used
	Aeimm = [eps,Aei(1:npn-1)];
	Aeipp = [Aei(2:npn),eps];
%
	XXAeimm(:,:,ir) = Aeimm'*ones(1,nmhu);
	XXAeim(:,:,ir) = Aeim'*ones(1,nmhu); 
	XXAei(:,:,ir) = Aei'*ones(1,nmhu);
	XXAeip(:,:,ir) = Aeip'*ones(1,nmhu);
	XXAeipp(:,:,ir) = Aeipp'*ones(1,nmhu);
%
	XXBtei(:,:,ir) = Btei'*ones(1,nmhu);	
%
%Fast electron-thermal electron collision term
%
	if coll_mode == 1,%High-velocity limit
		Fee = xne_norm(ir)'./v2;
		Feem = xne_norm(ir)'./v2m;		
		Feep = xne_norm(ir)'./v2p;		
	elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
		F1 = F1_1./v2 + F1_2./pn2;
		F2 = (1 - sigma./z./gamma).*F2_1./v;
		Fee = 4*pi*(F1 + F2);
%
		F1m = F1_1m ./v2m + F1_2m./pn2m;  
		F2m = (1 - sigmam./zm./gammam).*F2_1m./vm;	
		Feem = 4*pi*(F1m + F2m);		
%   
		F1p = F1_1p./v2p + F1_2p./pn2p;   
		F2p = (1 - sigmap./zp./gammap).*F2_1p./vp;
		Feep = 4*pi*(F1p + F2p);
	elseif coll_mode == 3,%Lorentz model
		Fee = zeros(1,npn);
		Feem = zeros(1,npn);
		Feep = zeros(1,npn);
	elseif coll_mode == 4,%Maxwellian background
		u = v/sqrt(2)/xTe_norm(ir)';Fee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v2;
		um = vm/sqrt(2)/xTe_norm(ir)';Feem = xne_norm(ir)'.*(erf(um)-2*um.*exp(-um.^2)/sqrt(pi))./v2m;	
		up = vp/sqrt(2)/xTe_norm(ir)';Feep = xne_norm(ir)'.*(erf(up)-2*up.*exp(-up.^2)/sqrt(pi))./v2p;			
	end
%
	Feem(1) = 1;%Avoid singularity at p = 0, but the value is not used
	Feemm = [0,Fee(1:npn-1)];
	Feepp = [Fee(2:npn),0];
%		
	XXFeemm(:,:,ir) = Feemm'*ones(1,nmhu);
	XXFeem(:,:,ir) = Feem'*ones(1,nmhu);
	XXFee(:,:,ir) = Fee'*ones(1,nmhu);
	XXFeep(:,:,ir) = Feep'*ones(1,nmhu);
	XXFeepp(:,:,ir) = Feepp'*ones(1,nmhu);
%
	if coll_mode == 1,%High-velocity limit
		Aee = xne_norm(ir)'.*xTe_norm(ir)'./v./v2;
		Aeem = xne_norm(ir)'.*xTe_norm(ir)'./vm./v2m;
		Aeep = xne_norm(ir)'.*xTe_norm(ir)'./vp./v2p;
	elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
		Aee = 4*pi*xTe_norm(ir)*(F1 + F2)./v;
		Aeem = 4*pi*xTe_norm(ir)*(F1m + F2m)./vm;
		Aeep = 4*pi*xTe_norm(ir)*(F1p + F2p)./vp;
	elseif coll_mode == 3,%Lorentz model
		Aee = zeros(1,npn);
		Aeem = zeros(1,npn);
		Aeep = zeros(1,npn);
	elseif coll_mode == 4,%Maxwellian background
		u = v/sqrt(2)/xTe_norm(ir)';Aee = xne_norm(ir)'.*(erf(u)-2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/2;
		um = vm/sqrt(2)/xTe_norm(ir)';Aeem = xne_norm(ir)'.*(erf(um)-2*um.*exp(-um.^2)/sqrt(pi))./vm./um./um/2;	
		Am(1) = 1;%Avoid singularity at p = 0, but the value is not used
		up = vp/sqrt(2)/xTe_norm(ir)';Aeep = xne_norm(ir)'.*(erf(up)-2*up.*exp(-up.^2)/sqrt(pi))./vp./up./up/2;	
	end
%
	Aeem(1) = 1;%Avoid singularity at p = 0, but the value is not used
	Aeemm = [eps,Aee(1:npn-1)];
	Aeepp = [Aee(2:npn),eps];
%
	XXAeemm(:,:,ir) = Aeemm'*ones(1,nmhu);
	XXAeem(:,:,ir) = Aeem'*ones(1,nmhu); 
	XXAee(:,:,ir) = Aee'*ones(1,nmhu);
	XXAeep(:,:,ir) = Aeep'*ones(1,nmhu);
	XXAeepp(:,:,ir) = Aeepp'*ones(1,nmhu);
%
	if coll_mode == 1,%High-velocity limit
		Btee = xne_norm(ir)'./v/2 - xne_norm(ir)'.*xTe_norm(ir)'./v./v2/2;
	elseif coll_mode == 0 | coll_mode == 2,%Linearized Belaiev-Budker
		B1 = B1_1./v/2 - B1_2./v./pn2/6 + B1_3./v./gamma2./z2/8 - B1_4./v./z2/4 - B1_5./v./gamma2/4;
		B2 = B2_1/2 + B2_2.*(-gamma2/6 + J1./z2./gamma/8 - gamma.*J2./z2/4) - B2_3.*(gamma - sigma./z)./pn2./gamma/4;   
		Btee = 4*pi*(B1 + B2);  	
	elseif coll_mode == 3,%Lorentz model
		Btee = zeros(1,npn);
	elseif coll_mode == 4,%Maxwellian background
		u = v/sqrt(2)/xTe_norm(ir)';                  
		Btee = xne_norm(ir)'.*((2*u.^2-1).*erf(u)+2*u.*exp(-u.^2)/sqrt(pi))./v./u./u/4;
	end
%
	XXBtee(:,:,ir) = Btee'*ones(1,nmhu);	
end
if display_mode >= 1,info_dke_yp(2,['D and F tensor calculations for collisions and Ohmic electric done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
%
  save(fullfile(temppath,'temp_data1'));
  if display_mode >= 1,info_dke_yp(2,['Data saving on disk done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
else
   load(fullfile(temppath,'temp_data1'));
	if display_mode >= 1,info_dke_yp(2,['Data reloading from disk done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
end
%
% RF wave coefficients
%
if ~isempty(waveparam),
    [nb,XXDrf_ij,XXDrf_tp_ij,XXFrf_tp_ij,...
    XXDpp_rf_ippj,XXDpp_rf_ipj,XXDpp_rf_ij,XXDpp_rf_imj,XXDpp_rf_immj,...
	 XXDpm_rf_ipj,XXDpm_rf_ij,XXDpm_rf_imj,XXDmp_rf_ijp,XXDmp_rf_ij,XXDmp_rf_ijm,...
	 XXDmm_rf_ijp,XXDmm_rf_ijm,...
	 XXDpp_rf_tp_ippj,XXDpp_rf_tp_ipj,XXDpp_rf_tp_ij,XXDpp_rf_tp_imj,XXDpp_rf_tp_immj,...
	 XXDpm_rf_tp_ipj,XXDpm_rf_tp_ij,XXDpm_rf_tp_imj,XXDmp_rf_tp_ijp,XXDmp_rf_tp_ij,XXDmp_rf_tp_ijm,...
	 XXDmm_rf_tp_ijp,XXDmm_rf_tp_ijm,...
	 XXFp_rf_tp_ippj,XXFp_rf_tp_ipj,XXFp_rf_tp_ij,XXFp_rf_tp_imj,XXFp_rf_tp_immj,XXFm_rf_tp_ijp,XXFm_rf_tp_ijm] = rfdiff_dke_jd(it_rf,Dqlmax,waveparam,nmax_rf,...
    theta,XR,XZ,XBR,XBZ,XBphi,xB0,Rp,Zp,xqtilde,...       
    XXheaviside,XXheaviside_p,XXheaviside_m,...  
	 Xmhup,Xmhu,Xmhum,Xmhu2p,Xmhu2,Xmhu2m,X1mmhu2p,X1mmhu2,X1mmhu2m,...
    Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
	 pnpp,pnp,pn,pnm,pnmm,Xpnpp,Xpnp,Xpn,Xpnm,Xpnmm,...
	 Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
	 Xgammapp,Xgammap,Xgamma,Xgammam,Xgammamm,...
	 Xxlambda_p,Xxlambda,Xxlambda_m,...
	 betath_ref,temppath,bounce_mode,dke_mode,display_mode);    
else
	nb = 0;
%    
	XXDpp_rf_ippj = zeros(npn,nmhu,nr);
	XXDpp_rf_ipj = zeros(npn,nmhu,nr);
	XXDpp_rf_ij = zeros(npn,nmhu,nr);
	XXDpp_rf_imj = zeros(npn,nmhu,nr);
	XXDpp_rf_immj = zeros(npn,nmhu,nr);
%
	XXDpm_rf_ipj = zeros(npn,nmhu,nr);
	XXDpm_rf_ij = zeros(npn,nmhu,nr);
	XXDpm_rf_imj = zeros(npn,nmhu,nr);
%
	XXDmp_rf_ijp = zeros(npn,nmhu,nr);
	XXDmp_rf_ij = zeros(npn,nmhu,nr);
	XXDmp_rf_ijm = zeros(npn,nmhu,nr);
%
	XXDmm_rf_ijp = zeros(npn,nmhu,nr);
	XXDmm_rf_ijm = zeros(npn,nmhu,nr);
%
	XXDrf_ij = zeros(npn,nmhu,nr);
	XXDrf_tp_ij = zeros(npn,nmhu,nr);
	XXFrf_tp_ij = zeros(npn,nmhu,nr);
%
   if dke_mode == 1
    	XXDpp_rf_tp_ippj = zeros(npn,nmhu,nr);
    	XXDpp_rf_tp_ipj = zeros(npn,nmhu,nr);
    	XXDpp_rf_tp_ij = zeros(npn,nmhu,nr);
    	XXDpp_rf_tp_imj = zeros(npn,nmhu,nr);
    	XXDpp_rf_tp_immj = zeros(npn,nmhu,nr);
%
    	XXDpm_rf_tp_ipj = zeros(npn,nmhu,nr);
    	XXDpm_rf_tp_ij = zeros(npn,nmhu,nr);
    	XXDpm_rf_tp_imj = zeros(npn,nmhu,nr);
%
    	XXDmp_rf_tp_ijp = zeros(npn,nmhu,nr);
    	XXDmp_rf_tp_ij = zeros(npn,nmhu,nr);
    	XXDmp_rf_tp_ijm = zeros(npn,nmhu,nr);
%
    	XXDmm_rf_tp_ijp = zeros(npn,nmhu,nr);
    	XXDmm_rf_tp_ijm = zeros(npn,nmhu,nr);
%
    	XXDrf_tp_ij = zeros(npn,nmhu,nr);
%    
     	XXFp_rf_tp_ippj = zeros(npn,nmhu,nr);
    	XXFp_rf_tp_ipj = zeros(npn,nmhu,nr);
    	XXFp_rf_tp_ij = zeros(npn,nmhu,nr);
    	XXFp_rf_tp_imj = zeros(npn,nmhu,nr);
    	XXFp_rf_tp_immj = zeros(npn,nmhu,nr);
%
      XXFm_rf_tp_ijp = zeros(npn,nmhu,nr);
    	XXFm_rf_tp_ijm = zeros(npn,nmhu,nr);
%
    	XXFrf_tp_ij = zeros(npn,nmhu,nr);
   end  
end
if display_mode >= 1,info_dke_yp(2,['D and F tensor calculations for RF waves done in ',num2str(etime(clock,time0)),' (s)']);end
%
% Fokker-Planck (zero order) matrix calculation
%
etime_fp = 0;
time0 = clock;
for ir = 1:nr,
%	
% D and F tensors for collisions
%
	XDpp_c_ippj = XXAeepp(:,:,ir) + XXAeipp(:,:,ir);
	XDpp_c_ipj = XXAeep(:,:,ir) + XXAeip(:,:,ir);
	XDpp_c_ij = XXAee(:,:,ir) + XXAei(:,:,ir);
	XDpp_c_imj = XXAeem(:,:,ir) + XXAeim(:,:,ir);
	XDpp_c_immj = XXAeemm(:,:,ir) + XXAeimm(:,:,ir);
%
	XDpm_c_ipj = zeros(npn,nmhu);
	XDpm_c_ij = zeros(npn,nmhu);
	XDpm_c_imj = zeros(npn,nmhu);
%
	XDmp_c_ijp = zeros(npn,nmhu);
	XDmp_c_ij = zeros(npn,nmhu);
	XDmp_c_ijm = zeros(npn,nmhu);
%
	XDmm_c_ijp = (XXBtee(:,:,ir) + XXBtei(:,:,ir)).*XXRlambda_p2m1_p(:,:,ir);
	XDmm_c_ijm = (XXBtee(:,:,ir) + XXBtei(:,:,ir)).*XXRlambda_p2m1_m(:,:,ir);
%
	XFp_c_ippj = -XXFeepp(:,:,ir) - XXFeipp(:,:,ir);
	XFp_c_ipj = -XXFeep(:,:,ir) - XXFeip(:,:,ir);
	XFp_c_ij = -XXFee(:,:,ir) - XXFei(:,:,ir);
	XFp_c_imj = -XXFeem(:,:,ir) - XXFeim(:,:,ir);
	XFp_c_immj = -XXFeemm(:,:,ir) - XXFeimm(:,:,ir);	
%
	XFm_c_ijp = zeros(npn,nmhu);
	XFm_c_ijm = zeros(npn,nmhu);
%    
	XXDpp_c_imj(:,:,ir) = XDpp_c_imj;
	XXDpm_c_imj(:,:,ir) = XDpm_c_imj;
	XXFp_c_imj(:,:,ir) = XFp_c_imj;
	XXDpp_c_ipj(:,:,ir) = XDpp_c_ipj;
	XXDpm_c_ipj(:,:,ir) = XDpm_c_ipj;
	XXFp_c_ipj(:,:,ir) = XFp_c_ipj;
%
	XXDmm_c_ijm(:,:,ir) = XDmm_c_ijm;
	XXDmp_c_ijm(:,:,ir) = XDmp_c_ijm;
	XXFm_c_ijm(:,:,ir) = XFm_c_ijm;
	XXDmm_c_ijp(:,:,ir) = XDmm_c_ijp;
	XXDmp_c_ijp(:,:,ir) = XDmp_c_ijp;
	XXFm_c_ijp(:,:,ir) = XFm_c_ijp;	
%	
% D and F tensors for electric field
%
	if bounce_mode == 0,
		xepsi(ir) = xepsi_fsav(ir);
	elseif bounce_mode == 1,
	   xepsi(ir) = xepsi_fsav(ir)*(xqbar(ir)/xqtilde(ir))*(xB0(ir)/xBT0(ir))*(xR0(ir)/Rp)/XXlambda_b_p1m3p4(1,1,ir);%Value at Bmin for FP or DKE calculations
	end
	if xepsi(ir) > 0.05, 
		info_dke_yp(2,'WARNING: Ohmic electric field is likely too large. See the documentation');%To be consistent with the assumption of the linearized Fokker-Planck equation
	end	
%	
	XDpp_e_ippj = zeros(npn,nmhu);
	XDpp_e_ipj = zeros(npn,nmhu);
	XDpp_e_ij = zeros(npn,nmhu); 	
	XDpp_e_imj = zeros(npn,nmhu);
	XDpp_e_immj = zeros(npn,nmhu);
%	
	XDpm_e_ipj = zeros(npn,nmhu);
	XDpm_e_ij = zeros(npn,nmhu);
	XDpm_e_imj = zeros(npn,nmhu);
%
	XDmp_e_ijp = zeros(npn,nmhu);
	XDmp_e_ij = zeros(npn,nmhu);
	XDmp_e_ijm = zeros(npn,nmhu);
%
	XDmm_e_ijp = zeros(npn,nmhu);
	XDmm_e_ijm = zeros(npn,nmhu);
%	
	XFp_e_ippj = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
	XFp_e_ipj = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
	XFp_e_ij = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);	
	XFp_e_imj = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir);
	XFp_e_immj = +Xmhu.*XXRlambda_b_p1m1p2(:,:,ir)*xepsi(ir); 	
%
	xEfield_validity(ir) = max(XFp_e_ij(ip_th_ref,[1,nmhu])./XFp_c_ij(ip_th_ref,[1,nmhu]));%Comparison between electric field and collisions pinches at pth_ref (if above 1, the code validity breaks close to p = 0 leading to numerical particle leak)                 
%
	XFm_e_ijp = -sqrt(X1mmhu2p).*XXRlambda_b_p1m1p2_p(:,:,ir)*xepsi(ir);
	XFm_e_ijm = -sqrt(X1mmhu2m).*XXRlambda_b_p1m1p2_m(:,:,ir)*xepsi(ir);
%
	XXDpp_e_imj(:,:,ir) = XDpp_e_imj;
	XXDpm_e_imj(:,:,ir) = XDpm_e_imj;
	XXFp_e_imj(:,:,ir) = XFp_e_imj;
	XXDpp_e_ipj(:,:,ir) = XDpp_e_ipj;
	XXDpm_e_ipj(:,:,ir) = XDpm_e_ipj;
	XXFp_e_ipj(:,:,ir) = XFp_e_ipj;
%
	XXDmm_e_ijm(:,:,ir) = XDmm_e_ijm;
	XXDmp_e_ijm(:,:,ir) = XDmp_e_ijm;
	XXFm_e_ijm(:,:,ir) = XFm_e_ijm;
	XXDmm_e_ijp(:,:,ir) = XDmm_e_ijp;
	XXDmp_e_ijp(:,:,ir) = XDmp_e_ijp;
	XXFm_e_ijp(:,:,ir) = XFm_e_ijp;
%
% D and F tensors for RF waves
%
	XDpp_rf_ippj = XXDpp_rf_ippj(:,:,ir);
	XDpp_rf_ipj = XXDpp_rf_ipj(:,:,ir);
	XDpp_rf_ij = XXDpp_rf_ij(:,:,ir);
	XDpp_rf_imj = XXDpp_rf_imj(:,:,ir);
	XDpp_rf_immj = XXDpp_rf_immj(:,:,ir);
%	
	XDpm_rf_ipj = XXDpm_rf_ipj(:,:,ir);
	XDpm_rf_ij = XXDpm_rf_ij(:,:,ir);	
	XDpm_rf_imj = XXDpm_rf_imj(:,:,ir);

	XDmp_rf_ijp = XXDmp_rf_ijp(:,:,ir);
	XDmp_rf_ij = XXDmp_rf_ij(:,:,ir);
	XDmp_rf_ijm = XXDmp_rf_ijm(:,:,ir);
%	
	XDmm_rf_ijp = XXDmm_rf_ijp(:,:,ir);
	XDmm_rf_ijm = XXDmm_rf_ijm(:,:,ir);	
%	
	XFp_rf_ippj = zeros(npn,nmhu);
	XFp_rf_ipj = zeros(npn,nmhu);
	XFp_rf_ij = zeros(npn,nmhu);
	XFp_rf_imj = zeros(npn,nmhu);
	XFp_rf_immj = zeros(npn,nmhu);
%
	XFm_rf_ijp = zeros(npn,nmhu);
	XFm_rf_ijm = zeros(npn,nmhu);
%	
% D and F tensors
% 
	XDpp_ippj = XDpp_c_ippj + XDpp_e_ippj + XDpp_rf_ippj;
	XDpp_ipj = XDpp_c_ipj + XDpp_e_ipj + XDpp_rf_ipj;
	XDpp_ij = XDpp_c_ij + XDpp_e_ij + XDpp_rf_ij;
	XDpp_imj = XDpp_c_imj + XDpp_e_imj + XDpp_rf_imj;
	XDpp_immj = XDpp_c_immj + XDpp_e_immj + XDpp_rf_immj;
%
	XDpm_ipj = XDpm_c_ipj + XDpm_e_ipj + XDpm_rf_ipj;
	XDpm_ij = XDpm_c_ij + XDpm_e_ij + XDpm_rf_ij;
	XDpm_imj = XDpm_c_imj + XDpm_e_imj + XDpm_rf_imj;
%
	XDmp_ijp = XDmp_c_ijp + XDmp_e_ijp + XDmp_rf_ijp;
	XDmp_ij = XDmp_c_ij + XDmp_e_ij + XDmp_rf_ij;
	XDmp_ijm = XDmp_c_ijm + XDmp_e_ijm + XDmp_rf_ijm;
%
	XDmm_ijp = XDmm_c_ijp + XDmm_e_ijp + XDmm_rf_ijp;
	XDmm_ijm = XDmm_c_ijm + XDmm_e_ijm + XDmm_rf_ijm;
%
	XFp_ippj = XFp_c_ippj + XFp_e_ippj + XFp_rf_ippj;
	XFp_ipj = XFp_c_ipj + XFp_e_ipj + XFp_rf_ipj;
	XFp_ij = XFp_c_ij + XFp_e_ij + XFp_rf_ij;
	XFp_imj = XFp_c_imj + XFp_e_imj + XFp_rf_imj;
	XFp_immj = XFp_c_immj + XFp_e_immj + XFp_rf_immj;
%
	XFm_ijp = XFm_c_ijp + XFm_e_ijp + XFm_rf_ijp;
	XFm_ijm = XFm_c_ijm + XFm_e_ijm + XFm_rf_ijm;
%
%Momentum weights calculations (for f0 and ftp also)
%
%
	[Xdeltap_imj,Xdeltap_ipj,...
		 Xdeltam_ijm,Xdeltam_ijp] = ...
		 fppgridweights_dke_yp(Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
       Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
		 XDpp_ippj,XDpp_ipj,XDpp_ij,XDpp_imj,XDpp_immj,...
		 XFp_ippj,XFp_ipj,XFp_ij,XFp_imj,XFp_immj);
%
	XXdeltap_imj(:,:,ir) = Xdeltap_imj; 
	XXdeltap_ipj(:,:,ir) = Xdeltap_ipj;
	XXdeltam_ijp(:,:,ir) = Xdeltam_ijp;
	XXdeltam_ijm(:,:,ir) = Xdeltam_ijm;		
%
	if display_mode == 2,
		figure(3100),plot(pn,Xdeltap_imj(:,:));hold on
		zoom on;
		axis('square');xlabel('pn');ylabel('Interpolation coefficient');
		title('Momentum flux grid interpolation factor');
		pause(time_pause);
   end
%
%Momentum dynamics matrix coefficients calculations
%	
	[XXa(:,:,ir),XXb(:,:,ir),XXc(:,:,ir),XXd(:,:,ir),XXe(:,:,ir),XXf(:,:,ir),XXg(:,:,ir),XXh(:,:,ir),XXi(:,:,ir)] = ...
  	fpengine_dke_yp(0,...
	XXdeltap_imj(:,:,ir),XXdeltap_ipj(:,:,ir),XXdeltam_ijm(:,:,ir),XXdeltam_ijp(:,:,ir),...
	XXRlambda_m(:,:,ir),XXRlambda_p(:,:,ir),...
	Xpnmm,Xpnm,Xpn,Xpnp,Xpnpp,Xpn2m,Xpn2p,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
	Xmhumm,Xmhum,Xmhu,Xmhup,Xmhupp,X1mmhu2,X1mmhu2m,X1mmhu2p,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
	XDpp_ippj,XDpp_ipj,XDpp_ij,XDpp_imj,XDpp_immj,...
	XDpm_ipj,XDpm_ij,XDpm_imj,...
	XDmp_ijp,XDmp_ij,XDmp_ijm,...
	XDmm_ijp,XDmm_ijm,...
	XFp_ippj,XFp_ipj,XFp_ij,XFp_imj,XFp_immj,...
	XFm_ijp,XFm_ijm);
% 
%Loss matrix coefficients (for magnetic ripple losses but may be used for other effects if necessary)
%
	XXc(:,:,ir) = XXc(:,:,ir) + XXnhuloss(:,:,ir).*Xpn2;
%
%Boundaries of the bounce domain for f0
%	
	XXc(:,1,ir) = XXc(:,1,ir) + XXa(:,1,ir);%Because of cross-derivatives
	XXd(:,1,ir) = XXd(:,1,ir) + XXi(:,1,ir);%Because of cross-derivatives
	XXb(:,1,ir) = XXb(:,1,ir) + XXf(:,1,ir);%Because of cross-derivatives
%
	XXa(:,1,ir) = 0;%Because of cross-derivatives
	XXi(:,1,ir) = 0;%Because of cross-derivatives
	XXf(:,1,ir) = 0;%Because of cross-derivatives
%
	XXc(:,nmhu,ir) = XXc(:,nmhu,ir) + XXe(:,nmhu,ir);%Because of cross-derivatives
	XXd(:,nmhu,ir) = XXd(:,nmhu,ir) + XXg(:,nmhu,ir);%Because of cross-derivatives
	XXb(:,nmhu,ir) = XXb(:,nmhu,ir) + XXh(:,nmhu,ir);%Because of cross-derivatives
%
	XXe(:,nmhu,ir) = 0;%Because of cross-derivatives
	XXg(:,nmhu,ir) = 0;%Because of cross-derivatives
	XXh(:,nmhu,ir) = 0;%Because of cross-derivatives
%
	XXc(1,:,ir) = XXc(1,:,ir) + fliplr(XXb(1,:,ir));%Because of cross-derivatives
	XXa(1,:,ir) = XXa(1,:,ir) + fliplr(XXf(1,:,ir));%Because of cross-derivatives
	XXe(1,:,ir) = XXe(1,:,ir) + fliplr(XXh(1,:,ir));%Because of cross-derivatives
%
	XXb(1,:,ir) = 0;%Because of cross-derivatives
	XXh(1,:,ir) = 0;%Because of cross-derivatives
	XXf(1,:,ir) = 0;%Because of cross-derivatives
%	
	if bounce_mode == 0,%No bounce averaging
		Xa_t = XXa(:,:,ir);
		Xb_t = XXb(:,:,ir);
		Xc_t = XXc(:,:,ir);
		Xd_t = XXd(:,:,ir);
		Xe_t = XXe(:,:,ir);
		Xf_t = XXf(:,:,ir);
		Xg_t = XXg(:,:,ir);
		Xh_t = XXh(:,:,ir);
		Xi_t = XXi(:,:,ir);              
		mhu_t = mhu;
		Xpn2_t = Xpn2;
	elseif bounce_mode == 1,%Full implicit bounce-averaging calculations, fifteen diagonals mode
		if djmhut(ir) > 3,%At least three points needed in the bounce domain
			Xa_t = zeros(npn,nmhu - djmhut(ir));
			Xb_t = zeros(npn,nmhu - djmhut(ir));
			Xc_t = zeros(npn,nmhu - djmhut(ir));
			Xd_t = zeros(npn,nmhu - djmhut(ir));
			Xe_t = zeros(npn,nmhu - djmhut(ir));
			Xf_t = zeros(npn,nmhu - djmhut(ir));
			Xg_t = zeros(npn,nmhu - djmhut(ir));
			Xh_t = zeros(npn,nmhu - djmhut(ir));
			Xi_t = zeros(npn,nmhu - djmhut(ir));
			Xj_t = zeros(npn,nmhu - djmhut(ir));
			Xk_t = zeros(npn,nmhu - djmhut(ir));
			Xl_t = zeros(npn,nmhu - djmhut(ir));
			Xm_t = zeros(npn,nmhu - djmhut(ir));
			Xn_t = zeros(npn,nmhu - djmhut(ir));
			Xo_t = zeros(npn,nmhu - djmhut(ir));
%
			Xa_t(:,Zmask_f0_t_P{ir}) = XXa(:,Zmask_f0_P{ir},ir);
			Xb_t(:,Zmask_f0_t_P{ir}) = XXb(:,Zmask_f0_P{ir},ir);
			Xc_t(:,Zmask_f0_t_P{ir}) = XXc(:,Zmask_f0_P{ir},ir);
			Xd_t(:,Zmask_f0_t_P{ir}) = XXd(:,Zmask_f0_P{ir},ir);
			Xe_t(:,Zmask_f0_t_P{ir}) = XXe(:,Zmask_f0_P{ir},ir);
			Xf_t(:,Zmask_f0_t_P{ir}) = XXf(:,Zmask_f0_P{ir},ir);
			Xg_t(:,Zmask_f0_t_P{ir}) = XXg(:,Zmask_f0_P{ir},ir);
			Xh_t(:,Zmask_f0_t_P{ir}) = XXh(:,Zmask_f0_P{ir},ir);
			Xi_t(:,Zmask_f0_t_P{ir}) = XXi(:,Zmask_f0_P{ir},ir);
%
%Symmetrization of the trapped region
%
			Xa_t(:,Zmask_f0_t_Tp{ir}) = (XXa(:,Zmask_f0_Tp{ir},ir) + fliplr(XXe(:,Zmask_f0_Tm{ir},ir)))/2;
			Xb_t(:,Zmask_f0_t_Tp{ir}) = (XXb(:,Zmask_f0_Tp{ir},ir) + fliplr(XXb(:,Zmask_f0_Tm{ir},ir)))/2;
			Xc_t(:,Zmask_f0_t_Tp{ir}) = (XXc(:,Zmask_f0_Tp{ir},ir) + fliplr(XXc(:,Zmask_f0_Tm{ir},ir)))/2;
			Xd_t(:,Zmask_f0_t_Tp{ir}) = (XXd(:,Zmask_f0_Tp{ir},ir) + fliplr(XXd(:,Zmask_f0_Tm{ir},ir)))/2;
			Xe_t(:,Zmask_f0_t_Tp{ir}) = (XXe(:,Zmask_f0_Tp{ir},ir) + fliplr(XXa(:,Zmask_f0_Tm{ir},ir)))/2;
			Xf_t(:,Zmask_f0_t_Tp{ir}) = (XXf(:,Zmask_f0_Tp{ir},ir) + fliplr(XXh(:,Zmask_f0_Tm{ir},ir)))/2;
			Xg_t(:,Zmask_f0_t_Tp{ir}) = (XXg(:,Zmask_f0_Tp{ir},ir) + fliplr(XXi(:,Zmask_f0_Tm{ir},ir)))/2;
			Xh_t(:,Zmask_f0_t_Tp{ir}) = (XXh(:,Zmask_f0_Tp{ir},ir) + fliplr(XXf(:,Zmask_f0_Tm{ir},ir)))/2;
			Xi_t(:,Zmask_f0_t_Tp{ir}) = (XXi(:,Zmask_f0_Tp{ir},ir) + fliplr(XXg(:,Zmask_f0_Tm{ir},ir)))/2;
%
			Xh_t(:,jmhut_max(ir) - djmhut(ir)) = Xh_t(:,jmhut_max(ir) - djmhut(ir))/2;
			Xe_t(:,jmhut_max(ir) - djmhut(ir)) = Xe_t(:,jmhut_max(ir) - djmhut(ir))/2;
			Xg_t(:,jmhut_max(ir) - djmhut(ir)) = Xg_t(:,jmhut_max(ir) - djmhut(ir))/2;
%
			Xj_t(:,jmhut_max(ir) - djmhut(ir)) = Xh_t(:,jmhut_max(ir) - djmhut(ir));%f0(i-1/2,j+1/2-djmhut) 
			Xk_t(:,jmhut_max(ir) - djmhut(ir)) = Xe_t(:,jmhut_max(ir) - djmhut(ir));%f0(i+1/2,j+1/2-djmhut)
			Xl_t(:,jmhut_max(ir) - djmhut(ir)) = Xg_t(:,jmhut_max(ir) - djmhut(ir));%f0(i+3/2,j+1/2-djmhut)
%
			Xm_t(:,jmhut_min(ir) - 1) = XXh(:,jmhut_min(ir) - 1,ir);%f0(i-1/2,j+1/2+djmhut)
			Xn_t(:,jmhut_min(ir) - 1) = XXe(:,jmhut_min(ir) - 1,ir);%f0(i+1/2,j+1/2+djmhut)
			Xo_t(:,jmhut_min(ir) - 1) = XXg(:,jmhut_min(ir) - 1,ir);%f0(i+3/2,j+1/2+djmhut)
%   
			Xh_t(:,jmhut_min(ir) - 1) = 0;
			Xe_t(:,jmhut_min(ir) - 1) = 0;
			Xg_t(:,jmhut_min(ir) - 1) = 0;
%
			Xa_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xb_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xc_t(:,nmhu/2 + 1 - djmhut(ir)) = 1;%df0(pn,mhu=pi/2) = 0
			Xd_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xe_t(:,nmhu/2 + 1 - djmhut(ir)) = -1;%df0(pn,mhu=pi/2) = 0
			Xf_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xg_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xh_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xi_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xj_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xk_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xl_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xm_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xn_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
			Xo_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0
%       
			mhu_t = mhu(Zmask_f0_t{ir});			
			Xpn2_t = Xpn2(:,Zmask_f0_t{ir});
			
		else
			error(['WARNING: Not enough grid point in the bounce region for accurate bounce-averaged calculations at psin = ',num2str(xpsin(ir)),' !'])
		end
	end
%
%Local boundary conditions at p = p(1/2): not necessary but help for the density conservation (Dirichlet boundary condition)
%
	if boundary_mode_f > 0,
		Xa_t(1:boundary_mode_f,:) = 0;
		Xb_t(1:boundary_mode_f,:) = 0;
		Xc_t(1:boundary_mode_f,:) = 0;%Maxwellian solution enforced at p = p(1/2 -> boundary_mode_f-1/2) (More accurate but not fully necessary)
		Xd_t(1:boundary_mode_f,:) = 0;
		Xe_t(1:boundary_mode_f,:) = 0;
		Xf_t(1:boundary_mode_f,:) = 0;
		Xg_t(1:boundary_mode_f,:) = 0;
		Xh_t(1:boundary_mode_f,:) = 0;
		Xi_t(1:boundary_mode_f,:) = 0;
		if bounce_mode == 1,
			Xj_t(1:boundary_mode_f,:) = 0;
			Xk_t(1:boundary_mode_f,:) = 0;
			Xl_t(1:boundary_mode_f,:) = 0;
			Xm_t(1:boundary_mode_f,:) = 0;
			Xn_t(1:boundary_mode_f,:) = 0;
			Xo_t(1:boundary_mode_f,:) = 0;   
%
			Xpn2_t(boundary_mode_f+1:npn,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0 only for p values where the Maxwellian solution is not enforced
		end 
	else
		if bounce_mode == 1,
			Xpn2_t(:,nmhu/2 + 1 - djmhut(ir)) = 0;%df0(pn,mhu=pi/2) = 0	
		end
	end
%
	Zpn2_t{ir} = Xpn2_t;	
%
%Momentum flux matrix calculation
%
	if bounce_mode == 0,
		MXc = reshape(Xc_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXc,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
		MXa = reshape(Xa_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-1],MXa(1+1:length(MXa)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
		MXe = reshape(Xe_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-1],[1+1:(nmhu-ns_f(ir))*npn],MXe(1:length(MXe)-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);       
		MXb = reshape(Xb_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],MXb(1+(nmhu-ns_f(ir)):length(MXb)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
		MXd = reshape(Xd_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],[1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],MXd(1:length(MXd)-(nmhu-ns_f(ir))),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
		MXf = reshape(Xf_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],MXf(1+(nmhu-ns_f(ir))+1:length(MXf)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXh = reshape(Xh_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],MXh(1+(nmhu-ns_f(ir))-1:length(MXh)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXi = reshape(Xi_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],[1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],MXi(1:length(MXi)-(nmhu-ns_f(ir))+1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXg = reshape(Xg_t',(nmhu-ns_f(ir))*npn,1);
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],[1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],MXg(1:length(MXg)-(nmhu-ns_f(ir))-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
	elseif bounce_mode == 1,
		MXc = reshape(Xc_t',(nmhu-ns_f(ir))*npn,1);%c(i+1/2,j+1/2)
		MXP_f_t = sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXc,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
		MXa = reshape(Xa_t',(nmhu-ns_f(ir))*npn,1);%a(i+1/2,j-1/2)
		MXP_f_t = MXP_f_t + sparse([1+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-1],MXa(1+1:length(MXa)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);
		MXe = reshape(Xe_t',(nmhu-ns_f(ir))*npn,1);%e(i+1/2,j+3/2)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-1],[1+1:(nmhu-ns_f(ir))*npn],MXe(1:length(MXe)-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
		MXj = reshape(Xj_t',(nmhu-ns_f(ir))*npn,1);%j(i-1/2,j+1/2-djmhut) 
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))+djmhut(ir):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-djmhut(ir)],MXj(1+(nmhu-ns_f(ir))+djmhut(ir):length(MXj)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);              
		MXk = reshape(Xk_t',(nmhu-ns_f(ir))*npn,1);%k(i+1/2,j+1/2-djmhut)
		MXP_f_t = MXP_f_t + sparse([1+djmhut(ir):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-djmhut(ir)],MXk(1+djmhut(ir):length(MXk)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);        
		MXl = reshape(Xl_t',(nmhu-ns_f(ir))*npn,1);%l(i+3/2,j+1/2-djmhut)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+djmhut(ir)],[1+(nmhu-ns_f(ir))-djmhut(ir):(nmhu-ns_f(ir))*npn],MXl(1:length(MXl)-(nmhu-ns_f(ir))+djmhut(ir)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);      
		MXf = reshape(Xf_t',(nmhu-ns_f(ir))*npn,1);%f(i-1/2,j-1/2)
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],MXf(1+(nmhu-ns_f(ir))+1:length(MXf)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXb = reshape(Xb_t',(nmhu-ns_f(ir))*npn,1);%b(i-1/2,j+1/2)
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],MXb(1+(nmhu-ns_f(ir)):length(MXb)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);           
		MXh = reshape(Xh_t',(nmhu-ns_f(ir))*npn,1);%h(i-1/2,j+3/2)
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],MXh(1+(nmhu-ns_f(ir))-1:length(MXh)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXi = reshape(Xi_t',(nmhu-ns_f(ir))*npn,1);%i(i+3/2,j-1/2)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+1],[1+(nmhu-ns_f(ir))-1:(nmhu-ns_f(ir))*npn],MXi(1:length(MXi)-(nmhu-ns_f(ir))+1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXd = reshape(Xd_t',(nmhu-ns_f(ir))*npn,1);%d(i+3/2,j+1/2)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))],[1+(nmhu-ns_f(ir)):(nmhu-ns_f(ir))*npn],MXd(1:length(MXd)-(nmhu-ns_f(ir))),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);                   
		MXg = reshape(Xg_t',(nmhu-ns_f(ir))*npn,1);%g(i+3/2,j+3/2)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-1],[1+(nmhu-ns_f(ir))+1:(nmhu-ns_f(ir))*npn],MXg(1:length(MXg)-(nmhu-ns_f(ir))-1),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);     
		MXm = reshape(Xm_t',(nmhu-ns_f(ir))*npn,1);%m(i-1/2,j+1/2+djmhut)
		MXP_f_t = MXP_f_t + sparse([1+(nmhu-ns_f(ir))-djmhut(ir):(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))+djmhut(ir)],MXm(1+(nmhu-ns_f(ir))-djmhut(ir):length(MXm)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);      
		MXn = reshape(Xn_t',(nmhu-ns_f(ir))*npn,1);%n(i+1/2,j+1/2+djmhut)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-djmhut(ir)],[1+djmhut(ir):(nmhu-ns_f(ir))*npn],MXn(1:length(MXn)-djmhut(ir)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);        
		MXo = reshape(Xo_t',(nmhu-ns_f(ir))*npn,1);%o(i+3/2,j+1/2+djmhut)
		MXP_f_t = MXP_f_t + sparse([1:(nmhu-ns_f(ir))*npn-(nmhu-ns_f(ir))-djmhut(ir)],[1+(nmhu-ns_f(ir))+djmhut(ir):(nmhu-ns_f(ir))*npn],MXo(1:length(MXo)-(nmhu-ns_f(ir))-djmhut(ir)),(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);      
	end
%
	MXP_f_t = (xqtilde(ir)/xB0(ir))*MXP_f_t;%Partial Jacobian multiplication to avoid numerical singularities at p = 0	
%    
	sm_f(ir+1) = sm_f(ir) + blocksize_f_t(ir);
	[i0_f,j0_f,s0_f] = find(MMXP_f_t);		
	[m0_f,n0_f] = size(MMXP_f_t);
	[i1_f,j1_f,s1_f] = find(MXP_f_t);
	[m1_f,n1_f] = size(MXP_f_t);
	MMXP_f_t = sparse(i0_f,j0_f,s0_f,m0_f+m1_f,m0_f+m1_f) + sparse(m0_f+i1_f,m0_f+j1_f,s1_f,m0_f+m1_f,m0_f+m1_f);
%
%Time diagonal matrix calculation
%	
	MXT = reshape(Zpn2_t{ir}',(nmhu-ns_f(ir))*npn,1)/dtn;%Partial momentum Jacobian 
	MXT_f_t = (xqtilde(ir)/xB0(ir))*sparse([1:(nmhu-ns_f(ir))*npn],[1:(nmhu-ns_f(ir))*npn],MXT,(nmhu-ns_f(ir))*npn,(nmhu-ns_f(ir))*npn);%Resizing for 3D calculations + multiplication by the remaining Jacobian
%	
	sm_T_f(ir+1) = sm_T_f(ir) + blocksize_T_f_t(ir);
	[i0_T_f,j0_T_f,s0_T_f] = find(MMXT_f_t);		
	[m0_T_f,n0_T_f] = size(MMXT_f_t);
	[i1_T_f,j1_T_f,s1_T_f] = find(MXT_f_t);
	[m1_T_f,n1_T_f] = size(MXT_f_t);
	MMXT_f_t = sparse(i0_T_f,j0_T_f,s0_T_f,m0_T_f+m1_T_f,m0_T_f+m1_T_f) + sparse(m0_T_f+i1_T_f,m0_T_f+j1_T_f,s1_T_f,m0_T_f+m1_T_f,m0_T_f+m1_T_f);	
%	
	etime_fp = etime_fp + etime(clock,time0);
	time0 = clock;
end
%
if display_mode >= 1,info_dke_yp(2,['Zero order momentum space matrix calculations done in ',num2str(etime_fp),' (s)']);end
%
% Drift kinetic calculations
%
etime_dke = 0;
time0 = clock;
%
if dke_mode == 1,
	for ir_dke = 1:nr_dke,
%
		jr1 = rdke(ir_dke)-1;
		jr2 = rdke(ir_dke);
		jr3 = rdke(ir_dke)+1;
%
%Matrix coefficients calculations for ftp
%	
% Collisions
%
		XDpp_c_tp_ippj = (XXAeepp(:,:,jr2) + XXAeipp(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XDpp_c_tp_ipj = (XXAeep(:,:,jr2) + XXAeip(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XDpp_c_tp_ij = (XXAee(:,:,jr2) + XXAei(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XDpp_c_tp_imj = (XXAeem(:,:,jr2) + XXAeim(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XDpp_c_tp_immj = (XXAeemm(:,:,jr2) + XXAeimm(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
%
		XDpm_c_tp_ipj = zeros(npn,nmhu);
		XDpm_c_tp_ij = zeros(npn,nmhu);
		XDpm_c_tp_imj = zeros(npn,nmhu);
%
		XDmp_c_tp_ijp = zeros(npn,nmhu);
		XDmp_c_tp_ij = zeros(npn,nmhu);
		XDmp_c_tp_ijm = zeros(npn,nmhu);
%
		XDmm_c_tp_ijp = (XXBtee(:,:,jr2) + XXBtei(:,:,jr2)).*XXRlambda_b_p3m2_p(:,:,jr2);
		XDmm_c_tp_ijm = (XXBtee(:,:,jr2) + XXBtei(:,:,jr2)).*XXRlambda_b_p3m2_m(:,:,jr2);
%
		XFp_c_tp_ippj = -(XXFeepp(:,:,jr2) + XXFeipp(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XFp_c_tp_ipj = -(XXFeep(:,:,jr2) + XXFeip(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XFp_c_tp_ij = -(XXFee(:,:,jr2) + XXFei(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XFp_c_tp_imj = -(XXFeem(:,:,jr2) + XXFeim(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);
		XFp_c_tp_immj = -(XXFeemm(:,:,jr2) + XXFeimm(:,:,jr2)).*XXRlambda_b_p1m1(:,:,jr2);	
%
		XFm_c_tp_ijp = (XXBtee(:,:,jr2) + XXBtei(:,:,jr2)).*(XXRlambda_b_p1m1_p(:,:,jr2) - XXRlambda_b_p1m2_p(:,:,jr2)).*sqrt(X1mmhu2p)./Xpn./Xmhu2p./Xmhup;
		XFm_c_tp_ijm = (XXBtee(:,:,jr2) + XXBtei(:,:,jr2)).*(XXRlambda_b_p1m1_m(:,:,jr2) - XXRlambda_b_p1m2_m(:,:,jr2)).*sqrt(X1mmhu2m)./Xpn./Xmhu2m./Xmhum;
%    
		XXDpp_c_tp_imj(:,:,jr2) = XDpp_c_tp_imj;
		XXDpm_c_tp_imj(:,:,jr2) = XDpm_c_tp_imj;
		XXFp_c_tp_imj(:,:,jr2) = XFp_c_tp_imj;
		
		XXDpp_c_tp_ipj(:,:,jr2) = XDpp_c_tp_ipj;
		XXDpm_c_tp_ipj(:,:,jr2) = XDpm_c_tp_ipj;
		XXFp_c_tp_ipj(:,:,jr2) = XFp_c_tp_ipj;
%
		XXDmm_c_tp_ijm(:,:,jr2) = XDmm_c_tp_ijm;
		XXDmp_c_tp_ijm(:,:,jr2) = XDmp_c_tp_ijm;
		XXFm_c_tp_ijm(:,:,jr2) = XFm_c_tp_ijm;
		XXDmm_c_tp_ijp(:,:,jr2) = XDmm_c_tp_ijp;
		XXDmp_c_tp_ijp(:,:,jr2) = XDmp_c_tp_ijp;
		XXFm_c_tp_ijp(:,:,jr2) = XFm_c_tp_ijp;
%	
% Electric field
%
		XDpp_e_tp_ippj = zeros(npn,nmhu);
		XDpp_e_tp_ipj = zeros(npn,nmhu);
		XDpp_e_tp_ij = zeros(npn,nmhu); 	
		XDpp_e_tp_imj = zeros(npn,nmhu);
		XDpp_e_tp_immj = zeros(npn,nmhu);
%	
		XDpm_e_tp_ipj = zeros(npn,nmhu);
		XDpm_e_tp_ij = zeros(npn,nmhu);
		XDpm_e_tp_imj = zeros(npn,nmhu);
%
		XDmp_e_tp_ijp = zeros(npn,nmhu);
		XDmp_e_tp_ij = zeros(npn,nmhu);
		XDmp_e_tp_ijm = zeros(npn,nmhu);
%
		XDmm_e_tp_ijp = zeros(npn,nmhu);
		XDmm_e_tp_ijm = zeros(npn,nmhu);
%
		XFp_e_tp_ippj = +Xmhu.*XXRlambda_b_p2m2p2(:,:,jr2)*xepsi(jr2);
		XFp_e_tp_ipj = +Xmhu.*XXRlambda_b_p2m2p2(:,:,jr2)*xepsi(jr2);
		XFp_e_tp_ij = +Xmhu.*XXRlambda_b_p2m2p2(:,:,jr2)*xepsi(jr2);	
		XFp_e_tp_imj = +Xmhu.*XXRlambda_b_p2m2p2(:,:,jr2)*xepsi(jr2);
		XFp_e_tp_immj = +Xmhu.*XXRlambda_b_p2m2p2(:,:,jr2)*xepsi(jr2);
%
		XFm_e_tp_ijp = -sqrt(X1mmhu2p).*XXRlambda_b_p2m2p2_p(:,:,jr2)*xepsi(jr2);
		XFm_e_tp_ijm = -sqrt(X1mmhu2m).*XXRlambda_b_p2m2p2_m(:,:,jr2)*xepsi(jr2);
%
		XXDpp_e_tp_imj(:,:,jr2) = XDpp_e_tp_imj;
		XXDpm_e_tp_imj(:,:,jr2) = XDpm_e_tp_imj;
		XXFp_e_tp_imj(:,:,jr2) = XFp_e_tp_imj;
		XXDpp_e_tp_ipj(:,:,jr2) = XDpp_e_tp_ipj;
		XXDpm_e_tp_ipj(:,:,jr2) = XDpm_e_tp_ipj;
		XXFp_e_tp_ipj(:,:,jr2) = XFp_e_tp_ipj;

		XXDmm_e_tp_ijm(:,:,jr2) = XDmm_e_tp_ijm;
		XXDmp_e_tp_ijm(:,:,jr2) = XDmp_e_tp_ijm;
		XXFm_e_tp_ijm(:,:,jr2) = XFm_e_tp_ijm;
		XXDmm_e_tp_ijp(:,:,jr2) = XDmm_e_tp_ijp;
		XXDmp_e_tp_ijp(:,:,jr2) = XDmp_e_tp_ijp;
		XXFm_e_tp_ijp(:,:,jr2) = XFm_e_tp_ijp;
%
% RF waves
%
%
		XDpp_rf_tp_ippj = XXDpp_rf_tp_ippj(:,:,jr2);
		XDpp_rf_tp_ipj = XXDpp_rf_tp_ipj(:,:,jr2);
		XDpp_rf_tp_ij = XXDpp_rf_tp_ij(:,:,jr2);
		XDpp_rf_tp_imj = XXDpp_rf_tp_imj(:,:,jr2);
		XDpp_rf_tp_immj = XXDpp_rf_tp_immj(:,:,jr2);
%	
		XDpm_rf_tp_ipj = XXDpm_rf_tp_ipj(:,:,jr2);
		XDpm_rf_tp_ij = XXDpm_rf_tp_ij(:,:,jr2);	
		XDpm_rf_tp_imj = XXDpm_rf_tp_imj(:,:,jr2);

		XDmp_rf_tp_ijp = XXDmp_rf_tp_ijp(:,:,jr2);
		XDmp_rf_tp_ij = XXDmp_rf_tp_ij(:,:,jr2);
		XDmp_rf_tp_ijm = XXDmp_rf_tp_ijm(:,:,jr2);
%	
		XDmm_rf_tp_ijp = XXDmm_rf_tp_ijp(:,:,jr2);
		XDmm_rf_tp_ijm = XXDmm_rf_tp_ijm(:,:,jr2);
%
		XFp_rf_tp_ippj = XXFp_rf_tp_ippj(:,:,jr2);
		XFp_rf_tp_ipj = XXFp_rf_tp_ipj(:,:,jr2);
		XFp_rf_tp_ij = XXFp_rf_tp_ij(:,:,jr2);
		XFp_rf_tp_imj = XXFp_rf_tp_imj(:,:,jr2);
		XFp_rf_tp_immj = XXFp_rf_tp_immj(:,:,jr2);
%
		XFm_rf_tp_ijp = XXFm_rf_tp_ijp(:,:,jr2);
		XFm_rf_tp_ijm = XXFm_rf_tp_ijm(:,:,jr2);
%	
% D and F tensors
% 
		XDpp_tp_ippj = XDpp_c_tp_ippj + XDpp_e_tp_ippj + XDpp_rf_tp_ippj;
		XDpp_tp_ipj = XDpp_c_tp_ipj + XDpp_e_tp_ipj + XDpp_rf_tp_ipj;
		XDpp_tp_ij = XDpp_c_tp_ij + XDpp_e_tp_ij + XDpp_rf_tp_ij;
		XDpp_tp_imj = XDpp_c_tp_imj + XDpp_e_tp_imj + XDpp_rf_tp_imj;
		XDpp_tp_immj = XDpp_c_tp_immj + XDpp_e_tp_immj + XDpp_rf_tp_immj;
%
		XDpm_tp_ipj = XDpm_c_tp_ipj + XDpm_e_tp_ipj + XDpm_rf_tp_ipj;
		XDpm_tp_ij = XDpm_c_tp_ij + XDpm_e_tp_ij + XDpm_rf_tp_ij;
		XDpm_tp_imj = XDpm_c_tp_imj + XDpm_e_tp_imj + XDpm_rf_tp_imj;
%
		XDmp_tp_ijp = XDmp_c_tp_ijp + XDmp_e_tp_ijp + XDmp_rf_tp_ijp;
		XDmp_tp_ij = XDmp_c_tp_ij + XDmp_e_tp_ij + XDmp_rf_tp_ij;
		XDmp_tp_ijm = XDmp_c_tp_ijm + XDmp_e_tp_ijm + XDmp_rf_tp_ijm;
%
		XDmm_tp_ijp = XDmm_c_tp_ijp + XDmm_e_tp_ijp + XDmm_rf_tp_ijp;
		XDmm_tp_ijm = XDmm_c_tp_ijm + XDmm_e_tp_ijm + XDmm_rf_tp_ijm;
%
		XFp_tp_ippj = XFp_c_tp_ippj + XFp_e_tp_ippj + XFp_rf_tp_ippj;
		XFp_tp_ipj = XFp_c_tp_ipj + XFp_e_tp_ipj + XFp_rf_tp_ipj;
		XFp_tp_ij = XFp_c_tp_ij + XFp_e_tp_ij + XFp_rf_tp_ij;
		XFp_tp_imj = XFp_c_tp_imj + XFp_e_tp_imj + XFp_rf_tp_imj;
		XFp_tp_immj = XFp_c_tp_immj + XFp_e_tp_immj + XFp_rf_tp_immj;
%
		XFm_tp_ijp = XFm_c_tp_ijp + XFm_e_tp_ijp + XFm_rf_tp_ijp;
		XFm_tp_ijm = XFm_c_tp_ijm + XFm_e_tp_ijm + XFm_rf_tp_ijm;
%
		[Xa_tp,Xb_tp,Xc_tp,Xd_tp,Xe_tp,Xf_tp,Xg_tp,Xh_tp,Xi_tp] = ...
		    fpengine_dke_yp(1,...
		    XXdeltap_imj(:,:,jr2),XXdeltap_ipj(:,:,jr2),XXdeltam_ijm(:,:,jr2),XXdeltam_ijp(:,:,jr2),...
		    XXRlambda_m(:,:,jr2),XXRlambda_p(:,:,jr2),...
		    Xpnmm,Xpnm,Xpn,Xpnp,Xpnpp,Xpn2m,Xpn2p,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
		    Xmhumm,Xmhum,Xmhu,Xmhup,Xmhupp,X1mmhu2,X1mmhu2m,X1mmhu2p,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
		    XDpp_tp_ippj,XDpp_tp_ipj,XDpp_tp_ij,XDpp_tp_imj,XDpp_tp_immj,...
		    XDpm_tp_ipj,XDpm_tp_ij,XDpm_tp_imj,...
		    XDmp_tp_ijp,XDmp_tp_ij,XDmp_tp_ijm,...
		    XDmm_tp_ijp,XDmm_tp_ijm,...
		    XFp_tp_ippj,XFp_tp_ipj,XFp_tp_ij,XFp_tp_imj,XFp_tp_immj,...
		    XFm_tp_ijp,XFm_tp_ijm); 
%
%Boundary conditions because of cross-derivatives (symmetry of f: fj-1/2=fj+1/2)
%
		Xc_tp(:,1) = Xc_tp(:,1) + Xa_tp(:,1);
		Xd_tp(:,1) = Xd_tp(:,1) + Xi_tp(:,1);
		Xb_tp(:,1) = Xb_tp(:,1) + Xf_tp(:,1);

		Xa_tp(:,1) = 0;
		Xi_tp(:,1) = 0;
		Xf_tp(:,1) = 0;

		Xc_tp(:,nmhu) = Xc_tp(:,nmhu) + Xe_tp(:,nmhu);
		Xd_tp(:,nmhu) = Xd_tp(:,nmhu) + Xg_tp(:,nmhu);
		Xb_tp(:,nmhu) = Xb_tp(:,nmhu) + Xh_tp(:,nmhu);

		Xe_tp(:,nmhu) = 0;
		Xg_tp(:,nmhu) = 0;
		Xh_tp(:,nmhu) = 0;

		Xc_tp(1,:) = Xc_tp(1,:) + fliplr(Xb_tp(1,:));
		Xa_tp(1,:) = Xa_tp(1,:) + fliplr(Xf_tp(1,:));
		Xe_tp(1,:) = Xe_tp(1,:) + fliplr(Xh_tp(1,:));

		Xb_tp(1,:) = 0;
		Xh_tp(1,:) = 0;
		Xf_tp(1,:) = 0;
%
%Correction matrix resulting from the radial gradient of Chang and Cooper interpolation coefficients
%           		
		dpsim = (xpsin(jr1) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)
		dpsi = (xpsin(jr3) - xpsin(jr1));%Radial step for parabolic gradient calculations (dke)
		dpsip = (xpsin(jr3) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)      
%					 		
		XXH_tp_mm(:,:,jr1) = (xftp_norm(jr2)*dpsip/dpsi/dpsim)*(XXdeltap_imj(:,:,jr2) - XXdeltap_imj(:,:,jr1)).*XFp_tp_imj.*Xmhu.*Xpn2m.*Xpnm./Xdpn;
		XXH_tp_mp(:,:,jr1) = (xftp_norm(jr2)*dpsip/dpsi/dpsim)*(XXdeltap_ipj(:,:,jr2) - XXdeltap_ipj(:,:,jr1)).*XFp_tp_ipj.*Xmhu.*Xpn2p.*Xpnp./Xdpn;
		XXH_tp_m(:,:,jr1) = -XXH_tp_mm(:,:,jr1) - XXH_tp_mp(:,:,jr1);
%
		XXH_tp_pm(:,:,jr3) = -(xftp_norm(jr2)*dpsim/dpsi/dpsip)*(XXdeltap_imj(:,:,jr2) - XXdeltap_imj(:,:,jr3)).*XFp_tp_imj.*Xmhu.*Xpn2m.*Xpnm./Xdpn;
		XXH_tp_pp(:,:,jr3) = -(xftp_norm(jr2)*dpsim/dpsi/dpsip)*(XXdeltap_ipj(:,:,jr2) - XXdeltap_ipj(:,:,jr3)).*XFp_tp_ipj.*Xmhu.*Xpn2p.*Xpnp./Xdpn;		
		XXH_tp_p(:,:,jr3) = -XXH_tp_pm(:,:,jr3) - XXH_tp_pp(:,:,jr3);
%
%Matrix coefficients calculations for g
%
		Xa_g = XXa(:,:,jr2);%g(i+1/2,j-1/2)
		Xb_g = XXb(:,:,jr2);%g(i-1/2,j+1/2)
		Xc_g = XXc(:,:,jr2);%g(i+1/2,j+1/2) (Since matrix coefficients for f0 and g are the same)
		Xd_g = XXd(:,:,jr2);%g(i+3/2,j+1/2)
		Xe_g = XXe(:,:,jr2);%g(i+1/2,j+3/2)
		Xf_g = XXf(:,:,jr2);%g(i-1/2,j-1/2)
		Xg_g = XXg(:,:,jr2);%g(i+3/2,j+3/2)
		Xh_g = XXh(:,:,jr2);%g(i-1/2,j+3/2)
		Xi_g = XXi(:,:,jr2);%g(i+3/2,j-1/2)
%
%Boundary conditions for g (the Lorentz model is enforced at p = 0)
%
		if boundary_mode_g > 0,
			Xa_g(1:boundary_mode_g,:) = 0;%g(i+1/2,j-1/2)
			Xb_g(1:boundary_mode_g,:) = 0;%g(i-1/2,j+1/2)
			Xc_g(1:boundary_mode_g,:) = 1;%g(i+1/2,j+1/2)
			Xd_g(1:boundary_mode_g,:) = 0;%g(i+3/2,j+1/2)
			Xe_g(1:boundary_mode_g,:) = 0;%g(i+1/2,j+3/2)
			Xf_g(1:boundary_mode_g,:) = 0;%g(i-1/2,j-1/2)
			Xg_g(1:boundary_mode_g,:) = 0;%g(i+3/2,j+3/2)
			Xh_g(1:boundary_mode_g,:) = 0;%g(i-1/2,j+3/2)
			Xi_g(1:boundary_mode_g,:) = 0;%g(i+3/2,j-1/2)
		end
%
%Boundaries of the bounce domain for g
%
		Xa_g_t = Xa_g(:,Zmask_g{ir_dke});%Matrix reduction along the angular direction
		Xb_g_t = Xb_g(:,Zmask_g{ir_dke});
		Xc_g_t = Xc_g(:,Zmask_g{ir_dke});
		Xd_g_t = Xd_g(:,Zmask_g{ir_dke});
		Xe_g_t = Xe_g(:,Zmask_g{ir_dke});
		Xf_g_t = Xf_g(:,Zmask_g{ir_dke});
		Xg_g_t = Xg_g(:,Zmask_g{ir_dke});
		Xh_g_t = Xh_g(:,Zmask_g{ir_dke});
		Xi_g_t = Xi_g(:,Zmask_g{ir_dke});
%
		Xe_g_t(:,(nmhu - ns_g(ir_dke))/2) = 0;%g(pn,mhu = -mhut) = 0
		Xg_g_t(:,(nmhu - ns_g(ir_dke))/2) = 0;%g(pn,mhu = -mhut) = 0
		Xh_g_t(:,(nmhu - ns_g(ir_dke))/2) = 0;%g(pn,mhu = -mhut) = 0
%
		Xa_g_t(:,(nmhu - ns_g(ir_dke))/2 + 1) = 0;%g(pn,mhu = mhut) = 0
		Xf_g_t(:,(nmhu - ns_g(ir_dke))/2 + 1) = 0;%g(pn,mhu = mhut) = 0
		Xi_g_t(:,(nmhu - ns_g(ir_dke))/2 + 1) = 0;%g(pn,mhu = mhut) = 0
%
%Matrix calculation for ftp
%
		MXc_tp = reshape(Xc_tp',nmhu*npn,1);
		MXP_tp = sparse([1:nmhu*npn],[1:nmhu*npn],MXc_tp,nmhu*npn,nmhu*npn);
		MXa_tp = reshape(Xa_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1+1:nmhu*npn],[1:nmhu*npn-1],MXa_tp(1+1:length(MXa_tp)),nmhu*npn,nmhu*npn);
		MXe_tp = reshape(Xe_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1:nmhu*npn-1],[1+1:nmhu*npn],MXe_tp(1:length(MXe_tp)-1),nmhu*npn,nmhu*npn);       
		MXb_tp = reshape(Xb_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1+nmhu:nmhu*npn],[1:nmhu*npn-nmhu],MXb_tp(1+nmhu:length(MXb_tp)),nmhu*npn,nmhu*npn);            
		MXd_tp = reshape(Xd_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1:nmhu*npn-nmhu],[1+nmhu:nmhu*npn],MXd_tp(1:length(MXd_tp)-nmhu),nmhu*npn,nmhu*npn);            
		MXf_tp = reshape(Xf_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1+nmhu+1:nmhu*npn],[1:nmhu*npn-nmhu-1],MXf_tp(1+nmhu+1:length(MXf_tp)),nmhu*npn,nmhu*npn);      
		MXh_tp = reshape(Xh_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1+nmhu-1:nmhu*npn],[1:nmhu*npn-nmhu+1],MXh_tp(1+nmhu-1:length(MXh_tp)),nmhu*npn,nmhu*npn);      
		MXi_tp = reshape(Xi_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1:nmhu*npn-nmhu+1],[1+nmhu-1:nmhu*npn],MXi_tp(1:length(MXi_tp)-nmhu+1),nmhu*npn,nmhu*npn);      
		MXg_tp = reshape(Xg_tp',nmhu*npn,1);
		MXP_tp = MXP_tp + sparse([1:nmhu*npn-nmhu-1],[1+nmhu+1:nmhu*npn],MXg_tp(1:length(MXg_tp)-nmhu-1),nmhu*npn,nmhu*npn);          		
%		
		sm_tp(ir_dke+1) = sm_tp(ir_dke) + blocksize_tp(ir_dke);
		[i0_tp,j0_tp,s0_tp] = find(MMXP_tp);		
		[m0_tp,n0_tp] = size(MMXP_tp);
		[i1_tp,j1_tp,s1_tp] = find(MXP_tp);
		[m1_tp,n1_tp] = size(MXP_tp);
		MMXP_tp = sparse(i0_tp,j0_tp,s0_tp,m0_tp+m1_tp,m0_tp+m1_tp) + sparse(m0_tp+i1_tp,m0_tp+j1_tp,s1_tp,m0_tp+m1_tp,m0_tp+m1_tp);
%
%Matrix calculation for g
%
		MXc_g_t = reshape(Xc_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = sparse([1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn],MXc_g_t,(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);
		MXa_g_t = reshape(Xa_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1+1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-1],MXa_g_t(1+1:length(MXa_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);
		MXe_g_t = reshape(Xe_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-1],[1+1:(nmhu - ns_g(ir_dke))*npn],MXe_g_t(1:length(MXe_g_t)-1),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);       
		MXb_g_t = reshape(Xb_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1+(nmhu - ns_g(ir_dke)):(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))],MXb_g_t(1+(nmhu - ns_g(ir_dke)):length(MXb_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);           
		MXd_g_t = reshape(Xd_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))],[1+(nmhu - ns_g(ir_dke)):(nmhu - ns_g(ir_dke))*npn],MXd_g_t(1:length(MXd_g_t)-(nmhu - ns_g(ir_dke))),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);           
		MXf_g_t = reshape(Xf_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1+(nmhu - ns_g(ir_dke))+1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))-1],MXf_g_t(1+(nmhu - ns_g(ir_dke))+1:length(MXf_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
		MXh_g_t = reshape(Xh_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1+(nmhu - ns_g(ir_dke))-1:(nmhu - ns_g(ir_dke))*npn],[1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))+1],MXh_g_t(1+(nmhu - ns_g(ir_dke))-1:length(MXh_g_t)),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
		MXi_g_t = reshape(Xi_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))+1],[1+(nmhu - ns_g(ir_dke))-1:(nmhu - ns_g(ir_dke))*npn],MXi_g_t(1:length(MXi_g_t)-(nmhu - ns_g(ir_dke))+1),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
		MXg_g_t = reshape(Xg_g_t',(nmhu - ns_g(ir_dke))*npn,1);
		MXP_g_t = MXP_g_t + sparse([1:(nmhu - ns_g(ir_dke))*npn-(nmhu - ns_g(ir_dke))-1],[1+(nmhu - ns_g(ir_dke))+1:(nmhu - ns_g(ir_dke))*npn],MXg_g_t(1:length(MXg_g_t)-(nmhu - ns_g(ir_dke))-1),(nmhu - ns_g(ir_dke))*npn,(nmhu - ns_g(ir_dke))*npn);     
%
		sm_g(ir_dke+1) = sm_g(ir_dke) + blocksize_g_t(ir_dke);
		[i0_g,j0_g,s0_g] = find(MMXP_g_t);		
		[m0_g,n0_g] = size(MMXP_g_t);
		[i1_g,j1_g,s1_g] = find(MXP_g_t);
		[m1_g,n1_g] = size(MXP_g_t);
		MMXP_g_t = sparse(i0_g,j0_g,s0_g,m0_g+m1_g,m0_g+m1_g) + sparse(m0_g+i1_g,m0_g+j1_g,s1_g,m0_g+m1_g,m0_g+m1_g);
%
		etime_dke = etime_dke + etime(clock,time0);
	   time0 = clock;
	end
	  
	  
else
%
% for collisions
%
   XXDpp_c_tp_imj = zeros(npn,nmhu,nr);
   XXDpm_c_tp_imj = zeros(npn,nmhu,nr);
   XXFp_c_tp_imj = zeros(npn,nmhu,nr);
   XXDpp_c_tp_ipj = zeros(npn,nmhu,nr);
   XXDpm_c_tp_ipj = zeros(npn,nmhu,nr);
   XXFp_c_tp_ipj = zeros(npn,nmhu,nr);
%
   XXDmm_c_tp_ijm = zeros(npn,nmhu,nr);
   XXDmp_c_tp_ijm = zeros(npn,nmhu,nr);
   XXFm_c_tp_ijm = zeros(npn,nmhu,nr);
   XXDmm_c_tp_ijp = zeros(npn,nmhu,nr);
   XXDmp_c_tp_ijp = zeros(npn,nmhu,nr);
   XXFm_c_tp_ijp = zeros(npn,nmhu,nr);
%
% For Ohmic electric field
%
	XXDpp_e_tp_imj = zeros(npn,nmhu,nr);
	XXDpm_e_tp_imj = zeros(npn,nmhu,nr);
	XXFp_e_tp_imj = zeros(npn,nmhu,nr);
	XXDpp_e_tp_ipj = zeros(npn,nmhu,nr);
	XXDpm_e_tp_ipj = zeros(npn,nmhu,nr);
	XXFp_e_tp_ipj = zeros(npn,nmhu,nr);
%
	XXDmm_e_tp_ijm = zeros(npn,nmhu,nr);
	XXDmp_e_tp_ijm = zeros(npn,nmhu,nr);
	XXFm_e_tp_ijm = zeros(npn,nmhu,nr);
	XXDmm_e_tp_ijp = zeros(npn,nmhu,nr);
	XXDmp_e_tp_ijp = zeros(npn,nmhu,nr);
	XXFm_e_tp_ijp = zeros(npn,nmhu,nr);
%
% For RF waves
%
	XXDpp_rf_tp_imj = zeros(npn,nmhu,nr);
	XXDpm_rf_tp_imj = zeros(npn,nmhu,nr);
	XXFp_rf_tp_imj = zeros(npn,nmhu,nr);
	XXDpp_rf_tp_ipj = zeros(npn,nmhu,nr);
	XXDpm_rf_tp_ipj = zeros(npn,nmhu,nr);
	XXFp_rf_tp_ipj = zeros(npn,nmhu,nr);
%
	XXDmm_rf_tp_ijm = zeros(npn,nmhu,nr);
	XXDmp_rf_tp_ijm = zeros(npn,nmhu,nr);
	XXFm_rf_tp_ijm = zeros(npn,nmhu,nr);
	XXDmm_rf_tp_ijp = zeros(npn,nmhu,nr);
	XXDmp_rf_tp_ijp = zeros(npn,nmhu,nr);
	XXFm_rf_tp_ijp = zeros(npn,nmhu,nr);
end
%
%Second order radial gradient correction for ftp (radial derivative of the Chang and Cooper momentum terms) 
%
if dke_mode == 1,
	XXH_tp_mm = permute(XXH_tp_mm,[2,1,3]);
	XXH_tp_m = permute(XXH_tp_m,[2,1,3]);
	XXH_tp_mp = permute(XXH_tp_mp,[2,1,3]);
	XXH_tp_pm = permute(XXH_tp_pm,[2,1,3]);
	XXH_tp_p = permute(XXH_tp_p,[2,1,3]);
	XXH_tp_pp = permute(XXH_tp_pp,[2,1,3]);
%	
	MMH_tp_mm = reshape(XXH_tp_mm,npn*nmhu*nr,1,1);
	MMH_tp_m = reshape(XXH_tp_m,npn*nmhu*nr,1,1);
	MMH_tp_mp = reshape(XXH_tp_mp,npn*nmhu*nr,1,1);	
	MMH_tp_pm = reshape(XXH_tp_pm,npn*nmhu*nr,1,1);
	MMH_tp_p = reshape(XXH_tp_p,npn*nmhu*nr,1,1);
	MMH_tp_pp = reshape(XXH_tp_pp,npn*nmhu*nr,1,1);
%
	MMH_tp = MMH_tp + sparse([1+(nmhu-1)*npn:nMMH_tp],[1:nMMH_tp-(nmhu-1)*npn],MMH_tp_mm(1+npn*(nmhu-1):nMMH_tp),nMMH_tp,nMMH_tp);	
	MMH_tp = MMH_tp + sparse([1+nmhu*npn:nMMH_tp],[1:nMMH_tp-nmhu*npn],MMH_tp_m(1+npn*nmhu:nMMH_tp),nMMH_tp,nMMH_tp);	
	MMH_tp = MMH_tp + sparse([1+(nmhu+1)*npn:nMMH_tp],[1:nMMH_tp-(nmhu+1)*npn],MMH_tp_mp(1+npn*(nmhu+1):nMMH_tp),nMMH_tp,nMMH_tp);
	MMH_tp = MMH_tp + sparse([1:nMMH_tp-(nmhu-1)*npn],[1+(nmhu-1)*npn:nMMH_tp],MMH_tp_pm(1:nMMH_tp-npn*(nmhu-1)),nMMH_tp,nMMH_tp);		
	MMH_tp = MMH_tp + sparse([1:nMMH_tp-nmhu*npn],[1+nmhu*npn:nMMH_tp],MMH_tp_p(1:nMMH_tp-npn*nmhu),nMMH_tp,nMMH_tp);
	MMH_tp = MMH_tp + sparse([1:nMMH_tp-(nmhu+1)*npn],[1+(nmhu+1)*npn:nMMH_tp],MMH_tp_pp(1:nMMH_tp-npn*(nmhu+1)),nMMH_tp,nMMH_tp);
%
	if display_mode >= 1,info_dke_yp(2,['Second order radial gradient correction for ftp matrix calculations done in ',num2str(etime(clock,time0)),' (s)']);time0 = clock;end
end
%
clear ir sssl0 XY XYm XYp 
clear alpha_tp Xsssl_tp XDelta XDeltam XDeltap 
clear XRlambda_m XRlambda_p Xlambda Xlambda_m Xlambda_p 
clear Xsstar Xsstarm Xsstarp Xsstar_tp Xsstar_tpm Xsstar_tpp Xheaviside Xheavisidem Xheavisidep 
clear Xmhu_psib Xmhu_psibm Xmhu_psibp 
clear XDeltalambda_rip XDeltalambda_ripm XDeltalambda_ripp theta0 theta0m theta0p thetaB thetaBm thetaBp
clear sstar_rip Xlambda_rip Xlambda_ripm Xlambda_ripp  
clear Xdummy1 Xdummy2 Xdummy3 Xdummy4
%
%clear Xa Xb Xc Xd Xe Xf Xg Xh Xi Xj Xk Xl Xm Xn Xo 
%clear Xa_t Xb_t Xc_t Xd_t Xe_t Xf_t Xg_t Xh_t Xi_t Xj_t Xk_t Xl_t Xm_t Xn_t Xo_t 
%clear Xa_ts Xb_ts Xc_ts Xd_ts Xe_ts Xf_ts Xg_ts Xh_ts Xi_ts
%clear Xa_tm Xb_tm Xc_tm Xd_tm Xe_tm Xf_tm Xg_tm Xh_tm Xi_tm
%clear Xa_tp Xb_tp Xc_tp Xd_tp Xe_tp Xf_tp Xg_tp Xh_tp Xi_tp
%clear Xa_tp_t Xb_tp_t Xc_tp_t Xd_tp_t Xe_tp_t Xf_tp_t Xg_tp_t Xh_tp_t Xi_tp_t
%clear Xb_c_tp_t Xc_c_tp_t Xd_c_tp_t
clear Xa_g Xb_g Xc_g Xd_g Xe_g Xf_g Xg_g Xh_g Xi_g
clear Xa_g_t Xb_g_t Xc_g_t Xd_g_t Xe_g_t Xf_g_t Xg_g_t Xh_g_t Xi_g_t
clear MXa MXb MXc MXd MXe MXf MXg MXh MXi MXj MXk MXl MXm MXn MXo 
clear MXa_tp_t MXb_tp_t MXc_tp_t MXd_tp_t MXe_tp_t MXf_tp_t MXg_tp_t MXh_tp_t MXi_tp_t
clear MXa_g_t MXb_g_t MXc_g_t MXd_g_t MXe_g_t MXf_g_t MXg_g_t MXh_g_t MXi_g_t
clear fM normfM xfM sfM normsfM fMm normfMm fMp normfMp
clear XDlh XDlhim XDlhip XDlhjm XDlhjp
clear XDcy XDcyim XDcyip XDcyjm XDcyjp
clear Xmhu_t Xmhub Xmhubm Xmhubp Xcym Xcyp Xcy0m Xcy0p
clear Xdeltaip Xdeltaim Xdeltajp Xdeltajm
clear F1_1 F2_1 F1_2 B1_1 B1_2 B1_3 B1_4 B1_5 B2_1 B2_2 B2_3 
clear F1 F2 F XF F1m F2m Fm F1p F2p Fp XFm XFp A XA Am Ap XAm XAp B1 B2 Bt XBt 
clear MXP_f_t MXPC_f_t MXPDI_f_t MXP_tp_t MXP_c_tp_t MXP_g_t MXPC_g_t MXPDI_g_t
clear Xmask Xmask_g Xmask_tp
clear Xnhuloss XI_th Xf0_g_th
clear jmhut_min jmhut_max
%
if display_mode >= 1,info_dke_yp(2,['Full elapsed time for matrix calculation: ',num2str(etime(clock,time00)),' (s)']);end
%
time0 = clock;
%
MMXdiag = diag(MMXP_f_t/time_scheme + MMXR_f_t/time_scheme + MMXT_f_t);
if isempty(find(MMXdiag==0)) == 1,
	MMXPDI_f_t = inv(diag(MMXdiag));
	MMXPC_f_t = MMXPDI_f_t*(MMXP_f_t/time_scheme + MMXR_f_t/time_scheme + MMXT_f_t);%Main diagonal matrix preconditionning
	[MMXL_f_t,MMXU_f_t] = luinc(MMXPC_f_t,prec_inv); 
	time_f = etime(clock,time0);
	memoryLU_f = (getfield(whos('MMXL_f_t'),'bytes') + getfield(whos('MMXU_f_t'),'bytes'))/1000000;
else
	error('Fokker-Planck matrix has a null element on the main diagonal');%Matrix must be main diagonal dominant
end
%
if dke_mode == 1,
	time0 = clock;	
	MMXPDI_g_t = inv(diag(diag(MMXP_g_t)));
	MMXPC_g_t = MMXPDI_g_t*MMXP_g_t;%Main diagonal matrix preconditionning
	[MMXL_g_t,MMXU_g_t] = luinc(MMXPC_g_t,prec_inv);
	time_g = etime(clock,time0);
	memoryLU_g = (getfield(whos('MMXL_g_t'),'bytes') + getfield(whos('MMXU_g_t'),'bytes'))/1000000;
else
	memoryLU_g = 0;
end
%
if display_mode >= 1,	
	info_dke_yp(2,['Full elapsed time of LU matrix factorization for f: ',num2str(time_f),' (s)']);
	info_dke_yp(2,['Size of the LU matrices for f: ',num2str(memoryLU_f),' MBytes']);
	if dke_mode == 1,
		info_dke_yp(2,['Full elapsed time of LU matrix factorization for g: ',num2str(time_g),' (s)']);
		info_dke_yp(2,['Size of the LU matrices for g: ',num2str(memoryLU_g),' MBytes']);
	end
end
%
if display_mode == 2 & strcmp(computer,'MAC') == 0,%Spy function seems to crash MatLab 6.5.1 on MAC OSX slow processor....
	figure(3000),spy(MMXP_f_t);
	zoom on;
	axis('square');
	title('Momentum space matrix');
%
	if radial_mode == 1,
		figure(3001),spy(MMXR_f_t);
		zoom on;
		axis('square');
		title('Configuration space matrix');	
	end
%
	figure(3002),spy(MMXPC_f_t);
	zoom on;
	axis('square');
	title('Total preconditionned matrix');
end
%
%************************************************** Main Fokker-Planck loop ******************************************************** 
%
if display_mode >= 1,
    disp('-------------------------------------------------------------------------------------------------------------------');
end
%
if display_mode >= 2,
	figure(6000),semilogy(xrho,abs(xEfield_validity),'r+')
	xlabel('r/a')
	ylabel('Fp_e/Fp_coll at pth_ref')
	zoom on, grid on
	title('Code validity with Ohmic electric field')
end
%
time0 = clock;
XXf0 = XXfinit;%Initial guess (normalized to xne_norm)
for ir = 1:nr,
	normf0(ir,1) = 2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,XXfinit(:,:,ir),2),1);
	curr0(ir,1) = 2*pi*integral_dke_jd(dpn',pn2'.*(pn'./gamma').*integral_dke_jd(dmhu,Xmhu.*XXfinit(:,:,ir),2),1)*xne_norm(ir)/normf0(ir,1);
end
%
ZXXf0{1} = XXfinit;%Time evolution of the distribution function is stored (only valid if no self-consistent calculations are done for Dql)
%
for it_f = 2:nit_f,   	
	if sum(residu_f(:,it_f-1) >= prec0_f) >= 1 & sum(prec_residu_f(:,it_f-1)) >= prec0_f | it_f < 7,
%	
		MMXf0_t = [];
		MMXq_t = [];
		MMXIpn2_t = [];
%
		for ir = 1:nr,
			if store_mode == 1,
				filename = ['MXP_',tokname,'.mat'];
				[s,dossier,machine] = comput_dke_yp;
				eval(['load ',dossier,s,filename,' Zmask_f0_t'])
			end	
%
			XI_t = XXI(:,Zmask_f0_t{ir},ir);
			if boundary_mode_f > 0,
				XI_t(1:boundary_mode_f,:) = 0;
			end
%
			MMXf0_t = [MMXf0_t;reshape(XXf0(:,Zmask_f0_t{ir},ir)',(nmhu - ns_f(ir))*npn,1)];
			MMXIpn2_t = [MMXIpn2_t;(xqtilde(ir)/xB0(ir))*reshape((XI_t.*Zpn2_t{ir})',(nmhu - ns_f(ir))*npn,1)];%Zpn2_t is here as part of the partial Jacobian used to avoid singularities at p = 0 and psi = 0, and for pitch-angle derivative df/dmhu = 0 enforced by symmetry at mhu == pi/2
		end 
%
		MMXq_t = MMXIpn2_t + (MMXT_f_t - (time_scheme - 1)*(MMXP_f_t + MMXR_f_t)/time_scheme)*MMXf0_t;%Right handside term of the Fokker-Planck equation
%
		MMXR_t = MMXPDI_f_t*MMXq_t - MMXPC_f_t*MMXf0_t;%Residu calculation for matrix inversion
%
		if invproc == 1,%cgs iterative method
			[MMXS_t,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,prec_inv,maxit_inv,MMXL_f_t,MMXU_f_t);
		elseif invproc == 2,%bicg iterative method		
			[MMXS_t,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,prec_inv,maxit_inv,MMXL_f_t,MMXU_f_t); 
		elseif invproc == 3,%qmr iterative method
			[MMXS_t,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,prec_inv,maxit_inv,MMXL_f_t,MMXU_f_t);
		end
%
      if flaginv_f == 2,
			error('WARNING: Matrix ill-conditionned. No inversion possible for the zero order Fokker-Planck equation. Try to reduce drop tolerance parameter for LU factorization...!');
		end
%
		MMXf1_t = MMXf0_t + MMXS_t;
%			
		for ir = 1:nr,
			Xf1_t = reshape(MMXf1_t(sm_f(ir)+1:sm_f(ir+1)),nmhu - ns_f(ir),npn)';
%
			if bounce_mode == 0,
				Xf1 = Xf1_t;
			elseif bounce_mode == 1,
				Xf1 = zeros(npn,nmhu);
				Xf1(:,1:nmhu/2 - ns_f(ir)) = Xf1_t(:,1:nmhu/2 - ns_f(ir));
				Xf1(:,nmhu/2 + 1:nmhu) = Xf1_t(:,nmhu/2 + 1 - ns_f(ir):nmhu - ns_f(ir));
				Xf1(:,nmhu/2 + 1 - ns_f(ir):nmhu/2) = fliplr(Xf1_t(:,nmhu/2 + 1 - ns_f(ir):nmhu/2));
			end
%
         normf0(ir,it_f) = 2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,XXf0(:,:,ir),2),1);
 			normf1(ir,it_f) = 2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,Xf1,2),1);
			curr0(ir,it_f) = 2*pi*integral_dke_jd(dpn',pn2'.*(pn'./gamma').*integral_dke_jd(dmhu,Xmhu.*XXf0(:,:,ir),2),1)*xne_norm(ir)/normf0(ir,it_f);
			curr1(ir,it_f) = 2*pi*integral_dke_jd(dpn',pn2'.*(pn'./gamma').*integral_dke_jd(dmhu,Xmhu.*Xf1,2),1)*xne_norm(ir)/normf1(ir,it_f);
			prec_curr(ir,it_f) = (curr1(ir,it_f) - curr0(ir,it_f))/curr0(ir,it_f);
			prec_normf(ir,it_f) = (normf1(ir,it_f) - normf0(ir,1))/normf0(ir,1);
			residu_f(ir,it_f) = sqrt(2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,(Xf1-XXf0(:,:,ir)).^2.*XXf0(:,:,ir),2),1)/normf1(ir,it_f)/dtn/dtn);%As done by J.P. Bizarro et al., Nuclear Fusion, 37 (1997) 1509
			prec_residu_f(ir,it_f) = abs((residu_f(ir,it_f) - residu_f(ir,it_f-1))/residu_f(ir,it_f));%For radial transport calculations	
%
			if display_mode >= 1,
				info_dke_yp(2,['Iteration : ',int2str(it_f),' / ',int2str(nit_f),', Residu = ',num2str(residu_f(ir,it_f))]);
				info_dke_yp(2,['   Normalized poloidal magnetic flux: ',num2str(xpsin(ir))]);
				info_dke_yp(2,['      Normalized radius on LFS midplane: ',num2str(xrho(ir))]);
				disp(['                - Density [t-1]: ',num2str(normf0(ir,it_f-1)),' - [t]: ',num2str(normf1(ir,it_f)),' / Relative variation [t-t0]: ',num2str(prec_normf(ir,it_f))]);               
				disp(['                - Current [t-1]: ',num2str(curr0(ir,it_f-1)),' - [t]: ',num2str(curr1(ir,it_f)),' / Current relative accuracy [dt]: ',num2str(prec_curr(ir,it_f))]);
			end
%
			if display_mode == 2,
				if dke_mode == 1,
					if ir == ir_display-1,
						figure(100),subplot(321),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
						axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
						title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
						hold on;zoom on
						figure(100),subplot(322),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
						axis('square');axis([0,it_f,prec0_f/10,1e-4]);
						title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
						hold on;zoom on
						pause(time_pause);
					elseif ir == ir_display,
						figure(100),subplot(323),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
						axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
						title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
						hold on;zoom on
						figure(100),subplot(324),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
						axis('square');axis([0,it_f,prec0_f/10,1e-4]);
						title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
						hold on;zoom on
						pause(time_pause);
					elseif ir == ir_display+1,
						figure(100),subplot(325),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
						axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
						title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
						hold on;zoom on
						figure(100),subplot(326),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
						axis('square');axis([0,it_f,prec0_f/10,1e-4]);
						title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
						hold on;zoom on
						pause(time_pause);
					end
				else
  					if ir == ir_display,
  						figure(100),subplot(121),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
  						axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
  						title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
  						hold on;
  						figure(100),subplot(122),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
  						axis('square');axis([0,it_f,prec0_f/10,1e-4]);
  						title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
  						hold on;
  						pause(time_pause);
  					end
  				end
			end
%
			if coll_mode == 2,%Belaiev-Budker collision operator
				f1 = 1.5*integral_dke_jd(dmhu,Xf1.*(ones(npn,1)*mhu),2)';				
				[I1,I2] = firstordercollop_dke_yp(f1,betath_ref,...
				          masku,maskl,...
				          dpn,xpn,xpn2,xpn3,xsigma,xgamma,xz,xz2,pn,pn2,pn3,sigma,gamma,z,z2,...
				          xJ1,xJ2,xJ3,xJ4,J1,J2,J3,J4,...
				          xTe_norm(ir));
				XI = 4*pi*((XXfM(:,1,ir)'.*(f1 + I1./pn2 + I2.*pn)./gamma)'*mhu).*XXRlambda_b_p1p1(:,:,ir);   
				XI(1,:) = 0;%Boundary conditions at p = 0
				XXI(:,:,ir) = XI;
			else
				XXI(:,:,ir) = zeros(npn,nmhu);
			end
%
			if norm_mode == 1,
				XXf0(:,:,ir) = xne_norm(ir)*Xf1/normf1(ir,it_f);%Normalization to the local density
			else
				XXf0(:,:,ir) = Xf1;%The default value in principle. If OK, tells that the numerical conservative scheme is correct
			end
%
			normf0(ir,it_f) = normf1(ir,it_f);
			curr0(ir,it_f) = curr1(ir,it_f);
%			
			ZXXf0{it_f} = XXf0(:,:,ir);%For time evolution studies
		end
	else			
		if sum(prec_residu_f(:,it_f-1)) < prec0_f,info_dke_yp(2,['WARNING: stationnary residu but convergence not achieved for f0 after ',int2str(it_f),' iterations. Time step likely too large !']);end
		if sum(residu_f(:,it_f-1) >= prec0_f) == 0 & display_mode > 0,
			info_dke_yp(2,['Successfull convergence achieved for f0 after ',int2str(it_f),' iterations !']);
		end
		break;
	end
	if it_f == nit_f,info_dke_yp(2,['WARNING: convergence not achieved for f0 after ',int2str(nit_f),' iterations. Time step too small !']);end
end
if display_mode >= 1,info_dke_yp(2,['Convergence achieved for zero order Fokker-Planck calculations in ',num2str(etime(clock,time0)),' (s)']);end
%
filename = ['TIME_',tokname,'_S',int2str(snumber),'.mat'];%Time evolution is stored in a separated file
save(filename,'dtn','normf0','curr0','ZXXf0');
%
clear ir fM XfM MMXPC_f_t MMXPDI_f_t Xmask_f0 MMXL_f_t MMXU_f_t
clear Xf0 Xf0_t Xq Xq_t Xf1 Xf1_t Xf1_tp Xf1_tm Xf1_ts XR_t XS_t XY_t
clear f1 xf1 I1 I2 XI 
%
if display_mode == 2,
    figure(100),subplot(121),hold off;
    figure(100),subplot(122),hold off;
end
% 
time0 = clock;
%
if dke_mode == 1,
	MMXf0_tp = [];
	MMXf0 = [];
	MMXI_tp = [];
	MMXq_tp_t = [];	
%
%Calculation of the right handside term of the first order Fokker-Planck equation
%	
	for ir_dke = 1:nr_dke,
		jr1 = rdke(ir_dke)-1;
		jr2 = rdke(ir_dke);
		jr3 = rdke(ir_dke)+1;
%           
		Xf0m = XXf0(:,:,jr1);%Lower radial value for gradient calculation
		Xf0  = XXf0(:,:,jr2);%Central radial value for gradient calculation (where ftp and g are calculated)
		Xf0p = XXf0(:,:,jr3);%Upper radial value for gradient calculation
%		
		XfMm = XXfM(:,:,jr1);%Lower radial value for gradient calculation
		XfM = XXfM(:,:,jr2);%Central radial value for gradient calculation (where ftp and g are calculated)
		XfMp = XXfM(:,:,jr3);%Upper radial value for gradient calculation
%
		if store_mode == 1,
			filename = ['MXP_',tokname,'.mat'];
			[s,dossier,machine] = comput_dke_yp;
			eval(['load ',dossier,s,filename,' Zmask_g'])
		end
%           		
		dpsim = (xpsin(jr1) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)
		dpsi = (xpsin(jr3) - xpsin(jr1));%Radial step for parabolic gradient calculations (dke)
		dpsip = (xpsin(jr3) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)      
%
		%if coll_mode == 3,%Normalized gradients of ne and Te for the Lorentz model (test mode only, see documentation)
			xdlnnedpsi(jr2) = (-dpsim*xne_norm(jr3)/dpsi/dpsip - (dpsip + dpsim)*xne_norm(jr2)/dpsip/dpsim + dpsip*xne_norm(jr1)/dpsi/dpsim)/xne_norm(jr2);
			xdlnTedpsi(jr2) = (-dpsim*xTe_norm(jr3)/dpsi/dpsip - (dpsip + dpsim)*xTe_norm(jr2)/dpsip/dpsim + dpsip*xTe_norm(jr1)/dpsi/dpsim)/xTe_norm(jr2);
        %end	
%
		Xdf0dpsi = -dpsim*Xf0p/dpsi/dpsip - (dpsip + dpsim)*Xf0/dpsip/dpsim + dpsip*Xf0m/dpsi/dpsim;%Calculation of the radial gradient of f0 (parabolic interpolation) 
		XXf0_tp(:,:,jr2) = -xftp_norm(jr2)*(Xpn.*Xmhu.*Xdf0dpsi);
%
% Initial guess for the iterative loop (Lorentz model)
%
		XdfMdpsi = -dpsim*XfMp/dpsi/dpsip - (dpsip + dpsim)*XfM/dpsip/dpsim + dpsip*XfMm/dpsi/dpsim;%Calculation of the radial gradient of fM (parabolic interpolation) 
		XXf0_g_th(:,:,jr2) = +xftp_norm(jr2)*(xdlnnedpsi(jr2) + xdlnTedpsi(jr2)*(Xpn2/xTe_norm(jr2)/2 - 1.5)).*Xpn.*(Xmhu./abs(Xmhu)).*XXfM(:,:,jr2).*abs(XXILor(:,:,jr2));%
%
%First order Legendre correction for ftp
%	  
		XI_tp = zeros(npn,nmhu);
		if coll_mode == 2,%Belaiev-Budker collision operator
			f1_tp = 1.5*integral_dke_jd(dmhu,XXf0_tp(:,:,jr2).*XXlambda_b_p2(:,:,jr2).*(ones(npn,1)*mhu),2)';
			[I1_tp,I2_tp] = firstordercollop_dke_yp(f1_tp,betath_ref,...
					 masku,maskl,...
					 dpn,xpn,xpn2,xpn3,xsigma,xgamma,xz,xz2,pn,pn2,pn3,sigma,gamma,z,z2,...
					 xJ1,xJ2,xJ3,xJ4,J1,J2,J3,J4,...
					 xTe_norm(jr2));
			XI_tp = 4*pi*((XXfM(:,1,jr2)'.*(f1_tp + I1_tp./pn2 + I2_tp.*pn)./gamma)'*mhu).*XXheaviside(:,:,jr2)./XXlambda(:,:,jr2);
		else
			XI_tp = zeros(npn,nmhu);
		end
%
		MMXf0_tp = [MMXf0_tp;reshape(XXf0_tp(:,:,jr2)',nmhu*npn,1)];		
		MMXI_tp = [MMXI_tp;reshape(XI_tp'.*Xpn2',nmhu*npn,1)];%Multiplication by the Jacobian of momentum coordinates
	end
%
	MMXq_tp = -MMXP_tp*MMXf0_tp + MMXI_tp;%****** WARNING : en mode Lorentz et en multipliant MMXP_tp_t*MMXf0_tp par 0.5 on retrouve le bon niveau de courant ****
	MMXq_tp_c = -MMH_tp*reshape(permute(XXf0,[2,1,3]),npn*nmhu*nr,1,1);	
%
	for ir_dke = 1:nr_dke,%Remove trapped region at jr2
		Xq_tp = reshape(MMXq_tp(sm_tp(ir_dke)+1:sm_tp(ir_dke+1)),nmhu,npn)';
		Xq_tp_c = reshape(MMXq_tp_c(npn*nmhu*rdke(ir_dke)+1:npn*nmhu*(rdke(ir_dke)+1)),nmhu,npn)';
		if boundary_mode_g ~= 0,
			Xq_tp(1:boundary_mode_g,:) = zeros(1:boundary_mode_g,nmhu);%Boundary conditions at p = 0 enforced for g
			Xq_tp_c(1:boundary_mode_g,:) = zeros(1:boundary_mode_g,nmhu);%Boundary conditions at p = 0 enforced for g
		end
		MMXq_tp_t = [MMXq_tp_t;reshape(Xq_tp(:,Zmask_g{ir_dke})' + 0*Xq_tp_c(:,Zmask_g{ir_dke})',(nmhu - ns_g(ir_dke))*npn,1)];%Matrix reduction since the trapped region is removed
	end   
%
%Resolution of the first order Fokker-Planck equation
%
	XXf0_g = XXf0_g_th;%Initial guess (thermal limit, large aspect ratio, Lorentz model)
	for it_g = 2:nit_g, 
		if sum(residu_g(:,it_g-1) >= prec0_g) >= 1 & sum(prec_residu_g(:,it_g-1)) >= prec0_g | it_g < 5,
%
			MMXf0_g_t = [];
			MMXq_g_t = [];
			for ir_dke = 1:nr_dke,
				jr2 = rdke(ir_dke);
%
				Xq_g_t = XXI_g(:,Zmask_g{ir_dke},jr2).*Xpn2(:,Zmask_g{ir_dke});%First order expansion of the Beliaev-Budker collision operator (current drive problem only)
				if boundary_mode_g ~= 0,
						Xq_g_t(1:boundary_mode_g,:) = XXf0_g_th(1:boundary_mode_g,Zmask_g{ir_dke},jr2);%Boundary conditions at p = 0 (large aspect ratio limit, Lorentz model)
				end
%
				MMXf0_g_t = [MMXf0_g_t;reshape(XXf0_g(:,Zmask_g{ir_dke},jr2)',(nmhu - ns_g(ir_dke))*npn,1)];
				MMXq_g_t = [MMXq_g_t;reshape(Xq_g_t',(nmhu - ns_g(ir_dke))*npn,1)];
			end
%
			MMXR_t = MMXPDI_g_t*(MMXq_g_t + MMXq_tp_t) - MMXPC_g_t*MMXf0_g_t;
%
			if invproc == 1,%cgs iterative method
				[MMXS_t,flaginv_g] = cgs(MMXPC_g_t,MMXR_t,prec_inv,maxit_inv,MMXL_g_t,MMXU_g_t);
			elseif invproc == 2,%bicg iterative method
				[MMXS_t,flaginv_g] = bicg(MMXPC_g_t,MMXR_t,prec_inv,maxit_inv,MMXL_g_t,MMXU_g_t);
			elseif invproc == 3,%qmr iterative method
				[MMXS_t,flaginv_g] = qmr(MMXPC_g_t,MMXR_t,prec_inv,maxit_inv,MMXL_g_t,MMXU_g_t);
			end
%
			if flaginv_g == 1,
				info_dke_yp(2,'WARNING: No convergence in the matrix inversion subroutine for the first order Fokker-Planck equation');
			elseif flaginv_g == 2,
				error('WARNING: Matrix ill-conditionned. No inversion possible for the first order Fokker-Planck equation');
			end
%
			MMXf1_g_t = MMXf0_g_t + MMXS_t;
%
			for ir_dke = 1:nr_dke,
				jr2 = rdke(ir_dke);
				Xf1_g_t = reshape(MMXf1_g_t(sm_g(ir_dke)+1:sm_g(ir_dke+1)),nmhu - ns_g(ir_dke),npn)';%Split vector into sub-matrices
%
				Xf1_g = zeros(npn,nmhu);
				Xf1_g(1:npn,1:(nmhu - ns_g(ir_dke))/2) = Xf1_g_t(1:npn,1:(nmhu - ns_g(ir_dke))/2);%Expansion of the function g on the pitch-angle grid
				Xf1_g(1:npn,(nmhu + ns_g(ir_dke))/2 + 1:nmhu) = Xf1_g_t(1:npn,(nmhu - ns_g(ir_dke))/2 + 1:nmhu - ns_g(ir_dke));%Expansion of the function g on the pitch-angle grid
%
				norm1_g(ir_dke,it_g) = 2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,Xf1_g,2),1);
				residu_g(ir_dke,it_g) = sqrt(abs(2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,(Xf1_g - XXf0_g(:,:,jr2)).^2.*XXf0_g(:,:,jr2),2),1)/norm1_g(ir_dke,it_g)));
				prec_residu_g(ir_dke,it_g) = abs((residu_g(ir_dke,it_g) - residu_g(ir_dke,it_g-1))/residu_g(ir_dke,it_g));				
%
				if display_mode >= 1,	
					info_dke_yp(2,['Iteration : ',int2str(it_g),' / ',int2str(nit_g),', Residu = ',num2str(residu_g(ir_dke,it_g))]);
					info_dke_yp(2,['   Normalized poloidal magnetic flux: ',num2str(xpsin(jr2))]);
					info_dke_yp(2,['      Normalized radius on LFS midplane: ',num2str(xrho(jr2))]);
				end
%
				if jr2 == ir_display & display_mode == 2,
					figure(101),subplot(121),plot(-pn,Xf1_g(:,1),'r-',pn,Xf1_g(:,nmhu),'r-');%g(perp = 0)
					axis('square');set(gca,'xlim',[-10,10]);
					title(['Iteration: ',int2str(it_g)]);xlabel('pn-ref');ylabel('g(pperp=0)')
					hold on;zoom on
					figure(101),subplot(122),semilogy([1:it_g],residu_g(ir_dke,1:it_g),'r+',[1:it_g],max(residu_g(:,1:it_g)),'gx',[1:it_g],prec0_g*ones(size([1:it_g])),'b--');
					axis('square');axis([0,it_g,prec0_g/10,1e-4]);
					title(['Convergence - g (rho=',num2str(xrho(jr2)),')']);xlabel('Iteration');ylabel('Residu')
					hold on;zoom on
					pause(time_pause);
				end
%
%First order Legendre correction for g
%
				if coll_mode == 2,%Belaiev-Budler collision operator
					f1_g = 1.5*integral_dke_jd(dmhu,Xf1_g.*(ones(npn,1)*mhu),2)';
					[I1_g,I2_g] = firstordercollop_dke_yp(f1_g,betath_ref,...
							 masku,maskl,...
							 dpn,xpn,xpn2,xpn3,xsigma,xgamma,xz,xz2,pn,pn2,pn3,sigma,gamma,z,z2,...
							 xJ1,xJ2,xJ3,xJ4,J1,J2,J3,J4,...
							 xTe_norm(jr2));
				         XI_g = 4*pi*((XXfM(:,1,jr2)'.*(f1_g + I1_g./pn2 + I2_g.*pn)./gamma)'*mhu).*XXRlambda_b_p1p1(:,:,jr2);   
				         XXI_g(:,:,jr2) = XI_g;
				else
					XXI_g(:,:,jr2) = zeros(npn,nmhu);
				end
%
				XXf0_g(:,:,jr2) = Xf1_g;
			end
		else
			if sum(prec_residu_g(:,it_g-1)) < prec0_g,info_dke_yp(2,['WARNING: stationnary residu but convergence not achieved for g after ',int2str(it_g),' iterations. Time step likely too large !']);end
			if sum(residu_g(:,it_g-1) >= prec0_g) == 0 & display_mode > 0,
				info_dke_yp(2,['Successfull convergence achieved for g after ',int2str(it_g),' iterations !']);
			end
			break;	
		end
		if it_g == nit_g,info_dke_yp(2,['WARNING: convergence not achieved for g after ',int2str(nit_g),' iterations.']);end
   end
%
	if display_mode >= 1,info_dke_yp(2,['Convergence achieved for first order Fokker-Planck calculations in ',num2str(etime(clock,time0)),' (s)']);end
else
    XXf0_tp = zeros(size(XXf0));
    XXf0_g = zeros(size(XXf0));
end
%  
if coll_mode == 3,%Lorentz model (test mode only, see documentation)
	for ir_dke = 1:nr_dke,
		jr2 = rdke(ir_dke);
		XXf0_L_tp(:,:,jr2) = -xftp_norm(jr2)*(xdlnnedpsi(jr2) + xdlnTedpsi(jr2)*(Xpn2/xTe_norm(jr2)/2 - 1.5)).*Xpn.*Xmhu.*XXfM(:,:,jr2);
		XXf0_L_g(:,:,jr2) =  xftp_norm(jr2)*(xdlnnedpsi(jr2) + xdlnTedpsi(jr2)*(Xpn2/xTe_norm(jr2)/2 - 1.5)).*Xpn.*(Xmhu./abs(Xmhu)).*XXfM(:,:,jr2).*abs(XXILor(:,:,jr2));%Signe ********
	end	
end 
%
clear fM XfM Xsssl Xsstar_tp Xlambda MXP_tp_t MXPC_g_t MXPDI_g_t Xmask_g MXL_g_t MXU_g_t 
clear Xdf0dpsin Xf0_tp Xf0_tp_t ir jr1 jr2 jr3 dr drm drp 
clear Xf0 Xf0m Xf0p Xf0_g Xf0_g_t Xf0_g_th_t Xq_g Xq_g_t Xf1_g Xf2_g Xf1_g_t XR_t XS_t XY_t
clear f1_g xf1_g I1_g I2_g XI_g XI_g_t 
clear f1_tp xf1_tp I1_tp I2_tp XI_tp XI_g_tp 
%
if display == 2,
	if dke_mode == 1,
%           
		XfM = XXfM(:,:,ir_display-1);
		Xf0 = XXf0(:,:,ir_display-1);
		figure(102),subplot(321),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
		axis('square');axis([-max(pn),max(pn),1e-20,10]);zoom on
		title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
		hold on;zoom on
		figure(102),subplot(322),plot([1:nit_f],curr1(ir_display-1,:),'r-');
		axis('square');if max(max(curr1(ir_display-1,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display-1,:)))]);end
		title('Convergence');xlabel('Iteration');ylabel('Current')
		hold on;zoom on
		pause(time_pause);
%
		XfM = XXfM(:,:,ir_display);
		Xf0 = XXf0(:,:,ir_display);
		figure(102),subplot(323),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
		axis('square');axis([-max(pn),max(pn),1e-20,10]);zoom on
		title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
		hold on;zoom on
		figure(102),subplot(324),plot([1:nit_f],curr1(ir_display,:),'r-');
		axis('square');if max(max(curr1(ir_display,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display,:)))]);end
		title('Convergence');xlabel('Iteration');ylabel('Current')
		hold on;zoom on
		pause(time_pause);
%
		XfM = XXfM(:,:,ir_display+1);
		Xf0 = XXf0(:,:,ir_display+1);
		figure(102),subplot(325),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
		axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
		title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
		hold on;zoom on
		figure(102),subplot(326),plot([1:nit_f],curr1(ir_display+1,:),'r-');
		axis('square');if max(max(curr1(ir_display+1,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display+1,:)))]);end
		title('Convergence');xlabel('Iteration');ylabel('Current')
		hold on;zoom on
		pause(time_pause);
	else
		XfM = XXfM(:,:,ir_display);
		Xf0 = XXf0(:,:,ir_display);
%
		figure(102),subplot(121),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
		axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
		title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
		hold on;
		figure(102),subplot(122),plot([1:nit_f],curr1(ir_display,:),'r-');
    	axis('square');if max(max(curr1(ir_display,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display,:)))]);end
    	title('Current convergence');xlabel('Iteration');ylabel('Current')
    	hold on;
    	pause(time_pause);
    end
end
%
clear ir XfM Xf0
%
% Calculation of the various moments of the distribution function (density, current, power, bremsstrahlung)
time0 = clock;
%
%   Density
%
xnorm_0 = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
xnorm_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
xnorm_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
%
Znorm{1,1} = xnorm_0;
Znorm{1,2} = xnorm_tp;
Znorm{1,3} = xnorm_g;
%
if coll_mode == 3,%Lorentz model (test mode only, see documentation)
	xnorm_L_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
	xnorm_L_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
	Znorm{1,4} = xnorm_L_tp;
	Znorm{1,5} = xnorm_L_g;
	clear xnorm_L_tp xnorm_L_g
end 
%
clear xnorm_0 xnorm_tp xnorm_g xnorm_L_tp xnorm_L_g
%
xnorm_0_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda(:,:,rdke).*XXf0(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
xnorm_tp_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda_b_p1m1(:,:,rdke).*XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
xnorm_g_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda(:,:,rdke).*XXf0_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
%
Znorm_fsav{1,1} = xnorm_0_fsav;
Znorm_fsav{1,2} = xnorm_tp_fsav;
Znorm_fsav{1,3} = xnorm_g_fsav;
%
if coll_mode == 3,%Lorentz model (test mode only, see documentation)
	xnorm_L_tp_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda_b_p1m1(:,:,rdke).*XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
	xnorm_L_g_fsav = 2*pi.*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXlambda(:,:,rdke).*XXf0_L_g(:,:,rdke).*XXpn2(:,:,rdke),1),1)';
	Znorm_fsav{1,4} = xnorm_L_tp_fsav;
	Znorm_fsav{1,5} = xnorm_L_g_fsav;
	clear xnorm_L_tp_fsav xnorm_L_g_fsav
end 
%
% When radial transport is turned off, the distribution function is renormalized before calculating all other
% moments. This makes physical sense since no electron is meant to be lost
% or gained (! still need to include run-away contribution - Yves?)
%
if radial_mode ~= 1,
    XXf0(:,:,rdke) = XXf0(:,:,rdke).*shiftdim(repmat(xne_norm(rdke)'./xnorm_0_fsav',[1,npn,nmhu]),1);
end
%
%
xc_g = -(xnorm_tp_fsav + xnorm_g_fsav)./xne_norm(rdke);%Flux surface averaged density conservation
XXxc_g = shiftdim(repmat(repmat(xc_g(:),[1,npn,1]),[1,1,nmhu]),1);
XXf0_g(:,:,rdke) = XXf0_g(:,:,rdke) + XXxc_g.*XXf0(:,:,rdke);%Normalisation in order to maintain the flux surface averaged density at the right level
%
clear xnorm_0_fsav xnorm_tp_fsav xnorm_g_fsav 
%
%   Current
%
xcurr_0 = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
xcurr_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
xcurr_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
%
xcurr_tot = xcurr_0 + xcurr_tp + xcurr_g;%Total current density
%
Zcurr{1,1} = xcurr_0;
Zcurr{1,2} = xcurr_tp;
Zcurr{1,3} = xcurr_g;
%
if coll_mode == 3,%Lorentz model (test mode only, see documentation)
	xcurr_L_tp = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
	xcurr_L_g = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
	Zcurr{1,4} = xcurr_L_tp;
	Zcurr{1,5} = xcurr_L_g;
	xcurr_L_tot = xcurr_0 + xcurr_L_tp + xcurr_L_g;%Total current density
	clear xcurr_L_tp xcurr_L_g
end 
%
clear xcurr_0 xcurr_tp xcurr_g
%
%   Flux surface averaged current
%
xcurr_0_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
xcurr_tp_fsav = 2*pi*(xqtilde(rdke)./xqbar(rdke)).*(Rp./xR0(rdke)).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_p2m2p2(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
xcurr_g_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_g(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
%
xcurr_tot_fsav = xcurr_0_fsav + xcurr_tp_fsav + xcurr_g_fsav;%Flux surface averaged total current density  
%
Zcurr_fsav{1,1} = xcurr_0_fsav;
Zcurr_fsav{1,2} = xcurr_tp_fsav;
Zcurr_fsav{1,3} = xcurr_g_fsav;
%
if coll_mode == 3,%Lorentz model (test mode only, see documentation)
	xcurr_L_tp_fsav = 2*pi*(xqtilde(rdke)./xqbar(rdke)).*(Rp./xR0(rdke)).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_tp(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke).*XXlambda_p2m2p2(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
	xcurr_L_g_fsav = 2*pi*(xq(rdke)./xqbar(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXf0_L_g(:,:,rdke).*XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXpn(:,:,rdke).*XXmhu(:,:,rdke)./XXgamma(:,:,rdke),1),1)';
	Zcurr_fsav{1,4} = xcurr_L_tp_fsav;
	Zcurr_fsav{1,5} = xcurr_L_g_fsav;
	xcurr_L_tot_fsav = xcurr_0_fsav + xcurr_L_tp_fsav + xcurr_L_g_fsav;%Total current density
	clear xcurr_L_tp_fsav xcurr_L_g_fsav
end 
%
clear xcurr_0_fsav xcurr_tp_fsav xcurr_g_fsav
%	
%   Fluxes
%
%   Collisional fluxes and power
%
%f0 contribution
%
[XXSp0_c_imj,XXSp0_c_ipj,XXSm0_c_ijm,XXSm0_c_ijp] = ...
    fluxes_dke_jd(XXDpp_c_imj(:,:,rdke),XXDpp_c_ipj(:,:,rdke),XXDpm_c_imj(:,:,rdke),XXDpm_c_ipj(:,:,rdke),...
    XXFp_c_imj(:,:,rdke),XXFp_c_ipj(:,:,rdke),...
    XXDmm_c_ijm(:,:,rdke),XXDmm_c_ijp(:,:,rdke),XXDmp_c_ijm(:,:,rdke),XXDmp_c_ijp(:,:,rdke),...
    XXFm_c_ijm(:,:,rdke),XXFm_c_ijp(:,:,rdke),...
    XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
xP0_c_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_c_imj,1),1)';       
%
%f0_tp contribution
%
[XXSp0_c_tp_imj,XXSp0_c_tp_ipj,XXSm0_c_tp_ijm,XXSm0_c_tp_ijp] = ...
    fluxes_dke_jd(XXDpp_c_tp_imj(:,:,rdke),XXDpp_c_tp_ipj(:,:,rdke),XXDpm_c_tp_imj(:,:,rdke),XXDpm_c_tp_ipj(:,:,rdke),...
    XXFp_c_tp_imj(:,:,rdke),XXFp_c_tp_ipj(:,:,rdke),...
    XXDmm_c_tp_ijm(:,:,rdke),XXDmm_c_tp_ijp(:,:,rdke),XXDmp_c_tp_ijm(:,:,rdke),XXDmp_c_tp_ijp(:,:,rdke),...
    XXFm_c_tp_ijm(:,:,rdke),XXFm_c_tp_ijp(:,:,rdke),...
    XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
xP0_c_tp_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_c_tp_imj,1),1)';       
%
%f0_g contribution
%
[XXSp0_c_g_imj,XXSp0_c_g_ipj,XXSm0_c_g_ijm,XXSm0_c_g_ijp] = ...
    fluxes_dke_jd(XXDpp_c_imj(:,:,rdke),XXDpp_c_ipj(:,:,rdke),XXDpm_c_imj(:,:,rdke),XXDpm_c_ipj(:,:,rdke),...
    XXFp_c_imj(:,:,rdke),XXFp_c_ipj(:,:,rdke),...
    XXDmm_c_ijm(:,:,rdke),XXDmm_c_ijp(:,:,rdke),XXDmp_c_ijm(:,:,rdke),XXDmp_c_ijp(:,:,rdke),...
    XXFm_c_ijm(:,:,rdke),XXFm_c_ijp(:,:,rdke),...
    XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
xP0_c_g_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_c_g_imj,1),1)';       
%
ZSp0{1,1} = XXSp0_c_imj;
ZSp0{1,2} = XXSp0_c_tp_imj;
ZSp0{1,3} = XXSp0_c_g_imj;
%
ZSp0{1,4} = XXSp0_c_ipj;
ZSp0{1,5} = XXSp0_c_tp_ipj;
ZSp0{1,6} = XXSp0_c_g_ipj;
%
ZSp0{1,7} = XXSm0_c_ijm;
ZSp0{1,8} = XXSm0_c_tp_ijm;
ZSp0{1,9} = XXSm0_c_g_ijm;
%
ZSp0{1,10} = XXSm0_c_ijp;
ZSp0{1,11} = XXSm0_c_tp_ijp;
ZSp0{1,12} = XXSm0_c_g_ijp;
%
ZP0_fsav{1,1} = xP0_c_fsav;
ZP0_fsav{1,2} = xP0_c_tp_fsav;
ZP0_fsav{1,3} = xP0_c_g_fsav;
%
XXSp0_imj = XXSp0_c_imj;
XXSm0_ijm = XXSm0_c_ijm;
%
clear XXSp0_c_imj XXSp0_c_tp_imj XXSp0_c_g_imj
clear xP0_c_fsav xP0_c_tp_fsav xP0_c_g_fsav
%
%   Ohmic fluxes and power
%
%f0 contribution
%
[XXSp0_e_imj,XXSp0_e_ipj,XXSm0_e_ijm,XXSm0_e_ijp] = ...
    fluxes_dke_jd(XXDpp_e_imj(:,:,rdke),XXDpp_e_ipj(:,:,rdke),XXDpm_e_imj(:,:,rdke),XXDpm_e_ipj(:,:,rdke),...
    XXFp_e_imj(:,:,rdke),XXFp_e_ipj(:,:,rdke),...
    XXDmm_e_ijm(:,:,rdke),XXDmm_e_ijp(:,:,rdke),XXDmp_e_ijm(:,:,rdke),XXDmp_e_ijp(:,:,rdke),...
    XXFm_e_ijm(:,:,rdke),XXFm_e_ijp(:,:,rdke),...
    XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
% 
xP0_e_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_e_imj,1),1)';       
%
%f0_tp contribution
%
[XXSp0_e_tp_imj,XXSp0_e_tp_ipj,XXSm0_e_tp_ijm,XXSm0_e_tp_ijp] = ...
    fluxes_dke_jd(XXDpp_e_tp_imj(:,:,rdke),XXDpp_e_tp_ipj(:,:,rdke),XXDpm_e_tp_imj(:,:,rdke),XXDpm_e_tp_ipj(:,:,rdke),...
    XXFp_e_tp_imj(:,:,rdke),XXFp_e_tp_ipj(:,:,rdke),...
    XXDmm_e_tp_ijm(:,:,rdke),XXDmm_e_tp_ijp(:,:,rdke),XXDmp_e_tp_ijm(:,:,rdke),XXDmp_e_tp_ijp(:,:,rdke),...
    XXFm_e_tp_ijm(:,:,rdke),XXFm_e_tp_ijp(:,:,rdke),...
    XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%
xP0_e_tp_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_e_tp_imj,1),1)';       
%
%f0_g contribution
%
[XXSp0_e_g_imj,XXSp0_e_g_ipj,XXSm0_e_g_ijm,XXSm0_e_g_ijp] = ...
    fluxes_dke_jd(XXDpp_e_imj(:,:,rdke),XXDpp_e_ipj(:,:,rdke),XXDpm_e_imj(:,:,rdke),XXDpm_e_ipj(:,:,rdke),...
    XXFp_e_imj(:,:,rdke),XXFp_e_ipj(:,:,rdke),...
    XXDmm_e_ijm(:,:,rdke),XXDmm_e_ijp(:,:,rdke),XXDmp_e_ijm(:,:,rdke),XXDmp_e_ijp(:,:,rdke),...
    XXFm_e_ijm(:,:,rdke),XXFm_e_ijp(:,:,rdke),...
    XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
    XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
    XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
% 
xP0_e_g_fsav = 2*pi*(xqtilde(rdke)./xqhat(rdke)).*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).*XXpn2m(:,:,rdke)./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_e_g_imj,1),1)';       
%
ZSp0{2,1} = XXSp0_e_imj;
ZSp0{2,2} = XXSp0_e_tp_imj;
ZSp0{2,3} = XXSp0_e_g_imj;
%
ZSp0{2,4} = XXSp0_e_ipj;
ZSp0{2,5} = XXSp0_e_tp_ipj;
ZSp0{2,6} = XXSp0_e_g_ipj;
%
ZSp0{2,7} = XXSm0_e_ijm;
ZSp0{2,8} = XXSm0_e_tp_ijm;
ZSp0{2,9} = XXSm0_e_g_ijm;
%
ZSp0{2,10} = XXSm0_e_ijp;
ZSp0{2,11} = XXSm0_e_tp_ijp;
ZSp0{2,12} = XXSm0_e_g_ijp;
%
ZP0_fsav{2,1} = xP0_e_fsav;
ZP0_fsav{2,2} = xP0_e_tp_fsav;
ZP0_fsav{2,3} = xP0_e_g_fsav;
%
XXSp0_imj = XXSp0_imj + XXSp0_e_imj;
XXSm0_ijm = XXSm0_ijm + XXSm0_e_ijm;
%
clear XXSp0_e_imj XXSp0_e_tp_imj XXSp0_e_g_imj
clear xP0_e_fsav xP0_e_tp_fsav xP0_e_g_fsav
%
%   RF fluxes and power
%      
if nb > 0,
   ZSp0{3,1} = 0;
   ZSp0{3,2} = 0;
   ZSp0{3,3} = 0;
%
   ZSp0{3,4} = 0;
   ZSp0{3,5} = 0;
   ZSp0{3,6} = 0;
%
   ZSp0{3,7} = 0;
   ZSp0{3,8} = 0;
   ZSp0{3,9} = 0;
%
   ZSp0{3,10} = 0;
   ZSp0{3,11} = 0;
   ZSp0{3,12} = 0;
%
   for ib=1:nb,
	   eval(['load temp_ray_#',int2str(ib),' ZYXXD_rf ZYXXD_rf_tp ZYXXF_rf_tp']);%Load large data file for each ray
%	   
		xyD0_rf = waveparam(:,ib,4);% RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
		YXXD0_rf = shiftdim(repmat(xyD0_rf,[1,1,npn,nmhu]),2);
%
% Sum over all rays
%	    
		XXDpp_rf_imj = ZYXXD_rf{4}.*YXXD0_rf;
		XXDpp_rf_ipj = ZYXXD_rf{2}.*YXXD0_rf;
		XXDpm_rf_imj = ZYXXD_rf{8}.*YXXD0_rf;
		XXDpm_rf_ipj = ZYXXD_rf{6}.*YXXD0_rf;
		XXFp_rf_imj = zeros(npn,nmhu,nr);
		XXFp_rf_ipj = zeros(npn,nmhu,nr);		
		XXDmm_rf_ijm = ZYXXD_rf{13}.*YXXD0_rf; 
		XXDmm_rf_ijp = ZYXXD_rf{12}.*YXXD0_rf;
		XXDmp_rf_ijm = ZYXXD_rf{11}.*YXXD0_rf;
		XXDmp_rf_ijp = ZYXXD_rf{9}.*YXXD0_rf;
		XXFm_rf_ijm = zeros(npn,nmhu,nr);
		XXFm_rf_ijp = zeros(npn,nmhu,nr);
%
		XXDpp_rf_tp_imj = ZYXXD_rf_tp{4}.*YXXD0_rf;
		XXDpp_rf_tp_ipj = ZYXXD_rf_tp{2}.*YXXD0_rf;
		XXDpm_rf_tp_imj = ZYXXD_rf_tp{8}.*YXXD0_rf;
		XXDpm_rf_tp_ipj = ZYXXD_rf_tp{6}.*YXXD0_rf;
		XXFp_rf_tp_imj = ZYXXF_rf_tp{4}.*YXXD0_rf;
		XXFp_rf_tp_ipj = ZYXXF_rf_tp{2}.*YXXD0_rf;
		XXDmm_rf_tp_ijm = ZYXXD_rf_tp{13}.*YXXD0_rf; 
		XXDmm_rf_tp_ijp = ZYXXD_rf_tp{12}.*YXXD0_rf;
		XXDmp_rf_tp_ijm = ZYXXD_rf_tp{11}.*YXXD0_rf;
		XXDmp_rf_tp_ijp = ZYXXD_rf_tp{9}.*YXXD0_rf;
		XXFm_rf_tp_ijm = ZYXXF_rf_tp{7}.*YXXD0_rf;
		XXFm_rf_tp_ijp = ZYXXF_rf_tp{6}.*YXXD0_rf;		
%
%f0 contribution for each ray
%
	   [XXSp0_rf_imj,XXSp0_rf_ipj,XXSm0_rf_ijm,XXSm0_rf_ijp] = ...
         fluxes_dke_jd(XXDpp_rf_imj(:,:,rdke),XXDpp_rf_ipj(:,:,rdke),XXDpm_rf_imj(:,:,rdke),XXDpm_rf_ipj(:,:,rdke),...
         XXFp_rf_imj(:,:,rdke),XXFp_rf_ipj(:,:,rdke),...
         XXDmm_rf_ijm(:,:,rdke),XXDmm_rf_ijp(:,:,rdke),XXDmp_rf_ijm(:,:,rdke),XXDmp_rf_ijp(:,:,rdke),...
         XXFm_rf_ijm(:,:,rdke),XXFm_rf_ijp(:,:,rdke),...
         XXf0(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
         XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
         XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%
      xyP0m_rf_fsav(rdke,ib) = 2*pi*(xqtilde(rdke)'./xqhat(rdke)').*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_imj,1),1);       
      xyP0p_rf_fsav(rdke,ib) = 2*pi*(xqtilde(rdke)'./xqhat(rdke)').*integral_dke_jd(dmhu,integral_dke_jd(dpnp,XXpnp(:,:,rdke).^3./XXgammap(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_ipj,1),1);       
      xyP0_rf_fsav(rdke,ib) = (xyP0m_rf_fsav(rdke,ib) + xyP0p_rf_fsav(rdke,ib))/2;
%
%f0_tp contribution for each ray
%
      [XXSp0_rf_tp_imj,XXSp0_rf_tp_ipj,XXSm0_rf_tp_ijm,XXSm0_rf_tp_ijp] = ...
         fluxes_dke_jd(XXDpp_rf_tp_imj(:,:,rdke),XXDpp_rf_tp_ipj(:,:,rdke),XXDpm_rf_tp_imj(:,:,rdke),XXDpm_rf_tp_ipj(:,:,rdke),...
         XXFp_rf_tp_imj(:,:,rdke),XXFp_rf_tp_ipj(:,:,rdke),...
         XXDmm_rf_tp_ijm(:,:,rdke),XXDmm_rf_tp_ijp(:,:,rdke),XXDmp_rf_tp_ijm(:,:,rdke),XXDmp_rf_tp_ijp(:,:,rdke),...
         XXFm_rf_tp_ijm(:,:,rdke),XXFm_rf_tp_ijp(:,:,rdke),...
         XXf0_tp(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
         XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
         XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%            
      xyP0_rf_tp_fsav(rdke,ib) = 2*pi*(xqtilde(rdke)'./xqhat(rdke)').*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_tp_imj,1),1);       
%
%f0_g contribution for each ray
%
      [XXSp0_rf_g_imj,XXSp0_rf_g_ipj,XXSm0_rf_g_ijm,XXSm0_rf_g_ijp] = ...
         fluxes_dke_jd(XXDpp_rf_imj(:,:,rdke),XXDpp_rf_ipj(:,:,rdke),XXDpm_rf_imj(:,:,rdke),XXDpm_rf_ipj(:,:,rdke),...
         XXFp_rf_imj(:,:,rdke),XXFp_rf_ipj(:,:,rdke),...
         XXDmm_rf_ijm(:,:,rdke),XXDmm_rf_ijp(:,:,rdke),XXDmp_rf_ijm(:,:,rdke),XXDmp_rf_ijp(:,:,rdke),...
         XXFm_rf_ijm(:,:,rdke),XXFm_rf_ijp(:,:,rdke),...
         XXf0_g(:,:,rdke),XXpn(:,:,rdke),XXpnm(:,:,rdke),XXpnp(:,:,rdke),XX1mmhu2(:,:,rdke),XX1mmhu2m(:,:,rdke),XX1mmhu2p(:,:,rdke),...
         XXdpnm(:,:,rdke),XXdpnp(:,:,rdke),XXdmhum(:,:,rdke),XXdmhup(:,:,rdke),...
         XXdeltap_imj(:,:,rdke),XXdeltap_ipj(:,:,rdke),XXdeltam_ijm(:,:,rdke),XXdeltam_ijp(:,:,rdke));
%    
      xyP0_rf_g_fsav(rdke,ib) = 2*pi*(xqtilde(rdke)'./xqhat(rdke)').*integral_dke_jd(dmhu,integral_dke_jd(dpnm,XXpnm(:,:,rdke).^3./XXgammam(:,:,rdke).*XXlambda(:,:,rdke).*XXSp0_rf_g_imj,1),1);       
%
		XXSp0_imj = XXSp0_imj + XXSp0_rf_imj;
		XXSm0_ijm = XXSm0_ijm + XXSm0_rf_ijm;
%
		ZSp0{3,1} = ZSp0{3,1} + XXSp0_rf_imj;
		ZSp0{3,2} = ZSp0{3,2} + XXSp0_rf_tp_imj;
		ZSp0{3,3} = ZSp0{3,3} + XXSp0_rf_g_imj;
%
		ZSp0{3,4} = ZSp0{3,4} + XXSp0_rf_ipj;
		ZSp0{3,5} = ZSp0{3,5} + XXSp0_rf_tp_ipj;
		ZSp0{3,6} = ZSp0{3,6} + XXSp0_rf_g_ipj;
%
		ZSp0{3,7} = ZSp0{3,7} + XXSm0_rf_ijm;
		ZSp0{3,8} = ZSp0{3,8} + XXSm0_rf_tp_ijm;
		ZSp0{3,9} = ZSp0{3,9} + XXSm0_rf_g_ijm;
%
		ZSp0{3,10} = ZSp0{3,10} + XXSm0_rf_ijp;
		ZSp0{3,11} = ZSp0{3,11} + XXSm0_rf_tp_ijp;
		ZSp0{3,12} = ZSp0{3,12} + XXSm0_rf_g_ijp;
%
	end
%
	ZP0_fsav{3,1} = xyP0_rf_fsav;
	ZP0_fsav{3,2} = xyP0_rf_tp_fsav;
	ZP0_fsav{3,3} = xyP0_rf_g_fsav;
end
%
    clear xyP0_rf_fsav xyP0_rf_tp_fsav xyP0_rf_g_fsav
end
%
% run-away rate
%
xepsi_rdke = xepsi(rdke);
Xxqtilde = repmat(xqtilde,npn,1);
Xxqhat = repmat(xqtilde,npn,1);
XxRR_fsav = 2*pi*(Xxqtilde(:,rdke)./Xxqhat(:,rdke)).*integral_dke_jd(dmhu,XXSp0_imj.*XXpn2m(:,:,rdke).*XXlambda(:,:,rdke),2);%Run-away rate
%
mask_xepsi = find(xepsi_rdke~=0);
if ~isempty(mask_xepsi)
    currB_fsav = xcurr_tot_fsav - 0.5*XxRR_fsav(npn-1,mask_xepsi)*max(v2)./xepsi_rdke(mask_xepsi);%Bulk current as defined by Karney (useful for non-zero large dc electric field only)
else
    currB_fsav = xcurr_tot_fsav;
end
Zcurr_fsav{2,1} = currB_fsav;
clear currB_fsav
%
%
Xxf0 = 0.5*integral_dke_jd(dmhu,XXf0(:,:,rdke),2);
XxfM = squeeze(XXfM(:,1,rdke));
Xxpn = repmat(pn',[1,nr_dke]);
Xxv = repmat(v',[1,nr_dke]);
%
xvth20 = 4*pi*integral_dke_jd(dpn,Xxpn.*Xxpn.*Xxv.*Xxv.*Xxf0,1)'/3;
xvth2M = 4*pi*integral_dke_jd(dpn,Xxpn.*Xxpn.*Xxv.*Xxv.*XxfM,1)'/3;
xTe_out_norm = (xvth20./xvth2M).*xTe_norm(rdke);%New bulk temperature (bulk heating)
%
%Exact trapped fraction (not the effective trapped fraction that rely on simplified plasma modeling with Maxwellian background)
%
if bounce_mode == 0,
	xft_fsav= zeros(1,nr_dke);%Fraction of trapped electrons
elseif bounce_mode == 1,
	xne_trap_fsav = integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXf0(:,:,rdke) + XXf0_g(:,:,rdke)).*~XXheaviside(:,:,rdke).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%trapped region only
	xne_tot_fsav = integral_dke_jd(dmhu,integral_dke_jd(dpn,(XXf0(:,:,rdke) + XXf0_tp(:,:,rdke) + XXf0_g(:,:,rdke)).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%
	xft_fsav = xne_trap_fsav./xne_tot_fsav;
end
%
%Effective trapped fraction 
%
if bounce_mode == 0,
	xfteff_fsav= zeros(1,nr_dke);%Effective fraction of trapped electrons
elseif bounce_mode == 1,
	xfteff_fsav = 1.5*(xBT0(rdke)./xB0(rdke)).*((xqtilde(rdke)./xqbar(rdke)).*(xBT0(rdke)./xB0(rdke)).*integral_dke_jd(dmhu,XXmhu(1,:,rdke).*XXmhu(1,:,rdke).*XXlambda_p2m2p2(1,:,rdke),2));	
	xfteff_fsav = xfteff_fsav - 1.5*(xBT0(rdke)./xB0(rdke)).*((xq(rdke)./xqbar(rdke)).*(xR0(rdke)/Rp).*integral_dke_jd(dmhu,abs(XXmhu(1,:,rdke)).*XXheaviside(1,:,rdke).*abs(XXILor(1,:,rdke)),2));
end
%
%   Magnetic ripple loss rate calculation (for Tore Supra tokamak only)
%
if sum(sum(sum(XXnhuloss))) ~= 0 & isempty(findstr(tokname,'TS')) == 0,
	xMRR_tau_ref = 2*pi*integral_dke_jd(dmhu,integral_dke_jd(dpn,XXnhuloss(:,:,rdke).*XXf0(:,:,rdke).*XXpn2(:,:,rdke).*XXlambda(:,:,rdke),1),1)';%Flux of electrons leaving the plasma through the loss cone
%
	XXmaskMRR_im = [zeros(1,nmhu,nr);abs(diff(XXnhuloss~=0))];%Mask in p (only nhuloss ~=0 is considered)
	XXmaskMRR_jm = [zeros(npn,1,nr),abs(permute(diff(permute(XXnhuloss~=0,[2,1,3])),[2,1,3]))];%Mask in mhu (mhu < 0 only because of symmetry) (only nhuloss ~=0 is considered)
	XXmaskMRR_jm(:,mhu>0,:)=0;%mhu < 0 only because of symmetry)
	XxMRR_flux_p_ref = 2*pi*integral_dke_jd(dmhum,XXmaskMRR_im(:,:,rdke).*XXSp0_imj.*XXpn2m(:,:,rdke).*XXlambda(:,:,rdke).*XXRlambda_m(:,:,rdke),2);
	XxMRR_flux_mhu_ref = 2*2*pi*integral_dke_jd(dpnm,XXmaskMRR_jm(:,:,rdke).*XXSm0_ijm.*XXpnm(:,:,rdke).*sqrt(XX1mmhu2m(:,:,rdke)).*XXlambda(:,:,rdke).*XXRlambda_m(:,:,rdke),1);
	xMRR_flux_p_ref = XxMRR_flux_p_ref(XxMRR_flux_p_ref~=0)';
	xMRR_flux_mhu_ref = XxMRR_flux_mhu_ref(XxMRR_flux_mhu_ref~=0)';
	xMRR_flux_ref = xMRR_flux_p_ref - xMRR_flux_mhu_ref;%Reduce number of points since only nhuloss ~=0 is considered
	xMRR_flux_ref =[xMRR_tau_ref(find(xMRR_tau_ref==0)),xMRR_flux_ref];%Restore the points for nhuloss =0 	
else
	xMRR_tau_ref = NaN*ones(1,nr_dke);
	xMRR_flux_ref = NaN*ones(1,nr_dke);
end
%
if display_mode >= 1,info_dke_yp(2,['Moments of the distribution function calculated in ',num2str(etime(clock,time0)),' (s)']);end


