function wavestruct = make_wavert_cronos(launch,par)
%
% Create the structures waveparam,fitequilparam,rayparam,raydisplay used by C3PO for CRONOS
% 
if nargin < 2,
    par = '';
end
%
if strcmp(launch.type,'LH');%For the Lower Hybrid wave simulations
%
% Wave parameters
%
%   waveparam.mmode = -1;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
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
    waveparam.n_rf_list = 0;
%
% Equilibrium parameters for the ray-tracing
%
    fitequilparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
    fitequilparam.method = 'pchip';%nearest,spline,pchip,cubic
    fitequilparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
    fitequilparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
    fitequilparam.opt_load = 0;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
    rayparam.testmode = 0;
    rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
    rayparam.t0 = 0;
    rayparam.tfinal = 100000;
    if isfield(launch,'aloha') && sum(launch.aloha.mode) > 0.
        rayparam.dS = 1.e-2;
        rayparam.kextra = 1000;%number of extra points after linear absorption
    else
        rayparam.dS = 1.e-3;
        rayparam.kextra = 5000;%number of extra points after linear absorption
    end
    rayparam.dt0 = 1.e-4;
    rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
    rayparam.kmax = 100000;
    rayparam.ncyclharm = 50;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
    rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
    rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
    rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
    rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
    rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
%
% Ray display mode
%
   raydisplay.ray = 0;
   raydisplay.equilibrium = 0;
   raydisplay.p_opt = -1;%Printing or saving option of the figures
%
elseif strcmp(launch.type,'EC') || strcmp(launch.type,'EBW'),%For the Electron Cyclotron or EBW wave simulations

% Wave parameters
%
%   waveparam.mmode = 1;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
    waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
    waveparam.opt_rf = 0;
    waveparam.dsmin = 0.01;
    waveparam.cut_fac = Inf;
    %
    waveparam.n_rf_list = 1:3;
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
    rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
    rayparam.t0 = 0;
    rayparam.tfinal = 100000;
    rayparam.dt0 = 1.e-5;
    rayparam.dS = 1.e-4;
    rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
    rayparam.kmax = 100000;
    rayparam.ncyclharm = 50;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
    rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
    rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
    rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
    rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
    rayparam.tau_lim = Inf;%value of optical depth beyond which the wave is considered absorbed
    rayparam.kextra = 1000;%number of extra points after linear absorption
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
%
% C3PO computing parameters
%
if isfield(par,'distray'),
    C3POparam.clustermode.main_C3PO_jd.scheduler.mode = par.distray;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)for the function main_C3PO_jd.m (MDC toolbox must be installed for option 1)
else
    C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 0;
end
%
C3POparam.clustermode.main_C3PO_jd.scheduler.timeout = 300;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
C3POparam.clustermode.main_C3PO_jd.scheduler.size = 12;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
C3POparam.clustermode.main_C3PO_jd.scheduler.mem = 500;% memory allocated to batch jobs (in MB)
%
if isfield(par,'conf'),
    wavestruct.id = [par.conf,'_',launch.id];
else
    wavestruct.id = launch.id;
end
%
wavestruct.launch = launch;
if ~isfield(launch,'w0')
  wavestruct.launch.w0 = NaN;
end
if ~isfield(launch,'z_L')
  wavestruct.launch.z_L = NaN;
end
%
wavestruct.waveparam = waveparam;
wavestruct.fitequilparam = fitequilparam;
wavestruct.rayparam = rayparam;
wavestruct.raydisplay = raydisplay;
%
if isfield(par,'raydisplay')
    wavestruct.raydisplay.ray = par.raydisplay.ray;
end
%
wavestruct.C3POparam = C3POparam;
%
wavestruct.wavesolver = 'C3PO';
wavestruct.waveparam.mmode = launch.mmode;% cold mode (+1 for m; -1 for p)
%
if isfield(launch,'a_sdNpar')
    wavestruct.waveparam.a_sdNpar = launch.a_sdNpar;
else
    wavestruct.waveparam.a_sdNpar = 0;
end
%
if isfield(par,'kmode')
    wavestruct.waveparam.kmode = par.kmode;%
else
    wavestruct.waveparam.kmode = 0;%Dielectric tensor (0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
end
%
wavestruct.rayparam.tensortype = wavestruct.waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
if isfield(par,'ray_tfinal')
    wavestruct.rayparam.tfinal = par.ray_tfinal;
end
%
if isfield(par,'oneray') && strcmp(par.oneray,'Yes') && strcmp(wavestruct.launch.type,'LH'),
    wavestruct.launch.rZ0 = mean(wavestruct.launch.rZ0);
end
%
