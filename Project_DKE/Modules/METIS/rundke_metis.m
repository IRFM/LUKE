function rundke_metis(path_sources,locid_simul,basestr,shotnum,shotimes,opt,dkepath,wavestructs,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,metisevol,scheduler_run_lukert)
%
% function running LUKE using METIS output and possibly user-defined
% parameters
%
% INPUTS :
%
%   - path_sources                    : Source files path (leave empty for current path)
%   - locid_simul                     : Simulation local id (leave empty for standard id)
%   - c_opt                           : Option for distributed batch jobs (0) : sequential, (1, 2, ...) remote profile number 
%   - basestr                         : tokamak name (ex: TS, ITER, ...)
%   - shotnum                         : shot number (string)
%   - shotimes              (optional): shot times to consider (cell array of strings *.****). Leave empty to include all relevant METIS data files in directory (default)
%   - opt                   (optional): options for saving LUKE results remotely, backup, wave, etc...
%   - dkepath               (optional): path structure for LUKE simulations (Leave empty for LOCAL path)
%   - wavestructs           (optional): user-defined wavestruct parameters (cell array of structure array, of size 1 or shotimes)
%   - equil                 (optional): user-defined equil parameters (structure array of size 1 or shotimes)
%   - dkeparam              (optional): user-defined dkeparam parameters (structure array of size 1 or shotimes)
%   - dkedisplay            (optional): user-defined dkedisplay parameters (structure array of size 1 or shotimes)
%   - ohm                   (optional): user-defined ohm parameters (structure array of size 1 or shotimes)
%   - transpfaste           (optional): user-defined transpfaste parameters (structure array of size 1 or shotimes)
%   - ripple                (optional): user-defined ripple parameters (structure array of size 1 or shotimes)
%   - metisevol             (optional): time evolution (1) or indepedent times (0)
%   - scheduler_run_lukert  (optional): distributed calculation options for run_lukert
%
% NOTE: the optional structures wavestructs ... ripple do not need to contain all fields. They are concatenated with METIS parameters.
%
% by J. Decker (joan.decker@cea.fr) and E. Nilsson (emelie.nilsson@cea.fr)
%
maxnargin = 16;
%
if nargin < maxnargin,
    scheduler_run_lukert = struct;
end
if nargin < maxnargin-1,
    metisevol = 0;
end
if nargin < maxnargin-2 || (~isstruct(ripple) && any(isnan(ripple))),
    ripple = struct;
end
if nargin < maxnargin-3 || (~isstruct(transpfaste) && any(isnan(transpfaste))),
    transpfaste = struct;
end
if nargin < maxnargin-4 || (~isstruct(ohm) && any(isnan(ohm))),
    ohm = struct;
    %ohm='';
end
if nargin < maxnargin-5 || (~isstruct(dkedisplay) && any(isnan(dkedisplay))),
    dkedisplay = struct;
end
if nargin < maxnargin-6 || (~isstruct(dkeparam) && any(isnan(dkeparam))),
    dkeparam = struct;
end
if nargin < maxnargin-7 || (~isstruct(equil) && any(isnan(equil))),
    equil = struct;
end
if nargin < maxnargin-8 || (~iscell(wavestructs) && ~isstruct(wavestructs) && any(isnan(wavestructs))),
    wavestructs = struct;
end
if nargin < maxnargin-9 || (~isstruct(dkepath) && any(isnan(dkepath))),
    dkepath = load_structures_yp('dkepath','','');
end
if nargin < maxnargin-10 || (~isstruct(opt) && any(isnan(opt))),
    opt = struct;
end
if nargin < maxnargin-11,
    shotimes = {};% all shot times
end
if nargin < maxnargin-12,
    error('shot number must be specified');
end
%
if metisevol == 0,
    dkepath.remtimout = 0;% do not return results, as it could be too heavy in terms of memory
else    
    dkepath.remtimout = Inf;% return result needed for next step
    opt.save = 1;% save each time step for later processing
    opt.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
    dkeparam.tn_mode = 1;% time given in seconds
end
%
% select source files associated with the current shot
%
if isempty(path_sources),
    path_sources = './';
end
%
[shotimes,isel] = select_shotimes_jd(['before_luke@',basestr,'_',shotnum,'_'],'.mat',path_sources,shotimes);
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
lukestructs = cell(1,nshots);
%
for ishot = 1:nshots
    %
    metis_data = load([path_sources,filesep,'before_luke@',basestr,'_',shotnum,'_',shotimes{ishot},'.mat']);
    %
    lukestruct = struct;
    %
    % replace structure content with user prescription 
    %
    if length(dkeparam) > 1,
        lukestruct.dkeparam = conc_struct_jd(metis_data.dkeparam,dkeparam(ishot));
    else
        lukestruct.dkeparam = conc_struct_jd(metis_data.dkeparam,dkeparam);
    end 
    %
    if length(dkedisplay) > 1,
        lukestruct.dkedisplay = conc_struct_jd(metis_data.dkedisplay,dkedisplay(ishot));
    else
        lukestruct.dkedisplay = conc_struct_jd(metis_data.dkedisplay,dkedisplay);
    end        
    %
    if length(equil) > 1,
        lukestruct.equil = conc_struct_jd(metis_data.equil,equil(ishot));
    else
        lukestruct.equil = conc_struct_jd(metis_data.equil,equil);
    end        
    %
    if length(metis_data.wavestructs) == 1 && iscell(wavestructs) && length(wavestructs) > 1,
        metis_data.wavestructs = repmat(metis_data.wavestructs,[1,length(wavestructs)]);
    end
    if isempty(metis_data.wavestructs) && iscell(wavestructs) && length(wavestructs) >= 1,
        metis_data.wavestructs = repmat({struct},[1,length(wavestructs)]);
    end
    %
    lukestruct.wavestructs = {};
    for iw = 1:length(metis_data.wavestructs),
        if iscell(wavestructs),% wavestruct specified for each wave
            if length(wavestructs{iw}) > 1,
                lukestruct.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs{iw}(ishot));
            else
                lukestruct.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs{iw});
            end
        else% wavestruct specified for all wave
            if length(wavestructs) > 1,
                lukestruct.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs(ishot));
            else
                lukestruct.wavestructs{iw} = conc_struct_jd(metis_data.wavestructs{iw},wavestructs);
            end
        end
    end
    %
    if length(ohm) > 1,
        lukestruct.ohm = conc_struct_jd(metis_data.ohm,ohm(ishot));
    else
        lukestruct.ohm = conc_struct_jd(metis_data.ohm,ohm);
    end        
    if length(transpfaste) > 1,
        lukestruct.transpfaste = conc_struct_jd(metis_data.transpfaste,transpfaste(ishot));
    else
        lukestruct.transpfaste = conc_struct_jd(metis_data.transpfaste,transpfaste);
    end        
    if length(ripple) > 1,
        lukestruct.ripple = conc_struct_jd(metis_data.ripple,ripple(ishot));
    else
        lukestruct.ripple = conc_struct_jd(metis_data.ripple,ripple);
    end 
    %
    lukestruct.opt = opt;
    %
    % Simulation ID
    %
    lukestruct.simul.id = ['METIS_',make_luke_simulid_jd(lukestruct.equil,lukestruct.ohm,lukestruct.transpfaste,lukestruct.ripple,...
        '',lukestruct.wavestructs,locid_simul)];
    %
    if ~isfield(dkepath,'remnum') || dkepath.remnum == 0 || isempty(dkepath.remote(dkepath.remnum).host),
        lukestruct.simul.path = path_sources;
    end
    %
    lukestructs{ishot} = lukestruct;
    %
    if isfield(opt,'saveinputs') && opt.saveinputs == 1,
        %
        saveinputs_jd(lukestruct);
        %
    end
    %
end
%
% Run LUKE
%
if metisevol == 0,
    %
    if isfield(dkepath,'remnum') && dkepath.remnum > 0,% calculations distributed within run_lukert
        %
        lukestructs = run_lukert(lukestructs,dkepath);
        %
    else % calculations distributed using mdce_luke
        %
        clustermode.run_lukert.scheduler = scheduler_run_lukert;
        dkecluster = clustermode_luke(clustermode,'run_lukert',dkepath);
        %
        [~,lukestructs] = mdce_luke(@run_lukert,{''},1,lukestructs,dkecluster);
        %
    end
    %
else
    %
    if metisevol == 1,% start from t = -inf
        lukestructs{1}.dkeparam.tn = NaN;% asymptotic first time calculation
    else % start from t = 0
        lukestructs{1}.dkeparam.tn = str2double(shotimes{1});% asymptotic first time calculation
    end
    %
    lukestruct = run_lukert(lukestructs{1},dkepath);
    %
    if ~isfield(lukestruct.dkeparam,'Te_ref') || ~isfield(lukestruct.dkeparam,'ne_ref'),% reference from first time
        lukestruct.dkeparam.Te_ref = lukestruct.output.mksa.Te_ref;
        lukestruct.dkeparam.ne_ref = lukestruct.output.mksa.ne_ref;
    end
    %
    for ishot = 2:nshots,
        lukestructs{ishot}.XXf0 = lukestruct.output.dke_out.Zf0_interp(end);% start from previous distribution
        lukestructs{ishot}.dkeparam.rho_S = lukestruct.output.radialDKE.xrho_S_dke;% use same radial grid
        lukestructs{ishot}.dkeparam.tn = str2double(shotimes{ishot}) - str2double(shotimes{ishot-1});% time in seconds
        %
        lukestruct = run_lukert(lukestructs{ishot},dkepath);
    end
end
%
% Save results if needed
%
if ~isfield(opt,'save') || opt.save == 0,
    %
    savestr = [basestr,'_',shotnum];
    %
    if ~isempty(locid_simul),
        savestr = [savestr,'_',locid_simul];
    end
    %
    save_batch_jd(lukestructs,dkepath,savestr)
    %
end
%
