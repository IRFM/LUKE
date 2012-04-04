%LUKE - Test function of matrix inversion techniques for LUKE
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr> and J. Decker (CEA-IRFM) <joan.decker@cea.fr>
%
clc
clear all
close all
%
% Flags of the tested methods (0: not testes, 1: tested). WARNING: it tests
% all compiled version of a matrix inversion method. Check before the
% compatibility with the working release of Matlab.
%
MUMPS = 1;
PETSC = 0;
SUPERLU = 1;
PARDISO = 0;
%
[lukeversion,matver] = LUKEversion_jd;
%
try
    GPUstatus = gpuDevice;%data from the GPU device
catch
    GPUstatus.DeviceSupported = false;
end    
%
if GPUstatus.DeviceSupported,
    reset(parallel.gpu.GPUDevice.current());%reset memory on GPU device (should be done to have the largest memory available)
    GPUstatus = gpuDevice;%data from the GPU device
end
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath,dkeparam] = load_structures_yp('dkepath','','','dkeparam',id_dkeparam,path_dkeparam);
dirinit = pwd;%initial directory
cd([dkepath.luke_root,'Project_DKE/Packages']);
%
disp(' ');
disp('Test performances of matrix inversion routines on your computer')
disp('---------------------------------------------------------------')
if GPUstatus.DeviceSupported,
    mode = input_dke_yp('2-D (0), 2-D for GPU (1) or 3-D (2) input matrix',0);
else
    mode = input_dke_yp('2-D (0) or 3-D (2) input matrix',0);
end
%
npass = input_dke_yp('Number of passes',1);
%
if GPUstatus.DeviceSupported && mode==1,
    gpu_mode = input_dke_yp('Calculation with GPU',1);disp(' ');
elseif GPUstatus.DeviceSupported && mode~=1,
    gpu_mode = input_dke_yp('Calculation with GPU',0);disp(' ');    
end
%
disp(' ');
disp('---------------------------------------------------------------')
%
if mode ==0,
   load('testLU2D.mat','MMXPC_f_t','MMXR_t');%,'dkeparam'
   if exist('testmatinv-2D.txt','file'),
       delete testmatinv-2D.txt;
   end;
   diary testmatinv-2D.txt;
   disp(['2-D LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
elseif mode == 1
   load('testLU2D_GPU.mat','MMXPC_f_t','MMXR_t');%,'dkeparam'
   if exist('testmatinv-2D_GPU.txt','file'),
       delete testmatinv-2D_GPU.txt;
   end;
   diary testmatinv-2D_GPU.txt;
   disp(['2-D (GPU) LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
elseif mode == 2
   load('testLU3D.mat','MMXPC_f_t','MMXR_t');%,'dkeparam'
   if exist('testmatinv-3D.txt','file'),
       delete testmatinv-3D.txt;
   end;
   diary testmatinv-3D.txt;
   disp(['3-D LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
end
%
if GPUstatus.DeviceSupported && gpu_mode,
    addpath([dkepath.luke_root,'/Project_DKE/Packages/MDCE/GPU']);
end
%
dkepath.temppath = [dkepath.temppathroot,filesep,timeid_jd(clock)];
if isfield(dkepath,'local_root'),
    local_root = dkepath.local_root;
else
    local_root = dkepath.luke_root;
end
%
% Matrix inversion tests
%
disp(' ');disp(['Matrix size: (',int2str(length(MMXR_t)),'x',int2str(length(MMXR_t)),')']);disp(' ');disp('---------------------------------------------------------------')
%
% MatLab built-in solvers
%
ipass = 0;
%
ilu_param.type = 'crout';%equivalent to old matlab function luinc
ilu_param.droptol = 1e-6;
ilu_param.milu = 'row';
%
if mode < 2,%not too large matrices for GPU tests and direct matrix inversions
    if GPUstatus.DeviceSupported && gpu_mode,
        MMXPC_f_t_full = single(full(MMXPC_f_t));%full matrix for GPU tests (single for memory limitations)
        MMXR_t_full = single(full(MMXR_t));
    else
        MMXPC_f_t_full = full(MMXPC_f_t);%full matrix for GPU tests
        MMXR_t_full = full(MMXR_t);
    end
end
%
while ipass < npass,
    %
    isim = 0;  
    %
    % Direct methods
    %
    isim = isim + 1;disp('- MATLAB-Direct inversion (\) by CPU with sparse matrix'),tic,MMXS_t = MMXPC_f_t\MMXR_t;t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion']);
    Zname{isim} = ['MATLAB_DIRECT_INVERSION'];
    %
    if mode < 2,%not too large matrices for GPU tests and direct matrix inversions
        isim = isim + 1;
        if GPUstatus.DeviceSupported && gpu_mode,
            disp('- MATLAB-Direct inversion (\) by CPU with full matrix (single precision)'),
            tic,MMXS_t_full = invmatGPU(MMXPC_f_t_full,MMXR_t_full);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion']);
            Zname{isim} = ['MATLAB_DIRECT_INVERSION_FULL_MATRIX_SINGLE'];
        else
            disp('- MATLAB-Direct inversion (\) by CPU with full matrix'),
            tic,MMXS_t_full = MMXPC_f_t_full\MMXR_t_full;t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion']);
            Zname{isim} = ['MATLAB_DIRECT_INVERSION_FULL_MATRIX'];
        end
        %
        if GPUstatus.DeviceSupported && gpu_mode,
            isim = isim + 1;tic,dummy = gather(invmatGPU(gpuArray(rand(2,2,'single')),gpuArray(rand(2,1,'single'))));t(isim) = toc;%GPU initialisation
            Zname{isim} = ['MATLAB_GPU_INITIALISATION'];
            disp('- MATLAB-Direct inversion (\) by GPU with full matrix'),
            isim = isim + 1;tic,MMXS_t_full_GPU = gather(invmatGPU(gpuArray(MMXPC_f_t_full),gpuArray(MMXR_t_full)));t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + GPU initialisation (once): ',num2str(t(isim-1)),' seconds.']);
            Zname{isim} = ['MATLAB_DIRECT_GPU_INVERSION_FULL_MATRIX_SINGLE'];
            %
            rmpath([dkepath.luke_root,'/Project_DKE/Packages/MDCE/GPU']);
        end
    end
    %
    disp('---------------------------------------------------------------')
    %
    % Iterative methods
    %
    isim = isim + 1;disp('- MATLAB-ILU by CPU with sparse matrix (drop_tol = 1e-6)'),tic,[MMXL_f_t,MMXU_f_t] = ilu(MMXPC_f_t,ilu_param);t(isim) = toc;
    Zname{isim} = ['MATLAB_LU_FACTORISATION'];
    isim = isim + 1;disp('- MATLAB-CGS by CPU with sparse matrix'),tic,[MMXS_t_cgs,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(isim-1)),' seconds.']);
    ZMMXS_t{isim} = MMXS_t_cgs;
    Zname{isim} = ['MATLAB_GCS'];
    isim = isim + 1;disp('- MATLAB-BICG by CPU with sparse matrix'),tic,[MMXS_t_bicg,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(isim-2)),' seconds.']);
    ZMMXS_t{isim} = MMXS_t_bicg;
    Zname{isim} = ['MATLAB_BICG'];
    isim = isim + 1;disp('- MATLAB-QMR by CPU with sparse matrix'),tic,[MMXS_t_qmr,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(isim-3)),' seconds.']);
    ZMMXS_t{isim} = MMXS_t_qmr;
    Zname{isim} = ['MATLAB_QMR'];    
    disp('---------------------------------------------------------------')
%
% MUMPS solver
%
% MUMPS packages (MEX application)
%
    MUMPSDIRS = {[local_root,'Packages/Bin/MUMPS/'],local_root};
    MUMPSDIR = '';
    for idir = 1:length(MUMPSDIRS),
        if exist(MUMPSDIRS{idir},'dir'),
            MUMPSDIR = MUMPSDIRS{idir};
            break
        end
    end
    %
    if ~isempty(MUMPSDIR) & MUMPS,
        list_of_packages = dir(MUMPSDIR);
        for ifile = 1:length(list_of_packages),
            if length(list_of_packages(ifile).name) >= 5 && strcmp(list_of_packages(ifile).name(1:5),'MUMPS') && ~isempty(strfind(list_of_packages(ifile).name,'_S_')),
                MUMPSMATLAB =[MUMPSDIR,list_of_packages(ifile).name,filesep,'MATLAB',matver,filesep];
                if exist(MUMPSMATLAB,'dir') && exist([MUMPSMATLAB,'dmumpsmex.',mexext],'file'),
                    addpath(MUMPSMATLAB)
                    isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-ILU (MEX) by CPU with sparse matrix']),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t(isim) = toc;
                    Zname{isim} = ['MEX_',list_of_packages(ifile).name,'_LU_FACTORISATION by CPU with sparse matrix'];
                    isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-SOLVE (MEX) by CPU with sparse matrix']),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t(isim) = toc;MMXS_t_MUMPS = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(isim-1)),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = ['MEX_',list_of_packages(ifile).name];
                    rmpath(MUMPSMATLAB)  
                end    
            end
        end
    end
%
    disp('---------------------------------------------------------------')
%
% MUMPS packages (stand-alone application)
%
    if exist([local_root,'Packages/Bin/MUMPS']) & MUMPS,
        list_of_packages = dir([local_root,'Packages/Bin/MUMPS']);
        for ifile = 1:length(list_of_packages),
            if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'MUMPS',
%
% Sequential processing (stand-alone application)
%
                if ~isempty(strfind(list_of_packages(ifile).name,'_S_'))
                    dkepath.MUMPS.seq = [local_root,'Packages/Bin/MUMPS/',list_of_packages(ifile).name,'/dke'];
                    if isfield(dkepath.MUMPS,'par'),rmfield(dkepath.MUMPS,'par');end
                    if exist(dkepath.MUMPS.seq),  
                        try
                            isim = isim + 1;disp(['- ',list_of_packages(ifile).name,' by CPU with sparse matrix (sequential processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);  
                        catch
                            MMXS_t_MUMPS = [];
                        end
                        ZMMXS_t{isim} = MMXS_t_MUMPS;
                        Zname{isim} = list_of_packages(ifile).name;
                        clear MMXS_t_MUMPS
                    end
                end
%
% Parallel processing (stand-alone application)
%
                if ~isempty(strfind(list_of_packages(ifile).name,'_P_'))
                    dkepath.MUMPS.par = [local_root,'Packages/Bin/MUMPS/',list_of_packages(ifile).name,'/dke'];
                    if isfield(dkepath.MUMPS,'seq'),rmfield(dkepath.MUMPS,'seq');end
                    if exist(dkepath.MUMPS.par),                                   
                        dkeparam.MUMPSparam.nproc = 4;%case with 4 processors
                        isim = isim + 1;disp(['- ',list_of_packages(ifile).name,', np = 4 (parallel processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_MUMPS;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_4'];
                    %
                        dkeparam.MUMPSparam.nproc = 1;%case with 1 processor
                        isim = isim + 1;disp(['- ',list_of_packages(ifile).name,', np = 1 (parallel processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_MUMPS;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_1'];
                    end
                end
            end
        end
    end           
    disp('---------------------------------------------------------------')
%
% PETSc packages (stand-alone application)
%
    if exist([local_root,'Packages/Bin/PETSC']) & PETSC,
        list_of_packages = dir([local_root,'Packages/Bin/PETSC']);
        for ifile = 1:length(list_of_packages),   
            if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'petsc',

%
% Sequential processing (stand-alone application)
%
                if ~isempty(strfind(list_of_packages(ifile).name,'_S_'))
                    dkepath.PETSc.seq = [local_root,'Packages/Bin/PETSC/',list_of_packages(ifile).name,'/DKE'];
                    if isfield(dkepath.PETSc,'par'),rmfield(dkepath.PETSc,'par');end
                    if exist(dkepath.PETSc.seq),
                        dkeparam.PETScparam.nproc = 1;%case with 1 processor
                        dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                        dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                        dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                        dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
                        isim = isim + 1;disp(['- ',list_of_packages(ifile).name,' bcgs (sequential processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_PETSc;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_1_bgcs_Mloop'];
                    end
                end
%
% Parallel processing (stand-alone application)
%
                if ~isempty(strfind(list_of_packages(ifile).name,'_P_'))
                    dkepath.PETSc.par = [local_root,'Packages/Bin/PETSC/',list_of_packages(ifile).name,'/DKE'];
                    if isfield(dkepath.PETSc,'seq'),rmfield(dkepath.PETSc,'seq');end
                    if exist(dkepath.PETSc.par),
                        dkeparam.PETScparam.nproc = 4;%case with 4 processors
                        dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                        dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                        dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                        dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                                       
                        isim = isim + 1;disp(['- ',list_of_packages(ifile).name,', np = 4 bcgs (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_PETSc;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_4_bgcs_Mloop'];
                    %
                        dkeparam.PETScparam.nproc = 1;%case with 1 processor
                        dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                        dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                        dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                        dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                   
                        isim = isim + 1;disp(['- ',list_of_packages(ifile).name,', np = 1 bcgs (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_PETSc;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_1_bgcs_Mloop'];
%
                        [flag,message] = unix('uname -n');
                        if strfind(message,'saturne'),%this option runs only on the SATURNE CEA-DRFC cluster
                            dkeparam.PETScparam.nproc = 1;%case with 1 processor
                            dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                            dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                            dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                            dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                   
                            isim = isim + 1;disp(['- ',list_of_packages(ifile).name,', np = 1 superlu_dist (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                            ZMMXS_t{isim} = MMXS_t_PETSc;
                            Zname{isim} = [list_of_packages(ifile).name,'_np_1_superludist_Mloop'];
%
                            dkeparam.PETScparam.nproc = 4;%case with 1 processor
                            dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                            dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                            dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                            dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                   
                            isim = isim + 1;disp(['- ',list_of_packages(ifile).name,', np = 4 superlu_dist (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                            ZMMXS_t{isim} = MMXS_t_PETSc;
                            Zname{isim} = [list_of_packages(ifile).name,'_np_4_superludist_Mloop'];
                        end
                    end
                end
            end
        end
    end           
    disp('---------------------------------------------------------------')  
%
% SUPERLU packages (MEX application)
%
    if exist([local_root,'Packages/Bin/SUPERLU']) & SUPERLU,
        list_of_packages = dir([local_root,'Packages/Bin/SUPERLU']);
        list_of_packages = dir([local_root,'Packages/Bin/SUPERLU']);
        for ifile = 1:length(list_of_packages),   
            if length(list_of_packages(ifile).name) >= 7 
                if list_of_packages(ifile).name(1:7) == 'SuperLU',
                    dkepath.SUPERLU.mex = [local_root,'Packages/Bin/SUPERLU/',list_of_packages(ifile).name,'/MATLAB',matver];
                    if exist(dkepath.SUPERLU.mex),
                        addpath(dkepath.SUPERLU.mex)
                        if exist('mexlusolve');isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-SOLVE (MEX)']),tic,[MMXS_t_SUPERLU] = lusolve(MMXPC_f_t,MMXR_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);end
                        ZMMXS_t{isim} = MMXS_t_SUPERLU;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_1_SUPERLUMEX'];  
                        rmpath(dkepath.SUPERLU.mex)   
                    end
                end
            end
        end
    end
%  
    disp('---------------------------------------------------------------')  
%
% PARDISO packages (MEX application)
%
    if exist([local_root,'Packages/Bin/PARDISO']) & PARDISO,
        list_of_packages = dir([local_root,'Packages/Bin/PARDISO']);
        for ifile = 1:length(list_of_packages),
            if strfind(list_of_packages(ifile).name,'PARDISO'),
                dkepath.PARDISO.mex = [local_root,'Packages/Bin/PARDISO/',list_of_packages(ifile).name,'/MATLAB',matver];
                if exist([dkepath.PARDISO.mex,filesep,'pardisosolve.',mexext]),
                    addpath(dkepath.PARDISO.mex);
                    isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-ILU (MEX) by CPU with sparse matrix']),tic,job_PARDISOMEX = 1;PARDISOMEX_dke_yp;job_PARDISOMEX = 2;PARDISOMEX_dke_yp;t(isim) = toc;
                    Zname{isim} = ['MEX_',list_of_packages(ifile).name,'_LU_FACTORISATION by CPU with sparse matrix'];
                    isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-SOLVE (MEX) by CPU with sparse matrix']),tic,job_PARDISOMEX = 3;PARDISOMEX_dke_yp;t(isim) = toc;MMXS_t_PARDISO = X_PARDISOMEX;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(isim-1)),' seconds.']);job_PARDISOMEX = -2;PARDISOMEX_dke_yp;
                    ZMMXS_t{isim} = MMXS_t_PARDISO;
                    Zname{isim} = ['MEX_',list_of_packages(ifile).name];  
                end 
                rmpath(dkepath.PARDISO.mex);
            end
        end
    end
    %
    ipass = ipass + 1;
    for ii = 1:isim
        tt(ipass,ii) = t(ii);
    end
end
%
if mode==0, dirfig = 'figures/2D/';end
if mode>=1, dirfig = 'figures/3D/';end
%
if npass > 1,
    meantt = mean(tt);%Mean value on several runs
    stdtt = std(tt);%Standard deviation on several runs
%
    for iisim = 1:isim,
        figure('Name',Zname{iisim}),graph1D_jd([1:npass],tt(:,iisim),0,0,'Number of passes','Computing time (s)',[strrep(Zname{iisim},'_','-'),' on ',computer],[num2str(meantt(iisim)),'(s) +/- ',num2str(stdtt(iisim))],[1,npass],[0,2*max(tt(:,iisim))],'-','non','r',2,20,gca,0.85,0.7,0.5);hold on    
        savefig_dke_yp(Zname{iisim},dirfig);
    end
end
%
for iisim = 1:isim,
    if ~isempty(ZMMXS_t{iisim})
        figure('Name',Zname{iisim}),graph1D_jd([1:length(ZMMXS_t{iisim})],ZMMXS_t{iisim},0,0,'Vector index','Vector coefficient',[strrep(Zname{iisim},'_','-'),' on ',computer],NaN,'','','-','non','r',1,20,gca,0.85,0.7,0.5);hold on    
        savefig_dke_yp(Zname{iisim},dirfig);
    end
end
%
diary off
%
cd(dirinit);%back to the initial directory
%