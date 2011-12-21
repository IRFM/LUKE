function [asipp] = path_ASIPP(luke_ref)
%
% path definitions for ASIPP (Heifei, China) computer
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
asipp.hostname = 'node0';
asipp.machine = 'asipp';
asipp.computer = computer;%machine type and supported OS
%
% Selected user profile (structure hostname.usernames(path_profile).xxx)
%
asipp.path_profile = 1;
%
%------------------------------------ Profile number 1, Bojiang Ding ------------------------------------
%
asipp.bojiangding(1).luke_root = [getenv('HOME'),'/',luke_ref,'/'];
asipp.bojiangding(1).local_root = [getenv('HOME'),'/'];
asipp.bojiangding(1).temppathroot = '/tmp/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
asipp.bojiangding(1).mex710 = [asipp.bojiangding(1).luke_root,'Project_DKE/MEX/Bin/asipp/MATLAB710'];
%
asipp.bojiangding(1).MUMPS.seq = [asipp.bojiangding(1).local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/dke'];
asipp.bojiangding(1).MUMPS.mex710 = [asipp.bojiangding(1).local_root,'PACKAGES/Bin/MUMPS/MUMPS_4.7.3_S_PGF90/MATLAB'];%Where MUMPS matrix solver is stored (MEX function)
asipp.bojiangding(1).compiler_opt.helmex = '-L/home/bojiangding/PACKAGES/Bin/GotoBLAS -lgoto';% Optional arguments for compilation 
%
