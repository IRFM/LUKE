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
id_simul = 'Runaway_Zi_nobounce';%Simulation ID
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
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
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
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
dkeparam.coll_mode = 0;%For comparison with theoretical results
betath = 0.001;%validated for NR limit
%
equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
Zi_list = [1:20];
epsi_list = [0.04,0.06,0.08,0.10];
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
%
for iZi = 1:length(Zi_list),
    %
    Zi = Zi_list(iZi);
    equil.zZi = [1,1,1,Zi];
    equil.pzni = [0;0;0;1/Zi]*equil.pne;
    %
    for iepsi = 1:length(epsi_list),
        %
        epsi = epsi_list(iepsi);
        %
        ohm = ohm_flat(equil,epsi);
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        %
        RR(iZi,iepsi) = dke_out.XxRR_fsav(end,:);
        %
    end
    %
end
%
Zi_kulsrud =[1,2,3,10];
RR_kulsrud = 1e-4*[ 0.01914,NaN   ,NaN  ,NaN  ;...%Kulsrud (PRL, 31,11, (1972) 690)
                    0.5411 ,0.2611,NaN  ,NaN  ;...  
                    3.177  ,1.735 ,1.047,0.09 ;...
                    10.04  ,5.839 ,3.757,0.449].';
%
%************************************************************************************************************************************
%
format
%
delete res_Zi
%
diary res_Zi
%
disp(['Comparison LUKE/Kulsrud - NR calculations (betath = 0.001)'])
disp(['----------------------'])
disp(['--> epsi = 0.04'])
disp(['Zi =  1 : gamma_R = ',num2str(RR( 1,1)),'/',num2str(RR_kulsrud(1,1))]) 
disp(['Zi =  2 : gamma_R = ',num2str(RR( 2,1)),'/',num2str(RR_kulsrud(2,1))]) 
disp(['Zi =  3 : gamma_R = ',num2str(RR( 3,1)),'/',num2str(RR_kulsrud(3,1))]) 
disp(['Zi = 10 : gamma_R = ',num2str(RR(10,1)),'/',num2str(RR_kulsrud(4,1))]) 
disp(['----------------------'])
disp(['--> epsi = 0.06'])
disp(['Zi =  1 : gamma_R = ',num2str(RR( 1,2)),'/',num2str(RR_kulsrud(1,2))]) 
disp(['Zi =  2 : gamma_R = ',num2str(RR( 2,2)),'/',num2str(RR_kulsrud(2,2))]) 
disp(['Zi =  3 : gamma_R = ',num2str(RR( 3,2)),'/',num2str(RR_kulsrud(3,2))]) 
disp(['Zi = 10 : gamma_R = ',num2str(RR(10,2)),'/',num2str(RR_kulsrud(4,2))]) 
disp(['----------------------'])
disp(['--> epsi = 0.08'])
disp(['Zi =  1 : gamma_R = ',num2str(RR( 1,3)),'/',num2str(RR_kulsrud(1,3))]) 
disp(['Zi =  2 : gamma_R = ',num2str(RR( 2,3)),'/',num2str(RR_kulsrud(2,3))]) 
disp(['Zi =  3 : gamma_R = ',num2str(RR( 3,3)),'/',num2str(RR_kulsrud(3,3))]) 
disp(['Zi = 10 : gamma_R = ',num2str(RR(10,3)),'/',num2str(RR_kulsrud(4,3))]) 
disp(['----------------------'])
disp(['--> epsi = 0.10'])
disp(['Zi =  1 : gamma_R = ',num2str(RR( 1,4)),'/',num2str(RR_kulsrud(1,4))]) 
disp(['Zi =  2 : gamma_R = ',num2str(RR( 2,4)),'/',num2str(RR_kulsrud(2,4))]) 
disp(['Zi =  3 : gamma_R = ',num2str(RR( 3,4)),'/',num2str(RR_kulsrud(3,4))]) 
disp(['Zi = 10 : gamma_R = ',num2str(RR(10,4)),'/',num2str(RR_kulsrud(4,4))]) 
%
diary off
%
figure(1),clf
%
leg = {'E/E_D = 0.04','E/E_D = 0.06','E/E_D = 0.08','E/E_D = 0.10'};
xlim = [0,20];
ylim = 10.^[-8,-2];
xlab = 'Z_i';
ylab = '\Gamma_R';
tit = '';
graph1D_jd(Zi_list,RR,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','',2,20,gca,0.9,0.7,0.7);
graph1D_jd(Zi_kulsrud,RR_kulsrud,0,1,'','','',leg,xlim,ylim,'none','+','',2,20,gca);
set(gca,'ytick',[1e-8 1e-7 1e-6 1e-5 1e-4 1e-3 1e-2])
set(gca,'xtick',[0:2:20])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(2,'fig_runaway_Zi','.',1)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
