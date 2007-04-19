clc
clear all
close all
%
disp('Test performances of matrix inversion routines on your computer')
disp('---------------------------------------------------------------')
mode = input_dke_yp('2-D (0) or 3-D (1) input matrix ?',0);disp(' ');
if mode ==0,
   load testLU2D.mat;delete testmatinv-2D;diary testmatinv-2D;disp(['2-D LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
elseif mode == 1
   load testLU3D.mat;delete testmatinv-3D;diary testmatinv-3D;disp(['3-D LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
end
%
dkepath = path_LUKE_LOCAL;
dkepath.temppath = pwd;
luke_root = dkepath.luke_root;
%
% Tests
%
disp(' ');disp(['Matrix size: (',int2str(length(MMXR_t)),'x',int2str(length(MMXR_t)),')']);disp(' ');disp('--------------------------------------')
%
% MatLab built-in solvers
%
disp('- MATLAB-ILU'),tic,[MMXL_f_t_test,MMXU_f_t_test] = luinc(MMXPC_f_t,1e-4);t_ilumatlab = toc;
disp('- MATLAB-CGS'),tic,[MMXS_t_cgs,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_cgs = toc;disp(['Elapsed time is ',num2str(t_cgs),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB-BICG'),tic,[MMXS_t_bicg,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_bicg = toc;disp(['Elapsed time is ',num2str(t_bicg),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB-QMR'),tic,[MMXS_t_qmr,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_qmr = toc;disp(['Elapsed time is ',num2str(t_qmr),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('--------------------------------------')
%
% MUMPS solver
%
isim = 0;
%
% MUMPS packages (MEX application)
%
if exist([luke_root,'Packages']),
    list_of_packages = dir([luke_root,'Packages']);
    for ifile = 1:length(list_of_packages),
        if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'MUMPS' & ~isempty(strfind(list_of_packages(ifile).name,'_S_')),
            dkepath.MUMPS.mex = [luke_root,'Packages/',list_of_packages(ifile).name,'/MATLAB'];
            if exist(dkepath.MUMPS.mex),
                addpath(dkepath.MUMPS.mex)
                isim = isim + 1;
                disp(['- ',list_of_packages(ifile).name,'-ILU (MEX)']),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;
				disp(['- ',list_of_packages(ifile).name,'-SOLVE (MEX)']),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPS = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;
                ZMMXS_t{isim} = MMXS_t_MUMPS;
                Zname{isim} = ['MEX_',list_of_packages(ifile).name];
                rmpath(dkepath.MUMPS.mex)  
            end    
        end
    end
end
%
disp('--------------------------------------')
%
% MUMPS packages (stand-alone application)
%
if exist([luke_root,'Packages']),
    list_of_packages = dir([luke_root,'Packages']);
    for ifile = 1:length(list_of_packages),
        if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'MUMPS',
%
% Sequential processing (stand-alone application)
%
            if ~isempty(strfind(list_of_packages(ifile).name,'_S_'))
                dkepath.MUMPS.seq = [luke_root,'Packages/',list_of_packages(ifile).name,'/dke'];
                if isfield(dkepath.MUMPS,'par'),rmfield(dkepath.MUMPS,'par');end
                if exist(dkepath.MUMPS.seq),                    
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,' (sequential processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps = toc;disp(['Elapsed time is ',num2str(t_mumps),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = list_of_packages(ifile).name;
                end
            end
%
% Parallel processing (stand-alone application)
%
            if ~isempty(strfind(list_of_packages(ifile).name,'_P_'))
                dkepath.MUMPS.par = [luke_root,'Packages/',list_of_packages(ifile).name,'/dke'];
                if isfield(dkepath.MUMPS,'seq'),rmfield(dkepath.MUMPS,'seq');end
                if exist(dkepath.MUMPS.par),                                   
                    dkeparam.MUMPSparam.nproc = 4;%case with 4 processors
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,', np = 4 (parallel processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps = toc;disp(['Elapsed time is ',num2str(t_mumps),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_4'];
                    %
                    dkeparam.MUMPSparam.nproc = 1;%case with 1 processor
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,', np = 1 (parallel processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps = toc;disp(['Elapsed time is ',num2str(t_mumps),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_1'];
                end
            end
        end
    end
end           
disp('--------------------------------------')           
%
% PETSc packages (stand-alone application)
%
if exist([luke_root,'Packages']),
    list_of_packages = dir([luke_root,'Packages']);
    for ifile = 1:length(list_of_packages),   
        if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'petsc',

%
% Sequential processing (stand-alone application)
%
            if ~isempty(strfind(list_of_packages(ifile).name,'_S_'))
                dkepath.PETSc.seq = [luke_root,'Packages/',list_of_packages(ifile).name,'/DKE'];
                if isfield(dkepath.PETSc,'par'),rmfield(dkepath.PETSc,'par');end
                if exist(dkepath.PETSc.seq),
                    dkeparam.PETScparam.nproc = 1;%case with 1 processor
                    dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                    dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                    dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                    dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,' bcgs (sequential processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = MUMPS_dke_yp(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_petsc = toc;disp(['Elapsed time is ',num2str(t_petsc),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_PETSc;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_1_bgcs_Mloop'];
                end
            end
%
% Parallel processing (stand-alone application)
%
            if ~isempty(strfind(list_of_packages(ifile).name,'_P_'))
                dkepath.PETSc.par = [luke_root,'Packages/',list_of_packages(ifile).name,'/DKE'];
                if isfield(dkepath.PETSc,'seq'),rmfield(dkepath.PETSc,'seq');end
                if exist(dkepath.PETSc.par),
                    dkeparam.PETScparam.nproc = 4;%case with 4 processors
                    dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                    dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                    dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                    dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                                       
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,', np = 4 bcgs (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_yp(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_petsc = toc;disp(['Elapsed time is ',num2str(t_petsc),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_PETSc;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_4_bgcs_Mloop'];
                    %
                    dkeparam.PETScparam.nproc = 1;%case with 1 processor
                    dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                    dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                    dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                    dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                   
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,', np = 1 bcgs (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_yp(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_petsc = toc;disp(['Elapsed time is ',num2str(t_petsc),' seconds.']);
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
                        isim = isim + 1;
                        disp(['- ',list_of_packages(ifile).name,', np = 1 superlu_dist (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_yp(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_petsc = toc;disp(['Elapsed time is ',num2str(t_petsc),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_PETSc;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_1_superludist_Mloop'];
%
                        dkeparam.PETScparam.nproc = 4;%case with 1 processor
                        dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
                        dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
                        dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation                
                        dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)                   
                        isim = isim + 1;
                        disp(['- ',list_of_packages(ifile).name,', np = 4 superlu_dist (parallel processing, stand-alone application)']),tic,[MMXS_t_PETSc,flaginv_f] = PETSc_dke_yp(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_petsc = toc;disp(['Elapsed time is ',num2str(t_petsc),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_PETSc;
                        Zname{isim} = [list_of_packages(ifile).name,'_np_4_superludist_Mloop'];

                    end
                end
            end
        end
    end
end           
disp('--------------------------------------')           
%
% SUPERLU packages (MEX application)
%
if exist([luke_root,'Packages']),
    list_of_packages = dir([luke_root,'Packages']);
    for ifile = 1:length(list_of_packages),   
        if length(list_of_packages(ifile).name) >= 7 
            if list_of_packages(ifile).name(1:7) == 'SuperLU',
                dkepath.SUPERLU.mex = [luke_root,'Packages/',list_of_packages(ifile).name,'/MATLAB'];
                if exist(dkepath.SUPERLU.mex),
                    addpath(dkepath.SUPERLU.mex)
                    if exist('mexlusolve');isim = isim + 1;disp('- SUPERLU (MEX)'),tic,[MMXS_t_SUPERLU] = lusolve(MMXPC_f_t,MMXR_t);t_slu = toc;disp(['Elapsed time is ',num2str(t_slu),' seconds.']);end
                    ZMMXS_t{isim} = MMXS_t_SUPERLU;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_1_SUPERLUMEX'];  
                    rmpath(dkepath.SUPERLU.mex)   
                end
            end
        end
    end
end 
%
figure('Name','MATLAB-CGS'),plot(MMXS_t_cgs),title(['MATLAB-CGS on ',computer])
figure('Name','MATLAB-BICG'),plot(MMXS_t_bicg),title(['MATLAB-BICG on ',computer])
figure('Name','MATLAB-QMR'),plot(MMXS_t_qmr),title(['MATLAB-QMR on ',computer])
%
for iisim = 1:isim,
    figure('Name',Zname{iisim}),plot(ZMMXS_t{isim}),title([Zname{iisim},' on ',computer]);
end
%
diary off

