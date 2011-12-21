function [] = check_remote_yp(dkepath)
%
%	Check if remote links are available
%
%	Input:
%
%       - dkepath: path structure
%       (default: if no input structure or empty, dkepath is automatically loaded from PATH_LOCAL.mat)
%
%	Output: none
%
%   Warning: If the process is blocked (no automatic ssh login for example or remote computer behind a firewall or 
%   remote computer not running, type CTRL-C to escape.
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0,
    dkepath = load_structures_yp('dkepath','','');
end
%
disp('------------------------------------------------------');
disp(['Number of remote computers: ',int2str(length(dkepath.remote))]);
%
for iremote = 1:length(dkepath.remote),
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
    display('(If the process is blocked (more than 10s approx.), type CTRL-C to escape)');
    [remote_access,~] = unix(['ssh ',USER,'@',HOST,' ''ls''']);
    if ~remote_access,%test is the remote machine is working with ssh
        [~,HOME] = unix(['ssh ',USER,'@',HOST,' pwd']);
        HOME = HOME(1:end-1);%remove extra term    
        info_dke_yp(2,['The remote computer ',USER,'@',HOST,' is available.'],'','Green');
    else
        info_dke_yp(6,['The remote computer ',USER,'@',HOST,' is NOT available.'],'','Red');
    end    
end
