function [XXf0,XXf0_tp,XXf0_g,XXf0_L_tp,XXf0_L_g,radial_mode,memoryLU_f,memoryLU_g] = solver_dke_yp(path,dkeparam,display,equilDKE,gridDKE,Zmomcoef,Zbouncecoef,mksa,Zpn2_t,sm_f,sm_g,sm_tp,it_rf,MMXR_f_t,MMXP_f_t,MMXT_f_t,MMXP_tp,MMXP_g_t,MMH_tp,XXILor,Xmask_r_edge,XXsinksource,XXfM,XXfinit)
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
%       - XXsinksource: normalized source/loss frequency (nhuth_ref) [np,nmhu,nr]
%       - xepsi_fsav: flux surface averaged normalized ohmic electric field (pth_ref*nhuth_ref/e) [1,nr]
%       - rdke: list of radial positions indexes at which FP or DKE are solved [1,nr_dke].  
%       - bounce: First argument: bounce averaged option, (0) no trapping, (1) trapping full implicit calculations, second argument: Fokker-Planck (0) or Drift Kinetic Equation (1 or 2) [1,2]
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
%       - invparam: structure for parameters of the matrix inversion
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
%   - trapped_fraction: exact fraction of trapped electrons ft [1,nr]
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
if nargin < 9,
    error('Wrong number of input arguments in solver_dke_yp')
end
%
time00 = clock;
timeCPU0 = cputime;
memoryLU_f = 0;
memoryLU_g = 0;
%
boundary_mode_f = dkeparam.boundary_mode_f;
boundary_mode_g = dkeparam.boundary_mode_g;
dke_mode = dkeparam.dke_mode;
bounce_mode = dkeparam.bounce_mode;
store_mode = dkeparam.store_mode;
dtn = dkeparam.dtn;
temppath = path.temppath;
prec0_f = dkeparam.prec0_f;
prec0_g = dkeparam.prec0_g;
nit_f = dkeparam.nit_f;
nit_g = dkeparam.nit_g;
%
display_mode = display.display_mode;
%
nr = gridDKE.nr;
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
nr_dke = gridDKE.nr_dke;
mhu = gridDKE.mhu;
Xdmhumm = gridDKE.Xdmhumm;
Xdmhum = gridDKE.Xdmhum;
Xdmhu = gridDKE.Xdmhu;
Xdmhup = gridDKE.Xdmhup;
Xdmhupp = gridDKE.Xdmhupp;
Xdpnmm = gridDKE.Xdpnmm;
Xdpnm = gridDKE.Xdpnm;
Xdpn = gridDKE.Xdpn;
Xdpnp = gridDKE.Xdpnp;
Xdpnpp = gridDKE.Xdpnpp;
Xmhumm = gridDKE.Xmhumm;
Xmhum = gridDKE.Xmhum;
Xmhu = gridDKE.Xmhu;
Xmhup = gridDKE.Xmhup;
Xmhupp = gridDKE.Xmhupp;
X1mmhu2m = gridDKE.X1mmhu2m;
X1mmhu2 = gridDKE.X1mmhu2;
X1mmhu2p = gridDKE.X1mmhu2p;
Xpnmm = gridDKE.Xpnmm;
Xpnm = gridDKE.Xpnm;
Xpn = gridDKE.Xpn;
Xpnp = gridDKE.Xpnp;
Xpnpp = gridDKE.Xpnpp;
Xpn2m = gridDKE.Xpn2m;
Xpn2 = gridDKE.Xpn2;
Xpn2p = gridDKE.Xpn2p;
xpsin = gridDKE.xpsin;
rdke = gridDKE.rdke;
xrho = gridDKE.rdke;
%
pn = gridDKE.pn;
pn2 = gridDKE.pn2;
pn3 = gridDKE.pn3;
xpn = gridDKE.xpn;
xpn2 = gridDKE.xpn2;
xpn3 = gridDKE.xpn3;dpn = gridDKE.dpn;
mhu = gridDKE.mhu;
dmhu = gridDKE.dmhu;
pn2 = gridDKE.pn2;
masku = gridDKE.masku;
maskl = gridDKE.maskl;
ir_display = gridDKE.ir_display_out;
%
z = Zmomcoef.z;
z2 = Zmomcoef.z2;
xz = Zmomcoef.xz;
xz2 = Zmomcoef.xz2;
gamma = Zmomcoef.gamma;
xgamma = Zmomcoef.xgamma;
sigma = Zmomcoef.sigma;
xsigma = Zmomcoef.xsigma;
J1 = Zmomcoef.J1;
J2 = Zmomcoef.J2;
J3 = Zmomcoef.J3;
J4 = Zmomcoef.J4;
xJ1 = Zmomcoef.xJ1;
xJ2 = Zmomcoef.xJ2;
xJ3 = Zmomcoef.xJ3;
xJ4 = Zmomcoef.xJ4;
%
XXheaviside = Zbouncecoef.XXheaviside;
XXRlambda_b_p1p1 = Zbouncecoef.XXRlambda_b_p1p1;
XXlambda_b_p2 = Zbouncecoef.XXlambda_b_p2;
XXlambda = Zbouncecoef.XXlambda;
Zmask_f0_t = Zbouncecoef.Zmask_f0_t;
ns_f = Zbouncecoef.ns_f; 
Zmask_g = Zbouncecoef.Zmask_g;
ns_g = Zbouncecoef.ns_g;
%
xB0 = equilDKE.xB0;               
%
betath_ref = mksa.betath_ref;
xftp_norm = mksa.xftp_norm_ref;
%
[xTe_norm,xne_norm,xzni_norm,xzTi_norm,xnloss_norm,xbetath,xlnc_e,xnhu,xrnhuth] = normcoef_dke_yp(mksa,equilDKE,gridDKE);   
%
if dtn > 0,
    time_scheme = 1;%Implicit differencing scheme
elseif dkeparam.dtn < 0,
    dtn  = abs(dtn);
    time_scheme = 2;%Crank-Nicholson differencing scheme
end 
%
if isempty(MMXR_f_t) == 0, radial_mode = 1;else radial_mode = 0;end
%
spparms('default');%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
spparms('supernd',4);%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
spparms('rreduce',4);%Set parameters for sparse matrix ordering algorithms and direct linear equation solver MatLab build-in functions only
%
%************************************************** Simulation parameter display ******************************************************** 
%
if display_mode >=1,
    disp('-------------------------------------------------------------------------------------------------------------------');
    disp('-------------------------------------------------------------------------------------------------------------------');
    disp('Kinetic calculation parameters: ');
%Numerical transient operation
    if (store_mode == 0), disp('   - Matrices storage in RAM (fast mode)');
    else                  disp('   - Matrices storage in disk file (slow mode)');end
%Matrix facorization tecnhique
    if (dkeparam.luproc == 0),  disp('   - MatLab incomplete LU matrix facorization');
    elseif (dkeparam.luproc == 1),  disp('   - MUMPS incomplete LU matrix facorization - FORTRAN 95 parallel processing');end
%Numerical matrix inversion procedure
    if (dkeparam.invproc == 1),  disp('   - MatLab CGS iterative matrix inversion method');
    elseif (dkeparam.invproc == 2),  disp('   - MatLab BICG iterative matrix inversion method');
    elseif (dkeparam.invproc == 3),  disp('   - MatLab QMR iterative matrix inversion method');
    elseif (dkeparam.invproc == -1),  disp('   - MUMPS matrix inversion - FORTRAN 95 parallel processing');end
%Boundary and normalization conditions
    if (dkeparam.norm_mode_f == 1),    disp('   - Normalization of f0 at each iteration and radius');
    elseif (dkeparam.norm_mode_f == 0),disp('   - No normalization of f0 at each iteration and radius: fully natural conservative mode');end
    if (dkeparam.boundary_mode_f >= 1),    disp(['   - Maxwellian distribution for FPE enforced on ',int2str(dkeparam.boundary_mode_f),' momentum grid point around p = 0']);
    elseif (dkeparam.boundary_mode_f == 0),disp('   - No Maxwellian distribution for FPE enforced around p = 0');end
    if (dkeparam.boundary_mode_g >= 1) & (dke_mode == 1),    disp(['   - Lorentz model distribution for DKE enforced on ',int2str(dkeparam.boundary_mode_g),' momentum grid point around p = 0']);
    elseif (dkeparam.boundary_mode_g == 0) & (dke_mode == 1),disp('   - No Lorentz model distribution for DKE enforced around p = 0');end
%Time scheme
    if (time_scheme == 1),    disp(['   - Implicit time differencing scheme']);
    elseif (time_scheme == 2),disp(['   - Crank-Nicholson time differencing scheme']);end
    disp(['   - Normalized time step: ',int2str(dkeparam.dtn)]);
%Momentum dynamics
    if (dkeparam.coll_mode == 0),     disp(['   - Collisions: Relativistic Maxwellian background']);
    elseif (dkeparam.coll_mode == 1), disp(['   - Collisions: High velocity limit']);    
    elseif (dkeparam.coll_mode == 2), disp(['   - Collisions: Linearized relativistic Belaiev-Budker']);
    elseif (dkeparam.coll_mode == 3), disp(['   - Collisions: Non-relativistic Lorentz model']);
    elseif (dkeparam.coll_mode == 4), disp(['   - Collisions: Non-relativistic Maxwellian background']);end
    if (bounce_mode == 0),      disp(['   - No bounce averaging']);
    elseif (bounce_mode == 1),  disp(['   - Bounce averaging + implicit symmetrization in the bounce domain (15 diagonals operator) for f0']);end
    if (dke_mode == 0),       disp(['   - Resolution of the electron Fokker-Planck Equation']);
    elseif (dke_mode == 1),   disp(['   - Resolution of the electron Drift Kinetic Equation']);end
%Spatial dynamics
    if (radial_mode == 1),      disp(['   - Fast electron radial diffusion or pinch']);
    elseif (radial_mode == 0),  disp(['   - No fast electron radial diffusion or pinch']);end
%
    disp(['   - Momentum grid: ',int2str(npn)]);
    disp(['   - Angular grid: ',int2str(nmhu)]);
    disp(['   - Total radial grid: ',int2str(nr)]);
    disp(['   - Effective radial grid: ',int2str(nr_dke)]);
    disp('-------------------------------------------------------------------------------------------------------------------');
end
%
normf0 = zeros(nr,nit_f);
normf1 = zeros(nr,nit_f);
curr0 = zeros(nr,nit_f);
curr1 = zeros(nr,nit_f);
prec_curr = zeros(nr,nit_f);
prec_normf = zeros(nr,nit_f);
residu_f = ones(nr,nit_f);
prec_residu_f = ones(nr,nit_f);
residu_g = ones(nr_dke,nit_g);
prec_residu_g = ones(nr_dke,nit_g);
%
XXI = zeros(npn,nmhu,nr);
XXI_g = zeros(npn,nmhu,nr);
XXf0 = zeros(npn,nmhu,nr);
XXf0_tp = zeros(npn,nmhu,nr);
XXf0_g = zeros(npn,nmhu,nr);
XXf0_L_tp = zeros(npn,nmhu,nr);
XXf0_L_g = zeros(npn,nmhu,nr);  
XXf0_g_th = zeros(npn,nmhu,nr);
%
time0 = clock;
%
MMXdiag = diag(MMXP_f_t/time_scheme + MMXR_f_t/time_scheme + MMXT_f_t);
if isempty(find(MMXdiag==0)) == 1, 
    MMXPDI_f_t = inv(diag(MMXdiag));
    MMXPC_f_t = MMXPDI_f_t*(MMXP_f_t/time_scheme + MMXR_f_t/time_scheme + MMXT_f_t);%Main diagonal matrix preconditionning
%
    if dkeparam.luproc == 0,%MatLab build-in matrix incomplete factorization
       [MMXL_f_t,MMXU_f_t] = luinc(MMXPC_f_t,dkeparam.ludroptol); 
    elseif dkeparam.luproc == 1;%HYPRE matrix incomplete factorization
       [dummy1,dummy2,MMXL_f_t,MMXU_f_t] = HYPRE_dke_yp(dkeparam.HYPREparam,MMXPC_f_t,[],dkeparam.ludroptol,temppath);
    end
%
    time_f = etime(clock,time0);
    if dkeparam.luproc >= 0,
       memoryLU_f = (getfield(whos('MMXL_f_t'),'bytes') + getfield(whos('MMXU_f_t'),'bytes'))/1000000;
    end
else
    error('Fokker-Planck matrix has a null element on the main diagonal');%Matrix must be main diagonal dominant
end
%
if dke_mode == 1,
    time0 = clock;  
    MMXPDI_g_t = inv(diag(diag(MMXP_g_t)));
    MMXPC_g_t = MMXPDI_g_t*MMXP_g_t;%Main diagonal matrix preconditionning
%
    if dkeparam.luproc == 0,%MatLab build-in matrix incomplete factorization
       [MMXL_g_t,MMXU_g_t] = luinc(MMXPC_g_t,dkeparam.ludroptol); 
    elseif dkeparam.luproc == 1;%HYPRE matrix incomplete factorization
       [dummy1,dummy2,MMXL_f_t,MMXU_f_t] = HYPRE_dke_yp(dkeparam.HYPREparam,MMXPC_f_t,[],dkeparam.ludroptol,temppath);
    end
%
    time_g = etime(clock,time0);
    if dkeparam.luproc >= 0,
       memoryLU_g = (getfield(whos('MMXL_g_t'),'bytes') + getfield(whos('MMXU_g_t'),'bytes'))/1000000;
    end
end
%
if display_mode >= 1,   
    if dkeparam.luproc >= 0,
        info_dke_yp(2,['Size of the LU matrices for f: ',num2str(memoryLU_f),' MBytes']);
        info_dke_yp(2,['Full elapsed time of LU matrix factorization for f: ',num2str(time_f),' (s)']);
    else
        info_dke_yp(2,'Direct matrix inversion, no LU matrix factorization');
    end
    if dke_mode == 1,
        if dkeparam.luproc >= 0,
            info_dke_yp(2,['Size of the LU matrices for g: ',num2str(memoryLU_g),' MBytes']);
            info_dke_yp(2,['Full elapsed time of LU matrix factorization for g: ',num2str(time_g),' (s)']);
        else
            info_dke_yp(2,'Direct matrix inversion, no LU matrix factorization');
        end
    end
end
%
if display_mode == 2,
    figure('Name','Momentum space matrix'),spy(MMXP_f_t);
    zoom on;
    axis('square');
    title('Momentum space matrix');
%
    if radial_mode == 1,
        figure('Name','Configuration space matrix'),spy(MMXR_f_t);
        zoom on;
        axis('square');
        title('Configuration space matrix');    
    end
%
    figure('Name','Total preconditionned matrix'),spy(MMXPC_f_t);
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
time0 = clock;
XXf0 = XXfinit;%Initial guess (normalized to xne_norm)
for ir = 1:nr,
    normf0(ir,1) = 2*pi*integral_dke_jd(dpn',pn2'.*integral_dke_jd(dmhu,XXfinit(:,:,ir),2),1);
    curr0(ir,1) = 2*pi*integral_dke_jd(dpn',pn2'.*(pn'./gamma').*integral_dke_jd(dmhu,Xmhu.*XXfinit(:,:,ir),2),1)*xne_norm(ir)/normf0(ir,1);
end
%
if display_mode == 2,
	Fig_FPEconvstatus = figure('Name','Fokker-Planck equation convergence status');
end
%
for it_f = 2:(nit_f+1),     
    if sum(residu_f(:,it_f-1) >= prec0_f) >= 1 %& sum(prec_residu_f(:,it_f-1)) >= prec0_f ,%| it_f < 7
%   
        MMXf0_t = [];
        MMXq_t = [];
        MMXIpn2_t = [];
        MMXsource_t = [];
%
        if store_mode == 1,
           load([fullfile(temppath,'MXP_'),save_id,'.mat'],'Zmask_f0_t');
        end 
%
        for ir = 1:nr-1,
            XI_t = XXI(:,Zmask_f0_t{ir},ir);
%
            if boundary_mode_f > 0,
                XI_t(1:boundary_mode_f,:) = 0;
            end
%
        
            MMXf0_t = [MMXf0_t;reshape(XXf0(:,Zmask_f0_t{ir},ir)',(nmhu - ns_f(ir))*npn,1)];
            MMXsource_t = [MMXsource_t;reshape(XXsinksource(:,Zmask_f0_t{ir},ir)',(nmhu - ns_f(ir))*npn,1)];
            MMXIpn2_t = [MMXIpn2_t;reshape((XI_t.*Zpn2_t{ir})',(nmhu - ns_f(ir))*npn,1)];%Zpn2_t is here as part of the partial Jacobian used to avoid singularities at p = 0 and psi = 0, and for pitch-angle derivative df/dmhu = 0 enforced by symmetry at mhu == pi/2
        end 
%
       if 1,%isempty(Xmask_r_edge),%No anomalous radial transport
           XI_t = XXI(:,Zmask_f0_t{nr},nr);
           if boundary_mode_f > 0,
               XI_t(1:boundary_mode_f,:) = 0;
           end
%
           
           MMXf0_t = [MMXf0_t;reshape(XXf0(:,Zmask_f0_t{nr},nr)',(nmhu - ns_f(nr))*npn,1)];
           MMXsource_t = [MMXsource_t;reshape(XXsinksource(:,Zmask_f0_t{nr},nr)',(nmhu - ns_f(nr))*npn,1)];
           MMXIpn2_t = [MMXIpn2_t;reshape((XI_t.*Zpn2_t{nr})',(nmhu - ns_f(nr))*npn,1)];%Zpn2_t is here as part of the partial Jacobian used to avoid singularities at p = 0 and psi = 0, and for pitch-angle derivative df/dmhu = 0 enforced by symmetry at mhu == pi/2

       else,%Edge radial boundary condition: f(r/a = 1) = fM(r/a) where transport operates
           MMXf0_t = [MMXf0_t;reshape(XXf0(:,Zmask_f0_t{nr},nr)',(nmhu - ns_f(nr))*npn,1)];
%       MMXq_t(nMMXP_f_t-npn*(nmhu - ns_f(nr))+1:nMMXP_f_t) = xrho(nr)*time_scheme*reshape((Xf0_t'.*~Xmask_r_edge_t' + XfM_t'.*Xmask_r_edge_t').*Xpn2_t',(nmhu - ns(nr))*npn,1)/dtn;
		   Xmask_r_edge_t = Xmask_r_edge(:,Zmask_f0_t{nr});  
           MMXsource_t = [MMXsource_t;reshape(XXsinksource(:,Zmask_f0_t{nr},nr)',(nmhu - ns_f(nr))*npn,1)];
           MMXIpn2_t = [MMXIpn2_t;reshape((XI_t.*Zpn2_t{nr})',(nmhu - ns_f(nr))*npn,1)];%Zpn2_t is here as part of the partial Jacobian used to avoid singularities at p = 0 and psi = 0, and for pitch-angle derivative df/dmhu = 0 enforced by symmetry at mhu == pi/2          
       end
%
        MMXq_t = MMXsource_t + MMXIpn2_t + (MMXT_f_t - (time_scheme - 1)*(MMXP_f_t + MMXR_f_t)/time_scheme)*MMXf0_t;%Right handside term of the Fokker-Planck equation          
        MMXR_t = sparse(MMXPDI_f_t*MMXq_t - MMXPC_f_t*MMXf0_t);%Residu calculation for matrix inversion, force sparse type for the RHS, optimized for Matlab 
%
        if dkeparam.invproc == 0,%Matlab direct inversion
            MMXS_t = MMXR_t\MMXPC_f_t;
        elseif dkeparam.invproc == 1,%Matlab cgs iterative inversion method
            [MMXS_t,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);
        elseif dkeparam.invproc == 2,%Matlab bicg iterative inversion method      
            [MMXS_t,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t); 
        elseif dkeparam.invproc == 3,%Matlab qmr iterative inversion method
            [MMXS_t,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);
        elseif dkeparam.invproc == -1,%MUMPS FORTAN 95 parallel processing package (direct inversion)
            [MMXS_t,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),display_mode,path);
        elseif dkeparam.invproc == -2,%HYPRE FORTAN 95 parallel processing package (direct inversion)
%            [MMXS_t,dummy1,dummu2,flaginv_f] = HYPRE_dke_yp(dkeparam.HYPREparam,MMXPC_f_t,MMXR_t,dkeparam.ludroptol,temppath);
        end
%
        if flaginv_f == 2 & dkeparam.invproc > 1,
            error('WARNING: Matrix ill-conditionned. No inversion possible for the zero order Fokker-Planck equation. Try to reduce drop tolerance parameter for LU factorization...!');
        elseif flaginv_f ~= 0 & dkeparam.invproc == -1,
            error(['WARNING: Error ',int2str(flaginv_f),' in MUMPS matrix inversion for the zero order Fokker-Planck equation. See MUMPS documentation !']);
        elseif flaginv_f ~= 0 & dkeparam.invproc == -2,
            error(['WARNING: Error ',int2str(flaginv_f),' in HYPRE matrix inversion for the zero order Fokker-Planck equation. See HYPRE documentation !']);
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
            	 disp(' ');           	 
                info_dke_yp(2,['Quasilinear iteration : ',int2str(it_rf),', Fokker-Planck iteration : ',int2str(it_f-1),' / ',int2str(nit_f),', Residu = ',num2str(residu_f(ir,it_f)),' / ',num2str(prec0_f)]);
                info_dke_yp(2,['   Normalized poloidal magnetic flux: ',num2str(xpsin(ir))]);
                info_dke_yp(2,['      Normalized radius on LFS midplane: ',num2str(xrho(ir)),' / Radius index number: ',int2str(ir)]);
                disp(['                - Density [t-1]: ',num2str(normf0(ir,it_f-1)),' - [t]: ',num2str(normf1(ir,it_f)),' / Relative variation [t-t0]: ',num2str(prec_normf(ir,it_f)),' / Absolute variation [dt]: ',num2str(normf1(ir,it_f) - normf0(ir,it_f))]);               
                disp(['                - Current [t-1]: ',num2str(curr0(ir,it_f-1)),' - [t]: ',num2str(curr1(ir,it_f)),' / Current relative accuracy [dt]: ',num2str(prec_curr(ir,it_f))]);
            end
%
            if display_mode == 2,
                if dke_mode == 1,
                    if ir == ir_display-1,
                        figure(Fig_FPEconvstatus),subplot(321),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
                        axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
                        title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
                        hold on;zoom on
                        figure(Fig_FPEconvstatus),subplot(322),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
                        axis('square');axis([0,it_f,prec0_f/10,1e-4]);
                        title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
                        hold on;zoom on
                        drawnow;
                    elseif ir == ir_display,
                        figure(Fig_FPEconvstatus),subplot(323),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
                        axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
                        title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
                        hold on;zoom on
                        figure(Fig_FPEconvstatus),subplot(324),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
                        axis('square');axis([0,it_f,prec0_f/10,1e-4]);
                        title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
                        hold on;zoom on
                        drawnow;
                    elseif ir == ir_display+1,
                        figure(Fig_FPEconvstatus),subplot(325),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
                        axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
                        title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
                        hold on;zoom on
                        figure(Fig_FPEconvstatus),subplot(326),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
                        axis('square');axis([0,it_f,prec0_f/10,1e-4]);
                        title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
                        hold on;zoom on
                        drawnow;
                    end
                else
                    if ir == ir_display,
                        figure(Fig_FPEconvstatus),subplot(121),semilogy(-pn,XXfM(:,2,ir),'g--',pn,XXfM(:,nmhu-1,ir),'g--',-pn,Xf1(:,2),'r-',pn,Xf1(:,nmhu-1),'r-');%f(perp = 0)
                        axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
                        title(['Iteration: ',int2str(it_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
                        hold on;
                        figure(Fig_FPEconvstatus),subplot(122),semilogy([1:it_f],residu_f(ir,1:it_f),'r+',[1:it_f],max(residu_f(:,1:it_f)),'gx',[1:it_f],prec0_f*ones(size([1:it_f])),'b--');
                        axis('square');axis([0,it_f,prec0_f/10,1e-4]);
                        title(['Convergence - f (rho=',num2str(xrho(ir)),')']);xlabel('Iteration');ylabel('Residu')
                        hold on;
                        drawnow;
                    end
                end
            end
%
            if dkeparam.coll_mode == 2,%Belaiev-Budker collision operator
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
            if dkeparam.norm_mode_f == 1,
                XXf0(:,:,ir) = xne_norm(ir)*Xf1/normf1(ir,it_f);%Normalization to the local density
            else
                XXf0(:,:,ir) = Xf1;%The default value in principle. If OK, tells that the numerical conservative scheme is correct
            end
%
            normf0(ir,it_f) = normf1(ir,it_f);
            curr0(ir,it_f) = curr1(ir,it_f);
%           
        end
    else            
        if sum(prec_residu_f(:,it_f-1)) < prec0_f,info_dke_yp(2,['WARNING: stationnary residu but convergence not achieved for f0 after ',int2str(it_f),' iterations. Time step likely too large !']);end
        if sum(residu_f(:,it_f-1) >= prec0_f) == 0 & display_mode > 0,
            info_dke_yp(2,['Successfull convergence achieved for f0 after ',int2str(it_f-2),' iterations !']);
        end
        break;
    end
    if it_f == nit_f,info_dke_yp(2,['WARNING: convergence not achieved for f0 after ',int2str(nit_f),' iterations. Time step too small !']);end
end
if display_mode >= 1,info_dke_yp(2,['Convergence achieved for zero order Fokker-Planck calculations in ',num2str(etime(clock,time0)),' (s)']);end
if dkeparam.invproc == -1 & display_mode >= 1,info_dke_yp(2,['Number of processors used for MUMPS matrix inversion : ',int2str(dkeparam.MUMPSparam.nproc)]);end%MUMPS FORTAN 95 parallel processing package
%
clear ir fM XfM MMXPC_f_t MMXPDI_f_t Xmask_f0 MMXL_f_t MMXU_f_t
clear Xf0 Xf0_t Xq Xq_t Xf1 Xf1_t Xf1_tp Xf1_tm Xf1_ts XR_t XS_t XY_t
clear f1 xf1 I1 I2 XI 
%
if display_mode == 2,
    figure(Fig_FPEconvstatus),subplot(121),hold off;
    figure(Fig_FPEconvstatus),subplot(122),hold off;
end
% 
time0 = clock;
%
if dke_mode == 1,
	if display_mode == 2,
		Fig_DKEconvstatus = figure('Name','Drift kinetic equation convergence status');
	end	
%
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
            load([fullfile(temppath,'MXP_'),save_id,'.mat'],'Zmask_g');
        end
%                   
        dpsim = (xpsin(jr1) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)
        dpsi = (xpsin(jr3) - xpsin(jr1));%Radial step for parabolic gradient calculations (dke)
        dpsip = (xpsin(jr3) - xpsin(jr2));%Radial step for parabolic gradient calculations (dke)      
%
        %if dkeparam.coll_mode == 3,%Normalized gradients of ne and Te for the Lorentz model (test mode only, see documentation)
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
        if dkeparam.coll_mode == 2,%Belaiev-Budker collision operator
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
%    MMXq_tp_c = -MMH_tp*reshape(permute(XXf0,[2,1,3]),npn*nmhu*nr,1,1); 
%
    for ir_dke = 1:nr_dke,%Remove trapped region at jr2
        Xq_tp = reshape(MMXq_tp(sm_tp(ir_dke)+1:sm_tp(ir_dke+1)),nmhu,npn)';
%        Xq_tp_c = reshape(MMXq_tp_c(npn*nmhu*rdke(ir_dke)+1:npn*nmhu*(rdke(ir_dke)+1)),nmhu,npn)';
        if boundary_mode_g ~= 0,
            Xq_tp(1:boundary_mode_g,:) = zeros(1:boundary_mode_g,nmhu);%Boundary conditions at p = 0 enforced for g
%            Xq_tp_c(1:boundary_mode_g,:) = zeros(1:boundary_mode_g,nmhu);%Boundary conditions at p = 0 enforced for g
        end
 %      MMXq_tp_t = [MMXq_tp_t;reshape(Xq_tp(:,Zmask_g{ir_dke})' + Xq_tp_c(:,Zmask_g{ir_dke})',(nmhu - ns_g(ir_dke))*npn,1)];%Matrix reduction since the trapped region is removed
        MMXq_tp_t = [MMXq_tp_t;reshape(Xq_tp(:,Zmask_g{ir_dke})',(nmhu - ns_g(ir_dke))*npn,1)];%Matrix reduction since the trapped region is removed
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
            MMXR_t = sparse(MMXPDI_g_t*(MMXq_g_t + MMXq_tp_t) - MMXPC_g_t*MMXf0_g_t);%Force sparse tyep for the RHS, optmized for Matlab
%        
            if dkeparam.invproc == 0,%Matlab direct inversion
               MMXS_t = MMXR_t\MMXPC_g_t;
            elseif dkeparam.invproc == 1,%cgs iterative method
               [MMXS_t,flaginv_g] = cgs(MMXPC_g_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_g_t,MMXU_g_t);
            elseif dkeparam.invproc == 2,%bicg iterative method      
               [MMXS_t,flaginv_g] = bicg(MMXPC_g_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_g_t,MMXU_g_t); 
            elseif dkeparam.invproc == 3,%qmr iterative method
               [MMXS_t,flaginv_g] = qmr(MMXPC_g_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_g_t,MMXU_g_t);
            elseif dkeparam.invproc == -1,%MUMPS FORTAN 95 parallel processing package (direct inversion)
               [MMXS_t,flaginv_g] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_g_t,full(MMXR_t),display_mode,temppath);
            elseif dkeparam.invproc == -2,%HYPRE FORTAN 95 parallel processing package (direct inversion)
%               [MMXS_t,flaginv_g] = HYPRE_dke_yp(dkeparam.HYPREparam,MMXPC_g_t,MMXR_t,dkeparam.ludroptol,temppath);
            end
%
            if flaginv_g == 2 & dkeparam.invproc > 1,
               error('WARNING: Matrix ill-conditionned. No inversion possible for the first order Fokker-Planck equation. Try to reduce drop tolerance parameter for LU factorization...!');
            elseif flaginv_g ~= 0 & dkeparam.invproc == -1,
               error(['WARNING: Error ',int2str(flaginv_g),' in MUMPS matrix inversion for the first order Fokker-Planck equation. See MUMPS documentation !']);
            elseif flaginv_g ~= 0 & dkeparam.invproc == -2,
               error(['WARNING: Error ',int2str(flaginv_g),' in HYPRE matrix inversion for the first order Fokker-Planck equation. See HYPRE documentation !']);
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
                    info_dke_yp(2,['Drift kinetic iteration : ',int2str(it_g),' / ',int2str(nit_g),', Residu = ',num2str(residu_g(ir_dke,it_g))]);
                    info_dke_yp(2,['   Normalized poloidal magnetic flux: ',num2str(xpsin(jr2))]);
                    info_dke_yp(2,['      Normalized radius on LFS midplane: ',num2str(xrho(jr2)),' / Radius index number: ',int2str(jr2)]);
                end
%
                if jr2 == ir_display & display_mode == 2,
                    figure(Fig_DKEconvstatus),subplot(121),plot(-pn,Xf1_g(:,1),'r-',pn,Xf1_g(:,nmhu),'r-');%g(perp = 0)
                    axis('square');set(gca,'xlim',[-10,10]);
                    title(['Iteration: ',int2str(it_g)]);xlabel('pn-ref');ylabel('g(pperp=0)')
                    hold on;zoom on
                    figure(Fig_DKEconvstatus),subplot(122),semilogy([1:it_g],residu_g(ir_dke,1:it_g),'r+',[1:it_g],max(residu_g(:,1:it_g)),'gx',[1:it_g],prec0_g*ones(size([1:it_g])),'b--');
                    axis('square');axis([0,it_g,prec0_g/10,1e-4]);
                    title(['Convergence - g (rho=',num2str(xrho(jr2)),')']);xlabel('Iteration');ylabel('Residu')
                    hold on;zoom on
                    drawnow;
                end
%
%First order Legendre correction for g
%
                if dkeparam.coll_mode == 2,%Belaiev-Budler collision operator
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
    if dkeparam.invproc == -1 & display_mode >= 1,info_dke_yp(2,['Number of processors used for MUMPS matrix inversion : ',int2str(dkeparam.MUMPSparam.nproc)]);end%MUMPS FORTAN 95 parallel processing package
else
    XXf0_tp = zeros(size(XXf0));
    XXf0_g = zeros(size(XXf0));
end
%  
if dkeparam.coll_mode == 3 & dke_mode == 1,%Lorentz model (test mode only, see documentation)
    for ir_dke = 1:nr_dke,
        jr2 = rdke(ir_dke);
        XXf0_L_tp(:,:,jr2) = -xftp_norm(jr2)*(xdlnnedpsi(jr2) + xdlnTedpsi(jr2)*(Xpn2/xTe_norm(jr2)/2 - 1.5)).*Xpn.*Xmhu.*XXfM(:,:,jr2);
        XXf0_L_g(:,:,jr2) =  xftp_norm(jr2)*(xdlnnedpsi(jr2) + xdlnTedpsi(jr2)*(Xpn2/xTe_norm(jr2)/2 - 1.5)).*Xpn.*(Xmhu./abs(Xmhu)).*XXfM(:,:,jr2).*abs(XXILor(:,:,jr2));%Signe ********
    end 
end 
%
if display_mode == 2,
    if dke_mode == 1,
%           
        XfM = XXfM(:,:,ir_display-1);
        Xf0 = XXf0(:,:,ir_display-1);
        Fig_Finalconvstatus = figure('Name','Final convergence status');subplot(321),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
        axis('square');axis([-max(pn),max(pn),1e-20,10]);zoom on
        title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
        hold on;zoom on
        figure(Fig_Finalconvstatus),subplot(322),plot([1:nit_f],curr1(ir_display-1,:),'r-');
        axis('square');if max(max(curr1(ir_display-1,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display-1,:)))]);end
        title('Convergence');xlabel('Iteration');ylabel('Current')
        hold on;zoom on
        drawnow;
%
        XfM = XXfM(:,:,ir_display);
        Xf0 = XXf0(:,:,ir_display);
        figure(Fig_Finalconvstatus),subplot(323),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
        axis('square');axis([-max(pn),max(pn),1e-20,10]);zoom on
        title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
        hold on;zoom on
        figure(Fig_Finalconvstatus),subplot(324),plot([1:nit_f],curr1(ir_display,:),'r-');
        axis('square');if max(max(curr1(ir_display,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display,:)))]);end
        title('Convergence');xlabel('Iteration');ylabel('Current')
        hold on;zoom on
        drawnow;
%
        XfM = XXfM(:,:,ir_display+1);
        Xf0 = XXf0(:,:,ir_display+1);
        figure(Fig_Finalconvstatus),subplot(325),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
        axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
        title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
        hold on;zoom on
        figure(Fig_Finalconvstatus),subplot(326),plot([1:nit_f],curr1(ir_display+1,:),'r-');
        axis('square');if max(max(curr1(ir_display+1,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display+1,:)))]);end
        title('Convergence');xlabel('Iteration');ylabel('Current')
        hold on;zoom on
        drawnow;
    else
        XfM = XXfM(:,:,ir_display);
        Xf0 = XXf0(:,:,ir_display);
%
        Fig_Finalconvstatus = figure('Name','Final convergence status');
        figure(Fig_Finalconvstatus),subplot(121),semilogy(-pn,XfM(:,2),'g--',pn,XfM(:,nmhu-1),'g--',-pn,Xf0(:,2),'r-',pn,Xf0(:,nmhu-1),'r-');%f(perp = 0)
        axis('square');axis([-max(pn),max(pn),1e-20,10]),zoom on
        title(['Iteration: ',int2str(nit_f)]);xlabel('pn-ref');ylabel('f(pperp=0)')
        hold on;
        figure(Fig_Finalconvstatus),subplot(122),plot([1:nit_f],curr1(ir_display,:),'r-');
        axis('square');if max(max(curr1(ir_display,:))) ~= 0,axis([0,nit_f,0,1.1*max(max(curr1(ir_display,:)))]);end
        title('Current convergence');xlabel('Iteration');ylabel('Current')
        hold on;
        drawnow;
    end
end
%
if display_mode >= 1,info_dke_yp(2,['Full DKE equation solved in ',num2str(etime(clock,time00)),' (s)']);end
