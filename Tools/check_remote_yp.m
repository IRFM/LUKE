function flag = check_remote_yp(dkepath,debugmode,bridge_enforce)
%
%	Check if remote links are available and functionning
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%         (default: if no input structure or empty, dkepath is automatically loaded from PATH_LOCAL.mat)
%       - debugmode: display details   
%       - bridge_enforce : [NaN, empty, 0 or 1] if 1, provides step by step information, and save diary file in remote job folder 
%           o NaN : (default) use value from remote.bridge_enforce
%           o []  : tests both modes and give priority to ssh key pair
%           o 0   : tests only ssh key pair,
%           o 1   : tests only bridge mode
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
if nargin < 3,
    bridge_enforce = NaN;
end
if nargin < 2,
    debugmode = 0;
end
if nargin < 1 || isempty(dkepath),
    dkepath = load_structures_yp('dkepath','','');
end
%
% test connection and identify local profiles
%
disp(' ')
info_dke_yp(2,'Testing remote connection for dkepath.remote profiles');
%
[remote,profilestr] = load_remoteprofiles_jd(dkepath.remote,true,false,NaN,NaN,false,false,bridge_enforce);
%
nrem = length(remote);
%
flag = false(1,nrem);
%  
for irem = 1:nrem,
    %
    disp(' ')
    disp('-----------------------------------------------------')
    disp(' ')
    info_dke_yp(2,['Testing profile : ',profilestr{irem}]);
    %
    job = matstandardjob_jd('runmat');% standard matlab job
    job.debugmode = debugmode; % to display info and debug
    job.funcopy = 0; % (0) to use function LUKEversion_jd on the remote host within matlab path - TEST REMOTE PATH
    %
    [err,remotelukever,~,remotematrel] = matremote_jd('LUKEversion_jd',{},remote(irem),job);
    %
    disp(' ')
    if isempty(err),        
        info_dke_yp(4,['Version ',remotelukever,' with Matlab ',remotematrel,' working.'])
        flag(irem) = true;
    else
        disperr_jd(err)
    end
    %
end
%
disp(' ')
%