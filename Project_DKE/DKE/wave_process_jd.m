function wave = wave_process_jd(equil,wave,n_rf_list,method);
%
% This function completes the missing wave characteristics. In particular, it calculates the wave
% absorption coefficient and the wave lilnear damping.
%
% by 	J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
% and   Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 4,
    method = 'linear';%'spline';%interpolation technique in psi
end
%
% Equilibrium data with Fourier-enhanced poloidal precision and original radial grid
%
[equilDKE_Fourier] = equilibrium_jd(equil);
%
% Absorption calculation including dnpar effects
%
if isfield(wave,'a_sdNpar') && wave.a_sdNpar > 0,
    if isfield(wave,'rayparam') && wave.rayparam.rel_opt == 0,
        wave.opt_disp = real(wave.opt_disp) - (1 + wave.a_sdNpar)*i;
    else
        wave.opt_disp = real(wave.opt_disp) + (1 + wave.a_sdNpar)*i;
    end
end
%
% Ray processing
%
for ib = 1:length(wave.rays),
    ray = rayprocess_jd(wave.rays{ib},equilDKE_Fourier,wave.opt_disp,wave.omega_rf,n_rf_list,method);
    %
    % Ray linear damping
    %
    salphaphi_lin = ray.salphaphi_lin;
    if any(~isnan(salphaphi_lin)),%absorption coefficient was calculated
        %
        sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
        salpha_lin = salphaphi_lin./sphi_norm;
        salpha_lin(isnan(salpha_lin)) = 0;
        %
        if ~isfield(ray,'stau') || all(isnan(ray.stau)) || abs(imag(wave.opt_disp)) > 1,
            %
            salpha_lin_h = (salpha_lin(1:end-1) + salpha_lin(2:end))/2;
            sds = diff(ray.ss);
            ray.stau = [0,cumsum(salpha_lin_h.*sds)];
            %
        end
        %
        ray.sP_2piRp = ray.P0_2piRp*exp(-ray.stau);
        ray.sdP_2piRp_ds = salpha_lin.*ray.sP_2piRp;
        %
    elseif isfield(ray,'sP_2piRp'),%power along the ray was calculated
        %
        stau = -log(ray.sP_2piRp/ray.sP_2piRp(1));
        %
        ss_h = (ray.ss(1:end - 1) + ray.ss(2:end))/2;
        sdtauds_h = diff(stau)./diff(ray.ss);
        salpha_lin = interp1(ss_h,sdtauds_h,ray.ss,'linear','extrap');
        %
        sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
        salphaphi_lin = salpha_lin.*sphi_norm;
        salphaphi_lin(isnan(salphaphi_lin)) = 0;
        %
        ray.stau = stau;
        ray.salphaphi_lin = salphaphi_lin;
        ray.sdP_2piRp_ds = salpha_lin.*ray.sP_2piRp;
    end
    %
    if isfield(ray,'stau') & isfield(wave,'cut_fac'),
        ns = length(ray.ss);
        is_max = min([ns,wave.kextra+find(ray.stau > 10*wave.cut_fac)]);
        if ray.stau(end) < 10*wave.cut_fac & ~isinf(wave.cut_fac),
            disp('WARNING: The ray might be too short. Increase tfinal')
        end
        %
        frays = fieldnames(ray);
        for ifield = 1:length(frays),
            eval(['ns_field = length(ray.',frays{ifield},');'])
            if ns_field == ns,
                eval(['ray.',frays{ifield},' = ray.',frays{ifield},'(:,1:is_max);'])
            end
        end
    end
    %
    wave.rays{ib} = ray;
    info_dke_yp(2,['Damping of ray #',num2str(ib),' calculated']);    
end
%
wave.opt_disp = 0;
%
