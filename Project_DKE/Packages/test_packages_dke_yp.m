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
if strcmp(computer,'MAC'),load ../Database/PATH_files/PATH_LAPTOP_YVES.mat,dkepath.temppath = '/tmp';end
if strcmp(computer,'GLNXA64'),load ../Database/PATH_files/PATH_PC_DRFC_YVES.mat,dkepath.temppath = '/scratch';end
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
% 4.6.4 release
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_absoft/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_4.6.4_S_ABSOFT'),tic,[MMXS_t_MUMPS_464_S_ABSOFT,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_absoft = toc;disp(['Elapsed time is ',num2str(t_mumps_s_absoft),' seconds.']);end
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_g95/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_4.6.4_S_G95'),tic,[MMXS_t_MUMPS_464_S_G95,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_g95 = toc;disp(['Elapsed time is ',num2str(t_mumps_s_g95),' seconds.']);end
dkeparam.MUMPSparam.nproc = 4;
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_P_pgf/dke'];   
if exist(dkepath.MUMPS),disp('- MUMPS_4.6.4_P_PGF90 (4 processors)'),tic,[MMXS_t_MUMPS_464_P_PGF90_4P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_p_pgf90_4p = toc;disp(['Elapsed time is ',num2str(t_mumps_p_pgf90_4p),' seconds.']);end
dkeparam.MUMPSparam.nproc = 1;
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_P_pgf/dke'];   
if exist(dkepath.MUMPS),disp('- MUMPS_4.6.4_P_PGF90 (1 processor)'),tic,[MMXS_t_MUMPS_464_P_PGF90_1P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_p_pgf90_1p = toc;disp(['Elapsed time is ',num2str(t_mumps_p_pgf90_1p),' seconds.']);end
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_pgf/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_4.6.4_S_PGF90'),tic,[MMXS_t_MUMPS_464_S_PGF90,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_pgf90 = toc;disp(['Elapsed time is ',num2str(t_mumps_s_pgf90),' seconds.']);end
%
cdold = cd;
cdnew = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_g95/MATLAB'];
if exist(cdnew),
   cd(cdnew);
   if exist('dmumpsmex');disp('- MUMPSMEX_4.6.4-ILU'),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;;disp(['Elapsed time is ',num2str(t_ilumumpsmex),' seconds.']);end
   if exist('dmumpsmex');disp('- MUMPSMEX_4.6.4-SOLVE'),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPSMEX_464_g95 = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;end
end
cdnew = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_pgf/MATLAB'];
if exist(cdnew),
   cd(cdnew);
   if exist('dmumpsmex');disp('- MUMPSMEX_4.6.4-ILU'),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;;disp(['Elapsed time is ',num2str(t_ilumumpsmex),' seconds.']);end
   if exist('dmumpsmex');disp('- MUMPSMEX_4.6.4-SOLVE'),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPSMEX_464_pgf = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;end
end
cd(cdold);
%
% 4.7.0 release
%
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.7.0_S_absoft/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_4.7.0_S_ABSOFT'),tic,[MMXS_t_MUMPS_470_S_ABSOFT,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_absoft = toc;disp(['Elapsed time is ',num2str(t_mumps_s_absoft),' seconds.']);end
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_g95/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_4.7.0_S_G95'),tic,[MMXS_t_MUMPS_470_S_G95,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_g95 = toc;disp(['Elapsed time is ',num2str(t_mumps_s_g95),' seconds.']);end
dkeparam.MUMPSparam.nproc = 4;
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.7.0_P_pgf/dke'];   
if exist(dkepath.MUMPS),disp('- MUMPS_4.7.0_P_PGF90 (4 processors)'),tic,[MMXS_t_MUMPS_470_P_PGF90_4P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_p_pgf90_4p = toc;disp(['Elapsed time is ',num2str(t_mumps_p_pgf90_4p),' seconds.']);end
dkeparam.MUMPSparam.nproc = 1;
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.7.0_P_pgf/dke'];   
if exist(dkepath.MUMPS),disp('- MUMPS_4.7.0_P_PGF90 (1 processor)'),tic,[MMXS_t_MUMPS_470_P_PGF90_1P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_p_pgf90_1p = toc;disp(['Elapsed time is ',num2str(t_mumps_p_pgf90_1p),' seconds.']);end
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_pgf/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_4.7.0_S_PGF90'),tic,[MMXS_t_MUMPS_470_S_PGF90,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_pgf90 = toc;disp(['Elapsed time is ',num2str(t_mumps_s_pgf90),' seconds.']);end
%
cdold = cd;
%
cdnew = [dkepath.luke_root,'Packages/MUMPS_4.7.0_S_g95/MATLAB'];
if exist(cdnew),
   cd(cdnew);
   if exist('dmumpsmex');disp('- MUMPSMEX_4.7.0-ILU'),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;;disp(['Elapsed time is ',num2str(t_ilumumpsmex),' seconds.']);end
   if exist('dmumpsmex');disp('- MUMPSMEX_4.7.0-SOLVE'),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPSMEX_470_g95 = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;end
end
cdnew = [dkepath.luke_root,'Packages/MUMPS_4.7.0_S_pgf/MATLAB'];
if exist(cdnew),
   cd(cdnew);
   if exist('dmumpsmex');disp('- MUMPSMEX_4.7.0-ILU'),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;;disp(['Elapsed time is ',num2str(t_ilumumpsmex),' seconds.']);end
   if exist('dmumpsmex');disp('- MUMPSMEX_4.7.0-SOLVE'),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPSMEX_470_pgf = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;end
end
%
cd(cdold);
disp('-------------------')
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
if exist('MMXS_t_MUMPS_464_S_ABSOFT'),figure('Name','MUMPS_4.6.4-ABSOFT-SEQ'),plot(MMXS_t_MUMPS_464_S_ABSOFT),title(['MUMPS-ABSOFT-SEQ on ',computer]);end
if exist('MMXS_t_MUMPS_464_S_G95'),figure('Name','MUMPS_4.6.4-G95-SEQ'),plot(MMXS_t_MUMPS_464_S_G95),title(['MUMPS-G95-SEQ on ',computer]);end
if exist('MMXS_t_MUMPS_464_P_PGF90_4P'),figure('Name','MUMPS_4.6.4-PGF90-PAR'),plot(MMXS_t_MUMPS_464_P_PGF90_4P),title(['MUMPS-PGF90-PAR (4 procs) on ',computer]);end
if exist('MMXS_t_MUMPS_464_P_PGF90_1P'),figure('Name','MUMPS_4.6.4-PGF90-PAR'),plot(MMXS_t_MUMPS_464_P_PGF90_1P),title(['MUMPS-PGF90-PAR (1 proc) on ',computer]);end
if exist('MMXS_t_MUMPS_464_S_PGF90'),figure('Name','MUMPS_4.6.4-PGF90-SEQ'),plot(MMXS_t_MUMPS_464_S_PGF90),title(['MUMPS-PGF90-SEQ on ',computer]);end
%
if exist('MMXS_t_MUMPS_470_S_ABSOFT'),figure('Name','MUMPS_4.7.0-ABSOFT-SEQ'),plot(MMXS_t_MUMPS_470_S_ABSOFT),title(['MUMPS-ABSOFT-SEQ on ',computer]);end
if exist('MMXS_t_MUMPS_470_S_G95'),figure('Name','MUMPS_4.7.0-G95-SEQ'),plot(MMXS_t_MUMPS_470_S_G95),title(['MUMPS-G95-SEQ on ',computer]);end
if exist('MMXS_t_MUMPS_470_P_PGF90_4P'),figure('Name','MUMPS_4.7.0-PGF90-PAR'),plot(MMXS_t_MUMPS_470_P_PGF90_4P),title(['MUMPS-PGF90-PAR (4 procs) on ',computer]);end
if exist('MMXS_t_MUMPS_470_P_PGF90_1P'),figure('Name','MUMPS_4.7.0-PGF90-PAR'),plot(MMXS_t_MUMPS_470_P_PGF90_1P),title(['MUMPS-PGF90-PAR (1 proc) on ',computer]);end
if exist('MMXS_t_MUMPS_470_S_PGF90'),figure('Name','MUMPS_4.7.0-PGF90-SEQ'),plot(MMXS_t_MUMPS_470_S_PGF90),title(['MUMPS-PGF90-SEQ on ',computer]);end
%
if exist('MMXS_t_PETSC_232p8_BCGS_1P'),figure('Name','PETSC_2.3.2-p8_BCGS_1P'),plot(MMXS_t_PETSC_232p8_BCGS_1P),title(['PETSC_BCGS_1P on ',computer]);end
if exist('MMXS_t_PETSC_232p8_SUPELUDIST_1P'),figure('Name','PETSC_2.3.2-p8_SUPELUDIST_1P'),plot(MMXS_t_PETSC_232p8_SUPELUDIST_1P),title(['PETSC_SUPELUDIST_1P on ',computer]);end
%
if exist('MMXS_t_MUMPSMEX_464_g95');figure('Name','MEX-MUMPS_4.6.4-G95'),plot(MMXS_t_MUMPSMEX_464_g95),title(['MEX-MUMPS_4.6.4-G95 on ',computer]);end
if exist('MMXS_t_MUMPSMEX_464_pgf');figure('Name','MEX-MUMPS_4.6.4-PGF'),plot(MMXS_t_MUMPSMEX_464_pgf),title(['MEX-MUMPS_4.6.4-PGF on ',computer]);end
if exist('MMXS_t_MUMPSMEX_470_g95');figure('Name','MEX-MUMPS_4.6.4-G95'),plot(MMXS_t_MUMPSMEX_470_g95),title(['MEX-MUMPS_4.7.0-G95 on ',computer]);end
if exist('MMXS_t_MUMPSMEX_470_pgf');figure('Name','MEX-MUMPS_4.7.0-PGF'),plot(MMXS_t_MUMPSMEX_470_pgf),title(['MEX-MUMPS_4.7.0-PGF on ',computer]);end
%
if exist('mexlusolve');figure('Name','MEX-SUPERLU_3.0'),plot(MMXS_t_SUPERLU),title(['MEX-SUPERLU on ',computer]);end
diary off

