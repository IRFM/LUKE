function wave = wave_process_jd(equil,wave,n_rf_list,opt_cut,method);
%
% This function completes the missing wave characteristics. In particular, it calculates the wave
% absorption coefficient and the wave lilnear damping.
%
% by 	J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
% and   Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
if nargin < 5,
    method = 'linear';%'spline';%interpolation technique in psi
end
if nargin < 4,
    opt_cut = 1;%'spline';%interpolation technique in psi
end
%
% Equilibrium data with Fourier-enhanced poloidal precision and original radial grid
%
[equilDKE_Fourier] = equilibrium_jd(equil);
%
% Ray processing
%
for ib = 1:length(wave.rays),
    ray = rayprocess_jd(wave.rays{ib},equilDKE_Fourier,wave.opt_disp,wave.omega_rf,n_rf_list,method);
    %
    % Ray linear damping
    %
    salphaphi_lin = ray.salphaphi_lin;
    if sum(~isnan(salphaphi_lin)) > 0,%absorption coefficient was calculated
        sphi_norm = sqrt(abs(ray.sphi_xyz(1,:)).^2 + abs(ray.sphi_xyz(2,:)).^2 + abs(ray.sphi_xyz(3,:)).^2);
        salpha_lin = salphaphi_lin./sphi_norm;
        salpha_lin(isnan(salpha_lin)) = 0;
        salpha_lin_h = (salpha_lin(1:end-1) + salpha_lin(2:end))/2;
        sds = diff(ray.ss);
        ray.sP_2piRp = ray.P0_2piRp*exp(-[0,cumsum(salpha_lin_h.*sds)]);
        ray.sdP_2piRp_ds = salpha_lin.*ray.sP_2piRp;
        %
        if opt_cut == 1,
            ns = length(ray.ss);
            is_max = min([ns,round(find(ray.sP_2piRp < ray.P0_2piRp/1000)*1.1)]);
            frays = fieldnames(ray);
            for ifield = 1:length(frays),
                eval(['ns_field = length(ray.',frays{ifield},');'])
                if ns_field == ns,
                    eval(['ray.',frays{ifield},' = ray.',frays{ifield},'(:,1:is_max);'])
                end
            end
        end
    end
    wave.rays{ib} = ray;
   info_dke_yp(2,['Damping of ray #',num2str(ib),' calculated']);    
end
%
wave.opt_disp = 0;
%
