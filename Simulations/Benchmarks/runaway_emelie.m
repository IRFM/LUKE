%
% This script is used to run LUKE for the runaway problem
%
% by J. Decker, Y. Peysson and E. Nilsson
%
clear all
clear mex
clear functions
close all
warning('off')
%
% grid parameters
%
pnmax_S = 50;
np_S = 51;
pn_S = linspace(0,pnmax_S,np_S);
%
%
% normalized electric field (with respect to the Critical field Ec)
%
alpha = 10;%E/Ec
%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 0.01;%
%
% ion charge (single species, cold ions)
%
Zi = 1;%
%
% collision mode : 
% (0) : Relativistic Maxwellian background
% (1) : High-velocity limit
% (2) : Linearized Belaiev-Budker (momentum-conserving)
%
coll_mode = 0;
%
id_simul = 'Runaway';%Simulation ID
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%

% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
%id_simul = 'Runaway';%Simulation ID
%path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = 0.5;%0:0.01:1;%0.5%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%'NO_DISPLAY';%For output code display, files from Project_DKE/DISPLAY_FILES/
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
%dkeparam.np_S=301;
dkeparam.nmhu_S=201;

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
dkeparam.bounce_mode=1; %bounce average
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

%
disp('Simulation parameters : ')
disp(['coll_mode = ',num2str(coll_mode),' ; Te/mc2 = ',num2str(betath2),' ; E/Ec = ',num2str(alpha),' ; E/ED = ',num2str(alpha*betath2),' ; Zi = ',num2str(Zi)])
disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt(alpha*betath2))])%NR
disp(['Relativ. : pc/pT = ',num2str(1/sqrt((alpha - 1)*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt((alpha - 1)*betath2))])%rel
disp(' ')
disp(['--> LUKE RR (normalized to ne and tauc) : ',num2str(RR)])
disp('----------------------')
%
diary off
%
%************************************************************************************************************************************
%
% 
% eval(['save ','test','.mat']);
% %info_dke_yp(2,['Data saved in
% %',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'_',filename,'.mat']);
