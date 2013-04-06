function rundke_metis(path_sources,locid_simul,basestr,shotnum,shotimes,opt,dkepath,wavestructs,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple)
%
% function running LUKE using METIS output and possibly user-defined
% parameters
%
% INPUTS :
%
%   - path_sources          : Source files path (leave empty for current path)
%   - locid_simul           : Simulation local id (leave empty for standard id)
%   - c_opt                 : Option for distributed batch jobs (0) : sequential, (1, 2, ...) remote profile number 
%   - basestr               : tokamak name (ex: TS, ITER, ...)
%   - shotnum               : shot number (string)
%   - shotimes    (optional): shot times to consider (cell array of strings *.****). Leave empty to include all relevant METIS data files in directory (default)
%   - opt         (optional): options for saving LUKE results remotely, backup, wave, etc...
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
if nargin < maxnargin-8 || (~isstruct(opt) && any(isnan(dkepath))),
    opt = struct;
end
if nargin < maxnargin-9,
    shotimes = {};% all shot times
end
if nargin < maxnargin-10,
    error('shot number must be specified');
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
    lukestructs{ishot} = lukestruct;
    %
end
%
% Run LUKE
%
dkepath.remtimout = 0;% do not return results, as it could be too heavy in terms of memory
%
lukestructs = run_lukert(lukestructs,dkepath);
%
% Save results if needed
%
savestr = [basestr,'_',shotnum];
%
if ~isempty(locid_simul),
    savestr = [savestr,'_',locid_simul];
end
%
save_batch_jd(lukestructs,dkepath,savestr)
%
