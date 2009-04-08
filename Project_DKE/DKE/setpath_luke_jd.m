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
    %
    ilim = find(P == ':',1,'first');
    pathline = P(1:ilim-1);
    %
    if ~isempty(strfind(pathline,'LUKE'))
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
addpath([luke_root,'Project_DKE/Modules/AMR']);
addpath([luke_root,'Project_DKE/Modules/ACCOME']);
addpath([luke_root,'Project_DKE/Modules/Helena']);
addpath([luke_root,'Project_DKE/Modules/R2D2']);
addpath([luke_root,'Project_DKE/Modules/R2D2/MEX/Bin']);
addpath([luke_root,'Project_DKE/Modules/EFIT']);
addpath([luke_root,'Project_DKE/Modules/RT']);
addpath([luke_root,'Project_DKE/Modules/Ripple/TS']);
addpath([luke_root,'Project_DKE/Modules/Cronos']);
addpath([luke_root,'Project_DKE/Display']);
addpath([luke_root,'Project_DKE/Packages']);
addpath([luke_root,'Project_DKE/Packages/MUMPS']);
addpath([luke_root,'Project_DKE/Packages/PETSc']);
addpath([luke_root,'Project_DKE/Packages/MDCE']);
addpath([luke_root,'Project_DKE/Packages/MDCE/dcluke']);
addpath([luke_root,'Project_DKE/Database/DISPLAY_files']);
addpath([luke_root,'Project_DKE/Database/DKEPARAM_files']);
addpath([luke_root,'Project_DKE/Database/EQUIL_files']);
addpath([luke_root,'Project_DKE/Database/HXR_files']);
addpath([luke_root,'Project_DKE/Database/WAVE_files']);
addpath([luke_root,'Project_DKE/Database/OHM_files']);
addpath([luke_root,'Project_DKE/Database/TRANSP_files']);
addpath([luke_root,'Project_DKE/Database/RIPPLE_files']);
addpath([luke_root,'Project_DKE/Database/EXTERNAL_files']);
addpath([luke_root,'Project_DKE/Database/PATH_files']);
addpath([luke_root,'Project_DKE/DKE']);
addpath([luke_root,'Tools']);
%
% Path for MEX files
%
matver = version;
matver = matver([1,3]);
%
sourcepath.DKE = [luke_root,'Project_DKE/MEX/Source/'];
sourcepath.C3PO = [luke_root,'Project_DKE/Modules/RT/MEX/Source/'];
sourcepath.helmex = [luke_root,'Project_DKE/Modules/Helena/MEX/Source/'];
%
if nargin == 2, 
    %
	if isfield(dkepath,['mex',matver]),
        mexpath = dkepath.(['mex',matver]);
        force_compile = 0;
    else
        mexpath = [luke_root,'Project_DKE/MEX/Bin'];
        force_compile = 1;
    end
    mex_compile_luke(sourcepath,mexpath,dkepath.compiler_opt,force_compile)
    %
    addpath(mexpath);
    %
end
%
% Path for external packages
%
if nargin == 2, 
    if isfield(dkepath,'MUMPS') 
		if isfield(dkepath.MUMPS,['mex',matver]),
			addpath(dkepath.MUMPS.(['mex',matver]));
        elseif isfield(dkepath.MUMPS,'mex'),
			addpath(dkepath.MUMPS.mex);
		end
    end
    if isfield(dkepath,'SUPERLU') & isfield(dkepath.SUPERLU,'mex'),
        addpath(dkepath.SUPERLU.mex);
    end
end
%
