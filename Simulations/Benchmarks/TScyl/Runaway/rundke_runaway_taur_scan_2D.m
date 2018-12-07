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
scanstrs = {'alpha','sfac1','pnmax_S','np_tail','dtn','taurinv','betath2','zi'};
%
% warning : 
% - do not vary np_tail with opt_grid = 1
% - use taurinv, sfac1, pnmax_S, np_tail, dtn as scanstr1 only
% - use betath2 as scanstr1 only if Emin is not NaN
%
scanstr1 = 'taurinv';
scanstr2 = 'alpha';
nan_enforce = [8,1;10,1];% artefacts in search for bump (linked to discretization)
%
% scanstr1 = 'zi';
% scanstr2 = 'alpha';
% nan_enforce = [11,2];%NaN(0,2);% artefacts in search for bumb (linked to discretization)
%
% MDCE
%
mdce_mode = -1;%0;%3,%
remnum = 0;
returnmode = 0;
transpmode = true;
nproc_enforce = 4;
%
% scan parameters
%
scanvar.dtn = 'opt.dtn';
scanval.dtn = 1 + 8*[1:4,8:4:40];
scanlab.dtn = '\Deltat/\tau_c';
xlim.dtn = [0,350];
xlog.dtn = 0;
xtick.dtn = 0:50:350;
%
scanvar.np_tail = 'grid.np_tail';
scanval.np_tail = (988-28)./2.^(0:6);
scanlab.np_tail = 'n_p (tail)';
xlim.np_tail = (988-28)./2.^[7,-1];
xlog.np_tail = 1;
xtick.np_tail = fliplr(scanval.np_tail);
%    
scanvar.pnmax_S = 'grid.pnmax_S';
scanval.pnmax_S = 7:7:70;%140;
scanlab.pnmax_S = 'p_{max}/p_T (fine grid)';
xlim .pnmax_S= [0,77];%[0,147];%
xlog.pnmax_S = 0;
xtick.pnmax_S = scanval.pnmax_S(2:2:end);
%    
scanvar.sfac1 = 'grid.sfac1';
scanval.sfac1 = [1,2,4,6,10,20,40,60,100];
scanlab.sfac1 = '\Delta\xi_{fine}/\Delta\xi_0';
xlim.sfac1 = [0.5,200];%[0,147];%
xlog.sfac1 = 1;
xtick.sfac1 = scanval.sfac1;
%    
scanvar.alpha = 'alpha';
scanval.alpha = (1.5:0.25:4);%(1.5:0.5:6);%
scanlab.alpha = 'E/E_c';
scanind.alpha = 2;
xlim.alpha = [1.25,4.25];%[1,7];%
xlog.alpha = 0;
xtick.alpha = scanval.alpha(1:2:11);
iscandisp.alpha = 1:2:11;
%    
scanvar.betath2 = 'betath2';
scanval.betath2 = 10.^(-3:0.25:-1);
scanlab.betath2 = 'E/E_c';
scanind.betath2 = 3;
xlim.betath2 = 10.^[-3.25,-0.75];
xlog.betath2 = 1;
xtick.betath2 = scanval.betath2(1:2:9);
%    
scanvar.taurinv = 'taurinv';
scanval.taurinv = 0.3:0.15:1.95;%0.3:0.1:1.5;
scanlab.taurinv = '\tau_r^{-1}';
xlim.taurinv = [0.25,2.0];%[0.2,1.6];
xlog.taurinv = 0;
xtick.taurinv = scanval.taurinv(1:2:11);%scanval.taurinv(1:3:13);%
iscandisp.taurinv = 1:2:11;
%    
scanvar.zi = 'Zi';
scanval.zi = 1:0.2:3;%1:0.25:4;%1:10;%
scanlab.zi = 'Z_i';
scanind.zi = 5;
xlim.zi = [0.9,3.1];%[0.5,4.5];%[0,11];%
xlog.zi = 0;
xtick.zi =1:0.4:3;%0.5:0.5:4.5;
iscandisp.zi = 1:2:11;
%
graph.cont_norm = 10.^(-24:0);
graph.cont_norm_lab = 10.^(-24:4:0);
graph.cont_gamma = 10.^(-30:2:0);
graph.cont_gamma_lab = 10.^(-30:5:0);
%
% printing option
%
id_simul0 = 'Runaway_scan';%Simulation ID
p_opt = -1;%2;% printing and saving options : (-1) do nothing (0) print figures (1) print figures and save figures and results (2) save figures and results
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
% the ratio of the syncrotron reaction force to the collisional drag scales
% as taurinv = 1/taur
% -> set taurinv = 0 or opt.synchro_mode = 0 to ignore syncrotron reaction force
%
% note : 
%   - without the syncrotron reaction force, and with a single cold ion
%   species of charge Zi, the normalized runaway rate - with respect to the
%   electron density and ee collision time - only depends upon Zi, alpha and betath2
%
%   - with the syncrotron reaction force, an additional parameter is
%   provived by taurinv
%
%   - the link between wpr=wc2/wp2 and taurinv is : 
%       taurinv = wpr*(2/3)/ln(Lambda)
%   
%   - the magnetic field being fixed, the density is adjusted in LUKE according to bhat
%
taurinv = 0.6;%0.1;%
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
opt.norm_mode_f = +1i;   
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
%
% opt.tnmin = 1;% > 0 for log scale
% opt.tn = 1e5;% 10000 is time for asymptotic solution
% opt.dtn = 51;% 10 time steps required for accurate runaway solution - see rundke_dtn
%
opt.tnmin = 1;% > 0 for log scale
opt.tn = [1e7,1e8];%1e10;% 10000 is time for asymptotic solution
opt.dtn = [141,90];%161;%21;%201;% 10 time steps required for accurate runaway solution - see rundke_dtn
%
% opt.tnmin = 0;% > 0 for log scale
% opt.tn = 1e8;%1e10;% 10000 is time for asymptotic solution
% opt.dtn = 10*1i;%161;%21;%201;% 10 time steps required for accurate runaway solution - see rundke_dtn
%
% momentum space grid -> you can specify nmhu_S and either 
% - the momentum grid pn_S directly
% - the parameters np_S, pnmax_S, np_tail, pnmax_S_tail as follows
%
grid.nmhu_S = 141;% number of pitch angle grid points
grid.sfac1 = 80;%40; % reduction factor for fine grid near abs(mhu) = 1
grid.snmhu1 = 5; % number of fine grid points near abs(mhu) = 1
%
% momentum grid contruction option :
%   (0) do not adjust number of fine and coarse grid points
%   (1) keep fine grid step constant (typically, 0.2)
%       if isreal(np_tail) : keep coarse grid steps constant (typically, 1). Note : do not enforce np_S and np_tail variations 
%       if isimag(np_tail), enforce continuity of grid step size at pnmax_S. Note : do not enforce np_S and np_tail variations
%
grid.opt = 1;
%
grid.np_S = 141;% number of bulk momentum grid points
grid.pnmax_S = 28;%28;%sqrt(((1 + Emax*1e3/mc2)^2 - 1)/betath2);% maximum of bulk momentum (normalized to pT) [pn = 28 corresponds to 1 MeV electrons for betath = 0.1]
grid.np_tail = 4i;%960;%240;%558;%331;%217;%103;%100;% number of tail momentum grid points
grid.pnmax_S_tail = 1967;%988;%597;%401;205;% maximum of tail momentum (normalized to pT) [107,205,303,401,499,597,793,988,1184,1576,1967] corresponds to [5,10,15,20,25,30,40,50,60,80,100] MeV electrons for betath = 0.1
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
opt.heavyions = true;
opt.adjustB = true;
%
%************************************************************************************************************************************
%
nscan1 = length(scanval.(scanstr1));
nscan2 = length(scanval.(scanstr2));
id_simul_scan = [id_simul0,'_',scanstr1,'_',scanstr2];
%
RR = cell(nscan1,nscan2);
mksa = cell(nscan1,nscan2);
Ec = cell(nscan1,nscan2);
f = cell(nscan1,nscan2);
tn = cell(nscan1,nscan2);
tRR = cell(nscan1,nscan2);
tnorm = cell(nscan1,nscan2);
fgrid = cell(nscan1,nscan2);
%
dp_bulk = grid.pnmax_S/(grid.np_S - 1);
dp_fine = (grid.pnmax_S_tail - grid.pnmax_S)/grid.np_tail;
pfac = imag(grid.np_tail);
%
for iscan1 = 1:nscan1,
    evalstr = [scanvar.(scanstr1),' = ',num2str(scanval.(scanstr1)(iscan1)),';'];
    disp(['Scan ',num2str(iscan1),'/',num2str(nscan1),' : ',evalstr])
    eval(evalstr);
    %
    if grid.opt == 1,
        grid.np_S = 1 + round(grid.pnmax_S/dp_bulk);
        if pfac == 0,
            grid.np_tail = round((grid.pnmax_S_tail - grid.pnmax_S)/dp_fine);
        else
            grid.np_tail = round((grid.np_S - 1)*pfac*((grid.pnmax_S_tail/grid.pnmax_S)^(1/pfac) - 1));
            grid.opt = pfac;
        end
    end
    %
    id_simul = [id_simul_scan,'_',num2str(scanval.(scanstr1)(iscan1))];
    %
    opt.pnmin_S = sqrt(((1 + Emin*1e3/mc2)^2 - 1)/betath2);
    wpr = -taurinv*1i;% real wpr : wpr, positive imaginary part : bhat, negative imaginary part : taurinv.
    %
    % RUN LUKE
    %
    dkepath = lukeschedulerparam('',mdce_mode,remnum,returnmode,transpmode);
    %
    if ~isnan(nproc_enforce),
        for irem = 1:length(dkepath.remote),
            dkepath.remote(irem).nproc = nproc_enforce;
        end
    end
    %
    dkecluster = clustermode_luke('','run_lukert',dkepath);
    %
    [flag,RR(iscan1,:),mksa(iscan1,:),Ec(iscan1,:),f(iscan1,:),tn(iscan1,:),tRR(iscan1,:),tnorm(iscan1,:),fgrid(iscan1,:)] = ...
        mdce_run('frundke_runaway',{id_simul,alpha,betath2,wpr,Zi,opt,grid,id_equil,id_wave,rho_S},scanind.(scanstr2),scanval.(scanstr2),dkecluster);
    %
end
%
%************************************************************************************************************************************
%
% PROCESS DATA
%
fproc_runaway_scan_2D(scanstr1,scanstr2,scanvar,scanval,scanlab,RR,mksa,Ec,f,tn,tRR,tnorm,fgrid,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,iscandisp,xlim,xlog,xtick,p_opt,id_simul_scan,nan_enforce);
%
%************************************************************************************************************************************
%
if p_opt > 0,
    %
    for iscan1 = 1:nscan1,
        for iscan2 = 1:nscan2,
            f{iscan1,iscan2} = f{iscan1,iscan2}(end);% to save space
        end
    end
    %
    filename = [path_simul,'DKE_RESULTS_',id_simul_scan,'.mat'];
    save(filename);
    info_dke_yp(2,['Data saved in ',filename]);
end