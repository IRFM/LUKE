function dkepath = path_LUKE_LOCAL
%
% This function sets the LUKE and packages path relative to the local directory
%
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
curr_dir = pwd;
%
ind_LUKE_dir = strfind(curr_dir,'LUKE_');
%
if isempty(ind_LUKE_dir),
    error('There is no local root LUKE folder');
end
%
ind_root = min(find(curr_dir(ind_LUKE_dir:end) == '/'));
%
path_root = curr_dir(1:ind_LUKE_dir + ind_root - 1);
%
dkepath.path_id = path_id;
dkepath.computer = computer;%machine type and supported OS
dkepath.MUMPS = [path_root,'Packages/MUMPS_4.6.1/dke'];%Where MUMPS matrix solver is stored
dkepath.PETSC = [path_root,'Packages/petsc-2.3.2-p8'];%Where PETSC matrix solver is stored
dkepath.PETSc_DIR = [path_root,'Packages/petsc-2.3.2-p8'];
dkepath.temppathroot = '/scratch';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
dkepath.mex = [path_root,'Project_DKE/MEX'];
dkepath.variables.input = [path_root,'Packages/petsc-2.3.2-p8/DKE/DKESolver_variables'];%directory where all inout variables are written
dkepath.variables.output = [path_root,'Packages/petsc-2.3.2-p8/DKE/DKESolver_output'];%location directory where the distribution function is written by C program before going back to matlab
dkepath.luke_root = path_root;


