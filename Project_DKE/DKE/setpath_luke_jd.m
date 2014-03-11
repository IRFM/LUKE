function dkepath = setpath_luke_jd(dkepath,bridge_enforce)
%
% LUKE - This function sets the path such that the simulations run on the specified LUKE version.
%
% Actions :
%   - remove exisiting LUKE paths
%   - load LUKE_PATH.mat and process for hostname and username
%   - test remote connections
%   - compile MEX files if needed
%   - setup new LUKE paths, including MEX files and matrix inverters
%
% INPUTS :
%
%   - dkepath :
%       o '' (or nargin == 0) : LUKE_PATH.mat is searched for in the current path
%       o luke_root (string)  : LUKE root path
%       o dkepath (struct)    : an existing dkepath structure (setpath_luke_jd then used to reset paths, recompile MEX, or test remote connections)
%
%   - bridge_enforce : [NaN, empty, 0 or 1] 
%       o NaN : (default) use value from remote.bridge_enforce
%       o []  : tests both modes and give priority to ssh key pair
%       o 0   : tests and authorize only ssh key pair,
%       o 1   : tests and authorize only bridge mode
%
% OUTPUTS : 
%
%   - dkepath : structure containing LUKE path and remote LUKE data specific to local filesystem, hostname and username.
%               if nargout = 0, dkepath is saved in matlab application data
%
% by Joan Decker CEA-IRFM (joan.decker@cea.fr) and Y.Peysson CEA-IRFM <yves.peysson@cea.fr>

%
if nargin == 0 || isempty(dkepath),
    %
    filenames = which('LUKE_PATH.mat','-all');
    %
    if length(filenames) > 1,
        ifile = iselect_jd(filenames,'Warning : more than one LUKE_PATH.mat file found. Please select one of the following :',false);
    elseif isempty(filenames),
        error('No LUKE_PATH.mat found on the matlab path')
    else
        ifile = 1;
    end
    %
    load(filenames{ifile},'dkepath');
    %
elseif ischar(dkepath),% luke_root  
    %
    luke_root = dkepath;
    %
    if ~strcmp(luke_root(end),filesep),
        luke_root = [luke_root,filesep];
    end
    %
    filename = [luke_root,'Project_DKE/Database/PATH_files/LUKE_PATH.mat'];
    %
    if ~exist(filename,'file'),
        error(['The file ',filename,' does not exist'])
    else
        load(filename,'dkepath');
    end
    %
elseif ~isfield(dkepath,'luke_root'),
    %
    error('Input variable ''dkepath'' cannot be identified');
    %
end
%
if ~strcmp(dkepath.luke_root(end),filesep),
    dkepath.luke_root = [dkepath.luke_root,filesep];
end
%
luke_root = dkepath.luke_root;
%
if nargin < 2,
    bridge_enforce = NaN;
end
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
% identify local hostname if multiple profiles on the same filesystem
%
% Load all path files and select local path profile according to hostname
%
if isfield(dkepath,'hostname') && iscell(dkepath.hostname),
    %
    lochostname = hostname_jd;
    nhosts = length(dkepath.hostname);
    flag = false(1,nhosts);
    for ihost = 1:nhosts,
        if any(strfind(lochostname,dkepath.hostname{ihost})),% local cluster,
            flag(ihost) = true;
        end
    end
    isel = find(flag);
    %
    if isempty(isel),
        error('The local hostname could not be identified in dkepath')
    elseif length(isel) > 1,
        disp('WARNING : more than one positive identification for local hostname in dkepath. First match enforced.')
        isel = isel(1);
    end
    %
    dkepath = conc_struct_jd(dkepath,dkepath.(dkepath.machine{isel}));% add fields specific to local profile
    %
    dkepath = rmfield(dkepath,dkepath.machine);% remove profile-specific fields 
    %
    dkepath.hostname = dkepath.hostname{isel};
    dkepath.machine = dkepath.machine{isel};
    %
end
%
% Path for LUKE and Modules
%
addpath([luke_root,'Project_DKE/Modules/MHDK']);
addpath([luke_root,'Project_DKE/Modules/FEB/Response']);
addpath([luke_root,'Project_DKE/Modules/FEB/Pile-up']);
addpath([luke_root,'Project_DKE/Modules/FEB']);
addpath([luke_root,'Project_DKE/Modules/ALOHA']);
addpath([luke_root,'Project_DKE/Modules/AMR']);
addpath([luke_root,'Project_DKE/Modules/ACCOME']);
addpath([luke_root,'Project_DKE/Modules/Helena']);
addpath([luke_root,'Project_DKE/Modules/R2D2']);
addpath([luke_root,'Project_DKE/Modules/R2D2/MEX/Bin']);
addpath([luke_root,'Project_DKE/Modules/EFIT']);
addpath([luke_root,'Project_DKE/Modules/C3PO']);
addpath([luke_root,'Project_DKE/Modules/Ripple']);
addpath([luke_root,'Project_DKE/Modules/Ripple/TS']);
addpath([luke_root,'Project_DKE/Modules/Cronos']);
addpath([luke_root,'Project_DKE/Modules/ITM']);
addpath([luke_root,'Project_DKE/Modules/METIS']);
addpath([luke_root,'Project_DKE/Display']);
addpath([luke_root,'Project_DKE/Packages']);
addpath([luke_root,'Project_DKE/Packages/MUMPS']);
addpath([luke_root,'Project_DKE/Packages/PARDISO']);
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
addpath([luke_root,'Project_DKE/Database/EXTERNAL_files/TSBase/TSBase']);
addpath([luke_root,'Project_DKE/Database/PATH_files']);
addpath([luke_root,'Project_DKE/DKE']);
addpath([luke_root,'Tools']);
%
% Path for machine specific libraries
%
if isfield(dkepath,'speclibpath'),
    speclibpathfields = fieldnames(dkepath.speclibpath);
    for ifield = 1:length(speclibpathfields)
        addpath(dkepath.speclibpath.(speclibpathfields{ifield}));
    end
end 
%
% Path for MEX files
%
[dummy,matver] = LUKEversion_jd;
%
sourcepath.DKE = [luke_root,'Project_DKE/MEX/Source/'];
sourcepath.C3PO = [luke_root,'Project_DKE/Modules/C3PO/MEX/Source/'];
sourcepath.helmex = [luke_root,'Project_DKE/Modules/Helena/MEX/Source/'];
%
if isfield(dkepath,['mex',matver]),
    mexpath = dkepath.(['mex',matver]);
    force_compile = 0;
else
    mexpath = [luke_root,'Project_DKE/MEX/Bin'];
    force_compile = 1;
end
mex_compile_luke(sourcepath,mexpath,dkepath.compiler_opt,force_compile);
%
addpath(mexpath);
%
% Path for external packages
%
if isfield(dkepath,'MUMPS') 
    if isfield(dkepath.MUMPS,['mex',matver]),
        addpath(dkepath.MUMPS.(['mex',matver]));
    elseif isfield(dkepath.MUMPS,'mex'),
        addpath(dkepath.MUMPS.mex);
    end
end
%
if isfield(dkepath,'SUPERLU') && isfield(dkepath.SUPERLU,'mex'),
    addpath(dkepath.SUPERLU.mex);
end
%
if isfield(dkepath,'PARDISO') 
    if isfield(dkepath.PARDISO,['mex',matver]),
        addpath(dkepath.PARDISO.(['mex',matver]));
    elseif isfield(dkepath.PARDISO,'mex'),
        addpath(dkepath.PARDISO.mex);
    end
end
%
% update and verify remote profiles
%
dkepath = update_remote_jd(dkepath,bridge_enforce);
%
if nargout == 0,
    setappdata(0,'dkepath',dkepath');
end
%
info_dke_yp(0,'To check if the remote profiles are currently functionning within LUKE environment, please run ''check_remote_yp;'':')
disp (' ');
%
