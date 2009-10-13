function wave = main_C3PO_jd(id_wave,equil,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,flag)
%C3PO - Set ray initial characteristics and launches the C3PO ray-tracing code
%
% This function calculates the ray initial characteristics and launches the C3PO ray-tracing code
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and   Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
    if nargin < 8,
    	C3POparam = [];
        flag = 0;%numerical equilibrium used by default
    end
	%
    if nargin < 9,
        flag = 0;%numerical equilibrium used by default
    end
    %
    % Build or load vectorized magnetic equilibrium structure
    %
    if fitparam.opt_load && exist(['EQUILV_',equil.id,'.mat'],'file'),
       load(['EQUILV_',equil.id,'.mat'],'equil_fit');
       if C3POdisplay.equilibrium,info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is reloaded.']);end
    else
       if C3POdisplay.equilibrium,info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is being calculated.']);end   
       [equil_fit] = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);
    %   
       if ~isfield(equil,'opt_save'),equil.opt_save = 1;end
    %   
       if equil.opt_save > 0,
            save(['EQUILV_',equil_fit.id,'.mat'],'equil_fit');
            if C3POdisplay.equilibrium,info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil_fit.id,' is saved.']);end
       end
    end
    %
    if C3POdisplay.equilibrium,
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
    % Backward compatibility
    %
    if ~isfield(C3POdisplay,'text'),
        C3POdisplay.text = 1;
    end
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
        disp('You should update old rayparam')
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
    if ~isfield(rayparam,'ns0'),% !!!! old rayparam, modify calling function
        rayparam.ns0 = 0;
    end
    %
    if ~isfield(rayparam,'xreset0'),% !!!! old rayparam, modify calling function
        rayparam.xreset0 = 1;
    end
    %
    if ~isfield(rayparam,'fmode'),% !!!! old rayparam, modify calling function
        rayparam.fmode = 0;
    end
    %
    if ~isfield(rayinit,'yn0'),% !!!! old rayparam, modify calling function
        rayinit.yn0 = NaN*rayinit.ym0;
    end
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
    if ~isempty(C3POparam) && C3POparam.clustermode.main_C3PO_jd.mode,
        arg_range = cell(1,Nrays);
        for iray = 1:Nrays,
            arg_range{iray} = iray;
        end
        [dkecluster] = clustermode_luke(C3POparam.clustermode,'main_C3PO_jd',C3POdisplay);
        [flag,rays] = mdce_luke(@loop_main_C3PO_jd,{iray,equil,equil_fit,id_wave,omega_rf,rayinit,rayparam,flag,waveparam,C3POdisplay},1,arg_range,dkecluster);
		rmdir(dkecluster.temppath,'s');
		%
		iray_wave = 1;
		for iray = 1:Nrays,
			if isempty(rays{iray}),
                disp(['kpsin has a non nul imaginary part for ray # ',int2str(iray),' !']);  
                info_dke_yp(2,['WARNING: Ray #',int2str(iray),' is not put in the wave structure.']);
            else
                wave.rays{iray_wave} = rays{iray};
                iray_wave = iray_wave + 1;
                info_dke_yp(2,['Ray #',int2str(iray),' is processed']);	
            end
		end
    else
    	iray_wave = 1;
        for iray = 1:Nrays,    
            [ray] = loop_main_C3PO_jd(iray,equil,equil_fit,id_wave,omega_rf,rayinit,rayparam,flag,waveparam,C3POdisplay);
            if isempty(ray),
                disp(['kpsin has a non nul imaginary part for ray # ',int2str(iray),' !']);
                info_dke_yp(2,['WARNING: Ray #',int2str(iray),' is not put in the wave structure.']);
            else
                wave.rays{iray_wave} = ray;
                iray_wave = iray_wave + 1;
                info_dke_yp(2,['Ray #',int2str(iray),' is processed']);
            end
        end
    end
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
    %
end

