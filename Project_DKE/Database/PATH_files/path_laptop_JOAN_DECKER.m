function dkepath = path_laptop_JOAN_DECKER
%
% path definitions for laptop of Joan Decker 
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'laptopjoan';
dkepath.hostname = 'CADTS-0096';%WARNING: for laptop, may change with connection status.
dkepath.computer = computer;%machine type and supported OS
%
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.joan(1).luke_root = [pwd,filesep];
dkepath.joan(1).local_root = '/opt/';
dkepath.joan(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% dkepath.joan(1).mex75 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB75'];
% dkepath.joan(1).mex77 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB77'];
% dkepath.joan(1).mex78 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB78'];
% dkepath.joan(1).mex710 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB710']; 
% dkepath.joan(1).mex711 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB711']; 
dkepath.joan(1).mex712 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB712']; 
dkepath.joan(1).mex714 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB714']; 
dkepath.joan(1).mex801 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/laptopjoan/MATLAB801']; 
%
% this version compiles but helmex still seems to use libc.so.6 instead of
% libgcc... to continue
%
%dkepath.joan(1).compiler_opt.helmex = '-largeArrayDims FLIBS=''-L/home/joan/lib/g95 -lf95 -lgcc -Wl,-rpath-link,/opt/R2010A/bin/glnxa64 -L/opt/R2010A/bin/glnxa64 -lmx -lmex -lmat -lm -lblas -llapack''';
%
% this version compiles but only separatrice works
%
%dkepath.joan(1).compiler_opt.helmex = '-lblas -llapack -largeArrayDims';%'-largeArrayDims';% Optional argument for helmex compilation 
%
% for separatrice, the code compiles with the new version of the file and
% no option (32 bits)
%
%FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer''  
%
% in fedora, g95 installed but helmex did not work... try again with kubuntu?
%
dkepath.joan(1).compiler_opt.helmex = ['-L',dkepath.joan(1).local_root,'lapack-3.4.2 -llapack -lrefblas'];%NaN;%'-v -L/home/joan/lib -llapack_g95_32 -lblas_g95_32';%'-v -largeArrayDims -llapack -lblas -lgfortran FC=''gfortran'' FFLAGS=''-fexceptions -fPIC -fbackslash''';%  
dkepath.joan(1).compiler_opt.fopts = '-v ';%'-v FC="gfortran"';%'FFLAGS="-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132"';
dkepath.joan(1).compiler_opt.copts = '';
%
% dkepath.joan(1).MUMPS.mex75 = [dkepath.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB75'];%Where MUMPS matrix solver is stored (MEX function)
% dkepath.joan(1).MUMPS.mex77 = [dkepath.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
% dkepath.joan(1).MUMPS.mex78 = [dkepath.joan(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.7.3_S_ifort/MATLAB78'];%Where MUMPS matrix solver is stored (MEX function)
% dkepath.joan(1).MUMPS.mex710 = [dkepath.joan(1).local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
% dkepath.joan(1).MUMPS.mex711 = [dkepath.joan(1).local_root,'MUMPS_4.9.2/MATLAB711'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex712 = [dkepath.joan(1).local_root,'MUMPS_4.9.2/MATLAB712'];%Where MUMPS matrix solver is stored (MEX function)
% dkepath.joan(1).MUMPS.mex801 = [dkepath.joan(1).local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex801 = [dkepath.joan(1).local_root,'MUMPS_4.10.0_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.joan(1).remote(1).remoteid = 'laptop_JOAN_DECKER';
dkepath.joan(1).remote(1).schedulername = 'direct';
dkepath.joan(1).remote(1).profilename = 'joan';
dkepath.joan(1).remote(1).luke_root = dkepath.joan(1).luke_root;% local cluster
%
dkepath.joan(1).remote(2).remoteid = 'CEA_ANDROMEDE';
dkepath.joan(1).remote(2).schedulername = 'pbs';
dkepath.joan(1).remote(2).profilename = 'JD211098';
dkepath.joan(1).remote(2).luke_root = '/home/JD211098/LUKE/';
%
dkepath.joan(1).remote(3).remoteid = 'macpro_YVES_PEYSSON';
dkepath.joan(1).remote(3).schedulername = 'condor';
dkepath.joan(1).remote(3).profilename = 'joan';
dkepath.joan(1).remote(3).luke_root.LUKE_1_10_0 = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
dkepath.joan(1).remote(3).luke_root.LUKE_default = '/Users/yvespeysson/joandecker/Work/LUKE/';
%
dkepath.joan(1).remote(4).remoteid = 'ASIPP_SHENMA';
dkepath.joan(1).remote(4).schedulername = 'torque';
dkepath.joan(1).remote(4).profilename = 'joan';
dkepath.joan(1).remote(4).luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
dkepath.joan(1).remote(5).remoteid = 'CEA_CEPHEE';
dkepath.joan(1).remote(5).schedulername = 'pbs';
dkepath.joan(1).remote(5).profilename = 'joan';
dkepath.joan(1).remote(5).luke_root.LUKE_1_8_6 = '/home/sccp/gsem/decker/LUKE_1_8/';
dkepath.joan(1).remote(5).luke_root.LUKE_1_9_1 = '/home/sccp/gsem/decker/LUKE_1_9/';
dkepath.joan(1).remote(5).luke_root.LUKE_1_10_0 = '/home/sccp/gsem/decker/LUKE_1_10/';
dkepath.joan(1).remote(5).luke_root.LUKE_default = '/home/sccp/gsem/decker/LUKE/';% default remote LUKE version. Leave empty to enforce error if no match
%
dkepath.joan(1).remote(6).remoteid = 'CEA_TIMDESKTOP';
dkepath.joan(1).remote(6).schedulername = 'torque';
dkepath.joan(1).remote(6).profilename = 'joan';
%dkepath.joan(1).remote(6).luke_root = dkepath.joan(1).remote(5).luke_root;% same FS as cephee %%%%% mount not working
dkepath.joan(1).remote(6).luke_root = '/home/joan/LUKE/';% same FS as cephee
%
dkepath.joan(1).remote(7).remoteid = 'CEA_PLEIONE';% pleione, merope, nashira, newpegase, nunki cluster
dkepath.joan(1).remote(7).schedulername = 'pbs';
dkepath.joan(1).remote(7).profilename = 'joan';
dkepath.joan(1).remote(7).luke_root = dkepath.joan(1).remote(5).luke_root;% same FS as cephee
%
dkepath.joan(1).remote(8).remoteid = 'EFDA_ITM';
dkepath.joan(1).remote(8).schedulername = 'sge';
dkepath.joan(1).remote(8).profilename = 'yvesp';
dkepath.joan(1).remote(8).luke_root = '/pfs/home/yvesp/public/LUKE_ITM/trunk/LUKE/';
% %
% dkepath.joan(1).remote(end+1).remoteid = 'CEA_SATURNE';
% dkepath.joan(1).remote(end).schedulername = 'sun';
% dkepath.joan(1).remote(end).profilename = 'joan';
% dkepath.joan(1).remote(end).luke_root = dkepath.joan(1).remote(2).luke_root;% same FS as andromede
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(2);
dkepath.joan(1).remote(end).schedulername = 'direct';
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(3);
dkepath.joan(1).remote(end).schedulername = 'xgrid';
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(3);
dkepath.joan(1).remote(end).schedulername = 'direct';
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(5);
dkepath.joan(1).remote(end).schedulername = 'direct';
%
dkepath.joan(1).remote(end+1) = dkepath.joan(1).remote(8);
dkepath.joan(1).remote(end).schedulername = 'direct';
%
