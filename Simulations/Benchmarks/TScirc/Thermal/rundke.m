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
id_simul = 'Thermal';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [0.001];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = '';%For DKE code parameters
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
nit = 20;%number of iterations
boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
coll_mode = 2;%Relativistic collision operator: (0) Relativistic Maxwellian background, (1) High-velocity limit, (2) Linearized Belaiev-Budker (3) Non-relativistic Lorentz model, (4) Non-relativistic Maxwellian background
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.coll_mode = coll_mode;
dkeparam.dtn = dkeparam.tn;
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
[Znorm_u,Zcurr_u,ZP0_u,dke_out_u,radialDKE_u,equilDKE_u,momentumDKE_u,gridDKE_u,Zmomcoef_u,Zbouncecoef_u,Zmripple_u,mksa,XXsinksource_u] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
ne_u(1) = Znorm_u.x_0_fsav;
for i = 2:nit,
   [Znorm_u,Zcurr_u,ZP0_u,dke_out_u] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out_u.XXf0,[]);
    ne_u(i) = Znorm_u.x_0_fsav;
end
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.coll_mode = coll_mode;
dkeparam.dtn = dkeparam.tn;
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
ne(1) = Znorm.x_0_fsav;
for i = 2:nit,
   [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out.XXf0,[]);
    ne(i) = Znorm.x_0_fsav;
end
%
figure(1),clf,
graph1D_jd([1:nit]*dkeparam.dtn,ne_u*mksa.ne_ref,0,0,'Integration time step (t_{coll})','Electron density (10^{+19} m^{-3)}',['Maxwellian distr., dtn = ',int2str(dkeparam.dtn)],NaN,'','','-','+','r',2,20,gca,1,0.6,0.6);hold on
graph1D_jd([1:nit]*dkeparam.dtn,ne*mksa.ne_ref,0,0,'Integration time step (\tau_{coll})','Electron density (10^{+19} m^{-3)}',['Maxwellian distr., dtn = ',int2str(dkeparam.dtn)],NaN,'','','-','o','b',2,20,gca,1,0.6,0.6);
axis([0,nit*dkeparam.dtn,mksa.ne_ref*0.98,mksa.ne_ref*1.02])
line([0,20]*dkeparam.dtn,[mksa.ne_ref,mksa.ne_ref],'Color','red')
legend('Uniform','Non-uniform','Location','SouthWest');
%
% Case with Ti = Te/2
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
equil.pzTi = equil.pzTi/2;
dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.coll_mode = coll_mode;
dkeparam.dtn = dkeparam.tn;
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
[Znorm_u1,Zcurr_u1,ZP0_u1,dke_out_u1,radialDKE_u1,equilDKE_u1,momentumDKE_u1,gridDKE_u1,Zmomcoef_u1,Zbouncecoef_u1,Zmripple_u1,mksa,XXsinksource_u1] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
ne_u1(1) = Znorm_u1.x_0_fsav;
for i = 2:nit,
   [Znorm_u1,Zcurr_u1,ZP0_u1,dke_out_u1] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out_u1.XXf0,[]);
    ne_u1(i) = Znorm_u1.x_0_fsav;
end
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
equil.pzTi = equil.pzTi/2;
dkeparam.boundary_mode_f = boundary_mode_f;
dkeparam.coll_mode = coll_mode;
dkeparam.dtn = dkeparam.tn;
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
[Znorm1,Zcurr1,ZP01,dke_out1,radialDKE1,equilDKE1,momentumDKE1,gridDKE1,Zmomcoef1,Zbouncecoef1,Zmripple1,mksa,XXsinksource1] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
ne1(1) = Znorm1.x_0_fsav;
for i = 2:nit,
   [Znorm1,Zcurr1,ZP01,dke_out1] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,dke_out1.XXf0,[]);
    ne1(i) = Znorm1.x_0_fsav;
end
%
figure(2),clf,graph1D_jd([1:nit]*dkeparam.dtn,ne_u1*mksa.ne_ref,0,0,'Integration time step (t_{coll})','Electron density (10^{+19} m^{-3)}',['Maxwellian distr., dtn = ',int2str(dkeparam.dtn)],NaN,'','','-','+','r',2,20,gca,1,0.6,0.6);
graph1D_jd([1:nit]*dkeparam.dtn,ne1*mksa.ne_ref,0,0,'Integration time step (\tau_{coll})','Electron density (10^{+19} m^{-3)}',['Ti = Te/2, Maxwellian distr., dtn = ',int2str(dkeparam.dtn)],NaN,'','','-','o','b',2,20,gca,1,0.6,0.6);
axis([0,nit*dkeparam.dtn,mksa.ne_ref*0.97,mksa.ne_ref*1.03])
line([0,20]*dkeparam.dtn,[mksa.ne_ref,mksa.ne_ref],'Color','red')
legend('Uniform','Non-uniform','Location','SouthWest');
%
print_jd(p_opt,'thermaldensity','./figures',1)
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);