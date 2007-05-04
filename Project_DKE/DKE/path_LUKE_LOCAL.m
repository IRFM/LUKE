function dkepath = path_LUKE_LOCAL
%
% This function sets the LUKE and packages path relative to the local directory
%
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
curr_dir = pwd;
%
ind_LUKE_dir = strfind(curr_dir,'LUKE');
%
if ~isempty(ind_LUKE_dir),
    %
    ind_root = min(find(curr_dir(ind_LUKE_dir:end) == '/'));
    %
    path_root = curr_dir(1:ind_LUKE_dir + ind_root - 2);
    %
    disp('LUKE folder in the current directory searched for PATH_LOCAL.mat')
    %
else
    %
    all_dir = path;
    %
    ind_LUKE_dir = min(strfind(all_dir,'LUKE'));
    %
    if isempty(ind_LUKE_dir),
        error('There is no LUKE folder in the current directory or in the path');
    end
    %
    disp('LUKE folder in the path searched for PATH_LOCAL.mat')
    %
    ind_root_beg = max([0,find(all_dir(1:ind_LUKE_dir) == ':')]);
    ind_root_end = min(find(all_dir(ind_LUKE_dir:end) == '/' | all_dir(ind_LUKE_dir:end) == ':'));
    %
    path_root = all_dir(ind_root_beg + 1:ind_LUKE_dir + ind_root_end - 2);
    %
end
%
path_root = [path_root,'/'];
%
filename = [path_root,'project_DKE/Database/PATH_files/PATH_LOCAL.mat'];
if exist(filename),
    disp([path_root,'project_DKE/Database/PATH_files/PATH_LOCAL.mat has been loaded'])
    load(filename);
    return
end
%
disp([path_root,'project_DKE/Database/PATH_files/PATH_LOCAL.mat was not found.'])
%
uisetpath_flag = '';
%
while ~(ischar(uisetpath_flag) & (strcmp(uisetpath_flag,'y') | strcmp(uisetpath_flag,'n'))),
    %
    uisetpath_flag  = input_dke_yp('Do you want to build PATH_LOCAL.mat interactively? [y,n] ','y'); 
    %
end
%
dkepath.path_id = path_id;
dkepath.computer = computer;%machine type and supported OS
dkepath.mex = [path_root,'Project_DKE/MEX'];
dkepath.luke_root = path_root;
%
if uisetpath_flag == 'n',
    dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
else
    %
    if exist('/scratch/','dir'),
        initdir = '/scratch/';
    else
        initdir = '';
    end
    dkepath.temppathroot = uigetdir(initdir,'Select Temporary Directory');%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
    dkepath.temppathroot = [dkepath.temppathroot,'/'];
    %
    initdir = [path_root,'Packages/'];
    %
    [dummy,MUMPS_par] = uigetfile([initdir,'mumpsdke.*'],'Select Parallel MUMPS entry file');%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
    [dummy,MUMPS_seq] = uigetfile([initdir,'mumpsdke.*'],'Select Sequential MUMPS entry file');%Where MUMPS matrix solver is stored (stand-alone application for sequential processing)
    [dummy,MUMPS_mex] = uigetfile([initdir,'dmumpsmex.*'],'Select Mex MUMPS entry file');%Where MUMPS matrix solver is stored (stand-alone application for MEX processing)
    %
    [dummy,PETSc_par] = uigetfile([initdir,'PETSc_DKE_ft.*'],'Select Parallel PETSc entry file');%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
    [dummy,PETSc_seq] = uigetfile([initdir,'PETSc_DKE_ft.*'],'Select Sequential PETSc entry file');%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
    [dummy,PETSc_mex] = uigetfile([initdir,'PETSc_DKE_ft.*'],'Select Mex PETSc entry file');%Where PETSc matrix solver is stored (stand-alone application for MEX processing)
    %
    [dummy,SUPERLU_mex] = uigetfile([initdir,'mexsuperlu.*'],'Select Mex SUPERLU entry file');%Where SUPERLU matrix solver is stored (stand-alone application for MEX processing)
    %
    if MUMPS_par ~= 0,
        dkepath.MUMPS.par = MUMPS_par;
    end
    if MUMPS_seq ~= 0,
        dkepath.MUMPS.seq = MUMPS_seq;
    end
    if MUMPS_mex ~= 0,
        dkepath.MUMPS.mex = MUMPS_mex;
    end
    if PETSc_par ~= 0,
        dkepath.PETSc.par = PETSc_par;
    end
    if PETSc_seq ~= 0,
        dkepath.PETSc.seq = PETSc_seq;
    end
    if PETSc_mex ~= 0,
        dkepath.PETSc.mex = PETSc_mex;
    end
    if SUPERLU_mex ~= 0,
        dkepath.SUPERLU.mex = SUPERLU_mex;
    end
    %
    save([path_root,'project_DKE/Database/PATH_files/PATH_LOCAL.mat'],'dkepath');
    disp([path_root,'project_DKE/Database/PATH_files/PATH_LOCAL.mat is created.'])
    %
end
%


