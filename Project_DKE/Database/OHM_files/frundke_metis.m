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
function [outputs] = frundke_metis(simul,opt,grid,initstate,metisoptfile,metisoptions)
%
dkepath = load_structures_yp('dkepath','','');
%
% initialization of the metis structure
%
[option,cons1t,geo1t] = zerodevolution;
%
if nargin > 4 && ~isempty(metisoptfile),
    metisoptdata = load(metisoptfile);
    option = conc_struct_jd(option,metisoptdata.z0dinput.option);% update options with specific set from METIS file
end
%
if nargin > 5 && isstruct(metisoptions),% update options with user input structure
    option = conc_struct_jd(option,metisoptions);
end
%
% first time is set by initial distribution
%
equil = initstate.luke_input.equil;% LUKE equilibrium
wavestructs = initstate.luke_input.wavestructs;% LUKE input wave structures
%
geo1t.a = (max(equil.ptx(end,:)) - min(equil.ptx(end,:)))/2;
geo1t.R = equil.Rp;
geo1t.K = equil.pelong(end);
geo1t.d = equil.ptrian(end);
geo1t.z0 = equil.Zp;
geo1t.b0 = equil.ptBPHI(end,1)*(1 + equil.ptx(end,1)/equil.Rp);% based on constant magnetic rigidity
geo1t.vp = [];% calculated by METIS
geo1t.sp = [];% calculated by METIS
geo1t.sext = [];% calculated by METIS
%
cons1t.temps = 0;
cons1t.ip = equil.ip;
cons1t.flux = 0;% ip used instead
%
pneh = (equil.pne(1:end-1) + equil.pne(2:end)).'/2;
pdxh = diff(equil.ptx(:,1));
cons1t.nbar = sum(pneh.*pdxh)/equil.ptx(end,1);
%
% line averaged density
%
pzeff = (equil.zZi.^2*equil.pzni)./equil.pne;
pzeffh = (pzeff(1:end-1) + pzeff(2:end)).'/2;
cons1t.zeff = sum(pzeffh.*pdxh)/equil.ptx(end,1);
%
% line averaged zeff
%
cons1t.picrh = 0;
cons1t.pnbi = 0;
cons1t.ftnbi = 0;
%
plh = 0;
wpecrh = zeros(1,0);
wwecrh = zeros(1,0);
%
if opt.waves,% initial current is associated with RF waves
    for wavestruct = wavestructs,% sum ofver wave input structures
        %
        launch = wavestruct{1}.launch;
        %
        if strcmp(launch.type,'LH'),
            plh = plh + sum(launch.bPlhtot);
        elseif strcmp(launch.type,'EC'), 
            wpecrh(1,end+1) = sum(launch.yP_L);
            wwecrh(1,end+1) = launch.omega_rf;
        else
            disp(['wave type ',launch.type,' not recognized. Discarded.'])
        end
    end
end
cons1t.plh = plh;
cons1t.pecrh = sum(wpecrh);
%
% ECRH deposition
%
n = [1,2,3];% harmonic numbers
[qe,me] = pc_dke_yp;%Universal physics constants
%
nwBres = (1./n.')*wwecrh*me/qe;% resonant B field
nwRres = geo1t.R*geo1t.b0./nwBres;% resonant major radius (in vacuum)
nwabsxres = abs(nwRres - geo1t.R);% resonant |R-Rp|
wabsxres = min([ones(1,length(wwecrh));nwabsxres]);% minimum resonant |R-Rp| (versus harmonic number)
if cons1t.pecrh > 0,    
    xece = sum(wabsxres.*wpecrh)/cons1t.pecrh;
else
    xece = 0;
end
%
cons1t.hmore = 1;% confinement factor adjustment
cons1t.iso = 0;% T fraction in DT mix
%
sepa1t.Rsepa = equil.Rp + equil.ptx(end,:);
sepa1t.Zsepa = equil.Zp + equil.pty(end,:);
%
% initialization of z0dstruct
%
if isappdata(0,'NE_EXP'),
    disp('Clearing external electron density data')
    rmappdata(0,'NE_EXP');
end
if isappdata(0,'TE_EXP'),
    disp('Clearing external electron temperature data')
    rmappdata(0,'TE_EXP');
end
if isappdata(0,'LH_SHAPE_EXP'),
    disp('Clearing external LH wave data')
    rmappdata(0,'LH_SHAPE_EXP');
end
if isappdata(0,'ECCD_SHAPE_EXP'),
    disp('Clearing external EC wave data')
    rmappdata(0,'ECCD_SHAPE_EXP');
end
if isappdata(0,'RUNAWAY_EXP'),
    disp('Clearing external runaway data')
    rmappdata(0,'RUNAWAY_EXP');
end
%
[zs_init,profil_init,z0dstruct_init] = zerodevolution([],option,0,cons1t,geo1t,[],sepa1t,[]);
%
% external data
%
if opt.necons,
    NE_EXP.temps = [-1,0];
    NE_EXP.x = equil.pli;
    NE_EXP.ne = [1;1]*equil.pne;
    %
    disp('Loading external electron density data')
    setappdata(0,'NE_EXP',NE_EXP)
end
%
if opt.tecons,
    TE_EXP.temps = [-1,0];
    TE_EXP.x = equil.pli;
    TE_EXP.te = [1;1]*equil.pTe*1e3;
    %
    disp('Loading external electron temperature data')
    setappdata(0,'TE_EXP',TE_EXP)
end
%
if opt.jcons > 0,
    equilDKE = initstate.equilDKE;
    Zcurr = initstate.Zcurr;
    ZP0 = initstate.ZP0;
    mksa = initstate.mksa;
    %
    prho = equil.ptx(:,1)/equil.ptx(end,1);
    xli = interp1(prho,equil.pli,equilDKE.xrho,'linear');
    jluke = mksa.j_ref*1e6*Zcurr.x_0_vcfsav;
    prf = mksa.P_ref*1e6*ZP0.x_rf_fsav.';
    %
    if isstruct(initstate.luke_input.ohm),
        if isfield(initstate,'Zcurr_lin') && isfield(initstate,'ohm_lin'),% Spitzer contribution is calculated
            %
            Zcurr_lin = initstate.Zcurr_lin;
            dke_out_lin = initstate.Zcurr_lin;
            %
        else% Spitzer contribution not calculated
            %
            ohm_lin = initstate.luke_input.ohm;
            ohm_lin.epsi = 1e-6*ones(size(ohm_lin.epsi));% linear limit for Spitzer calculation
            %
            [~,Zcurr_lin,~,dke_out_lin] = main_dke_yp('lin',dkepath,initstate.luke_input.equil,initstate.luke_input.dkeparam,initstate.luke_input.dkedisplay,ohm_lin,'','','',[],[]);
            %
        end
        %
        dke_out = initstate.dke_out;
        %
        johm = mksa.j_ref*1e6*Zcurr_lin.x_0_vcfsav.*dke_out.xepsi./dke_out_lin.xepsi;
        %
    else
        johm = zeros(size(xli));
    end        
    %
    RUNAWAY_EXP.jrun = zeros(2,length(xli));
    LH_SHAPE_EXP.jlh = zeros(2,length(xli));
    ECCD_SHAPE_EXP.jeccd = zeros(2,length(xli));
    %
    if cons1t.plh > 0 && cons1t.pecrh > 0,
        disp(['current prescription not implemented with several wave types combined. Discarded.'])
    elseif cons1t.plh > 0
        %
        LH_SHAPE_EXP.temps = [-1,0];
        LH_SHAPE_EXP.x = xli;
        LH_SHAPE_EXP.jlh = [1;1]*(jluke - johm);
        LH_SHAPE_EXP.plh = [1;1]*prf;
        %
        if opt.jcons > 1,
            LH_SHAPE_EXP.nbar = [1;1]*cons1t.nbar;% to account for density variations in eta_lh
        end
        %
        disp('Loading external LH wave data')
        setappdata(0,'LH_SHAPE_EXP',LH_SHAPE_EXP)
        %
    elseif cons1t.pecrh > 0
        %
        ECCD_SHAPE_EXP.temps = [-1,0];
        ECCD_SHAPE_EXP.x = xli;
        ECCD_SHAPE_EXP.jeccd = [1;1]*(jluke - johm);
        ECCD_SHAPE_EXP.peccd = [1;1]*prf;
        %
        if opt.jcons > 1,
            ECCD_SHAPE_EXP.nbar = [1;1]*cons1t.nbar;% to account for density variations in eta_ec
        end
        %
        disp('Loading external EC wave data')
        setappdata(0,'ECCD_SHAPE_EXP',ECCD_SHAPE_EXP)
        %
    else% initial LUKE current was all runaway
        %
        RUNAWAY_EXP.temps = [-1,0];
        RUNAWAY_EXP.x = xli;
        RUNAWAY_EXP.jrun = [1;1]*(jluke - johm);
        RUNAWAY_EXP.irun = 1e6*[1;1]*Zcurr.I_tot;
        RUNAWAY_EXP.iohm = [1;1]*NaN;% for first order nonlinear corrections - not used yet
        RUNAWAY_EXP.ip = [1;1]*cons1t.ip;
        %
        disp('Loading external runaway data')
        setappdata(0,'RUNAWAY_EXP',RUNAWAY_EXP)
        %
    end
end
%
% initial METIS state calculation with external data
%
[zs,profil,z0dstruct] = zerodevolution(z0dstruct_init,option,0,cons1t,geo1t,[],sepa1t,[]);
%
% adjust initial prf for non-inductive state
%
if opt.ni,
    if cons1t.plh > 0 && cons1t.pecrh > 0,
        disp(['power/current adjustment not implemented with several wave types combined. Discarded.'])
    elseif cons1t.plh > 0,
        %
        LH_SHAPE_EXP.jlh = LH_SHAPE_EXP.jlh*(1 + zs.iohm/zs.ilh);
        disp('Loading external LH wave data')
        setappdata(0,'LH_SHAPE_EXP',LH_SHAPE_EXP)
        %
%         cons1t.plh = cons1t.plh*(1 + zs.iohm/zs.ilh);
        %
    elseif cons1t.pecrh > 0,
        %
        ECCD_SHAPE_EXP.jeccd = ECCD_SHAPE_EXP.jeccd*(1 + zs.iohm/zs.ieccd);
        disp('Loading external EC wave data')
        setappdata(0,'ECCD_SHAPE_EXP',ECCD_SHAPE_EXP)
        %
%         cons1t.peccd = cons1t.peccd*(1 + zs.iohm/zs.ieccd);
        %
    else
        %
        RUNAWAY_EXP.jrun = RUNAWAY_EXP.jrun*(1 + zs.iohm/zs.irun);
        RUNAWAY_EXP.irun = [1;1]*zs.irun*(1 + zs.iohm/zs.irun);
        disp('Loading external runaway data')
        setappdata(0,'RUNAWAY_EXP',RUNAWAY_EXP)
        %
    end
    %
    [zs,profil,z0dstruct] = zerodevolution(z0dstruct,option,0,cons1t,geo1t,[],sepa1t,[]);
    %
end
%
% transfer current to hot tail as RF is switched off (TODO : switched down...)
%
cons1t.plh = 0;
cons1t.pecrh = 0;
%
RUNAWAY_EXP.temps = [-1,0];
RUNAWAY_EXP.x = xli;
RUNAWAY_EXP.jrun = RUNAWAY_EXP.jrun + LH_SHAPE_EXP.jlh + ECCD_SHAPE_EXP.jeccd;
RUNAWAY_EXP.irun = [1;1]*(zs.irun + zs.ilh + zs.ieccd);
RUNAWAY_EXP.iohm = [1;1]*NaN;% for first order nonlinear corrections - not used yet
RUNAWAY_EXP.ip = [1;1]*cons1t.ip;
%
disp('Loading external runaway data')
setappdata(0,'RUNAWAY_EXP',RUNAWAY_EXP)
%
[zs,profil,z0dstruct] = zerodevolution(z0dstruct,option,0,cons1t,geo1t,[],sepa1t,[]);
%
% loop on time evolution
%
% time grid (normalized to collision time) -> you can specify :
% - linear arbitrary grid with tn array                 : opt.tnmin = 0 ;opt.tn = 1000:1000:10000,dtn = NaN;opt.tnmin = 0
% - linear arbitrary grid with dtn array                : opt.tnmin = 0 ;opt.tn = NaN;dtn = 1000*ones(1,10);
% - linear grid with tnmax and grid step                : opt.tnmin = 0 ;opt.tn = 10000;dtn = 1000;
% - linear grid with tnmax and number of grid steps     : opt.tnmin = 0 ;opt.tn = 10000;dtn = 10i;
% - log grid with tnmin, tnmax and number of grid steps : opt.tnmin = 1 ;opt.tn = 10000;dtn = 10;
%
if opt.tnmin == 0,%linear time grid
    nit = opt.tn/opt.dtn;
    tn = linspace(opt.dtn,opt.tn,nit);
end
if opt.tnmin > 0,%log time grid
    nit = opt.dtn;
    tn = logspace(log10(opt.tnmin),log10(opt.tn),opt.dtn);
end
%
for it = 1:nit,  
    %
    cons1t.temps = tn(it)/initstate.mksa.nhu_ref;
    %
    RUNAWAY_EXP.temps(1,end+1) = cons1t.temps;
    RUNAWAY_EXP.ip(end+1,1) = cons1t.ip;
    RUNAWAY_EXP.iohm(end+1,1) = NaN;% for first order nonlinear corrections - not used yet
    %
    % loop on E-field convergence
    %
    RUNAWAY_EXP.jrun(end+1,:) = RUNAWAY_EXP.jrun(end,:);% previous time is first guess
    RUNAWAY_EXP.irun(end+1,1) = RUNAWAY_EXP.irun(end,1);% previous time is first guess
    %
    for iconv = 1:nconv;
        %
        disp('Loading external runaway data')
        setappdata(0,'RUNAWAY_EXP',RUNAWAY_EXP)
        %
        [zs,profil,z0dstruct] = zerodevolution(z0dstruct,option,cons1t.temps,cons1t,geo1t,[],sepa1t,[]);
        %
        %
    end
    
    
    
    
    
    
    
    [Znorm(it),Zcurr(it),ZP0(it),dke_out(it)] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,'','',XXfinit{it},[],loadstructs);
    XXfinit{it+1} = dke_out(it).XXf0{1};
    %
    ohm.epsi = dke_out(it).xepsi{end}*mksa0.Edreicer_ref;% guess is previous time
    ohm.xnrem_init = dke_out(it).xnorm_rem{end};
    ohm.xnrep_init = dke_out(it).xnorm_rep{end};
    %
    disp(['Time step ',num2str(it),'/',num2str(nit),' calculated.'])
end











[dkepath,equil,dkeparam,dkedisplay,waves] = fprep_runaway(wpr,Zi,opt,varargin{:});
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
%************************************************************************************************************************************
%
% initial (time-asymptotic) distribution
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));%initial temperature
equil.pzni = equil.pzni*ne0/equil.pne(1);%initial temperature
equil.pne = ne0*ones(size(equil.pne));%initial temperature
%
dkeparam0 = dkeparam;% parameters for initial distribution calculation
%
dkeparam0.tn = NaN;%time-asymptotic
dkeparam0.dtn = NaN;%time-asymptotic
%
% determine the power for LH drive to reach targer current
%
for it_wave = 1:opt.maxiconv,
    %
    [~,Zcurr0,~,~,~,~,~,~,~,~,~,mksa0,~] = main_dke_yp(id_simul,dkepath,equil,dkeparam0,dkedisplay,'',waves,'','',[],[]);
    %
    Jtot_rf = Zcurr0.x_0_fsav*mksa0.j_ref;
    %
    if abs(Jtot_rf - jlh)/jlh <= 1e-3;%opt.tol,
        disp(['convergence obtained for RF current after ',num2str(it_wave),' iterations']);
        break
    elseif it_wave == opt.maxiconv,
        disp(['WARNING : convergence not obtained for RF current after ',num2str(it_wave),' iterations']);
    else
        waves{1}.rays{1}.P0_2piRp = waves{1}.rays{1}.P0_2piRp*jlh/Jtot_rf;
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
% determine the initial time asymptotic distribution function to have j0 with ohmic heating
%
dkeparam0 = dkeparam;% parameters for initial distribution calculation
%
dkeparam0.tn = NaN;%time-asymptotic
dkeparam0.dtn = NaN;%time-asymptotic
dkeparam0.opt_struct = 2;%to keep all fields in output structures for loadstruct
%
[Znorm0,Zcurr0,ZP00,dke_out0,radialDKE0,equilDKE0,momentumDKE0,gridDKE0,Zmomcoef0,Zbouncecoef0,Zmripple0,mksa0,XXsinksource0] = ...
    main_dke_yp(id_simul,dkepath,equil,dkeparam0,dkedisplay,'','','','',[],[]);
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
for it = 1:nit,    
    [Znorm(it),Zcurr(it),ZP0(it),dke_out(it)] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,'','',XXfinit{it},[],loadstructs);
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
[~,Zcurr_lin0] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,'','','',[],[],loadstructs);
%
pfM = cell(1,nit+1);
pf0 = cell(1,nit+1);
%
pfM{1} = (1/2)*integral_dke_jd(dmhu,dke_out0.XXfM,2);%mhu-averaged distribution
pf0{1} = (1/2)*integral_dke_jd(dmhu,dke_out0.XXf0{1},2);%mhu-averaged distribution
%
for it = 1:nit,
    pfM{it+1} = (1/2)*integral_dke_jd(dmhu,dke_out(it).XXfM,2);%mhu-averaged distribution
    pf0{it+1} = (1/2)*integral_dke_jd(dmhu,dke_out(it).XXf0{1},2);%mhu-averaged distribution
end
%
J.tot = NaN(1,nit+1);% total current density
J.lin = NaN(1,nit+1);% Spitzer current density 
J.rei = NaN(1,nit+1);% Internal RE current density  
J.reep = NaN(1,nit+1);% External RE current density   
J.reem = NaN(1,nit+1);% External RE current density   
%
Efield = NaN(1,nit+1);%E/E_c
%
Efield(1) = dke_out0.xepsi{end}/mksa0.betath_ref^2;
%
J.tot(1) = dke_out0.xcurr{end};% total current density
J.lin(1) = Zcurr_lin0.x_0_fsav*(dke_out0.xepsi{end}.*mksa0.Edreicer_ref)/ohm.epsi;% Spitzer current density 
J.rei(1) = Zcurr0.x_Rfrac_0_fsav;% Internal RE current density  
J.reep(1) = dke_out0.xcurr_rep{end};% External RE current density   
J.reem(1) = dke_out0.xcurr_rem{end};% External RE current density   
%
for it = 1:nit,
    Efield(it+1) = dke_out(it).xepsi{1}/mksa0.betath_ref^2;
    %
    J.tot(it+1) = dke_out(it).xcurr{end};% total current density
    %
    % maybe we must multiply Zcurr_lin(it) by the bulk density xnorm0 or ((1-delta)*xnorm0 ?
    J.lin(it+1) = Zcurr_lin0.x_0_fsav*(dke_out(it).xepsi{end}*mksa0.Edreicer_ref)/ohm.epsi;% Spitzer current density 
    J.rei(it+1) = Zcurr(it).x_Rfrac_0_fsav;% Internal RE current density  
    J.reep(it+1) = dke_out(it).xcurr_rep{end};% External RE current density   
    J.reem(it+1) = dke_out(it).xcurr_rem{end};% External RE current density   
end
%
J.hot = J.tot - J.lin - J.rei - J.reep - J.reem;% Hot tail current density
%
J.j0 = j0/mksa0.j_ref;   
%
[np,nmhu] = size(dke_out0.XXf0{1});
%
savedata = struct;
%
savedata.t = [0,tn];
savedata.betath = betath;
savedata.pn = pn;
savedata.dpn = dpn;
savedata.xi = mhu;
savedata.dxi = dmhu;
%
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
savedata.info.betath = 'ratio of the reference thermal velocity VT0=sqrt(T0/m) to the speed of light c. Also equal to sqrt(T0/mc2)';
savedata.info.pn = 'momentum grid, normalized to the reference thermal momentum pT0 = m*vT0';
savedata.info.dpn = 'momentum grid steps';
savedata.info.xi = 'pitch angle grid, xi = p||/p';
savedata.info.dxi = 'pitch angle grid steps';
savedata.info.rbetath = 'temperature evolution prescribed through field particles in the collision operator: rbetath = vT/vT0';
savedata.info.f = 'electron distribution function as a function of (pn,xi,t), normalized to the electron density';
savedata.info.fM = 'Maxwellian distribution function as a function of (pn,xi,t), normalized to the electron density';
%
