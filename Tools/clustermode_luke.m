% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [dkecluster] = clustermode_luke(param,fun,dkepath,remnum)
%
% This function provides an interface between LUKE and mdce_clustermode(param,fun)
%
% INPUTS : 
%   - param : parameters for distributed computing
% -> see mdce_clustermode for a detailed list of parameters
%
%   Notes : 
%           o if param contains the field 'remnum', it is equivalent to specifying the fourth argument 
%           o if param == '', the field clustermode is searched within the structure 'dkepath'
%
%   Different modes can be used for distributed computing
%
%           o (0)           : sequential
%           o (1)           : job scheduler (Matlab MDCE required)             (+i enables GPU calculations)
%           o (2)           : parfor parallel computing (Matlab MDCE required) (+i enables GPU calculations)
%           o (-1, -2, ...) : use of remcomputing with profile #1, #2, ... in structure dkepath
%
%   - fun : function name, used if (fun) is a field of param 
%               (case when param contains distributed computing parameters for multiple functions)
%
%   - dkepath : LUKE path structure including remote profiles, and possibly a field clustermode
%
%   - remnum : remote profile index for use of mdce_remote (transfer entire calculation to remote host)
%
% OUTPUT :
%   - dkecluster : structure containing MDCE properties
%
if ~ismember('mute_clustermode_luke', who('global'))
    mute_clustermode_luke = 0;
else
    global mute_clustermode_luke
end
%
if nargin < 3
    dkepath = load_structures_yp('dkepath','','');
end
if nargin < 2
    fun = '';
end
if nargin < 1
    param = 0;
end
if isempty(param)
    if isfield(dkepath,'clustermode')
        param = dkepath.clustermode;
    else
        param = 0;
    end
end
%
% manage case where param.(fun) is defined
%
if ~isempty(fun)% when function-specific DC parameters are present 
    %
    if isfield(param,fun) % DC parameters found for the specific function
        if isfield(param.(fun),'scheduler') && isfield(param.(fun).scheduler,'mode'),
            dkecluster.scheduler = param.(fun).scheduler;
        elseif isfield(param.(fun),'batch')
            %not yet implemented
            if mute_clustermode_luke == 0
                disp('Warning : batch structure not yet implemented')
            end
            dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced
        else
            if mute_clustermode_luke == 0
                disp('Warning : dkecluster type not recognized')
            end
            dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced
        end        
    else
        dkecluster.scheduler.mode = 0;%function not referenced in param, sequential mode enforced
    end
elseif ~isstruct(param)
    if isscalar(param)
        dkecluster.scheduler.mode = param;
    else
        dkecluster.scheduler.mode = 0;%param type not recognized, sequential mode enforced
    end
else
    if isfield(param,'mode')
        dkecluster.scheduler = param;
    else
        if mute_clustermode_luke == 0
            disp('Warning : dkecluster type not recognized')
        end
        dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced      
    end
end
%
% link with dkepath : LUKE paths, local cluster, remote profiles
%
mode = dkecluster.scheduler.mode;
%
if isfield(dkepath,'remote'),
    remote = dkepath.remote;
else
    remote = [];
end
%
nrem = length(remote);
%
% distributed computing mode
%
if ~any(mode == -nrem:3)
    if mute_clustermode_luke == 0
        disp('Warning : invalid cluster mode')
    end
    dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced      
elseif any(mode == -nrem:-1),
    %
    if ~isfield(remote(-mode),'env') || ~isfield(remote(-mode).env,'luke_root')
        if mute_clustermode_luke == 0
            disp(['Warning : luke_root not specified in dkepath.remote(',num2str(-mode),'). Switching to sequential mode'])
        end
        dkecluster.scheduler.mode = 0;%sequential mode enforced     
    else
        dkecluster.scheduler.mode = remote(-mode);
        dkecluster.scheduler.remnum = -mode*i;
    end
end
%
% possible use of mdce_remote
%
if nargin < 4
    if isfield(dkecluster.scheduler,'remnum'),
        remnum = dkecluster.scheduler.remnum;
    else
        remnum = 0;
    end
end
if ~iscell(remnum)
    remnum = {remnum};
end
if remnum{1} > 0
    for irem = 1:length(remnum)
        if any(remnum{irem} == 1:nrem)
            dkecluster.scheduler.remote{irem} = remote(remnum{irem});
            if irem == length(remnum) && mode >= 0 % in this case remote{irem} must have LUKE paths
                if ~isfield(remote(remnum{irem}),'env') || ~isfield(remote(remnum{irem}).env,'luke_root')
                    if mute_clustermode_luke == 0
                        disp(['Warning : luke_root not specified in dkepath.remote(',remnum{irem},'). Switching to sequential mode'])
                    end
                    dkecluster.scheduler.mode = 0;%sequential mode enforced  
                    dkecluster.scheduler.remote = [];                    
                end
            end
        else
            if mute_clustermode_luke == 0
                disp('Warning : invalid mdce_remote mode')
            end
            dkecluster.scheduler.remote = [];
            break
        end
    end
end
%
if exist('private_bridge_parameters.m','file') && remnum{1} > 0
    %
    if ~isempty(dkecluster.scheduler.remote{1}.bridge) && isfield(dkecluster.scheduler.remote{1}.bridge.ssh,'remotepassword') && ~isempty(dkecluster.scheduler.remote{1}.bridge.ssh.remotepassword) && isfield(dkecluster.scheduler.remote{1},'hosts') && ~isempty(dkecluster.scheduler.remote{1}.hosts) && length(dkecluster.scheduler.remote{1}.hosts) > 1
        %
        dkecluster.scheduler.remote{1}.ssh.sshcmd = strrep(dkecluster.scheduler.remote{1}.ssh.sshcmd,[dkecluster.scheduler.remote{1}.remoteuser,'@',dkecluster.scheduler.remote{1}.hosts{1}],[dkecluster.scheduler.remote{1}.remoteuser,'@',dkecluster.scheduler.remote{1}.hosts{2}]);% choose the external IP since connected from outside
        dkecluster.scheduler.remote{1}.ssh.scpcmd = strrep(dkecluster.scheduler.remote{1}.ssh.scpcmd,[dkecluster.scheduler.remote{1}.remoteuser,'@',dkecluster.scheduler.remote{1}.hosts{1}],[dkecluster.scheduler.remote{1}.remoteuser,'@',dkecluster.scheduler.remote{1}.hosts{2}]);% choose the external IP since connected from outside
        dkecluster.scheduler.remote{1}.host = dkecluster.scheduler.remote{1}.hosts{2};% choose the external IP since connected from outside
        % 
    end
    %
end
%
[dkecluster] = mdce_clustermode(dkecluster.scheduler);
%
if isfield(dkecluster,'scheduler') && isfield(dkecluster,'remote')
    %
    if isfield(dkecluster.scheduler,'walltime') && isfield(dkecluster.remote,'walltime')
        %
        if isnumeric(dkecluster.scheduler.walltime) && isnumeric(dkecluster.remote.walltime)
            %
            if dkecluster.scheduler.walltime > dkecluster.remote.walltime
                %
                dkecluster.remote.walltime = dkecluster.scheduler.walltime;
                %
            end
            %
        end
        %
    end
    %
end
%
