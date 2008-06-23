%R5-X2 - Test script for FEB calculations using the 3 temperatures model for the LH model
%
%Script for testing the dependencies of the Fast Electron Bremsstrahlung
%to the 3 temperatures model (Tpar, Tperp, Tback) for modeling the the LH
%wave. Two additional parameters may be considered, the fraction of
%non-thermal electrons and the upper limit cut-off (Ecut)
%
%by Y. Peysson (CEA/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/IRFM) (joan.decker@cea.fr)
%
clear all
clear mex
clear functions
close all
warning off
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul0 = '3Tmodel';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.3,0.7];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
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
id_hxr = 'TScirc';%For HXR diagnostic configuration
path_hxr = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path

%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,hxr,hxrparam] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple,'hxr',id_hxr,path_hxr);
%
%************************************************************************************************************************************
%
dkeparam.boundary_mode_f = 1;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
dkeparam.np_S = 61;
dkeparam.nmhu_S = 51;
dkeparam.pnmax_S = 30;
%
dkeparam.bounce_mode = 0;
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkedisplay.display_mode = 0;
%
%
% C3PO computing parameters
%
scanparam.clustermode.multithreading = 'automatic';%Intrinsic distributed computing with multicore machines (MatLab > R2007a). Can be set to 'automatic', or enforced to any value from 1 to more threads. WARNING: if the number of threads is larger than the number of cores, performances may be reduced.
scanparam.clustermode.scanloop.mode = 2;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)for the function main_C3PO_jd.m (MDC toolbox must be installed for option 1)
scanparam.clustermode.scanloop.timeout = 500;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
scanparam.clustermode.scanloop.size = 4;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
%
frac = 1e-3;
Ecut = 500;%[100,200,500,1000];
Tpar = 200;%logspace(1,3,5);
Tperp = 100;%[10,20,50,100,200,500,1000];
Tback = Tperp;
%
fieldside = NaN;%Distribution enforced corresponding to 'HFS' (theta = pi) or 'LFS' (theta = 0). If NaN, exact trapping effects of the magnetic equilibrium are considered.
chordview = 0;%No heliticity enforced: 0 (perp), 1 (forward) or -1 (backward). If NaN, the exact heliticity of the magnetic equilibrium is considered.
%
disp('---------------------------------------------------------------------');
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp('test',[],rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,[],transpfaste,[],[],[]);
return
%
for iEcut = 1:length(iEcut),arg_range{iEcut} = iEcut;end
[flag,norm,curr,Tph,Tph_star] = mdce_luke(@loop_scan_3Tmodel,{iEcut,frac,Ecut,Tpar,Tperp,Tback,Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,hxr,hxrparam,fieldside,chordview},1,arg_range,clusterparam);
%
norm1 = cell2mat(norm);
curr1 = cell2mat(curr);
Tph1 = cell2mat(Tph);
Tph_star1 = cell2mat(Tph_star);
%
for ivmin = 1:length(vmin),
	figure,graph1D_jd(D0,Tph1(ivmin:length(vmin):end,:),1,0,'D0','Tph',['v_{min}/v_{Ref} = ',num2str(vmin(ivmin))],NaN,[-1,4],[0,70],'-','none','r',2,20,gca,0.9,0.7,0.7);
	figure,graph1D_jd(D0,Tph_star1(ivmin:length(vmin):end,:),1,0,'D0','Tph',['v_{min}/v_{Ref} = ',num2str(vmin(ivmin))],NaN,[-1,4],[0,70],'-','none','r',2,20,gca,0.9,0.7,0.7);
end
%
