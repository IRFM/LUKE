function [wave] = wave_solver_yp(dkepath,wavestruct,f0struct)
%
% Wave solver module for LUKE. Self-consistent calculations with or without plasma fluctuations
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
if isfield(wavestruct,'waveparam') && isfield(wavestruct.waveparam,'n_rf_list'),
    n_rf_list = wavestruct.waveparam.n_rf_list;
elseif isfield(dkeparam,'n_rf_list'),
    n_rf_list = dkeparam.n_rf_list;
else
    disp('Warning : no n_rf_list data found, enforced to 0:3')
    n_rf_list = 0:3;
end
%
if strcmp(wavestruct.wavesolver,'C3PO'),% C3P0 ray tracing
    rayinit = main_rayinit_launch_jd(wavestruct.equil,wavestruct.launch);
    %
    if ~isfield(wavestruct,'C3POparam'),
        wavestruct.C3POparam = [];
    end
    %
    if ~isfield(wavestruct.equil_fit,'fluct_fit'),
        wave = main_C3PO_jd(dkepath,wavestruct.id,wavestruct.equil,wavestruct.equil_fit,rayinit,wavestruct.waveparam,[],wavestruct.rayparam,wavestruct.raydisplay,wavestruct.C3POparam);%Ray calculations
    else
        wave = main_C3PO_jd(dkepath,wavestruct.id,wavestruct.equil,wavestruct.equil_fit,rayinit,wavestruct.waveparam,[],wavestruct.rayparam,wavestruct.raydisplay,wavestruct.C3POparam,f0struct,wavestruct.equil_fit.fluct_fit);%Ray calculations
    end
    %
    wave = wave_process_jd(wavestruct.equil,wave,n_rf_list);%Wave processing and relativistic linear damping
    %
    if isfield(wavestruct.launch,'b_sdNpar') == 1,
        wave.b_sdNpar = wavestruct.launch.b_sdNpar;
    end
    %
elseif strcmp(wavestruct.wavesolver,'AMR'),% AMR ray tracing
    %
    wave = make_wave_AMR_jd(wavestruct,equil);%Ray calculations
    %
    wave = wave_process_jd(equil,wave,n_rf_list);%Wave processing and relativistic linear damping
    %
else
    error('This wave solver is not linked to LUKE.')
end