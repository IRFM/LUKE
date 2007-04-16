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
%
luke_root = dkepath.luke_root;
%
% Tests
%
disp(['Matrix size:',int2str(length(MMXR_t)),'x',int2str(length(MMXR_t))]);
disp(' ');
disp('-------------------')
%
% MatLab built-in solvers
%
disp('- MATLAB-ILU'),tic,[MMXL_f_t_test,MMXU_f_t_test] = luinc(MMXPC_f_t,1e-4);t_ilumatlab = toc;disp(['Elapsed time is ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB_CGS'),tic,[MMXS_t_cgs,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_cgs = toc;disp(['Elapsed time is ',num2str(t_cgs),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB_BICG'),tic,[MMXS_t_bicg,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_bicg = toc;disp(['Elapsed time is ',num2str(t_bicg),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB_QMR'),tic,[MMXS_t_qmr,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_qmr = toc;disp(['Elapsed time is ',num2str(t_qmr),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('-------------------')
%
% MUMPS solver
%
isim = 0;
%
% MUMPSMEX packages
%
if exist([luke_root,'Packages']),
    list_of_packages = dir([luke_root,'Packages']);
    for ifile = 1:length(list_of_packages),
        if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'MUMPS' & ~isempty(strfind(list_of_packages(ifile).name,'_S_')),
            dkepath.MUMPSMEX = [luke_root,'Packages/',list_of_packages(ifile).name,'/MATLAB'];
            addpath(dkepath.MUMPSMEX)
            if exist(dkepath.MUMPSMEX),
                isim = isim + 1;
                disp(['- ',list_of_packages(ifile).name,'-ILU']),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;
				disp(['- ',list_of_packages(ifile).name,'-SOLVE']),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPS = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;
                ZMMXS_t{isim} = MMXS_t_MUMPS;
                Zname{isim} = ['MEX_',list_of_packages(ifile).name];
            end
            rmpath(dkepath.MUMPSMEX)
        end
    end
end
%
disp('-------------------')
%
if exist([luke_root,'Packages']),
    list_of_packages = dir([luke_root,'Packages']);
    for ifile = 1:length(list_of_packages),
        %
        % MUMPS packages
        %
        if length(list_of_packages(ifile).name) >= 5 & list_of_packages(ifile).name(1:5) == 'MUMPS',
            dkepath.MUMPS = [luke_root,'Packages/',list_of_packages(ifile).name,'/dke'];
            if exist(dkepath.MUMPS),
                %
                % MUMPS sequenciel
                %
                if ~isempty(strfind(list_of_packages(ifile).name,'_S_'))
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name]),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps = toc;disp(['Elapsed time is ',num2str(t_mumps),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = list_of_packages(ifile).name;
                end
                %
                % MUMPS parallel
                %
                if ~isempty(strfind(list_of_packages(ifile).name,'_P_'))
                    dkeparam.MUMPSparam.nproc = 4;%case with 4 processors
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,', np = 4']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps = toc;disp(['Elapsed time is ',num2str(t_mumps),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_4'];
                    %
                    dkeparam.MUMPSparam.nproc = 1;%case with 1 processor
                    isim = isim + 1;
                    disp(['- ',list_of_packages(ifile).name,', np = 1']),tic,[MMXS_t_MUMPS,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps = toc;disp(['Elapsed time is ',num2str(t_mumps),' seconds.']);
                    ZMMXS_t{isim} = MMXS_t_MUMPS;
                    Zname{isim} = [list_of_packages(ifile).name,'_np_1'];                    
                end
            end
        end
    end
end
%
%
%PETSc
%  
% 2.3.2-p8 release
dkepath.PETSC = [dkepath.luke_root,'Packages/petsc-2.3.2-p8'];
dkeparam.invproc = -30;%Number of processors
dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation 
dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
if exist(dkepath.PETSC),disp('- PETSc_2.3.2-p8-PGF90-BCGS (1 processor)'),tic,[MMXS_t_PETSC_232p8_BCGS_1P,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),display_mode,dkepath);t_petsc_bcgs_1p = toc;disp(['Elapsed time is ',num2str(t_petsc_bcgs_1p),' seconds.']);end
%
dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
if exist(dkepath.PETSC),disp('- PETSc_2.3.2-p8-PGF90-SUPERLUDIST (1 processor)'),tic,[MMXS_t_PETSC_232p8_SUPELUDIST_1P,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),display_mode,dkepath);t_petsc_superludist_1p = toc;disp(['Elapsed time is ',num2str(t_petsc_superludist_1p),' seconds.']);end
disp('-------------------')
%
% SUPERLU
%
% 3.0 release
%
if exist('mexlusolve');disp('- MEX-SUPERLU'),tic,[MMXS_t_SUPERLU] = lusolve(MMXPC_f_t,MMXR_t);t_slu = toc;disp(['Elapsed time is ',num2str(t_slu),' seconds.']);end
disp('-------------------')
%
figure('Name','MATLAB-CGS'),plot(MMXS_t_cgs),title(['MATLAB-CGS on ',computer])
figure('Name','MATLAB-BICG'),plot(MMXS_t_bicg),title(['MATLAB-BICG on ',computer])
figure('Name','MATLAB-QMR'),plot(MMXS_t_qmr),title(['MATLAB-QMR on ',computer])
%
for iisim = 1:isim,
    figure('Name',Zname{iisim}),plot(ZMMXS_t{isim}),title([Zname{iisim},' on ',computer]);
end
%
if exist('MMXS_t_PETSC_232p8_BCGS_1P'),figure('Name','PETSC_2.3.2-p8_BCGS_1P'),plot(MMXS_t_PETSC_232p8_BCGS_1P),title(['PETSC_BCGS_1P on ',computer]);end
if exist('MMXS_t_PETSC_232p8_SUPELUDIST_1P'),figure('Name','PETSC_2.3.2-p8_SUPELUDIST_1P'),plot(MMXS_t_PETSC_232p8_SUPELUDIST_1P),title(['PETSC_SUPELUDIST_1P on ',computer]);end
%
if exist('mexlusolve');figure('Name','MEX-SUPERLU_3.0'),plot(MMXS_t_SUPERLU),title(['MEX-SUPERLU on ',computer]);end
diary off

