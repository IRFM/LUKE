function [wave] = main_C3PO_jd(dkepath,id_wave,equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,f0struct,fluct,flag)
%C3PO - Set ray initial characteristics and launches the C3PO ray-tracing code
%
% This function calculates the ray initial characteristics and launches the
% C3PO ray-tracing code
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
if nargin < 10,
    C3POparam = [];
end
%
if nargin < 11,
    f0struct = []; 
end
%
if nargin < 12,
    fluct = [];
end
%
if nargin < 13,
    flag = 0;%numerical equilibrium used by default
end
%
if ~isempty(fluct) && ~isstruct(fluct),
    fluct = [];
    disp('WARNING: <fluct> should be a structure or empty in main_C3PO_jd.m. It has been set to [].')
end
%
if ~isempty(f0struct) && ~isstruct(f0struct),
    f0struct = [];
    disp('WARNING: <f0struct> should be a structure or empty in main_C3PO_jd.m. It has been set to [].')
end
%
if ~isfield(C3POdisplay,'equilibrium'),
    C3POdisplay.equilibrium = 0;
end
%
if ~isfield(C3POdisplay,'fluctuations'),
    C3POdisplay.fluctuations = 0;
end
%
% Build or load vectorized magnetic equilibrium structure
%
if ~isstruct(equil),
    error('The ''equil'' argument in main_C3PO_jd.m must be a structure.') 
end
%
% SO FAR equil IS NEEDED FOR LOOP_MAIN (VESSEL REFLECTIONS).
% Uncomment following lines when only equil_fit will be needed
%
% if isfield(equil,'psin_fit'),%vectorized equilibrium is passed as equil structure
%     equil_fit = equil;
% elseif ~isempty(fitparam),
% ----
if isempty(equil_fit),
    info_dke_yp(2,['Vectorized form of the magnetic equilibrium ',equil.id,' is being calculated...'],C3POdisplay.equilibrium);
    equil_fit = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);
    info_dke_yp(2,'    ...done',C3POdisplay.equilibrium);
% ----
% else
%     error('When fitparam structure is empty, the ''equil'' argument in main_C3PO_jd.m must be a structure that corresponds to the interpolated magnetic equilibrium.')
end
%    
fluct_fit = [];
if isempty(fluct),
    info_dke_yp(2,'No equilibrium fluctuation effects included.',C3POdisplay.fluctuations);
elseif rayparam.tensortype > 0
    disp('WARNING: Plasma fluctuations model inconsistent with the plasma dielectric tensor type, fluctuation effects discarded.');
elseif ~isstruct(fluct),
    disp('WARNING: The ''fluct'' argument in main_C3PO_jd.m must be a structure, fluctuation effects discarded.') 
elseif isfield(fluct,'xL_perp_fit'), 
    fluct_fit = fluct;%reload existing fluctuation structure
elseif isfield(fluct,'xL_perp'), 
    if isfield(fluct,'fitparam'),
        info_dke_yp(2,['Vectorized form of the plasma fluctuations ',equil.id,'_',fluct.id,' being calculated...'],C3POdisplay.fluctuations);
        fluct_fit = fitfluct_yp(fluct,fitparam.mode_equil,fluct.fitparam.method,fluct.fitparam.ngridresample,fluct.fitparam.nharm);
        info_dke_yp(2,'    ...done',C3POdisplay.fluctuations);
        if C3POdisplay.fluctuations,
            testfitfluct_yp(equil_fit,fluct,fluct_fit);
        end
    else
        disp('WARNING: empty field ''fitparam'' in structure ''fluct'', fluctuation effects discarded.')
    end
elseif isfield(fluct,'npar0_lh'), 
    %to validate that the field exists in the 'fluct' structure
else
    disp('WARNING: The ''fluct'' structure is not recognized, fluctuation effects discarded.')
end
%
% wave structure initialization
%
Nrays = length(rayinit.yrho0);
%
omega_rf = rayinit.omega_rf;
%
wave.id = id_wave;
wave.model = 'RT';
wave.equil_id = equil.id;
wave.omega_rf = omega_rf;
wave.opt_rf = waveparam.opt_rf;
if isfield(waveparam,'n_rf_list'),
    wave.n_rf_list = waveparam.n_rf_list;
end
%
wave.opt_disp = 0;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
%
wave.dsmin = waveparam.dsmin;
%
% Backward compatibility
%
if ~isfield(C3POdisplay,'text'),
    C3POdisplay.text = 1;
end
%
if ~isfield(C3POdisplay,'mdce'),
    C3POdisplay.mdce = 0;
end
%
if ~isfield(waveparam,'nd'),
    waveparam.nd = 1;
end
if ~isfield(waveparam,'nchi'),
    waveparam.nchi = 1;
end
if ~isfield(waveparam,'ns'),
    waveparam.ns = 1;
end
if isfield(waveparam,'a_sdNpar'),
    wave.a_sdNpar = waveparam.a_sdNpar;
end
%
if ~isfield(rayparam,'dS'),% !!!! old rayparam, modify calling function
    disp('WARNING: You should update old rayparam')
    rayparam.dS = rayparam.drho;
    %
    rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
    rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
    rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
    rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
    %
    rayparam = rmfield(rayparam,'drho');
end
%
if ~isfield(rayparam,'kextra'),% !!!! old rayparam, modify calling function
    rayparam.kextra = 0;
end
%
%if ~isfield(rayinit,'yn0'),% !!!! old rayparam, modify calling function
%    rayinit.yn0 = NaN*rayinit.ym0;
%end
%
%if ~isfield(rayinit,'ykz0'),% !!!! old rayparam, modify calling function
%    rayinit.ykz0 = NaN*rayinit.ym0;
%end
%
if ~isfield(rayinit,'w0'),% waist information
    rayinit.w0 = NaN;
end
if ~isfield(rayinit,'z0'),% waist position information
    rayinit.z0 = NaN;
end
%
waveparam.cut_fac = rayparam.tau_lim/10;
%
wave.cut_fac = waveparam.cut_fac;
wave.kextra = rayparam.kextra;
%
arg_range = cell(1,Nrays);
for iray = 1:Nrays,
    arg_range{iray} = iray;
end
%
if isempty(dkepath),
    [dkepath] = load_structures_yp('dkepath','','');
end
%
if isempty(C3POparam),
    C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
    C3POparam.schedulertype = 'local';%type of scheduler, '' or 'local' for any machine or cluster,'pbspro' for CEPHEE or SATURNE cluster,'xgrid' on mac computers,... [1,1]
    C3POparam.mdce_remnum = 0;%remote index (0 for local cluster calculations) [1,1]
end
%
if ~isfield(C3POparam,'schedulertype');
    C3POparam.schedulertype = 'local';
end
%
if ~isfield(C3POparam,'mdce_remnum');
    C3POparam.mdce_remnum = 0;
end
%
dkecluster = clustermode_luke(C3POparam.clustermode,'main_C3PO_jd',dkepath,C3POparam.schedulertype,C3POparam.mdce_remnum);%MatLab distributed computing environment
%
[flag_mdce_main_C3PO_jd,rayss] = mdce_luke(@loop_main_C3PO_jd,{iray,equil,equil_fit,id_wave,omega_rf,rayinit,rayparam,flag,waveparam,C3POdisplay,f0struct,fluct_fit},1,arg_range,dkecluster);
%
iray_wave = 1;
for iray = 1:Nrays,
    %
    rays = rayss{iray};
    Niray = length(rays);%ray can be duplicated if multiple reflections
    %
    if Niray == 1 && isempty(rays{1}.srho),
        disp(['kpsin has a non nul imaginary part for ray # ',int2str(iray),' !']);  
        info_dke_yp(2,['WARNING: Ray #',int2str(iray),' is not put in the wave structure.']);
    else
        wave.rays(iray_wave:iray_wave + Niray - 1) = rays;
        iray_wave = iray_wave + Niray;
        info_dke_yp(2,['Ray #',int2str(iray),' is processed']);	
    end
end    
clear rayss rays
%
wave = make_beam_wave_jd(wave,equil,C3POdisplay,waveparam.nd,waveparam.nchi,rayinit.w0,rayinit.z0,waveparam.ns);
%
if length(rayinit.yP0_2piRp) > length(wave.rays),
    ptot_coupled = 0;
    %
    for ii = 1:length(wave.rays)
        ptot_coupled = ptot_coupled + wave.rays{ii}.P0_2piRp*2*pi*equil.Rp;
    end
    %
    disp('WARNING: Some rays have been removed since they do not penetrate the plasma (kpsin has a non nul imaginary part)');
    disp(['WARNING: The launched rf power is : ',num2str(sum(rayinit.yP0_2piRp)*2*pi*equil.Rp/1e6),' (MW), while the rf power coupled to the plasma is : ',num2str(ptot_coupled/1e6),' (MW).']);
end
%
wave.rayinit = rayinit;
wave.waveparam = waveparam;
wave.fitparam = fitparam;
wave.rayparam = rayparam;
wave.C3POparam = C3POparam;
wave.display = C3POdisplay;
wave.flag_mdce_main_C3PO_jd = flag_mdce_main_C3PO_jd;
%

