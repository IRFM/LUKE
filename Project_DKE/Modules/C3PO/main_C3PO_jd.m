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
   if display.equilibrium,
       testfitequil_yp(equil,equil_fit);
   end
end
%
Nrays = length(rayinit);
%
kray = 0;
%
wave.equil_id = equil.id;
wave.omega_rf = waveparam.omega_rf;
wave.opt_rf = waveparam.opt_rf;
wave.opt_disp = 0+i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
%
for iray = 1:Nrays,
%
      y0 = init_RT_jd(equil,equil_fit,rayinit(iray).rho0,rayinit(iray).theta0,rayinit(iray).phi0,waveparam.omega_rf,rayinit(iray).Npar0,rayinit(iray).m0,waveparam.xmode,waveparam.sigma,waveparam.kmode)';
%
      info_dke_yp(2,['Initial conditions of ray #',int2str(iray),' is calculated']);
%
      if isreal(y0(4)),
%
         [tout, yout] = raytracing_yp(rayparam,equil_fit,y0);
%
         info_dke_yp(2,['Trajectory of ray #',int2str(iray),' is calculated']);
%
         filename_in = [id_wave,'_ray_',int2str(iray)];
         [iabs_out,srho,stheta,sphi,sR,sZ,sNpar,sNperp,sepol_pmz,sphi_xyz] = raypostprocessing_yp(tout,yout,rayparam,equil_fit,waveparam.omega_rf,display.ray,display.p_opt,filename_in);
         if display.ray == 1,
             pause
         end
         iabs = min(length(srho),round(iabs_out*1.1));
%
% building ray for Fp calculations
%
         ray.P0_2piRp = rayinit(iray).P0_2piRp;%Initial lineic power density in the ray (W/m) [1,1]
%
         ray.sx = sR(1:iabs).' - equil_fit.Rp;% Ray location (major radius) along the propagation [1,ns]
         ray.sphi = sphi(1:iabs).';% Ray location (toroidal angle) along the propagation [1,ns]
         ray.sy = sZ(1:iabs).' - equil_fit.Zp;% Ray location (vertical) along the propagation [1,ns]
%
         ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
         ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
         ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
%
         ray.skx = [];% Ray wave vector (major radius) along the propagation [1,ns]
         ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
         ray.sky = [];% Ray wave vector (vertical) along the propagation [1,ns]
%
         ray.sNpar = sNpar(1:iabs).';% Ray parallel wave number [1,ns]
         ray.sNperp = sNperp(1:iabs).';% Ray perpendicular wave number [1,ns]
         ray.sdNpar = rayinit(iray).dNpar0*ones(1,iabs);% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. ->
%       square spectrum (centered on sNpar)
         ray.sepol_pmz = sepol_pmz(1:iabs,:).';% polarization vector [3,ns] complex
         ray.sphi_xyz = sphi_xyz(1:iabs,:).';% normalized power flow [3,ns]
%
         kray = kray + 1;
         wave.rays{kray} = ray;
%
         info_dke_yp(2,['Ray #',int2str(iray),' is processed']);
      else
         warning('kpsin has a non nul imaginary part !');        
      end
end
%

