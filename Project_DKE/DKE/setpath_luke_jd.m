function setpath_luke_jd(luke_root,dkepath)
%
% This script sets the path such that the simulations run on the specified LUKE version.
%

%
%remove old DKE and packages path
%
P = [path,':'];
%
while ~isempty(P),
    ilim = min(find(P == ':'));
    pathline = P(1:ilim-1);
    if strfind(pathline,'LUKE'),
        rmpath(pathline);
    end
    P(1:ilim) = '';
end
%
% Path for DKE
%
addpath([luke_root,'Project_DKE/Modules/FEB/Response']);
addpath([luke_root,'Project_DKE/Modules/FEB/Pile-up']);
addpath([luke_root,'Project_DKE/Modules/FEB']);
addpath([luke_root,'Project_DKE/Modules/FEB/MEX/Bin']);
addpath([luke_root,'Project_DKE/Modules/Helena']);
addpath([luke_root,'Project_DKE/Modules/Helena/MEX/Bin']);
addpath([luke_root,'Project_DKE/Modules/R2D2']);
addpath([luke_root,'Project_DKE/Modules/R2D2/MEX/Bin']);
addpath([luke_root,'Project_DKE/Modules/EFIT']);
addpath([luke_root,'Project_DKE/Modules/RT']);
addpath([luke_root,'Project_DKE/Modules/RT/MEX/Bin']);
addpath([luke_root,'Project_DKE/Modules/Cronos']);
addpath([luke_root,'Project_DKE/Packages']);
addpath([luke_root,'Project_DKE/Packages/MUMPS']);
addpath([luke_root,'Project_DKE/Packages/PETSc']);
addpath([luke_root,'Project_DKE/Packages/PETSc/MEX/Bin']);
addpath([luke_root,'Project_DKE/Database/PATH_files']);
addpath([luke_root,'Project_DKE/Database/DISPLAY_files']);
addpath([luke_root,'Project_DKE/Database/DKEPARAM_files']);
addpath([luke_root,'Project_DKE/Database/EQUIL_files']);
addpath([luke_root,'Project_DKE/Database/WAVE_files']);
addpath([luke_root,'Project_DKE/Database/OHM_files']);
addpath([luke_root,'Project_DKE/Database/TRANSP_files']);
addpath([luke_root,'Project_DKE/Database/RIPPLE_files']);
addpath([luke_root,'Project_DKE/MEX']);
addpath([luke_root,'Project_DKE/DKE']);
%
% Path for external packages
%
if nargin >= 2, 
    if isfield(dkepath.MUMPS,'mex'),
        addpath(dkepath.MUMPS.mex);
    end
    if isfield(dkepath.SUPERLU,'mex'),
        addpath(dkepath.SUPERLU.mex);
    end
end
%
