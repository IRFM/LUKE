function [dkepath] = path_CRPP_PC82(luke_ref)
%
% path definitions for CRPP (EPFL, Suisse) PC82 computer
%
%	Input:
%
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
if nargin == 0, 
    luke_ref = 'LUKE';
end
%
dkepath.hostname = 'crpppc82';
dkepath.machine = 'crpppc82';
dkepath.computer = computer;%machine type and supported OS
%
% Selected default user profile
%
dkepath.path_profile.joan = 1;
%
% Selected user profile for unlisted users
%
dkepath.default = 'joan';
%
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.joan(1).luke_root = ['/home/decker/',luke_ref,'/'];
dkepath.joan(1).local_root = '/home/decker/Packages/';
dkepath.joan(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.joan(1).mex800 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/mat800/'];
dkepath.joan(1).mex801 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/mat801/'];
%
dkepath.joan(1).compiler_opt.helmex.mex800 = 'FLIBS=''-Wl,-rpath-link,/usr/local/MATLAB/R2012b/bin/glnxa64 -L/usr/local/MATLAB/R2012b/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/Packages/lapack-3.4.2 -llapack -lrefblas_gf''';
dkepath.joan(1).compiler_opt.helmex.mex801 = 'FLIBS=''-Wl,-rpath-link,/usr/local/MATLAB/R2013a/bin/glnxa64 -L/usr/local/MATLAB/R2013a/bin/glnxa64 -lmx -lmex -lmat -lm -L/home/decker/Packages/lapack-3.4.2 -llapack -lrefblas_gf''';
%
dkepath.joan(1).compiler_opt.fopts = '';
%
dkepath.joan(1).MUMPS.mex800 = [dkepath.joan(1).local_root,'MUMPS_4.10.0_gf/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex801 = [dkepath.joan(1).local_root,'MUMPS_4.10.0_gf/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
