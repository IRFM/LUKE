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
dkeparam.ludroptol = 0;%Full LU factorization for preconditionning
dkeparam.mlprecinv = 1-4;
dkeparam.mlmaxitinv = 4;
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
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
      disp(['Incomplete LU calculation #',int2str(i),' with lmatrix inversion method #',int2str(j),'  done'])
    end
end
%
%dkeparam.invproc = 0;
%[Znorm_directML,Zcurr_directML,ZP0_directML,dke_out_directML] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp(['Direct MatLab calculation done'])
dkeparam.invproc = -1;
[Znorm_MUMPS,Zcurr_MUMPS,ZP0_MUMPS,dke_out_MUMPS] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp(['Direct MUMPS calculation done'])
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),graph1D_jd(dludroptol,time_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2);hold on
graph1D_jd(dludroptol,time_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2);hold on
graph1D_jd(dludroptol,time_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2);
legend('CGS','BICG','QMR')
savefig_dke_yp('timeludroptol')
%
figure(2),graph1D_jd(dludroptol,memory_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2);hold on
savefig_dke_yp('memoryludroptol')
%
figure(3),graph1D_jd(dludroptol,norm_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Electron density (m^{-3})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2);hold on
graph1D_jd(dludroptol,norm_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Electron density (m^{-3})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2);hold on
graph1D_jd(dludroptol,norm_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Electron density (m^{-3})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2);
legend('CGS','BICG','QMR')
savefig_dke_yp('normludroptol')
%
figure(4),graph1D_jd(dludroptol,abs(curr_f(:,1)),1,0,'Drop tolerance parameter \delta_{LU}','Current density (MA/m^{2})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2);hold on
graph1D_jd(dludroptol,abs(curr_f(:,2)),1,0,'Drop tolerance parameter \delta_{LU}','Current density (MA/m^{2})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2);hold on
graph1D_jd(dludroptol,abs(curr_f(:,3)),1,0,'Drop tolerance parameter \delta_{LU}','Current density (MA/m^{2})',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2);
legend('CGS','BICG','QMR')
savefig_dke_yp('currludroptol')
%
figure(5),graph1D_jd(dludroptol,Prf_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Power density (MW/m^{3}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2);hold on
graph1D_jd(dludroptol,Prf_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Power density (MW/m^{3}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2);hold on
graph1D_jd(dludroptol,Prf_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Power density (MW/m^{3}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2);hold on
graph1D_jd(dludroptol,-Pcoll_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','p_{LH} and p_{coll}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','-','none','r',2);hold on
graph1D_jd(dludroptol,-Pcoll_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','p_{LH} and p_{coll}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','--','none','b',2);hold on
graph1D_jd(dludroptol,-Pcoll_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','p_{LH} and p_{coll}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','-.','none','g',2);
legend('LH (CGS)','LH (BICG)','LH (QMR)','Collision (CGS)','Collision (BICG)','Collision (QMR)')
savefig_dke_yp('PLHPcollludroptol')
% 
figure(6),graph1D_jd(dludroptol,abs(curr_f(:,1))./Prf_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','|\eta| (MA.m/MW)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','+','r',2);hold on
graph1D_jd(dludroptol,abs(curr_f(:,2))./Prf_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','|\eta| (MA.m/MW)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','x','b',2);hold on
graph1D_jd(dludroptol,abs(curr_f(:,3))./Prf_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','|\eta| (MA.m/MW)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1)],NaN,'','','none','*','g',2);
legend('CGS','BICG','QMR')
savefig_dke_yp('efficiencyludroptol')
%
disp('-------------------')
disp('Incomplete LU precondtionning, CGS iterative Krylov algorithm')
disp(['droptolerance: ',num2str(dludroptol(end-1)),' - Full CPU time: ',num2str(time_f(end-1,1)),' (s) - LU memory size: ',num2str(memory_f(end-1,1)),' (MBytes)'])
disp(['ne: ',num2str(round(norm_f(end-1,1)/1e+16)/1e3),' (10+19 m-3) - JLH: ',num2str(abs(curr_f(end-1,1))),' (MA/m2) - PLH: ',num2str(Prf_f(end-1,1)),' (MW/m3) - Pcoll: ',num2str(-Pcoll_f(end-1,1)),' (MW/m3)'])
disp('-------------------')
disp('Full LU precondtionning, CGS iterative Krylov algorithm')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_LU.time_out),' (s) - LU memory size: ',num2str(dke_out_LU.memoryLU_f_out),' (MBytes)'])
disp(['ne: ',num2str(round(Znorm_LU.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_LU.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_LU.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_LU.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
disp('-------------------')
disp('Direct matrix inversion MUMPS')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(dke_out_MUMPS.time_out),' (s)'])
disp(['ne: ',num2str(round(Znorm_MUMPS.x_0_fsav.*mksa.ne_ref)/1e+19),' (10+19 m-3) - JLH: ',num2str(abs(Zcurr_MUMPS.x_0_fsav.*mksa.j_ref)),' (MA/m2) - PLH: ',num2str(ZP0_MUMPS.x_rf_fsav.*mksa.P_ref),' (MW/m3) - Pcoll: ',num2str(-ZP0_MUMPS.x_c_fsav.*mksa.P_ref),' (MW/m3)'])
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);