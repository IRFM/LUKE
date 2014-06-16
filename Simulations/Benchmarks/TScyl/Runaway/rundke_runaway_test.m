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
% *********************** This part must be specified by the user *****************************
%
% printing option
%
id_simul = 'Runaway_test_a5_lin_fine_long';%Simulation ID
p_opt = 2;% printing and saving options : (-1) do nothing (0) print figures (1) print figures and save figures and results (2) save figures and results
%
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
Emin = 1;%runaway energy threshold in MeV
Emax = 1;%grid energy threshold in MeV
%
% calculation mode : (0) quasi steady state (1) time evolution
%
opt.timevol = 1;
%
% normalized electric field (with respect to the Critical field Ec)
%
alpha = 5;%E/Ec
%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 0.01;
%
% the ratio of the syncrotron reaction force to the collisional drag scales as wc2/wp2
% -> set wpr = 0 or opt.synchro_mode = 0 to ignore syncrotron reaction force
%
wpr = 0;%([Bt]*qe/me)^2/([ne19]*1e19*qe^2/(me*e0));%wc2/wp2
%
opt.synchro_mode = 0;
%
% ion charge (single species, cold ions)
%
Zi = 1;
%
% collision mode : 
% (0) : Relativistic Maxwellian background
% (1) : High-velocity limit
% (2) : Linearized Belaiev-Budker (momentum-conserving)
%
opt.coll_mode = 0;
opt.bounce_mode = 0;% bounce-averaged calculation
opt.boundary_mode_f = 0;% Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
opt.norm_mode_f = 0;%Local normalization of f0 at each iteration (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
% time grid (normalized to collision time) -> you can specify :
% - linear arbitrary grid with tn array                 : opt.tnmin = 0 ;opt.tn = 1000:1000:10000,dtn = NaN;opt.tnmin = 0
% - linear arbitrary grid with dtn array                : opt.tnmin = 0 ;opt.tn = NaN;dtn = 1000*ones(1,10);
% - linear grid with tnmax and grid step                : opt.tnmin = 0 ;opt.tn = 10000;dtn = 1000;
% - linear grid with tnmax and number of grid steps     : opt.tnmin = 0 ;opt.tn = 10000;dtn = 10i;
% - log grid with tnmin, tnmax and number of grid steps : opt.tnmin = 1 ;opt.tn = 10000;dtn = 10;
%
% opt.tnmin = 1;%0;% > 0 for log scale
% opt.tn = 1e4;%1e5;% 10000 is time for asymptotic solution
% opt.dtn = 81;%1001;% 10 time steps required for accurate runaway solution - see rundke_dtn
% graph.itdisp = 21:20:81;%201:200:1001;% display times - only used if opt.timevol > 0 
%
opt.tnmin = 0;% > 0 for log scale
opt.tn = 10000;%100000;% 10000 is time for asymptotic solution
opt.dtn = 10;%1000;%1000;% 10 time steps required for accurate runaway solution - see rundke_dtn
graph.itdisp = 200:200:1000;%20:20:100;%[1,5,10];% display times - only used if opt.timevol > 0 
%
% momentum space grid -> you can specify nmhu_S and either 
% - the momentum grid pn_S directly
% - the parameters np_S, pnmax_S, np_tail, pnmax_S_tail as follows
%
% grid.nmhu_S = 101;% number of pitch angle grid points
% grid.np_S = 101;% number of bulk momentum grid points
% %grid.pnmax_S = 28;% maximum of bulk momentum (normalized to pT) [pn = 28 corresponds to 1 MeV electrons for betath = 0.1]
% grid.pnmax_S = sqrt(((1 + Emax*1e3/mc2)^2 - 1)/betath2);% maximum of bulk momentum (normalized to pT)
% grid.np_tail = 0;%100;% number of tail momentum grid points
% grid.pnmax_S_tail = 5i;% maximum of tail momentum (normalized to pT)
%
grid.nmhu_S = 101;% number of pitch angle grid points
grid.np_S = 141;% number of bulk momentum grid points
grid.pnmax_S = 28;%sqrt(((1 + Emax*1e3/mc2)^2 - 1)/betath2);% maximum of bulk momentum (normalized to pT) [pn = 28 corresponds to 1 MeV electrons for betath = 0.1]
grid.np_tail = 331;%100;% number of tail momentum grid points
grid.pnmax_S_tail = 597;% maximum of tail momentum (normalized to pT) [107,205,303,401,499,597] corresponds to [5,10,15,20,25,30] MeV electrons for betath = 0.1
%
opt.pnmin_S = grid.pnmax_S;% to only count RE beyond 1MeV
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
opt.pnmin0_KO = 28;% pnmin0_KO = 28 corresponds to 1 MeV electrons for betath = 0.1
opt.pnmax1_KO = 0;%NaN;%grid.pnmax_S;%
opt.pnmin2_KO = 1i;%NaN;%1;% 1i is the "natural" limit as for lower energies it is simply the identity operator
opt.pnmax2_KO = NaN;%100;% 
%
path_simul = '';%Simulation path
%
id_equil = '';%'TScirc';%'TScyl';%
id_wave = '';
%
rho_S = 0.005;
%
if alpha == 10,
    %
    % E/Ec = 10
    %
    graph.ylim_norm = [1e-4,2e-0];
    graph.ytick_norm = 10.^(-4:1);
    %
    graph.ylim_gamma = [1e-4,5e-3];
    graph.ytick_gamma = 10.^(-5:-2);
    %
elseif alpha == 5,
    %
    % E/Ec = 5
    %
    graph.ylim_norm = [1e-9,1e1];
    graph.ytick_norm = 10.^(-10:2:2);
    %
    graph.ylim_gamma = [1e-12,1e-4];
    graph.ytick_gamma = 10.^(-12:2:-4);
else
    graph.ylim_norm = NaN;
    graph.ylim_gamma = NaN;
end
%
%************************************************************************************************************************************
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