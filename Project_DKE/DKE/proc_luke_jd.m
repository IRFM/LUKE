function proc_luke_jd(data,ir_display,p_opt,dp_cyl)
%
% This function plots the results from LUKE data structure
%
% To use this function from saved rundke files:
%		data = load(filename);
%		proc_luke_jd(data,ir_display,p_opt,dp_cyl);
%
% by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (CEA-DRFC) <joan.decker@cea.fr>
%
if nargin < 4,
    dp_cyl = 0.1;
end
if nargin < 3,
    p_opt = -1;
end
if nargin < 2,
    ir_display = 0;
end
%
Znorm = data.Znorm;
Zcurr = data.Zcurr;
ZP0 = data.ZP0;
dke_out = data.dke_out;
radialDKE = data.radialDKE;
equilDKE = data.equilDKE;
momentumDKE = data.momentumDKE;
gridDKE = data.gridDKE;
Zmomcoef = data.Zmomcoef;
Zbouncecoef = data.Zbouncecoef;
Zmripple = data.Zmripple;
mksa = data.mksa;
%
style0 = 'none';
style = '-';
style2 = '--';
marker = 'none';
marker1 = '+';
marker2 = 'o';
marker3 = 's';
marker4 = '.';
color1 = 'k';
color2 = 'r';
color3 = 'b';
color4 = 'g';
color5 = 'm';
color6 = 'c';
%
width = 0.5;
width2 = 2;
siz = 20;
%
red = 0.9;
lspace = 0.7;
lspace2 = 0.5;
bspace = 0.7;
bspace2 = 0.5;
%
xrho = equilDKE.xrho; 
pn = momentumDKE.pn;
mhu = momentumDKE.mhu;
%
nr = length(xrho);
%
J_rf = Zcurr.x_0_fsav*mksa.j_ref;
P_rf = ZP0.x_rf_fsav.'*mksa.P_ref; 
%
I_rf = sum(J_rf.*equilDKE.xdA_dke);
%
tir_display = num2str(ir_display);
diaryname = ['res_',tir_display,'.txt'];
delete(diaryname)
diary(diaryname)
%
if I_rf < 0,
    disp('Warning : sign of J inverted for positive total current')
    J_rf = -J_rf;
    I_rf = -I_rf;
end
%
p_rf_2piRp = sum(P_rf.*equilDKE.xdV_2piRp_dke);
EtaRp_rf = I_rf/p_rf_2piRp/(2*pi);    
%
eta = J_rf./P_rf;
i_peak = find(P_rf == max(P_rf));
eta_peak = eta(i_peak);
%
if nr > 1,
    %
    disp(['current (I): ',num2str(I_rf),' MA'])
    disp(['RF power (P/2piRp): ',num2str(p_rf_2piRp),' MW/m'])
    disp(['CD efficiency (I*Rp/P): ',num2str(EtaRp_rf),' A.m/W'])
    %
    % power profile
    %
    figure(1),clf
    %
    xlab = 'r/a';
    ylab = 'P_{RF} (MW/m^3)';
    tit = '';
    %
    xlim = [0,1];
    xtick = 0:0.2:1;
    ylim = NaN;
    %
    graph1D_jd(xrho,P_rf,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %
    print_jd(p_opt,'Prf_profile','.');
    %
    % current profile
    %
    figure(2),clf
    %
    ylab = 'J (MA/m^2)';
    tit = '';
    ylim = 1.2*[min(J_rf),max(J_rf)];
    %
    graph1D_jd(xrho,J_rf,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %set(gca,'ylim',[0,max(get(gca,'ylim'))])
    %
    print_jd(p_opt,'J_profile','.');
    %
    % efficiency profile
    %
    figure(3),clf
    %
    ylab = '\eta (A.m/W)';
    tit = '';
    ylim = [0,2*eta_peak];
    %
    graph1D_jd(xrho,eta,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace);
    set(gca,'xtick',xtick);
    %
    print_jd(p_opt,'eta_profile','.');
    %
else
    %
    disp(['normalized current: ',num2str(Zcurr.x_0_fsav)])
    disp(['normalized RF power: ',num2str(ZP0.x_rf_fsav)])
    disp(['normalized CD efficiency: ',num2str(Zcurr.x_0_fsav./ZP0.x_rf_fsav)])
    %
end
%
if ir_display > 0 & ir_display <= nr,
    %
    disp(['normalized radius for distribution plots: ',num2str(xrho(ir_display))])
    %
    [logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(dke_out.XXf0(:,:,ir_display)),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
    %
    logXfinit_cyl_ref = s2c_dke_yp(log(dke_out.XXfinit(:,:,ir_display)),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
    %
    XDparpar_cyl_ref = s2c_dke_yp(dke_out.ZXXD_rf.parpar_ij(:,:,ir_display),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
    %
    Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
    Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
    Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
    %
    Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
    Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
    Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
    %
    Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
    Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<=max(ppar_cyl_ref));%Remove values above max(ppar)
    Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values
    %
    % Remove values less than computer accuracy
    %
    Xmask = abs(Xf0_cyl_ref) < eps;
    %
    pnmax_S = max(momentumDKE.pn_S);
    pnmax_0 = min(min(Xp_cyl_ref(Xmask)));
    %
    pnmax = min([pnmax_0,pnmax_S]);
    %
    Xmask = Xp_cyl_ref >= pnmax;    
    %
    Xf0_cyl_ref(Xmask) = 0;
    Xfinit_cyl_ref(Xmask) = 0;
    XDparpar_cyl_ref(Xmask) = 0;
    %
    Fpar0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
    Fparinit_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xfinit_cyl_ref,1);		
    %
    % Figures
    %
    figure(4),clf
    %
    x1 = ppar_cyl_ref;
    xlab1 = 'p_{||}/p_{Te}';
    xlim1 = [-pnmax,pnmax];
    %
    x2 = pperp_cyl_ref;
    xlab2 = 'p_{\perp}/p_{Te}';
    xlim2 = [0,pnmax];
    %
    leg = {'f_M','f'};
    %
    y1 = Xfinit_cyl_ref;
    y2 = Xf0_cyl_ref;
    y3 = XDparpar_cyl_ref;
    y3max = max(max(y3));
    %
    y9 = sqrt(pnmax^2 - x1.^2);
    %
    graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color3,width,siz,1,max(max(y1)));
    graph2D_jd(x1,x2,y2','','','',xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pnmax],0,style,color2,width2,siz,1,max(max(y1)));
    %
    if y3max > 1e-5,
        graph2D_jd(x1,x2,y3','','','',xlim1,xlim2,0,NaN,y3max/100,0,style,color4,width2,siz);
    end
    %
    graph1D_jd(x1,y9,0,0,xlab1,xlab2,'',NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace);
    %
    axis('equal');axis([xlim1,xlim2]);
    legend(leg);
    %
    if equilDKE.Rp ~= Inf,
        bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,[]);
    end
    %
    print_jd(p_opt,['f_2D',tir_display],'.');
    %
    figure(5),clf
    %
    cont = 10;
    %
    graph2D_jd(x1,x2,y3','','','',xlim1,xlim2,1,NaN,cont,0,style,NaN,width,siz,1);
    graph1D_jd(x1,y9,0,0,xlab1,xlab2,'',NaN,xlim1,xlim2,style,marker,color1,width2,siz,gca,red,lspace,bspace);
    axis('equal');axis([xlim1,xlim2])
    %
    if equilDKE.Rp ~= Inf,
        bounce_ripple_jd(1,pnmax,gridDKE.xmhubounce2,ir_display,[]);
    end
    colorbar
    %
    print_jd(p_opt,['DQL',tir_display],'.');
    %
    % ---------- parallel distribution difference-----------
    %
    figure(6),clf
    %
    y1 = Fpar0_cyl_ref - Fparinit_cyl_ref;
    ylab = 'F_{||} - F_{||M}';
    ylim = NaN;
    %
    graph1D_jd(x1,y1,0,0,xlab1,ylab,'',NaN,xlim1,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace);
    %
    print_jd(p_opt,['F0mFM_1D',tir_display],'.');
    %
    % ---------- parallel distribution -----------
    %
    figure(7),clf
    %
    y1 = Fparinit_cyl_ref;
    y2 = Fpar0_cyl_ref;
    ylab = 'F_{||}';
    ylim = [eps,1];
    %
    graph1D_jd(x1,y1,0,1,'','','',NaN,xlim1,ylim,style,marker,color3,width,siz,gca,red,lspace,bspace);
    graph1D_jd(x1,y2,0,1,xlab1,ylab,'',leg,xlim1,ylim,style,marker,color2,width2,siz);
    legend(leg);
    %
    print_jd(p_opt,['F0pFM_1D_',tir_display],'.');
end
%
diary off
%


