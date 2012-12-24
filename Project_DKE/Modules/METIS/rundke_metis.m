function rundke_metis(path_simul,locid_simul,c_opt,basestr,shotnum,shotimes,dkepath,wavestructs,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple)
%
% function running LUKE using METIS output and possibly user-defined
% parameters
%
% INPUTS :
%
%   - path_simul            : Simulation path (leave empty for current path)
%   - locid_simul           : Simulation local id (leave empty for standard id)
%   - c_opt                 : Option for distributed batch jobs (0) : sequential, (1, 2, ...) remote profile number 
%   - basestr               : tokamak name (ex: TS, ITER, ...)
%   - shotnum               : shot number (string)
%   - shotimes    (optional): shot times to consider (cell array of strings *.****). Leave empty to include all relevant METIS data files in directory (default)
%   - dkepath     (optional): path structure for LUKE simulations (Leave empty for LOCAL path)
%   - wavestructs (optional): user-defined wavestruct parameters (cell array of structure array, of size 1 or shotimes)
%   - equil       (optional): user-defined equil parameters (structure array of size 1 or shotimes)
%   - dkeparam    (optional): user-defined dkeparam parameters (structure array of size 1 or shotimes)
%   - dkedisplay  (optional): user-defined dkedisplay parameters (structure array of size 1 or shotimes)
%   - ohm         (optional): user-defined ohm parameters (structure array of size 1 or shotimes)
%   - transpfaste (optional): user-defined transpfaste parameters (structure array of size 1 or shotimes)
%   - ripple      (optional): user-defined ripple parameters (structure array of size 1 or shotimes)
%
% NOTE: the optional structures wavestructs ... ripple do not need to contain all fields. They are concatenated with METIS parameters.
%
% by J. Decker (joan.decker@cea.fr) and E. Nilsson (emelie.nilsson@cea.fr)
%
maxnargin = 14;
%
if nargin < maxnargin || (~isstruct(ripple) && any(isnan(ripple))),
    ripple = struct;
end
if nargin < maxnargin-1 || (~isstruct(transpfaste) && any(isnan(transpfaste))),
    transpfaste = struct;
end
if nargin < maxnargin-2 || (~isstruct(ohm) && any(isnan(ohm))),
    ohm = struct;
    %ohm='';
end
if nargin < maxnargin-3 || (~isstruct(dkedisplay) && any(isnan(dkedisplay))),
    dkedisplay = struct;
end
if nargin < maxnargin-4 || (~isstruct(dkeparam) && any(isnan(dkeparam))),
    dkeparam = struct;
end
if nargin < maxnargin-5 || (~isstruct(equil) && any(isnan(equil))),
    equil = struct;
end
if nargin < maxnargin-6 || (~iscell(wavestructs) && ~isstruct(wavestructs) && any(isnan(wavestructs))),
    wavestructs = struct;
end
if nargin < maxnargin-7 || (~isstruct(dkepath) && any(isnan(dkepath))),
    dkepath = load_structures_yp('dkepath','','');
end
if nargin < maxnargin-8,
    shotimes = {};% all shot times
end
if nargin < maxnargin-9,
    error('shot number must be specified');
end
%
s_opt = imag(c_opt);
c_opt = real(c_opt);
%
% select source files associated with the current shot
%
if isempty(path_simul),
    path_simul = pwd;
end
%
[shotimes,isel] = select_shotimes_jd(['before_luke@',basestr,'_',shotnum,'_'],'.mat',path_simul,shotimes);
%
% select shot times
%
if ~isnan(isel),% indices in structure arrays
    %
    % case of structure arrays
    %
    if length(dkeparam) > 1,
        dkeparam = dkeparam(isel);
    end
    if length(dkedisplay) > 1,
        dkedisplay = dkedisplay(isel);
    end
    if length(equil) > 1,
        equil = equil(isel);
    end
    for iw = 1:length(wavestructs),
        if iscell(wavestructs) && length(wavestructs{iw}) > 1,
            wavestructs{iw} = wavestructs{iw}(isel);
        elseif ~iscell(wavestructs) && length(wavestructs) > 1,
            wavestructs = wavestructs(isel);
        end
    end
    if length(ohm) > 1,
        ohm = ohm(isel);
    end
    if length(transpfaste) > 1,
        transpfaste = transpfaste(isel);
    end
    if length(ripple) > 1,
        ripple = ripple(isel);
    end
end
%
nshots = length(shotimes);
%
% LUKE calculation for selected shotimes
%
jobs = cell(1,nshots);
luke_inputs = cell(1,nshots);
%
for ishot = 1:nshots
    %
    metis_data = load([path_simul,filesep,'before_luke@',basestr,'_',shotnum,'_',shotimes{ishot},'.mat']);
    %
    luke_input = struct;
    %
    % replace structure content with user prescription 
    %
    if length(dkeparam) > 1,
        luke_input.dkeparam = conc_struct_jd(metis_data.dkeparam,dkeparam(ishot));
    else
        luke_input.dkeparam = conc_struct_jd(metis_data.dkeparam,dkeparam);
    end 
    %
    if length(dkedisplay) > 1,
        luke_input.dkedisplay = conc_struct_jd(metis_data.dkedisplay,dkedisplay(ishot));
    else
        luke_input.dkedisplay = conc_struct_jd(metis_data.dkedisplay,dkedisplay);
    end        
    %
    if length(equil) > 1,
        luke_input.equil = conc_struct_jd(metis_data.equil,equil(ishot));
    else
        luke_input.equil = conc_struct_jd(metis_data.equil,equil);
    end        
    %
    if length(metis_data.wavestructs) == 1 && iscell(wavestructs) && length(wavestructs) > 1,
        metis_data.wavestructs = repmat(metis_data.wavestructs,[1,length(wavestructs)]);
    end
    if isempty(metis_data.wavestructs) && iscell(wavestructs) && length(wavestructs) >= 1,
        metis_data.wavestructs = repmat({struct},[1,length(wavestructs)]);
    end
    %
    luke_input.wavestructs = {};
    for iw = 1:length(metis_data.wavestructs),
        if iscell(wavestructs),% wavestruct specified for each wave
            if length(wavestructs{iw}) > 1,
                luke_input.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs{iw}(ishot));
            else
                luke_input.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs{iw});
            end
        else% wavestruct specified for all wave
            if length(wavestructs) > 1,
                luke_input.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs(ishot));
            else
                luke_input.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs);
            end
        end
    end
    %
    if length(ohm) > 1,
        luke_input.ohm = conc_struct_jd(metis_data.ohm,ohm(ishot));
    else
        luke_input.ohm = conc_struct_jd(metis_data.ohm,ohm);
    end        
    if length(transpfaste) > 1,
        luke_input.transpfaste = conc_struct_jd(metis_data.transpfaste,transpfaste(ishot));
    else
        luke_input.transpfaste = conc_struct_jd(metis_data.transpfaste,transpfaste);
    end        
    if length(ripple) > 1,
        luke_input.ripple = conc_struct_jd(metis_data.ripple,ripple(ishot));
    else
        luke_input.ripple = conc_struct_jd(metis_data.ripple,ripple);
    end        
    %
    luke_input.waves = '';
    luke_input.Zf0_interp = '';
    luke_input.XXsinksource = '';
    %
    % Simulation ID
    %
    id_simul = ['METIS_',luke_input.equil.id];
    for iw = 1:length(luke_input.wavestructs),
        id_simul = [id_simul,'_',luke_input.wavestructs{iw}.id];
    end
    if isfield(luke_input.ohm,'id'),
        id_simul = [id_simul,'_',luke_input.ohm.id];
    else
        luke_input.ohm = '';
    end
    if isfield(luke_input.transpfaste,'id'),
        id_simul = [id_simul,'_',luke_input.transpfaste.id];
    else
        luke_input.transpfaste = '';
    end
    if isfield(luke_input.ripple,'id'),
        id_simul = [id_simul,'_',luke_input.ripple.id];
    else
        luke_input.ripple = '';
    end
    if ~isempty(locid_simul),
        id_simul = [id_simul,'_',locid_simul];
    end
    %
    luke_input.simul_in = id_simul;
    luke_input.opt_save = 0;
    %
    % Run LUKE
    %
    if c_opt == 0,% sequential mode
        %
        [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] ...
            = run_lukert(luke_input.simul_in,luke_input.wavestructs,luke_input.waves,luke_input.dkeparam.psin_S,luke_input.dkeparam.rho_S,dkepath,luke_input.equil,luke_input.dkeparam,luke_input.dkedisplay,luke_input.ohm,luke_input.transpfaste,luke_input.ripple,luke_input.Zf0_interp,luke_input.XXsinksource,luke_input.opt_save);
        %
        filename = [path_simul,filesep,'LUKE_RESULTS_',luke_input.simul_in,'.mat'];
        save(filename,'basestr','luke_input','Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource');
        info_dke_yp(2,['LUKE Results saved in ',filename]);
        %
    else
        %
        remote = dkepath.remote(c_opt);
        %
        jobs{ishot} = runluke_remote_jd(luke_input,remote);
        %
        luke_inputs{ishot} = luke_input;
        %
    end
    %
end
%
if c_opt == 0,
    return
elseif s_opt == 1,
    savestr = ['LUKE_BATCH_',basestr,'_',shotnum];
    if ~isempty(locid_simul),
        savestr = [savestr,'_',locid_simul];
    end
    filename = [path_simul,filesep,savestr,'.mat'];
    ifilenum = 0;
    while exist(filename,'file'),
        ifilenum = ifilenum + 1;
        filename = [path_simul,filesep,savestr,'_',num2str(ifilenum),'.mat'];
    end        
    save(filename,'path_simul','basestr','shotimes','luke_inputs','jobs','remote')
    disp(['Batch info saved in ',filename])
    return
end
%
% Load and save LUKE results
%
w_opt = 4;%time to wait for all jobs to be completed, in hours
tic
%
completed_jobs = zeros(1,nshots);
%
while any(completed_jobs == 0) && toc/3600 < w_opt,
    %
    pause(15);
    %
    disp(['Some jobs are still running , elapsed time (minutes) ',num2str(round(toc/60)),'/',num2str(w_opt)])
    %
    for ishot = find(completed_jobs == 0),
        %
        output = getluke_remote_jd(timeids{ishot},jobids{ishot},remote);
        %
        if isempty(output)
            disp(['Remote LUKE still running for time ',shotimes{ishot}])
        elseif isfield(output,'err'),
            disp(['Remote LUKE run failed for time ',shotimes{ishot}])
            completed_jobs(ishot) = -1;
        else
            disp(['Remote LUKE completed for time ',shotimes{ishot}])
            %
            Znorm = output.Znorm;
            Zcurr = output.Zcurr;
            ZP0 = output.ZP0;
            dke_out = output.dke_out;
            radialDKE = output.radialDKE;
            equilDKE = output.equilDKE;
            momentumDKE = output.momentumDKE;
            gridDKE = output.gridDKE;
            Zmomcoef = output.Zmomcoef;
            Zbouncecoef = output.Zbouncecoef;
            Zmripple = output.Zmripple;
            mksa = output.mksa;
            XXsinksource = output.XXsinksource;
            %
            luke_input = luke_inputs{ishot};
            %
            filename = [path_simul,filesep,'LUKE_RESULTS_',luke_input.simul_in,'.mat'];
            save(filename,'basestr','luke_input','Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource');
            info_dke_yp(2,['LUKE Results saved in ',filename]);
            %
            completed_jobs(ishot) = 1;
        end
        %
    end
end
%   

