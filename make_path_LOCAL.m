function make_path_LOCAL
%
%---------------------------------------------------------------------------------------------------
%-------------------------------------- PATH PARAMETERS --------------------------------------------
%---------------------------------------------------------------------------------------------------
%
% Create the local file LUKE_PATH.mat
%
% WARNING: matlab versions before 7.5 (R2007b) are no longer supported
% 
% by Y.Peysson CEA/DSM/IRFM <yves.peysson@cea.fr> and Joan Decker CEA/DSM/IRFM (joan.decker@cea.fr)
%
dkepath = load_dkepath_yp;% Load local path profile
%
%---------------------------------------------------------------------------------------------------
%
% save LUKE_PATH.mat
%
pathfile = [dkepath.luke_root,'Project_DKE/Database/PATH_files/LUKE_PATH.mat'];
save(pathfile,'dkepath');
disp('------------------------------------------------------');
info_dke_yp(2,['The dkepath structure is saved in ',pathfile],'','Green');
%