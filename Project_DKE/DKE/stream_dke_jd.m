function [XAstr_S,ppar_cyl_S,pperp_cyl_S] = stream_dke_jd(dke_out,dkeparam,momentumDKE,gridDKE,equilDKE,ir_display_dke,display_mode,pmax_disp)
%
%Stream function calculation for graphical flux analysis
%
%by Joan Decker (joan.decker@cea.fr, CEA/DSM/IRFM) and Yves Peysson (yves.peysson@cea.fr, CEA/DSM/IRFM)
%
if nargin < 6,
	info_dke_yp(2,'Wrong number of input arguments for stream_dke_jd');
	return;
end
%
if nargin == 6,
    ir_display_dke = 1;
    display_mode = 0;
    pmax_disp = max(momentumDKE.pn_S);
end
%
if nargin == 7,
    display_mode = 0;
    pmax_disp = max(momentumDKE.pn_S);
end
%
if nargin == 8,
    pmax_disp = max(momentumDKE.pn_S);
end
%
ZXXS = dke_out.ZXXS;
XxRR_fsav = dke_out.XxRR_fsav(:,ir_display_dke);
%
pn_S = momentumDKE.pn_S(:);
npn_S = length(pn_S);
%
mhu_S = momentumDKE.mhu_S;
nmhu_S = length(mhu_S);
%
dmhu = momentumDKE.dmhu;
xmhubounce2 = gridDKE.xmhubounce2(ir_display_dke);
%
XSp0_tot_ipj = ZXXS.p0_c_ipj(:,:,ir_display_dke) + ZXXS.p0_e_ipj(:,:,ir_display_dke) + ZXXS.p0_rf_ipj(:,:,ir_display_dke);
%
XAstr_S_Pp = zeros(npn_S,nmhu_S);%circulating particles (pn>=0)
XAstr_S_Pm = zeros(npn_S,nmhu_S);%circulating particles (pn<0)
XAstr_S_T = zeros(npn_S,nmhu_S);%trapped particles
XAstr_S = zeros(npn_S,nmhu_S);
%
if dkeparam.bounce_mode,
    %
    nT = sum(abs(mhu_S) <= sqrt(xmhubounce2));%Trapped particles
    nP = (nmhu_S - nT)/2;%Circulating particles 
    %
    for j=1:nP,%ksi < 0
    	XAstr_S_Pm(2:npn_S,j) = XxRR_fsav(end) - 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
    end
    %
    for j=1:nP,%ksi > 0
    	XAstr_S_Pp(2:npn_S,nmhu_S-j+1) = XxRR_fsav(end) + 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(nmhu_S-j:nmhu_S-1),XSp0_tot_ipj(:,nmhu_S-j:nmhu_S-1),2);%Stream function with runaway
    end
    %
    for j=1:(nT-1)/2,%|ksi| <= ksi_T
    	XAstr_S_T(2:npn_S,(nmhu_S-1)/2+j+1) = XxRR_fsav(end) - 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu((nmhu_S-1)/2+1:(nmhu_S-1)/2+j),XSp0_tot_ipj(:,(nmhu_S-1)/2+1:(nmhu_S-1)/2+j),2);%Stream function with runaway
    	XAstr_S_T(2:npn_S,(nmhu_S-1)/2-j+1) = XxRR_fsav(end) + 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu((nmhu_S-1)/2+1-j:(nmhu_S-1)/2),XSp0_tot_ipj(:,(nmhu_S-1)/2+1-j:(nmhu_S-1)/2),2);%Stream function with runaway
    end
    %
    XAstr_S_T(2:npn_S,(nmhu_S+1)/2) = XxRR_fsav(end);
    %
    XAstr_S_T = (XAstr_S_T + fliplr(XAstr_S_T))/2;
    XAstr_S = XAstr_S_Pm + XAstr_S_T + XAstr_S_Pp;
else
    %
    for j=1:nmhu_S-1,
    	XAstr_S_Pm(2:npn_S,j) = XxRR_fsav(end) - 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(1:j),XSp0_tot_ipj(:,1:j),2);%Stream function with runaway
    end
    %
    for j=1:nmhu_S-1,
    	XAstr_S_Pp(2:npn_S,nmhu_S-j+1) = XxRR_fsav(end) + 2*pi*pn_S(2:npn_S).*pn_S(2:npn_S).*integral_dke_jd(dmhu(nmhu_S-j:nmhu_S-1),XSp0_tot_ipj(:,nmhu_S-j:nmhu_S-1),2);%Stream function with runaway
    end
    %
    XAstr_S = (XAstr_S_Pm + XAstr_S_Pp)/2;
end
%
dp_cyl = min(pn_S(2:end) - pn_S(1:end-1))/2;%cylindrical momentum grid step
%
[XAstr_cyl_S,ppar_cyl_S,dppar_cyl_S,pperp_cyl_S,dpperp_S_cyl] = s2c_dke_yp(XAstr_S,pn_S,mhu_S,dp_cyl);%Spherical to cylindrical coordinate transformation

Xppar_cyl_S = ones(length(pperp_cyl_S),1)*ppar_cyl_S(:)';%Grid for the stream or flux functions only
Xpperp_cyl_S = pperp_cyl_S(:)*ones(1,length(ppar_cyl_S));
Xmhu_cyl_S = Xppar_cyl_S./sqrt(Xppar_cyl_S.^2+Xpperp_cyl_S.^2);
Xp_cyl_S = sqrt(Xppar_cyl_S.*Xppar_cyl_S + Xpperp_cyl_S.*Xpperp_cyl_S);
%
XAstr_cyl_S = XAstr_cyl_S.*(Xp_cyl_S<max(ppar_cyl_S));%Remove values above max(ppar)
XAstr_cyl_S(isnan(XAstr_cyl_S)) = 0;%Remove NaN values
XAstr_cyl_S(1,:) = 0;
%
if display_mode == 1,
    figure,graph2D_jd(Xppar_cyl_S,Xpperp_cyl_S,XAstr_cyl_S','p_{//}/p_{th}','p_\perp/p_{th}',['Stream lines @ \rho = ',num2str(equilDKE.xrho(ir_display_dke))],[-pmax_disp,pmax_disp],[0,pmax_disp],0, NaN,linspace(min(min(XAstr_cyl_S)),max(max(XAstr_cyl_S)),200))
    if pmax_disp == pn_S(end),axis('equal');end
end    
    
    
    
    
