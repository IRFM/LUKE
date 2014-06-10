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
% id_simul = 'Quench_thermal_nosynchro';%Simulation ID
id_simul = 'Quench_thermal_nosynchro_noaval';%Simulation ID
%
p_opt = -1;%2;% printing option
l_opt = false;%true;% (true) use loadstructs, (false) recalculate all structures (for verification)
f_opt = false;%true;% display electron distribution
c_opt = true;% option for cylindrical calculation
s_opt = false;% save distribution in file
%
betath0 = 0.1;% 0.01 corresponds to 5.1 keV
betathf = 0.01;% 0.01 corresponds to 51 eV
%
j0 = 1;%NaN;% initial current density (MA/m²)
%
avalanche_mode = false;%true;
synchro_mode = false;%true;%
%
% avalanche modelling : 
%
% dkeparam.pnmin0_KO is the low threshold on primary electrons for the knock-on operator
% The condition pnmin0_KO <= pnmax_S is enforced so that the source can be calculated
% - For pnmin0_KO = NaN, the limit is set to pnmax_S
% 
% dkeparam.pnmin1_KO is the low threshold on secondary electrons for the knock-on operator
% - If pnmin1_KO == NaN, the current value of pc is used
% - If pnmin1_KO is imaginary, it is normalized to the actual thermal momentum (instead of reference)
%
% dkeparam.pnmax1_KO is the high threshold on secondary electrons for the knock-on operator
% in principle, as rosenbluth assumes p0 > p1 we must separate the domain of source runaways (ex : 1MeV) from that of secondary electrons.
% Therefore, we should ensure pnmax1_KO <= pnmin0_KO
% - For pnmax1_KO = NaN, the limit is set to pnmin0_KO
% - If pnmax1_KO > pnmax_S (which violate the principle described above), the source between pnmax_S and pnmax1_KO is calculated as a "number"
%
pnmin0_KO = 28;%NaN;% pnmin0_KO = 28 corresponds to 1 MeV electrons for betath = 0.1
pnmin1_KO = 1i;%NaN;%1;% 1i is the "natural" limit as for lower energies it is simply the identity operator
pnmax1_KO = NaN;%100;% 
%
% temperature evolution :
%
%   o (0) : constant
%   o (1) : power law     : Te = Te0*(1-t/tq)^(2/3) 
%   o (2) : exp. law      : Te = Tef + (Te0-Tef)*exp(-t/tq) 
%   o (3) : step function : Te = Tef
%   o (4) : arena         : Te = Tef + (Te0-Tef)*exp(-(t/tq)^2) 
%
opt_T = 4;%1;%
%
% tnq = 4;% opt_T = 0 or opt_T = 1 or opt_T = 3
% tnq = 2;% opt_T = 2
tnq = 50;% opt_T = 4
%
tnmax = 500;%NaN;%5;%50;%
%
% if tnmax = NaN, the simulation time tnmax is calculated as a function of opt_T and tnq :
% 
%   - opt_T = 0 : tnmax = tq
%   - opt_T = 1 : tnmax = tq*(1 - (Tef/Te0)^(3/2))
%   - opt_T = 2 : tnmax = 2*tq
%   - opt_T = 3 : tnmax = tq
%   - opt_T = 4 : tnmax = 2*tq
%
nit = 100;%50;% number of time steps (lin scale)
it_disp = 10:10:50;
%
nmhu_S = 101;
%
% np_S = 101;
% pnmax_S = 20;
% np_bulk = 0;%50;
% np_tail = 0;%50;
% pnmax_S_tail = 100;%[107,205,303] corresponds to [5,10,15] MeV electrons for betath = 0.1
%
np_S = 141;
pnmax_S = 28;%28 corresponds to 1 MeV electrons for betath = 0.1
np_bulk = 0;%50;
np_tail = 331;%160;%60;%0;
pnmax_S_tail = 597;%303;%107;%[107,205,303,401,499,597] corresponds to [5,10,15,20,25,30] MeV electrons for betath = 0.1
%
tol = 1e-3;
maxiconv = 20;
efield0 = 0.01;

% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.5];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
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
[dkepath,equil0,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
equil0.pzTi = 1e-10*ones(size(equil0.pzTi));
%
Zi = 1;
equil0.zZi = [1,1,1,Zi];
equil0.pzni = [0;0;0;1/Zi]*equil0.pne;
%
%**************************************************************************
%**************************************************************************
%
% simulation parameters
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
dkeparam.coll_mode = 0;%For comparison with theoretical results
dkeparam.timevol = 0;%to calculate moments at all internal times
%
dkeparam.tn = NaN;% time steps prescribed by vector dtn
%
% if np_bulk == 0 && np_tail == 0,%uniform momentum grid
%     dkeparam.np_S = np_S;
% else
pn_S = linspace(0,pnmax_S,np_S);
%
if np_bulk == 0,
    pn_S_bulk = [];
else
    pn_S = pn_S(pn_S > 1);
    pn_S_bulk = linspace(0,1,np_bulk + 1);
end
%    
if imag(pnmax_S_tail) > 0,
    pnmax_S_tail = imag(pnmax_S_tail)*pnmax_S;
end
if np_tail == 0,
    pn_S_tail = [];
else
    pn_S = pn_S(pn_S < pnmax_S);
    pn_S_tail = linspace(pnmax_S,pnmax_S_tail,np_tail + 1);
end
dkeparam.pn_S = [pn_S_bulk,pn_S,pn_S_tail];
%
dkeparam.nmhu_S = nmhu_S;
dkeparam.pnmax_S = pnmax_S;
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
if ~isnan(j0),
    dkeparam.nit_ohm = maxiconv;
    dkeparam.tol_ohm = tol;
    dkeparam.efield_ohm = efield0;
    dkeparam.Jtot_ohm = j0;
end
%
dkeparam.avalanche_mode = avalanche_mode;
dkeparam.synchro_mode = synchro_mode;
%
dkeparam.pnmin0_KO = pnmin0_KO;
dkeparam.pnmin1_KO = pnmin1_KO;
dkeparam.pnmax1_KO = pnmax1_KO;
%
if exist('dmumpsmex');
    dkeparam.invproc = -2;
end
%
% time grid
%
if isnan(tnmax),
    if opt_T == 0,
        tnmax = tnq;
    elseif opt_T == 1,
        tnmax = tnq*(1 - (betathf/betath0)^3);
    elseif opt_T == 2,
        tnmax = 2*tnq;
    elseif opt_T == 3,
        tnmax = tnq;
    elseif opt_T == 4,
        tnmax = 2*tnq;
    end
end
%
dtn = tnmax/nit;
tn = linspace(dtn,tnmax,nit);
%
% temperature evolution and time dependent equilibrium
%
if opt_T == 0,
    tbetath = repmat(betath0,[1,nit]);
elseif opt_T == 1,
    tbetath = betath0*(1-tn/tnq).^(1/3); 
elseif opt_T == 2,
    tbetath = sqrt(betathf^2 + (betath0^2-betathf^2)*exp(-tn/tnq)); 
elseif opt_T == 3,
    tbetath = repmat(betathf,[1,nit]); 
elseif opt_T == 4,
    tbetath = sqrt(betathf^2 + (betath0^2-betathf^2)*exp(-(tn/tnq).^2)); 
end
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil0.pTe = betath0^2*mc2*ones(size(equil0.pTe));
%
tequil = repmat(equil0,[1,nit]);
%
for it = 1:nit,
    tequil(it).pTe = tbetath(it)^2*mc2*ones(size(tequil(it).pTe));
end
%
% initial (time-asymptotic) distribution
%
dkeparam.dtn = NaN;%time-asymptotic
dkeparam.opt_struct = 2;%to keep all fields in output structures for loadstruct
%
[Znorm0,Zcurr0,ZP00,dke_out0,radialDKE0,equilDKE0,momentumDKE0,gridDKE0,Zmomcoef0,Zbouncecoef0,Zmripple0,mksa0,XXsinksource0] = main_dke_yp(id_simul,dkepath,equil0,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
dmhu = momentumDKE0.dmhu;
mhu = momentumDKE0.mhu;
dpn = momentumDKE0.dpn;
pn = momentumDKE0.pn;
pn2 = gridDKE0.pn2;
gamma = Zmomcoef0.gamma;
%
pfM0 = (1/2)*integral_dke_jd(dmhu,dke_out0.XXfM,2);%mhu-averaged distribution
pf00 = (1/2)*integral_dke_jd(dmhu,dke_out0.XXf0{1},2);%mhu-averaged distribution
%
xTe_normM0 = 4*pi*integral_dke_jd(dpn.',pn2.'.*pn2.'.*pfM0./gamma.',1)/3;
xTe_norm00 = 4*pi*integral_dke_jd(dpn.',pn2.'.*pn2.'.*pf00./gamma.',1)/3;
%
if l_opt,
    loadstructs.radialgrid_dke_jd.radialDKE = radialDKE0;
    %
%     loadstructs.equilibrium_jd.equilDKE = equilDKE0;
    %
    loadstructs.momentumgrid_dke_jd.momentumDKE = momentumDKE0;
    loadstructs.matrix3Dgridbuilder_dke_yp.gridDKE = gridDKE0;
    loadstructs.momentumcoefbuilder_dke_yp.Zmomcoef = Zmomcoef0;
    loadstructs.bouncecoefbuilder_dke_yp.Zbouncecoef = Zbouncecoef0;
    loadstructs.mripplecoefbuilder_dke_yp.Zmripple = Zmripple0;
    loadstructs.mksacoefbuilder_dke_yp.mksa = mksa0;
    loadstructs.sinksourcecoeffbuilder_dke_yp.XXsinksource = XXsinksource0;
    %
    loadstructs.rad_dke_yp.ZXXD_a = dke_out0.ZXXD_a;
    loadstructs.rad_dke_yp.ZXXF_a = dke_out0.ZXXF_a;
    %
%     loadstructs.coll_dke_jd.ZXXD_c = dke_out0.ZXXD_c;
%     loadstructs.coll_dke_jd.ZXXF_c = dke_out0.ZXXF_c;
%     loadstructs.coll_dke_jd.ZXXD_c_tp = NaN;%dke_out.ZXXD_c_tp;
%     loadstructs.coll_dke_jd.ZXXF_c_tp = NaN;%dke_out.ZXXF_c_tp;
%     loadstructs.coll_dke_jd.XXfM = dke_out0.XXfM;
%     loadstructs.coll_dke_jd.XXILor = dke_out0.XXILor;
    %
    loadstructs.efield_dke_jd.ZXXD_e = dke_out0.ZXXD_e;
    loadstructs.efield_dke_jd.ZXXF_e = dke_out0.ZXXF_e;
    loadstructs.efield_dke_jd.ZXXD_e_tp = NaN;%dke_out.ZXXD_e_tp;
    loadstructs.efield_dke_jd.ZXXF_e_tp = NaN;%dke_out.ZXXF_e_tp;
    loadstructs.efield_dke_jd.xepsi_init = dke_out0.xepsi_init;
    loadstructs.efield_dke_jd.xEfield_validity = dke_out0.xEfield_validity;
    %
    loadstructs.rfwave_dke_jd.waveparam = dke_out0.waveparam;
    loadstructs.rfwave_dke_jd.xyprop_dke = dke_out0.xyprop_dke;
    loadstructs.rfwave_dke_jd.xyP0_2piRp_mod = dke_out0.xyP0_2piRp_mod;
    loadstructs.rfwave_dke_jd.yb = dke_out0.yb;
    loadstructs.rfwave_dke_jd.yP0_2piRp = dke_out0.yP0_2piRp;
    loadstructs.rfwave_dke_jd.xys = dke_out0.xys;
    %
    loadstructs.loop_rfdiff_dke_jd.ZXYD_rf = dke_out0.ZXYD_rf;
    loadstructs.loop_rfdiff_dke_jd.ZXYF_rf = dke_out0.ZXYF_rf;
    loadstructs.loop_rfdiff_dke_jd.ZXYD_rf_tp = NaN;%dke_out.ZXYD_rf_tp;
    loadstructs.loop_rfdiff_dke_jd.ZXYF_rf_tp = NaN;%dke_out.ZXYF_rf_tp;
    loadstructs.loop_rfdiff_dke_jd.gridindex_rf = dke_out0.gridindex_rf;
    %
    % loadstructs.finit_dke_yp.XXfinit = dke_out0.XXfinit;   
    %
else
    %
    loadstructs = [];
    %
    dkeparam.Te_ref = mksa0.Te_ref;%Reference temperature
    dkeparam.ne_ref = mksa0.ne_ref;%Reference density
    %
end
%
I_tot = Zcurr0.I_tot;
%
XXfinit = dke_out0.XXf0;
%
ohm = struct;
ohm.id = 'evolution';
ohm.rho = rho_S;
ohm.epsi = dke_out0.xepsi{end}*mksa0.Edreicer_ref;% guess is previous time
ohm.xnrem_init = dke_out0.xnorm_rem{end};
ohm.xnrep_init = dke_out0.xnorm_rep{end};
%
% time evolution of the distribution
%
dkeparam.dtn = dtn;
dkeparam.opt_struct = 0;
%
for it = 1:nit,    
    [Znorm(it),Zcurr(it),ZP0(it),dke_out(it)] = main_dke_yp(id_simul,dkepath,tequil(it),dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXfinit{it},[],loadstructs);
    XXfinit{it+1} = dke_out(it).XXf0{1};
    %
    ohm.epsi = dke_out(it).xepsi{end}*mksa0.Edreicer_ref;% guess is previous time
    ohm.xnrem_init = dke_out(it).xnorm_rem{end};
    ohm.xnrep_init = dke_out(it).xnorm_rep{end};
    %
    disp(['Time step ',num2str(it),'/',num2str(nit),' calculated.'])
end
%
% calculation of the Spitzer current
%
if ~isnan(j0),
    %
    dkeparam.avalanche_mode = 0;
    dkeparam.dtn = NaN;%time-asymptotic
    dkeparam.nit_ohm = 1;%no field adjustment
    %dkeparam = rmfield(dkeparam,{'Te_ref','ne_ref'});%TODO : pb when we keep the old grid...
    %
    ohm = struct;
    ohm.id = 'linear';
    ohm.rho = rho_S;
    ohm.epsi = 1e-6;% linear limit
    %
    if l_opt,
        loadstructs = rmfield(loadstructs,'efield_dke_jd');
    end
    %
    [~,Zcurr_lin0] = main_dke_yp(id_simul,dkepath,equil0,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[],loadstructs);
    for it = 1:nit,    
        [~,Zcurr_lin(it),~,~,~,~,~,~,~,~,~,mksa_lin(it)] = main_dke_yp(id_simul,dkepath,tequil(it),dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[],loadstructs);
        disp(['Time step ',num2str(it),'/',num2str(nit),' calculated.'])
    end
end
%
pfM = cell(1,nit);
pf0 = cell(1,nit);
%
xTe_normM = NaN(1,nit);
xTe_norm0 = NaN(1,nit);
%
pfbM = cell(1,nit);
xTe_normb = NaN(1,nit);
xTe_norms = NaN(1,nit);
delta = NaN(1,nit);
err = NaN(1,nit);
%
for it = 1:nit,
    pfM{it} = (1/2)*integral_dke_jd(dmhu,dke_out(it).XXfM,2);%mhu-averaged distribution
    pf0{it} = (1/2)*integral_dke_jd(dmhu,dke_out(it).XXf0{1},2);%mhu-averaged distribution
    %
    xTe_normM(it) = 4*pi*integral_dke_jd(dpn.',pn2.'.*pn2.'.*pfM{it}./gamma.',1)/3;
    xTe_norm0(it) = 4*pi*integral_dke_jd(dpn.',pn2.'.*pn2.'.*pf0{it}./gamma.',1)/3;
    %
    if ~c_opt,
        [xTe_normb(it),xTe_norms(it),delta(it),pfbM{it},err(it)] = bimaxfit_jd(dpn.',pn.',gamma.',pf0{it},1,3,xTe_normM(it),1);
    end
end
%
if ~isnan(j0),
    Efield0 = dke_out0.xepsi{end}/mksa0.betath_ref^2;
    %
    Jtot0 = dke_out0.xcurr{end};% total current density
    Jlin0 = Zcurr_lin0.x_0_fsav*(dke_out0.xepsi{end}.*mksa0.Edreicer_ref)/ohm.epsi;% Spitzer current density 
    Jrei0 = Zcurr0.x_Rfrac_0_fsav;% Internal RE current density  
    Jree0 = dke_out0.xcurr_rem{end} + dke_out0.xcurr_rep{end};% External RE current density   
    Jhot0 = Jtot0 - Jlin0 - Jrei0 - Jree0;% Hot tail current density
    %
    Efield = NaN(1,nit);%E/E_c
    %
    Jtot = NaN(1,nit);% total current density
    Jlin = NaN(1,nit);% Spitzer current density 
    Jrei = NaN(1,nit);% Internal RE current density  
    Jree = NaN(1,nit);% External RE current density   
    %
    for it = 1:nit,
        Efield(it) = dke_out(it).xepsi{1}/mksa0.betath_ref^2;
        %
        Jtot(it) = dke_out(it).xcurr{end};% total current density
        %
        % maybe we must multiply Zcurr_lin(it) by the bulk density xnorm0 or ((1-delta)*xnorm0 ?
        Jlin(it) = Zcurr_lin(it).x_0_fsav*(mksa_lin(it).j_ref/mksa0.j_ref)*(dke_out(it).xepsi{end}*mksa0.Edreicer_ref)/ohm.epsi;% Spitzer current density 
        Jrei(it) = Zcurr(it).x_Rfrac_0_fsav;% Internal RE current density  
        Jree(it) = dke_out(it).xcurr_rem{end} + dke_out(it).xcurr_rep{end};% External RE current density   
    end
    Jhot = Jtot - Jlin - Jrei - Jree;% Hot tail current density
    %
    J0 = j0/mksa0.j_ref;   
end
%
%************************************************************************************************************************************
%
figure(1),clf
%
if ~c_opt,
    leg = {'Prescr.','LUKE','Bulk','Supra.'};%,'Max.'
else
    leg = {'Prescr.','Max.','LUKE'};
end
xlim = [0,tnmax];
ylim = NaN;%[0,1.4];%
ytick = 0:0.2:1.4;
xlab = 't/\tau_c';
ylab = 'T_e/T_{e0}';
tit = '';
siz = 20+14i;
%
graph1D_jd(tn,(tbetath/betath0).^2,0,0,'','','',NaN,xlim,ylim,'-','none','k',0.5,siz,gca);
if c_opt,
    graph1D_jd(tn,xTe_normM,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
end
graph1D_jd(tn,xTe_norm0,0,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
if ~c_opt,
    graph1D_jd(tn,xTe_normb,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
    graph1D_jd(tn,xTe_norms,0,0,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
end
graph1D_jd(tn,delta,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',[0.5,0,0.5],2,siz,gca,0.9,0.7,0.7);
%
%set(gca,'ytick',ytick)
%
print_jd(p_opt,'fig_Quench_thermal_T','./figures',1)
%
if ~isnan(j0),
    %
    figure(2),clf
    %
    xlim = [0,tnmax];
    ylim = NaN;%[0,1.4];%
    ytick = NaN;%0:0.2:1.4;
    xlab = 't/\tau_c';
    ylab = 'E/E_c';
    tit = '';
    siz = 20+14i;
    %
    graph1D_jd([0,tn],[Efield0,Efield],0,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(xlim,[1,1],0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
    %
    %set(gca,'ytick',ytick)
    %
    print_jd(p_opt,'fig_Quench_thermal_E','./figures',2)
    %
    figure(3),clf
    %
    leg = {'Spitzer','Hot','Internal RE','External RE','Total'};%,'Max.'
    xlim = [0,tnmax];
    ylim = [0,1.2];%
    ytick = 0:0.2:1.2;
    xlab = 't/\tau_c';
    ylab = 'J/J_0';
    tit = '';
    siz = 20+14i;
    %
    graph1D_jd([0,tn],[Jlin0,Jlin]/J0,0,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd([0,tn],[Jhot0,Jhot]/J0,0,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd([0,tn],[Jrei0,Jrei]/J0,0,0,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
    graph1D_jd([0,tn],[Jree0,Jree]/J0,0,0,'','','',NaN,xlim,ylim,'-','none',[0.5,0,0.5],2,siz,gca);
    graph1D_jd([0,tn],[Jtot0,Jtot]/J0,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
    %
    set(gca,'ytick',ytick)
    %
    print_jd(p_opt,'fig_Quench_thermal_J','./figures',3)
    %
end
%
if f_opt,
    nit_disp = length(it_disp);
    colors = {'r','b',[0,0.5,0],'m','c','y'};
    %
    if c_opt,% cylindrical display
        %
        dp_cyl = 0.1;
        %
        % spherical to cylindrical transformation
        %
        [logXf00_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(dke_out0.XXf0{1}),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        Xf00_cyl_ref = exp(logXf00_cyl_ref);%For accurate representation in figures 
        %
        logXf0M_cyl_ref = s2c_dke_yp(log(dke_out0.XXfM),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
        Xf0M_cyl_ref = exp(logXf0M_cyl_ref);%For accurate representation in figures 
        %
        Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
        Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
        Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
        %
        Xf00_cyl_ref = Xf00_cyl_ref.*(Xf00_cyl_ref>0);%Remove negative values
        Xf00_cyl_ref = Xf00_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
        Xf00_cyl_ref(isnan(Xf00_cyl_ref)) = 0;%Remove NaN values
        %
        Xf0M_cyl_ref = Xf0M_cyl_ref.*(Xf0M_cyl_ref>0);%Remove negative values
        Xf0M_cyl_ref = Xf0M_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
        Xf0M_cyl_ref(isnan(Xf0M_cyl_ref)) = 0;%Remove NaN values
        %
        % Remove values less than computer accuracy
        %
        pnmax_0 = min(min(Xp_cyl_ref(abs(Xf00_cyl_ref) < eps)));
        pnmax = min([pnmax_0,pnmax_S]);
        %
        Xmask = Xp_cyl_ref >= pnmax;    
        %
        Xf00_cyl_ref(Xmask) = 0;
        Xf0M_cyl_ref(Xmask) = 0;
        %
        Fpar00_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf00_cyl_ref,1);
        Fpar0M_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0M_cyl_ref,1);
        %
        Fpar0_cyl_ref = cell(1,nit_disp);
        FparM_cyl_ref = cell(1,nit_disp);
        leg = cell(1,nit_disp);
        %
        for iit = 1:nit_disp,
            %
            it = it_disp(iit);
            %
            logXf0_cyl_ref = s2c_dke_yp(log(dke_out(it).XXf0{1}),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
            Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
            %
            logXfM_cyl_ref = s2c_dke_yp(log(dke_out(it).XXfM),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
            XfM_cyl_ref = exp(logXfM_cyl_ref);%For accurate representation in figures 
            %
            Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
            Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
            Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
            %
            XfM_cyl_ref = XfM_cyl_ref.*(XfM_cyl_ref>0);%Remove negative values
            XfM_cyl_ref = XfM_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
            XfM_cyl_ref(isnan(XfM_cyl_ref)) = 0;%Remove NaN values
            %
            % Remove values less than computer accuracy
            %
            Xf0_cyl_ref(Xmask) = 0;
            XfM_cyl_ref(Xmask) = 0;
            %
            Fpar0_cyl_ref{iit} = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
            FparM_cyl_ref{iit} = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*XfM_cyl_ref,1);
            %
            leg{iit} = ['t/\tau_c = ',num2str(tn(it))];
        end
        %
        leg = ['t/\tau_c = 0',leg];
        %
        figure(10),clf
        %
        xlab = 'p_{||}/p_{Te}';
        xlim = [-pnmax,pnmax];
        ylab = 'F_{||}';
        ylim = [eps,1];
        %
        graph1D_jd(ppar_cyl_ref,Fpar00_cyl_ref,0,1,'','','',NaN,xlim,ylim,'-','none','k',2,siz,gca);
        %
        for iit = 1:nit_disp-1,
            graph1D_jd(ppar_cyl_ref,Fpar0_cyl_ref{iit},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},2,siz,gca);
        end
        %
        graph1D_jd(ppar_cyl_ref,Fpar0_cyl_ref{nit_disp},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{nit_disp},2,siz,gca,0.9,0.7,0.7);
        %
        graph1D_jd(ppar_cyl_ref,Fpar0M_cyl_ref,0,1,'','','',NaN,xlim,ylim,'-','none','k',0.5,siz,gca);
        %
        for iit = 1:nit_disp,
            graph1D_jd(ppar_cyl_ref,FparM_cyl_ref{iit},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},0.5,siz,gca);
        end
        %
        print_jd(p_opt,'fig_Quench_thermal_f1D','./figures',10)
        %
    else% mhu-averaged distribution
        %
        % Ignore values less than computer accuracy
        %
        pnmax_0 = min(min(pn(pf00 < eps)));
        pnmax = min([pnmax_0,pnmax_S]);
        %
        leg = cell(1,nit_disp);
        for iit = 1:nit_disp,
            leg{iit} = ['t/\tau_c = ',num2str(tn(it_disp(iit)))];
        end
        leg = ['t/\tau_c = 0',leg];
        %
        figure(10),clf
        %
        xlab = 'p/p_{Te}';
        xlim = [0,pnmax];
        ylab = 'F_p';
        ylim = [eps,max(pfM{end})];
        %
        graph1D_jd(pn,pf00,0,1,'','','',NaN,xlim,ylim,'-','none','k',2,siz,gca);
        %
        for iit = 1:nit_disp-1,
            graph1D_jd(pn,pf0{it_disp(iit)},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},2,siz,gca);
        end
        %
        graph1D_jd(pn,pf0{it_disp(nit_disp)},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{nit_disp},2,siz,gca,0.9,0.7,0.7);
        %
        graph1D_jd(pn,pfM0,0,1,'','','',NaN,xlim,ylim,'-','none','k',0.5,siz,gca);
        %
        for iit = 1:nit_disp,
            graph1D_jd(pn,pfM{it_disp(iit)},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iit},0.5,siz,gca);
            graph1D_jd(pn,pfbM{it_disp(iit)},0,1,'','','',NaN,xlim,ylim,'--','none',colors{iit},0.5,siz,gca);
        end
        %
        print_jd(p_opt,'fig_Quench_thermal_f1Dp','./figures',10)
        %
    end
    %    
end
%
if s_opt,
    %
    [np,nmhu] = size(dke_out0.XXf0{1});
    %
    savedata = struct;
    %
    savedata.t = [0,tn];
    savedata.betath0 = betath0;
    savedata.pn = pn;
    savedata.dpn = dpn;
    savedata.xi = mhu;
    savedata.dxi = dmhu;
    %
    savedata.rbetath = [betath0,tbetath]/betath0;
    savedata.f = NaN(np,nmhu,nit+1);
    savedata.f(:,:,1) = dke_out0.XXf0{1}/Znorm0.x_0_fsav;
    for it = 1:nit,
        savedata.f(:,:,it+1) = dke_out(it).XXf0{1}/Znorm(it).x_0_fsav;
    end
    %
    savedata.info.t = 'time grid, normalized to electron thermal collision time 4*pi*e0^2*m^2*vT0^3/(ne*e^4)';
    savedata.info.betath0 = 'ratio of the reference thermal velocity VT0=sqrt(T0/m) to the speed of light c. Also equal to sqrt(T0/mc2)';
    savedata.info.pn = 'momentum grid, normalized to the reference thermal momentum pT0 = m*vT0';
    savedata.info.dpn = 'momentum grid steps';
    savedata.info.xi = 'pitch angle grid, xi = p||/p';
    savedata.info.dxi = 'pitch angle grid steps';
    savedata.info.rbetath = 'temperature evolution prescribed through field particles in the collision operator: rbetath = vT/vT0';
    savedata.info.f = 'electron distribution function as a function of (pn,xi,t), normalized to the electron density';
        %
    savestr = [path_simul,'LUKEDIST_',id_simul,'.mat'];
    save(savestr,'-struct','savedata');
    info_dke_yp(2,['Data saved in ',savestr]);
end
%
%************************************************************************************************************************************
%
savestr = [path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat'];
save(savestr);
info_dke_yp(2,['Data saved in ',savestr]);
