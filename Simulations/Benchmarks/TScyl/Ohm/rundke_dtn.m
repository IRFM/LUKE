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
id_simul = 'Ohm_dtn';%Simulation ID
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
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
betath = 0.01;%validated for NR limit
%
epsi = 0.001;
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%
ohm = ohm_flat(equil,epsi);
%
sigma_Karney_nr_0 = 3.773;
sigma_Karney_nr_1 = 2.837;
sigma_Karney_nr_2 = 7.429;
%
% Building the distribution function to a quasi steady-state for the
% ohmic problem : tn = 10000
%
tnmax = 10000;
nit_list = round(logspace(0,2,11));
dtn_list = tnmax./nit_list;
%
dkeparam.tn = NaN;%specified by dtn
%
% Testing different dtn
%
ndtn = length(dtn_list);
sigma_0 = NaN(1,ndtn);
sigma_1 = NaN(1,ndtn);
sigma_2 = NaN(1,ndtn);
%
for idtn = 1:ndtn,
    %
    dtn = dtn_list(idtn); 
    dkeparam.dtn = repmat(dtn,[1,nit_list(idtn)]);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    [dummy,Zcurr] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    sigma_0(idtn) = Zcurr.x_0/epsi;
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    [dummy,Zcurr] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    sigma_1(idtn) = Zcurr.x_0/epsi;
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    [dummy,Zcurr,dummy,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        sigma_2(idtn) = Zcurr.x_0/epsi;
    end        
    %
end
%
sigma_Z1s = 1/100*sqrt(me*qe/10)/(1.65*mu0*e0^2);%Spitzer conductivity (from 'Tokamaks' by J. Wesson, Oxford Science Publication, 3rd Eds., 2004)
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[2,4];
ylim = [0,10];
xlab = '\Deltat';
ylab = '\sigma';
tit = '';
siz = 20+14i;
%
graph1D_jd(dtn_list,sigma_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(dtn_list,sigma_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(dtn_list,sigma_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(xlim,[sigma_Karney_nr_2,sigma_Karney_nr_2],1,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(xlim,[sigma_Karney_nr_1,sigma_Karney_nr_1],1,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
graph1D_jd(xlim,[sigma_Karney_nr_0,sigma_Karney_nr_0],1,0,'','','',NaN,xlim,ylim,'--','none','g',2,siz,gca);
graph1D_jd(xlim,[sigma_Z1s,sigma_Z1s],1,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:2:10])
%
print_jd(p_opt,'fig_sigma_dtn','./figures',1)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
