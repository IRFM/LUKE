function [flag] = check_remote_yp(dkepath,remote)
%
%	Check if remote links are available
%
%	Input:
%
%       - dkepath: path structure
%         (default: if no input structure or empty, dkepath is automatically loaded from PATH_LOCAL.mat)
%       - remote: remote computer name [1,p]
%        
%
%	Output:
%
%       - flag: 1 -> remote link available, 0 -> remote link not available [1,nlinks]
%
%   Warning: If the process is blocked (no automatic ssh login for example or remote computer behind a firewall or 
%   remote computer not running, type CTRL-C to escape.
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0,
    dkepath = load_structures_yp('dkepath','','');
    remote = '';
    flag = zeros(length(dkepath.remote));
end
if nargin == 1,
    remote = '';
    flag = zeros(length(dkepath.remote));
end
if nargin == 2,
    flag = 0;
end
%
if nargin < 2,
    disp('------------------------------------------------------');
    disp(['Number of remote computers: ',int2str(length(dkepath.remote))]);
end
%
flag_remote = 0;
%
iremote_min = 1;
iremote_max = length(dkepath.remote);
%
if ~isempty(remote),
    if strcmp(remote,'local'),
        iremote_min = 1;
        iremote_max = 1;
    else
        for iremote = 1:length(dkepath.remote),
            a = dkepath.remote(iremote).host{1};
            if ~isempty(strfind(a,remote)),
                iremote_min = iremote;
                iremote_max = iremote;
                flag_remote = 1;
                break
            end
        end
        %
        if ~flag_remote,%error on the name of the remote computer
            info_dke_yp(7,['The remote computer ''',remote,''' is NOT is the list (see the path script called by make_path_LOCAL.m).'],'','Red');
            return;
        end
    end
end
%  
for iremote = iremote_min:iremote_max,
    if iscell(dkepath.remote(iremote).host),
        HOST = dkepath.remote(iremote).host{1};
    else
        HOST = dkepath.remote(iremote).host;
    end
    %
    if isempty(dkepath.remote(iremote).(getenv('USER')));
        USER = getenv('USER');
    else
        USER = dkepath.remote(iremote).(getenv('USER'));
    end
    %
    disp('------------------------------------------------------');
    display(['Check if remote computer is accessible at to ',USER,'@',HOST,'.'])
    info_dke_yp(0,'(If the process is blocked (waiting more than 10s approx.), type CTRL-C to escape)','','Blue');
    %
    [remote_access,~] = unix(['ssh ',USER,'@',HOST,' ''ls''']);
    %
    if ~remote_access,%test is the remote machine is working with ssh
        [~,HOME] = unix(['ssh ',USER,'@',HOST,' pwd']);
        HOME = HOME(1:end-1);%remove extra term    
        info_dke_yp(2,['The remote computer ',USER,'@',HOST,' is available.'],'','Green');
        flag(iremote) = 1;
    else
        info_dke_yp(6,['The remote computer ',USER,'@',HOST,' is NOT available.'],'','Red');
        info_dke_yp(2,['Check that SSH login without password is well configured with the remote computer ''',HOST,'''.'],'','Red');
        info_dke_yp(2,['Type manually the following command in a Matlab command window for investigating the problem : !ssh ',USER,'@',HOST,' ''ls'''],'','Red');
    end    
end
