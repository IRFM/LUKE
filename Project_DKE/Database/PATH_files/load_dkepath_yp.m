function [dkepath] = load_dkepath_yp(dkepath,luke_ref)
%
%	Load path definitions that match the machine on which LUKE is running
%
%	Input:
%
%       - dkepath: path structure
%       - luke_ref: for CVS tagged LUKE version [1,m]
%         (default: 'LUKE')
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
list_path = dir('Project_DKE/Database/PATH_files/path_*.m');
flagconfig = 0;
%
[~,hostname] = unix('hostname');hostname = hostname(1:end-1);%remove extra term
%
for ipath = 1:length(list_path),
    eval(['dkepath_temp = ',list_path(ipath).name(1:end-2),'(''',luke_ref,''');']);
    fnames = fieldnames(dkepath_temp);
    for ifnames = 1:length(fnames),
        if strfind(dkepath_temp.hostname,hostname) & strcmp(getenv('USER'),fnames(ifnames)) & ~flagconfig,
            dkepath.hostname.(dkepath_temp.machine) = dkepath_temp.hostname;
            if length(dkepath_temp.([fnames{ifnames}])) > 1,%if several path for the same user
                dkepath.(dkepath_temp.machine) = dkepath_temp.([fnames{ifnames}])(dkepath_temp.path_profile);
            else
                dkepath.(dkepath_temp.machine) = dkepath_temp.([fnames{ifnames}]);
            end
            dkepath.(dkepath_temp.machine).computer = dkepath_temp.computer;
            %
            dkepath = rmfield(dkepath,'default');%useless since a specific one is found.
            %
            flagconfig = 1;
        end
    end
end
%
if flagconfig == 0,
    disp('------------------------------------------------------');
    info_dke_yp(1,['WARNING: no specific path configuration found for user ''',getenv('USER'),''' on host ''',hostname,''''],'','Red');
else
    disp('------------------------------------------------------');
    info_dke_yp(2,['Path configuration for user ''',getenv('USER'),''' on host ''',hostname,''' well loaded.'],'','Green');
end
%




