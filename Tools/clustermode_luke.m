function [dkecluster] = clustermode_luke(param,fun,dkepath,remnum)
%
% This function provides an interface between LUKE and mdce_clustermode(param,fun)
%
% INPUTS : 
%   - param : parameters for distributed computing
% -> see mdce_clustermode for a detailed list of parameters
%
%   Note : if param contains the field 'remnum', it is equivalent to specifying the fourth argument 
%
% Different modes can be used for distributed computing
%
%           o (0)           : sequential
%           o (1)           : job scheduler (Matlab MDCE required)             (+i enables GPU calculations)
%           o (2)           : parfor parallel computing (Matlab MDCE required) (+i enables GPU calculations)
%           o (-1, -2, ...) : use of remcomputing with profile #1, #2, ... in structure dkepath
%
%   - fun : function name, used if (fun) is a field of param 
%               (case when param contains distributed computing parameters for multiple functions)
%
%   - dkepath : LUKE path structure including remote profiles
%   - remnum : remote profile index for use of mdce_remote (transfer entire calculation to remote host)
%
% OUTPUT :
%   - dkecluster : structure containing MDCE properties
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%

%
% manage case where param.(fun) is defined
%
if ~isempty(fun)% when function-specific DC parameters are present 
    %
    if isfield(param,fun),% DC parameters found for the specific function
        if isfield(param.(fun),'scheduler') && isfield(param.(fun).scheduler,'mode'),
            dkecluster.scheduler = param.(fun).scheduler;
        elseif isfield(param.(fun),'batch'),
            %not yet implemented
            disp('Warning : batch structure not yet implemented')
            dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced
        else
            disp('Warning : dkecluster type not recognized')
            dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced
        end        
    else
        dkecluster.scheduler.mode = 0;%function not referenced in param, sequential mode enforced
    end
elseif ~isstruct(param),
    if isscalar(param),
        dkecluster.scheduler.mode = param;
    else
        dkecluster.scheduler.mode = 0;%param type not recognized, sequential mode enforced
    end
else
    if isfield(param,'mode'),
        dkecluster.scheduler = param;
    else
        disp('Warning : dkecluster type not recognized')
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
if ~any(mode == -nrem:2),
    disp('Warning : invalid cluster mode')
    dkecluster.scheduler.mode = 0;%dkecluster type not recognized, sequential mode enforced      
elseif any(mode == -nrem:-1),
    %
    if ~isfield(remote(-mode),'env') || ~isfield(remote(-mode).env,'luke_root'),
        disp(['Warning : luke_root not specified in dkepath.remote(',num2str(-mode),'). Switching to sequential mode'])
        dkecluster.scheduler.mode = 0;%sequential mode enforced     
    else
        dkecluster.scheduler.mode = remote(-mode);
        dkecluster.scheduler.mode.env.remotepathfnc = [remote(-mode).env.luke_root,'setpath_luke_jd'];% (optional, called by remotematrun) matlab function to set the path on the remote machine
    end
end
%
% possible use of mdce_remote
%
if nargin < 4,
    if isfield(dkecluster.scheduler,'remnum'),
        remnum = dkecluster.scheduler.remnum;
    else
        remnum = 0;
    end
end
if ~iscell(remnum),
    remnum = {remnum};
end
if remnum{1} > 0,
    for irem = 1:length(remnum),
        if any(remnum{irem} == 1:nrem),
            dkecluster.scheduler.remote{irem} = remote(remnum{irem});
            dkecluster.scheduler.remote{irem}.env.remotepathfnc = 'setpath_luke_jd';% (optional, called by remotematrun) matlab function to set the path on the remote machine
        else
            disp('Warning : invalid mdce_remote mode')
            dkecluster.scheduler.remote = [];
            break
        end
    end
end
%
[dkecluster] = mdce_clustermode(dkecluster.scheduler);
%
