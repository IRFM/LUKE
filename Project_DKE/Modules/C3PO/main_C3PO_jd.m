function wave = main_C3PO_jd(id_wave,equil,rayinit,waveparam,fitparam,rayparam,display,flag);
%
% This function calculates the ray initial characteristics and launches the C3PO ray-tracing code
%
% by 	J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
% and   Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 8,
    flag = 0;%numerical equilibrium used by default
end
%
% Build or load vectorized magnetic equilibrium structure
%
if fitparam.opt_load*exist(['EQUILV_',equil.id,'.mat']),
   load(['EQUILV_',equil.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is reloaded.']);
else
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is being calculated.']);   
   [equil_fit] = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);
%   
   if ~isfield(equil,'opt_save'),equil.opt_save = 1;end
%   
   if equil.opt_save > 0,
        save(['EQUILV_',equil_fit.id,'.mat'],'equil_fit');
        info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil_fit.id,' is saved.']);
   end
end
%
if display.equilibrium,
   testfitequil_yp(equil,equil_fit);
end
%
Nrays = length(rayinit.yrho0);
%
kray = 0;
%
omega_rf = rayinit.omega_rf;
%
wave.id = id_wave;
wave.equil_id = equil.id;
wave.omega_rf = omega_rf;
wave.opt_rf = waveparam.opt_rf;
wave.opt_disp = 0;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
%
wave.dsmin = waveparam.dsmin;
%
if ~isfield(display,'text'),
    display.text = 1;
end
%
if ~isfield(waveparam,'nd'),
    waveparam.nd = 1;
end
if ~isfield(waveparam,'nchi'),
    waveparam.nchi = 1;
end
%
if ~isfield(rayparam,'dS'),% !!!! old rayparam, modify calling function
    warning('Update old rayparam in the script')
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
if ~isfield(rayinit,'yn0'),% !!!! old rayparam, modify calling function
    rayinit.yn0 = NaN*rayinit.ym0;
end
%
waveparam.cut_fac = rayparam.tau_lim/10;
%
wave.cut_fac = waveparam.cut_fac;
wave.kextra = rayparam.kextra;
%
for iray = 1:Nrays,
    %
    y0 = init_RT_jd(equil,equil_fit,rayinit.yrho0(iray),rayinit.ytheta0(iray),rayinit.yphi0(iray),omega_rf,rayinit.yNpar0(iray),rayinit.ym0(iray),rayinit.yn0(iray),waveparam.mmode,waveparam.kmode)';
    %
    info_dke_yp(2,['Initial conditions of ray #',int2str(iray),' are calculated']);
    %
    if isreal(y0(4)),
        %
        [tout, yout, yproc] = raytracing_yp(rayparam,equil_fit,y0,flag);
        %
        info_dke_yp(2,['Trajectory of ray #',int2str(iray),' is calculated']);
        %
        filename_in = [id_wave,'_ray_',int2str(iray)];
        [iabs_out,srho,stheta,sphi,sR,sZ,sNpar,sNperp,sepol_pmz,sphi_xyz,spmode,sD,ss,salphaphi_lin,sB,sBP,sBPHI,sTe,sne,szTi,szni,sr,salpha,sgradrhon,stau] = raypostprocessing_yp(tout,yout,yproc,rayparam,equil_fit,display.text,display.ray,display.p_opt,filename_in);
        if display.ray == 1,
            pause(5)
        end
        %
        % building ray for Fp calculations
        %
        ray.P0_2piRp = rayinit.yP0_2piRp(iray);%Initial lineic power density in the ray (W/m) [1,1]
        %
        ray.sx = sR.' - equil_fit.Rp;% Ray location (major radius) along the propagation [1,ns]
        ray.sphi = sphi.';% Ray location (toroidal angle) along the propagation [1,ns]
        ray.sy = sZ.' - equil_fit.Zp;% Ray location (vertical) along the propagation [1,ns]
        %
        ray.ss = ss.';% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
        ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
        ray.stheta = stheta.';% Ray location (poloidal angle) along the propagation [1,ns]
        %
        ray.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
        ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
        ray.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
        %
        ray.sNpar = sNpar.';% Ray parallel wave number [1,ns]
        ray.sNperp = sNperp.';% Ray perpendicular wave number [1,ns]
        ray.sdNpar = rayinit.ydNpar0(iray)*ones(1,length(srho));% Ray spectral width in Npar [1,ns] 
        %       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. ->
        %       square spectrum (centered on sNpar)
        ray.sepol_pmz = sepol_pmz.';% polarization vector [3,ns] complex
        ray.sphi_xyz = sphi_xyz.';% normalized power flow [3,ns]
        %
        ray.spmode = spmode.';%(1) cold mode p, (0) cold mode m (p is the slow LH wave)  
        %
        ray.sr = sr.';% Ray radial position [1,ns] (m)
        ray.srho = srho.';% Ray normalized radial position [1,ns]
        %
        ray.salphaphi_lin = salphaphi_lin.';% Ray absorption coefficient [1,ns]
        ray.stau = stau.';% Ray optical depth [1,ns]
        %
        ray.sB = sB.';% Total magnetic field along the ray [1,ns] (T)
        ray.sBP = sBP.';% Poloidal magnetic field along the ray [1,ns] (T)
        ray.sBPHI = sBPHI.';% Total magnetic field along the ray [1,ns] (T)
        
        ray.sTe = sTe.';% Total magnetic field along the ray [1,ns] (keV)
        ray.sne = sne.';% Total magnetic field along the ray [1,ns] (m-3)
        ray.szTi = szTi.';% Total magnetic field along the ray [ni,ns] (keV)
        ray.szni = szni.';% Total magnetic field along the ray [ni,ns] (m-3)
        %   
        kray = kray + 1;
        wave.rays{kray} = ray;
        %
        info_dke_yp(2,['Ray #',int2str(iray),' is processed']);
    else
        disp('kpsin has a non nul imaginary part !');     
        return
    end
end
%
wave = make_beam_wave_jd(wave,equil,waveparam.nd,waveparam.nchi);
%

