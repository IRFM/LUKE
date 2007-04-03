%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_3D_num';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'../../../Database/WAVE_files/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
nit = 6;
dludroptol = logspace(-6,-2,nit);
%
dkeparam.invproc = 1;%CGS  
dkeparam.mlprecinv = 1-4;
dkeparam.mlmaxitinv = 4;
%
dmesh = 5;
nmesh = 6;
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   for i = 1:nit,%droptolerance scan       
      dkeparam.ludroptol = dludroptol(i);
      [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
      memory_f(i,j) = dke_out.memoryLU_f_out;
      time_f(i,j) = dke_out.time_out;
      rho_f{i,j} = rho_S;
      norm_f{i,j} = Znorm.x_0_fsav.*mksa.ne_ref;
      curr_f{i,j} = Zcurr.x_0_fsav.*mksa.j_ref;
      Prf_f{i,j} = ZP0.x_rf_fsav.*mksa.P_ref;
      Pcoll_f{i,j} = ZP0.x_c_fsav.*mksa.P_ref;
%
      disp(['Calculation in MatLab with incomplete LU calculation #',int2str(i),' with radial mesh size #',int2str(j*dmesh),'  done'])
    end
end
%
dkeparam.invproc = -1;%MUMPS
dkeparam.MUMPSparam.nproc = 4;%number of processor used by MUMPS (depends of the computer framework).
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_MUMPS(j) = dke_out.time_out;
   rho_f_MUMPS{j} = rho_S;
   norm_f_MUMPS{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_MUMPS{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_MUMPS{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_MUMPS{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Calculation with MUMPS done with radial mesh size #',int2str(j*dmesh),'  done'])
end
%
dkeparam.invproc = -2;%MUMPSMEX
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_MUMPSMEX(j) = dke_out.time_out;
   rho_f_MUMPSMEX{j} = rho_S;
   norm_f_MUMPSMEX{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_MUMPSMEX{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_MUMPSMEX{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_MUMPSMEX{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Calculation with MUMPSMEX done with radial mesh size #',int2str(j*dmesh),'  done'])
end
%
dkeparam.invproc = -3;%SUPERLUMEX
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_SUPERLU(j) = dke_out.time_out;
   rho_f_SUPERLU{j} = rho_S;
   norm_f_SUPERLU{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_SUPERLU{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_SUPERLU{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_SUPERLU{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Calculation with SUPERLU done with radial mesh size #',int2str(j*dmesh),'  done'])
end
%
dkeparam.invproc = -30;%PETSc
dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_PETSc_slu_i(j) = dke_out.time_out;
   rho_f_PETSc_slu_i{j} = rho_S;
   norm_f_PETSc_slu_i{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_PETSc_slu_i{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_PETSc_slu_i{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_PETSc_slu_i{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Calculation with PETSc (SUPERLU) done with radial mesh size #',int2str(j*dmesh),' (collision operator loop in C)  done'])
end
%
dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_PETSc_slu_e(j) = dke_out.time_out;
   rho_f_PETSc_slu_e{j} = rho_S;
   norm_f_PETSc_slu_e{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_PETSc_slu_e{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_PETSc_slu_e{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_PETSc_slu_e{j} = ZP0.x_c_fsav.*mksa.P_ref;
   
%
   disp(['Calculation with PETSc (SUPERLU) done with radial mesh size #',int2str(j*dmesh),' (collision operator loop in MatLab)  done'])
end
%
dkeparam.invproc = -30;%PETSc
dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_PETSc_bcgs_i(j) = dke_out.time_out;
   rho_f_PETSc_bcgs_i{j} = rho_S;
   norm_f_PETSc_bcgs_i{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_PETSc_bcgs_i{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_PETSc_bcgs_i{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_PETSc_bcgs_i{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Calculation with PETSc (SUPERLU) done with radial mesh size #',int2str(j*dmesh),' (collision operator loop in C)  done'])
end
%
dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_PETSc_bcgs_e(j) = dke_out.time_out;
   rho_f_PETSc_bcgs_e{j} = rho_S;
   norm_f_PETSc_bcgs_e{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_PETSc_bcgs_e{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_PETSc_bcgs_e{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_PETSc_bcgs_e{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Calculation with PETSc (SUPERLU) done with radial mesh size #',int2str(j*dmesh),' (collision operator loop in MatLab)  done'])
end
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),graph1D_jd(dludroptol,time_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',2);hold on
graph1D_jd(dludroptol,time_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',2);hold on
graph1D_jd(dludroptol,time_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',2);
graph1D_jd(dludroptol,time_f(:,4),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',1);
graph1D_jd(dludroptol,time_f(:,5),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',1);
graph1D_jd(dludroptol,time_f(:,6),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',1);
legend('n_{\psi} = 4','n_{\psi} = 9','n_{\psi} = 14','n_{\psi} = 19','n_{\psi} = 24','n_{\psi} = 29')
savefig_dke_yp('timeludroptol')
%
figure(2),graph1D_jd(dludroptol,memory_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',2);hold on
graph1D_jd(dludroptol,memory_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',2);hold on
graph1D_jd(dludroptol,memory_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',2);
graph1D_jd(dludroptol,memory_f(:,4),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',1);
graph1D_jd(dludroptol,memory_f(:,5),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',1);
graph1D_jd(dludroptol,memory_f(:,6),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',1);
legend('n_{\psi} = 4','n_{\psi} = 9','n_{\psi} = 14','n_{\psi} = 19','n_{\psi} = 24','n_{\psi} = 29')
savefig_dke_yp('memoryludroptol')
%
diary testmatinv.txt
disp('-------------------')
disp('Incomplete LU preconditionning, CGS iterative Krylov algorithm, npsi = 30')
disp(['droptolerance: ',num2str(dludroptol(end-1)),' - Full CPU time: ',num2str(time_f(end-1,6)),' (s) - LU memory size: ',num2str(memory_f(end-1,6)),' (MBytes)'])
disp(['ne(0): ',num2str(round(norm_f{end-1,6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f{end-1,6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f{end-1,6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f{end-1,6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion with MUMPS (4 processors), npsi = 30')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_MUMPS(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_MUMPS{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_MUMPS{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_MUMPS{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_MUMPS{6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion MUMPSMEX')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_MUMPSMEX(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_MUMPSMEX{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_MUMPSMEX{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_MUMPSMEX{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_MUMPSMEX{6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion SUPERLUMEX')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_SUPERLUMEX(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_SUPERLUMEX{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_SUPERLUMEX{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_SUPERLUMEX{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_SUPERLUMEX{6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion with PETSc (SUPERLU, 1 processor) (collision loop in MatLab), npsi = 30')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_PETSc_slu_e(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_PETSc_slu_e{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_PETSc_slu_e{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_PETSc_slu_e{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_PETSc_slu_e{6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion with PETSc (SUPERLU, 1 processor) (collision loop in C), npsi = 30')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_PETSc_slu_i(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_PETSc_slu_i{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_PETSc_slu_i{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_PETSc_slu_i{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_PETSc_slu_i{6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion with PETSc (BCGS, 1 processor) (collision loop in MatLab), npsi = 30')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_PETSc_bcgs_e(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_PETSc_bcgs_e{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_PETSc_bcgs_e{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_PETSc_bcgs_e{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_PETSc_bcgs_e{6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Matrix inversion with PETSc (BCGS, 1 processor) (collision loop in C), npsi = 30')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_PETSc_bcgs_i(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_PETSc_bcgs_i{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_PETSc_bcgs_i{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_PETSc_bcgs_i{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_PETSc_bcgs_i{6}(1)),' (MW/m3)'])
diary off
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);