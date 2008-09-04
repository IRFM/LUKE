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
id_simul = 'Thermal_dtn';%Simulation ID
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
[dkepath,equil,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
if exist('dmumpsmex'),
	invproc = -2;
else
	invproc = 1;
end
%
boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
prec0_f = -1;
%
tnmax = 100000;%number of iterations
dtn_list = [500,5000,50000];
%
% Case Ti=Te, uniform grid
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkeparam] = load_structures_yp('dkeparam',id_dkeparam,path_dkeparam);
%
dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.coll_mode = coll_mode;
dkeparam.prec0_f = prec0_f;
dkeparam.invproc = invproc;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f = round(tnmax/dtn);
    %
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_u_1{idtn} = dke_out.normf0;
    residue_final_u_1(idtn) = dke_out.residu_f(end);
end
%
% Case Ti=Te/2, uniform grid
%
pzTi = equil.pzTi;
equil.pzTi = pzTi/2;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f = round(tnmax/dtn);
    %
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_u_2{idtn} = dke_out.normf0;
    residue_final_u_2(idtn) = dke_out.residu_f(end);
end
%
% Case Ti=Te, non-uniform grid
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkeparam] = load_structures_yp('dkeparam',id_dkeparam,path_dkeparam);
%
dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.coll_mode = coll_mode;
dkeparam.prec0_f = prec0_f;
dkeparam.invproc = invproc;
%
equil.pzTi = pzTi;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f = round(tnmax/dtn);
    %
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_nu_1{idtn} = dke_out.normf0;
    residue_final_nu_1(idtn) = dke_out.residu_f(end);
end
%
% Case Ti=Te/2, uniform grid
%
equil.pzTi = pzTi/2;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f = round(tnmax/dtn);
    %
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_nu_2{idtn} = dke_out.normf0;
    residue_final_nu_2(idtn) = dke_out.residu_f(end);
end
%
figure(1),clf
%
leg = {'\Deltat/\tau_c = 500','\Deltat/\tau_c = 5000','\Deltat/\tau_c = 50000'};
xlim = [0,tnmax];
ylim = [-4,4]*1e-8;
xlab = 't/\tau_c';
ylab = '\Deltan/n_0';
tit = '';
colors = {'r','b','g','m'};
graph1D_jd(0:dtn_list(1):tnmax,normf0_u_1{1}-1,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,20,gca,0.9,0.7,0.7);
for idtn = 2:length(dtn_list);
    graph1D_jd(0:dtn_list(idtn):tnmax,normf0_u_1{idtn}-1,0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,20,gca);
end
legend(leg)
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-8)
%
figure(2),clf
%
ylim = [-4,4]*1e-3;
graph1D_jd(0:dtn_list(1):tnmax,normf0_u_2{1}-1,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,20,gca,0.9,0.7,0.7);
for idtn = 2:length(dtn_list);
    graph1D_jd(0:dtn_list(idtn):tnmax,normf0_u_2{idtn}-1,0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,20,gca);
end
legend(leg)
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-3)
%
figure(3),clf
%
ylim = [-5,5]*1e-8;
graph1D_jd(0:dtn_list(1):tnmax,normf0_nu_1{1}-1,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,20,gca,0.9,0.7,0.7);
for idtn = 2:length(dtn_list);
    graph1D_jd(0:dtn_list(idtn):tnmax,normf0_nu_1{idtn}-1,0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,20,gca);
end
legend(leg)
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-8)
%
figure(4),clf
%
ylim = [-4,4]*1e-3;
graph1D_jd(0:dtn_list(1):tnmax,normf0_nu_2{1}-1,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,20,gca,0.9,0.7,0.7);
for idtn = 2:length(dtn_list);
    graph1D_jd(0:dtn_list(idtn):tnmax,normf0_nu_2{idtn}-1,0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,20,gca);
end
legend(leg)
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-3)
%
residue_final_u_1
residue_final_u_2
residue_final_nu_1
residue_final_nu_2
%
print_jd(2,'fig_thermal_dtn_TiTe_u','.',1)
print_jd(2,'fig_thermal_dtn_TiTe2_u','.',2)
print_jd(2,'fig_thermal_dtn_TiTe_nu','.',3)
print_jd(2,'fig_thermal_dtn_TiTe2_nu','.',4)
%	    
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);