function [sunipp] = path_IPP_SUN(luke_ref)
%
% path definitions for IPP (Pragues, Czech Republic) SUN workstation
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
if nargin == 0, luke_ref = 'LUKE';end
%
[~,matlabversion,matlabrelease] = LUKEversion_jd;
%
[~,hostname] = unix('hostname');hostname = hostname(1:end-1);%remove extra term
%
sunipp.hostname = 'Sun1.ipp.cas.cz';
sunipp.machine = 'sunipp';
sunipp.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
sunipp.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
sunipp.vader(1).luke_root = [pwd,'/'];
sunipp.vader(1).local_root = '/home/luke/';
sunipp.vader(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
sunipp.vader(1).mex704 = [sunipp.vader(1).luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB74'];
sunipp.vader(1).mex705 = [sunipp.vader(1).luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB75'];
sunipp.vader(1).mex706 = [sunipp.vader(1).luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB76'];
sunipp.vader(1).mex707 = [sunipp.vader(1).luke_root,'Project_DKE/MEX/Bin/sunipp/MATLAB77'];
sunipp.vader(1).compiler_opt.copts = 'CC="gcc4"';
%sunipp.vader(1).compiler_opt.fopts = 'FC="gfortran" FFLAGS="-v -largeArrayDims -fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
sunipp.vader(1).compiler_opt.fopts = 'FC="/opt/g95/0.91_x86_64_32DI/bin/g95" FFLAGS="-v -largeArrayDims -fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
sunipp.vader(1).compiler_opt.helmex = 'FLIBS=''-Wl,-rpath-link,/opt/matlab/r2008b/bin/glnxa64 -L/opt/matlab/r2008b/bin/glnxa64 -lmx -lmex -lmat -lm  -llapack -lblas -lguide -lpthread''';
%
sunipp.vader(1).MUMPS.mex705 = [sunipp.vader(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
sunipp.vader(1).MUMPS.mex706 = [sunipp.vader(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB76'];%Where MUMPS matrix solver is stored (MEX function)
sunipp.vader(1).MUMPS.mex707 = [sunipp.vader(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_gfort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)


