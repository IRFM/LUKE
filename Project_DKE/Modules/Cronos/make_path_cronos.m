function [dkepath] = make_path_cronos(config)
%
% Create the structure dkepath for CRONOS
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
if strcmp(config,'PC_DRFC_CRONOS');
   path_id = 'PC_DRFC_CRONOS';%Set here the name path parameters (user specific)
%
   dkepath.path_id = path_id;
   dkepath.computer = 'GLNXA64';%machine type and supported OS
   dkepath.MUMPS = '/home/sccp/gsem/peysson/Packages/MUMPS_4.6.1/dke';%Where MUMPS matrix solver is stored
   dkepath.PETSC = '/home/sccp/gsem/peysson/Packages/petsc-2.3.2-p0';%Where PETSC matrix solver is stored
   dkepath.temppathroot = '/scratch';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
   dkepath.mex = '/home/sccp/gsem/peysson/Project_DKE/MEX';
else
   error('The path configuration name does not exists');
end