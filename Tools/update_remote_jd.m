function dkepath = update_remote_jd(dkepath)
%
% this function updates luke_root to call remote cluster with compatible LUKE version 
%
lukever = LUKEversion_jd;% local LUKE version
%
lukever(lukever == ' ' | lukever == '.') = '_';% syntax for comparison
%
nrem = length(dkepath.remote);
%
flag = true(1,nrem);
%
for irem = 1:nrem
    %
    % if dkepath.remote(irem).luke_root is a string, it is considered as the default value
    %
    if isstruct(dkepath.remote(irem).luke_root), 
        %
        if isfield(dkepath.remote(irem).luke_root,lukever),
            dkepath.remote(irem).luke_root = dkepath.remote(irem).luke_root.(lukever);
        elseif isfield(dkepath.remote(irem).luke_root,'LUKE_default') && ~isempty(dkepath.remote(irem).luke_root.LUKE_default),
            dkepath.remote(irem).luke_root = dkepath.remote(irem).luke_root.LUKE_default;
        else
            flag(irem) = false;
            if isempty(dkepath.remote(irem).host),
                info_dke_yp(6,['no compatible LUKE version found for remote profile #',num2str(irem),' to host : local. profile disabled.'])
            else
                info_dke_yp(6,['no compatible LUKE version found for remote profile #',num2str(irem),' to host : ',dkepath.remote(irem).host,'. profile disabled.'])
            end
        end
    end
end
%
dkepath.remote = dkepath.remote(flag);
%
disp (' ')
info_dke_yp(2,'List of compatible remote profiles available :')
%
for irem = 1:length(dkepath.remote),
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
    if isempty(dkepath.remote(irem).host),
        info_dke_yp(4,['#',num2str(irem),' to host : local with cmd : ',cmdstr])
    else
        info_dke_yp(4,['#',num2str(irem),' to host : ',dkepath.remote(irem).host,' with cmd : ',cmdstr])
    end
end
info_dke_yp(0,'To check if the remote profiles are currently functionning, please run :')
info_dke_yp(4,'check_remote_yp(load_structures_yp(''dkepath'','''',''''));')
disp (' ')
%


        
    
