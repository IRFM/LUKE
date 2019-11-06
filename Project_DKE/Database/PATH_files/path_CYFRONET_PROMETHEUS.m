function dkepath = path_CYFRONET_PROMETHEUS
%
% path definitions for Cyfronet Prometheus cluster in Poland
%srun -p plgrid -A poloniumwest -n 1 --pty /bin/bash -l
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
%
dkepath.machine = 'prometheus';
dkepath.hostname = 'prometheus';%here its a pattern since the hostname may fluctuate from time to time when login to the gateway
%
dkepath.computer = computer;%machine type and supported OS
%
dkepath.default = 'plgypeysson';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
path_root = fileparts(which(mfilename));
luke_root = path_root(1:strfind(path_root,'/Project_DKE/Database/PATH_files'));
dkepath.plgypeysson(1).luke_root = luke_root;
%
sep = strfind(luke_root,'/');
dkepath.plgypeysson(1).luke_branch = luke_root(sep(end-1)+1:sep(end)-1);
%
dkepath.plgypeysson(1).temppathroot = '/net/scratch/people/plgypeysson/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%dkepath.plgypeysson(1).local_root = '/net/archive/groups/plggfusion/packages/';%DOES NOT WORK (RIGHT ACCESS ISSUE ?)
dkepath.plgypeysson(1).local_root = '/net/people/plgypeysson/luke/Packages/';%WORKS FINE
%
dkepath.plgypeysson(1).mex904 = [dkepath.plgypeysson(1).luke_root,'Project_DKE/MEX/Bin/cyfronet/MATLAB904/'];%R2018a
dkepath.plgypeysson(1).mex905 = [dkepath.plgypeysson(1).luke_root,'Project_DKE/MEX/Bin/cyfronet/MATLAB905/'];%R2018b
%
%dkepath.plgypeysson(1).compiler_opt.libs.gfortran = [dkepath.plgypeysson(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
%
dkepath.plgypeysson(1).compiler_opt.copts = '';
dkepath.plgypeysson(1).compiler_opt.copts.cpp.mex904 = '';
dkepath.plgypeysson(1).compiler_opt.copts.cpp.mex905 = '';
%
dkepath.plgypeysson(1).compiler_opt.fopts.mex904 = 'FC=''gfortran''';%
dkepath.plgypeysson(1).compiler_opt.separatrice.mex904 = [' -largeArrayDims -lgfortran -L',dkepath.plgypeysson(1).local_root,'lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgypeysson(1).compiler_opt.helmex.mex904 = [' -compatibleArrayDims -lgfortran -L',dkepath.plgypeysson(1).local_root,'lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgypeysson(1).compiler_opt.fopts.mex904 = ' ';%-largeArrayDims';
%
dkepath.plgypeysson(1).compiler_opt.fopts.mex905 = 'FC=''gfortran''';%
dkepath.plgypeysson(1).compiler_opt.separatrice.mex905 = [' -largeArrayDims -lgfortran -L',dkepath.plgypeysson(1).local_root,'lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgypeysson(1).compiler_opt.helmex.mex905 = [' -compatibleArrayDims -lgfortran -L',dkepath.plgypeysson(1).local_root,'lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgypeysson(1).compiler_opt.fopts.mex905 = ' ';%-largeArrayDims';
%
dkepath.plgypeysson(1).MUMPS.mex904 = [dkepath.plgypeysson(1).local_root,'MUMPS_5.1.2/MATLAB904'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.plgypeysson(1).MUMPS.mex905 = [dkepath.plgypeysson(1).local_root,'MUMPS_5.1.2/MATLAB905'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.plgypeysson(1).graphviz.env = '/bin/';% Graphviz environment variable
dkepath.plgypeysson(1).latex.env = '/bin/';% Latex environment variable
dkepath.plgypeysson(1).imagemagick.env = '/bin/';% ImageMagick environment variable
%
% ---------------------------- login other node -------------------------------
%
%dkepath.plgypeysson(1).node = dkepath.plgypeysson(1).cyfronet;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.plgypeysson(1).remote(1).remoteid = 'CYFRONET_PROMETHEUS';
dkepath.plgypeysson(1).remote(1).schedulername = 'slurm';
dkepath.plgypeysson(1).remote(1).profilename = 'local';
dkepath.plgypeysson(1).remote(1).luke_root = dkepath.plgypeysson(1).luke_root;% local cluster
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 2, KRZYSZTOF KROL-----------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.plgzgoryk(1).luke_root = '/net/people/plgzgoryk/luke/LUKE/';
dkepath.plgzgoryk(1).temppathroot = '/net/scratch/people/plgzgoryk/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
%dkepath.plgzgoryk(1).local_root = '/net/archive/groups/plggfusion/packages/';%DOES NOT WORK (RIGHT ACCESS ISSUE ?)
dkepath.plgzgoryk(1).local_root = '/net/people/plgzgoryk/luke/Packages/';%WORKS FINE
%
dkepath.plgzgoryk(1).mex904 = [dkepath.plgzgoryk(1).luke_root,'Project_DKE/MEX/Bin/cyfronet/MATLAB904/'];%R2018a
dkepath.plgzgoryk(1).mex905 = [dkepath.plgzgoryk(1).luke_root,'Project_DKE/MEX/Bin/cyfronet/MATLAB905/'];%R2018b
%
%dkepath.plgzgoryk(1).compiler_opt.libs.gfortran = [dkepath.plgzgoryk(1).luke_root,'Project_DKE/MEX/Libs/gfortran/4.4.3','/',dkepath.machine,'/'];%extra libraries
%
dkepath.plgzgoryk(1).compiler_opt.copts = '';
dkepath.plgzgoryk(1).compiler_opt.copts.cpp.mex904 = '-f /net/people/plgzgoryk/luke/LUKE/Project_DKE/MEX/Bin/cyfronet/MATLAB904/g++_glnxa64.xml';
dkepath.plgzgoryk(1).compiler_opt.copts.cpp.mex905 = '-f /net/people/plgzgoryk/luke/LUKE/Project_DKE/MEX/Bin/cyfronet/MATLAB905/g++_glnxa64.xml';
%
dkepath.plgzgoryk(1).compiler_opt.fopts.mex904 = 'FC=''gfortran''';%
dkepath.plgzgoryk(1).compiler_opt.separatrice.mex904 = [' -largeArrayDims -lgfortran -L',dkepath.plgzgoryk(1).local_root,'lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgzgoryk(1).compiler_opt.helmex.mex904 = [' -compatibleArrayDims -lgfortran -L',dkepath.plgzgoryk(1).local_root,'lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgzgoryk(1).compiler_opt.fopts.mex904 = ' ';%-largeArrayDims';
%
dkepath.plgzgoryk(1).compiler_opt.fopts.mex905 = 'FC=''gfortran''';%
dkepath.plgzgoryk(1).compiler_opt.separatrice.mex905 = [' -largeArrayDims -lgfortran -L',dkepath.plgzgoryk(1).local_root,'lapack-3.8.0 -llapack -lrefblas '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgzgoryk(1).compiler_opt.helmex.mex905 = [' -compatibleArrayDims -lgfortran -L',dkepath.plgzgoryk(1).local_root,'lapack-3.8.0 -llapack -lrefblas  '];% -largeArrayDims does not work for helmex77.F but OK for separatrice.F
dkepath.plgzgoryk(1).compiler_opt.fopts.mex905 = ' ';%-largeArrayDims';
%
dkepath.plgzgoryk(1).MUMPS.mex904 = [dkepath.plgzgoryk(1).local_root,'MUMPS_5.1.2/MATLAB904'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.plgzgoryk(1).MUMPS.mex905 = [dkepath.plgzgoryk(1).local_root,'MUMPS_5.1.2/MATLAB905'];%Where MUMPS matrix solver is stored (MEX function)
%
% LUKE documentation
%
dkepath.plgzgoryk(1).graphviz.env = '/bin/';% Graphviz environment variable
dkepath.plgzgoryk(1).latex.env = '/bin/';% Latex environment variable
dkepath.plgzgoryk(1).imagemagick.env = '/bin/';% ImageMagick environment variable
%
% ---------------------------- login other node -------------------------------
%
%dkepath.plgzgoryk(1).node = dkepath.plgzgoryk(1).cyfronet;
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.plgzgoryk(1).remote(1).remoteid = 'CYFRONET_PROMETHEUS';
dkepath.plgzgoryk(1).remote(1).schedulername = 'slurm';
dkepath.plgzgoryk(1).remote(1).profilename = 'local';
dkepath.plgzgoryk(1).remote(1).luke_root = dkepath.plgzgoryk(1).luke_root;% local cluster
