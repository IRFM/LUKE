function wave = main_C3PO_jd(id_wave,equil,rayinit,waveparam,fitparam,rayparam,display);
%
% This function calculates the ray initial characteristics and launches the C3PO ray-tracing code
%
% by 	J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
% and   Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>

%
% Build or load vectorized magnetic equilibrium structure
%
if fitparam.opt_load*exist(['EQUILV_',equil.id,'.mat']),
   load(['EQUILV_',equil.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is reloaded.']);
  else
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is being calculated.']);   
   [equil_fit] = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);
   save(['EQUILV_',equil_fit.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil_fit.id,' is saved.']);
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
wave.equil_id = equil.id;
wave.omega_rf = omega_rf;
wave.opt_rf = waveparam.opt_rf;
wave.opt_disp = 0+i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
%
for iray = 1:Nrays,
%
      y0 = init_RT_jd(equil,equil_fit,rayinit.yrho0(iray),rayinit.ytheta0(iray),rayinit.yphi0(iray),omega_rf,rayinit.yNpar0(iray),rayinit.ym0(iray),waveparam.mmode,waveparam.kmode)';
%
      info_dke_yp(2,['Initial conditions of ray #',int2str(iray),' are calculated']);
%
      if isreal(y0(4)),
%
         [tout, yout] = raytracing_yp(rayparam,equil_fit,y0);
%
         info_dke_yp(2,['Trajectory of ray #',int2str(iray),' is calculated']);
%
         filename_in = [id_wave,'_ray_',int2str(iray)];
         [iabs_out,srho,stheta,sphi,sR,sZ,sNpar,sNperp,sepol_pmz,sphi_xyz] = raypostprocessing_yp(tout,yout,rayparam,equil_fit,omega_rf,display.ray,display.p_opt,filename_in);
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
         ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
         ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
         ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
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
         kray = kray + 1;
         wave.rays{kray} = ray;
%
         info_dke_yp(2,['Ray #',int2str(iray),' is processed']);
      else
         disp('kpsin has a non nul imaginary part !');        
      end
end
%

