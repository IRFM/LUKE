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
    if ~iscell(dkepath.remote(irem).cmd) && ~isempty(strfind(dkepath.remote(irem).cmd,'qsub')),
        cmdstr = 'qsub';
    elseif ~iscell(dkepath.remote(irem).cmd) && ~isempty(strfind(dkepath.remote(irem).cmd,'condor')),
        cmdstr = 'condor';
    elseif iscell(dkepath.remote(irem).cmd) && any(~cellfun('isempty',strfind(dkepath.remote(irem).cmd,'xgrid'))),
        cmdstr = 'xgrid';
    else
        cmdstr = 'unknown';
    end
    %
    [err,remotelukever,~,remotematrel] = matremote_luke_jd('LUKEversion_jd',{},dkepath.remote(irem));
    %
    if isempty(dkepath.remote(irem).host),
        info_dke_yp(2,['Profile #',num2str(irem),' to host : local with cmd : ',cmdstr])
    else
        info_dke_yp(2,['Profile #',num2str(irem),' to host : ',dkepath.remote(irem).host,' with cmd : ',cmdstr])
    end        
    %
    if isempty(err),        
        info_dke_yp(4,['Version ',remotelukever,' with Matlab ',remotematrel,' working.'])
        flag(irem) = true;
    else
        info_dke_yp(4,'Remote link failed for the following reason : ')
        if iscell(err),
            for ierr = 1:length(err),
                disp(err(ierr))
            end
        else
            disp(err)
        end
    end
    %
    disp(' ')
end
%