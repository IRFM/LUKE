function plot_fluct_jd(itn,xrho,pn,txJ,txP,tXXf0,simul,Te0)
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
    yprop = false(nt,ny);
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
    %
    it = 1;
    %
    fig.position = [0,0,1200,400];
    ax1.position = [30,100,320,270];
    ax2.position = [440,100,320,270];
    ax3.position = [850,100,320,270];
    slider.position = [150,10,1000,30];
    txt.position = [30,10,40,30];
    itxt.position = [80,10,40,30];
    %
    slider.callback = @slider_callback;
    itxt.callback = @txt_callback;
    %
    fig.handle = figure('name','fluctuations','visible','on','menubar','figure','numbertitle','off','resize','off','position',fig.position,'toolbar','none','units','pixels');
    %
    subplot(1,3,1);
    %
    xlim = [0,1];
    xlab = 'r/a';
    ylim = 1.1*[min([txJ(:);txP(:)]),max([txJ(:);txP(:)])];
    ylab = '';
    tit = '';
    %
    graph1D_jd(xrho,txJ(it,:),0,0,'','','',NaN,xlim,ylim,'-','+','r',2,20+14i);
    graph1D_jd(xrho,txP(it,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','o','b',2,20+14i);
    %
    subplot(1,3,2);
    %
    xlim = [-10,10];
    xlab = 'p/p_T';
    ylim = [1e-8,1];
    ylab = 'f(p) [p_{\perp} = 0]';
    tit = '';
    %
    graph1D_jd(ppar,tfpar(it,:),0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20+14i);
    %
    subplot(1,3,3);
    %
    xlim = [0,nt+1];
    xlab = 'time index';
    ylim = NaN;
    ylab = 'N_{||0}';
    tit = '';
    %
    colors = repmat({'r';'b';'k';[0,0.5,0]},[1,4]);
    markers = repmat({'+','o','s','d'},[4,1]);
    %
    yNpar(real(yNpar) == 0) = imag(yNpar(real(yNpar) == 0));
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
    axes = get(gcf,'children');
    %
    ax1.handle = axes(3);
    ax2.handle = axes(2);
    ax3.handle = axes(1);
    %
    set(ax1.handle,'units','pixels','position',ax1.position)
    set(ax2.handle,'units','pixels','position',ax2.position)
    set(ax3.handle,'units','pixels','position',ax3.position)
    %
    slider.handle = uicontrol(fig.handle,'Style','slider','Position',slider.position,'min',1,'max',nt,'sliderstep',[1/(nt-1),10/(nt-1)],'Value',it);
    txt.handle = uicontrol(fig.handle,'Style','text','Position',txt.position,'string',['# = '],'FontSize',20);
    itxt.handle = uicontrol(fig.handle,'callback',itxt.callback,'Style','edit','Position',itxt.position,'string',num2str(it),'FontSize',20);
    %
    set(slider.handle,'callback',{slider.callback,itxt.handle,ax1.handle,txJ,txP,ax2.handle,tfpar,ax3.handle});
    set(itxt.handle,'callback',{itxt.callback,slider.handle,ax1.handle,txJ,txP,ax2.handle,tfpar,ax3.handle});
    %
    %
    nx = 101;
    nbins = 10;
    %
    for iy = 1:ny,
        %
        figure(100+iy),clf
        %
        if ~isempty(tail(iy).Npar0_tail),
            %
            Npar0_tail = tail(iy).Npar0_tail;
            dNpar0_tail = tail(iy).dNpar0_tail;
            P0_2piRp_tail = tail(iy).P0_2piRp_tail;
            %
            n_tail = length(Npar0_tail);
            %
            Npar0_tail(real(Npar0_tail) == 0) = imag(Npar0_tail(real(Npar0_tail) == 0));
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
function slider_callback(handle,eventdata,itxt_handle,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle)
    %
    value = get(handle,'value');
    %
    %disp(['slider value : ',num2str(value)])
    %
    it = round(value);
    %
    set(itxt_handle,'string',num2str(it));
    %
    update_plot(it,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle);
    %
end
%
function txt_callback(handle,eventdata,slider_handle,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle)
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
    update_plot(it,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle);
    %
end
%
function update_plot(it,ax1_handle,txJ,txP,ax2_handle,tfpar,ax3_handle)
    %
    lines = get(ax1_handle,'children');
    set(lines(2),'ydata',txJ(it,:));
    set(lines(1),'ydata',txP(it,:));
    %
    set(get(ax2_handle,'children'),'ydata',tfpar(it,:));
    %
    lines = get(ax3_handle,'children');
    %
    set(lines(1),'xdata',[it,it]);
    %
end












