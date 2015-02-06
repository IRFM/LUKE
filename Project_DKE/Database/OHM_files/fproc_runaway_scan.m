function fproc_runaway_scan(scanvar,scanval,scanstr,scanlab,RR,mksa,Ec,f,tn,tRR,tnorm,fgrid,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,p_opt,id_simul_scan)
%
%
% disp(['coll_mode = ',num2str(opt.coll_mode),' ; bounce_mode = ',num2str(opt.bounce_mode),' ; equil = ',id_equil])
% disp(['Te/mc2 = ',num2str(betath2),' ; E/Ec = ',num2str(alpha),' ; E/ED = ',num2str(alpha*betath2),' ; Zi = ',num2str(Zi)])
% if opt.synchro_mode == 0,
%     disp(['No synchrotron force'])
% elseif imag(wpr) == 0,
%     disp(['Synchrotron force on : wc2/wp2 = ',num2str(wpr)]);
% elseif imag(wpr) > 0,
%     disp(['Synchrotron force on : Bhat = ',num2str(imag(wpr))]);
% else
%     disp(['Synchrotron force on : 1/taur = ',num2str(-imag(wpr))]);
% end    
% disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt(alpha*betath2))])%NR
% disp(['Relativ. : pc/pT = ',num2str(1/sqrt((alpha - 1)*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt((alpha - 1)*betath2))])%rel
% disp(' ')
%     disp(['--> r/a = ',num2str(rho_S)])
%     disp(['--> LUKE RR from bound calc. (normalized to ne and tauc) : ',num2str(RR)])
%     disp(['--> LUKE RR from exact calc. (normalized to ne and tauc) : ',num2str(tRR.re(end) + tRR.ri(end))])
% 	disp(['--> LUKE ext. RE fraction : ',num2str(tnorm.re(end))])
% 	disp(['--> LUKE int. RE fraction : ',num2str(tnorm.ri(end))])
% 	disp(['--> LUKE tot. RE fraction : ',num2str(tnorm.re(end) + tnorm.ri(end))])
%     %
%     if opt.synchro_mode,
%         fpar = f{end}(:,end).';
%         ipparnan = find(fpar < 0,1);
%         if ~isempty(ipparnan),
%             fpar(ipparnan:end) = NaN;
%         end
%         ipparmin = find(diff(fpar) > 0,1);
%         if ~isempty(ipparmin),
%             disp(['--> minimum found in f(xi=1) : p/pT = ',num2str(fgrid.pn(ipparmin)),' ; Ec = ',num2str(Ec(ipparmin)),' MeV']);
%             %
%             ipparmax = find(diff(fpar) < 0 & 1:np-1 > ipparmin,1);
%             %
%             if ~isempty(ipparmax),
%                 disp(['--> maximum found in f(xi=1) : p/pT = ',num2str(fgrid.pn(ipparmax)),' ; Ec = ',num2str(Ec(ipparmax)),' MeV']);
%             end
%         end
%     end



%
nscan = length(scanval);
%
snorm.re = NaN(1,nscan);
snorm.ri = NaN(1,nscan);
snorm.rtot = NaN(1,nscan);
snorm.b = NaN(1,nscan);
snorm.tot = NaN(1,nscan);
%
sRR.re = NaN(1,nscan);
sRR.ri = NaN(1,nscan);
sRR.rtot = NaN(1,nscan);
%
spnmin = NaN(1,nscan);
spnmax = NaN(1,nscan);
sEcmin = NaN(1,nscan);
sEcmax = NaN(1,nscan);
%
salpha = NaN(1,nscan);
sbetath2 = NaN(1,nscan);
%
spnmax_S = NaN(1,nscan);
spnmax_S_tail = NaN(1,nscan);
%
sfpar = cell(1,nscan);
%
for iscan = 1:nscan,
    %
    snorm.re(iscan) = tnorm{iscan}.re(end);
    snorm.ri(iscan) = tnorm{iscan}.ri(end);
    snorm.rtot(iscan) = tnorm{iscan}.re(end) + tnorm{iscan}.ri(end);
    snorm.b(iscan) = tnorm{iscan}.b(end);
    snorm.tot(iscan) = tnorm{iscan}.tot(end);
    %
    sRR.re(iscan) = tRR{iscan}.re(end);
    sRR.ri(iscan) = tRR{iscan}.ri(end);
    sRR.rtot(iscan) = tRR{iscan}.re(end) + tRR{iscan}.ri(end);
    %
    sfpar{iscan} = f{iscan}{end}(:,end).';
    np = length(sfpar{iscan});
    ipparnan = find(sfpar{iscan} < 0,1);
    if ~isempty(ipparnan),
        sfpar{iscan}(ipparnan:end) = NaN;
    end
    ipparmin = find(diff(sfpar{iscan}) > 0,1);
    if ~isempty(ipparmin),
        spnmin(iscan) = fgrid{iscan}.pn(ipparmin);
        sEcmin(iscan) = Ec{iscan}(ipparmin);
        %
        ipparmax = find(diff(sfpar{iscan}) < 0 & 1:np-1 > ipparmin,1);
        if ~isempty(ipparmax),
            spnmax(iscan) = fgrid{iscan}.pn(ipparmax);
            sEcmax(iscan) = Ec{iscan}(ipparmax);
        end
    end
    if strcmp(scanvar,'alpha'),
        salpha(iscan) = scanval(iscan);
    else
        salpha(iscan) = alpha;
    end
    if strcmp(scanvar,'betath2'),
        sbetath2(iscan) = scanval(iscan);
    else
        sbetath2(iscan) = betath2;
    end
    %
    if strcmp(scanvar,'grid.pnmax_S'),
        spnmax_S(iscan) = scanval(iscan);
    else
        spnmax_S(iscan) = grid.pnmax_S;
    end
    if strcmp(scanvar,'grid.pnmax_S_tail'),
        spnmax_S_tail(iscan) = scanval(iscan);
    else
        spnmax_S_tail(iscan) = grid.pnmax_S_tail;
    end
end
%
spc = 1./sqrt((salpha - 1).*sbetath2);
sgammac = sqrt(salpha./(salpha - 1));
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
sEcc = 1e-3*mc2*(sgammac - 1);
%
if grid.np_tail > 0,
    if imag(grid.pnmax_S_tail) == 0,
        spnmax_S = spnmax_S_tail;
    else
        spnmax_S = spnmax_S.*imag(spnmax_S_tail);
    end
end
%
sgammamax_S = sqrt(1 + spnmax_S.^2.*sbetath2);
sEcmax_S = 1e-3*mc2*(sgammamax_S - 1);
%
siz = 20+14i;
tit = '';
%     colors = {'b','r',[0,0.5,0],[0.5,0,0.5],[0,0.5,0.5],[0.5,0.5,0],'k'};
colors = {'b','r','g','m','y','c','k'};
%
if isfield(graph,'xlim'),
    xlim = graph.xlim;
else
    xlim = NaN;
end
if isfield(graph,'xlog'),
    xlog = graph.xlog;
else
    xlog = 0;
end
if isfield(graph,'xtick'),
    xtick = graph.xtick;
else
    xtick = scanval;
end
%
figure(1),clf
%
xlab = scanlab;
ylab = 'n/n_e';
if isfield(graph,'ylim_norm'),
    ylim = graph.ylim_norm;
else
    ylim = 10.^[-9,1];
    graph.ytick_norm = 10.^(-8:2:0);
end
%
leg = {'ext. RE','int. RE','tot. RE','bulk','total'};
%
graph1D_jd(scanval,snorm.re,xlog,1,'','','',NaN,xlim,ylim,'-','o','r',2,siz,gca);
graph1D_jd(scanval,snorm.ri,xlog,1,'','','',NaN,xlim,ylim,'-','s','b',2,siz,gca);
graph1D_jd(scanval,snorm.rtot,xlog,1,'','','',NaN,xlim,ylim,'--','*','m',0.5,siz,gca);
graph1D_jd(scanval,snorm.b,xlog,1,'','','',NaN,xlim,ylim,'-','d','g',2,siz,gca);
graph1D_jd(scanval,snorm.tot,xlog,1,xlab,ylab,tit,leg,xlim,ylim,'--','x','k',0.5,siz,gca,0.9,0.7,0.7);
%
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_norm'),
    set(gca,'ytick',graph.ytick_norm)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(2),clf
%
ylab = '\Gamma_R\tau_c';
if isfield(graph,'ylim_gamma'),
    ylim = graph.ylim_gamma;
else
    ylim = 10.^[-12,-2];
    graph.ytick_gamma = 10.^(-12:2:-2);
end    
%
leg = {'ext. RR','int. RR','total RR'};
%
graph1D_jd(scanval,sRR.re,xlog,1,'','','',NaN,xlim,ylim,'none','s','r',2,siz,gca);
graph1D_jd(scanval,sRR.ri,xlog,1,'','','',NaN,xlim,ylim,'none','s','b',2,siz,gca);
graph1D_jd(scanval,sRR.rtot,xlog,1,xlab,ylab,tit,leg,xlim,ylim,'none','s','k',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(scanval,-sRR.re,xlog,1,'','','',NaN,xlim,ylim,'none','o','r',2,siz,gca);
graph1D_jd(scanval,-sRR.ri,xlog,1,'','','',NaN,xlim,ylim,'none','o','b',2,siz,gca);
graph1D_jd(scanval,-sRR.rtot,xlog,1,'','','',NaN,xlim,ylim,'none','o','k',2,siz,gca);    
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_gamma'),
    set(gca,'ytick',graph.ytick_gamma)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(3),clf
%
ylab = 'p/p_T';
if isfield(graph,'ylim_p'),
    ylim = graph.ylim_p;
else
    ylim = [0,max(spnmax_S)*1.1];
end    
%
leg = {'critical','grid','minimum','maximum'};
%
graph1D_jd(scanval,spc,xlog,0,'','','',NaN,xlim,ylim,'-','s','r',2,siz,gca);
graph1D_jd(scanval,spnmax_S,xlog,0,'','','',NaN,xlim,ylim,'-','o','k',2,siz,gca);
graph1D_jd(scanval,spnmin,xlog,0,'','','',NaN,xlim,ylim,'-','d','b',2,siz,gca);
graph1D_jd(scanval,spnmax,xlog,0,xlab,ylab,tit,leg,xlim,ylim,'-','x','m',2,siz,gca,0.9,0.7,0.7);
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_p'),
    set(gca,'ytick',graph.ytick_p)
end
%
figure(4),clf
%
ylab = 'E_c (keV)';
if isfield(graph,'ylim_ec'),
    ylim = graph.ylim_ec;
else
    ylim = [0,max(sEcmax_S)*1.1];
end    
%
leg = {'critical','grid','minimum','maximum'};
%
graph1D_jd(scanval,sEcc,xlog,0,'','','',NaN,xlim,ylim,'-','s','r',2,siz,gca);
graph1D_jd(scanval,sEcmax_S,xlog,0,'','','',NaN,xlim,ylim,'-','o','k',2,siz,gca);
graph1D_jd(scanval,sEcmin,xlog,0,'','','',NaN,xlim,ylim,'-','d','b',2,siz,gca);
graph1D_jd(scanval,sEcmax,xlog,0,xlab,ylab,tit,leg,xlim,ylim,'-','x','m',2,siz,gca,0.9,0.7,0.7);
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_ec'),
    set(gca,'ytick',graph.ytick_ec)
end
%
print_jd(p_opt,['fig_',id_simul_scan,'_nr'],['./figures',filesep,scanstr],1)
print_jd(p_opt,['fig_',id_simul_scan,'_rr'],['./figures',filesep,scanstr],2)
print_jd(p_opt,['fig_',id_simul_scan,'_p'],['./figures',filesep,scanstr],3)
print_jd(p_opt,['fig_',id_simul_scan,'_Ec'],['./figures',filesep,scanstr],4)
%
if isfield(graph,'iscandisp'),
    %
    figure(5),clf
    %
    xlab = 'E_c (MeV)';
    ylab = 'f(E_c,\xi = 1)';
    xlim = [0,max(sEcmax_S)];    
    if isfield(graph,'ylim_f'),
        ylim = graph.ylim_f;
    else
        ylim = [eps,2];
        graph.ytick_f = 10.^(-18:2:2);
    end    
    %
    nscandisp = length(graph.iscandisp);
    %
    leg = cell(1,nscandisp);
    %
    for iiscan = 1:nscandisp-1,
        leg{iiscan} = [scanlab,' = ',num2str(scanval(graph.iscandisp(iiscan)))];
        graph1D_jd(Ec{graph.iscandisp(iiscan)},sfpar{graph.iscandisp(iiscan)},0,1,'','','',NaN,xlim,ylim,'-','none',colors{iiscan},2,siz);
    end
    leg{nscandisp} = [scanlab,' = ',num2str(scanval(graph.iscandisp(nscandisp)))];
    graph1D_jd(Ec{graph.iscandisp(nscandisp)},sfpar{graph.iscandisp(nscandisp)},0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{nscandisp},2,siz,gca,0.9,0.7,0.7);
    %
    if isfield(graph,'ytick_f'),
        set(gca,'ytick',graph.ytick_f)
    end
    set(gca,'YMinorGrid','off')
    set(gca,'YMinorTick','on')
    %
    print_jd(p_opt,['fig_',id_simul_scan,'_f'],['./figures',filesep,scanstr],5)
    %
end
%
