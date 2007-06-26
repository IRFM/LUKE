function dkepath = path_LUKE_LOCAL
%
% This function sets the LUKE and packages path relative to the local directory
%
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
curr_dir = pwd;
%
if strfind(computer,'PCWIN'),    
    delim = '\';
    pathdelim = ';';
else
    delim = '/';
    pathdelim = ':';
end
%
lukestr = [delim,'LUKE'];
%
ind_LUKE_dir = strfind(curr_dir,lukestr);
%
if ~isempty(ind_LUKE_dir),
    %
    ind_root = min(find(curr_dir(ind_LUKE_dir+1:end) == delim));
    %
    path_root = curr_dir(1:ind_LUKE_dir + ind_root - 1);
    %
    disp('LUKE folder in the current directory searched for PATH_LOCAL.mat')
    %
else
    %
    all_dir = path;
    %
    ind_LUKE_dir = min(strfind(all_dir,lukestr));
    %
    if isempty(ind_LUKE_dir),
        error('There is no LUKE folder in the current directory or in the path');
    end
    %
    disp('LUKE folder in the path searched for PATH_LOCAL.mat')
    %
    ind_root_beg = max([0,find(all_dir(1:ind_LUKE_dir) == pathdelim)]);
    ind_root_end = min(find(all_dir(ind_LUKE_dir+1:end) == delim | all_dir(ind_LUKE_dir+1:end) == pathdelim));
    %
    path_root = all_dir(ind_root_beg + 1:ind_LUKE_dir + ind_root_end - 1);
    %
end
%
path_root = [path_root,delim];
%
filename = [path_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat'];
if exist(filename),
    load(filename);
    disp([path_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat has been loaded'])
    return
end
%
disp([path_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat was not found.'])
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
dkepath.luke_root = path_root;
dkepath.local_root = path_root;
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
    MUMPS_par = uigetdir(initdir,'Select Parallel MUMPS directory: "dke"');%Where MUMPS matrix solver is stored (stand-alone application for parallel processing)
    MUMPS_seq = uigetdir(initdir,'Select Sequential MUMPS directory: "dke"');%Where MUMPS matrix solver is stored (stand-alone application for sequential processing)
    MUMPS_mex = uigetdir(initdir,'Select Mex MUMPS directory: "MATLAB"');%Where MUMPS matrix solver is stored (stand-alone application for MEX processing)
    %
    MUMPS_mpi = uigetdir('/','Select mpi directory for MUMPS: "bin". Cancel to use system path.');%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
    %
    PETSc_par = uigetdir(initdir,'Select Parallel PETSc directory: "DKE"');%Where PETSc matrix solver is stored (stand-alone application for parallel processing)
    PETSc_seq = uigetdir(initdir,'Select Sequential PETSc directory: "DKE"');%Where PETSc matrix solver is stored (stand-alone application for sequential processing)
    PETSc_mex = uigetdir(initdir,'Select Mex PETSc directory: "MATLAB"');%Where PETSc matrix solver is stored (stand-alone application for MEX processing)
    %
    PETSc_mpi = uigetdir('/','Select mpi directory for PETSc: "bin". Cancel to use system path.');%Absolute path to the correct mpirun or mpiexec (may depend of the architecture and the program). Leave empty is default system path is used
    %
    SUPERLU_mex = uigetdir(initdir,'Select Mex SUPERLU directory: "MATLAB"');%Where SUPERLU matrix solver is stored (stand-alone application for MEX processing)
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
    if MUMPS_mpi ~= 0,
        dkepath.MUMPS.mpipath = [MUMPS_mpi,'/'];
    else
        dkepath.MUMPS.mpipath = '';
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
    if PETSc_mpi ~= 0,
        dkepath.PETSc.mpipath = [PETSc_mpi,'/'];
    else
        dkepath.PETSc.mpipath = '';
    end
    if SUPERLU_mex ~= 0,
        dkepath.SUPERLU.mex = SUPERLU_mex;
    end
    %
    save([path_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat'],'dkepath');
    disp([path_root,'Project_DKE/Database/PATH_files/PATH_LOCAL.mat is created.'])
    %
end
%

