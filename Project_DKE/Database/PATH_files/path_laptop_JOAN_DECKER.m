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
dkepath.hostname = 'CADTS-0096';%WARNING: for laptop, may change with connection status.
dkepath.machine = 'laptopjoan';
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
% local (direct)
%
dkepath.joan(1).remote(1) = remote_laptop_JOAN_DECKER('direct','joan');
dkepath.joan(1).remote(1).host = '';
dkepath.joan(1).remote(1).env.luke_root = dkepath.joan(1).luke_root;
%
% andromede (pbs)
%
dkepath.joan(1).remote(1) = remote_CEA_ANDROMEDE('pbs','joan');
dkepath.joan(1).remote(1).env.luke_root = '/home/JD211098/LUKE/';
%
% macproyves (condor)
%
dkepath.joan(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan');
dkepath.joan(1).remote(2).env.luke_root = '/Users/yvespeysson/joandecker/Work/LUKE_1_10/';
%
% macproyves (xgrid)
%
dkepath.joan(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan');
dkepath.joan(1).remote(3).env.luke_root = dkepath.joan(1).remote(2).env.luke_root;
%
% shenma (torque)
%
dkepath.joan(1).remote(4) = remote_ASIPP_SHENMA('torque','joan');
dkepath.joan(1).remote(4).env.luke_root = '/home/PEYSSON/JoanDecker/LUKE/';
%
% cephee (pbs)
%
dkepath.joan(1).remote(5) = remote_CEA_CEPHEE('pbs','joan');
dkepath.joan(1).remote(5).env.luke_root.LUKE_1_8_6 = '/home/sccp/gsem/decker/LUKE_1_8/';
dkepath.joan(1).remote(5).env.luke_root.LUKE_1_9_1 = '/home/sccp/gsem/decker/LUKE_1_9/';
dkepath.joan(1).remote(5).env.luke_root.LUKE_1_10_0 = '/home/sccp/gsem/decker/LUKE_1_10/';
dkepath.joan(1).remote(5).env.luke_root.LUKE_default = dkepath.joan(1).remote(5).env.luke_root.LUKE_1_10_0;% default remote LUKE version. Leave empty to enforce error if no match
%
% cadts-0412 (torque, Timothee's computer)
%
dkepath.joan(1).remote(6) = remote_CEA_TIMDESKTOP('torque','joan');
dkepath.joan(1).remote(6).env.luke_root = dkepath.joan(1).remote(5).env.luke_root;% same FS as cephee
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster).
%
dkepath.joan(1).remote(7) = remote_CEA_PLEIONE('pbs','joan');
dkepath.joan(1).remote(7).env.luke_root = dkepath.joan(1).remote(5).env.luke_root;% same FS as cephee
%
% saturne (sun)
%
dkepath.joan(1).remote(8) = remote_CEA_SATURNE('sun','joan');
dkepath.joan(1).remote(8).env.luke_root = dkepath.joan(1).remote(1).env.luke_root;% same FS as andromede
% 
