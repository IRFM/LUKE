% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
[qe,me,~,~,e0,~,~,mc2] = pc_dke_yp;%Universal physics constants
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
scanstr = 'zi';%'betath2';%'taurinv';%'alpha';%'sfac1';%'pnmax_S';%'np_tail';%'dtn';%
% 
% momentum grid contruction option :
%   (0) do not adjust number of fine and coarse grid points
%   (1) keep fine grid step constant (typically, 0.2)
%       if isreal(np_tail) : keep coarse grid steps constant (typically, 1). Note : do not enforce np_S and np_tail variations 
%       if isimag(np_tail), enforce continuity of grid step size at pnmax_S. Note : do not enforce np_S and np_tail variations
% warning : 
% - do not vary np_tail with opt_grid = 1
%
grid.opt = 1;
%
% MDCE
%
mdce_mode = -1;%0;%
remnum = 0;
returnmode = 0;
transpmode = true;
nproc_enforce = 4;
%
% scan parameters
%
switch scanstr,
    case 'dtn'
        %            
        scanvar = 'opt.dtn';
        scanval = 1 + 8*[1:4,8:4:40];
        scanlab = '\Deltat/\tau_c';
        graph.xlim = [0,350];
        graph.xlog = 0;
        graph.xtick = 0:50:350;
        graph.ylim_norm = 10.^[-5,-3];
        graph.ytick_norm = 10.^(-5:-3);
        graph.ylim_gamma = 10.^[-20,-15];
        graph.ytick_gamma = 10.^(-20:-15);
        graph.iscandisp = [1,2,4,8,13];
        %
    case 'np_tail'
        %    
        scanvar = 'grid.np_tail';
        scanval = (988-28)./2.^(0:6);
        scanlab = 'n_p (tail)';
        graph.xlim = (988-28)./2.^[7,-1];
        graph.xlog = 1;
        graph.xtick = fliplr(scanval);
        graph.ylim_norm = 10.^[-5,-2];
        graph.ytick_norm = 10.^(-5:-3);
        graph.ylim_gamma = 10.^[-20,-10];
        graph.ytick_gamma = 10.^(-20:2:-10);
        graph.iscandisp = [1,3,5,7];
        %
    case 'pnmax_S'
        %    
        scanvar = 'grid.pnmax_S';
        scanval = 7:7:70;%140;
        scanlab = 'p_{max}/p_T (fine grid)';
        graph.xlim = [0,77];%[0,147];%
        graph.xlog = 0;
        graph.xtick = scanval(2:2:end);
        graph.ylim_norm = 10.^[-5,-2];
        graph.ytick_norm = 10.^(-5:-3);
        graph.ylim_gamma = 10.^[-20,-10];
        graph.ytick_gamma = 10.^(-20:2:-10);
        graph.iscandisp = [2:2:10];%[4:4:20];%
        %
    case 'sfac1'
        %    
        scanvar = 'grid.sfac1';
        scanval = [1,2,4,6,10,20,40,60,100];
        scanlab = '\Delta\xi_{fine}/\Delta\xi_0';
        graph.xlim = [0.5,200];%[0,147];%
        graph.xlog = 1;
        graph.xtick = scanval;
        graph.ylim_norm = 10.^[-5,-2];
        graph.ytick_norm = 10.^(-5:-3);
        graph.ylim_gamma = 10.^[-20,-10];
        graph.ytick_gamma = 10.^(-20:2:-10);
        graph.iscandisp = [1:2:9];%[4:4:20];%
        %
    case 'alpha'
        %    
        scanvar = 'alpha';
        scanval = (1.5:0.25:4);%(1.5:0.5:6);%
        scanlab = 'E_{||}';%'E/E_c';
        scanind = 2;
        graph.xmask = 1:8;
        graph.xlim = [1.25,3.5];%[1.25,4.25];%[1,7];%
        graph.xlog = 0;
        graph.xtick = scanval(1:2:11);
        graph.ylim_norm = 10.^[-11,1];%10.^[-15,0];
        graph.ytick_norm = 10.^(-10:2:0);%10.^(-15:5:0);
        graph.ylim_gamma = 10.^[-30,0];
        graph.ytick_gamma = 10.^(-30:5:0);
        graph.iscandisp = [1:2:7,8];%[1:2:11];%[2:2:10];%
        %
    case 'betath2'
        %    
        scanvar = 'betath2';
        scanval = 10.^(-3:0.25:-1);
        scanlab = 'T_e';%'T_e/mc^2';
        scanind = 3;
        graph.scanformat = '%10.1f';
        graph.scanunits = 'keV';
        graph.xmask = 3:7;
        graph.x = mc2*scanval;
        graph.xlim = [1,30];%[0.3,30];%10.^[-3.25,-0.75];
        graph.xlog = 1;
        graph.xtick = [1,3,10,30];%[0.3,1,3,10,30];%scanval(1:2:9);
        graph.ylim_norm = 10.^[-11,1];%10.^[-30,1];%10.^[-60,0];
        graph.ytick_norm = 10.^(-10:2:0);%10.^(-30:5:1);%10.^(-60:10:0);
        graph.ylim_gamma = 10.^[-70,0];
        graph.ytick_gamma = 10.^(-60:20:0);
        graph.iscandisp = [3:7];%[1:2:9];
        %
    case 'taurinv'
        %    
        scanvar = 'taurinv';
        scanval = 0.3:0.1:1.6;%0.3:0.1:1.5;
        scanlab = '\sigma_r';%'\tau_r^{-1}';
        graph.xmask = 2:14;
        graph.xlim = [0,1.8];%[0.2,1.6];
        graph.xlog = 0;
        graph.xtick = 0:0.3:1.8;%scanval(1:3:13);
        graph.ylim_norm = 10.^[-11,1];%10.^[-15,0];
        graph.ytick_norm = 10.^(-10:2:0);%10.^(-15:5:0);
        graph.ylim_gamma = 10.^[-30,0];
        graph.ytick_gamma = 10.^(-30:5:0);
        graph.iscandisp = [2,4,6:4:14];% [1:3:13];
        %
    case 'zi'
        %    
        scanvar = 'Zi';
        scanval = 1:0.25:4;%1:10;%
        scanlab = 'Z_{eff}';'Z_i';
        scanind = 5;
        graph.xlim = [0.5,4.5];%[0,11];%
        graph.xlog = 0;
        graph.xtick = 0.5:0.5:4.5;
        graph.ylim_norm = 10.^[-11,1];%10.^[-15,0];
        graph.ytick_norm = 10.^(-10:2:0);%10.^(-15:5:0);
        graph.ylim_gamma = 10.^[-30,0];
        graph.ytick_gamma = 10.^(-30:5:0);
        graph.iscandisp = [1:4:13];%[1:2:9];%
        %
    otherwise
        error('Scan variable not implemented')
end
%
graph.re = false;
graph.xlog_f = 1;
graph.xlim_f = [1e-3,1e2];
graph.xtick_f = 10.^(-3:2);
graph.ylim_f = [1e-20,1e0];%[1e-35,1e5];
graph.ytick_f = 10.^(-20:4:0);%10.^(-35:5:5);
%
% printing option
%
id_simul0 = 'Runaway_scan';%Simulation ID
p_opt = -1;%2;% printing and saving options : (-1) do nothing (0) print figures (1) print figures and save figures and results (2) save figures and results
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
taurinv = 0.6;%0.9;%0.1;%
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
opt.tn = [1e7,1e8];%1e8;%1e10;% 10000 is time for asymptotic solution
opt.dtn = [141,90];%17;%161;%201;% 10 time steps required for accurate runaway solution - see rundke_dtn
%
% momentum space grid -> you can specify nmhu_S and either 
% - the momentum grid pn_S directly
% - the parameters np_S, pnmax_S, np_tail, pnmax_S_tail as follows
%
grid.nmhu_S = 141;% number of pitch angle grid points
grid.sfac1 = 80;%40; % reduction factor for fine grid near abs(mhu) = 1
grid.snmhu1 = 5; % number of fine grid points near abs(mhu) = 1
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
nscan = length(scanval);
id_simul_scan = [id_simul0,'_',scanstr];
%
RR = cell(1,nscan);
mksa = cell(1,nscan);
Ec = cell(1,nscan);
f = cell(1,nscan);
tn = cell(1,nscan);
tRR = cell(1,nscan);
tnorm = cell(1,nscan);
fgrid = cell(1,nscan);
%
dp_bulk = grid.pnmax_S/(grid.np_S - 1);
dp_fine = (grid.pnmax_S_tail - grid.pnmax_S)/grid.np_tail;
pfac = imag(grid.np_tail);
%
% - use taurinv, , , ,  as scanstr1 only
% - use  as scanstr1 only if Emin is not NaN
%
if any(strcmp(scanstr,{'taurinv','sfac1','pnmax_S','np_tail','dtn'}))...
    || (strcmp(scanstr,'betath2') && ~isnan(Emin)),% cannot use MDCE
    %
    for iscan = 1:nscan,
        evalstr = [scanvar,' = ',num2str(scanval(iscan)),';'];
        disp(['Scan ',num2str(iscan),'/',num2str(nscan),' : ',evalstr])
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
        id_simul = [id_simul_scan,'_',num2str(scanval(iscan))];
        %
        opt.pnmin_S = sqrt(((1 + Emin*1e3/mc2)^2 - 1)/betath2);
        wpr = -taurinv*1i;% real wpr : wpr, positive imaginary part : bhat, negative imaginary part : taurinv.
        %
        % RUN LUKE
        %
        [RR{iscan},mksa{iscan},Ec{iscan},f{iscan},tn{iscan},tRR{iscan},tnorm{iscan},fgrid{iscan}] = frundke_runaway(id_simul,alpha,betath2,wpr,Zi,opt,grid,id_equil,id_wave,rho_S);
        %
    end
else
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
    [flag,RR(:),mksa(:),Ec(:),f(:),tn(:),tRR(:),tnorm(:),fgrid(:)] = ...
        mdce_run('frundke_runaway',{id_simul_scan,alpha,betath2,wpr,Zi,opt,grid,id_equil,id_wave,rho_S},scanind,scanval,dkecluster);
end
%
%************************************************************************************************************************************
%
% PROCESS DATA
%
fproc_runaway_scan(scanvar,scanval,scanstr,scanlab,RR,mksa,Ec,f,tn,tRR,tnorm,fgrid,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,p_opt,id_simul_scan);
%
%************************************************************************************************************************************
%
if p_opt > 0,
    %
    for iscan = 1:nscan,
        f{iscan} = f{iscan}(end);% to save space
    end
    %
    filename = [path_simul,'DKE_RESULTS_',id_simul_scan,'.mat'];
    save(filename);
    info_dke_yp(2,['Data saved in ',filename]);
end