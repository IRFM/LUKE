function dkepath = path_CEA_ANDROMEDE
%
% path definitions for the andromede and cephee computers
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = {'andromede','cephee'};
dkepath.hostname = {'andromede1.partenaires.cea.fr','cephee.partenaires.cea.fr'};% should match the output of hostname_jd on the machine
%
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'YP105119';
%
%------------------------------------ Profile number 1, YP105119 Peysson ------------------------------------
%
dkepath.YP105119(1).luke_root = [pwd,filesep];
dkepath.YP105119(1).temppathroot = '/data/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
% ---------------------------- andromede -------------------------------
%
dkepath.YP105119(1).andromede.local_root = '/home/YP105119/Packages/andromede/';
%
dkepath.YP105119(1).andromede.mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB710/'];
dkepath.YP105119(1).andromede.mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB800/'];
dkepath.YP105119(1).andromede.mex801 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB801/'];
dkepath.YP105119(1).andromede.mex805 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB805/'];
dkepath.YP105119(1).andromede.mex806 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/andromede/MATLAB806/'];
%
dkepath.YP105119(1).andromede.compiler_opt.copts = '';
dkepath.YP105119(1).andromede.compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.YP105119(1).andromede.compiler_opt.fopts.mex800 = '';
dkepath.YP105119(1).andromede.compiler_opt.fopts.mex801 = '';
dkepath.YP105119(1).andromede.compiler_opt.fopts.mex805 = '';
dkepath.YP105119(1).andromede.compiler_opt.fopts.mex806 = '';
dkepath.YP105119(1).andromede.compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede.compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede.compiler_opt.helmex.mex801 = ['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede.compiler_opt.helmex.mex805 = ['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).andromede.compiler_opt.helmex.mex806 = ['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).andromede.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).andromede.MUMPS.mex710 = [dkepath.YP105119(1).andromede.local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede.MUMPS.mex800 = [dkepath.YP105119(1).andromede.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede.MUMPS.mex801 = [dkepath.YP105119(1).andromede.local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede.MUMPS.mex805 = [dkepath.YP105119(1).andromede.local_root,'MUMPS_4.10.0/MATLAB805'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).andromede.MUMPS.mex806 = [dkepath.YP105119(1).andromede.local_root,'MUMPS_4.10.0/MATLAB806'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).extrapaths.LUKE_ITM = [dkepath.YP105119(1).andromede.local_root,'LUKE_ITM/trunk'];% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.YP105119(1).andromede.graphviz.env = '/home/YP105119/bin/';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).andromede.latex.env = '/usr/bin/';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).andromede.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
% ---------------------------- cephee -------------------------------
%
dkepath.YP105119(1).cephee.local_root = '/home/YP105119/Packages/cephee/';
%
dkepath.YP105119(1).cephee.mex710 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB710/'];
dkepath.YP105119(1).cephee.mex800 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB800/'];
dkepath.YP105119(1).cephee.mex801 = [dkepath.YP105119(1).luke_root,'Project_DKE/MEX/Bin/cephee/MATLAB801/'];
%
dkepath.YP105119(1).cephee.compiler_opt.copts = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex710 = 'FC=''gfortran''';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex800 = '';
dkepath.YP105119(1).cephee.compiler_opt.fopts.mex801 = '';
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex710 = NaN;%['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex800 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
dkepath.YP105119(1).cephee.compiler_opt.helmex.mex801 = ['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.4.2 -llapack -lrefblas'];%['-L',dkepath.YP105119(1).cephee.local_root,'lapack-3.1.1/ -llapack_ifort -lblas_ifort'];% Optional argument for helmex compilation
%
dkepath.YP105119(1).cephee.MUMPS.mex710 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).cephee.MUMPS.mex800 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB800'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.YP105119(1).cephee.MUMPS.mex801 = [dkepath.YP105119(1).cephee.local_root,'MUMPS_4.10.0/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
dkepath.YP105119(1).extrapaths.LUKE_ITM = [dkepath.YP105119(1).cephee.local_root,'LUKE_ITM/trunk'];% LUKE <-> ITM toolbox 
%
% LUKE documentation
%
dkepath.YP105119(1).cephee.graphviz.env = '';% Graphviz environment variable ('which dot' and 'dot -v')
dkepath.YP105119(1).cephee.latex.env = '';% Latex environment variable  ('which latex' and 'latex -v')
dkepath.YP105119(1).cephee.imagemagick.env = '/usr/bin/';% ImageMagick environment variable ('which convert' and 'convert -v')
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.YP105119(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.YP105119(1).remote(1).schedulername = 'pbs';
dkepath.YP105119(1).remote(1).profilename = 'YP105119';
dkepath.YP105119(1).remote(1).luke_root = dkepath.YP105119(1).luke_root;% local cluster
%
dkepath.YP105119(1).remote(2).remoteid = 'macpro_YVES_PEYSSON';
dkepath.YP105119(1).remote(2).schedulername = 'condor';
dkepath.YP105119(1).remote(2).profilename = 'yves';
dkepath.YP105119(1).remote(2).luke_root = '/Users/yvespeysson/Projets/LUKE/';
dkepath.YP105119(1).remote(2).cvs.CVSROOT = ':pserver:YP105119:6He3dNkHVzMoUg@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(2).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(2).luke_root];%CVS command
dkepath.YP105119(1).remote(2).gitupdate = true;
%
dkepath.YP105119(1).remote(3) = dkepath.YP105119(1).remote(2);
dkepath.YP105119(1).remote(3).schedulername = 'direct';
%
dkepath.YP105119(1).remote(4).remoteid = 'ASIPP_SHENMA';
dkepath.YP105119(1).remote(4).schedulername = 'torque';
dkepath.YP105119(1).remote(4).profilename = 'yves';
dkepath.YP105119(1).remote(4).luke_root = '/project/LUKE/LUKE/';
dkepath.YP105119(1).remote(4).cvs.CVSROOT = ':pserver:YP105119:6He3dNkHVzMoUg@altair.partenaires.cea.fr:/usr/local/cvs/gcgc';%CVS root for LUKE
dkepath.YP105119(1).remote(4).cvs.cmd = ['update -d ',dkepath.YP105119(1).remote(4).luke_root];%CVS command
dkepath.YP105119(1).remote(4).gitupdate = true;
%
