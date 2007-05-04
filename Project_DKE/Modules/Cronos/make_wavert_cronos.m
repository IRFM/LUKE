function [waveparam,fitequilparam,rayparam,raydisplay] = make_wavert_cronos(config)
%
% Create the structures waveparam,fitequilparam,rayparam,raydisplay used by C3PO for CRONOS
% 
if strcmp(config,'LH');%For the Lower Hybrid wave simulations
%
% Wave parameters
%
   waveparam.mmode = -1;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
   waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
   waveparam.opt_rf = 1;
   waveparam.dsmin = Inf;
   waveparam.cut_fac = 2;
%
% Equilibrium parameters for the ray-tracing
%
   fitequilparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
   fitequilparam.method = 'spline';%nearest,spline,pchip,cubic
   fitequilparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
   fitequilparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
   fitequilparam.opt_load = 0;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
   rayparam.testmode = 0;
   rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
   rayparam.t0 = 0;
   rayparam.tfinal = 20000;
   rayparam.dt0 = 1.e-5;
   rayparam.drho = 1.e-4;
   rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
   rayparam.kmax = 100000;
   rayparam.ncyclharm = 50;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
   rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
%
% Ray display mode
%
   raydisplay.ray = 0;
   raydisplay.equilibrium = 0;
   raydisplay.p_opt = -1;%Printing or saving option of the figures
%
elseif strcmp(config,'EC') | strcmp(config,'EBW');;%For the Electron Cyclotron or EBW wave simulations
%
% Wave parameters
%
   waveparam.mmode = 1;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
   waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
   waveparam.opt_rf = 0;
   waveparam.dsmin = 0;
   waveparam.cut_fac = 2;
%
% Equilibrium parameters for the ray-tracing
%
   fitequilparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
   fitequilparam.method = 'spline';%nearest,spline,pchip,cubic
   fitequilparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
   fitequilparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
   fitequilparam.opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
   rayparam.testmode = 0;
   rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
   rayparam.t0 = 0;
   rayparam.tfinal = 2000;
   rayparam.dt0 = 1.e-5;
   rayparam.drho = 1.e-4;
   rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
   rayparam.kmax = 100000;
   rayparam.ncyclharm = 50;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
   rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
%
% Ray display mode
%
   raydisplay.ray = 0;
   raydisplay.equilibrium = 0;
   raydisplay.p_opt = -1;%Printing or saving option of the figures
%
else
   error('The wavert configuration name does not exists')  	
end