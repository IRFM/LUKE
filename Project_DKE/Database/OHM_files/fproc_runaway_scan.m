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
spnmax_f = NaN(1,nscan);
spnmin_f = NaN(1,nscan);
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
    spnmax_f(iscan) = max(fgrid{iscan}.pn);
    spnmin_f(iscan) = min(fgrid{iscan}.pn);
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
sgammamax_f = sqrt(1 + spnmax_f.^2.*sbetath2);
sEcmax_f = 1e-3*mc2*(sgammamax_f - 1);
%
sgammamin_f = sqrt(1 + spnmin_f.^2.*sbetath2);
sEcmin_f = 1e-3*mc2*(sgammamin_f - 1);
%
siz = 20+14i;
tit = '';
if ~isfield(opt,'color') || opt.color,
    colors = {'b','r',[0,0.75,0],[0.75,0,0.75],[0,0.75,0.75],[0.75,0.75,0],'k'};
    %colors = {'k','b','r','g','m','c','y'};
    styles = {'-','-','-','-','-','-','-'};
    sizes = [2,2,2,2,2];
    colstr = '_col';
else
    colors = {'k','k','k','k','k','k','k','k','k'};
    styles = {'-','--','-.','-','--','-.'};
    colstr = '';
    sizes = [2,0.5,0.5,0.5,2];%,0.5
end
%
if ~isfield(graph,'x'),
    graph.x = scanval;
end
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
    xtick = graph.x;
end
if ~isfield(graph,'xmask'),
    graph.xmask = 1:nscan;
end
%
if ~isfield(graph,'re'),
    graph.re = true;
end
%
if isfield(graph,'scanunits') && ~isempty(graph.scanunits),
    unitstr1 = [' (',graph.scanunits,')'];
    unitstr2 = [' ',graph.scanunits];
else
    unitstr1 = '';
    unitstr2 = '';
end
%
figure(1),clf
%
xlab = [scanlab,unitstr1];
ylab = 'n/n_e';
if isfield(graph,'ylim_norm'),
    ylim = graph.ylim_norm;
else
    ylim = 10.^[-9,1];
    graph.ytick_norm = 10.^(-8:2:0);
end
if graph.re,
    leg = {'ext. RE','int. RE','tot. RE'};
    %
    graph1D_jd(graph.x(graph.xmask),snorm.re(graph.xmask),xlog,1,'','','',NaN,xlim,ylim,styles{1},'d',colors{2},sizes(1),siz,gca);
    graph1D_jd(graph.x(graph.xmask),snorm.ri(graph.xmask),xlog,1,'','','',NaN,xlim,ylim,styles{2},'*',colors{3},sizes(1),siz,gca);
    graph1D_jd(graph.x(graph.xmask),snorm.rtot(graph.xmask),xlog,1,'','','',NaN,xlim,ylim,styles{4},'o',colors{5},sizes(2),siz,gca);%+12i
else
    leg = {'runaways'};
    %
    graph1D_jd(graph.x(graph.xmask),snorm.rtot(graph.xmask),xlog,1,'','','',NaN,xlim,ylim,styles{4},'o',colors{5},sizes(2),siz,gca);%+12i
end
leg = [leg,'bulk','total'];
graph1D_jd(graph.x(graph.xmask),snorm.b(graph.xmask),xlog,1,'','','',NaN,xlim,ylim,styles{4},'s',colors{4},sizes(2),siz,gca);
graph1D_jd(graph.x(graph.xmask),snorm.tot(graph.xmask),xlog,1,xlab,ylab,tit,leg,xlim,ylim,styles{5},'x',colors{1},sizes(1),siz,gca,0.9,0.7,0.7);
%
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_norm'),
    set(gca,'ytick',graph.ytick_norm)
end
if xlog,
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','off')
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
graph1D_jd(graph.x,sRR.re,xlog,1,'','','',NaN,xlim,ylim,'none','s','r',2,siz,gca);
graph1D_jd(graph.x,sRR.ri,xlog,1,'','','',NaN,xlim,ylim,'none','s','b',2,siz,gca);
graph1D_jd(graph.x,sRR.rtot,xlog,1,xlab,ylab,tit,leg,xlim,ylim,'none','s','k',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(graph.x,-sRR.re,xlog,1,'','','',NaN,xlim,ylim,'none','o','r',2,siz,gca);
graph1D_jd(graph.x,-sRR.ri,xlog,1,'','','',NaN,xlim,ylim,'none','o','b',2,siz,gca);
graph1D_jd(graph.x,-sRR.rtot,xlog,1,'','','',NaN,xlim,ylim,'none','o','k',2,siz,gca);    
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_gamma'),
    set(gca,'ytick',graph.ytick_gamma)
end
if xlog,
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','off')
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
graph1D_jd(graph.x,spc,xlog,0,'','','',NaN,xlim,ylim,'-','s','r',2,siz,gca);
graph1D_jd(graph.x,spnmax_S,xlog,0,'','','',NaN,xlim,ylim,'-','o','k',2,siz,gca);
graph1D_jd(graph.x,spnmin,xlog,0,'','','',NaN,xlim,ylim,'-','d','b',2,siz,gca);
graph1D_jd(graph.x,spnmax,xlog,0,xlab,ylab,tit,leg,xlim,ylim,'-','x','m',2,siz,gca,0.9,0.7,0.7);
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_p'),
    set(gca,'ytick',graph.ytick_p)
end
if xlog,
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','off')
end    
%
figure(4),clf
%
ylab = 'p/(mc)';
if isfield(graph,'ylim_pc'),
    ylim = graph.ylim_pc;
else
    ylim = NaN;%[0,max(spnmax_S)*1.1];
end    
%
leg = NaN;%{'critical','grid','minimum','maximum'};
%
graph1D_jd(graph.x,spnmax.*sqrt(sbetath2),xlog,0,xlab,ylab,tit,leg,xlim,ylim,'-','s','b',2,siz,gca,0.9,0.7,0.7);
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_pc'),
    set(gca,'ytick',graph.ytick_pc)
end
if xlog,
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','off')
end    
%
figure(5),clf
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
graph1D_jd(graph.x,sEcc,xlog,0,'','','',NaN,xlim,ylim,'-','s','r',2,siz,gca);
graph1D_jd(graph.x,sEcmax_S,xlog,0,'','','',NaN,xlim,ylim,'-','o','k',2,siz,gca);
graph1D_jd(graph.x,sEcmin,xlog,0,'','','',NaN,xlim,ylim,'-','d','b',2,siz,gca);
graph1D_jd(graph.x,sEcmax,xlog,0,xlab,ylab,tit,leg,xlim,ylim,'-','x','m',2,siz,gca,0.9,0.7,0.7);
 %
if ~isnan(xtick),
    set(gca,'xtick',xtick)
end
%
if isfield(graph,'ytick_ec'),
    set(gca,'ytick',graph.ytick_ec)
end
if xlog,
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','off')
end    
%
print_jd(p_opt,['fig_',id_simul_scan,'_nr',colstr],['./figures',filesep,scanstr],1)
print_jd(p_opt,['fig_',id_simul_scan,'_rr',colstr],['./figures',filesep,scanstr],2)
print_jd(p_opt,['fig_',id_simul_scan,'_p',colstr],['./figures',filesep,scanstr],3)
print_jd(p_opt,['fig_',id_simul_scan,'_pmax',colstr],['./figures',filesep,scanstr],4)
print_jd(p_opt,['fig_',id_simul_scan,'_Ec',colstr],['./figures',filesep,scanstr],5)
%
if isfield(graph,'iscandisp'),
    %
    figure(6),clf
    %
    xlab = '$\mathcal{E}_k$ (MeV)';
    ylab = '$f(\mathcal{E}_k,\xi = 1)$';
    %
    if ~isfield(graph,'xlog_f'),
        graph.xlog_f = false;
    end
    %
    if ~isfield(graph,'xlim_f'),
        if graph.xlog_f,
            graph.xlim_f = [min(sEcmin_f),max(sEcmax_f)];                
        else
            graph.xlim_f = [0,max(sEcmax_f)];                
        end
    end
    %
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
        if isfield(graph,'scanformat'),
            legstr = num2str(graph.x(graph.iscandisp(iiscan)),graph.scanformat);
        else
            legstr = num2str(graph.x(graph.iscandisp(iiscan)));
        end
        leg{iiscan} = [scanlab,' = ',legstr,unitstr2];
        graph1D_jd(Ec{graph.iscandisp(iiscan)},sfpar{graph.iscandisp(iiscan)},graph.xlog_f,1,'','','',NaN,graph.xlim_f,ylim,styles{iiscan},'none',colors{iiscan},sizes(iiscan),siz);
    end
    if isfield(graph,'scanformat'),
        legstr = num2str(graph.x(graph.iscandisp(nscandisp)),graph.scanformat);
    else
        legstr = num2str(graph.x(graph.iscandisp(nscandisp)));
    end
    leg{nscandisp} = [scanlab,' = ',legstr,unitstr2];
    graph1D_jd(Ec{graph.iscandisp(nscandisp)},sfpar{graph.iscandisp(nscandisp)},graph.xlog_f,1,xlab,ylab,tit,leg,graph.xlim_f,ylim,styles{nscandisp},'none',colors{nscandisp},sizes(nscandisp),siz,gca,0.9,0.7,0.7);
    %
    if isfield(graph,'xtick_f'),
        set(gca,'xtick',graph.xtick_f)
    end
    if isfield(graph,'ytick_f'),
        set(gca,'ytick',graph.ytick_f)
    end
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','on')
    set(gca,'YMinorGrid','off')
    set(gca,'YMinorTick','on')
    set(get(gca,'xlabel'),'interpreter','latex')
    set(get(gca,'ylabel'),'interpreter','latex')
    %
    print_jd(p_opt,['fig_',id_simul_scan,'_f',colstr],['./figures',filesep,scanstr],6)
    %
end
%
