function [dkepath] = load_dkepath_yp(dkepath,luke_ref)
%
%	Load path definitions that match the machine on which LUKE is running
%
%	Input:
%
%       - dkepath: initial path structure
%       - luke_ref: for CVS tagged LUKE version [1,1]
%         (default: 'LUKE')
%
%	Output:
%
%       - dkepath: final path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if ~isempty(dkepath) && ~isempty(luke_ref),
    list_path = dir('Project_DKE/Database/PATH_files/path_*.m');% list of path configurations
else
    [dkepath] = load_structures_yp('dkepath','','');
    list_path = dir([dkepath.luke_root,'Project_DKE/Database/PATH_files/path_*.m']);% list of path configurations
    dkepath = '';
    luke_ref = '';
end
%
for ipath = 1:length(list_path),
    %
    funcname = list_path(ipath).name(1:end-2);
    pathfunc = str2func(funcname);
    %
    try
        dkepath_new = dkepath;
        dkepath_temp = pathfunc(luke_ref);% try loading specific path profile for 
        %
        dkepath_new.hostname.(dkepath_temp.machine) = dkepath_temp.hostname;
        dkepath_new.(dkepath_temp.machine) = dkepath_temp;
        %
        disp(['Path from profile ',funcname,'.m successfully loaded'])
        %
        dkepath = dkepath_new;
        %
    catch err
        disp(['Warning : path from profile ',funcname,'.m could not be loaded because of the following error :',err.message]);
    end
    %
end
%



