function [ray] = loop_main_C3PO_jd(iray,equil,equil_fit,id_wave,omega_rf,rayinit,rayparam,flag,waveparam,C3POdisplay,fluct_fit)
%C3PO - Set ray initial characteristics and launches the C3PO ray-tracing code (loop function for distributed computing environment)
%
%This function calculates the ray initial characteristics and launches the C3PO ray-tracing code
%
%by Yves Peysson (CEA-IRFM,yves.peysson@cea.fr) and Joan Decker (CEA-IRFM,joan.decker@cea.fr) and 
%
    ray = '';
    %
    y0 = init_RT_jd(equil,equil_fit,rayinit.yrho0(iray),rayinit.ytheta0(iray),rayinit.yphi0(iray),omega_rf,rayinit.yNpar0(iray),rayinit.ym0(iray),rayinit.yn0(iray),waveparam.mmode,waveparam.kmode)';
    %
    if C3POdisplay.ray,info_dke_yp(2,['Initial conditions of ray #',int2str(iray),' are calculated']);end
    %
    if isreal(y0(4)),
        %
        [tout, yout, yproc] = raytracing_yp(rayparam,equil_fit,y0,fluct_fit,flag);
        %
        if C3POdisplay.ray,info_dke_yp(2,['Trajectory of ray #',int2str(iray),' is calculated']);end
        %
        filename_in = [id_wave,'_ray_',int2str(iray)];
        [iabs_out,srho,stheta,sphi,sR,sZ,sNpar,sNperp,sepol_pmz,sphi_xyz,spmode,sD,ss,salphaphi_lin,sB,sBP,sBPHI,sTe,sne,szTi,szni,sr,salpha,sgradrhon,stau] = raypostprocessing_yp(tout,yout,yproc,rayparam,equil_fit,C3POdisplay.text,C3POdisplay.ray,C3POdisplay.p_opt,filename_in);
        if C3POdisplay.ray == 1,
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
    else
        return
    end
end

