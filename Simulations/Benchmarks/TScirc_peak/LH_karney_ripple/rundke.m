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
id_simul = 'LH_karney_ripple';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [linspace(0.1,0.3,3),linspace(0.35,0.65,12),linspace(0.7,0.9,3)];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc_peak';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'BOUNCE3D_MUMPS';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney_uniform'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'../../../Database/WAVE_files/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = 'TScirc';%For fast electron magnetic ripple losses
path_ripple = '../../../Database/RIPPLE_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
dkeparam.nmhu_S = 151;
dkeparam.np_S = 151;
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
%
addpath('rippleTS');
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,dke_out.xMRR_flux,0,0,'','','',NaN,'','','-','non','r',2);
graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,dke_out.xMRR_tau,0,0,'R(m)','Magnetic ripple loss rate',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','--','non','b',2);hold on
legend('Flux calculations','\tau calculations')
savefig_dke_yp(['ripplelossrate'])
%
figure(2),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,ZP0.x_rf_fsav,0,0,'R(m)','P_{lh}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,-ZP0.x_c_fsav,0,0,'R(m)','P_{lh}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','b',1);
legend('P_{lh}','P_{coll}')
savefig_dke_yp(['powerdensity'])
%
figure(3),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,Zmripple.xthetabanana,0,0,'R(m)','Angle (deg.)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,Zmripple.xthetaloss,0,0,'R(m)','Angle (deg.)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','--','non','b',2);
legend('Banana cone angle','Loss cone angle')
savefig_dke_yp(['losscone'])
%
figure(4),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,Zmripple.xpndetrap,0,0,'R(m)','Magnetic ripple p_{detrap}/p_{th-ref}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
savefig_dke_yp(['detrap'])
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
%
proc_rundke_yp(4,'DKE_RESULTS_TScirc_peak_LH_karney_ripple.mat',10,1);% 


