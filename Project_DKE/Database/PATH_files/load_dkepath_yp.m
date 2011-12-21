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
    if strcmp(dkepath_temp.hostname,hostname) && strcmp(getenv('USER'),dkepath_temp.user),
        dkepath.hostname.(dkepath_temp.machine) = dkepath_temp.hostname;
        dkepath.(dkepath_temp.machine) = dkepath_temp.(dkepath_temp.user);
        dkepath = rmfield(dkepath,'default');%useless since a specific one is found.
        flagconfig = 1;
        break
    end
end
%
if flagconfig == 0,
    disp(['WARNING: no specific configuration found for user ''',dkepath_temp.user,''' on machine ''',dkepath_temp.machine,'''']);
else
    disp(['Configuration for user ''',dkepath_temp.user,''' on machine ''',dkepath_temp.machine,''' well loaded.']);
end
%




