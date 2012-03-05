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
% ***********************This part must be specified by the user, run make files in $HOME/Database directory if necessary *****************************
%
id_simul = 'Thermal_Ti';%Simulation ID
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
dtn = 10000;
tnmax = 100000;
%
dkeparam.coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
dkeparam.dtn = dtn;
dkeparam.tn = tnmax;
dkeparam.prec0_f = 0;
%
pzTi = equil.pzTi;
Tifac_list = logspace(-2,2,21);
%
for iTi = 1:length(Tifac_list);
    %
    equil.pzTi = pzTi*Tifac_list(iTi);
    %
    % free mode
    %
    dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
    dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_final_0(iTi) = dke_out.normf0{end}(end);
    residue_final_0(iTi) = dke_out.residu_f{end}(end);
    %
    % boundary mode
    %
    dkeparam.boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
    dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_final_1(iTi) = dke_out.normf0{end}(end);
    residue_final_1(iTi) = dke_out.residu_f{end}(end);
    %
    % norm mode
    %
    dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
    dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_final_2(iTi) = dke_out.normf0{end}(end);
    residue_final_2(iTi) = dke_out.residu_f{end}(end);
end
%
figure(1),clf
%
leg = {'Free Mode','Fixed point','Normalization'};
xlim = 10.^[-2,2];
ylim = [-4,4]*1e-2;
xlab = 'T_i/T_e';
ylab = '\Deltan/n_0';
tit = '';
colors = {'r','b','g','m'};
siz = 20+14i;
%
graph1D_jd(Tifac_list,normf0_final_0-1,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,siz,gca,0.9,0.7,0.7);
graph1D_jd(Tifac_list,normf0_final_1-1,1,0,'','','',NaN,xlim,ylim,'-','none',colors{2},2,siz,gca);
graph1D_jd(Tifac_list,normf0_final_2-1,1,0,'','','',leg,xlim,ylim,'-','none',colors{3},2,siz,gca);
%
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'ytick',[-4:2:4]*1e-2)
%
figure(2),clf
%
ylim = 10.^[-23,-21];
ylab = 'Legendre convergence parameter';
%
graph1D_jd(Tifac_list,residue_final_0,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','+',colors{1},2,siz,gca,0.9,0.7,0.7);
graph1D_jd(Tifac_list,residue_final_1,1,1,'','','',NaN,xlim,ylim,'-','+',colors{2},2,siz,gca);
graph1D_jd(Tifac_list,residue_final_2,1,1,'','','',leg,xlim,ylim,'-','+',colors{3},2,siz,gca);
%
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'ytick',10.^[-23:21])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','off')
%
print_jd(2,'fig_thermal_Ti_deltan','./figures',1)
print_jd(2,'fig_thermal_Ti_residue','./figures',2)
%	    
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);