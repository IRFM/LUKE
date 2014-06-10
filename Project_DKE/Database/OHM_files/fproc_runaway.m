function fproc_runaway(RR,mksa,Ec,f,tn,tRR,tnorm,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,p_opt,id_simul)
%
epsi_kulsrud = [0.04;0.06;0.08;0.10];
Zi_kulsrud =[1,2,3,10];
RR_kulsrud = 1e-4*[ 0.01914,NaN   ,NaN  ,NaN   ;...%Kulsrud (PRL, 31,11, (1972) 690)
                    0.5411 ,0.2611,NaN  ,NaN   ;...  
                    3.177  ,1.735 ,1.047,0.09  ;...
                    10.04  ,5.839 ,3.757,0.449];
%
iepsi = find(abs((alpha*betath2 - epsi_kulsrud)./epsi_kulsrud) < 10*eps);
%
if opt.coll_mode == 0 && opt.bounce_mode == 0 && abs((betath2 - 1e-6)/1e-6) < 10*eps && ~isempty(iepsi) && any(Zi == Zi_kulsrud),
    RR_k = RR_kulsrud(iepsi,Zi == Zi_kulsrud);
else
    RR_k = '';
end
%
% additional info
%
% Dreicer field ED = Ec/betath2
% Critical momentum at mhu=1 : 
% - NR limit     : pc = 1/sqrt(betath2*alpha)
% - Relativistic : pc = 1/sqrt(betath2*alpha - betath2))
%
%************************************************************************************************************************************
%
if grid.np_tail == 0,
    pnmax_S = grid.pnmax_S;
elseif imag(grid.pnmax_S_tail) == 0,
    pnmax_S = grid.pnmax_S_tail;
else
    pnmax_S = grid.pnmax_S*imag(grid.pnmax_S_tail);
end
%
format
%
if p_opt > 0,
    delete res_runaway
    %
    diary res_runaway
end
%
disp('Simulation parameters : ')
disp(['coll_mode = ',num2str(opt.coll_mode),' ; bounce_mode = ',num2str(opt.bounce_mode),' ; equil = ',id_equil,' ; r/a = ',num2str(rho_S)])
disp(['Te/mc2 = ',num2str(betath2),' ; E/Ec = ',num2str(alpha),' ; E/ED = ',num2str(alpha*betath2),' ; Zi = ',num2str(Zi)])
disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt(alpha*betath2))])%NR
disp(['Relativ. : pc/pT = ',num2str(1/sqrt((alpha - 1)*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt((alpha - 1)*betath2))])%rel
disp(' ')
disp(['--> LUKE RR (normalized to ne and tauc) : ',num2str(RR)])
if ~isempty(RR_k),
    disp(['--> Kulsrud RR : ',num2str(RR_k)])
end
disp('----------------------')
%
if p_opt > 0,
    diary off
end
%
if opt.timevol == 0,% steady-state solution
    %
    figure(1),clf
    %
    fM = f{1}(:,end);
    f = f{2}(:,end);
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
    leg = {'f_M','f'};
    graph1D_jd(Ec,fM,0,1,'','','',NaN,xlim,ylim,'-','none','b',0.5,siz);
    graph1D_jd(Ec,f,0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
    %
    if isfield(graph,'ytick_f'),
        set(gca,'ytick',graph.ytick_f)
    end
    set(gca,'YMinorGrid','off')
    set(gca,'YMinorTick','on')
    %
    print_jd(p_opt,['fig_',id_simul,'_f1'],'./figures',1)
    %
else% time dependent solution
    %
    ntn = length(tn);
    %
    if opt.tnmin == 0,
        xlim = [0,tn(end)];   
        mask = 1:ntn;
    else
        xlim = [tn(2),tn(end)];
        mask = 2:ntn;
    end
    %
    siz = 20+14i;
    tit = '';
    colors = {'b','r',[0,0.5,0],[0.5,0,0.5],[0,0.5,0.5],[0.5,0.5,0],'k'};
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
    graph1D_jd(tn(mask),tnorm.re(mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(tn(mask),tnorm.ri(mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd(tn(mask),tnorm.b(mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
    graph1D_jd(tn(mask),tnorm.tot(mask),opt.tnmin > 0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
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
    if ~isnan(RR_k),
        leg = ['Kulsrud',leg];
    end
    %
    if ~isempty(RR_k),
        graph1D_jd(xlim,[RR_k,RR_k],opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
    end
    graph1D_jd(tn(2:ntn),tRR.re,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(tn(2:ntn),tRR.ri,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd(tn(2:ntn),tRR.re + tRR.ri,opt.tnmin > 0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
    %
    if isfield(graph,'ytick_gamma'),
        set(gca,'ytick',graph.ytick_gamma)
    end
    set(gca,'YMinorGrid','off')
    set(gca,'YMinorTick','on')
    %
    figure(3),clf
    %
    fM = f{1}(:,end);
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
    %
    ntdisp = length(graph.itdisp);
    leg = cell(1,ntdisp+1);
    leg{1} = ['t/\tau_c = 0'];
    graph1D_jd(Ec,fM,0,1,'','','',NaN,xlim,ylim,'-','none',colors{1},0.5,siz,gca);
    for iit = 1:ntdisp-1,
        leg{1+iit} = ['t/\tau_c = ',num2str(tn(1+graph.itdisp(iit)))];
        graph1D_jd(Ec,f{1+graph.itdisp(iit)}(:,end),0,1,'','','',NaN,xlim,ylim,'-','none',colors{1+iit},2,siz);
    end
    leg{1+ntdisp} = ['t/\tau_c = ',num2str(tn(1+graph.itdisp(ntdisp)))];
    graph1D_jd(Ec,f{1+graph.itdisp(ntdisp)}(:,end),0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{1+ntdisp},2,siz,gca,0.9,0.7,0.7);
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
end
%