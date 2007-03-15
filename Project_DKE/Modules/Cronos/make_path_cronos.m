function [dkepath] = make_path_cronos(config)
%
% Create the structure dkepath for CRONOS
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
if strcmp(config,'PC_DRFC_CRONOS');
   path_id = 'PC_DRFC_CRONOS';%Set here the name path parameters (user specific)
%
   path_root = '/cgc_data/zineb/data/LUKE/';
%
   dkepath.path_id = path_id;
   dkepath.computer = 'GLNXA64';%machine type and supported OS
   dkepath.MUMPS = [path_root,'Packages/MUMPS_4.6.1/dke'];%Where MUMPS matrix solver is stored
   dkepath.PETSC = [path_root,'Packages/petsc-2.3.2-p8'];%Where PETSC matrix solver is stored
   dkepath.PETSc_DIR = [path_root,'Packages/petsc-2.3.2-p8'];
   dkepath.temppathroot = '/scratch';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
   dkepath.mex = [path_root,'Project_DKE/MEX'];
   dkepath.variables.input = [path_root,'Packages/petsc-2.3.2-p8/DKE/DKESolver_variables'];%directory where all inout variables are written
   dkepath.variables.output = [path_root,'Packages/petsc-2.3.2-p8/DKE/DKESolver_output'];%location directory where the distribution function is written by C program before going back to matlab
   dkepath.pathfile = 'setpath_luke_jd';
else
   error('The path configuration name does not exists');
end