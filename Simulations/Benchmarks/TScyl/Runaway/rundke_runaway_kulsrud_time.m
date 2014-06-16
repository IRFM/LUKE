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
id_simul = 'Runaway_kulsrud_time';%Simulation ID
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
alpha = 6e4;%1e5;%E/Ec
%
% temperature betath2 = Te/mc2
% (betath2 = 10^(-6) is validated for NR limit)
%
betath2 = 1e-6;
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
Zi = 1;%2;%
%
% collision mode : 
% (0) : Relativistic Maxwellian background
% (1) : High-velocity limit
% (2) : Linearized Belaiev-Budker (momentum-conserving)
%
opt.coll_mode = 0;
opt.bounce_mode = 0;%1;% bounce-averaged calculation
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
opt.tnmin = 1;%0;% > 0 for log scale
opt.tn = 1e4;%10000;% 10000 is time for asymptotic solution
opt.dtn = 81;%1000;% 10 time steps required for accurate runaway solution - see rundke_dtn
%
% momentum space grid -> you can specify nmhu_S and either 
% - the momentum grid pn_S directly
% - the parameters np_S, pnmax_S, np_tail, pnmax_S_tail as follows
%
grid.nmhu_S = 101;% number of pitch angle grid points
grid.np_S = 101;% number of bulk momentum grid points
grid.pnmax_S = 20;% maximum of bulk momentum (normalized to pT)
grid.np_tail = 0;%100;% number of tail momentum grid points
grid.pnmax_S_tail = 5i;% maximum of tail momentum (normalized to pT)
%
path_simul = '';%Simulation path
%
id_equil = 'TScyl';% cylindrical equilibrium, rho_S has no effect
id_wave = '';
%
rho_S = 0.5;
%
% graph.itdisp = 20:20:60;%[1,5,10];% display times - only used if opt.timevol > 0 
graph.itdisp = 21:20:81;%[1,5,10];% display times - only used if opt.timevol > 0 
%
if alpha == 1e5 && Zi == 2,
    graph.ylim_norm = [1e-4,2e-0];
    graph.ytick_norm = 10.^(-4:1);
    %
    graph.ylim_gamma = [5e-5,2e-3];
    graph.ytick_gamma = 10.^(-5:-2);
elseif alpha == 1e5 && Zi == 2,
    graph.ylim_norm = [1e-4,2e-0];
    graph.ytick_norm = 10.^(-4:1);
    %
    graph.ylim_gamma = [1e-6,1e-4];
    graph.ytick_gamma = 10.^(-6:-4);
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