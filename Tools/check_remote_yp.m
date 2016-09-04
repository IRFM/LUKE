function flag = check_remote_yp(dkepath,remlist,debugmode,link_mode,log_mode)
% LUKE - Check if remote links are available and functionning
%
%	Check if remote links are available and functionning
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%       - remlist : list of profiles indices to be tested
%           o NaN : (default) test all profiles
%           o []  : user-prompt profile list
%           o [1,3...] : tests specified profiles
%       - debugmode: display details   
%       - link_mode : connection mode prescription
%           o -1  : local profiles only
%           o NaN : (default) use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced
%           o 1   : ssh bridge enforced
%           o 2   : url/ftp bridge enforced
%       - log_mode : output results in a log file
%           o 0 : no 
%           o 1 : yes (default)
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
if nargin < 5,
    log_mode = 1;
end
if nargin < 4,
    link_mode = NaN;
end
if nargin < 3,
    debugmode = 0;
end
if nargin < 2,
    remlist = NaN;
end
if nargin < 1,
    dkepath = '';
end
%
if ~isempty(link_mode) && ~isnan(link_mode),
    link_modestr = ['_link_mode_',num2str(link_mode)];
else
    link_modestr = '';
end
%
filename = '';
%
if log_mode,
    %
    filename = ['res_check_remote_yp_',datestr(now,29),link_modestr,'.log'];
    %
    if input_dke_yp(['Do you want to save the results in the log file ',filename,' ? (y/n)'],'n',{'y','n'}) == 'y',
        %
        if exist(filename,'file'),
            delete(filename);
        end
        %
        diary(filename);
        %
    end
    %
end
%
if ~isempty(remlist) && ~isnan(sum(remlist)) && ~isempty(dkepath),%for the remlist only
    %
    dkepath.remote = dkepath.remote(remlist);
    dkepath.profilestr = dkepath.profilestr(remlist);
    dkepath.remprofiles = dkepath.remprofiles([1,remlist+1]);
    dkepath.distprofiles = dkepath.distprofiles([1:3,remlist+3]);
    %
    remlist = 1:length(remlist);
    %
    dkepath = setpath_luke_jd(dkepath,link_mode);
    %
else
    dkepath = setpath_luke_jd(dkepath,link_mode,0);
end
%
% test connection and identify local profiles
%
disp(' ')
info_dke_yp(2,'Testing remote connection for dkepath.remote profiles using LUKE code.');
%
nrem = length(dkepath.remote);
%
flag = zeros(1,nrem);
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
    job.remtimout = 5;% in minutes
    %
    job.funcopy = 0; % (0) to use function LUKEversion_jd on the remote host within matlab path - TEST REMOTE PATH
    %
    flag_remote_path = 0;
    disp(' - LUKEversion_jd.m on the remote machine is used');
    [err,~,remotelukever,~,remotematrel] = matremote_jd('LUKEversion_jd',{},dkepath.remote(irem),job);
    %
    if ~isempty(err),
        disp('----------------------------')
        disperr_jd(err);
        disp('----------------------------')
        %
        disp(' - LUKEversion_jd.m send from the local machine to the remote one is used.');
        job.funcopy = 1; % (0) to use function LUKEversion_jd on the remote host within matlab path - TEST REMOTE PATH
        [err,~,remotelukever,~,remotematrel] = matremote_jd('LUKEversion_jd',{},dkepath.remote(irem),job);
        flag_remote_path = 1;
    end
    %
    disp(' ')
    if isempty(err),        
        info_dke_yp(4,['Version ',remotelukever,' with Matlab ',remotematrel,' working.'])
        flag(irem) = 1;
        if flag_remote_path, flag(irem) = -1; end 
    else
        disperr_jd(err);
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