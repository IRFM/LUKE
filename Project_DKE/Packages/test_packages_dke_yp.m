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
disp(['Matrix size:',int2str(length(MMXR_t)),'x',int2str(length(MMXR_t))]);
disp(' ');
disp('- MATLAB-ILU'),tic,[MMXL_f_t_test,MMXU_f_t_test] = luinc(MMXPC_f_t,1e-4);t_ilumatlab = toc;disp(['Elapsed time is ',num2str(t_ilumatlab),' seconds.'])
if exist('dmumpsmex');disp('- MUMPS-ILU'),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;;disp(['Elapsed time is ',num2str(t_ilumumpsmex),' seconds.']);end
disp('-------------------')
disp('- MATLAB_CGS'),tic,[MMXS_t_cgs,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_cgs = toc;disp(['Elapsed time is ',num2str(t_cgs),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB_BICG'),tic,[MMXS_t_bicg,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_bicg = toc;disp(['Elapsed time is ',num2str(t_bicg),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB_QMR'),tic,[MMXS_t_qmr,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_qmr = toc;disp(['Elapsed time is ',num2str(t_qmr),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
%
% MUMPS
%
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_absoft/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_S_ABSOFT'),tic,[MMXS_t_MUMPS_S_ABSOFT,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_absoft = toc;disp(['Elapsed time is ',num2str(t_mumps_s_absoft),' seconds.']);end
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_g95/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_S_G95'),tic,[MMXS_t_MUMPS_S_G95,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_g95 = toc;disp(['Elapsed time is ',num2str(t_mumps_s_g95),' seconds.']);end
dkeparam.MUMPSparam.nproc = 4;
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_P_pgf/dke'];   
if exist(dkepath.MUMPS),disp('- MUMPS_P_PGF90 (4 processors)'),tic,[MMXS_t_MUMPS_P_PGF90_4P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_p_pgf90_4p = toc;disp(['Elapsed time is ',num2str(t_mumps_p_pgf90_4p),' seconds.']);end
dkeparam.MUMPSparam.nproc = 1;
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_P_pgf/dke'];   
if exist(dkepath.MUMPS),disp('- MUMPS_P_GF90 (1 processor)'),tic,[MMXS_t_MUMPS_P_PGF90_1P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_p_pgf90_1p = toc;disp(['Elapsed time is ',num2str(t_mumps_p_pgf90_1p),' seconds.']);end
dkepath.MUMPS = [dkepath.luke_root,'Packages/MUMPS_4.6.4_S_pgf/dke'];
if exist(dkepath.MUMPS),disp('- MUMPS_S_PGF90'),tic,[MMXS_t_MUMPS_S_PGF90,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumps_s_pgf90 = toc;disp(['Elapsed time is ',num2str(t_mumps_s_pgf90),' seconds.']);end
%
%PETSc
%   
dkeparam.invproc = -30;%Number of processors
dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation 
dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
if exist(dkepath.MUMPS),disp('- PETSc-PGF90-BCGS (1 processor)'),tic,[MMXS_t_PETSC_BCGS_1P,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),display_mode,dkepath);t_petsc_bcgs_1p = toc;disp(['Elapsed time is ',num2str(t_petsc_bcgs_1p),' seconds.']);end
%
dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
if exist(dkepath.MUMPS),disp('- PETSc-PGF90-SUPERLUDIST (1 processor)'),tic,[MMXS_t_PETSC_SUPELUDIST_1P,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),display_mode,dkepath);t_petsc_superludist_1p = toc;disp(['Elapsed time is ',num2str(t_petsc_superludist_1p),' seconds.']);end
%
if exist('dmumpsmex');disp('- MEX-MUMPS'),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPSMEX = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.']);job_MUMPSMEX = -2;MUMPSMEX_dke_yp;end
if exist('mexlusolve');disp('- MEX-SUPERLU'),tic,[MMXS_t_SUPERLU] = lusolve(MMXPC_f_t,MMXR_t);t_slu = toc;disp(['Elapsed time is ',num2str(t_slu),' seconds.']);end
%
figure(1),plot(MMXS_t_cgs),title(['MATLAB-CGS on ',computer])
figure(2),plot(MMXS_t_bicg),title(['MATLAB-BICG on ',computer])
figure(3),plot(MMXS_t_qmr),title(['MATLAB-QMR on ',computer])
%
if exist('MMXS_t_MUMPS_S_ABSOFT'),figure(4),plot(MMXS_t_MUMPS_S_ABSOFT),title(['MUMPS-ABSOFT-SEQ on ',computer]);end
if exist('MMXS_t_MUMPS_S_G95'),figure(5),plot(MMXS_t_MUMPS_S_G95),title(['MUMPS-G95-SEQ on ',computer]);end
if exist('MMXS_t_MUMPS_P_PGF90_4P'),figure(6),plot(MMXS_t_MUMPS_P_PGF90_4P),title(['MUMPS-PGF90-PAR (4 procs) on ',computer]);end
if exist('MMXS_t_MUMPS_P_PGF90_1P'),figure(7),plot(MMXS_t_MUMPS_P_PGF90_1P),title(['MUMPS-PGF90-PAR (1 proc) on ',computer]);end
if exist('MMXS_t_MUMPS_S_PGF90'),figure(8),plot(MMXS_t_MUMPS_S_PGF90),title(['MUMPS-PGF90-SEQ on ',computer]);end
if exist('MMXS_t_PETSC_BCGS_1P'),figure(9),plot(MMXS_t_PETSC_BCGS_1P),title(['MMXS_t_PETSC_BCGS_1P on ',computer]);end
if exist('MMXS_t_PETSC_SUPELUDIST_1P'),figure(10),plot(MMXS_t_PETSC_SUPELUDIST_1P),title(['MMXS_t_PETSC_SUPELUDIST_1P on ',computer]);end
%
if exist('dmumpsmex');figure(11),plot(MMXS_t_MUMPSMEX),title(['MEX-MUMPS on ',computer]);end
if exist('mexlusolve');figure(12),plot(MMXS_t_SUPERLU),title(['MEX-SUPERLU on ',computer]);end
diary off

