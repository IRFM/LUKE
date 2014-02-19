function flag = check_remote_yp(dkepath)
%
%	Check if remote links are available and functionning
%
%	Input:
%
%       - dkepath: path structure with nrem remote profiles
%         (default: if no input structure or empty, dkepath is automatically loaded from PATH_LOCAL.mat)
%        
%
%	Output:
%
%       - flag    : 1 -> remote link working, 0 -> remote link not working [1,nrem]
%
%   Warning: If the process is blocked (no automatic ssh login for example or remote computer behind a firewall or 
%   remote cluster (or computer) not running, type CTRL-C to escape.
%
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0,
    dkepath = load_structures_yp('dkepath','','');
end
%
nrem = length(dkepath.remote);
%
info_dke_yp(5,['Number of remote profiles: ',int2str(nrem)]);
info_dke_yp(2,['If test of one profile does not complete in a minute or less, please use ''CTRL+C'' and check the following :']);
info_dke_yp(4,'Direct ssh connection must be recorded in known_hosts');
info_dke_yp(4,'Direct ssh connection must be free of user prompts (no password, use ssh key pair)');
info_dke_yp(4,'Job might be stuck in queue - check cluster usage, priorities, and job attributes.');
disp(' ')
%
flag = false(1,nrem);
%  
for irem = 1:nrem,
    %
    remote = dkepath.remote(irem);
    %
    if ~iscell(remote.cmd) && ~isempty(strfind(remote.cmd,'qsub')),
        cmdstr = 'qsub';
    elseif ~iscell(remote.cmd) && ~isempty(strfind(remote.cmd,'condor')),
        cmdstr = 'condor';
    elseif iscell(remote.cmd) && any(~cellfun('isempty',strfind(remote.cmd,'xgrid'))),
        cmdstr = 'xgrid';
    else
        cmdstr = 'unknown';
    end
    %
    job = matstandardjob_jd('runmat','setpath_luke_jd',[remote.env.luke_root,'Project_DKE/DKE/']);% standard job
    job.debugmode = 1; % to display info and debug
    job.funcopy = 0; % (0) to use function LUKEversion_jd on the remote host within matlab path
    %
    [err,remotelukever,~,remotematrel] = matremote_jd('LUKEversion_jd',{},remote,job);
    %
    if isempty(remote.host),
        info_dke_yp(2,['Profile #',num2str(irem),' to host : local with cmd : ',cmdstr])
    else
        info_dke_yp(2,['Profile #',num2str(irem),' to host : ',remote.host,' with cmd : ',cmdstr])
    end        
    %
    if isempty(err),        
        info_dke_yp(4,['Version ',remotelukever,' with Matlab ',remotematrel,' working.'])
        flag(irem) = true;
    else
        disperr_jd(err)
    end
    %
    disp(' ')
end
%