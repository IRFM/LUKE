function [XAstr_S,XAstr_cyl_S,ppar_cyl_S,pperp_cyl_S] = stream_dke_jd(dke_out,dkeparam,momentumDKE,gridDKE,ir_display_dke,dp_cyl,graph,XXmask,pmhu_crit,ifig)
%
%Stream function calculation for graphical flux analysis
%
%by Joan Decker (joan.decker@cea.fr, CEA/DSM/IRFM) and Yves Peysson (yves.peysson@cea.fr, CEA/DSM/IRFM)
%
if nargin < 9,
    ifig = 0;
end
%
if nargin < 8,
    XXmask = [];
end
%
if nargin < 7,
    graph = struct;
end
%
if nargin < 6,
    dp_cyl = [];
end
%
if nargin < 5,
    ir_display_dke = 1;
end
%
if nargin < 4,
	info_dke_yp(2,'Wrong number of input arguments for stream_dke_jd');
	return;
end
%
if ~isfield(graph,'pnmax_disp') || isnan(graph.pnmax_disp),
    graph.pnmax_disp = momentumDKE.pn_S(end);
end
%
ZXXS = dke_out.ZXXS;
xRR_fsav = 0;%dke_out.xRR_fsav(ir_display_dke);
betath_ref = dke_out.betath_ref;
%
pn_S = momentumDKE.pn_S.';
npn_S = find(pn_S <= graph.pnmax_disp,1,'last');
pn_S = pn_S(1:npn_S);
%
mhu_S = momentumDKE.mhu_S;
nmhu_S = length(mhu_S);
%
dmhu = momentumDKE.dmhu;
nmhu = length(dmhu);
xmhubounce2 = gridDKE.xmhubounce2(ir_display_dke);
%
XSp0_tot_ipj = ZXXS.p0_c_ipj(1:npn_S-1,:,ir_display_dke) + ZXXS.p0_e_ipj(1:npn_S-1,:,ir_display_dke) + ...
    ZXXS.p0_s_ipj(1:npn_S-1,:,ir_display_dke) + ZXXS.p0_rf_ipj(1:npn_S-1,:,ir_display_dke);
%
if ~isempty(XXmask),
    pn = momentumDKE.pn.';
    pnmask = pn <= graph.pnmax_disp;
    pn = pn(pnmask);
    XXmask = XXmask(pnmask,:,:);
    mhu = momentumDKE.mhu;
    np = length(pn);
end
%
XAstr_S_Pp = zeros(npn_S,nmhu_S);%circulating particles (pn>=0)
XAstr_S_Pm = zeros(npn_S,nmhu_S);%circulating particles (pn<0)
XAstr_S_T = zeros(npn_S,nmhu_S);%trapped particles
%
if dkeparam.bounce_mode,
    %
    nT = sum(abs(mhu_S) <= sqrt(xmhubounce2));%Trapped particles
    nP = (nmhu_S - nT)/2;%Circulating particles 
    %
    for j=1:nP,%ksi < 0
    	XAstr_S_Pm(2:npn_S,j) = xRR_fsav - 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
    end
    %
    for j=1:nP,%ksi > 0
    	XAstr_S_Pp(2:npn_S,nmhu_S-j+1) = xRR_fsav + 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(nmhu_S-j:nmhu_S-1),XSp0_tot_ipj(:,nmhu_S-j:nmhu_S-1),2);%Stream function with runaway
    end
    %
    for j=1:(nT-1)/2,%|ksi| <= ksi_T
    	XAstr_S_T(2:npn_S,(nmhu_S-1)/2+j+1) = xRR_fsav - 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu((nmhu_S-1)/2+1:(nmhu_S-1)/2+j),XSp0_tot_ipj(:,(nmhu_S-1)/2+1:(nmhu_S-1)/2+j),2);%Stream function with runaway
    	XAstr_S_T(2:npn_S,(nmhu_S-1)/2-j+1) = xRR_fsav + 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu((nmhu_S-1)/2+1-j:(nmhu_S-1)/2),XSp0_tot_ipj(:,(nmhu_S-1)/2+1-j:(nmhu_S-1)/2),2);%Stream function with runaway
    end
    %
    XAstr_S_T(2:npn_S,(nmhu_S+1)/2) = xRR_fsav;
    %
    XAstr_S_T = (XAstr_S_T + fliplr(XAstr_S_T))/2;
    XAstr_S = XAstr_S_Pm + XAstr_S_T + XAstr_S_Pp;
else
    %
    pRR_ip_fsav = integral_dke_jd(dmhu,XSp0_tot_ipj,2)/2;
    %
    XSp0_tot_ipj = XSp0_tot_ipj - repmat(pRR_ip_fsav,[1,nmhu]);
    %
    for j=1:nmhu_S-1,
    	XAstr_S_Pm(2:npn_S,j+1) = xRR_fsav - 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
    end
    %
    for j=1:nmhu_S-1,
    	XAstr_S_Pp(2:npn_S,nmhu_S-j) = xRR_fsav + 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(nmhu_S-j:nmhu_S-1),XSp0_tot_ipj(:,nmhu_S-j:nmhu_S-1),2);%Stream function with runaway
    end
    %
    XAstr_S = (XAstr_S_Pm + XAstr_S_Pp)/2;
end
%
if isempty(dp_cyl),
    dp_cyl = min(pn_S(2:end) - pn_S(1:end-1))/2;%cylindrical momentum grid step
end
%
[XAstr_cyl_S,ppar_cyl_S,~,pperp_cyl_S] = s2c_dke_yp(XAstr_S,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
% [XAstr_cyl_S_Pm] = s2c_dke_yp(XAstr_S_Pm,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
% [XAstr_cyl_S_Pp] = s2c_dke_yp(XAstr_S_Pp,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
% [logXAstr_cyl_S,ppar_cyl_S,dppar_cyl_S,pperp_cyl_S,dpperp_S_cyl] = s2c_dke_yp(log(XAstr_S),pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation
% XAstr_cyl_S = exp(logXAstr_cyl_S);%For accurate representation in figures 
%
if ~isempty(XXmask),
    [Xmask_cyl,ppar_cyl,~,pperp_cyl] = s2c_dke_yp(double(XXmask(:,:,ir_display_dke)),pn,mhu,dp_cyl);%Spherical to cylindrical coordinate transformation
else
    Xmask_cyl = NaN;
end
%
if isempty(pmhu_crit) || all(isnan(pmhu_crit)),
    pmhu_crit = zeros(1,np);
    for ipn = 1:np,
        pmhu_crit(ipn) = min([1,mhu(XXmask(ipn,:,ir_display_dke))]);
    end
else
    pmhu_crit = pmhu_crit(pnmask);
end
%
Xppar_cyl_S = ones(length(pperp_cyl_S),1)*ppar_cyl_S(:)';%Grid for the stream or flux functions only
Xpperp_cyl_S = pperp_cyl_S(:)*ones(1,length(ppar_cyl_S));
Xp_cyl_S = sqrt(Xppar_cyl_S.*Xppar_cyl_S + Xpperp_cyl_S.*Xpperp_cyl_S);
%
pnmax_S = max(ppar_cyl_S);
%
XAstr_cyl_S(Xp_cyl_S > pnmax_S) = 0;%Remove values above max(ppar)
XAstr_cyl_S(isnan(XAstr_cyl_S)) = 0;%Remove NaN values
XAstr_cyl_S(1,:) = 0;
%
% XAstr_cyl_S_Pm(Xp_cyl_S > pnmax_S) = 0;%Remove values above max(ppar)
% XAstr_cyl_S_Pm(isnan(XAstr_cyl_S_Pm)) = 0;%Remove NaN values
% XAstr_cyl_S_Pm(1,:) = 0;
% %
% XAstr_cyl_S_Pp(Xp_cyl_S > pnmax_S) = 0;%Remove values above max(ppar)
% XAstr_cyl_S_Pp(isnan(XAstr_cyl_S_Pp)) = 0;%Remove NaN values
% XAstr_cyl_S_Pp(1,:) = 0;
%
if ifig > 0,
    %
%     x1 = ppar_cyl_S;
%     xlab1 = 'p_{||}/p_{Te}';
%     xlim1 = [-pnmax_S,pnmax_S];
    x1 = ppar_cyl_S*betath_ref;
    xlab1 = 'p_{||}';%/(mc)
    xlim1 = [-pnmax_S,pnmax_S]*betath_ref;
    %
%     x2 = pperp_cyl_S;
%     xlab2 = 'p_{\perp}/p_{Te}';
%     xlim2 = [0,pnmax_S];
    x2 = pperp_cyl_S*betath_ref;
    xlab2 = 'p_{\perp}';%/(mc)
    xlim2 = [0,pnmax_S]*betath_ref;
    %
%     y2 = sqrt(pnmax_S^2 - ppar_cyl_S.^2);
    y2 = sqrt(pnmax_S^2 - ppar_cyl_S.^2)*betath_ref;
    y3 = Xmask_cyl;
    %
    x4 = pn.'*betath_ref.*pmhu_crit;
    y4 = pn.'*betath_ref.*sqrt(1 - pmhu_crit.^2);
    %
%     y1 = log10(XAstr_cyl_S);
%     cont = linspace(min(min(y1(~isinf(y1)))),max(max(y1(~isinf(y1)))),30);
    %
    y1 = XAstr_cyl_S;
    if ~isfield(graph,'cont'),
        graph.cont = linspace(min(min(y1(~isinf(y1)))),max(max(y1(~isinf(y1)))),30);
    end
    %
    figure(ifig),hold on%,clf%
%     %
%     tit = '(m+p)/2';
%     y1 = log(XAstr_cyl_S);
%     %
%     graph2D_jd(x1,x2,y1.','','','',xlim1,xlim2,1,NaN,cont,0,'-','k',0.5,20);hold on
%     graph2D_jd(ppar_cyl,pperp_cyl,y3.','','','',xlim1,xlim2,0,NaN,0.5,0,'-','k',2,20);
%     %
%     graph1D_jd(x1,y2,0,0,xlab1,xlab2,tit,NaN,xlim1,xlim2,'--','none','k',2,20,gca,0.9,0.7,0.7);
%     %
%     axis('equal');axis([xlim1,xlim2]);
%     %
%     figure(ifig+1),clf
%     %
%     tit = 'm';
%     y1 = log(XAstr_cyl_S_Pm);
%     %
%     graph2D_jd(x1,x2,y1.','','','',xlim1,xlim2,1,NaN,cont,0,'-','k',0.5,20);hold on
%     graph2D_jd(ppar_cyl,pperp_cyl,y3.','','','',xlim1,xlim2,0,NaN,0.5,0,'-','k',2,20);
%     %
%     graph1D_jd(x1,y2,0,0,xlab1,xlab2,tit,NaN,xlim1,xlim2,'--','none','k',2,20,gca,0.9,0.7,0.7);
%     %
%     axis('equal');axis([xlim1,xlim2]);
%     %
%     figure(ifig+2),clf
    %
    tit = '';%'p';
    %
    graph2D_jd(x1,x2,y1.','','','',xlim1,xlim2,0,NaN,graph.cont,0,'-','k',0.5,20);hold on
    %
%     graph2D_jd(x1,x2,y3.','','','',xlim1,xlim2,0,NaN,0.5,0,'-','k',2,20);
    graph1D_jd(x4,y4,0,0,'','','',NaN,xlim1,xlim2,'--','none','k',0.5,20);
        %
    graph1D_jd(x1,y2,0,0,xlab1,xlab2,tit,NaN,xlim1,xlim2,'--','none','k',2,20,gca,0.9,0.7,0.7);
    %
    axis('equal');axis([xlim1,xlim2]);
end    
    
    
    
    
