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
permission = test_permissions_yp;
%
if ~permission 
    disp('Please move the script to a local folder where you have write permission before to run it')
    return;
end
%
% *********************** This part must be specified by the user *****************************
%
% printing option
%
id_simul = 'Runaway_alpha3_sync';%Simulation ID
p_opt = -1;% printing and saving options : (-1) do nothing (0) print figures (1) print figures and save figures and results (2) save figures and results
%
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
% calculation mode : (0) quasi steady state (1) time evolution
%
opt.timevol = 1;
%
% normalized electric field (with respect to the Critical field Ec)
%
alpha = 3;% E/Ec
%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 0.01;% Te/mc2
%
% the ratio of the syncrotron reaction force to the collisional drag scales as bhat^2
% -> set bhat = 0 or opt.synchro_mode = 0 to ignore syncrotron reaction force
%
% note : 
%   - without the syncrotron reaction force, and with a single cold ion
%   species of charge Zi, the normalized runaway rate - with respect to the
%   electron density and ee collision time - only depends upon Zi, alpha and betath2
%
%   - with the syncrotron reaction force, an additional parameter is
%   provived by bhat
%
%   - the link between wpr=wc2/wp2 and bhat is : 
%       bhat^2 = wpr*(2/3)*betath^3/ln(Lambda)
%   
%   - the magnetic field being fixed, the density is adjusted in LUKE according to bhat
%
bhat = 0.03;
%
opt.synchro_mode = 1;
%
% ion charge (single species, cold ions)
%
Zi = 1;
%
Emin = NaN;%runaway energy threshold in MeV (limit where electrons are "counted") 
% Emax = (sqrt(20^2*betath2+1)-1)*mc2/1e3;%1;%grid energy threshold in MeV [(sqrt(pnmax_S^2*betath2+1)-1)*mc2/1e3 = 0.63163 corresponds to pnmax_S = 20 for betath = 0.1]
%
% collision mode : 
% (0) : Relativistic Maxwellian background
% (1) : High-velocity limit
% (2) : Linearized Belaiev-Budker (momentum-conserving)
%
opt.coll_mode = 0;
opt.bounce_mode = 0;%1;% bounce-averaged calculation
opt.boundary_mode_f = 0;% Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
%
% normalization mode : 
% (0) : "free" mode
% (1) : "normalization of f0 maintained to its initial (maxwellian) value". DO NOT use in the runaway problem
% (2) : "normalization of f0 maintained to its value at the previous time". Use only in the runaway problem with (+1i)
% (... + 1i) : compensate for numerical error after each time step, acounting for boundary losses.
opt.norm_mode_f = 0;%+1i;   
%
% time grid (normalized to collision time) -> you can specify :
% - linear arbitrary grid with tn array                 : opt.tnmin = 0 ;opt.tn = 1000:1000:10000,dtn = NaN;opt.tnmin = 0
% - linear arbitrary grid with dtn array                : opt.tnmin = 0 ;opt.tn = NaN;dtn = 1000*ones(1,10);
% - linear grid with tnmax and grid step                : opt.tnmin = 0 ;opt.tn = 10000;dtn = 1000;
% - linear grid with tnmax and number of grid steps     : opt.tnmin = 0 ;opt.tn = 10000;dtn = 10i;
% - log grid with tnmin, tnmax and number of grid steps : opt.tnmin = 1 ;opt.tn = 10000;dtn = 10;
%
% opt.tnmin = 0;% > 0 for log scale
% opt.tn = 10000;% 10000 is time for asymptotic solution
% opt.dtn = 1000;% 10 time steps required for accurate runaway solution - see rundke_dtn
% graph.itdisp = [1,5,10];% display times - only used if opt.timevol > 0 
%
% opt.tnmin = 1;% > 0 for log scale
% opt.tn = 1e5;% 10000 is time for asymptotic solution
% opt.dtn = 51;% 10 time steps required for accurate runaway solution - see rundke_dtn
% graph.itdisp = 11:10:51;% display times - only used if opt.timevol > 0 
%
opt.tnmin = 1;% > 0 for log scale
opt.tn = 1e6;% 10000 is time for asymptotic solution
opt.dtn = 61;% 10 time steps required for accurate runaway solution - see rundke_dtn
graph.itdisp = 11:10:61;% display times - only used if opt.timevol > 0 
%
% momentum space grid -> you can specify nmhu_S and either 
% - the momentum grid pn_S directly
% - the parameters np_S, pnmax_S, np_tail, pnmax_S_tail as follows
%
grid.nmhu_S = 101;% number of pitch angle grid points
grid.np_S = 101;% number of bulk momentum grid points
grid.pnmax_S = 20;%sqrt(((1 + Emax*1e3/mc2)^2 - 1)/betath2);% maximum of bulk momentum (normalized to pT) [pn = 28 corresponds to 1 MeV electrons for betath = 0.1]
grid.np_tail = 100;%0;% number of tail momentum grid points
grid.pnmax_S_tail = 20+100;% maximum of tail momentum (normalized to pT) [107,205,303,401,499,597] corresponds to [5,10,15,20,25,30] MeV electrons for betath = 0.1
%
% avalanche modelling : 
%
% dkeparam.pnmin0_KO is the low threshold on initial primary electrons for the knock-on operator
% The condition pnmin0_KO <= pnmax_S is enforced so that the source can be calculated
% - For pnmin0_KO = NaN, the limit is set to pnmax_S
%
% dkeparam.pnmax1_KO is the high threshold on initial secondary (bulk) electrons for the knock-on operator
% in principle, pnmax1_KO <= pnmin2_KO so that secondary electrons can only 'lose energy'
% - For pnmax1_KO = 0, the bulk population is taken as f(1)/fM(1), a logical estimate considering the sink term
% - For pnmax1_KO = NaN, the limit is set to pnmin2_KO
% 
% dkeparam.pnmin2_KO is the low threshold on final secondary electrons for the knock-on operator
% - If pnmin2_KO == NaN, the current value of pc (or pnmin_S) is used
% - If pnmin2_KO is imaginary, it is normalized to the actual thermal momentum (instead of reference)
%
% dkeparam.pnmax2_KO is the high threshold on final secondary electrons for the knock-on operator
% in principle, as rosenbluth assumes p0 > p1 we must separate the domain of source runaways (ex : 1MeV) from that of secondary electrons.
% Therefore, we should ensure pnmax2_KO <= pnmin0_KO
% - For pnmax2_KO = NaN, the limit is set to pnmin0_KO
% - If pnmax2_KO > pnmax_S (which violate the principle described above), the source between pnmax_S and pnmax2_KO is calculated as a "number"
%
opt.avalanche_mode = false;%true;%
opt.pnmin0_KO = NaN;% pnmin0_KO = 28 corresponds to 1 MeV electrons for betath = 0.1
opt.pnmax1_KO = 0;%NaN;%grid.pnmax_S;%
opt.pnmin2_KO = 1i;%NaN;%1;% 1i is the "natural" limit as for lower energies it is simply the identity operator
opt.pnmax2_KO = NaN;%100;% 
%
path_simul = '';%Simulation path
%
if opt.bounce_mode == 0,
    id_equil = 'TScyl';% cylindrical equilibrium, rho_S has no effect
else
    id_equil = 'TScirc_e1';% toroidal equilibirum with a/R = 1 : then rho_S = r/R
end
id_wave = '';
%
rho_S = 0.5;
%
if alpha == 2,
    %
    % E/Ec = 2
    %
    graph.ylim_norm = [1e-25,1e1];
    graph.ytick_norm = 10.^(-25:5:5);
    graph.ylim_gamma = [1e-26,1e-12];
    graph.ytick_gamma = 10.^(-26:4:-12);
    graph.ylim_f = [1e-45,1e5];
    graph.ytick_f = 10.^(-45:5:5);
elseif alpha == 3,
    %
    % E/Ec = 3
    %
    graph.ylim_norm = [1e-25,1e1];
    graph.ytick_norm = 10.^(-25:5:5);
    graph.ylim_gamma = [1e-32,1e-8];
    graph.ytick_gamma = 10.^(-32:4:-8);
    graph.ylim_f = [1e-35,1e5];
    graph.ytick_f = 10.^(-35:5:5);
elseif alpha == 5,
    %
    % E/Ec = 5
    %
    graph.ylim_norm = [1e-9,1e1];
    graph.ytick_norm = 10.^(-10:2:2);
    graph.ylim_gamma = [1e-12,1e-4];
    graph.ytick_gamma = 10.^(-12:2:-4);
else
    graph.ylim_norm = NaN;
    graph.ylim_gamma = NaN;
end
%
%************************************************************************************************************************************
%
opt.pnmin_S = sqrt(((1 + Emin*1e3/mc2)^2 - 1)/betath2);
wpr = bhat*1i;
%
% RUN LUKE
%
[RR,mksa,Ec,f,tn,tRR,tnorm] = frundke_runaway(id_simul,alpha,betath2,wpr,Zi,opt,grid,id_equil,id_wave,rho_S);
%
%************************************************************************************************************************************
%
% PROCESS DATA
%
fproc_runaway(RR,mksa,Ec,f,tn,tRR,tnorm,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,p_opt,id_simul);
%
%************************************************************************************************************************************
%
if p_opt > 0,
    filename = [path_simul,'DKE_RESULTS_',id_simul,'.mat'];
    save(filename);
    info_dke_yp(2,['Data saved in ',filename]);
end