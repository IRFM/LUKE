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
id_simul = 'LH_karney_num';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [0.001];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
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
%**************************************************************************
%**************************************************************************
%
nit = 6;
dludroptol = logspace(-6,-2,nit);
%
dkeparam.invproc = 1;%MATLAB-CGS
dkeparam.ludroptol = 0;%Full LU factorization for preconditionning
dkeparam.mlprecinv = 1-4;
dkeparam.mlmaxitinv = 4;
%
[Znorm_LU,Zcurr_LU,ZP0_LU,dke_out_LU,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp('Full LU calculation done')
%
for j = 1:3,%Numerical method (CGS, BICG, QMR)
    for i = 1:nit,%droptolerance scan
      dkeparam.ludroptol = dludroptol(i);
      dkeparam.invproc  = j;
      [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
% 
      memory_f(i,dkeparam.invproc) = dke_out.memoryLU_f_out;
      time_f(i,dkeparam.invproc) = dke_out.time_out;
      norm_f(i,dkeparam.invproc) = Znorm.x_0_fsav.*mksa.ne_ref;
      curr_f(i,dkeparam.invproc) = Zcurr.x_0_fsav.*mksa.j_ref;
      Prf_f(i,dkeparam.invproc) = ZP0.x_rf_fsav.*mksa.P_ref;
      Pcoll_f(i,dkeparam.invproc) = ZP0.x_c_fsav.*mksa.P_ref;
%
      disp(['Calculation with MatLab incomplete LU calculation #',int2str(i),' with matrix inversion method #',int2str(j),'  done'])
    end
end
%
%dkeparam.invproc = 0;
%[Znorm_directML,Zcurr_directML,ZP0_directML,dke_out_directML] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp(['Direct MatLab calculation done'])
%
if isfield(dkepath,'MUMPS'),
   dkeparam.invproc = -1;
   [Znorm_MUMPS,Zcurr_MUMPS,ZP0_MUMPS,dke_out_MUMPS] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp(['Direct MUMPS calculation done'])
end
%
if exist('dmumpsmex'),
    dkeparam.invproc = -2;
    [Znorm_MUMPSMEX,Zcurr_MUMPSMEX,ZP0_MUMPSMEX,dke_out_MUMPSMEX] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    disp(['MUMPSMEX calculation done'])
end
%
if exist('mexlusolve'),
    dkeparam.invproc = -3;
    [Znorm_SUPERLUMEX,Zcurr_SUPERLUMEX,ZP0_SUPERLUMEX,dke_out_SUPERLUMEX] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    disp(['SUPERLUMEX calculation done'])
end
%
if isfield(dkepath,'PETSc'),
    dkeparam.invproc = -30;
    dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
%
    [flag,message] = unix('uname -n');
    if strfind(message,'saturne'),%this option runs only on the SATURNE CEA-DRFC cluster
        dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
        dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
        dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
        dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
        [Znorm_PETScSUPERLU0,Zcurr_PETScSUPERLU0,ZP0_PETScSUPERLU0,dke_out_PETScSUPERLU0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        disp(['PETSc/SUPERLU calculation done (first collision operator loop in MatLab).'])
        dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
        [Znorm_PETScSUPERLU1,Zcurr_PETScSUPERLU1,ZP0_PETScSUPERLU1,dke_out_PETScSUPERLU1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        disp(['PETSc/SUPERLU calculation done (first collision operator loop in C).'])
        flag_PETSC = 1;
    else
        flag_PETSC = 0;
    end
    %
    dkeparam.PETScparam.matrixtype = '';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
    dkeparam.PETScparam.kspmethod = '-ksp_type bcgs';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
    dkeparam.PETScparam.pcmethod = '';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
    dkeparam.PETScparam.cloop = 0;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
    [Znorm_PETScBCGS0,Zcurr_PETScBCGS0,ZP0_PETScBCGS0,dke_out_PETScBCGS0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    disp(['PETSc/BCGS calculation done (first collision operator loop in MatLab).'])
    dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
    [Znorm_PETScBCGS1,Zcurr_PETScBCGS1,ZP0_PETScBCGS1,dke_out_PETScBCGS1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    disp(['PETSc/BCGS calculation done (first collision operator loop in C).'])  
end
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),clf,graph1D_jd(dludroptol,time_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,time_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,time_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);
legend('CGS','BICG','QMR')
savefig_dke_yp('timeludroptol')
%
figure(2),clf,graph1D_jd(dludroptol,memory_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2,20,gca,0.85,0.7,0.5);hold on
savefig_dke_yp('memoryludroptol')
%
figure(3),clf,graph1D_jd(dludroptol,norm_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Electron density (m^{-3})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,norm_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Electron density (m^{-3})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,norm_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Electron density (m^{-3})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);
legend('CGS','BICG','QMR')
savefig_dke_yp('normludroptol')
%
figure(4),clf,graph1D_jd(dludroptol,abs(curr_f(:,1)),1,0,'Drop tolerance parameter \delta_{LU}','Current density (MA/m^{2})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,abs(curr_f(:,2)),1,0,'Drop tolerance parameter \delta_{LU}','Current density (MA/m^{2})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,abs(curr_f(:,3)),1,0,'Drop tolerance parameter \delta_{LU}','Current density (MA/m^{2})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);
legend('CGS','BICG','QMR')
savefig_dke_yp('currludroptol')
%
figure(5),clf,graph1D_jd(dludroptol,Prf_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Power density (MW/m^{3}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,Prf_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Power density (MW/m^{3}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,Prf_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Power density (MW/m^{3}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,-Pcoll_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','p_{LH} and p_{coll}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','-','none','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,-Pcoll_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','p_{LH} and p_{coll}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','--','none','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,-Pcoll_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','p_{LH} and p_{coll}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','-.','none','g',2,20,gca,0.85,0.7,0.5);
legend('LH (CGS)','LH (BICG)','LH (QMR)','Collision (CGS)','Collision (BICG)','Collision (QMR)')
savefig_dke_yp('PLHPcollludroptol')
% 
figure(6),clf,graph1D_jd(dludroptol,abs(curr_f(:,1))./Prf_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','|\eta| (MA.m/MW)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,abs(curr_f(:,2))./Prf_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','|\eta| (MA.m/MW)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(dludroptol,abs(curr_f(:,3))./Prf_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','|\eta| (MA.m/MW)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);
legend('CGS','BICG','QMR')
savefig_dke_yp('efficiencyludroptol')
%
diary testmatinv.txt
disp('-------------------')
disp('Incomplete LU precondtionning, CGS iterative Krylov algorithm')
disp(['droptolerance: ',num2str(dludroptol(end-1)),' - Full CPU time: ',num2str(time_f(end-1,1)),' (s) - LU memory size: ',num2str(memory_f(end-1,1)),' (MBytes)'])
disp(['ne: ',num2str(round(norm_f(end-1,1)/1e+16)/1e3),' (10+19 m-3) - JLH: ',num2str(abs(curr_f(end-1,1))),' (MA/m2) - PLH: ',num2str(Prf_f(end-1,1)),' (MW/m3) - Pcoll: ',num2str(-Pcoll_f(end-1,1)),' (MW/m3)'])
disp('-------------------')
disp('Full LU precondtionning, CGS iterative Krylov algorithm')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_LU.time_out),' (s) - LU memory size: ',num2str(dke_out_LU.memoryLU_f_out),' (MBytes)'])
disp(['ne: ',num2str(round(Znorm_LU.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_LU.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_LU.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_LU.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
disp('-------------------')
if isfield(dkepath,'MUMPS'),
    disp('Direct matrix inversion MUMPS')
    disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_MUMPS.time_out),' (s)'])
    disp(['ne: ',num2str(round(Znorm_MUMPS.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_MUMPS.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_MUMPS.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_MUMPS.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
    disp('-------------------')
end
if exist('dmumpsmex'),
    disp('Matrix inversion MUMPSMEX')
    disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_MUMPSMEX.time_out),' (s)'])
    disp(['ne: ',num2str(round(Znorm_MUMPSMEX.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_MUMPSMEX.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_MUMPSMEX.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_MUMPSMEX.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
    disp('-------------------')
end
if exist('mexlusolve'),
    disp('Matrix inversion SUPERLUMEX')
    disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_SUPERLUMEX.time_out),' (s)'])
    disp(['ne: ',num2str(round(Znorm_SUPERLUMEX.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_SUPERLUMEX.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_SUPERLUMEX.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_SUPERLUMEX.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
    disp('-------------------')
end
if isfield(dkepath,'PETSc'),
    if flag_PETSC == 1,
        disp('Matrix inversion PETSc/SUPERLU, 1 processor and first order collision correction in MatLab')
        disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_PETScSUPERLU0.time_out),' (s)'])
        disp(['ne: ',num2str(round(Znorm_PETScSUPERLU0.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_PETScSUPERLU0.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_PETScSUPERLU0.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_PETScSUPERLU0.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
        disp('-------------------')
        disp('Matrix inversion PETSc/SUPERLU, 1 processor and first order collision correction in C')
        disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_PETScSUPERLU1.time_out),' (s)'])
        disp(['ne: ',num2str(round(Znorm_PETScSUPERLU1.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_PETScSUPERLU1.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_PETScSUPERLU1.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_PETScSUPERLU1.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
        disp('-------------------')
    end
    disp('Matrix inversion PETSc/BCGS, 1 processor and first order collision correction in MatLab')
    disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_PETScBCGS0.time_out),' (s)'])
    disp(['ne: ',num2str(round(Znorm_PETScBCGS0.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_PETScBCGS0.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_PETScBCGS0.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_PETScBCGS0.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
    disp('-------------------')  
    disp('Matrix inversion PETSc/BCGS, 1 processor and first order collision correction in C')
    disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_PETScBCGS1.time_out),' (s)'])
    disp(['ne: ',num2str(round(Znorm_PETScBCGS1.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_PETScBCGS1.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_PETScBCGS1.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_PETScBCGS1.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
end
%
diary off
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);