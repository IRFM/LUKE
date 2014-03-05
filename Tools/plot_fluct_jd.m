function plot_fluct_jd(itn,xrho,pn,txJ,txP,XXfM,tXXf0,simul,Te0,opt)
    %
if 0,    
    %
    nt = length(itn);
    npn = length(pn);
    %
    ppar = [fliplr(-pn(2:end)),pn(1:end)]; 
    tfpar = NaN(nt,2*npn - 1);
    %
    ir_P = find(sum(txP,1) == max(sum(txP,1)));
    %
    wavestr = [simul.path,'wave_results/waves_',simul.id];
    %
    data = load([wavestr,'_1.mat'],'waves');
    %
    iy = 0;
    for iw = 1:length(data.waves),
        iiy = 0;
        for ib = 1:length(data.waves{iw}.rayinit.launch.bNpar0),
            for ir = 1:length(data.waves{iw}.rayinit.launch.rZ0),
                %
                iy = iy + 1;
                iiy = iiy + 1;
                %
                yiw(iy) = iw;% wave index
                yNpar0(iy) = data.waves{iw}.rayinit.launch.bNpar0(ib);% prescribed n//
                ydNpar0(iy) = data.waves{iw}.rayinit.launch.bdNpar0(ib);% prescribed n//
                ytheta0(iy) = data.waves{iw}.rayinit.ytheta0(iiy);% initial theta
                %
                if data.waves{iw}.rayinit.launch.tail.mode == 3,
                    %
                    if data.waves{iw}.rayinit.launch.tail.bNparmax_tail == 0,
                        Nparmax_tail = 6.5/sqrt(Te0);
                    else
                         Nparmax_tail = data.waves{iw}.rayinit.launch.tail.Nparmax_tail;
                    end
                    %
                    [tail(iy).Npar0_tail,tail(iy).dNpar0_tail,tail(iy).P0_2piRp_tail] = calc_tail_jd(yNpar0(iy),ydNpar0(iy),1,...
                        Nparmax_tail,data.waves{iw}.rayinit.launch.tail.bn_tail,data.waves{iw}.rayinit.launch.tail.bP_tail,data.waves{iw}.rayinit.launch.tail.bopt_tail,0);
                    %
                end
                %
            end
        end
    end
    %
    ny = iy;
    %
    yNpar = NaN(nt,ny);
    ydNpar = NaN(nt,ny);
    yprop = false(nt,ny);
    %
    fparM = [flipud(XXfM(2:end,1,ir_P));XXfM(1:end,end,ir_P)].';
    %
    for it = 1:nt,
        %
        tfpar(it,:) = [flipud(tXXf0{it}(2:end,1,ir_P));tXXf0{it}(1:end,end,ir_P)].';
        %
        data = load([wavestr,'_',num2str(it),'.mat'],'waves');
        %
        iy = 0;
        for iw = 1:length(data.waves),
            for iiy = 1:length(data.waves{iw}.rayinit.yNpar0),
                %
                iy = iy + 1;
                %
                yNpar(it,iy) = data.waves{iw}.rayinit.yNpar0(iiy);% fluctuating n//
                ydNpar(it,iy) = data.waves{iw}.rayinit.ydNpar0(iiy);% fluctuating n//
                %
            end
            %
            for iray = 1:length(data.waves{iw}.rays),
                %
                iy = find(yiw == iw & yNpar(it,:) == data.waves{iw}.rays{iray}.rayinits{1}.yNpar0 & ytheta0 == data.waves{iw}.rays{iray}.rayinits{1}.ytheta0);
                %
                if isempty(iy) || length(iy) > 1,
                    disp('warning : pb in ray identification.')
                    keyboard
                else
                    yprop(it,iy) = true;
                end
                %
            end
        end
        %
        disp(['time index ',num2str(it),'/',num2str(nt),' processed.']) 
        %
    end
    %
    clear tXXf0 data
    %
else
    %
    load toto2.mat
    keyboard
    %
end
    %
    colors = repmat({'r';'b';'k';[0,0.5,0]},[1,4]);
    markers = repmat({'+','o','s','d'},[4,1]);
    %
    yNpar = abs(yNpar);
    %yNpar(real(yNpar) == 0) = imag(yNpar(real(yNpar) == 0));
    %
    it = 1;
    %
    nx = 101;
    nbins = 10;
    pmax = 15;
    dit = 10;%1;%
    %
    fac0 = 1/3;
    res = 600;
    %
    fig.position_slider = [0,0,1200,400];
    ax1.position_slider = [30,100,320,270];
    ax2.position_slider = [440,100,320,270];
    ax3.position_slider = [850,100,320,270];
    %
    fig.position_movie = [0,0,1200,360];
    ax1.position_movie = [30,60,320,270];
    ax2.position_movie = [440,60,320,270];
    ax3.position_movie = [850,60,320,270];
    %
    slider.position = [150,10,1000,30];
    txt.position = [30,10,40,30];
    itxt.position = [80,10,40,30];
    %
    slider.callback = @slider_callback;
    itxt.callback = @txt_callback;
    %
    if opt.mov == 0,
        fig.handle = figure('name','fluctuations','visible','on','menubar','figure','numbertitle','off','resize','off','position',fig.position_slider,'toolbar','none','units','pixels');
    else
        fig.handle = figure('name','fluctuations','visible','on','menubar','figure','numbertitle','off','resize','off','position',fig.position_movie,'toolbar','none','units','pixels');
    end        
    %
    subplot(1,3,1);
    %
    xlim = [0,1];
    xlab = 'r/a';
    ylim = 1.1*[min([txJ(:);txP(:)]),max([txJ(:);txP(:)])];
    ylab = '';
    tit = '';
    leg_JP = {'J (MA/m^2)','P (MW/m^3)'};
    %
    graph1D_jd(xrho,txJ(it,:),0,0,'','','',NaN,xlim,ylim,'-','+','r',2,20+14i);
    graph1D_jd(xrho,txP(it,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','o','b',2,20+14i);
    %
    subplot(1,3,2);
    %
    xlim = [-pmax,pmax];
    xlab = 'p/p_T';
    ylim = [1e-8,1];
    ylab = 'f(p) [p_{\perp} = 0]';
    tit = '';
    leg_f = {'f_M','f_{LH}'};
    %
    graph1D_jd(ppar,fparM,0,1,'','','',NaN,xlim,ylim,'-','none','b',0.5,20+14i);
    graph1D_jd(ppar,tfpar(it,:),0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20+14i);
    %
    subplot(1,3,3);
    %
    if ~isscalar(opt.iy) || ~any(opt.iy == 1:ny) || isempty(tail(opt.iy).Npar0_tail),
        opt.iy = 0;
    end
    %
    if opt.iy == 0,
        %
        xlim = [0,nt+1];
        xlab = 'time index';
        ylim = NaN;
        ylab = 'N_{||0}';
        tit = '';
        %
        yNpar_true = yNpar;
        yNpar_false = yNpar;
        %
        yNpar_true(~yprop) = NaN;
        yNpar_false(yprop) = NaN;
        %
        for iy = 1:ny,
            graph1D_jd(1:nt,yNpar_true(:,iy),0,0,'','','',NaN,xlim,ylim,'none',markers{iy},colors{iy},2,20+14i);
            graph1D_jd(1:nt,yNpar_false(:,iy),0,0,'','','',NaN,xlim,ylim,'none',markers{iy},colors{iy},0.5,20+14i);
        end
        %
        ylim = get(gca,'ylim');
        %
        graph1D_jd([it,it],ylim,0,0,xlab,ylab,tit,NaN,xlim,ylim,'--','none','k',2,20+14i);
        %
    else% opt.iy = iy, tail model
        %
        [xN,xdPdN,xlim] = tail_spec(tail(opt.iy),nx);
        xdPdN0 = spec0(yNpar(it,opt.iy),ydNpar(it,opt.iy),xN);
        %
        leg_Npar = {'Hist.','Fluct.','Tail'};
        %
%         xdPdN = xdPdN*it*diff(xlim)/nbins;
%         xdPdN0 = xdPdN0*it*diff(xlim)/nbins*fac0;
        %
        xdPdN = xdPdN*diff(xlim)/nbins;
        xdPdN0 = xdPdN0*diff(xlim)/nbins*fac0;
        %
        edges = [linspace(xlim(1),xlim(2),nbins+1)];%[-Inf,linspace(xlim(1),xlim(2),nbins+1),Inf];
        %
%         counts = histc(yNpar(1:it,opt.iy),edges);
        %
        counts = histc(yNpar(1:it,opt.iy),edges)/it;
        %
        bar(edges,counts,'histc');
        %
        xlab = 'N_{||}';
        ylim = NaN;
        ylab = 'dPdN_{||} (norm.)';
        tit = '';
        %
        graph1D_jd(xN,xdPdN0,0,0,'','','',NaN,xlim,ylim,'-','none',[0,0.5,0],2,20+14i); 
        graph1D_jd(xN,xdPdN,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20+14i); 
        %
    end
    %
    axes = get(gcf,'children');
    %
    ax1.handle = axes(3);
    ax2.handle = axes(2);
    ax3.handle = axes(1);
    %
    if opt.mov == 0,% slider
        %
        set(ax1.handle,'units','pixels','position',ax1.position_slider)
        set(ax2.handle,'units','pixels','position',ax2.position_slider)
        set(ax3.handle,'units','pixels','position',ax3.position_slider)
        %
        legend(ax1.handle,leg_JP)
        legend(ax2.handle,leg_f)
        %
        if opt.iy,
            legend(ax3.handle,leg_Npar)
            Npar = yNpar(:,opt.iy);
            dNpar = ydNpar(:,opt.iy);
        else
            Npar = NaN;
            dNpar = NaN;
        end
        %
        slider.handle = uicontrol(fig.handle,'Style','slider','Position',slider.position,'min',1,'max',nt,'sliderstep',[1/(nt-1),10/(nt-1)],'Value',it);
        txt.handle = uicontrol(fig.handle,'Style','text','Position',txt.position,'string',['# = '],'FontSize',20);
        itxt.handle = uicontrol(fig.handle,'callback',itxt.callback,'Style','edit','Position',itxt.position,'string',num2str(it),'FontSize',20);
        %
        set(slider.handle,'callback',{slider.callback,itxt.handle,ax1.handle,txJ,txP,ax2.handle,tfpar,ax3.handle,Npar,dNpar,fac0});
        set(itxt.handle,'callback',{itxt.callback,slider.handle,ax1.handle,txJ,txP,ax2.handle,tfpar,ax3.handle,Npar,dNpar,fac0});
        %
    else % movie
        %
        set(ax1.handle,'units','pixels','position',ax1.position_movie)
        set(ax2.handle,'units','pixels','position',ax2.position_movie)
        set(ax3.handle,'units','pixels','position',ax3.position_movie)
        %
        legend(ax1.handle,leg_JP)
        legend(ax2.handle,leg_f)
        %
        if opt.iy,
            legend(ax3.handle,leg_Npar)
            Npar = yNpar(:,opt.iy);
            dNpar = ydNpar(:,opt.iy);
        else
            Npar = NaN;
            dNpar = NaN;
        end
        %
        iit = 0;
        %
        for it = 1:dit:nt,
            %
            iit = iit + 1;
            %
            update_plot(it,ax1.handle,txJ,txP,ax2.handle,tfpar,ax3.handle,Npar,dNpar,fac0);
            %
            %figs(iit) = getframe(1);
            %
            savename = ['Fig_fluct_frame_',repmat('0',[1,4-ceil(log10(iit+1))]),num2str(iit)];
            eval(['print -dpng -r',num2str(res),' ',savename,'.png']);
            %
        end
        %
    end
    %
    if opt.spec,
        %
        for iy = 1:ny,
            %
            figure(100+iy),clf
            %
            if ~isempty(tail(iy).Npar0_tail),
                %
                [xN,xdPdN,xlim] = tail_spec(tail(iy),nx);
                %
                leg = {'Fluct.','Tail'};
                %
                xdPdN = xdPdN*nt*diff(xlim)/nbins;
                %
                edges = [linspace(xlim(1),xlim(2),nbins+1)];%[-Inf,linspace(xlim(1),xlim(2),nbins+1),Inf];
                counts = histc(yNpar(:,iy),edges);
                bar(edges,counts,'histc');
                %
                graph1D_jd(xN,xdPdN,0,0,'N_{||}','dPdN_{||} (norm.)','',leg,xlim,NaN,'-','none','r',2,20+14i,gca,0.9,0.7,0.7); 
                %
            end
            %
        end
        %
    end
    %
    if isfield(opt,'itcomp') && length(opt.itcomp) > 1,
        %
        figure(1001),clf
        %
        locxlim = [0,1];
        xlab = 'r/a';
        ylim = 1.1*[min(min([txJ(opt.itcomp,:);txP(opt.itcomp,:)])),max(max([txJ(opt.itcomp,:);txP(opt.itcomp,:)]))];
        ylab = '';
        tit = '';
        %
        nitcomp = length(opt.itcomp);
        locleg = cell(1,2*nitcomp);
        for locit = 1:nitcomp-1,
            locleg{1+2*(locit - 1)} = ['it. # ',num2str(opt.itcomp(locit)),': J (MA/m^2)'];
            locleg{2+2*(locit - 1)} = ['it. # ',num2str(opt.itcomp(locit)),': P (MW/m^3)'];
            graph1D_jd(xrho,txJ(opt.itcomp(locit),:),0,0,'','','',NaN,locxlim,ylim,'-','+',colors{locit},2,20+14i);
            graph1D_jd(xrho,txP(opt.itcomp(locit),:),0,0,'','','',NaN,locxlim,ylim,'-','o',colors{locit},2,20+14i);
        end
        locleg{1+2*(nitcomp - 1)} = ['it. # ',num2str(opt.itcomp(nitcomp)),': J (MA/m^2)'];
        locleg{2+2*(nitcomp - 1)} = ['it. # ',num2str(opt.itcomp(nitcomp)),': P (MW/m^3)'];
        graph1D_jd(xrho,txJ(opt.itcomp(nitcomp),:),0,0,'','','',NaN,locxlim,ylim,'-','+',colors{nitcomp},2,20+14i);
        graph1D_jd(xrho,txP(opt.itcomp(nitcomp),:),0,0,xlab,ylab,tit,locleg,locxlim,ylim,'-','o',colors{nitcomp},2,20+14i,gca,0.9,0.7,0.7);
        %
        %
        if opt.iy > 0,
            %
            xdPdN0comp = NaN(nitcomp,nx);
            for locit = 1:nitcomp,
                xdPdN0comp(locit,:) = spec0(yNpar(opt.itcomp(locit),opt.iy),ydNpar(opt.itcomp(locit),opt.iy),xN);
            end
            xdPdN0comp = xdPdN0comp*diff(xlim)/nbins*fac0;
            counts = histc(yNpar(:,opt.iy),edges)/nt;
            %
            figure(1002),clf
            %
            xlab = 'N_{||}';
            ylim = NaN;
            ylab = 'dPdN_{||} (norm.)';
            tit = '';
            %
            locleg = cell(1,nitcomp);
            for locit = 1:nitcomp-1,
                locleg{locit} = ['it. # ',num2str(opt.itcomp(locit))];
                graph1D_jd(xN,xdPdN0comp(locit,:),0,0,'','','',NaN,xlim,ylim,'-','none',colors{locit},2,20+14i); 
            end
            locleg{nitcomp} = ['it. # ',num2str(opt.itcomp(nitcomp))];
            graph1D_jd(xN,xdPdN0comp(nitcomp,:),0,0,xlab,ylab,tit,locleg,xlim,ylim,'-','none',colors{nitcomp},2,20+14i,gca,0.9,0.7,0.7); 
            %
            hold on
            bar(edges,counts,0.6,'histc');
            hold off
            %
            figure(1003),clf
            %
            xlab = 'N_{||}';
            ylim = NaN;
            ylab = 'counts';
            tit = '';
            %
            graph1D_jd(NaN,NaN,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20+14i,gca,0.9,0.7,0.7); 
            %
            hold on
            bar(edges,counts*nt,0.6,'histc');
            hold off
            %
        end
        %
    end
    %
end
%
function slider_callback(handle,eventdata,itxt_handle,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle,Npar,dNpar,fac0)
    %
    value = get(handle,'value');
    %
    %disp(['slider value : ',num2str(value)])
    %
    it = round(value);
    %
    set(itxt_handle,'string',num2str(it));
    %
    update_plot(it,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle,Npar,dNpar);
    %
end
%
function txt_callback(handle,eventdata,slider_handle,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle,Npar,dNpar,fac0)
    %
    txt = get(handle,'string');
    %
    %disp(['txt value : ',txt])
    %
    nt = get(slider_handle,'max');
    %
    it = round(str2double(txt));
    it(it < 1) = 1;
    it(it > nt) = nt;
    %
    set(handle,'string',num2str(it));
    set(slider_handle,'Value',it);
    %
    update_plot(it,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle,Npar,dNpar);
    %
end
%
function update_plot(it,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle,Npar,dNpar,fac0)
    %
    lines = get(ax1_handle,'children');
    set(lines(2),'ydata',txJ(it,:));
    set(lines(1),'ydata',txP(it,:));
    %
    lines = get(ax2_handle,'children');
    set(lines(1),'ydata',tfpar(it,:));
    %
    lines = get(ax3_handle,'children');
    %
    if length(get(lines(1),'xdata')) == 2,%opt.iy = 0,
        set(lines(1),'xdata',[it,it]);
    else
        %
        xlim = get(ax3_handle,'xlim');
        %
        nbins = size(get(lines(3),'xdata'),2) - 1;
%         itm = sum(sum(get(lines(3),'YData')))/2;
        %
        edges = [linspace(xlim(1),xlim(2),nbins+1)];%[-Inf,linspace(xlim(1),xlim(2),nbins+1),Inf];
        %
%         counts = histc(Npar(1:it),edges);
        %
        counts = histc(Npar(1:it),edges)/it;
        %
        delete(lines(3)),
        hold on
        bar(ax3_handle,edges,counts,'histc');
        hold off
        %
        xN = get(lines(2),'xdata');
        %
        xdPdN0 = spec0(Npar(it),dNpar(it),xN);
        %
%         xdPdN0 = xdPdN0*it*diff(xlim)/nbins*fac0;
        %
        xdPdN0 = xdPdN0*diff(xlim)/nbins*fac0;
        %
        set(lines(2),'ydata',xdPdN0);
%         set(lines(1),'ydata',get(lines(1),'ydata')*it/itm);
        %
        lines = get(ax3_handle,'children');
        set(ax3_handle,'children',lines([2,3,1]));
        %
    end
    %
end
%
function [xN,xdPdN,xlim] = tail_spec(tail,nx)
    %
    Npar0_tail = tail.Npar0_tail;
    dNpar0_tail = tail.dNpar0_tail;
    P0_2piRp_tail = tail.P0_2piRp_tail;
    %
    n_tail = length(Npar0_tail);
    %
    Npar0_tail = abs(Npar0_tail);
    %Npar0_tail(real(Npar0_tail) == 0) = imag(Npar0_tail(real(Npar0_tail) == 0));
    %
    xlim = [min(Npar0_tail) - 2*max(dNpar0_tail),max(Npar0_tail) + 2*max(dNpar0_tail)];
    %
    xN = linspace(xlim(1),xlim(2),nx);
    %
    xdPdN = zeros(1,nx);
    for in = 1:n_tail,
        xdPdN = xdPdN + P0_2piRp_tail(in)*exp(-(xN - Npar0_tail(in)).^2/dNpar0_tail(in).^2)/(sqrt(pi)*dNpar0_tail(in));
    end
    %
end
%
function xdPdN = spec0(Npar,dNpar,xN)
    %
    xdPdN = exp(-(xN - Npar).^2/dNpar.^2)/(sqrt(pi)*dNpar);
    %
end







