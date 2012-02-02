function [flag,remote] = check_remote_yp(dkepath,clustername)
%
%	Check if remote links are available and if yes, extract the structure of the active
%	cluster for remote calculations. If zero or one input arguments, scan the
%	available clusters (or computers) for remote calculations from the
%	dkepath structure.
%
%	Input:
%
%       - dkepath: path structure
%         (default: if no input structure or empty, dkepath is automatically loaded from PATH_LOCAL.mat)
%       - clustername: remote cluster (or computer) name [1,p]
%        
%
%	Output:
%
%       - flag: 1 -> remote link available, 0 -> remote link not available [1,nlinks]
%       - remote: structure of the active cluster for remote calculations
%
%   Warning: If the process is blocked (no automatic ssh login for example or remote computer behind a firewall or 
%   remote cluster (or computer) not running, type CTRL-C to escape.
%
%by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
%remote = dkepath.remote(clusternum);
%
if nargin == 0,
    dkepath = load_structures_yp('dkepath','','');
end
%
if nargin < 2,
    disp('------------------------------------------------------');
    disp(['Number of remote computers: ',int2str(length(dkepath.remote))]);
    clustername = '';
end
%
flag = 0;
flag_remote = 0;
%
iremote_min = 1;
iremote_max = length(dkepath.remote);
%
if ~isempty(clustername),
    if strcmp(clustername,'local'),
        iremote_min = 1;
        iremote_max = 1;
        remote = dkepath.remote(1);%first substructure is always correpsonding to the local cluster (or computer)
    else
        if isfield(dkepath.remote,'cluster'), 
            for iremote = 1:length(dkepath.remote),
                clustername0 = dkepath.remote(iremote).cluster;
                if ~isempty(clustername0)
                    if ~isempty(strfind(clustername0,clustername)),
                        iremote_min = iremote;
                        iremote_max = iremote;
                        flag_remote = 1;
                        remote = dkepath.remote(iremote);
                        break
                    end
                else
                    clustername0 = dkepath.remote(iremote).host{1};%look if the cluster name is in the hostname
                    if ~isempty(strfind(clustername0,clustername)),
                        iremote_min = iremote;
                        iremote_max = iremote;
                        flag_remote = 1;
                        remote = dkepath.remote(iremote);
                        break
                    end                     
                end
            end
        else
            for iremote = 1:length(dkepath.remote),
                clustername0 = dkepath.remote(iremote).host{1};%look if the cluster name is in the hostname
                if ~isempty(strfind(clustername0,clustername)),
                    iremote_min = iremote;
                    iremote_max = iremote;
                    flag_remote = 1;
                    remote = dkepath.remote(iremote);
                    break
                end
            end
        end
        %
        if ~flag_remote,%error on the name of the remote computer
            info_dke_yp(7,['The remote computer ''',clustername,''' is NOT is the list (see the path script called by make_path_LOCAL.m).'],'','Red');
            remote = [];
            %
            disp('------------------------------------------------------');
            disp('Available remote computers: ');
            %
            for iremote = 1:length(dkepath.remote),
                if isfield(dkepath.remote(iremote),'cluster')
                    if iremote == 1,
                        info_dke_yp(2,[dkepath.remote(iremote).cluster,' or local'],0,'Blue');
                    else
                        info_dke_yp(2,dkepath.remote(iremote).cluster,0,'Blue');
                    end
                else
                    if iremote == 1,
                        info_dke_yp(2,[dkepath.remote(iremote).host{1},' or local'],0,'Blue');
                    else
                        info_dke_yp(2,dkepath.remote(iremote).host{1},0,'Blue');
                    end
                end
            end
            %
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
