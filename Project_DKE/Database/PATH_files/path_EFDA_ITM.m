function [efdaitm] = path_EFDA_ITM(luke_ref)
%
% path definitions for EFDA ITM cluster
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
[dummy,matlabversion,matlabrelease] = LUKEversion_jd;
%
efdaitm.hostname = 'enea144.efda-itm.eu';
efdaitm.machine = 'efdaitm';
efdaitm.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
efdaitm.path_profile = 1;
%
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%
efdaitm.peysson(1).luke_root = [getenv('HOME'),'/LUKE/'];
efdaitm.peysson(1).local_root = ['/afs/efda-itm.eu/project/switm/'];
efdaitm.peysson(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
efdaitm.peysson(1).speclibpath.xml_io_tools = [efdaitm.peysson(1).luke_root,'Project_DKE/Modules/ITM/xml_io_tools/'];%Other machine specific libraries (XML I/O)
%efdaitm.peysson(1).speclibpath.ual = [efdaitm.peysson(1).local_root,'ual/matlabinterface'];%Other machine specific libraries (UAL)
efdaitm.peysson(1).speclibpath.ual = ['/afs/efda-itm.eu/isip/user/buravand/public/matlab/v4.06d'];%Other machine specific libraries (UAL)
%TODO: Adresse temporairede Yves Buravand
%
efdaitm.peysson(1).mex706 = [efdaitm.peysson(1).luke_root,'Project_DKE/MEX/Bin/efdaitm/MATLAB76/'];
efdaitm.peysson(1).compiler_opt.copts = '';
efdaitm.peysson(1).compiler_opt.fopts.mex76 = ['-v FFLAGS=''-fexceptions -fPIC -fno-omit-frame-pointer -ffixed-line-length-132'''];
%efdaitm.peysson(1).compiler_opt.helmex.mex76 = 'FLIBS=''-L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas''';
efdaitm.peysson(1).compiler_opt.helmex.mex76 = ['-L/usr/bin/g95 -lf95 -lgcc ',efdaitm.peysson(1).local_root,'lapack/amd64_g95/lib/liblapack.so ',efdaitm.peysson(1).local_root,'blas/amd64_g95/lib/libblas.so ',efdaitm.peysson(1).local_root,'lapack/amd64_g95/lib/libtmglib.so '];% Optional argument for helmex compilation
efdaitm.peysson(1).compiler_opt.helmex.mex76 = 'FLIBS=''-L/usr/bin/g95 -lf95 -lgcc -Wl,-rpath-link,/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -L/afs/efda-itm.eu/project/switm/matlab/bin/glnxa64 -lmx -lmex -lmat -lm -L/afs/efda-itm.eu/project/switm/lapack/amd64_g95/lib/ -llapack -ltmglib -L/afs/efda-itm.eu/project/switm/blas/amd64_g95/lib/ -lblas -lguide -lpthread''';
efdaitm.peysson(1).compiler_opt.helmex.mex75 = NaN;
%
efdaitm.peysson(1).MUMPS.mex706 = [efdaitm.peysson(1).local_root,'mumps/MUMPS_4.7.3_SEQ/MATLAB/'];%Where MUMPS matrix solver is stored (MEX function)