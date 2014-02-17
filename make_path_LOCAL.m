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
%update startup.m file with parameters in dkepath
%
if isfield(dkepath,'startup'),
    if ~isempty(dkepath.startup),
        LUKE_startup_jd(dkepath.startup,'',1);%update startup.m 
    end
end
%
%update .cshrc.perso file with parameters in dkepath
%
if isfield(dkepath,'cshrc'),
    if ~isempty(dkepath.cshrc),
        LUKE_cshrc_yp(dkepath.cshrc);%update .cshrc.perso file if a .cshrc file exists in the session
    end
end
