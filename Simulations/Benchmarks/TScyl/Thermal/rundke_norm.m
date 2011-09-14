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
id_simul = 'Thermal_norm';%Simulation ID
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
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dtn = 10000;
nit = 10;
tnmax = dtn*nit;
%
dkeparam.coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
dkeparam.dtn = dtn;
dkeparam.tn = tnmax;
dkeparam.prec0_f = 0;%to reach end of Legendre iterations
%
% Case Ti=Te, free mode
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
normf0_1_0 = NaN(1,nit);
normf0_1_1 = NaN(1,nit);
normf0_1_2 = NaN(1,nit);
normf0_2_0 = NaN(1,nit);
normf0_2_1 = NaN(1,nit);
normf0_2_2 = NaN(1,nit);
%
residue_1_0 = NaN(1,nit);
residue_1_1 = NaN(1,nit);
residue_1_2 = NaN(1,nit);
residue_2_0 = NaN(1,nit);
residue_2_1 = NaN(1,nit);
residue_2_2 = NaN(1,nit);
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
for itn = 1:nit,
    normf0_1_0(itn) = dke_out.normf0{itn}(end);
    residue_1_0(itn) = dke_out.residu_f{itn}(end);
end
%
% Case Ti=Te, boundary mode
%
dkeparam.boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
for itn = 1:nit,
    normf0_1_1(itn) = dke_out.normf0{itn}(end);
    residue_1_1(itn) = dke_out.residu_f{itn}(end);
end
%
% Case Ti=Te, norm mode
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
for itn = 1:nit,
    normf0_1_2(itn) = dke_out.normf0{itn}(end);
    residue_1_2(itn) = dke_out.residu_f{itn}(end);
end
%
% Case Ti=Te/2, free mode
%
equil.pzTi = equil.pzTi/2;
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
for itn = 1:nit,
    normf0_2_0(itn) = dke_out.normf0{itn}(end);
    residue_2_0(itn) = dke_out.residu_f{itn}(end);
end
%
% Case Ti=Te/2, boundary mode
%
dkeparam.boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
for itn = 1:nit,
    normf0_2_1(itn) = dke_out.normf0{itn}(end);
    residue_2_1(itn) = dke_out.residu_f{itn}(end);
end
%
% Case Ti=Te/2, norm mode
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
for itn = 1:nit,
    normf0_2_2(itn) = dke_out.normf0{itn}(end);
    residue_2_2(itn) = dke_out.residu_f{itn}(end);
end
%
figure(1),clf
%
leg = {'Free Mode (\times 10^3)','Fixed point','Normalization (\times 10^3)'};
xlim = [0,tnmax];
ylim = [-8,8]*1e-5;
xlab = 't/\tau_c';
ylab = '\Deltan/n_0';
tit = '';
colors = {'r','b','g','m'};
siz = 20+14i;
%
graph1D_jd(0:dtn:tnmax,[0,(normf0_1_0-1)*1e3],0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,siz,gca,0.9,0.7,0.7);
graph1D_jd(0:dtn:tnmax,[0,normf0_1_1-1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{2},2,siz,gca);
graph1D_jd(0:dtn:tnmax,[0,(normf0_1_2-1)*1e3],0,0,'','','',leg,xlim,ylim,'-','none',colors{3},2,siz,gca);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-8:4:8]*1e-5)
%
figure(2),clf
%
leg = {'Free Mode','Fixed point','Normalization'};
ylim = [-4,4]*1e-3;
%
graph1D_jd(0:dtn:tnmax,[0,normf0_2_0-1],0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1},2,siz,gca,0.9,0.7,0.7);
graph1D_jd(0:dtn:tnmax,[0,normf0_2_1-1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{2},2,siz,gca);
graph1D_jd(0:dtn:tnmax,[0,normf0_2_2-1],0,0,'','','',leg,xlim,ylim,'-','none',colors{3},2,siz,gca);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-3)
%
% residue
%
figure(3),clf
%
ylim = 10.^[-23,-21];
ytick = 10.^[-23:-21];
ylab = 'convergence parameter';
%
graph1D_jd(dtn:dtn:tnmax,residue_1_0,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','+',colors{1},2,siz,gca,0.9,0.7,0.7);
graph1D_jd(dtn:dtn:tnmax,residue_1_1,0,1,'','','',NaN,xlim,ylim,'-','+',colors{2},2,siz,gca);
graph1D_jd(dtn:dtn:tnmax,residue_1_2,0,1,'','','',leg,xlim,ylim,'-','+',colors{3},2,siz,gca);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',ytick)
%
figure(4),clf
%
graph1D_jd(dtn:dtn:tnmax,residue_2_0,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','+',colors{1},2,siz,gca,0.9,0.7,0.7);
graph1D_jd(dtn:dtn:tnmax,residue_2_1,0,1,'','','',NaN,xlim,ylim,'-','+',colors{2},2,siz,gca);
graph1D_jd(dtn:dtn:tnmax,residue_2_2,0,1,'','','',leg,xlim,ylim,'-','+',colors{3},2,siz,gca);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',ytick)
%
print_jd(2,'fig_thermal_norm_TiTe','.',1)
print_jd(2,'fig_thermal_norm_TiTe2','.',2)
%
print_jd(2,'fig_thermal_norm_TiTe_res','.',3)
print_jd(2,'fig_thermal_norm_TiTe2_res','.',4)
%	    
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);