function Zfluct_out = fproc_fluctn_jd(filename,fluct_display,Zfluct_ref,leg_ref,opt)
%
if nargin < 5,
    opt = struct;
end
%
if nargin < 4,
    leg_ref = NaN;
end
%
if nargin < 3,
    Zfluct_ref = '';
end
%
if nargin < 2,
    fluct_display.mode = 0;
    fluct_display.evol = 0;
    fluct_display.stat = 0;
end
%
if nargin < 4,
    leg_ref = cell(1,length(Zfluct_ref));
end
%
data = load(filename,'Ztime','Zitn','Zcurr','ZP0','dke_out','equil','XXf0_t','simul','loadstructs','calctime','lukestructs');
%
if isfield(data,'loadstructs') && isfield(data.loadstructs,'equilibrium_jd'),% new run_lukert, backup file, with fluct
    equilDKE = data.loadstructs.equilibrium_jd.equilDKE;
    mksa = data.loadstructs.mksacoefbuilder_dke_yp.mksa;
    radialDKE = data.loadstructs.radialgrid_dke_jd.radialDKE;
    momentumDKE = data.loadstructs.momentumgrid_dke_jd.momentumDKE;
    data.XXfM = data.loadstructs.coll_dke_jd.XXfM;
elseif isfield(data,'loadstructs'),% old run_lukert, backup file, with fluct
    equilDKE = data.loadstructs.equilDKE;
    mksa = data.loadstructs.mksa;
    radialDKE = data.loadstructs.radialDKE;
    momentumDKE = data.loadstructs.momentumDKE;
    data.XXfM = data.loadstructs.XXfM;
elseif isfield(data,'lukestructs'),% new run_lukert, LUKE_RESULTS, no fluct
    data.Ztime = data.lukestructs.output.dke_out.FPtime;
    data.Zitn = length(data.Ztime);
    data.Zcurr = data.lukestructs.output.Zcurr;
    data.ZP0 = data.lukestructs.output.ZP0;
    data.XXf0_t = data.lukestructs.output.dke_out.XXf0;
    data.XXfM = data.lukestructs.output.dke_out.XXfM;
    data.simul = data.lukestructs.output.dke_out.simul;
    data.equil = data.lukestructs.output.dke_out.equil;
    equilDKE = data.lukestructs.output.equilDKE;
    mksa = data.lukestructs.output.mksa;
    radialDKE = data.lukestructs.output.radialDKE;
    momentumDKE = data.lukestructs.output.momentumDKE;
else% old run_lukert, LUKE_RESULT, no fluct
    data = conc_struct_jd(data,load(filename,'equilDKE','mksa','radialDKE','momentumDKE'));
    data.XXf0_t = data.dke_out.XXf0;
    data.XXfM = data.dke_out.XXfM;
    data.simul = data.dke_out.simul;
    data.equil = data.dke_out.equil;
    equilDKE = data.equilDKE;
    mksa = data.mksa;
    radialDKE = data.radialDKE;
    momentumDKE = data.momentumDKE;
end
%
xrho = equilDKE.xrho.';
xdrho = diff(radialDKE.xrho_S_dke).';
xdA = equilDKE.xdA_dke.';
if isfield(equilDKE,'xdV_dke'),
    xdV = equilDKE.xdV_dke.';  
else
    xdV = equilDKE.xdV_2piRp_dke.'*2*pi*equilDKE.Rp;
end
%
if isfield(data,'Ztime'),% new run_lukert
    Ztime = data.Ztime;%cumsum(data.Ztime);%
elseif isfield(data.Zcurr,'xtn'),% old run_lukert, with fluct
    Ztime = data.Zcurr.xtn;
else% old run_lukert, no fluct
    data = conc_struct_jd(data,load(filename,'dke_out'));
    Ztime = data.dke_out.FPtime;
end
%
nt = length(Ztime);
nr = length(xrho);
%
if isfield(data,'Zitn'),% new run_lukert
    Zitn = data.Zitn;
elseif isfield(data.Zcurr,'xtn'),% old run_lukert, with fluct
    Zitn = 1:nt;
else% old run_lukert, no fluct
    Zitn = nt;
end
%
nitn = length(Zitn);
%
if isfield(data,'Ztime') && any(diff(Ztime) <= 0),% keep until corrected in run_lukert
    Zcumtime = [0,cumsum(Ztime(Zitn))];
    Ztime = Ztime + Zcumtime(ceil((1:nt)/Zitn(1)));
end
%
calctime.waves = NaN(1,nitn);
calctime.luke = NaN(1,nitn);
%
if isfield(data,'calctime'),
    for itn = 1:nitn,
        calctime.waves(itn) = data.calctime(itn).waves;
        calctime.luke(itn) = data.calctime(itn).luke;
    end
end
%
if length(data.Zcurr) == nt,% new run_lukert
    J = NaN(nt,nr);
    P = NaN(nt,nr);
    %
    for it = 1:nt,
        %
        J(it,:) = data.Zcurr(it).x_0_fsav*mksa.j_ref;
        P(it,:) = data.ZP0(it).x_rf_fsav*mksa.P_ref;
    end
elseif isfield(data.Zcurr,'xtn'),% old run_lukert, with fluct
    J = data.Zcurr.t_x_0_fsav*mksa.j_ref;
    P = data.ZP0.t_x_rf_fsav*mksa.P_ref;
end
%
I_tot = J*xdA;
P_rf = P*xdV;
%
%
%
if nitn > 1 && fluct_display.evol,
    plot_fluct_jd(Zitn,xrho,momentumDKE.pn,J,P,data.XXfM,data.XXf0_t,data.simul,data.equil.pTe(1),opt)
end
%
%
%
fwhm = 2*sqrt(2*log(2));% ratio of fwhm to STD
%
Zmask = Zitn;%
%
if isfield(opt,'racc'),
    racc = opt.racc;
else
    racc.P = NaN;
    racc.I = NaN;
end
%
if isfield(opt,'itnmin'),
    itnmin = opt.itnmin;
else
    itnmin = 1;
end
%
[~,~,fluctres] = fluctanalysis_yp(Ztime(Zmask),J(Zmask,:),P(Zmask,:),I_tot(Zmask),P_rf(Zmask),racc,itnmin);
%
sitn = (itnmin - 1) + fluctres.P.iPtot(fluctres.I.iItot);%select values after rejection of abnormal power and current ramp-up points
sitnPr = [1:itnmin - 1, (itnmin - 1) + fluctres.P.iPtotr];
sitnIr = (itnmin - 1) + fluctres.P.iPtot(fluctres.I.iItotr);
%
stn = Ztime(Zmask(sitn));
%
ntn = length(stn);
%
sJ = J(Zmask(sitn),:);% time-dependent current profile
sP = P(Zmask(sitn),:);% time-dependent power profile
sI_tot = I_tot(Zmask(sitn));% time-dependent current
sP_rf = P_rf(Zmask(sitn));% time-dependent powert
%
srhoJ = sJ*(xrho.*xdA)./sI_tot;% time-dependent current peak location
srhoP = sP*(xrho.*xdV)./sP_rf;% time-dependent power peak location
%
srho = repmat(xrho.',[ntn,1]);
sxrhoJ = repmat(srhoJ,[1,nr]);
sxrhoP = repmat(srhoP,[1,nr]);
%
sdrhoJ = fwhm*sqrt((sJ.*((srho-sxrhoJ).^2)*xdA)./sI_tot);%time-dependent current FWHM
sdrhoP = fwhm*sqrt((sP.*((srho-sxrhoP).^2)*xdV)./sP_rf);%time-dependent power FWHM
%
sI_totm = NaN(1,ntn);
ssI_tot =  NaN(1,ntn);
srI_totm =  NaN(1,ntn);
%
sP_rfm =  NaN(1,ntn);
ssP_rf =  NaN(1,ntn);
srP_rfm =  NaN(1,ntn);
%
srhoJm =  NaN(1,ntn);
ssrhoJ =  NaN(1,ntn);
srrhoJm =  NaN(1,ntn);
%
srhoPm =  NaN(1,ntn);
ssrhoP =  NaN(1,ntn);
srrhoPm =  NaN(1,ntn);
%
sdrhoJm =  NaN(1,ntn);
ssdrhoJ =  NaN(1,ntn);
srdrhoJm =  NaN(1,ntn);
%
sdrhoPm =  NaN(1,ntn);
ssdrhoP =  NaN(1,ntn);
srdrhoPm =  NaN(1,ntn);
%
sJm =  NaN(ntn,nr);
ssJ =  NaN(ntn,nr);
srJm =  NaN(ntn,nr);
%
sPm =  NaN(ntn,nr);
ssP =  NaN(ntn,nr);
srPm =  NaN(ntn,nr);
%
for itn = 1:ntn,
    sI_totm(itn) = mean(sI_tot(1:itn));% time-integrated current average
    ssI_tot(itn) = std(sI_tot(1:itn));% time-integrated current STD
    srI_totm(itn) = ssI_tot(itn)/sI_totm(itn)/sqrt(itn);%relative statistical accuracy of current average
    %
    sP_rfm(itn) = mean(sP_rf(1:itn));% time-integrated power average
    ssP_rf(itn) = std(sP_rf(1:itn));% time-integrated power STD
    srP_rfm(itn) = ssP_rf(itn)/sP_rfm(itn)/sqrt(itn);%relative statistical accuracy of power average
    %
    srhoJm(itn) = mean(srhoJ(1:itn));% time-integrated current peak location average
    ssrhoJ(itn) = std(srhoJ(1:itn));% time-integrated current peak location STD
    srrhoJm(itn) = ssrhoJ(itn)/srhoJm(itn)/sqrt(itn);%relative statistical accuracy of current peak location average
    %
    srhoPm(itn) = mean(srhoP(1:itn));% time-integrated power peak location average
    ssrhoP(itn) = std(srhoP(1:itn));% time-integrated power peak location STD
    srrhoPm(itn) = ssrhoP(itn)/srhoPm(itn)/sqrt(itn);%relative statistical accuracy of power peak location average
    %
    sdrhoJm(itn) = mean(sdrhoJ(1:itn));% time-integrated current FWHM average
    ssdrhoJ(itn) = std(sdrhoJ(1:itn));% time-integrated current FWHM STD
    srdrhoJm(itn) = ssdrhoJ(itn)/sdrhoJm(itn)/sqrt(itn);%relative statistical accuracy of current FWHM average
    %
    sdrhoPm(itn) = mean(sdrhoP(1:itn));% time-integrated power FWHM average
    ssdrhoP(itn) = std(sdrhoP(1:itn));% time-integrated power FWHM STD
    srdrhoPm(itn) = ssdrhoP(itn)/sdrhoPm(itn)/sqrt(itn);%relative statistical accuracy of power FWHM average
    %
    sJm(itn,:) = mean(sJ(1:itn,:),1);% time-dependent average current profile
    ssJ(itn,:) = std(sJ(1:itn,:),0,1);% time-dependent average current STD
    srJm(itn,:) = ssJ(itn,:)./sJm(itn,:)/sqrt(itn);% relative statistical accuracy of average current profile
    %
    sPm(itn,:) = mean(sP(1:itn,:),1);% time-dependent average power profile
    ssP(itn,:) = std(sP(1:itn,:),0,1);% time-dependent average power STD
    srPm(itn,:) = ssP(itn,:)./sPm(itn,:)/sqrt(itn);% relative statistical accuracy of average power profile
    %    
end
%
sIm_tot = sJm*xdA;% time-dependent average current - should be the same as sI_totm
sPm_rf = sPm*xdV;% time-dependent average power - should be the same as sP_rfm
%
smrhoJ = sJm*(xrho.*xdA)./sIm_tot;% time-dependent peak location of averaged current
smrhoP = sPm*(xrho.*xdV)./sPm_rf;% time-dependent  peak location of averaged power
%
smxrhoJ = repmat(smrhoJ,[1,nr]);
smxrhoP = repmat(smrhoP,[1,nr]);
%
smdrhoJ = fwhm*sqrt((sJm.*((srho-smxrhoJ).^2)*xdA)./sIm_tot);%time-dependent FWHM of averaged current
smdrhoP = fwhm*sqrt((sPm.*((srho-smxrhoP).^2)*xdV)./sPm_rf);%time-dependent FWHM of averaged power
%
colors = {'k',[0,0.5,0]};
%
if fluct_display.mode >= 2,
    %
    % --------- current ---------
    %
    stnmask = 1:fix(ntn/10):ntn;
    %
    figure(11),clf
    %
    xlim = [0,ceil(max(stn))];
    xlab = 't/\tau_c';
    ylim = NaN;
    ylab = 'I (MA)';
    tit = '';
    leg = {'Fluctuations'};%{'With fluct.','Average'};
    %
    graph1D_jd(stn,sI_tot,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    %graph1D_jd(stn,sI_totm,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    %graph1D_jd(xlim,sI_totm(end)*[1,1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(xlim,Zfluct_ref(iref).J.sI_tot*[1,1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end
    else
        leg_loc = leg;
    end
    if fluct_display.stat,% to verify it is the same as sI_totm
        leg_loc = [leg_loc,'From av. profile']; 
        graph1D_jd(stn,sIm_tot,0,0,'','','',NaN,xlim,ylim,'--','none','m',0.5,20+14i);
    end
    graph1D_jd(stn(stnmask),sI_totm(stnmask),0,0,'','','',leg_loc,xlim,ylim,'none','none','b',2,20+14i,gca,1,0.7,0.7,srI_totm(stnmask).*sI_totm(stnmask));
    graph1D_jd(Ztime(Zmask(sitnPr)),I_tot(Zmask(sitnPr)),0,0,'','','',NaN,xlim,ylim,'none','o','m',2,20+14i);
    graph1D_jd(Ztime(Zmask(sitnIr)),I_tot(Zmask(sitnIr)),0,0,'','','',NaN,xlim,ylim,'none','*','r',2,20+14i);
    %
    % --------- current radial location ---------
    %
    figure(12),clf
    %
    ylim = NaN;
    ylab = 'r/a';
    tit = 'current deposition';
    %
    graph1D_jd(stn,srhoJ,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(stn,srhoJm,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    %graph1D_jd(xlim,srhoJm(end)*[1,1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(xlim,Zfluct_ref(iref).J.srho*[1,1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end        
    else
        leg_loc = leg;
    end
    if fluct_display.stat,% should be slightly different from srhoJm
        leg_loc = [leg_loc,'From av. profile']; 
        graph1D_jd(stn,smrhoJ,0,0,'','','',NaN,xlim,ylim,'--','none','m',0.5,20+14i);
    end
    graph1D_jd(stn(stnmask),srhoJm(stnmask),0,0,'','','',leg_loc,xlim,ylim,'none','none','b',2,20+14i,gca,1,0.7,0.7,srrhoJm(stnmask).*srhoJm(stnmask));
    %
    % --------- current radial width ---------
    %
    figure(13),clf
    %
    ylim = NaN;
    ylab = 'FWHM';
    %
    graph1D_jd(stn,sdrhoJ,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(stn,sdrhoJm,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    %graph1D_jd(xlim,sdrhoJm(end)*[1,1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(xlim,Zfluct_ref(iref).J.sdrho*[1,1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    else
        leg_loc = leg;
    end
    if fluct_display.stat,
        leg_loc = [leg_loc,'\sigma_{\rho}','(\sigma_{\rho}^2 + FWHM^2)^{(1/2)}','From av. profile']; 
        graph1D_jd(stn,fwhm*ssrhoJ,0,0,'','','',NaN,xlim,ylim,'--','none','m',0.5,20+14i);
        graph1D_jd(stn,sqrt((fwhm*ssrhoJ).^2 + sdrhoJm.^2),0,0,'','','',NaN,xlim,ylim,'--','none','c',0.5,20+14i);
        graph1D_jd(stn,smdrhoJ,0,0,'','','',NaN,xlim,ylim,'-','none','y',2,20+14i);
    end
    graph1D_jd(stn(stnmask),sdrhoJm(stnmask),0,0,'','','',leg_loc,xlim,ylim,'none','none','b',2,20+14i,gca,1,0.7,0.7,srdrhoJm(stnmask).*sdrhoJm(stnmask));
    %
    % --------- power ---------
    %
    figure(14),clf
    %
    ylim = NaN;
    ylab = 'P_{RF} (MW)';
    tit = '';
    %
    graph1D_jd(stn,sP_rf,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(stn,sP_rfm,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    %graph1D_jd(xlim,sP_rfm(end)*[1,1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(xlim,Zfluct_ref(iref).P.sP_rf*[1,1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    else
        leg_loc = leg;
    end
    if fluct_display.stat,% to verify it is the same as sP_rfm
        leg_loc = [leg_loc,'From av. profile']; 
        graph1D_jd(stn,sPm_rf,0,0,'','','',NaN,xlim,ylim,'--','none','m',0.5,20+14i);
    end
    graph1D_jd(stn(stnmask),sP_rfm(stnmask),0,0,'','','',leg_loc,xlim,ylim,'none','none','b',2,20+14i,gca,1,0.7,0.7,srP_rfm(stnmask).*sP_rfm(stnmask));
    graph1D_jd(Ztime(Zmask(sitnPr)),P_rf(Zmask(sitnPr)),0,0,'','','',NaN,xlim,ylim,'none','o','r',2,20+14i);
    graph1D_jd(Ztime(Zmask(sitnIr)),P_rf(Zmask(sitnIr)),0,0,'','','',NaN,xlim,ylim,'none','*','m',2,20+14i);
    %
    % --------- power radial location ---------
    %
    figure(15),clf
    %
    ylim = NaN;
    ylab = 'r/a';
    tit = 'power deposition';
    %
    graph1D_jd(stn,srhoP,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(stn,srhoPm,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    %graph1D_jd(xlim,srhoPm(end)*[1,1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(xlim,Zfluct_ref(iref).P.srho*[1,1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    else
        leg_loc = leg;
    end
    if fluct_display.stat,% should be slightly different from srhoPm
        leg_loc = [leg_loc,'From av. profile']; 
        graph1D_jd(stn,smrhoP,0,0,'','','',NaN,xlim,ylim,'--','none','m',0.5,20+14i);
    end
    graph1D_jd(stn(stnmask),srhoPm(stnmask),0,0,'','','',leg_loc,xlim,ylim,'none','none','b',2,20+14i,gca,1,0.7,0.7,srrhoPm(stnmask).*srhoPm(stnmask));
    %
    % --------- power radial width ---------
    %
    figure(16),clf
    %
    ylim = NaN;
    ylab = 'FWHM';
    %
    graph1D_jd(stn,sdrhoP,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(stn,sdrhoPm,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    %graph1D_jd(xlim,sdrhoPm(end)*[1,1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20+14i);
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(xlim,Zfluct_ref(iref).P.sdrho*[1,1],0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    else
        leg_loc = leg;
    end
    if fluct_display.stat,
        leg_loc = [leg_loc,'\sigma_{\rho}','(\sigma_{\rho}^2 + FWHM^2)^{(1/2)}','From av. profile']; 
        graph1D_jd(stn,fwhm*ssrhoP,0,0,'','','',NaN,xlim,ylim,'--','none','m',0.5,20+14i);
        graph1D_jd(stn,sqrt((fwhm*ssrhoP).^2 + sdrhoPm.^2),0,0,'','','',NaN,xlim,ylim,'--','none','c',0.5,20+14i);
        graph1D_jd(stn,smdrhoP,0,0,'','','',NaN,xlim,ylim,'-','none','y',2,20+14i);
    end
    graph1D_jd(stn(stnmask),sdrhoPm(stnmask),0,0,'','','',leg_loc,xlim,ylim,'none','none','b',2,20+14i,gca,1,0.7,0.7,srdrhoPm(stnmask).*sdrhoPm(stnmask));
    %
    % --------- current profile ---------
    %
    figure(17),clf
    %
    xlim = [0,1];
    xlab = 'r/a';
    ylim = NaN;
    ylab = 'dJ/d\rho (MA)';
    tit = '';
    leg = {'With fluct.'};
    %
    sxdAdrho = repmat((xdA./xdrho).',[ntn,1]);
    sxdIdrhom = sJm.*sxdAdrho;
    %
    smxdrhoJ = repmat(smdrhoJ,[1,nr]);
    sxIm_tot = repmat(sIm_tot,[1,nr]);
    %
    sxdIdrhom_fit = sxIm_tot.*exp(-(srho - smxrhoJ).^2./(smxdrhoJ*sqrt(2)/fwhm).^2)./(sqrt(pi)*smxdrhoJ*sqrt(2)/fwhm);
    %
    %graph1D_jd(xrho,sJm(end,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,ssJ(end,:));
    graph1D_jd(xrho,sxdIdrhom(end,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,sxdIdrhom(end,:).*srJm(end,:));
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            xdIdrhom_ref = Zfluct_ref(iref).J.sJm.*(Zfluct_ref(iref).dA./Zfluct_ref(iref).drho).';
            graph1D_jd(Zfluct_ref(iref).rho,xdIdrhom_ref,0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    else
        leg_loc = leg;
    end
    if fluct_display.stat,
        leg_loc = [leg_loc,'Fit']; 
        graph1D_jd(xrho,sxdIdrhom_fit(end,:),0,0,'','','',leg_loc,xlim,ylim,'--','none','b',2,20+14i);
    else
        graph1D_jd(NaN,NaN,0,0,'','','',leg_loc,xlim,ylim,'--','none','b',2,20+14i);
    end
    %
    % --------- power profile ---------
    %
    figure(18),clf
    %
    xlim = [0,1];
    xlab = 'r/a';
    ylim = NaN;
    ylab = 'dP_{RF}/d\rho (MW)';
    tit = '';
    leg = {'With fluct.'};
    %
    sxdVdrho = repmat((xdV./xdrho).',[ntn,1]);
    sxdPdrhom = sPm.*sxdVdrho;
    %
    smxdrhoP = repmat(smdrhoP,[1,nr]);
    sxPm_rf = repmat(sPm_rf,[1,nr]);
    %
    sxdPdrhom_fit = sxPm_rf.*exp(-(srho - smxrhoP).^2./(smxdrhoP*sqrt(2)/fwhm).^2)./(sqrt(pi)*smxdrhoP*sqrt(2)/fwhm);
    %
    %graph1D_jd(xrho,sJm(end,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,ssJ(end,:));
    graph1D_jd(xrho,sxdPdrhom(end,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,sxdPdrhom(end,:).*srPm(end,:));
    if ~isempty(Zfluct_ref),
        leg_loc = [leg,leg_ref];
        for iref = 1:length(Zfluct_ref),
            xdPdrhom_ref = Zfluct_ref(iref).P.sPm.*(Zfluct_ref(iref).dV./Zfluct_ref(iref).drho).';
            graph1D_jd(Zfluct_ref(iref).rho,xdPdrhom_ref,0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    else
        leg_loc = leg;
    end
    if fluct_display.stat,
        leg_loc = [leg_loc,'Fit']; 
        graph1D_jd(xrho,sxdPdrhom_fit(end,:),0,0,'','','',leg_loc,xlim,ylim,'--','none','b',2,20+14i);
    else
        graph1D_jd(NaN,NaN,0,0,'','','',leg_loc,xlim,ylim,'--','none','b',2,20+14i);
    end
    %
    % --------- power density profile ---------
    %
    figure(19),clf
    %
    xlim = [0,1];
    xlab = 'r/a';
    ylim = NaN;
    ylab = 'P_{RF} (MW/m^3)';
    tit = '';
    %
    if isfield(opt,'hxrinv');
        %
        hxrinv = load(opt.hxrinv);
        hxrinv.rho = hxrinv.rayon/(1000*hxrinv.ap);
        hxrinv.Xinterp = interp1(hxrinv.rho,hxrinv.X,xrho).';
        hxrinv.P = hxrinv.Xinterp*(sPm(end,:)*xdrho)/(hxrinv.Xinterp*xdrho);
        hxrinv.P(find(hxrinv.P < 0,1,'first'):end) = 0;
        %
        graph1D_jd(xrho,hxrinv.P,0,0,'','','',NaN,xlim,ylim,'-','none','b',2,20+14i);
        %
        leg_loc = {'Exp. HXR'};
        %
    else
        leg_loc = {};
    end
    %
    if ~isempty(Zfluct_ref),
        leg_loc = [leg_loc,leg_ref];
        for iref = 1:length(Zfluct_ref),
            graph1D_jd(Zfluct_ref(iref).rho,Zfluct_ref(iref).P.sPm,0,0,'','','',NaN,xlim,ylim,'-','none',colors{iref},2,20+14i);
        end             
    end
    %
    leg = [leg_loc,'With fluct.'];
    graph1D_jd(xrho,sPm(end,:),0,0,xlab,ylab,tit,leg,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,sxdPdrhom(end,:).*srPm(end,:));
    %
end
%
Zfluct_out.stn = stn;
Zfluct_out.rho = xrho;
Zfluct_out.drho = xdrho;
Zfluct_out.dA = xdA;
Zfluct_out.dV = xdV;
Zfluct_out.calctime = calctime;
Zfluct_out.J.sJ = sJ;
Zfluct_out.J.sJm = sJm;
Zfluct_out.J.ssJ = ssJ;
Zfluct_out.J.srJm = srJm;
Zfluct_out.J.sI_tot = sI_tot;
Zfluct_out.J.sI_totm = sI_totm;
Zfluct_out.J.ssI_tot = ssI_tot;
Zfluct_out.J.srI_totm = srI_totm;
Zfluct_out.J.srho = srhoJ;
Zfluct_out.J.sdrho = sdrhoJ;
Zfluct_out.J.srhom = srhoJm;
Zfluct_out.J.ssrho = ssrhoJ;
Zfluct_out.J.srrhom = srrhoJm;
Zfluct_out.J.sdrhom = sdrhoJm;
Zfluct_out.J.ssdrho = ssdrhoJ;
Zfluct_out.J.srdrhom = srdrhoJm;
Zfluct_out.J.smrho = smrhoJ;
Zfluct_out.J.smdrho = smdrhoJ;
Zfluct_out.P.sP = sP;
Zfluct_out.P.sPm = sPm;
Zfluct_out.P.ssP = ssP;
Zfluct_out.P.srPm = srPm;
Zfluct_out.P.sP_rf = sP_rf;
Zfluct_out.P.sP_rfm = sP_rfm;
Zfluct_out.P.ssP_rf = ssP_rf;
Zfluct_out.P.srP_rfm = srP_rfm;
Zfluct_out.P.srho = srhoP;
Zfluct_out.P.sdrho = sdrhoP;
Zfluct_out.P.srhom = srhoPm;
Zfluct_out.P.ssrho = ssrhoP;
Zfluct_out.P.srrhom = srrhoPm;
Zfluct_out.P.sdrhom = sdrhoPm;
Zfluct_out.P.ssdrho = ssdrhoP;
Zfluct_out.P.srdrhom = srdrhoPm;
Zfluct_out.P.smrho = smrhoP;
Zfluct_out.P.smdrho = smdrhoP;
%


