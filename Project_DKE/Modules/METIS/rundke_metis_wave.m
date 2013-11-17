function rundke_metis_wave(basestr,shotnum,shotimes,locpath_simul,locid_simul,launch,dkeparam,dkedisplay,equil,ohm,transpfaste_in,fitparam,rayparam,waveparam,C3POdisplay,C3POparam)
%
if ~iscell(locpath_simul),
    path_simul = [basestr,filesep,shotnum,filesep,locpath_simul];% Simulation path (leave empty for current path)
else
    if length(locpath_simul) == 2,
        path_simul = [locpath_simul{1},basestr,filesep,shotnum,filesep,locpath_simul{2}];% Simulation path (leave empty for current path)
    else
        path_simul = locpath_simul{1};
    end
end    
%
% -------------------------------------------------------------------------
%
[dkepath,rtparam] = load_structures_yp('dkepath','','','rtparam','LH','');
%
% ====================================================
%
fitparam = conc_struct_jd(rtparam.fitparam,fitparam);
rayparam = conc_struct_jd(rtparam.rayparam,rayparam);
waveparam = conc_struct_jd(rtparam.waveparam,waveparam);
C3POdisplay = conc_struct_jd(rtparam.C3POdisplay,C3POdisplay);
C3POparam = conc_struct_jd(rtparam.C3POparam,C3POparam);
%
wavestruct.launch = launch;
wavestruct.wavesolver = 'C3PO';
if isfield(wavestruct.launch,'id'),
    wavestruct.id = [wavestruct.wavesolver,'_',wavestruct.launch.id];
end
wavestruct.waveparam = waveparam;
wavestruct.fitequilparam = fitparam;
wavestruct.rayparam = rayparam;
wavestruct.C3POparam = C3POparam;
wavestruct.raydisplay = C3POdisplay;
%
% backup & save options
%
opt.save = 1;% (1): save LUKE_RESULTS or return error (0): return results or error
opt.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
opt.backup = 0;% (1) save fluctuation time steps (0) do not save
opt.waves = 0;% (1) save waves at each time step (0) do not save
%
% ---- RADIAL TRANSPORT ----
%
if transpfaste_in.Dr0 > 0,
    %
    % initialization
    %
    transpfaste.Dr0 = 0;%Core radial diffusion coefficient (m/s)
    transpfaste.pDr = 0;%Coefficient for the Dr radial profile
    transpfaste.Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), (2) Energy dependence
    transpfaste.Vr0 = 0;%Core radial pinch coefficient (m/s)
    transpfaste.pVr = 0;%Coefficient for the Vr radial profile
    transpfaste.Vr_model = 0;%Radial pinch type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), (2) Energy dependence
    transpfaste.vparmin = 3.5;%Lower limit of the parallel velocity dependence of the radial diffusion and pinch (vth_ref or vth)
    transpfaste.norm_ref = 1;%Normalization procedure for the lower limit of the parallel velocity dependence of the radial diffusion and pinch: (0) from local values Te and ne, (1) from reference values Te_ref and ne_ref 
    %
    transpfaste = conc_struct_jd(transpfaste,transpfaste_in);
    %
    transpfaste.id = ['TR_',num2str(transpfaste.Dr_model),'_Dr0_',num2str(transpfaste.Dr0),'_pDr_',num2str(transpfaste.pDr)];
else
    transpfaste = struct;
end
%
% ====================================================
%
% start rundke_metis function
%
rundke_metis(path_simul,locid_simul,basestr,shotnum,shotimes,opt,dkepath,{wavestruct},equil,dkeparam,dkedisplay,ohm,transpfaste)
%