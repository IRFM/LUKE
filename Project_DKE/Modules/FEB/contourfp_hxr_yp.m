function [ppar_cyl,pperp_cyl,p_hxr,Xf_hxr_cyl,mc2,betath_ref] = contourfp_hxr_yp(dkeparam,display,equilDKE,momentumDKE,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,Zbremdiag,i_kphot,i_test,j_test,display_mode)
%
%Draw countour plot of the electron distribution function with the region that is concerned by fast electron bremsstrahlung above a given photon energy
%(see its use in postprocessingTS_hxr.m and postprocessingMST_hxr.m in Simulations directory)
%
%by Y. PEYSSON (CEA/DRFC, yves.peysson@cea.fr) and J. DECKER (CEA/DRFC, joan.decker@cea.fr)
%
if nargin < 14,
    error('Not enough input arguments in contourfp_hxr_yp');
end
%
if i_test > size(Zbremplasma.ZXf0_hxr,1),
    error(['Radial index may not exceed ',int2str(size(Zbremplasma.ZXf0_hxr,1))]);
end
if j_test > size(Zbremplasma.ZXf0_hxr,2),
    error(['Poloidal index may not exceed ',int2str(size(Zbremplasma.ZXf0_hxr,2))]);
end
%
if isempty(Zbremplasma.ZXf0_hxr{i_test,j_test}),
    error('No chord is crossing the cell. Try another one');
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
dp_cyl = display.dp_cyl;
nlevel = display.nlevel;
%
theta_hxr = Zbremchord.theta_hxr;
PSI_hxr = Zbremchord.PSI_hxr;
mask_hxr = Zbremchord.mask_hxr;
%
ne_ref = mksa.ne_ref;
betath_ref = mksa.betath_ref;
Ec = mksa.Ec_ref;
%
dmhu = momentumDKE.dmhu;
mhu = momentumDKE.mhu;
dpn = momentumDKE.dpn;
pn = momentumDKE.pn;
%
r_dke = radialDKE.r_dke;
%
pnmax_S = dkeparam.pnmax_S;
bounce_mode = dkeparam.bounce_mode;
%
kphot = Zbremdiag.kfit;
%
XXfinit = dke_out.XXfinit(:,:,r_dke);
XXf0 = dke_out.XXf0(:,:,r_dke);
XXf0_tp = dke_out.XXf0_tp(:,:,r_dke);
XXf0_g = dke_out.XXf0_g(:,:,r_dke);
%
Rp = equilDKE.Rp;
Zp = equilDKE.Zp;
ap = equilDKE.Xx(end,1);
%
theta = equilDKE.mtheta;
xpsin = equilDKE.xpsin;
psia_apRp = equilDKE.psia_apRp;
XR = equilDKE.Xx + Rp;
XZ = equilDKE.Xy + Zp;
XBR = equilDKE.XBx;
XBZ = equilDKE.XBy;
XBphi = equilDKE.XBphi;
xB0 = equilDKE.xB0;
xR0 = equilDKE.xx0 + Rp;
xBT0 = equilDKE.xBT0;
xBp0 = equilDKE.xBp0;
xrho = equilDKE.xrho;
xTe = equilDKE.xTe;
xne = equilDKE.xne;
xzTi = equilDKE.xzTi;
xzni = equilDKE.xzni;
zZi = equilDKE.zZi;
zmi = equilDKE.zmi;
xZeff = equilDKE.xZeff;
Rp = equilDKE.Rp;
Zp = equilDKE.Zp;
ap = equilDKE.ap;
xmhu0T2 = equilDKE.xmhu0T2;
xdV_dke = equilDKE.xdV_2piRp_dke*2*pi*Rp;
xdA_dke = equilDKE.xdA_dke;
xzni_norm = xzni(:,r_dke)/ne_ref;
xne_norm = xne(r_dke)/ne_ref;
xrho = xrho(r_dke);
%
pn2 = pn.*pn;
gamma = sqrt(1 + pn2*betath_ref^2);
%
[logXf_hxr_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Zbremplasma.ZXf0_hxr{i_test,j_test}),pn,Zbremplasma.mhu_hxr{i_test,j_test},dp_cyl);
%
Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
Ec_cyl = (sqrt((Xp_cyl*betath_ref).^2 + 1) - 1)*mc2;
mask_cyl_hxr = Ec_cyl >= kphot(i_kphot) - Zbremdiag.dkfit(i_kphot)/2;%Photon of energies less than the lower bound of the channel are rejected
p_hxr = min(min(Xp_cyl(mask_cyl_hxr)));%Momentum of the minimum kinetic energies of electrons contributing to the bremsstrahlung
%
Xf_hxr_cyl = exp(logXf_hxr_cyl);%For accurate representation in figures 
Xf_hxr_cyl = Xf_hxr_cyl.*(Xf_hxr_cyl>0);%Remove negative values
Xf_hxr_cyl = Xf_hxr_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xf_hxr_cyl(isnan(Xf_hxr_cyl)) = 0;%Remove NaN values
Xf_hxr_cyl(abs(Xf_hxr_cyl)<=eps) = 0;%Remove value smaller than the numerical accuracy
%
Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
%
if display_mode,
	xlim1 = [-pnmax_S,pnmax_S];xlim2 = [0,pnmax_S];
	siz = 20;red = 0.95;
%
	graph2D_jd(ppar_cyl,pperp_cyl,Xf_hxr_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xf_hxr_cyl)));
%
	Xf_hxr_cyl_mask = Xf_hxr_cyl'.*~mask_cyl_hxr';
	Xf_hxr_cyl_mask(Xf_hxr_cyl_mask == 0) = Xf_hxr_cyl_mask(Xf_hxr_cyl_mask == 0)*NaN;
	graph2D_jd(ppar_cyl,pperp_cyl,Xf_hxr_cyl_mask,'p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.25:pnmax_S],0,'-','k',2,siz,red,max(max(Xf_hxr_cyl)));
	graph1D_jd(p_hxr*[-1,mhu,1],p_hxr*sqrt(1-[-1,mhu,1].^2),0,0,'p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',NaN,'','','-','none','b',2);
	axis('equal');
	xxlimit = xlim;yylimit = ylim;
	ht = text(xxlimit(1)+1,yylimit(2)*1.2,['\rho = ',num2str(Zbremplasma.xrho(i_test)),', \theta_{pol} = ',num2str(Zbremplasma.theta_hxr(1,j_test)*180/pi),' (Deg)']);set(ht,'fontsize',20);
	ht = text(xxlimit(1)+1,yylimit(1)*0.3,['k = ',num2str(kphot(i_kphot)),' (keV), \Deltak = ',num2str(Zbremdiag.dkfit(i_kphot)),' (keV)']);set(ht,'fontsize',20,'Color','red');
%
	if bounce_mode >= 1,%Draw bounce domain boundaries
   		mhubounce2 = 1 - PSI_hxr(i_test,j_test)/max(PSI_hxr(i_test,:));
   		line([0,pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
   		line([0,-pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
	end
end


