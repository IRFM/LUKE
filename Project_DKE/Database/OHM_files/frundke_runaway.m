function [RR,mksa] = frundke_runaway(id_simul,alpha,betath2,Zi,coll_mode,pn_S)
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
%id_simul = 'Runaway';%Simulation ID
%path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = 0.5;%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc_peak';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display);
%
%**************************************************************************
%**************************************************************************
%
if exist('dmumpsmex','file') == 3,
    dkeparam.invproc = -2;
end
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.tn = 10000;%time for asymptotic solution with norm_mode_f = 1
dkeparam.dtn = 1000;%10 time steps required for accurate runaway solution - see rundke_dtn
dkeparam.coll_mode = coll_mode;% mode for the collision operator
dkeparam.bounce_mode=1;
%
equil.pzTi = 1e-10*ones(size(equil.pzTi));% cold ions
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath2*mc2*ones(size(equil.pTe));
%
equil.zZi = [1,1,1,Zi];
equil.pzni = [0;0;0;1/Zi]*equil.pne;% single ion species
%
epsi = alpha*betath2;
ohm = ohm_flat(equil,epsi);
%
if nargin >= 6,
    dkeparam.pn_S = pn_S;
end
%
[~,~,~,dke_out,~,~,~,~,~,~,~,mksa,~] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,'','','',[],[]);
%
RR = dke_out.XxRR_fsav(end,:);
%

