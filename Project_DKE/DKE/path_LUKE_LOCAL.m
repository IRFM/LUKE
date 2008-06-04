function dkepath = path_LUKE_LOCAL
%
% This function sets the LUKE and packages path relative to the local directory
%
path_id = 'LOCAL';%Set here the name path parameters (user specific)
%
filename = ['PATH_',path_id,'.mat'];
filepaths = which(filename,'-all');
nn = length(filepaths);
%
kk = [];
if strcmp(computer,'MAC') | strcmp(computer,'MACI') | strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64'),%Systems which are usually not case sensitive
    for ii = 1:nn-1,
        for jj = ii+1:nn
            if strcmpi(filepaths{ii},filepaths{jj}),%identify identical strings (not case sensitive)
            	kk = [kk,jj];
            end
        end
    end
%
    if ~isempty(kk),
        filepaths_new{1} = filepaths{1};%The first path is always kept
        mm = 2;
        for ii = 2:nn
            flag = 0;
            for jj = 1:length(kk)
                if ii == kk(jj),flag = 1;end
            end
            if flag == 0,
                filepaths_new{mm} = filepaths{ii};
                mm = mm + 1;
            end
        end
        filepaths = filepaths_new;
        nn = length(filepaths);   
	end
end
%
if nn > 0,
    if nn == 1,
        isel = 1;
    else
        disp('----> Please select one of the following :');
        for in = 1:nn,
            disp(['(',num2str(in),') : ',filepaths{in}]);
        end
        isel = input('? [1] ');
        if isempty(isel) | ~isnumeric(isel) | isel > nn,
            isel = 1;
        end
    end
    %
    filepath = filepaths{isel};
    %
    load(filepath,'dkepath'); 
    disp([filepath,' has been loaded'])
    return
end   
%
if strfind(computer,'PCWIN'),    
    delim = '\';
    pathdelim = ';';
else
    delim = '/';
    pathdelim = ':';
end
%
curr_dir = [which('path_LUKE_LOCAL.m'),delim];
%
lukestr = [delim,'LUKE'];
%
ind_LUKE_dir = max(strfind(curr_dir,lukestr));
%
ind_root = min(find(curr_dir(ind_LUKE_dir+1:end) == delim));
%
path_root = curr_dir(1:ind_LUKE_dir + ind_root - 1);
path_root = [path_root,delim];
%
filename = [path_root,'Project_DKE',delim,'Database',delim,'PATH_files',delim,filename];
%
disp([filename,' was not found and is created now.'])
%
dkepath.path_id = path_id;
dkepath.computer = computer;%machine type and supported OS
dkepath.luke_root = path_root;
%
uisetpath_flag = '';
%
while ~(ischar(uisetpath_flag) & (strcmp(uisetpath_flag,'y') | strcmp(uisetpath_flag,'n'))),
    %
    uisetpath_flag  = input_dke_yp('Do you want to build PATH_LOCAL.mat interactively? [y,n] ','y'); 
    %
end
%
if uisetpath_flag == 'n',
    dkepath.temppathroot = '';%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
	dkepath.local_root = path_root;
else
	%
	disp('Press cancel to skip any path setting.')
    %
    if exist('/scratch/','dir'),
        initdir = '/scratch/';
    elseif exist('/tmp/','dir'),
        initdir = '/tmp/';
	else 
		initdir = '';
    end
	%
    temppathroot = uigetdir(initdir,'Select Temporary Directory');%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
    if temppathroot ~= 0,
        dkepath.temppathroot = [temppathroot,'/'];
	else
		dkepath.temppathroot = '';
    end
    %
    initdir = [path_root,'Packages/'];
    %
    local_root = uigetdir(initdir,'Select External Packages Directory');%Absolute root directory path adress where temporary matrices are stored (empty: local directory)
    if local_root ~= 0,
        dkepath.local_root = [local_root,'/'];
	else
		dkepath.local_root = path_root;
    end
    %
	initdir = dkepath.local_root;
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
	uisetpath_flag  = input('Please provide the arguments for the HELMEX compilation (type n to abandon helmex compilation): ','s');
	%
	if ischar(uisetpath_flag) | ~strcmp(uisetpath_flag,'n'),
		dkepath.compiler_opt.helmex = uisetpath_flag;
	end
	%
    save(filename,'dkepath');
    disp([filename,' is created.'])
    disp('The path file PATH_LOCAL.mat can be interactively rebuilt with the function path_LUKE_LOCAL.m')
    %
end

