function dkepath = path_CEA_TIMDESKTOP
%
% path definitions for TIMOTHEE NICOLAS desktop 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'timdesktop';
dkepath.hostname = 'cadts-0412';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'joan';
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.joan(1).luke_root = [pwd,filesep];
dkepath.joan(1).local_root = '/home/joan/Packages/cadts-0412/';
dkepath.joan(1).temppathroot = '/home/joan/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.joan(1).mex77 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB77'];
dkepath.joan(1).mex710 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB710']; 
dkepath.joan(1).mex712 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB712']; 
dkepath.joan(1).mex800 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB800']; 
%
dkepath.joan(1).compiler_opt.copts = '';
dkepath.joan(1).compiler_opt.fopts.mex77 = 'FC=''ifort''';
dkepath.joan(1).compiler_opt.fopts.mex710 = '';
dkepath.joan(1).compiler_opt.fopts.mex712 = '';
dkepath.joan(1).compiler_opt.fopts.mex800 = '';
dkepath.joan(1).compiler_opt.helmex.mex77 = NaN;% Optional argument for helmex compilation
dkepath.joan(1).compiler_opt.helmex.mex710 = NaN;% Optional argument for helmex compilation
dkepath.joan(1).compiler_opt.helmex.mex712 = ['-L',dkepath.joan(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];% Optional argument for helmex compilation
dkepath.joan(1).compiler_opt.helmex.mex800 = ['-L',dkepath.joan(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.joan(1).local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.joan(1).MUMPS.mex77 = '/home/joan/MUMPS_4.9.2/MATLAB77';%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex710 = [dkepath.joan(1).local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex712 = [dkepath.joan(1).local_root,'MUMPS_4.10.0/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex800 = [dkepath.joan(1).local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.joan(1).graphviz.env = '';% Graphviz environment variable
dkepath.joan(1).latex.env = '';% Latex environment variable
dkepath.joan(1).imagemagick.env = '';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.joan(1).remote(1).remoteid = 'CEA_TIMDESKTOP';
dkepath.joan(1).remote(1).schedulername = 'torque';
dkepath.joan(1).remote(1).profilename = 'joan';
dkepath.joan(1).remote(1).luke_root = dkepath.joan(1).luke_root;% local cluster
%
dkepath.joan(1).remote(2).remoteid = 'CEA_CEPHEE';
dkepath.joan(1).remote(2).schedulername = 'pbs';
dkepath.joan(1).remote(2).profilename = 'joan';
dkepath.joan(1).remote(2).luke_root = '/home/sccp/gsem/decker/LUKE/';
%
dkepath.joan(1).remote(3).remoteid = 'CEA_PLEIONE';% pleione, merope, nashira, newpegase, nunki cluster
dkepath.joan(1).remote(3).schedulername = 'pbs';
dkepath.joan(1).remote(3).profilename = 'joan';
dkepath.joan(1).remote(3).luke_root = dkepath.joan(1).remote(2).luke_root;% same filesystem as cephee
%
dkepath.joan(1).remote(4).remoteid = 'CEA_ANDROMEDE';
dkepath.joan(1).remote(4).schedulername = 'pbs';
dkepath.joan(1).remote(4).profilename = 'JD211098';
dkepath.joan(1).remote(4).luke_root = '/home/JD211098/LUKE/';
%
dkepath.joan(1).remote(5).remoteid = 'macpro_YVES_PEYSSON';
dkepath.joan(1).remote(5).schedulername = 'condor';
dkepath.joan(1).remote(5).profilename = 'joan';
dkepath.joan(1).remote(5).luke_root.LUKE_1_10_0 = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
dkepath.joan(1).remote(5).luke_root.LUKE_default = '/Users/yvespeysson/joandecker/Work/LUKE/';
%
dkepath.joan(1).remote(6).remoteid = 'ASIPP_SHENMA';
dkepath.joan(1).remote(6).schedulername = 'torque';
dkepath.joan(1).remote(6).profilename = 'joan';
dkepath.joan(1).remote(6).luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(5);
dkepath.joan(1).remote(end).schedulername = 'xgrid';
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(5);
dkepath.joan(1).remote(end).schedulername = 'direct';
