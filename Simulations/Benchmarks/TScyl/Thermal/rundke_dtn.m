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
if exist('dmumpsmex','file'),
	invproc = -2;% MUMPSMEX
else
	invproc = 1;
end
%
boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
%
tnmax = 100000;%asymptotic time
dtn_list = [500,5000,50000];%time steps
%
pzTi = equil.pzTi;
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
dkeparam.invproc = invproc;
%
dkeparam.prec0_f = 0;%to reach end of Legendre iterations
dkeparam.tn = tnmax;
%
ndtn = length(dtn_list);
%
normf0_u_1 = cell(1,ndtn);
normf0_u_2 = cell(1,ndtn);
normf0_nu_1 = cell(1,ndtn);
normf0_nu_2 = cell(1,ndtn);
%
residue_u_1 = cell(1,ndtn);
residue_u_2 = cell(1,ndtn);
residue_nu_1 = cell(1,ndtn);
residue_nu_2 = cell(1,ndtn);
%
for idtn = 1:ndtn,
    %
    dtn = dtn_list(idtn);
    dkeparam.dtn = dtn;
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    for itn = 1:length(dke_out.residu_f),
        normf0_u_1{idtn}(itn) = dke_out.normf0{itn}(end);
        residue_u_1{idtn}(itn) = dke_out.residu_f{itn}(end);
    end
end
%
% Case Ti=Te/2, uniform grid
%
equil.pzTi = pzTi/2;
%
for idtn = 1:ndtn;
    %
    dtn = dtn_list(idtn);
    dkeparam.dtn = dtn;
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    for itn = 1:length(dke_out.residu_f),
        normf0_u_2{idtn}(itn) = dke_out.normf0{itn}(end);
        residue_u_2{idtn}(itn) = dke_out.residu_f{itn}(end);
    end
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
dkeparam.invproc = invproc;
%
dkeparam.prec0_f = 0;%to reach end of Legendre iterations
dkeparam.tn = tnmax;
%
equil.pzTi = pzTi;
%
for idtn = 1:ndtn;
    %
    dtn = dtn_list(idtn);
    dkeparam.dtn = dtn;
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    for itn = 1:length(dke_out.residu_f),
        normf0_nu_1{idtn}(itn) = dke_out.normf0{itn}(end);
        residue_nu_1{idtn}(itn) = dke_out.residu_f{itn}(end);
    end
end
%
% Case Ti=Te/2, non-uniform grid
%
equil.pzTi = pzTi/2;
%
for idtn = 1:ndtn;
    %
    dtn = dtn_list(idtn);
    dkeparam.dtn = dtn;
    %
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    for itn = 1:length(dke_out.residu_f),
        normf0_nu_2{idtn}(itn) = dke_out.normf0{itn}(end);
        residue_nu_2{idtn}(itn) = dke_out.residu_f{itn}(end);
    end
end
%
% density conservation
%
figure(1),clf
%
leg = {'\Deltat/\tau_c = 500','\Deltat/\tau_c = 5000','\Deltat/\tau_c = 50000','Location','SouthWest'};
xlim = [0,tnmax];
ylim = [-4,4]*1e-8;
xlab = 't/\tau_c';
ylab = '\Deltan/n_0';
tit = '';
colors = {'r','b','g'};
siz = 20+14i;
%
for idtn = 1:ndtn-1;
    graph1D_jd(0:dtn_list(idtn):tnmax,[0,normf0_u_1{idtn}-1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,siz,gca);
end
graph1D_jd(0:dtn_list(end):tnmax,[0,normf0_u_1{end}-1],0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-8)
%
figure(2),clf
%
ylim = [-4,4]*1e-3;
%
for idtn = 1:ndtn-1;
    graph1D_jd(0:dtn_list(idtn):tnmax,[0,normf0_u_2{idtn}-1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,siz,gca);
end
graph1D_jd(0:dtn_list(end):tnmax,[0,normf0_u_2{end}-1],0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-3)
%
figure(3),clf
%
ylim = [-4,4]*1e-8;
%
for idtn = 1:ndtn-1;
    graph1D_jd(0:dtn_list(idtn):tnmax,[0,normf0_nu_1{idtn}-1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,siz,gca);
end
graph1D_jd(0:dtn_list(end):tnmax,[0,normf0_nu_1{end}-1],0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-8)
%
figure(4),clf
%
ylim = [-4,4]*1e-3;
%
for idtn = 1:ndtn-1;
    graph1D_jd(0:dtn_list(idtn):tnmax,[0,normf0_nu_2{idtn}-1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{idtn},2,siz,gca);
end
graph1D_jd(0:dtn_list(end):tnmax,[0,normf0_nu_2{end}-1],0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',[-4:2:4]*1e-3)
%
% residue
%
figure(5),clf
%
ylim = [1e-24,2e-21];
ytick = 10.^[-24:-21];
ylab = 'Legendre convergence parameter';
%
for idtn = 1:ndtn-1;
    graph1D_jd(dtn_list(idtn):dtn_list(idtn):tnmax,residue_u_1{idtn},0,1,'','','',NaN,xlim,ylim,'-','+',colors{idtn},2,siz,gca);
end
graph1D_jd(dtn_list(end):dtn_list(end):tnmax,residue_u_1{end},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','+',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',ytick)
%
figure(6),clf
%
for idtn = 1:ndtn-1;
    graph1D_jd(dtn_list(idtn):dtn_list(idtn):tnmax,residue_u_2{idtn},0,1,'','','',NaN,xlim,ylim,'-','+',colors{idtn},2,siz,gca);
end
graph1D_jd(dtn_list(end):dtn_list(end):tnmax,residue_u_2{end},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','+',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',ytick)
%
figure(7),clf
%
for idtn = 1:ndtn-1;
    graph1D_jd(dtn_list(idtn):dtn_list(idtn):tnmax,residue_nu_1{idtn},0,1,'','','',NaN,xlim,ylim,'-','+',colors{idtn},2,siz,gca);
end
graph1D_jd(dtn_list(end):dtn_list(end):tnmax,residue_nu_1{end},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','+',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',ytick)
%
figure(8),clf
%
for idtn = 1:ndtn-1;
    graph1D_jd(dtn_list(idtn):dtn_list(idtn):tnmax,residue_nu_2{idtn},0,1,'','','',NaN,xlim,ylim,'-','+',colors{idtn},2,siz,gca);
end
graph1D_jd(dtn_list(end):dtn_list(end):tnmax,residue_nu_2{end},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','+',colors{end},2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*tnmax)
set(gca,'ytick',ytick)
%
print_jd(p_opt,'fig_thermal_dtn_TiTe_u','.',1)
print_jd(p_opt,'fig_thermal_dtn_TiTe2_u','.',2)
print_jd(p_opt,'fig_thermal_dtn_TiTe_nu','.',3)
print_jd(p_opt,'fig_thermal_dtn_TiTe2_nu','.',4)
%
print_jd(p_opt,'fig_thermal_dtn_TiTe_u_res','.',5)
print_jd(p_opt,'fig_thermal_dtn_TiTe2_u_res','.',6)
print_jd(p_opt,'fig_thermal_dtn_TiTe_nu_res','.',7)
print_jd(p_opt,'fig_thermal_dtn_TiTe2_nu_res','.',8)
%	    
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);