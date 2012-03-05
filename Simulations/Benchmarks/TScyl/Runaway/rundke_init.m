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
p_opt = 2;
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'Runaway_init';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.5];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
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
%************************************************************************************************************************************
%
if exist('dmumpsmex','file');dkeparam.invproc = -2;end
%
betath = 0.001;%validated for NR limit
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
dkeparam.boundary_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
dkeparam.timevol = 1;%to calculate moments at all internal times
%
dtn = 100;% time step
nit = 100;% number of iterations
tn_max = dtn*nit;% total time
%
epsi = 0.04;%corresponds to pc/pT = 5
%
ohm = ohm_flat(equil,epsi);
%
RR_kulsrud = 1.914*1e-6;%Kulsrud (PRL, 31,11, (1972) 690)
%
% ------------------------------
% Internal time loop calculation
% ------------------------------
%
dkeparam.dtn = dtn;    
dkeparam.tn = tn_max;    
%
dkeparam.coll_mode = 0;% Relativistic Maxwellian background
%
[Znorm_0,Zcurr_0,ZP0_0,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
%
[Znorm_2,Zcurr_2,ZP0_2,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
% One can check that dke_out_0.normf0{it}(1) is the same as dke_out_0.normf0{it-1}(end)
%
snormf0_0 = NaN(1,nit);
sRRv_0 = NaN(1,nit);
sRRs_0 = NaN(1,nit);
for it=1:nit,
    snormf0_0(it) = dke_out_0.normf0{it}(end);
    sRRv_0(it) = (dke_out_0.normf0{it}(1) - dke_out_0.normf0{it}(end))/dtn;
    sRRs_0(it) = dke_out_0.XxRR_fsav{it}(end,:);
end
%
snormf0_2 = NaN(1,nit);
sresidue_2 = NaN(1,nit);
sRRv_2 = NaN(1,nit);
sRRs_2 = NaN(1,nit);
for it=1:nit,
    snormf0_2(it) = dke_out_2.normf0{it}(end);
    sresidue_2(it) = dke_out_2.residu_f{it}(end);
    sRRv_2(it) = (dke_out_2.normf0{it}(1) - dke_out_2.normf0{it}(end))/dtn;
    sRRs_2(it) = dke_out_2.XxRR_fsav{it}(end,:);
end
snormf0_2(sresidue_2 > dkeparam.prec0_f) = NaN;
sRRv_2(sresidue_2 > dkeparam.prec0_f) = NaN;
sRRs_2(sresidue_2 > dkeparam.prec0_f) = NaN;
%
% ------------------------------
% External time loop calculation
% ------------------------------
%
XXf0_0 = [];
XXf0_2 = [];
%
dkeparam.tn = dtn;%Enforcing a single iteration
%
xnormf0_0 = NaN(1,nit);
xRRv_0 = NaN(1,nit);
xRRs_0 = NaN(1,nit);
%
xnormf0_2 = NaN(1,nit);
xRRv_2 = NaN(1,nit);
xRRs_2 = NaN(1,nit);
%
for it = 1:nit,
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    %
    [Znorm_0,Zcurr_0,ZP0_0,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_0,[]);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    %
    [Znorm_2,Zcurr_2,ZP0_2,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_2,[]);
    %
    % One can check that : 
    %
    % - Znorm_0.x_0_fsav is the same as dke_out_0.normf0{1}(end)
    % - dke_out_0.normf0{1}(1) is the same as xnormf0_0(it-1)
    %
    xnormf0_0(it) = Znorm_0.x_0_fsav;
    xRRv_0(it) = (dke_out_0.normf0{1}(1) - dke_out_0.normf0{1}(end))/dtn;
    xRRs_0(it) = dke_out_0.XxRR_fsav{1}(end,:);
    %
    if dke_out_2.residu_f{1}(end) <= dkeparam.prec0_f,
        xnormf0_2(it) = Znorm_2.x_0_fsav;
        xRRv_2(it) = (dke_out_2.normf0{1}(1) - dke_out_2.normf0{1}(end))/dtn;
        xRRs_2(it) = dke_out_2.XxRR_fsav{1}(end,:);
    else
        xnormf0_2(it) = NaN;
        RRv_end_2 = NaN;
        RRs_end_2 = NaN;
    end        
    %
    XXf0_0 = dke_out_0.XXf0{1};
    XXf0_2 = dke_out_2.XXf0{1};
    %
end
%
%************************************************************************************************************************************
%
format
%
delete res_init
%
diary res_init
%
disp('Test for internal and external loop consistency')
disp('----------------------')
disp('--> Maximum difference between internal and external density calculations : ')
disp(['coll_mode = 0 : max(abs(snormf0_0 - xnormf0_0)) = ',num2str(max(abs(snormf0_0 - xnormf0_0)))]) 
disp(['coll_mode = 2 : max(abs(snormf0_2 - xnormf0_2)) = ',num2str(max(abs(snormf0_2 - xnormf0_2)))]) 
disp(' ')
disp('--> Maximum difference between internal and external volume runaway calculations : ')
disp(['coll_mode = 0 : max(abs(sRRv_0 - xRRv_0)) = ',num2str(max(abs(sRRv_0 - xRRv_0)))]) 
disp(['coll_mode = 2 : max(abs(sRRv_2 - xRRv_2)) = ',num2str(max(abs(sRRv_2 - xRRv_2)))]) 
disp(' ')
disp('--> Maximum difference between internal and external surface runaway calculations : ')
disp(['coll_mode = 0 : max(abs(sRRs_0 - xRRs_0)) = ',num2str(max(abs(sRRs_0 - xRRs_0)))]) 
disp(['coll_mode = 2 : max(abs(sRRs_2 - xRRs_2)) = ',num2str(max(abs(sRRs_2 - xRRs_2)))]) 
disp('----------------------')
%
diary off
%
figure(1),clf
%
leg = {'Single run','Multiple runs'};
xlim = [0,tn_max];
ylim = 10.^[-10,0];
xlab = '\Deltat';
ylab = '\Deltan/n_0';
tit = '';
siz = 20+14i;
%
graph1D_jd((1:nit)*dtn,1-snormf0_0,0,1,xlab,ylab,tit,NaN,xlim,ylim,'--','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd((1:nit)*dtn,1-xnormf0_0,0,1,'','','',leg,xlim,ylim,'-','none','b',0.5,siz,gca);
%
set(gca,'ytick',[1e-010 1e-08 1e-06 1e-04 1e-02 1e-00])
set(gca,'xtick',[0:tn_max/5:tn_max])
set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(2),clf
%
graph1D_jd((1:nit)*dtn,1-snormf0_2,0,1,xlab,ylab,tit,NaN,xlim,ylim,'--','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd((1:nit)*dtn,1-xnormf0_2,0,1,'','','',leg,xlim,ylim,'-','none','b',0.5,siz,gca);
%
set(gca,'ytick',[1e-010 1e-08 1e-06 1e-04 1e-02 1e-00])
set(gca,'xtick',[0:tn_max/5:tn_max])
set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(3),clf
%
leg = {'Volumic losses','Boundary losses','Runaway losses'};
xlim = [dtn,tn_max];
ylim = 10.^[-10,-5];
xlab = '\Deltat';
ylab = '\Gamma_R';
tit = '';
%
graph1D_jd((1:nit)*dtn,sRRv_0,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd((1:nit)*dtn,sRRs_0,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,1,'','','',leg,xlim,ylim,'--','none','k',2,20,gca);
%
set(gca,'ytick',[1e-010 1e-09 1e-08 1e-07 1e-06 1e-05])
set(gca,'xtick',[1 10 100 1000 10000])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(4),clf
%
leg = {'Volumic losses','Boundary losses'};
%
graph1D_jd((1:nit)*dtn,sRRv_2,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd((1:nit)*dtn,sRRs_2,1,1,'','','',leg,xlim,ylim,'-','none','b',2,siz,gca);
%
set(gca,'ytick',[1e-010 1e-09 1e-08 1e-07 1e-06 1e-05])
set(gca,'xtick',[1 10 100 1000 10000])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(p_opt,'fig_runaway_init_cons_coll0','./figures',1)
print_jd(p_opt,'fig_runaway_init_cons_coll2','./figures',2)
print_jd(p_opt,'fig_runaway_init_RR_coll0','./figures',3)
print_jd(p_opt,'fig_runaway_init_RR_coll2','./figures',4)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
