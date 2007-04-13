function dkepath = path_LUKE_LOCAL
%
% This function sets the LUKE and packages path relative to the local directory
%
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
curr_dir = pwd;
%
ind_LUKE_dir = strfind(curr_dir,'LUKE');
%
if isempty(ind_LUKE_dir),
    error('There is no local root LUKE folder');
end
%
ind_root = min(find(curr_dir(ind_LUKE_dir:end) == '/'));
%
path_root = curr_dir(1:ind_LUKE_dir + ind_root - 1);
%
filename = [path_root,'project_DKE/Database/PATH_files/PATH_LOCAL.mat'];
if exist(filename),
    load(filename);
    return
end
%
dkepath.path_id = path_id;
dkepath.computer = computer;%machine type and supported OS
dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];
dkepath.luke_root = path_root;


