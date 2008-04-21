function setpath_luke_jd(luke_root,dkepath,flag)
%
% This script sets the path such that the simulations run on the specified LUKE version.
%

if nargin < 3,
    flag = 0;
end
%
%remove old DKE and packages path
%
P = [path,':'];
%
while ~isempty(P),
    if strfind(computer,'PCWIN'),
        pathdelim = ';';
        pathstr = 'Project_DKE\Database\PATH_files';
    else
        pathdelim = ':';
        pathstr = 'Project_DKE/Database/PATH_files';
    end
    ilim = min(find(P == pathdelim));
    if isempty(ilim),
        ilim = length(P);
    end
    pathline = P(1:ilim-1);
    if ~isempty(strfind(pathline,'LUKE')) & (flag | isempty(strfind(pathline,pathstr))),
        rmpath(pathline);
    end
    P(1:ilim) = '';
end
%
if nargin == 0, 
    return
end
%
% Path for DKE
%
addpath([luke_root,'Project_DKE/Modules/FEB/Response']);
addpath([luke_root,'Project_DKE/Modules/FEB/Pile-up']);
addpath([luke_root,'Project_DKE/Modules/FEB']);
addpath([luke_root,'Project_DKE/Modules/ACCOME']);
addpath([luke_root,'Project_DKE/Modules/Helena']);
addpath([luke_root,'Project_DKE/Modules/R2D2']);
addpath([luke_root,'Project_DKE/Modules/EFIT']);
addpath([luke_root,'Project_DKE/Modules/RT']);
addpath([luke_root,'Project_DKE/Modules/Cronos']);
addpath([luke_root,'Project_DKE/Display']);
addpath([luke_root,'Project_DKE/Packages']);
addpath([luke_root,'Project_DKE/Packages/MUMPS']);
addpath([luke_root,'Project_DKE/Packages/PETSc']);
addpath([luke_root,'Project_DKE/Database/DISPLAY_files']);
addpath([luke_root,'Project_DKE/Database/DKEPARAM_files']);
addpath([luke_root,'Project_DKE/Database/EQUIL_files']);
addpath([luke_root,'Project_DKE/Database/HXR_files']);
addpath([luke_root,'Project_DKE/Database/WAVE_files']);
addpath([luke_root,'Project_DKE/Database/OHM_files']);
addpath([luke_root,'Project_DKE/Database/TRANSP_files']);
addpath([luke_root,'Project_DKE/Database/RIPPLE_files']);
addpath([luke_root,'Project_DKE/Database/EXTERNAL_files']);
addpath([luke_root,'Project_DKE/DKE']);
%
% Path for MEX files
%
if nargin >= 2 & isstruct(dkepath), 
    if ~isfield(dkepath,'mex')
        addpath([luke_root,'Project_DKE/MEX/Bin']);
        addpath([luke_root,'Project_DKE/Packages/PETSc/MEX/Bin']);
        addpath([luke_root,'Project_DKE/Modules/RT/MEX/Bin']);
        addpath([luke_root,'Project_DKE/Modules/R2D2/MEX/Bin']);
        addpath([luke_root,'Project_DKE/Modules/Helena/MEX/Bin']);
        addpath([luke_root,'Project_DKE/Modules/FEB/MEX/Bin']);
    else
        addpath(dkepath.mex);
    end
end
%
%
% Path for external packages
%
if nargin >= 2 & isstruct(dkepath), 
    if isfield(dkepath,'MUMPS') & isfield(dkepath.MUMPS,'mex'),
		matver = version;
		matver = matver([1,3]);
		if isfield(dkepath.MUMPS,['mex',matver]),
			eval(['addpath(dkepath.MUMPS.mex',matver,')']);
		else
			addpath(dkepath.MUMPS.mex);
		end
    end
    if isfield(dkepath,'SUPERLU') & isfield(dkepath.SUPERLU,'mex'),
        addpath(dkepath.SUPERLU.mex);
    end
end
%
