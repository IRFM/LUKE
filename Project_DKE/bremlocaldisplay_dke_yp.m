function [] = bremlocaldisplay_dke_yp(dkeparam,display,equilDKE,momentumDKE,radialDKE,dke_out,mksa,Zbremchord,Zbremplasma,r_display,t_display);
%
% This function draws local properties of the plasma bremsstrahlung
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
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
kphot = Zbremplasma.kphot;
%
XXfinit = dke_out.XXfinit(:,:,r_dke);
XXf0 = dke_out.XXf0(:,:,r_dke);
XXf0_tp = dke_out.XXf0_tp(:,:,r_dke);
XXf0_g = dke_out.XXf0_g(:,:,r_dke);
%
theta = equilDKE.mtheta;
xpsin = equilDKE.xpsin;
psia = equilDKE.psia;
XR = equilDKE.XR;
XZ = equilDKE.XZ;
XBR = equilDKE.XBR;
XBZ = equilDKE.XBZ;
XBphi = equilDKE.XBphi;
xB0 = equilDKE.xB0;
xR0 = equilDKE.xR0;
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
xdV_dke = equilDKE.xdV_dke;
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
if isempty(j_test), j_test = size(theta_hxr,2);end;%To avoid round-off that give an empty value close to theta = 0.
%
if ~mask_hxr(i_test,j_test),
   info_dke_yp(2,'WARNING: no chord is going through the plasma volume at the chosen radial and poloidal positions !');
   [i_test1,j_test1]=find(mask_hxr==1);
   disp('Choose one of these index values (i,j) for which one chord crosses the plasma volume')
   for ii=1:length(i_test1),
      disp([int2str(ii),' - (i,j) : ',int2str(i_test1(ii)),'/',int2str(j_test1(ii)),' - (rho,theta[deg.]) : ',num2str(xrho(i_test1(ii))),'/',num2str(180*theta_hxr(1,j_test1(ii))/pi)]);
   end
   ii1 = input_dke_yp(['Give the index (between 1 and ',int2str(max(ii)),')'],1);
   i_test = i_test1(ii1);
   j_test = j_test1(ii1);
   return
end
%
rho_out = xrho(i_test);
theta_out = theta_hxr(1,j_test);
%
% Test of the reconstruction of the distribution function on the Legendre polynomial basis
%
Fig_distri = figure('Name','Distribution function');
figure(Fig_distri);
ylab = ['f(norm initial: ',num2str(Zbremplasma.Znorm0_hxr{i_test,j_test}),', norm recontructed: ',num2str(Zbremplasma.Znormi_hxr{i_test,j_test}),')'];
tit = ['Distribution function at {\rho} = ',num2str(rho_out),' and {\theta}_{pol} = ',num2str(theta_out*180/pi),' (Deg)'];
%	
graph1D_jd(pn,Zbremplasma.ZXf0_i{i_test,j_test}(:,size(Zbremplasma.ZXf0_i{i_test,j_test},2)),0,1,'','','',NaN,'','','-','non','b',2);
hold on			
graph1D_jd(pn,Zbremplasma.ZXf0_i1{i_test,j_test}(:,size(Zbremplasma.ZXf0_i{i_test,j_test},2)),0,1,'','','',NaN,'','','--','non','r',2);
graph1D_jd(pn,Zbremplasma.ZXf0_i{i_test,j_test}(:,1),0,1,'','','',NaN,'','','-','non','c',2);
graph1D_jd(pn,Zbremplasma.ZXf0_i1{i_test,j_test}(:,1),0,1,'p_{||}/p_{Te}^{ref}',ylab,tit,NaN,'','','--','non','k',2);
grid on,zoom on
legend('Forward initial','Forward reconstructed (Legendre)','Backward initial','backward reconstructed (Legendre)')
%
% Contour plot of the electron distribution function
%
[logXfinit_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXfinit(:,:,i_test)),pn,mhu,dp_cyl);
[logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXf0(:,:,i_test) + XXf0_tp(:,:,i_test) + XXf0_g(:,:,i_test)),pn,mhu,dp_cyl);
[logXf_hxr_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(Zbremplasma.ZXf0_hxr{i_test,j_test}),pn,Zbremplasma.mhu_hxr{i_test,j_test},dp_cyl);
%
Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
%
Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xf0_cyl(isnan(Xf0_cyl)) = 0;%Remove NaN values
Xfinit_cyl = exp(logXfinit_cyl);%For accurate representation in figures 
Xfinit_cyl = Xfinit_cyl.*(Xfinit_cyl>0);%Remove negative values
Xfinit_cyl = Xfinit_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xfinit_cyl(isnan(Xfinit_cyl)) = 0;%Remove NaN values
Xf_hxr_cyl = exp(logXf_hxr_cyl);%For accurate representation in figures 
Xf_hxr_cyl = Xf_hxr_cyl.*(Xf_hxr_cyl>0);%Remove negative values
Xf_hxr_cyl = Xf_hxr_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
Xf_hxr_cyl(isnan(Xf_hxr_cyl)) = 0;%Remove NaN values
%
Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';
Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
%
xlim1 = [-pnmax_S,pnmax_S];xlim2 = [0,pnmax_S];
siz = 20;red = 0.95;
%
Fig_districontour1 = figure('Name','Distribution function contour at B=Bmin');
figure(Fig_districontour1);
graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','b',0.5,siz,red,max(max(Xf0_cyl)));
graph2D_jd(ppar_cyl,pperp_cyl,Xf0_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xfinit_cyl)));
axis('equal');
faxis = axis;dfaxis = (faxis(2) - faxis(1))/100; 
text(faxis(1) + dfaxis,faxis(2) - dfaxis,['{\rho} = ',num2str(rho_out),', {\theta}_{pol} = 0']);
%s
if bounce_mode >= 1,%Draw bounce domain boundaries
   mhubounce2_0 = 1 - 1/max(PSI_hxr(i_test,:));
   line([0,pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
   line([0,-pnmax_S*sqrt(mhubounce2_0)],[0,pnmax_S*sqrt(1 - mhubounce2_0)],'color','k');
end				
%
Fig_districontour2 = figure('Name','Distribution function contour');
figure(Fig_districontour2);
graph2D_jd(ppar_cyl,pperp_cyl,Xfinit_cyl','','','',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','b',0.5,siz,red,max(max(Xf_hxr_cyl)));
graph2D_jd(ppar_cyl,pperp_cyl,Xf_hxr_cyl','p_{||}/p_{Te}^{ref}','p_{\perp}/p_{Te}^{ref}','Distribution function',xlim1,xlim2,0,betath_ref,[0:0.5:pnmax_S],0,'-','r',2,siz,red,max(max(Xfinit_cyl)));
axis('equal');
faxis = axis;dfaxis = (faxis(2) - faxis(1))/100; 
text(faxis(1) + dfaxis,faxis(2) - dfaxis,['{\rho} = ',num2str(rho_out),', {\theta}_{pol} = ',num2str(theta_out*180/pi),' (Deg)']);
%
if bounce_mode >= 1,%Draw bounce domain boundaries
   mhubounce2 = 1 - PSI_hxr(i_test,j_test)/max(PSI_hxr(i_test,:));
   line([0,pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
   line([0,-pnmax_S*sqrt(mhubounce2)],[0,pnmax_S*sqrt(1 - mhubounce2)],'color','k');
end					
%
% Local bremsstrahlung properties
%
Fig_brem = figure('Name','Local bremshrahlung forward - perp - backward');
figure(Fig_brem);
graph1D_jd(kphot,Zbremplasma.brem_forward{i_test,j_test},0,1,'','','',NaN,'','','-','non','r',2);
graph1D_jd(kphot,Zbremplasma.brem_backward{i_test,j_test},0,1,'','','',NaN,'','','-','non','b',2);
graph1D_jd(kphot,Zbremplasma.brem_4pi{i_test,j_test},0,1,'','','',NaN,'','','-.','non','g',2);
graph1D_jd(kphot,Zbremplasma.brem_perp{i_test,j_test},0,1,'Photon energy (keV)','Photon density (s-1*m-3*keV-1*str-1)',['Bremsstrahlung emission at {\rho} = ',num2str(rho_out),' and {\theta}_{pol} = ',num2str(theta_out*180/pi),' (Deg)'],NaN,'','','-','non','k',2);
legend('Forward','Backward','Mean 4{\pi}','Perp.')
grid on
%
