function [] = bremlocaldisplay_dke_yp(dkeparam,display,equilDKE,momentumDKE,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,r_display,t_display,k_display,p_opt,filename);
%R5-X2 - Draws local properties of the plasma bremsstrahlung
%
% This function draws local properties of the plasma bremsstrahlung
%
% by J. Decker (CEA/IRFM, joan.decker@cea.fr) and Y. Peysson (CEA/IRFM, yves.peysson@cea.fr)
%
if nargin < 12, error('Not enough input argument in bremlocaldisplay_dke_yp');end
if nargin == 12, 
    p_opt = 2;
    filename = '';
end
if nargin == 13, 
    filename = '';
end
%
dp_cyl = display.dp_cyl;
nlevel = display.nlevel;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
theta_hxr = Zbremchord.theta_hxr;
PSI_hxr = Zbremchord.PSI_hxr;
mask_hxr = Zbremchord.mask_hxr;
%
ne_ref = mksa.ne_ref;
betath_ref = mksa.betath_ref;
Ec = momentumDKE.Ec_ref;
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
kphot = Zbremplasma.kphot;
%
XXfinit = dke_out.XXfinit(:,:,r_dke);
XXf0 = dke_out.XXf0(:,:,r_dke);
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
i_test = max(find(xrho <= r_display));%Normalized radius index for output and display
j_test = max(find(theta_hxr(1,:) <= t_display*pi/180));%Poloidal angle index for output and display
k_test = find(kphot == k_display,1);%Photon energy (keV)
%
if isempty(j_test), j_test = size(theta_hxr,2);end;%To avoid round-off that give an empty value close to theta = 0.
%
for j = 0:5,%Search the closest cell where a chord is going through
   if mask_hxr(i_test,j_test + j), 
   	j_testref = j_test + j;break;
   else
   	j_testref = 1;
   end
end
j_test = j_testref;
%
if ~mask_hxr(i_test,j_testref),
   info_dke_yp(2,'WARNING: no chord is going through the plasma volume at the chosen radial and poloidal positions !');
   [i_test1,j_test1]=find(mask_hxr==1);
   disp('Choose one of these index values (i,j) for which one chord crosses the plasma volume')
   for ii=1:length(i_test1),
      disp([int2str(ii),' - (i,j) : ',int2str(i_test1(ii)),'/',int2str(j_test1(ii)),' - (rho,theta[deg.]) : ',num2str(xrho(i_test1(ii))),'/',num2str(180*theta_hxr(1,j_test1(ii))/pi)]);
   end
   ii1 = input_dke_yp(['Give the index (between 1 and ',int2str(max(ii)),')'],1);
   i_test = i_test1(ii1);
   j_test = j_test1(ii1);
end
%
rho_out = xrho(i_test);
theta_out = theta_hxr(1,j_test);
%
% Test of the reconstruction of the distribution function on the Legendre polynomial basis
%
figure('Name','Distribution function @ p_{\perp} = 0');
%ylab = ['f(norm initial: ',num2str(Zbremplasma.Znorm0_hxr{i_test,j_test}),', norm recontructed: ',num2str(Zbremplasma.Znormi_hxr{i_test,j_test}),')'];
ylab = 'f_{0}/n_{e0}';
tit = 'Distribution function @ p_{\perp} = 0';
%	
graph1D_jd(pn,Zbremplasma.ZXf0_i{i_test,j_test}(:,size(Zbremplasma.ZXf0_i{i_test,j_test},2)),0,1,'','','',NaN,'','','-','non','b',2);
hold on			
graph1D_jd(pn,Zbremplasma.ZXf0_i1{i_test,j_test}(:,size(Zbremplasma.ZXf0_i{i_test,j_test},2)),0,1,'','','',NaN,'','','--','non','r',2);
graph1D_jd(pn,Zbremplasma.ZXf0_i{i_test,j_test}(:,1),0,1,'','','',NaN,'','','-','non','c',2);
graph1D_jd(pn,Zbremplasma.ZXf0_i1{i_test,j_test}(:,1),0,1,'p_{||}/p_{Te}^{ref}',ylab,tit,NaN,'','','--','non','k',2);
grid on,zoom on
legend('Forward DKE','Forward Legendre','Backward DKE','Backward Legendre','Location','NorthEast')
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(1)+1,yylimit(1)*6,['\rho = ',num2str(rho_out),' and \theta_{pol} = ',num2str(theta_out*180/pi),' (Deg)']);set(ht,'fontsize',20);
print_jd(p_opt,[filename,'_DistributionFunction']);
%
% Contour plot of the electron distribution function
%
[logXfinit_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXfinit(:,:,i_test)),pn,mhu,dp_cyl);
[logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXf0(:,:,i_test)),pn,mhu,dp_cyl);
[logXf_hxr_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Zbremplasma.ZXf0_hxr{i_test,j_test}),pn,Zbremplasma.mhu_hxr{i_test,j_test},dp_cyl);
%
Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
Xp_cyl2 = Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl;
Xp_cyl = sqrt(Xp_cyl2);
%
Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xf0_cyl(isnan(Xf0_cyl)) = 0;%Remove NaN values
Xf0_cyl = Xf0_cyl.*(abs(Xf0_cyl)>eps);%Remove value smaller than the numerical accuracy
%
Xfinit_cyl = exp(logXfinit_cyl);%For accurate representation in figures 
Xfinit_cyl = Xfinit_cyl.*(Xfinit_cyl>0);%Remove negative values
Xfinit_cyl = Xfinit_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xfinit_cyl(isnan(Xfinit_cyl)) = 0;%Remove NaN values
Xfinit_cyl = Xfinit_cyl.*(abs(Xfinit_cyl)>eps);%Remove value smaller than the numerical accuracy
%
Xf_hxr_cyl = exp(logXf_hxr_cyl);%For accurate representation in figures 
Xf_hxr_cyl = Xf_hxr_cyl.*(Xf_hxr_cyl>0);%Remove negative values
Xf_hxr_cyl = Xf_hxr_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xf_hxr_cyl(isnan(Xf_hxr_cyl)) = 0;%Remove NaN values
Xf_hxr_cyl = Xf_hxr_cyl.*(abs(Xf_hxr_cyl)>eps);%Remove value smaller than the numerical accuracy
%
%Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
%Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
%Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
Ec_cyl = (sqrt(Xp_cyl2*(betath_ref).^2 + 1) - 1)*mc2;
mask_cyl_hxr = 1.0*(Ec_cyl < kphot(k_test));
mask_cyl_hxr(mask_cyl_hxr==0) = Inf*mask_cyl_hxr(mask_cyl_hxr==0);
%
xlim1 = [-pnmax_S,pnmax_S];xlim2 = [0,pnmax_S];
siz = 20;red = 0.95;
%
figure('Name','Distribution function contour at B=Bmin');
graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','b',0.5,siz,red,max(max(Xf0_cyl)));
graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl'.*mask_cyl_hxr','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','k',2,siz,red,max(max(Xfinit_cyl)));
graph2D_jd(ppar_cyl,pperp_cyl,Xf0_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xfinit_cyl)));
axis('equal');
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(1)+1,yylimit(1),['\rho = ',num2str(rho_out),' and \theta_{pol} = 0 (Deg)']);set(ht,'fontsize',20);
%s
if bounce_mode >= 1,%Draw bounce domain boundaries
   mhubounce2_0 = 1 - 1/max(PSI_hxr(i_test,:));
   line([0,pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
   line([0,-pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
end				
print_jd(p_opt,[filename,'_DistributionFunctionBmin']);
%
figure('Name','Distribution function contour');
graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','b',0.5,siz,red,max(max(Xf_hxr_cyl)));
graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl'.*mask_cyl_hxr','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','k',2,siz,red,max(max(Xfinit_cyl)));
graph2D_jd(ppar_cyl,pperp_cyl,Xf_hxr_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xfinit_cyl)));
axis('equal');
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(1)+1,yylimit(1),['\rho = ',num2str(rho_out),' and \theta_{pol} = ',num2str(theta_out*180/pi),' (Deg)']);set(ht,'fontsize',20);
%
if bounce_mode >= 1,%Draw bounce domain boundaries
   mhubounce2 = 1 - PSI_hxr(i_test,j_test)/max(PSI_hxr(i_test,:));
   line([0,pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
   line([0,-pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
end
print_jd(p_opt,[filename,'_DistributionFunctionB']);
%
% Local bremsstrahlung properties
%
figure('Name','Local bremshrahlung forward - perp - backward');
graph1D_jd(kphot,Zbremplasma.brem_forward{i_test,j_test},0,1,'','','',NaN,'','','-','non','r',2);
graph1D_jd(kphot,Zbremplasma.brem_backward{i_test,j_test},0,1,'','','',NaN,'','','-','non','b',2);
graph1D_jd(kphot,Zbremplasma.brem_4pi{i_test,j_test},0,1,'','','',NaN,[0,200],'','-.','non','g',2);
graph1D_jd(kphot,Zbremplasma.brem_perp{i_test,j_test},0,1,'Photon energy (keV)','Photon density (s-1*m-3*keV-1*str-1)','Bremsstrahlung emission',NaN,'','','-','non','k',2);
legend('Forward','Backward','Mean 4{\pi}','Perp.')
xxlimit = xlim;yylimit = ylim;
ht = text(xxlimit(1)+1,yylimit(1)*7,['\rho = ',num2str(rho_out),' and \theta_{pol} = ',num2str(theta_out*180/pi),' (Deg)']);set(ht,'fontsize',20);
grid on
print_jd(p_opt,[filename,'_LocalBremsstrahlung']);
%
