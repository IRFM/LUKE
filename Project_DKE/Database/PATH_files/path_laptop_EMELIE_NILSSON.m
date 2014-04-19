function dkepath = path_laptop_EMELIE_NILSSON
%
% path definitions for macbook pro 2011 (Core i5 Intel) of Emelie Nilsson
%
%	Output:
%
%       - dkepath: path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
dkepath.machine = 'macbookemelie';
dkepath.hostname = 'macbookemelie';
dkepath.computer = computer;%machine type and supported OS
%
% Selected user profile for unlisted users
%
dkepath.default = 'emenil';
%
%--------------------------------------------------------------------------------------------------------
%------------------------------------ Profile number 1, Yves Peysson ------------------------------------
%--------------------------------------------------------------------------------------------------------
%
dkepath.emenil(1).luke_root = [pwd,filesep];
dkepath.emenil(1).local_root = [getenv('HOME'),'/CEA/'];
dkepath.emenil(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.emenil(1).mex801 = [dkepath.yves(1).luke_root,'Project_DKE/MEX/Bin/macbookemelie/MATLAB801','/'];
%
dkepath.emenil(1).compiler_opt.copts = '';
dkepath.emenil(1).compiler_opt.fopts.mex801 = ' ';%-largeArrayDims';
dkepath.emenil(1).compiler_opt.helmex.mex801 = NaN;%' -llapack -lblas';%-O2 -fdefault-real-8 -fdefault-double-8 -lgfortran';%'  -llapack -lblas';% Optional argument for helmex compilation. WARNING: the option for 64bits integer -largeArrayDims does not work for helmex77.F but OK for separatrice.F
%
% MUMPS matrix solver (parallel, sequential, mex)
%
dkepath.emenil(1).MUMPS.seq = [dkepath.emenil(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/dke'];%Where MUMPS matrix solver is stored  (stand-alone application for sequential processing)
dkepath.emenil(1).MUMPS.mex801 = [dkepath.emenil(1).local_root,'Packages/Bin/MUMPS/MUMPS_4.10.0_S_ifort/MATLAB801'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Access to the experimental databases -----------------------------
%
% Tore Supra (TSBase)
%
dkepath.emenil(1).TSBASE.mex = [dkepath.emenil(1).luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase'];%Where tsbase, tsmat and tsdernier_choc functions are stored (MEX function)
%
% LUKE documentation
%
dkepath.emenil(1).graphviz.env = '/usr/local/bin/';% Graphviz environment variable
dkepath.emenil(1).latex.env = '/usr/texbin/';% Latex environment variable
dkepath.emenil(1).imagemagick.env = '/usr/local/bin/';% ImageMagick environment variable
%
%--------------------------- Remote computing -----------------------------
%
% for profilename, use 'local' to select profile from user name on client machine (or default if unknown)
%
dkepath.emenil(1).remote(1).remoteid = 'CEA_ANDROMEDE';
dkepath.emenil(1).remote(1).schedulername = 'pbs';
dkepath.emenil(1).remote(1).profilename = 'EN290612';
dkepath.emenil(1).remote(1).luke_root = '/home/EN290612/LUKE/';
dkepath.emenil(1).remote(1).link_mode = [];
dkepath.emenil(1).remote(1).cvsupdate = false;% update done in 'direct' mode
%
dkepath.emenil(1).remote(2) = dkepath.emenil(1).remote(1);
dkepath.emenil(1).remote(2).schedulername = 'direct';
dkepath.emenil(1).remote(2).cvsupdate = true;% update done in 'direct' mode
dkepath.emenil(1).remote(2).cvsrights = 'chmod -R a+rx ./';
%


