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
function fproc_runaway(RR,mksa,Ec,f,tn,tRR,tnorm,fgrid,tacc,pmhucrit,ZXXS,alpha,betath2,wpr,Zi,opt,grid,id_equil,rho_S,graph,p_opt,id_simul)
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
    filename = ['res_',id_simul,'.log'];
    %
    if exist(filename,'file')
        delete(filename);
    end
    %
    diary(filename);
end
%
nr = length(RR);
np = length(Ec);
%
disp('Simulation parameters : ')
disp(['coll_mode = ',num2str(opt.coll_mode),' ; bounce_mode = ',num2str(opt.bounce_mode),' ; equil = ',id_equil])
disp(['Te/mc2 = ',num2str(betath2),' ; E/Ec = ',num2str(alpha),' ; E/ED = ',num2str(alpha*betath2),' ; Zi = ',num2str(Zi)])
if opt.synchro_mode == 0,
    disp(['No synchrotron force'])
elseif imag(wpr) == 0,
    disp(['Synchrotron force on : wc2/wp2 = ',num2str(wpr)]);
elseif imag(wpr) > 0,
    disp(['Synchrotron force on : Bhat = ',num2str(imag(wpr))]);
else
    disp(['Synchrotron force on : 1/taur = ',num2str(-imag(wpr))]);
end    
disp(['NR limit : pc/pT = ',num2str(1/sqrt(alpha*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt(alpha*betath2))])%NR
disp(['Relativ. : pc/pT = ',num2str(1/sqrt((alpha - 1)*betath2)),' ; pmax/pc = ',num2str(pnmax_S*sqrt((alpha - 1)*betath2))])%rel
disp(' ')
if nr == 1,
    disp(['--> r/a = ',num2str(rho_S)])
    disp(['--> LUKE RR from bound calc. (normalized to ne and tauc) : ',num2str(RR)])
    disp(['--> LUKE RR from exact calc. (normalized to ne and tauc) : ',num2str(tRR.re(end) + tRR.ri(end))])
	disp(['--> LUKE ext. RE fraction : ',num2str(tnorm.re(end))])
	disp(['--> LUKE int. RE fraction : ',num2str(tnorm.ri(end))])
	disp(['--> LUKE tot. RE fraction : ',num2str(tnorm.re(end) + tnorm.ri(end))])
    %
    if opt.synchro_mode,
        fpar = f{end}(:,end).';
        ipparnan = find(fpar < 0,1);
        if ~isempty(ipparnan),
            fpar(ipparnan:end) = NaN;
        end
        ipparmin = find(diff(fpar) > 0,1);
        if ~isempty(ipparmin),
            disp(['--> minimum found in f(xi=1) : p/pT = ',num2str(fgrid.pn(ipparmin)),' ; Ec = ',num2str(Ec(ipparmin)),' MeV']);
            %
            ipparmax = find(diff(fpar) < 0 & 1:np-1 > ipparmin,1);
            %
            if ~isempty(ipparmax),
                disp(['--> maximum found in f(xi=1) : p/pT = ',num2str(fgrid.pn(ipparmax)),' ; Ec = ',num2str(Ec(ipparmax)),' MeV']);
            end
        end
    end
else
    rho = (rho_S(1:end-1) + rho_S(2:end))/2;%%%%% not exact, extract from equilDKE
    disp('--> r/a | bound. RR | exact RR')
    disp(num2str([rho.',RR.',tRR.re(:,end) + tRR.ri(:,end)]))
end
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
    if isfield(graph,'tnc') && graph.tnc, 
        tn = tn*betath2^(3/2);
        RRfac = betath2^(-3/2);
    else
        RRfac = 1;
    end
    %
    if opt.tnmin == 0,
        xlim = [0,tn(end)]; 
        xtick = NaN;
        mask = 1:ntn;
    else
        xlim = [tn(2),tn(end)];
        xtick = 10.^(floor(log10(tn(2))):2:ceil(log10(tn(end))));
        mask = 2:ntn;
    end
    %
    siz = 20+14i;
    tit = '';
    if ~isfield(opt,'color') || opt.color,
        colors = {'b','r',[0,0.75,0],[0.75,0,0.75],[0,0.75,0.75],[0.75,0.75,0],'k'};
        %colors = {'k','b','r','g','m','c','y'};
        styles = {'-','-','-','-','--','-','-'};
        sizes = [2,0.5,0.5,0.5,2];%,0.5
        colstr = '_col';
    else
        colors = {'k','k','k','k','k','k','k','k','k'};
        styles = {'-','--','-.','-','--','-.'};
        colstr = '';
        sizes = [2,0.5,0.5,0.5,2];%,0.5
    end
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
    graph1D_jd(tn(mask),tnorm.re(1,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,styles{3},'none',colors{3},sizes(3),siz,gca);
    graph1D_jd(tn(mask),tnorm.ri(1,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,styles{2},'none',colors{2},sizes(2),siz,gca);
%    graph1D_jd(tn(mask),tnorm.b(1,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
    graph1D_jd(tn(mask),tnorm.b(1,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,styles{4},'none',colors{4},sizes(4),siz,gca);
    graph1D_jd(tn(mask),tnorm.tot(1,mask),opt.tnmin > 0,1,xlab,ylab,tit,leg,xlim,ylim,styles{5},'none',colors{1},sizes(1),siz,gca,0.9,0.7,0.7);
    %
    if nr > 1,
        graph1D_jd(tn(mask),tnorm.re(end,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','r',0.5,siz,gca);
        graph1D_jd(tn(mask),tnorm.ri(end,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','b',0.5,siz,gca);
%        graph1D_jd(tn(mask),tnorm.b(end,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none',[0,0.5,0],0.5,siz,gca);
        graph1D_jd(tn(mask),tnorm.b(end,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','g',0.5,siz,gca);
        graph1D_jd(tn(mask),tnorm.tot(end,mask),opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','k',0.5,siz,gca);
    end
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
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','on')
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
%         graph1D_jd(xlim,[RR_k,RR_k],opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
        graph1D_jd(xlim,[RR_k,RR_k]*RRfac,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'-','none','g',2,siz,gca);
    end
    graph1D_jd(tn(2:ntn),tRR.re(1,:)*RRfac,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,styles{3},'none',colors{3},sizes(3),siz,gca);
    graph1D_jd(tn(2:ntn),tRR.ri(1,:)*RRfac,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,styles{4},'none',colors{4},sizes(4),siz,gca);
    graph1D_jd(tn(2:ntn),tRR.re(1,:)*RRfac + tRR.ri(1,:)*RRfac,opt.tnmin > 0,1,xlab,ylab,tit,leg,xlim,ylim,styles{5},'none',colors{1},sizes(1),siz,gca,0.9,0.7,0.7);
    %
    if nr > 1,
        graph1D_jd(tn(2:ntn),tRR.re(end,:)*RRfac,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','r',0.5,siz,gca);
        graph1D_jd(tn(2:ntn),tRR.ri(end,:)*RRfac,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','b',0.5,siz,gca);
        graph1D_jd(tn(2:ntn),tRR.re(end,:)*RRfac + tRR.ri(end,:)*RRfac,opt.tnmin > 0,1,'','','',NaN,xlim,ylim,'--','none','k',0.5,siz,gca);
    end
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
    set(gca,'XMinorGrid','off')
    set(gca,'XMinorTick','on')
    %
    figure(3),clf
    %
    if ~isfield(graph,'xlog'),
        graph.xlog = 0;
    end
    %
    fM = reshape(f{1}(:,end,:),[np,nr]);
    %
    if ~isfield(graph,'xec') || graph.xec,
        xlab = '$\mathcal{E}_k$ (MeV)';
        ylab = '$f(\mathcal{E}_k,\xi = 1)$';
        %
        x = Ec;
    else
        xlab = '$p/(mc)$';
        ylab = '$f(p,\xi = 1)$';
        %
        x = fgrid.pn*sqrt(betath2);
    end
    %
    if ~isfield(graph,'xlim'),
        if graph.xlog,
            graph.xlim = [min(x),max(x)];                
        else
            graph.xlim = [0,max(x)];                
        end
    end
    %
    if isfield(graph,'ylim_f'),
        ylim = graph.ylim_f;
    else
        ylim = [eps,max(fM(:))];
        graph.ytick_f = 10.^(-18:2:2);
    end    
    %
    ntdisp = length(graph.itdisp);
    leg = cell(1,ntdisp+1);
    leg{1} = ['t/\tau_c = 0'];
    graph1D_jd(x,fM(:,1),graph.xlog,1,'','','',NaN,graph.xlim,ylim,styles{1},'none',colors{1},sizes(1),siz,gca);
    for iit = 1:ntdisp-1,
        leg{1+iit} = ['t/\tau_c = ',num2str(tn(1+graph.itdisp(iit)))];
        graph1D_jd(x,f{1+graph.itdisp(iit)}(:,end,1),graph.xlog,1,'','','',NaN,graph.xlim,ylim,styles{1+iit},'none',colors{1+iit},sizes(1+iit),siz);
    end
    leg{1+ntdisp} = ['t/\tau_c = ',num2str(tn(1+graph.itdisp(ntdisp)))];
    graph1D_jd(x,f{1+graph.itdisp(ntdisp)}(:,end,1),graph.xlog,1,xlab,ylab,tit,leg,graph.xlim,ylim,styles{1+ntdisp},'none',colors{1+ntdisp},sizes(1+ntdisp),siz,gca,0.9,0.7,0.7);
    %
    if nr > 1,
        graph1D_jd(x,fM(:,end),graph.xlog,1,'','','',NaN,graph.xlim,ylim,'--','none',colors{1},0.5,siz,gca);
        for iit = 1:ntdisp,
            graph1D_jd(x,f{1+graph.itdisp(iit)}(:,end,end),graph.xlog,1,'','','',NaN,graph.xlim,ylim,'--','none',colors{1+iit},0.5,siz);
        end
    end
    %
    if isfield(graph,'xtick'),
        set(gca,'xtick',graph.xtick)
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
    print_jd(p_opt,['fig_',id_simul,'_nr',colstr],'./figures',1)
    print_jd(p_opt,['fig_',id_simul,'_rr',colstr],'./figures',2)
    print_jd(p_opt,['fig_',id_simul,'_f1',colstr],'./figures',3)
    %
    if nr > 1,
        %
        figure(4),clf
        %
        xlim = [0,1];
        xlab = 'r/a';
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
        graph1D_jd(rho,tnorm.re(:,end),0,1,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
        graph1D_jd(rho,tnorm.ri(:,end),0,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
        graph1D_jd(rho,tnorm.b(:,end),0,1,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,siz,gca);
        graph1D_jd(rho,tnorm.tot(:,end),0,1,xlab,ylab,tit,leg,xlim,ylim,'-','none','k',2,siz,gca,0.9,0.7,0.7);
        %
        set(gca,'xtick',0:0.2:1)
        %
        if isfield(graph,'ytick_norm'),
            set(gca,'ytick',graph.ytick_norm)
        end
        set(gca,'YMinorGrid','off')
        set(gca,'YMinorTick','on')
        %
        figure(5),clf
        %
        ylim = NaN;
        %
        leg = cell(1,ntdisp);
        for iit = 1:ntdisp-1,
            leg{iit} = ['t/\tau_c = ',num2str(tn(1+graph.itdisp(iit)))];
            graph1D_jd(rho,tnorm.re(:,1+graph.itdisp(iit)) + tnorm.ri(:,1+graph.itdisp(iit)),0,0,'','','',NaN,xlim,ylim,'-','none',colors{iit},2,siz);
        end
        leg{ntdisp} = ['t/\tau_c = ',num2str(tn(1+graph.itdisp(ntdisp)))];
        graph1D_jd(rho,tnorm.re(:,1+graph.itdisp(ntdisp)) + tnorm.ri(:,1+graph.itdisp(ntdisp)),0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',colors{ntdisp},2,siz,gca,0.9,0.7,0.7);
        %
        set(gca,'xtick',0:0.2:1)
%         set(gca,'ytick',0:0.2:1)
        %
    elseif isfield(graph,'dp_cyl') && graph.dp_cyl > 0,
        %
        if ~isfield(graph,'pnmax_disp'),
            graph.pnmax_disp = pnmax_S;
        end
        %
        f02D = f{end};
        fM2D = f{1};
        %
        calc_fcyl_jd(f02D,sqrt(betath2),fgrid.pn,fgrid.mhu,graph.dp_cyl,1,1,graph.pnmax_disp,tacc{end},pmhucrit,[6,0,0]);       
        set(gca,'xlim',graph.xlim_disp);
        set(gca,'xtick',graph.xtick_disp);
        set(gca,'ylim',graph.ylim_disp);
        set(gca,'ytick',graph.ytick_disp);
        %
        figpos = get(gcf,'position');
%         newfigpos = [figpos(1),figpos(2),figpos(3),figpos(3)*diff(graph.ylim_disp)/diff(graph.xlim_disp)];
        newfigpos = [figpos(1),figpos(2),figpos(3),figpos(3)*1/2];
        set(gcf,'position',newfigpos)
        %
        % stream function
        %
        dke_out.ZXXS = ZXXS;
        dke_out.xRR_fsav = RR;
        dke_out.betath_ref = sqrt(betath2);
        %
        gridDKE.xmhubounce2 = 0;
        %
        stream_dke_jd(dke_out,opt,fgrid,gridDKE,1,graph.dp_cyl,graph,tacc{end},pmhucrit,7);
        %
%         ch = get(gca,'children');% case where both are on same fig.
%         set(gca,'children',ch([3,4,2,1]));
        set(gca,'xlim',graph.xlim_disp);
        set(gca,'xtick',graph.xtick_disp);
        set(gca,'ylim',graph.ylim_disp);
        set(gca,'ytick',graph.ytick_disp);
        set(gcf,'position',newfigpos)
        %
        print_jd(p_opt,['fig_',id_simul,'_f2',colstr],'./figures',6)
        print_jd(p_opt,['fig_',id_simul,'_stream',colstr],'./figures',7)
        %
    end
    %
end
%