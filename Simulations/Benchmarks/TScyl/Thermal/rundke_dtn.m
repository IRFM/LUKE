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
id_simul = 'Thermal';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [0.001];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = '';%For DKE code parameters
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
tnmax = 10000;%number of iterations
dtn_list = [100,1000];
%boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.boundary_mode_f = 0;
dkeparam.coll_mode = coll_mode;
dkeparam.prec0_f = -1;
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f(idtn) = round(tnmax/dtn);
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f(idtn);
    [Znorm_u,Zcurr_u,ZP0_u,dke_out_u,radialDKE_u,equilDKE_u,momentumDKE_u,gridDKE_u,Zmomcoef_u,Zbouncecoef_u,Zmripple_u,mksa,XXsinksource_u] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_u{idtn} = dke_out_u.normf0;
end
%
% id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
% path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
% [dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
% dkeparam.boundary_mode_f = boundary_mode_f;
% dkeparam.coll_mode = coll_mode;
% dkeparam.prec0_f = -1;
% if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 1;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f(idtn) = round(tnmax/dtn);
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f(idtn);
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0{idtn} = dke_out.normf0;
end
%
figure(1),clf
%leg = {'Uniform','Non-uniform'};
leg = {'Free mode','f(0) enforced'};
xlim = [0,tnmax];
xlab = 'Integration time step (\times\tau_c)';
ylab = 'Normalized n_e variations';
tit = 'Uniform grid, T_i = T_e';
graph1D_jd([0:nit_f(1)]*dtn_list(1),normf0_u{1}-1,0,0,xlab,ylab,tit,NaN,xlim,NaN,'-','+','r',2,20,gca,0.9,0.7,0.5);
graph1D_jd([0:nit_f(1)]*dtn_list(1),normf0{1}-1,0,0,'','','',leg,xlim,NaN,'-','o','b',2,20,gca);
for idtn = 2:length(dtn_list);
    graph1D_jd([0:nit_f(idtn)]*dtn_list(idtn),normf0_u{idtn}-1,0,0,'','','',NaN,xlim,NaN,'-','+','r',2,20,gca);
    graph1D_jd([0:nit_f(idtn)]*dtn_list(idtn),normf0{idtn}-1  ,0,0,'','','',NaN,xlim,NaN,'-','o','b',2,20,gca);
end
%
% Case with Ti = Te/2
%
% id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
% path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
% [dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
% equil.pzTi = equil.pzTi/2;
% dkeparam.boundary_mode_f = boundary_mode_f;
% dkeparam.coll_mode = coll_mode;
% dkeparam.prec0_f = -1;
% if exist('dmumpsmex');dkeparam.invproc = -2;end
%
equil.pzTi = equil.pzTi/2;
dkeparam.boundary_mode_f = 0;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f(idtn) = round(tnmax/dtn);
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f(idtn);
    [Znorm_u,Zcurr_u,ZP0_u,dke_out_u,radialDKE_u,equilDKE_u,momentumDKE_u,gridDKE_u,Zmomcoef_u,Zbouncecoef_u,Zmripple_u,mksa,XXsinksource_u] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_2_u{idtn} = dke_out_u.normf0;
end
%
% id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
% path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
% [dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
% equil.pzTi = equil.pzTi/2;
% dkeparam.boundary_mode_f = boundary_mode_f;
% dkeparam.coll_mode = coll_mode;
% dkeparam.prec0_f = -1;
% if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 1;
%
for idtn = 1:length(dtn_list);
    dtn = dtn_list(idtn);
    nit_f(idtn) = round(tnmax/dtn);
    dkeparam.dtn = dtn;
    dkeparam.nit_f = nit_f(idtn);
    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    normf0_2{idtn} = dke_out.normf0;
end
%
figure(2),clf
%leg = {'Uniform','Non-uniform'};
%xlim = [0,tnmax];
%xlab = 'Integration time step (\times\tau_c)';
%ylab = 'Normalized n_e variations';
tit = 'Uniform grid, T_i = T_e/2';
graph1D_jd([0:nit_f(1)]*dtn_list(1),normf0_2_u{1}-1,0,0,xlab,ylab,tit,NaN,xlim,NaN,'-','+','r',2,20,gca,0.9,0.7,0.5);
graph1D_jd([0:nit_f(1)]*dtn_list(1),normf0_2{1}-1,0,0,'','','',leg,xlim,NaN,'-','o','b',2,20,gca);
for idtn = 2:length(dtn_list);
    graph1D_jd([0:nit_f(idtn)]*dtn_list(idtn),normf0_2_u{idtn}-1,0,0,'','','',NaN,xlim,NaN,'-','+','r',2,20,gca);
    graph1D_jd([0:nit_f(idtn)]*dtn_list(idtn),normf0_2{idtn}-1  ,0,0,'','','',NaN,xlim,NaN,'-','o','b',2,20,gca);
end
%	    
%************************************************************************************************************************************
%
print_jd(2,'fig_norm_TiTe','.',1)
print_jd(2,'fig_norm_TiTe2','.',2)
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);