function fcomp_sync(Ec,tn,f_nosync,tRR_nosync,tnorm_nosync,f_sync,tRR_sync,tnorm_sync,l_opt,graph,p_opt,id_simul)
%
ntn = length(tn);
%
if l_opt == 0,
    xlim = [0,tn(end)];   
    mask = 1:ntn;
else
    xlim = [tn(2),tn(end)];
    mask = 2:ntn;
end
%
siz = 20+14i;
tit = '';
%
figure(1),clf
%
xlab = 't/\tau_c';
ylab = 'n/n_e';
if isfield(graph,'ylim_norm'),
    ylim = graph.ylim_norm;
else
    ylim = 10.^[-9,1];
    graph.ytick_norm = 10.^(-8:2:0);
end
%
leg = {'ext. RE','int. RE','bulk','total'};
%
graph1D_jd(tn(mask),tnorm_nosync.re(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'-','none','r',0.5,siz,gca);
graph1D_jd(tn(mask),tnorm_nosync.ri(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'-','none','b',0.5,siz,gca);
graph1D_jd(tn(mask),tnorm_nosync.b(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],0.5,siz,gca);
graph1D_jd(tn(mask),tnorm_nosync.tot(mask),l_opt > 0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',0.5,siz,gca,0.9,0.7,0.7);
%
graph1D_jd(tn(mask),tnorm_sync.re(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(tn(mask),tnorm_sync.ri(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
graph1D_jd(tn(mask),tnorm_sync.b(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none',[0,0.5,0],2,siz,gca);
graph1D_jd(tn(mask),tnorm_sync.tot(mask),l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
if isfield(graph,'ytick_norm'),
    set(gca,'ytick',graph.ytick_norm)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(2),clf
%
xlab = 't/\tau_c';
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
graph1D_jd(tn(2:ntn),tRR_nosync.re,l_opt > 0,1,'','','',NaN,xlim,ylim,'-','none','r',0.5,siz,gca);
graph1D_jd(tn(2:ntn),tRR_nosync.ri,l_opt > 0,1,'','','',NaN,xlim,ylim,'-','none','b',0.5,siz,gca);
graph1D_jd(tn(2:ntn),tRR_nosync.re + tRR_nosync.ri,l_opt > 0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',0.5,siz,gca,0.9,0.7,0.7);
%
graph1D_jd(tn(2:ntn),tRR_sync.re,l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(tn(2:ntn),tRR_sync.ri,l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
graph1D_jd(tn(2:ntn),tRR_sync.re + tRR_sync.ri,l_opt > 0,1,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
if isfield(graph,'ytick_gamma'),
    set(gca,'ytick',graph.ytick_gamma)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(3),clf
%
fM = f_nosync{1}(:,end);
f_nosync = f_nosync{end}(:,end);
f_sync = f_sync{end}(:,end);
%
xlab = 'E_c (MeV)';
ylab = 'f(E_c,\xi = 1)';
xlim = [0,max(Ec)];
if isfield(graph,'ylim_f'),
    ylim = graph.ylim_f;
else
    ylim = [eps,max(fM)];
    graph.ytick_f = 10.^(-18:2:2);
end    
tit = '';
siz = 20+14i;
%
leg = {'f_M','f (no synch.)','f (with synch.)'};
graph1D_jd(Ec,fM,0,1,'','','',NaN,xlim,ylim,'-','none','b',0.5,siz);
graph1D_jd(Ec,f_nosync,0,1,'','','',NaN,xlim,ylim,'-','none','r',0.5,siz);
graph1D_jd(Ec,f_sync,0,1,xlab,ylab,tit,leg,xlim,ylim,'--','none',[0,0.5,0],2,siz,gca,0.9,0.7,0.7);
%
if isfield(graph,'ytick_f'),
    set(gca,'ytick',graph.ytick_f)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(p_opt,['fig_',id_simul,'_nr'],'./figures',1)
print_jd(p_opt,['fig_',id_simul,'_rr'],'./figures',2)
print_jd(p_opt,['fig_',id_simul,'_f1'],'./figures',3)
%