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
if strcmp(computer,'GLNXA64'),load ../Database/PATH_files/PATH_PC_DRFC_YVES.mat,,dkepath.temppath = '/scratch';end
%
disp(['Matrix size:',int2str(length(MMXR_t)),'x',int2str(length(MMXR_t))]);
disp(' ');
disp('- MATLAB-ILU'),tic,[MMXL_f_t_test,MMXU_f_t_test] = luinc(MMXPC_f_t,1e-4);t_ilumatlab = toc;disp(['Elapsed time is ',num2str(t_ilumatlab),' seconds.'])
disp('- MUMPS-ILU'),tic,job_MUMPSMEX = 1;MUMPSMEX_dke_yp;job_MUMPSMEX = 2;MUMPSMEX_dke_yp;t_ilumumpsmex = toc;;disp(['Elapsed time is ',num2str(t_ilumumpsmex),' seconds.'])
disp('-------------------')
disp('- MATLAB-CGS'),tic,[MMXS_t_cgs,flaginv_f] = cgs(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_cgs = toc;disp(['Elapsed time is ',num2str(t_cgs),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB-BICG'),tic,[MMXS_t_bicg,flaginv_f] = bicg(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_bicg = toc;disp(['Elapsed time is ',num2str(t_bicg),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
disp('- MATLAB-QMR'),tic,[MMXS_t_qmr,flaginv_f] = qmr(MMXPC_f_t,MMXR_t,dkeparam.mlprecinv,dkeparam.mlmaxitinv,MMXL_f_t,MMXU_f_t);t_qmr = toc;disp(['Elapsed time is ',num2str(t_qmr),' seconds per inversion + ILU time (once): ',num2str(t_ilumatlab),' seconds.'])
if strcmp(computer,'MAC'),
   dkepath.MUMPS_old = dkepath.MUMPS;
   dkepath.MUMPS = '/Users/Yves/CEA/Projets/Packages/MUMPS_4.6.4_absoft_seq/dke';%Unused version (for benchmark only)
   disp('- MUMPS-ABSOFT'),tic,[MMXS_t_MUMPS_ABSOFT,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumpsabsoft = toc;disp(['Elapsed time is ',num2str(t_mumpsabsoft),' seconds.'])
   dkepath.MUMPS = dkepath.MUMPS_old;%Back to default version
   disp('- MUMPS-G95'),tic,[MMXS_t_MUMPS_G95,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumpsg95 = toc;disp(['Elapsed time is ',num2str(t_mumpsg95),' seconds.'])
elseif strcmp(computer,'GLNXA64'),  
   dkepath.MUMPS_old = dkepath.MUMPS;
   dkepath.MUMPS = '/home/sccp/gsem/peysson/Packages/MUMPS_4.6.4_seq/dke';%Unused version (for benchmark only)
   disp('- MUMPS-PGF90S'),tic,[MMXS_t_MUMPS_PGF90S,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumpspgf90s = toc;disp(['Elapsed time is ',num2str(t_mumpspgf90s),' seconds.'])
   dkepath.MUMPS = dkepath.MUMPS_old;%Back to default version
   disp('- MUMPS-PGF90P'),tic,[MMXS_t_MUMPS_PGF90P,flaginv_f] = MUMPS_dke_yp(dkeparam.MUMPSparam,MMXPC_f_t,full(MMXR_t),0,dkepath);t_mumpspgf90p = toc;disp(['Elapsed time is ',num2str(t_mumpspgf90p),' seconds.'])
%
   disp('- PETSc-PGF90'),tic,[MMXS_t,flaginv_f] = PETSc_dke_ft(dkeparam.PETScparam,MMXPC_f_t,full(MMXR_t),display_mode,dkepath);t_petsc = toc;disp(['Elapsed time is ',num2str(t_petsc),' seconds.'])
end
disp('- MEX-MUMPS'),tic,job_MUMPSMEX = 3;MUMPSMEX_dke_yp;t_mumpsmex = toc;MMXS_t_MUMPSMEX = id_MUMPSMEX.SOL;disp(['Elapsed time is ',num2str(t_mumpsmex),' seconds per inversion + ILU time (once): ',num2str(t_ilumumpsmex),' seconds.'])
job_MUMPSMEX = -2;MUMPSMEX_dke_yp;
disp('- MEX-SUPERLU'),tic,[MMXS_t_SUPERLU] = lusolve(MMXPC_f_t,MMXR_t);t_slu = toc;disp(['Elapsed time is ',num2str(t_slu),' seconds.'])
%
figure(1),plot(MMXS_t_cgs),title(['MATLAB-CGS on ',computer])
figure(2),plot(MMXS_t_bicg),title(['MATLAB-BICG on ',computer])
figure(3),plot(MMXS_t_qmr),title(['MATLAB-QMR on ',computer])
if strcmp(computer,'MAC'),
    figure(4),plot(MMXS_t_MUMPS_ABSOFT),title(['MUMPS-ABSOFT-SEQ on ',computer])
    figure(5),plot(MMXS_t_MUMPS_G95),title(['MUMPS-G95-SEQ on ',computer])
elseif strcmp(computer,'GLNXA64'),
    figure(4),plot(MMXS_t_MUMPS_PGF90S),title(['MUMPS-PGF90-SEQ on ',computer])
    figure(5),plot(MMXS_t_MUMPS_PGF90P),title(['MUMPS-PGF90-PAR on ',computer])  
end
figure(6),plot(MMXS_t_MUMPSMEX),title(['MEX-MUMPS on ',computer])
figure(7),plot(MMXS_t_SUPERLU),title(['MEX-SUPERLU on ',computer])
diary off