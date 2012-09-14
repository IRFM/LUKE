function lukeparam = make_lukeparam_metis2luke(cons,option,auto_mode)
%
% This function sets - and possibly modifies - LUKE parameters when called
% from METIS
%
% by J. Decker and J.-F. Artaud, 02/02/2011
%

%
% LUKE base parameters
%
dkeparam = load_structures_yp('dkeparam','LH_RT','');% LH type parameters
dkeparam = rmfield(dkeparam,'n_rf_list');%determined from waves
%
% LUKE equilibrium parameters
%
equilparam.nbpx = 101;% number of points in interpolated radial grid (enter 0 if no interpolation)
equilparam.mode = 'standard';% interpolation mode : linear in "standard" (xli), "sqrt(psi)", or "psi"
equilparam.expo = option.morphing;% exposant de la fonction de morphing
equilparam.comp = false;%control of equilibrium moments reconstructed from LUKE
%
% LUKE LH parameters
%
lhparam.freqlh = option.freqlh;% wave frequency (GHz) [1,1]
lhparam.plh = cons.plh;% wave power (W) [1,1]
lhparam.npar0 = option.npar0;% wave initial index of refraction [1,1]
%
lhparam.mode = 1;% LUKE LH mode : (0) simple v1, v2, D model, (1) C3PO with ideal antenna, (2) C3PO with prescribed antenna
lhparam.plhmin = 1e4;%minimum power level to use wave in LUKE
%
lhparam.directivity = 0.7;% spectrum directivity [1,1]
lhparam.lob = true;% include opposite lobe [1,1] boolean
lhparam.dnpar0 = 0.2;%initial spectral width [1,1]
lhparam.z0 = 0;%initial vertical positions [1,nz]
lhparam.m0 = 0;%initial poloidal mode number [1,1]
lhparam.phi0 = 0;%toroidal angle position [1,1]
lhparam.i_ref = -1;%Initial radial position index [1,1]
lhparam.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
lhparam.mmode = -1;% (-1) for slow wave, (1) for fast wave
lhparam.a_sdNpar = 0;% spectral broadening factor [1,1]
lhparam.nparp = 0;% initial spectral upshift [1,1]
%
% LUKE EC parameters
%
ecparam.freqec = -1;% wave frequency (GHz) [1,1] (if negative integer = harmonic number, determined from torangle, xec and polec)
ecparam.alpha_L = NaN;% Toroidal launching angle (degrees)  [1,1] (if NaN, determined from freqec, xec and polec, or 30° if freqec=NaN)
%
ecparam.pec = cons.pecrh;% wave power (W) [1,1]
ecparam.xec = cons.xece;% radial location of ECRH deposition
ecparam.polec = option.angle_ece;%poloidal location of ECRH deposition, (degrees) (if NaN, determined from freqec, xec and torangle)
%
ecparam.pabs = 1.5;%momentum at absorption (for Doppler shift)
%
ecparam.mode = 1;% LUKE LH mode : (1) C3PO with ideal launcher, (2) C3PO with prescribed launcher
ecparam.pecmin = 1e4;%minimum power level to use wave in LUKE
%
ecparam.dnpar0 = 0.05;%initial spectral width [1,1]
ecparam.phi0 = 0;%toroidal angle launching position [1,1]
ecparam.mmode = -1;% (-1) for O mode (1) for X mode
ecparam.ns = 1000;
ecparam.method = 'cubic';
%
% LUKE radial transport parameters
%
transpfaste.id = 'ES_0';
%
transpfaste.Dr0 = 0;%Core radial diffusion coefficient (m^2/s)
transpfaste.Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
transpfaste.pDr = 0;%Coefficient for the Dr radial profile
transpfaste.Vr0 = 0;%Core radial pinch coefficient (m/s)
transpfaste.Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth),
transpfaste.pVr = 0;%Coefficient for the Vr radial profile
transpfaste.vparmin = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
transpfaste.norm_ref = 1;%Normalization procedure for the lower limit of radial transport parallel velocity dependence: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref
%
if isfield(option,'luke_mode'),
    lukeparam.luke_mode = option.luke_mode;% (0) run LUKE, (1) run LUKE then save output (2) save input then exit
else  
    lukeparam.luke_mode = 0;% (0) run LUKE, (1) run LUKE then save output (2) save input then exit
end
lukeparam.batch_mode = 1;% (0) rum LUKE in interactive mode, (1) run LUKE in batch mode
%
lukeparam.display_mode = 0;
lukeparam.rho_display = 0.5;
%
lukeparam.dkeparam = dkeparam;
lukeparam.equilparam = equilparam;
lukeparam.lhparam = lhparam;
lukeparam.ecparam = ecparam;
lukeparam.transpfaste = transpfaste;
%
if ~auto_mode,
    lukeparam = imod_struct_jd(lukeparam,'lukeparam',1,1);
end
%







