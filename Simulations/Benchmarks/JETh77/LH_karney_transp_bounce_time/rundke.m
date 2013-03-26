%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
%
opt_proc = 0;%test for numerical performance test with number of processors 
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_transp_bounce_time';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0:0.025:0.65,0.7:0.1:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'JETh77';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = 'magneticturbulence';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
wavestruct.omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit opt_lh > 0
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
wavestruct.opt_lh = 2; % [1,1]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
wavestruct.norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
wavestruct.yD0_in_c_lh = [2];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [1];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [0.4];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [0.1];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
wavestruct.ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.dtn = 10;%Normalized integration time step
dkeparam.nit_f = 1;%Maximum number of internal iterations for f (>= 1)
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
ntime_step = 10;%number of time steps
%
transpfaste.Dr0 = 0;
%
% Initial magnetic equilibrium (JETh77)
%
R_sep(1) = 3.0;%  Geometrical major radius of the separatrix (m)
a_sep(1) = 0.9;%  Geometrical minor radius of the separatrix (m)
Z_sep(1) = 0.0;%  Geometrical vertical shift of the separatrix (m)
%
xpoint(1,1) = 1.687;%Upper altitude X point in minor radius unit
xpoint(2,1) = 0.466;%Upper triangularity in minor radius unit
xpoint(3,1) = 0;%Upper separatrix angle (R,X)  (LFS, degrees)
xpoint(4,1) = 0;%Upper separatrix angle (-R,X) (HFS, degrees)
xpoint(5,1) = 2.001;%Lower altitude X point in minor radius unit (always positive)
xpoint(6,1) = 0.568;%Lower triangularity in minor radius unit
xpoint(7,1) = 22.46;%Lower separatrix angle (R,X)  (LFS, degrees)
xpoint(8,1) = 67.92;%Lower separatrix angle (-R,X)  (HFS, degrees)
%
npsi(1) = 101;%ONLY 101 radial profile grid points for HELMEX77
ntheta(1) = 65;%ONLY 65 poloidal grid points for HELMEX77
%
Ip(1) = 2;%  Plasma current (MA)  
%
qmin(1) = 1;%  Safety factor q0 at plasma center
eq(1) = 3;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
qopt(1) = 1;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
%
Bt(1) = 3.5;%  Toroidal magnetic field on the magnetic axis (T) 
%
% Kinetic parameters (profiles)
%
Zi(1,:) =  [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi(1,:) =  [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi(1,:) =  [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0(1) = 5;%  Core electron temperature (keV)
Tea(1) = 0.5;%  Edge electron temperature (keV)
eTe1(1) = 2;%  Exponent #1 for Te profile 
eTe2(1) = 2;%  Exponent #2 for Te profile 
%
ne0(1) = 2.0e19;%  Core electron density (m-3)
nea(1) = 2.0e17;%  Edge electron density (m-3)
ene1(1) = 2;%  Exponent #1 for ne profile 
ene2(1) = 0.5;%  Exponent #2 for ne profile
%
Ti0(1) = 2;%  Core ion temperature (keV)
Tia(1) = 0.2;%  Edge ion temperature (keV)
eTi1(1) = 2;%  Exponent #1 for Ti profile
eTi2(1) = 2;%  Exponent #2 for Ti profile
%
Zeff0(1) = 1.5;%  Core effective charge (a.u.)
Zeffa(1) = 1.5;%  Edge effective charge (a.u.)
eZeff(1) = 0;%  Define the slope at the radial point where the derivative is maximum (must be >> 1)
xZeff(1) = 0.5;%Radial normalized position at which the derivative is maximum
%
[ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(a_sep(1),R_sep(1),Z_sep(1),Bt(1),Ip(1),qmin(1)*R_sep(1)/a_sep(1),eq(1),qopt(1),npsi(1),ntheta(1));%Cylindrical magnetic equilibrium
%
[prho,pTe,pne,pzTi,pzni,zZi,zmi,fi,pkin] = idealprof_yp(Zi(1,:),mi(1,:),fi(1,:),Te0(1),Tea(1),eTe1(1),eTe2(1),ne0(1),nea(1),ene1(1),ene2(1),Ti0(1),Tia(1),eTi1(1),eTi2(1),Zeff0(1),Zeffa(1),eZeff(1),xZeff(1),npsi(1));%Profiles
%
pj_min = min(pj); 
if pj_min < 0,pj = pj - pj_min;end,%pj must be non-negative. Only the shape is considered and Ip for the total plasma current
[equil_magnetic,prho_out,pspsin_out,pspsinT_out,pp_out] = equil_magnetic_helmex77_yp(a_sep(1),R_sep(1),Z_sep(1),xpoint(:,1),Bt(1),Ip(1),ppsi_apRp*R_sep(1)/a_sep(1),pj,pkin,ntheta(1),0);
%
equil_prof.pTe = pTe;
equil_prof.pne = pne;
equil_prof.pzTi = pzTi;
equil_prof.pzni = pzni;
equil_prof.zZi = zZi;
equil_prof.zmi = zmi;
%
clear equil
%
equil{1} = conc_struct_jd(equil_magnetic,equil_prof);
equil{1}.id = id_equil;
%
equilibrium_jd(equil{1},'',2,'linear',50);
drawnow
%
% Magnetic equilibrium independent of time (fixed equilibrium)
%
waves{1} = make_idealLHwave_jd(equil{1},wavestruct);
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,dkepath,equil{1},dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
j_fe(:,1) = Zcurr.x_0;
P_fe(:,1) = ZP0.x_rf_fsav;
Itot_fe(1) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
Ptot_2piRp_fe(1) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
%
for it = 2:ntime_step,
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,dkepath,equil{1},dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out.Zf0_interp,[]);
    %
    j_fe(:,it) = Zcurr.x_0;
    P_fe(:,it) = ZP0.x_rf_fsav;
    Itot_fe(it) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
    Ptot_2piRp_fe(it) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
end
%
% Magnetic equilibrium evolves with time (variable equilibrium)
%
waves{1} = make_idealLHwave_jd(equil{1},wavestruct);
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,dkepath,equil{1},dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
j_ve(:,1) = Zcurr.x_0;
P_ve(:,1) = ZP0.x_rf_fsav;
Itot_ve(1) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
Ptot_2piRp_ve(1) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
%
% Other time steps
% 
for it = 2:ntime_step,
    R_sep(it) = 3.0 - 1.5*(it/ntime_step);%  Geometrical major radius of the separatrix (m)
    a_sep(it) = 0.9;%  Geometrical minor radius of the separatrix (m)
    Z_sep(it) = 0.0;%  Geometrical vertical shift of the separatrix (m)
    %
    xpoint(1,it) = 1.687;%Upper altitude X point in minor radius unit
    xpoint(2,it) = 0.466;%Upper triangularity in minor radius unit
    xpoint(3,it) = 0;%Upper separatrix angle (R,X)  (LFS, degrees)
    xpoint(4,it) = 0;%Upper separatrix angle (-R,X) (HFS, degrees)
    xpoint(5,it) = 2.001;%Lower altitude X point in minor radius unit (always positive)
    xpoint(6,it) = 0.568 - 0.102*(it/ntime_step);%Lower triangularity in minor radius unit
    xpoint(7,it) = 22.46 - 22.46*(it/ntime_step);%Lower separatrix angle (R,X)  (LFS, degrees)
    xpoint(8,it) = 67.92 - 67.92*(it/ntime_step);%Lower separatrix angle (-R,X)  (HFS, degrees)
    %
    npsi(it) = 101;%ONLY 101 radial profile grid points for HELMEX77
    ntheta(it) = 65;%ONLY 65 poloidal grid points for HELMEX77
    %
    Ip(it) = 2;%  Plasma current (MA)  
    %
    qmin(it) = 1;%  Safety factor q0 at plasma center
    eq(it) = 3;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
    qopt(it) = 1;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
    %
    Bt(it) = 3.5;%  Toroidal magnetic field on the magnetic axis (T) 
    %
    % Kinetic parameters (profiles)
    %
    Zi(it,:) =  [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
    mi(it,:) =  [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
    fi(it,:) =  [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
    %
    Te0(it) = 5;%  Core electron temperature (keV)
    Tea(it) = 0.5;%  Edge electron temperature (keV)
    eTe1(it) = 2;%  Exponent #1 for Te profile 
    eTe2(it) = 2;%  Exponent #2 for Te profile 
    %
    ne0(it) = 2.0e19;%  Core electron density (m-3)
    nea(it) = 2.0e17;%  Edge electron density (m-3)
    ene1(it) = 2;%  Exponent #1 for ne profile 
    ene2(it) = 0.5;%  Exponent #2 for ne profile
    %
    Ti0(it) = 2;%  Core ion temperature (keV)
    Tia(it) = 0.2;%  Edge ion temperature (keV)
    eTi1(it) = 2;%  Exponent #1 for Ti profile
    eTi2(it) = 2;%  Exponent #2 for Ti profile
    %
    Zeff0(it) = 1.5;%  Core effective charge (a.u.)
    Zeffa(it) = 1.5;%  Edge effective charge (a.u.)
    eZeff(it) = 0;%  Define the slope at the radial point where the derivative is maximum (must be >> 1)
    xZeff(it) = 0.5;%Radial normalized position at which the derivative is maximum
    %
    [ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(a_sep(it),R_sep(it),Z_sep(it),Bt(it),Ip(it),qmin(it)*R_sep(it)/a_sep(it),eq(it),qopt(it),npsi(it),ntheta(it));%Cylindrical magnetic equilibrium
    %
    [prho,pTe,pne,pzTi,pzni,zZi,zmi,fi,pkin] = idealprof_yp(Zi(it,:),mi(it,:),fi(it,:),Te0(it),Tea(it),eTe1(it),eTe2(it),ne0(it),nea(it),ene1(it),ene2(it),Ti0(it),Tia(it),eTi1(it),eTi2(it),Zeff0(it),Zeffa(it),eZeff(it),xZeff(it),npsi(it));%Profiles
    %
    pj_min = min(pj); 
    if pj_min < 0,pj = pj - pj_min;end,%pj must be non-negative. Only the shape is considered and Ip for the total plasma current
    [equil_magnetic,prho_out,pspsin_out,pspsinT_out,pp_out] = equil_magnetic_helmex77_yp(a_sep(it),R_sep(it),Z_sep(it),xpoint(:,it),Bt(it),Ip(it),ppsi_apRp*R_sep(it)/a_sep(it),pj,pkin,ntheta(it),0);
    %
    equil_prof.pTe = pTe;
    equil_prof.pne = pne;
    equil_prof.pzTi = pzTi;
    equil_prof.pzni = pzni;
    equil_prof.zZi = zZi;
    equil_prof.zmi = zmi;
    %
    equil{it} = conc_struct_jd(equil_magnetic,equil_prof);
    equil{it}.id = id_equil;
    %
    equilibrium_jd(equil{it},'',2,'linear',50);
    drawnow
    %
    waves{1} = make_idealLHwave_jd(equil{it},wavestruct);
    %
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,dkepath,equil{it},dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out.Zf0_interp,[]);
    %
    j_ve(:,it) = Zcurr.x_0*mksa.j_ref;
    P_ve(:,it) = ZP0.x_rf_fsav*mksa.P_ref;
    Itot_ve(it) = sum(Zcurr.x_0.*equilDKE.xdA_dke*mksa.j_ref);
    Ptot_2piRp_ve(it) = sum(ZP0.x_rf_fsav.'.*equilDKE.xdV_2piRp_dke*mksa.P_ref);
end
%
Eta_fe = equilDKE.xne(1)*Itot_fe./Ptot_2piRp_fe/(2*pi)/1e19;
Eta_ve = equilDKE.xne(1)*Itot_ve./Ptot_2piRp_fe/(2*pi)/1e19;
%
strcolor = ['b','g','r','c','m','y','k'];
figure(1000),
for it = 1:ntime_step,
    graph1D_jd(equilDKE.xrho,j_fe(:,it),0,0,'\rho','Current density (MA.m-2)','Fixed plasma shape',NaN,'','','-','none',strcolor(rem(it,length(strcolor))+1),2);
end
%
figure(1001),
for it = 1:ntime_step,
    graph1D_jd(equilDKE.xrho,j_ve(:,it),0,0,'\rho','Current density (MA.m-2)','Time evolving plasma shape',NaN,'','','-','none',strcolor(rem(it,length(strcolor))+1),2);
end
%
figure(1002),
graph1D_jd([1:ntime_step]*dkeparam.dtn,abs(Itot_fe),0,0,'t*\nu','Current (MA)','JETh77 @ t = 0',NaN,'','','-','none','b',2);
graph1D_jd([1:ntime_step]*dkeparam.dtn,abs(Itot_ve),0,0,'t*\nu','Current (MA)','JETh77 @ t = 0',NaN,[1,ntime_step]*dkeparam.dtn,'','--','none','r',2);
legend('Fixed','Evolving')
%
figure(1003),
graph1D_jd([1:ntime_step]*dkeparam.dtn,abs(Ptot_2piRp_fe),0,0,'t*\nu','Power (MW)','JETh77 @ t = 0',NaN,'','','-','none','b',2);
graph1D_jd([1:ntime_step]*dkeparam.dtn,abs(Ptot_2piRp_ve),0,0,'t*\nu','Power (MW)','JETh77 @ t = 0',NaN,[1,ntime_step]*dkeparam.dtn,'','--','none','r',2);
legend('Fixed','Evolving')
%
figure(1004),
graph1D_jd([1:ntime_step]*dkeparam.dtn,Eta_fe,0,0,'t*\nu','\eta (A/W/m2)','JETh77 @ t = 0',NaN,'','','-','none','b',2);
graph1D_jd([1:ntime_step]*dkeparam.dtn,Eta_ve,0,0,'t*\nu','\eta (A/W/m2)','JETh77 @ t = 0',NaN,[1,ntime_step]*dkeparam.dtn,'','--','none','r',2);
legend('Fixed','Evolving')
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
