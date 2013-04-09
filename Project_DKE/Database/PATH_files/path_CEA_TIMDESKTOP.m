function [dkepath] = path_CEA_TIMDESKTOP(luke_ref)
%
% path definitions for TIMOTHEE NICOLAS desktop 
%
%	Input:
%
%       - luke_ref: for CVS tagged LUKE version [1,1]
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
dkepath.hostname = 'cadts-0412';
dkepath.machine = 'timdesktop';
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
%------------------------------------ Profile number 1, Joan Decker ------------------------------------
%
dkepath.joan(1).luke_root = ['/home/sccp/gsem/decker/',luke_ref,'/'];
dkepath.joan(1).local_root = '/home/joan/';
dkepath.joan(1).temppathroot = '/home/joan/tmp/';%'/scratch/';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
%
dkepath.joan(1).mex77 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB77'];
dkepath.joan(1).mex710 = [dkepath.joan(1).luke_root,'Project_DKE/MEX/Bin/timdesktop/MATLAB710']; 
%
dkepath.joan(1).compiler_opt.copts = '';
dkepath.joan(1).compiler_opt.fopts = 'FC=''ifort''';
dkepath.joan(1).compiler_opt.helmex = NaN;% Optional argument for helmex compilation
%
dkepath.joan(1).MUMPS.mex77 = [dkepath.joan(1).local_root,'MUMPS_4.9.2/MATLAB77'];%Where MUMPS matrix solver is stored (MEX function)
dkepath.joan(1).MUMPS.mex710 = [dkepath.joan(1).local_root,'MUMPS_4.9.2/MATLAB710'];%Where MUMPS matrix solver is stored (MEX function)
%
%--------------------------- Remote computing -----------------------------
%
% cadts-0412 (torque, Timothee's computer). 
%
dkepath.joan(1).remote(1) = remote_CEA_TIMDESKTOP('torque','joan','joan');
dkepath.joan(1).remote(1).host = '';% empty for local host
dkepath.joan(1).remote(1).luke_root = dkepath.joan(1).luke_root;
%
% macproyves (condor)
%
dkepath.joan(1).remote(2) = remote_macpro_YVES_PEYSSON('condor','joan','joan');
%
% macproyves (xgrid)
%
dkepath.joan(1).remote(3) = remote_macpro_YVES_PEYSSON('xgrid','joan','joan');
%
% intra integrated pbspro system (pleione, merope, nashira, newpegase, nunki cluster). Shares the same filesystem as cadts-0412
%
dkepath.joan(1).remote(4) = remote_CEA_PLEIONE('pbs','joan','joan');
dkepath.joan(1).remote(4).luke_root = dkepath.joan(1).luke_root;
%
% cephee (pbs). Shares the same filesystem as cadts-0412
%
dkepath.joan(1).remote(5) = remote_CEA_CEPHEE('pbs','joan','joan');
dkepath.joan(1).remote(5).luke_root = dkepath.joan(1).luke_root;
%
% andromede (pbs). Shares the same filesystem as cadts-0412
%
dkepath.joan(1).remote(6) = remote_CEA_ANDROMEDE('pbs','joan','joan');
dkepath.joan(1).remote(6).luke_root = dkepath.joan(1).luke_root;
%
% saturne (sun)
%
dkepath.joan(1).remote(7) = remote_CEA_SATURNE('sun','joan','joan');
%