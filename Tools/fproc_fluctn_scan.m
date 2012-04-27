function fproc_fluctn_scan(p_opt,id_equil,id_fluct,locid_simul,id_wave,sigmar_max,sigmar_hwhm,Nfluct,tn,dtn,Zfluct_ref)
%
if length(Nfluct) > 1,
    scanlist = Nfluct;
    scanvar = 'Nfluct';
    xlab = 'N';
    logx = 1;
elseif length(sigmar_max) > 1,
    scanlist = sigmar_max;
    scanvar = 'sigmar_max';
    xlab = 'sigma';
    logx = 0;
end
%
id_simul0 = [id_equil,'_',id_wave,'_',id_fluct,locid_simul];
%
nscan = length(scanlist);
%
fwhm = 2*sqrt(2*log(2));% ratio of fwhm to STD
%
%Zfluct = cell(1,nscan);
I_totm = NaN(1,nscan);
%
for iscan = 1:nscan,
    %
    eval([scanvar,' = ',num2str(scanlist(iscan)),';']);
    %
    id_simul = [id_simul0,'_sigma',num2str(sigmar_max),'_delta',num2str(sigmar_hwhm),'_dtn',num2str(dtn),'_tn',num2str(tn),'_Nfluct',num2str(Nfluct)];
    id_simul(id_simul == '.') = 'p';
    id_simul(id_simul == '+') = 'p';
    %
    filename = ['backup_',id_simul,'.mat'];
    %
    if exist(filename,'file'),
        %
        Zfluct = fproc_fluctn_jd(filename);%{iscan}
        %
        I_totm(iscan) = Zfluct.J.sI_totm(end);
        sI_tot(iscan) = Zfluct.J.ssI_tot(end);
        rI_totm(iscan) = Zfluct.J.srI_totm(end);
        %
        rhom(iscan) = Zfluct.J.srhom(end);
        srho(iscan) = Zfluct.J.ssrho(end);
        rrhom(iscan) = Zfluct.J.srrhom(end);
        %
        drhom(iscan) = Zfluct.J.sdrhom(end);
        sdrho(iscan) = Zfluct.J.ssdrho(end);
        rdrhom(iscan) = Zfluct.J.srdrhom(end);
        mdrho(iscan) = Zfluct.J.smdrho(end);
        %
        wavestime(iscan) = sum(Zfluct.calctime.waves);
        luketime(iscan) = sum(Zfluct.calctime.luke);
        %
    else
    end
end
%
%
% --------- current ---------
%
figure(1),clf
%
xlim = NaN;
ylim = NaN;
ylab = '<I> (MA)';
tit = '';
leg = {'With fluct.'};
%
%graph1D_jd(scanlist,I_totm,logx,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,I_totm.*rI_totm);
graph1D_jd(scanlist,I_totm,logx,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,sI_tot);
if ~isempty(Zfluct_ref),
    leg = [leg,'No fluct.'];
   graph1D_jd(get(gca,'xlim'),Zfluct_ref.J.sI_tot*[1,1],logx,0,'','','',leg,xlim,ylim,'-','none','k',0.5,20+14i);
end
%
% --------- current radial location ---------
%
figure(2),clf
%
ylab = 'r/a';
tit = 'current deposition';
%
graph1D_jd(scanlist,rhom,logx,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,srho);
if ~isempty(Zfluct_ref),
    graph1D_jd(get(gca,'xlim'),Zfluct_ref.J.srho*[1,1],logx,0,'','','',leg,xlim,ylim,'-','none','k',0.5,20+14i);
end
%
% --------- current radial width ---------
%
figure(3),clf
%
ylab = 'FWHM';
leg_loc = [leg,'\sigma_{\rho}','(\sigma_{\rho}^2 + FWHM^2)^{(1/2)}','From av. profile']; 
%
graph1D_jd(scanlist,drhom,logx,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7,sdrho);
if ~isempty(Zfluct_ref),
    graph1D_jd(get(gca,'xlim'),Zfluct_ref.J.sdrho*[1,1],logx,0,'','','',NaN,xlim,ylim,'-','none','k',0.5,20+14i);
end
graph1D_jd(scanlist,fwhm*srho,logx,0,'','','',NaN,xlim,ylim,'--','+','m',2,20+14i);
graph1D_jd(scanlist,sqrt((fwhm*srho).^2 + drhom.^2),logx,0,'','','',NaN,xlim,ylim,'--','o','c',2,20+14i);
graph1D_jd(scanlist,mdrho,logx,0,'','','',leg_loc,xlim,ylim,'--','*','g',2,20+14i);
%
% --------- calculation time ---------
%
figure(4),clf
%
xlim = NaN;
xlab = 'N';
ylim = NaN;
ylab = 't (s)';
tit = '';
leg = {'C3PO','LUKE','TOTAL'};
%
graph1D_jd(scanlist,wavestime,logx,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
graph1D_jd(scanlist,luketime,logx,0,'','','',NaN,xlim,ylim,'-','+','b',2,20+14i);
graph1D_jd(scanlist,wavestime + luketime,logx,0,'','','',leg,xlim,ylim,'-','+','m',2,20+14i);


%      stn: [1x97 double]
%      rho: [30x1 double]
%     drho: [30x1 double]
%        J: [1x1 struct]
%        P: [1x1 struct]
% 
% K>> Zfluct{ifluct}.J
% 
% ans = 
% 
%           sJ: [97x30 double]
%          sJm: [97x30 double]
%          ssJ: [97x30 double]
%         srJm: [97x30 double]
%       sI_tot: [97x1 double]
%      sI_totm: [1x97 double]
%      ssI_tot: [1x97 double]
%     srI_totm: [1x97 double]
%         srho: [97x1 double]
%        sdrho: [97x1 double]
%        srhom: [1x97 double]
%        ssrho: [1x97 double]
%       srrhom: [1x97 double]
%       sdrhom: [1x97 double]
%       ssdrho: [1x97 double]
%      srdrhom: [1x97 double]
%        smrho: [97x1 double]
%       smdrho: [97x1 double]
% 
% K>> Zfluct{ifluct}.P
% 
% ans = 
% 
%          sP: [97x30 double]
%         sPm: [97x30 double]
%         ssP: [97x30 double]
%        srPm: [97x30 double]
%       sP_rf: [97x1 double]
%      sP_rfm: [1x97 double]
%      ssP_rf: [1x97 double]
%     srP_rfm: [1x97 double]
%        srho: [97x1 double]
%       sdrho: [97x1 double]
%       srhom: [1x97 double]
%       ssrho: [1x97 double]
%      srrhom: [1x97 double]
%      sdrhom: [1x97 double]
%      ssdrho: [1x97 double]
%     srdrhom: [1x97 double]
%       smrho: [97x1 double]
%      smdrho: [97x1 double]
% 
