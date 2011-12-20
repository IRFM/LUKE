%---------------------------------------------------------------------------------------------------
%-------------------------------------- PATH PARAMETERS --------------------------------------------
%---------------------------------------------------------------------------------------------------
%
% Create the local file PATH_path_id.mat
%
% WARNING: matlab versions before 7.5 (R2007b) are no longer supported
% 
% by Y.Peysson CEA/DSM/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/DSM/IRFM (joan.decker@cea.fr)
%
clear all
%
dkepath.id = 'LOCAL';%Set here the name path parameters (user specific)
[lukeversion,matver] = LUKEversion_jd;
%
% default paths for unrecognized profiles
%
default.luke_root = [pwd,'/'];
default.local_root = [pwd,'/'];
default.computer = computer;
default.temppathroot = [pwd,'/'];
default.compiler_opt = '';% Optional arguments for compilation 
%
default.(['mex',matver]) = [default.luke_root,'Project_DKE/MEX/Bin/default/MATLAB',matver,'/'];%where compiled mex files are stored for this version of matlab
%
dkepath.default = default;
%
% Load specific path in Project_DKE/Database/PATH_files if exist
%
luke_root_dir = pwd;
iluke_root_dir = regexp(luke_root_dir,'/')+1;
luke_ref = luke_root_dir(iluke_root_dir(end):end);%for CVS tagged LUKE version
%
dkepath = load_dkepath_yp(dkepath,luke_ref);
%
%---------------------------------------------------------------------------------------------------
%
save([pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat'],'dkepath');
disp(['>> The dkepath structure for ',luke_ref,' is saved in ',pwd,'/Project_DKE/Database/PATH_files/PATH_',dkepath.id,'.mat']);
%