function flag = check_remote_yp(dkepath,debugmode,bridge_enforce,remlist)
%
%	Check if remote links are available and functionning
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%       - debugmode: display details   
%       - bridge_enforce : [NaN, empty, 0 or 1] if 1, provides step by step information, and save diary file in remote job folder 
%           o NaN : (default) use value from remote.bridge_enforce
%           o []  : tests both modes and give priority to ssh key pair
%           o 0   : tests only ssh key pair,
%           o 1   : tests only bridge mode
%       - remlist : list of profiles indices to be tested
%           o NaN : (default) test all profiles
%           o []  : user-prompt profile list
%           o [1,3...] : tests specified profiles
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
if nargin < 1,
    dkepath = '';
end
%
if ~isempty(bridge_enforce) && ~isnan(bridge_enforce),
    bridgestr = ['_bridge_',num2str(bridge_enforce)];
else
    bridgestr = '';
end
%
filename = ['res_check_remote_yp_',datestr(now,29),bridgestr,'.log'];
%
if input_dke_yp(['Do you want to save the results in the log file ',filename,' ? (y/n)'],'y',{'y','n'}) == 'y',
    %
    if exist(filename,'file'),
        delete(filename);
    end
    %
    diary(filename);
    %
else
    filename = '';
end
%
dkepath = setpath_luke_jd(dkepath,bridge_enforce);
%
% test connection and identify local profiles
%
disp(' ')
info_dke_yp(2,'Testing remote connection for dkepath.remote profiles');
%
nrem = length(dkepath.remote);
%
flag = false(1,nrem);
%  
if nargin < 4 || isempty(remlist),
    remlist = input_dke_yp('Please identify profiles to be tested.',1:nrem,[1;nrem]);
elseif isnan(remlist),
    remlist = 1:nrem;
end
%
for irem = remlist,
    %
    disp(' ')
    disp('-----------------------------------------------------')
    disp(' ')
    info_dke_yp(2,['Testing profile : ',dkepath.profilestr{irem}]);
    %
    job = matstandardjob_jd('runmat');% standard matlab job
    job.debugmode = debugmode; % to display info and debug
    job.funcopy = 0; % (0) to use function LUKEversion_jd on the remote host within matlab path - TEST REMOTE PATH
    %
    [err,remotelukever,~,remotematrel] = matremote_jd('LUKEversion_jd',{},dkepath.remote(irem),job);
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
if ~isempty(filename),
    diary('off');
end
%