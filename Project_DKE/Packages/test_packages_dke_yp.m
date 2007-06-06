clc
clear all
close all
%
disp('Test performances of matrix inversion routines on your computer')
disp('---------------------------------------------------------------')
mode = input_dke_yp('2-D (0) or 3-D (1) input matrix',0);
npass = input_dke_yp('Number of passes',1);disp(' ');
if mode ==0,
   load testLU2D.mat;if exist('testmatinv-2D'),delete testmatinv-2D;end;diary testmatinv-2D;disp(['2-D LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
elseif mode == 1
   load testLU3D.mat;if exist('testmatinv-3D'),delete testmatinv-3D;end;diary testmatinv-3D;disp(['3-D LUKE matrix inversion performances on ',computer]);disp('----------------------------------------------')
end
%
dkepath = path_LUKE_LOCAL;
dkepath.temppath = [dkepath.temppathroot,filesep,timeid_jd(clock)];
local_root = dkepath.local_root;
%
% Tests
%
disp(' ');disp(['Matrix size: (',int2str(length(MMXR_t)),'x',int2str(length(MMXR_t)),')']);disp(' ');disp('--------------------------------------')
%
% MatLab built-in solvers
%
ipass = 0;
while ipass < npass,
%
    isim = 0;  
%      
    isim = isim + 1;disp('- MATLAB-ILU'),tic,[MMXL_f_t_test,MMXU_f_t_test] = luinc(MMXPC_f_t,1e-4);t(isim) = toc;
    Zname{isim} = ['MATLAB_LU_FACTORISATION'];
    isim = isim + 1;disp('- MATLAB-CGS'),tic,[MMXS_t_cgs,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(1)),' seconds.']);
    ZMMXS_t{isim} = MMXS_t_cgs;
    Zname{isim} = ['MATLAB_GCS'];
    isim = isim + 1;disp('- MATLAB-BICG'),tic,[MMXS_t_bicg,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(1)),' seconds.']);
    ZMMXS_t{isim} = MMXS_t_bicg;
    Zname{isim} = ['MATLAB_BICG'];
    isim = isim + 1;disp('- MATLAB-QMR'),tic,[MMXS_t_qmr,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(1)),' seconds.']);
    ZMMXS_t{isim} = MMXS_t_qmr;
    Zname{isim} = ['MATLAB_QMR'];
    disp('--------------------------------------')
%
% MUMPS solver
%
% MUMPS packages (MEX application)
%
    if exist([local_root,'Packages/Bin/MUMPS']),
        list_of_packages = dir([local_root,'Packages/Bin/MUMPS']);
        for ifile = 1:length(list_of_packages),
            if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'MUMPS' & ~isempty(strfind(list_of_packages(ifile).name,'_S_')),
                dkepath.MUMPS.mex = [local_root,'Packages/Bin/MUMPS/',list_of_packages(ifile).name,'/MATLAB'];
                if exist([dkepath.MUMPS.mex,filesep,'dmumpsmex.',mexext]),
                    addpath(dkepath.MUMPS.mex)
                    isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-ILU (MEX)']),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t(isim) = toc;
                    Zname{isim} = ['MEX_',list_of_packages(ifile).name,'_LU_FACTORISATION'];
                    isim = isim + 1;disp(['- ',list_of_packages(ifile).name,'-SOLVE (MEX)']),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t(isim) = toc;MMXS_t_MUMPS = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t(isim)),' seconds per inversion + ILU time (once): ',num2str(t(isim-1)),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;
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
    if exist([local_root,'Packages/Bin/MUMPS']),
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
                        isim = isim + 1;disp(['- ',list_of_packages(ifile).name,' (sequential processing, stand-alone application)']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t(isim) = toc;disp(['Elapsed time is ',num2str(t(isim)),' seconds.']);
                        ZMMXS_t{isim} = MMXS_t_MUMPS;
                        Zname{isim} = list_of_packages(ifile).name;
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
    disp('--------------------------------------')           
%
% PETSc packages (stand-alone application)
%
    if exist([local_root,'Packages/Bin/PETSC']),
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
    disp('--------------------------------------')   
%
% SUPERLU packages (MEX application)
%
    if exist([local_root,'Packages/Bin/SUPERLU']),
        list_of_packages = dir([local_root,'Packages/Bin/SUPERLU']);
        for ifile = 1:length(list_of_packages),   
            if length(list_of_packages(ifile).name) >= 7 
                if list_of_packages(ifile).name(1:7) == 'SuperLU',
                    dkepath.SUPERLU.mex = [local_root,'Packages/Bin/SUPERLU/',list_of_packages(ifile).name,'/MATLAB'];
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
        figure('Name',Zname{iisim}),graph1D_jd([1:npass],tt(:,iisim),0,0,'Number of passes','Computing time (s)',[strrep(Zname{iisim},'_','-'),' on ',computer],[num2str(meantt(iisim)),'(s) � ',num2str(stdtt(iisim))],[1,npass],[0,2*max(tt(:,iisim))],'-','non','r',2,20,gca,0.85,0.7,0.5);hold on    
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

