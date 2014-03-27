function dkepath = update_remote_jd(dkepath,link_mode)
%
% this function load remote profiles and selects accessible remote clusters with compatible LUKE version 
%
%   - link_mode : connection mode prescription
%       o -1  : disable remote profiles
%       o NaN : (default) use value from remote.link_mode
%       o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%       o 0   : ssh key pair enforced
%       o 1   : ssh bridge enforced
%       o 2   : url/ftp bridge enforced
%
lukever = LUKEversion_jd;% local LUKE version
lukever(lukever == ' ' | lukever == '.') = '_';% syntax for comparison
%
% Local hostname
%
lochostname = hostname_jd;
%
% load remote profiles if needed
%
nrem = 0;
%
for irem = 1:length(dkepath.remote),
    if isfield(dkepath.remote(irem),'remoteid'),% process remote profile with schedulername, profilename & luke_root
        remotestr = ['remote_',dkepath.remote(irem).remoteid];
        if exist([remotestr,'.m'],'file'),
            %
            nrem = nrem+1;
            remote(nrem) = feval(remotestr,dkepath.remote(irem).schedulername,dkepath.remote(irem).profilename); 
            remote(nrem).env.luke_root = dkepath.remote(irem).luke_root;
            if isfield(dkepath.remote(nrem),'link_mode'),
                remote(nrem).link_mode = dkepath.remote(irem).link_mode;
            end
            if isfield(dkepath.remote(nrem),'cvsupdate'),
                remote(nrem).cvsupdate = dkepath.remote(irem).cvsupdate;
            end
            %
        else
            continue
        end
    else
        %
        nrem = irem;
        remote(nrem) = dkepath.remote(nrem);
        %
    end
    %
    if any(strfind(lochostname,remote(nrem).hostname)),
        remote(nrem).host = '';
    end
end
%
if nrem == 0,
    remote = [];
end
%
% test compatibility of local and remote LUKE versions
%
flag = true(1,nrem);
%
for irem = 1:nrem
    %
    % if remote(irem).luke_root is a string, it is considered as the default value
    %
    if isfield(remote(irem).env,'luke_root'),
        %
        if isstruct(remote(irem).env.luke_root), 
            %
            if isfield(remote(irem).env.luke_root,lukever),
                remote(irem).env.luke_root = remote(irem).env.luke_root.(lukever);
            elseif isfield(remote(irem).env.luke_root,'LUKE_default') && ~isempty(remote(irem).env.luke_root.LUKE_default),
                remote(irem).env.luke_root = remote(irem).env.luke_root.LUKE_default;
            else
                flag(irem) = false;
                info_dke_yp(6,['no compatible LUKE version found for remote profile #',num2str(irem),' to host : ',remote(irem).host,'. Profile disabled.'])
            end
        end
    else
        flag(irem) = false;% no remote luke root specified
    end
end
%
% test connection and identify local profiles
%
if isempty(link_mode) || isnan(link_mode) || link_mode >= 0,% remote profiles enabled : test connections and display output following link_mode
    %
    disp (' ')
    info_dke_yp(3,'Testing remote profile connections ')
    %
    [dkepath.remote,dkepath.profilestr] = load_remoteprofiles_jd(remote(flag),true,false,NaN,NaN,false,false,link_mode);
    %
    nrem = length(dkepath.remote);
    %
    disp (' ')
    info_dke_yp(2,'List of compatible remote profiles available :')
    disp(' ')
    %
    for irem = 1:nrem,
        info_dke_yp(4,['#',num2str(irem),' : ',dkepath.profilestr{irem}]);
    end
    disp(' ')
    %
else% remote profiles disabled
    %
    dkepath.remote = [];
    dkepath.profilestr = {};
    nrem = 0;
    %
end
%
dkepath.remprofiles = cell(1,1 + nrem);
dkepath.distprofiles = cell(1,3 + nrem);
%
dkepath.remprofiles{1} = 'Local interactive calculation';
%
dkepath.distprofiles{1} = 'Sequential';
dkepath.distprofiles{2} = 'MDCE Job scheduler';
dkepath.distprofiles{3} = 'MDCE parfor';
%
for irem = 1:nrem,
    dkepath.remprofiles{irem+1} = dkepath.profilestr{irem};
    dkepath.distprofiles{irem+3} = ['batch jobs on ',dkepath.profilestr{irem}];
end
%

        
    
