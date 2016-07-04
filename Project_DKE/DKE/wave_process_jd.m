function wave = wave_process_jd(equil,wave,n_rf_list,method)
%
% This function completes the missing wave characteristics. In particular, it calculates the wave absorption coefficient and the wave linear damping.
%
% by J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if ~isfield(wave,'rays'),% Not a RT code (FW, etc)
    return
end
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
if ~any(isnan(n_rf_list)),
    if isfield(wave,'rayparam') && wave.rayparam.rel_opt == 0,
        wave.opt_disp = real(wave.opt_disp) - 1i;
    else
        wave.opt_disp = real(wave.opt_disp) + 1i;
    end
end
%
if isfield(wave,'a_sdNpar') && wave.a_sdNpar > 0,
    %
    n_rf_list = 0;% used for Landau damping only
    %
    if isfield(wave,'rayparam') && wave.rayparam.rel_opt == 0,
        wave.opt_disp = real(wave.opt_disp) - (1 + wave.a_sdNpar)*1i;
    else
        wave.opt_disp = real(wave.opt_disp) + (1 + wave.a_sdNpar)*1i;
    end
end
%
% Ray processing
%
for ib = 1:length(wave.rays),
    %
    if isfield(wave,'colldamp'),
        colldamp = wave.colldamp ;
    else
        if isfield(wave.rayparam,'colldamp'),%backward compatibility
            colldamp = wave.rayparam.colldamp;
        else
            colldamp = 0;%no collisional damping 
        end
        %
        wave.colldamp = colldamp;
    end
    %
    ray = rayprocess_jd(wave.rays{ib},equilDKE_Fourier,wave.opt_disp,wave.omega_rf,n_rf_list,method,colldamp);
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
        if ~isfield(ray,'stau_lin') || all(isnan(ray.stau_lin)) || abs(imag(wave.opt_disp)) >= 1,
            %
            salpha_lin_h = (salpha_lin(1:end-1) + salpha_lin(2:end))/2;
            sds = diff(ray.ss);
            ray.stau_lin = [0,cumsum(salpha_lin_h.*sds)];
            %
        end
        %
        ray.sP_2piRp_lin = ray.P0_2piRp*exp(-ray.stau_lin);
        ray.sdP_2piRp_ds_lin = salpha_lin.*ray.sP_2piRp_lin;
        %
    elseif isfield(ray,'sP_2piRp_lin'),%power along the ray was calculated
        %
        stau_lin = -log(ray.sP_2piRp_lin/ray.sP_2piRp_lin(1));
        %
        ss_h = (ray.ss(1:end - 1) + ray.ss(2:end))/2;
        sdtauds_h_lin = diff(stau_lin)./diff(ray.ss);
        salpha_lin = interp1(ss_h,sdtauds_h_lin,ray.ss,'linear','extrap');
        %
        sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
        salphaphi_lin = salpha_lin.*sphi_norm;
        salphaphi_lin(isnan(salphaphi_lin)) = 0;
        %
        ray.stau_lin = stau_lin;
        ray.salphaphi_lin = salphaphi_lin;
        ray.sdP_2piRp_ds_lin = salpha_lin.*ray.sP_2piRp_lin;
    end
    %
    % Collisional ray damping
    %
    if isfield(ray,'salphaphi_coll'),
        %
        salphaphi_coll = ray.salphaphi_coll;
        %
        if any(~isnan(salphaphi_coll)),%collisional damping
            %
            sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
            salpha_coll = salphaphi_coll./sphi_norm;
            salpha_coll(isnan(salpha_coll)) = 0;
            %
            if ~isfield(ray,'stau_coll') || all(isnan(ray.stau_coll)) || abs(imag(wave.opt_disp)) >= 1,
                %
                salpha_coll_h = (salpha_coll(1:end-1) + salpha_coll(2:end))/2;
                sds = diff(ray.ss);
                ray.stau_coll = [0,cumsum(salpha_coll_h.*sds)];
                %
            end
            %
            ray.sP_2piRp_coll = ray.P0_2piRp*exp(-ray.stau_coll);%Power lost for collisional damping alone
            ray.sdP_2piRp_ds_coll = salpha_coll.*ray.sP_2piRp_coll;%Power lost for collisional damping alone        
            %
        end
    end
    %
    if isfield(ray,'stau_lin'),
        %
        if isfield(ray,'stau_coll')
            ray.sP_2piRp_lin_coll = ray.P0_2piRp*exp(-ray.stau_lin-ray.stau_coll);%Combined linear + collisional damping
            ray.sdP_2piRp_ds_lin_coll = (salpha_lin + salpha_coll).*ray.sP_2piRp_lin_coll;%Combined linear + collisional damping
        else
            ray.sP_2piRp_lin_coll = ray.P0_2piRp*exp(-ray.stau_lin);%linear damping
            ray.sdP_2piRp_ds_lin_coll = salpha_lin.*ray.sP_2piRp_lin;%linear damping
        end
        %
    end
    %
    if isfield(ray,'stau_lin') && isfield(wave,'cut_fac'),
        %
        ns = length(ray.ss);
        %
        if isfield(ray,'stau_coll'),
            is_max = min([ns,wave.kextra+find(ray.stau_lin + ray.stau_coll > 10*wave.cut_fac)]);
            if ray.stau_lin(end) + ray.stau_coll(end)  < 10*wave.cut_fac && ~isinf(wave.cut_fac),
                disp('WARNING: The ray might be too short. Increase tfinal')
            end
        else
            is_max = min([ns,wave.kextra+find(ray.stau_lin > 10*wave.cut_fac)]);
            if ray.stau_lin(end) < 10*wave.cut_fac && ~isinf(wave.cut_fac),
                disp('WARNING: The ray might be too short. Increase tfinal')
            end            
        end
        %
        frays = fieldnames(ray);
        for ifield = 1:length(frays),
            ns_field = length(ray.(frays{ifield}));
            if ns_field == ns,
                ray.(frays{ifield}) = ray.(frays{ifield})(:,1:is_max);
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
