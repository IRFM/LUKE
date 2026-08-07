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
function [xTe,Efield,J,pfM,pf0,pfbM,savedata,trbetath] = frundke_quench(id_simul,j0,betath0,betathf,wpr,Zi,opt,varargin)
%
[dkepath,equil0,dkeparam,dkedisplay,waves] = fprep_runaway(wpr,Zi,opt,varargin{:});
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
%************************************************************************************************************************************
%
% initial (time-asymptotic) distribution
%
equil0.pTe = betath0^2*mc2*ones(size(equil0.pTe));%initial temperature
%
dkeparam0 = dkeparam;% parameters for initial distribution calculation
%
dkeparam0.tn = NaN;%time-asymptotic
dkeparam0.dtn = NaN;%time-asymptotic
dkeparam0.opt_struct = 2;%to keep all fields in output structures for loadstruct
%
if isempty(waves),% the plasma is initially in ohmic state
    %
    dkeparam0.Jtot_ohm = j0;% current density 
    %
    dkeparam0.nit_ohm = opt.maxiconv;
    dkeparam0.tol_ohm = opt.tol;
    dkeparam0.efield_ohm = opt.efield0;
    %
    [Znorm0,Zcurr0,ZP00,dke_out0,radialDKE0,equilDKE0,momentumDKE0,gridDKE0,Zmomcoef0,Zbouncecoef0,Zmripple0,mksa0,XXsinksource0] = main_dke_yp(id_simul,dkepath,equil0,dkeparam0,dkedisplay,'','','','',[],[]);
    %
else% the plasma is initially in RF driven state
    %
    for it_wave = 1:opt.maxiconv,
        %
        [Znorm0,Zcurr0,ZP00,dke_out0,radialDKE0,equilDKE0,momentumDKE0,gridDKE0,Zmomcoef0,Zbouncecoef0,Zmripple0,mksa0,XXsinksource0] = main_dke_yp(id_simul,dkepath,equil0,dkeparam0,dkedisplay,'',waves,'','',[],[]);
        %
        Jtot_rf = Zcurr0.x_0_fsav*mksa0.j_ref;
        %
        if abs(Jtot_rf - j0)/j0 <= opt.tol,
            disp(['convergence obtained for RF current after ',num2str(it_wave),' iterations']);
            break
        elseif it_wave == opt.maxiconv,
            disp(['WARNING : convergence not obtained for RF current after ',num2str(it_wave),' iterations']);
        else
            waves{1}.rays{1}.P0_2piRp = waves{1}.rays{1}.P0_2piRp*j0/Jtot_rf;
        end
        %
    end
    %
end
%
dkeparam.Jtot_ohm = j0;% current density 
%
dkeparam.nit_ohm = opt.maxiconv;
dkeparam.tol_ohm = opt.tol;
dkeparam.efield_ohm = opt.efield0;
%
dkeparam.opt_struct = 0;%to keep all fields in output structures for loadstruct
%
dmhu = momentumDKE0.dmhu;
mhu = momentumDKE0.mhu;
dpn = momentumDKE0.dpn;
pn = momentumDKE0.pn;
pn2 = gridDKE0.pn2;
gamma = Zmomcoef0.gamma;
%
if opt.loadstructs,
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
%     loadstructs.rfwave_dke_jd.waveparam = dke_out0.waveparam;
%     loadstructs.rfwave_dke_jd.xyprop_dke = dke_out0.xyprop_dke;
%     loadstructs.rfwave_dke_jd.xyP0_2piRp_mod = dke_out0.xyP0_2piRp_mod;
%     loadstructs.rfwave_dke_jd.yb = dke_out0.yb;
%     loadstructs.rfwave_dke_jd.yP0_2piRp = dke_out0.yP0_2piRp;
%     loadstructs.rfwave_dke_jd.xys = dke_out0.xys;
    %
%     loadstructs.loop_rfdiff_dke_jd.ZXYD_rf = dke_out0.ZXYD_rf;
%     loadstructs.loop_rfdiff_dke_jd.ZXYF_rf = dke_out0.ZXYF_rf;
%     loadstructs.loop_rfdiff_dke_jd.ZXYD_rf_tp = NaN;%dke_out.ZXYD_rf_tp;
%     loadstructs.loop_rfdiff_dke_jd.ZXYF_rf_tp = NaN;%dke_out.ZXYF_rf_tp;
%     loadstructs.loop_rfdiff_dke_jd.gridindex_rf = dke_out0.gridindex_rf;
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
ohm.rho = gridDKE0.xrho;
ohm.epsi = dke_out0.xepsi{end}*mksa0.Edreicer_ref;% guess is previous time
ohm.xnrem_init = dke_out0.xnorm_rem{end};
ohm.xnrep_init = dke_out0.xnorm_rep{end};
%
%************************************************************************************************************************************
%
% temperature evolution and time dependent distribution
%
% time grid
%
nit = opt.nit;
%
if isnan(opt.tnmax),
    if opt.T == 0,
        opt.tnmax = opt.tnq;
    elseif opt.T == 1,
        opt.tnmax = opt.tnq*(1 - (betathf/betath0)^3);
    elseif opt.T == 2,
        opt.tnmax = 2*opt.tnq;
    elseif opt.T == 3,
        opt.tnmax = opt.tnq;
    elseif opt.T == 4,
        opt.tnmax = 2*opt.tnq;
    end
end
%
% time grid (normalized to collision time) -> you can specify :
% - linear arbitrary grid with tn array                 : opt.tnmin = 0 ;opt.tn = 1000:1000:10000,dtn = NaN;opt.tnmin = 0
% - linear arbitrary grid with dtn array                : opt.tnmin = 0 ;opt.tn = NaN;dtn = 1000*ones(1,10);
% - linear grid with tnmax and grid step                : opt.tnmin = 0 ;opt.tn = 10000;dtn = 1000;
% - linear grid with tnmax and number of grid steps     : opt.tnmin = 0 ;opt.tn = 10000;dtn = 10i;
% - log grid with tnmin, tnmax and number of grid steps : opt.tnmin = 1 ;opt.tn = 10000;dtn = 10;
%
dkeparam.tn = NaN;
dkeparam.dtn = opt.tnmax/nit;
tn = linspace(dkeparam.dtn,opt.tnmax,nit);
%
if opt.T == 0,
    tbetath = repmat(betath0,[1,nit]);
elseif opt.T == 1,
    tbetath = betath0*(1-tn/opt.tnq).^(1/3); 
elseif opt.T == 2,
    tbetath = sqrt(betathf^2 + (betath0^2-betathf^2)*exp(-tn/opt.tnq)); 
elseif opt.T == 3,
    tbetath = repmat(betathf,[1,nit]); 
elseif opt.T == 4,
    tbetath = sqrt(betathf^2 + (betath0^2-betathf^2)*exp(-(tn/opt.tnq).^2)); 
end
%
trbetath = [1,tbetath/betath0];
%
tequil = repmat(equil0,[1,nit]);
%
for it = 1:nit,
    tequil(it).pTe = tbetath(it)^2*mc2*ones(size(tequil(it).pTe));
end
%
for it = 1:nit,    
    [Znorm(it),Zcurr(it),ZP0(it),dke_out(it)] = main_dke_yp(id_simul,dkepath,tequil(it),dkeparam,dkedisplay,ohm,'','','',XXfinit{it},[],loadstructs);
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
dkeparam.avalanche_mode = 0;
dkeparam.dtn = NaN;%time-asymptotic
dkeparam.nit_ohm = 1;%no field adjustment
%dkeparam = rmfield(dkeparam,{'Te_ref','ne_ref'});%TODO : pb when we keep the old grid...
%
ohm = struct;
ohm.id = 'linear';
ohm.rho = gridDKE0.xrho;
ohm.epsi = 1e-6;% linear limit
%
if opt.loadstructs,
    loadstructs = rmfield(loadstructs,'efield_dke_jd');
end
%
[~,Zcurr_lin0] = main_dke_yp(id_simul,dkepath,equil0,dkeparam,dkedisplay,ohm,'','','',[],[],loadstructs);
for it = 1:nit,    
    [~,Zcurr_lin(it),~,~,~,~,~,~,~,~,~,mksa_lin(it)] = main_dke_yp(id_simul,dkepath,tequil(it),dkeparam,dkedisplay,ohm,'','','',[],[],loadstructs);
    disp(['Time step ',num2str(it),'/',num2str(nit),' calculated.'])
end
%
pfM = cell(1,nit+1);
pf0 = cell(1,nit+1);
%
xTe.normM = NaN(1,nit+1);
xTe.norm0 = NaN(1,nit+1);
%
pfbM = cell(1,nit+1);
xTe.normb = NaN(1,nit+1);
xTe.norms = NaN(1,nit+1);
xTe.delta = NaN(1,nit+1);
err = NaN(1,nit+1);
%
pfM{1} = (1/2)*integral_dke_jd(dmhu,dke_out0.XXfM,2);%mhu-averaged distribution
pf0{1} = (1/2)*integral_dke_jd(dmhu,dke_out0.XXf0{1},2);%mhu-averaged distribution
%
for it = 1:nit,
    pfM{it+1} = (1/2)*integral_dke_jd(dmhu,dke_out(it).XXfM,2);%mhu-averaged distribution
    pf0{it+1} = (1/2)*integral_dke_jd(dmhu,dke_out(it).XXf0{1},2);%mhu-averaged distribution
end
%
for it = 1:nit+1,
    %
    xTe.normM(it) = 4*pi*integral_dke_jd(dpn.',pn2.'.*pn2.'.*pfM{it}./gamma.',1)/3;
    xTe.norm0(it) = 4*pi*integral_dke_jd(dpn.',pn2.'.*pn2.'.*pf0{it}./gamma.',1)/3;
    %
    [xTe.normb(it),xTe.norms(it),xTe.delta(it),pfbM{it},err(it)] = bimaxfit_jd(dpn.',pn.',gamma.',pf0{it},1,3,xTe.normM(it),1);
end
%
J.tot = NaN(1,nit+1);% total current density
J.lin = NaN(1,nit+1);% Spitzer current density 
J.rei = NaN(1,nit+1);% Internal RE current density  
J.ree = NaN(1,nit+1);% External RE current density   
%
Efield = NaN(1,nit+1);%E/E_c
%
Efield(1) = dke_out0.xepsi{end}/mksa0.betath_ref^2;
%
J.tot(1) = dke_out0.xcurr{end};% total current density
J.lin(1) = Zcurr_lin0.x_0_fsav*(dke_out0.xepsi{end}.*mksa0.Edreicer_ref)/ohm.epsi;% Spitzer current density 
J.rei(1) = Zcurr0.x_Rfrac_0_fsav;% Internal RE current density  
J.ree(1) = dke_out0.xcurr_rem{end} + dke_out0.xcurr_rep{end};% External RE current density   
%
for it = 1:nit,
    Efield(it+1) = dke_out(it).xepsi{1}/mksa0.betath_ref^2;
    %
    J.tot(it+1) = dke_out(it).xcurr{end};% total current density
    %
    % maybe we must multiply Zcurr_lin(it) by the bulk density xnorm0 or ((1-delta)*xnorm0 ?
    J.lin(it+1) = Zcurr_lin(it).x_0_fsav*(mksa_lin(it).j_ref/mksa0.j_ref)*(dke_out(it).xepsi{end}*mksa0.Edreicer_ref)/ohm.epsi;% Spitzer current density 
    J.rei(it+1) = Zcurr(it).x_Rfrac_0_fsav;% Internal RE current density  
    J.ree(it+1) = dke_out(it).xcurr_rem{end} + dke_out(it).xcurr_rep{end};% External RE current density   
end
%
J.hot = J.tot - J.lin - J.rei - J.ree;% Hot tail current density
%
J.j0 = j0/mksa0.j_ref;   
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
savedata.fM = NaN(np,nmhu,nit+1);
savedata.f(:,:,1) = dke_out0.XXf0{1}/Znorm0.x_0_fsav;
savedata.fM = dke_out0.XXfM;
for it = 1:nit,
    savedata.f(:,:,it+1) = dke_out(it).XXf0{1}/Znorm(it).x_0_fsav;
    savedata.fM(:,:,it+1) = dke_out(it).XXfM;
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
savedata.info.fM = 'Maxwellian distribution function as a function of (pn,xi,t), normalized to the electron density';
%
