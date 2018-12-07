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
permission = test_permissions_yp;
%
if ~permission 
    disp('Please move the script to a local folder where you have write permission before to run it')
    return;
end
%
% *********************** This part must be specified by the user *****************************
%
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
id_simul = 'Quench_ohm_nosync';%Simulation ID
%
% proc options
%
p_opt = 3;% printing and saving options : (-1) do nothing (0) print figures (1) print figures and save figures and results (2) save figures and results
s_opt = true;% save distribution in file
%
f_opt = false;%true;% display electron distribution
c_opt = true;% option for cylindrical calculation
%
% current and electric field
%
j0 = 1;%NaN;% initial current density (MA/m²)
id_wave = '';%'LH_karney_mod_rev';%'';% for non empty id_wave, the initial current density is carried by the wave, with the diffusion coefficient adapted accordingly
%
opt.tol = 1e-3;% tolerance of electric field convergence
opt.maxiconv = 20;% max # of iterations of electric field convergence
opt.efield0 = 0.01;% initial guess for the electric field
%
% temperature evolution :
%
%   o (0) : constant
%   o (1) : power law     : Te = Te0*(1-t/tq)^(2/3) 
%   o (2) : exp. law      : Te = Tef + (Te0-Tef)*exp(-t/tq) 
%   o (3) : step function : Te = Tef
%   o (4) : arena         : Te = Tef + (Te0-Tef)*exp(-(t/tq)^2) 
%
opt.T = 4;%1;%
%
betath0 = 0.1;% 0.01 corresponds to 5.1 keV
betathf = 0.01;% 0.01 corresponds to 51 eV
%
% the ratio of the syncrotron reaction force to the collisional drag scales as wc2/wp2
% -> set wpr = 0 or opt.synchro_mode = 0 to ignore syncrotron reaction force
%
wpr = 0;%([4]*qe/me)^2/([1e19]*qe^2/(me*e0));%wc2/wp2
%
opt.synchro_mode = 0;
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
opt.bounce_mode = 0;% bounce-averaged calculation
opt.boundary_mode_f = 0;% Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
opt.norm_mode_f = 0;%Local normalization of f0 at each iteration (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
% time grid
%
% opt.tnq = 4;% opt.T = 0 or opt.T = 1 or opt.T = 3
% opt.tnq = 2;% opt.T = 2
opt.tnq = 50;% opt.T = 4
%
opt.tnmax = 500;%NaN;%5;%50;%
%
% if opt.tnmax = NaN, the simulation time tnmax is calculated as a function of opt.T and opt.tnq :
% 
%   - opt.T = 0 : opt.tnmax = opt.tnq
%   - opt.T = 1 : opt.tnmax = opt.tnq*(1 - (betathf/betath0)^3))
%   - opt.T = 2 : opt.tnmax = 2*opt.tnq
%   - opt.T = 3 : opt.tnmax = opt.tnq
%   - opt.T = 4 : opt.tnmax = 2*opt.tnq
%
opt.nit = 100;%50;% number of time steps (lin scale)
%
graph.itdisp = 10:10:50;%[1,5,10];% display times - only used if opt.timevol > 0 
%
% momentum grid
%
% momentum space grid -> you can specify nmhu_S and either 
% - the momentum grid pn_S directly
% - the parameters np_S, pnmax_S, np_tail, pnmax_S_tail as follows
%
grid.nmhu_S = 101;% number of pitch angle grid points
grid.np_S = 141;% number of bulk momentum grid points
grid.pnmax_S = 28;%sqrt(((1 + Emax*1e3/mc2)^2 - 1)/betath2);% maximum of bulk momentum (normalized to pT) [pn = 28 corresponds to 1 MeV electrons for betath = 0.1]
grid.np_tail = 331;%100;% number of tail momentum grid points
grid.pnmax_S_tail = 597;% maximum of tail momentum (normalized to pT) [107,205,303,401,499,597] corresponds to [5,10,15,20,25,30] MeV electrons for betath = 0.1
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
if opt.bounce_mode == 0,
    id_equil = 'TScyl';% cylindrical equilibrium, rho_S has no effect
else
    id_equil = 'TScirc_e1';% toroidal equilibirum with a/R = 1 : then rho_S = r/R
end
%
rho_S = 0.5;
%
opt.loadstructs = false;%true;% (true) use loadstructs, (false) recalculate all structures (for verification)
%
% graph.ylim_norm = [1e-35,1e1];
% graph.ytick_norm = 10.^(-35:5:5);
% graph.ylim_gamma = [1e-34,1e-18];
% graph.ytick_gamma = 10.^(-34:4:-18);
% graph.ylim_f = [1e-45,1e5];
% graph.ytick_f = 10.^(-45:5:5);
%
%************************************************************************************************************************************
%
opt.pnmin_S = sqrt(((1 + Emin*1e3/mc2)^2 - 1))/betath0;
%
% RUN LUKE
%
[xTe,Efield,J,pfM,pf0,pfbM,savedata,trbetath] = frundke_quench(id_simul,j0,betath0,betathf,wpr,Zi,opt,grid,id_equil,id_wave,rho_S);
%
%************************************************************************************************************************************
%
% PROCESS DATA
%
fproc_quench(xTe,Efield,J,pfM,pf0,pfbM,savedata,trbetath,graph,p_opt,f_opt,c_opt,id_simul);
%
%************************************************************************************************************************************
%
if s_opt,
    savestr = [path_simul,'LUKEDIST_',id_simul,'.mat'];
    save(savestr,'-struct','savedata');
    info_dke_yp(2,['Distribution data saved in ',savestr]);
end
%
if p_opt > 0,
    filename = [path_simul,'DKE_RESULTS_',id_simul,'.mat'];
    save(filename);
    info_dke_yp(2,['Simulation data saved in ',filename]);
end
%