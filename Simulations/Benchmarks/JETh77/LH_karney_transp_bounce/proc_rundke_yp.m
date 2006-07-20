function [] = proc_rundke_yp(nfig0,filename,ir_display,save_mode)
%
syn_mode = 0;
print_mode = -1;
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
color4 = [0,0.75,0];
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
load(filename,'ZP0_10','Zcurr10','gridDKE','mksa','equilDKE','dke_out10','display','dkeparam')
%
J_rf = -Zcurr10.x_0_fsav*mksa.j_ref;
P_rf = ZP0_10.x_rf_fsav.'*mksa.P_ref; 
%
xrho = gridDKE.xrho; 
%
I_rf = sum(J_rf.*equilDKE.xdA_dke);
p_rf = sum(P_rf.*equilDKE.xdV_dke);
Eta_rf = I_rf/p_rf;
%
disp(['RF current: ',num2str(I_rf),' MA'])
disp(['RF power: ',num2str(p_rf),' MW'])
disp(['RF CD efficiency: ',num2str(Eta_rf),' A/W'])
%
% figures
%
figure(nfig0+1),clf
%
xlab = 'r/a';
ylab = 'P_{rf} (MW/m^3)';
tit = 'Density of RF Power Absorbed';
%
xlim = [0,1];
xtick = 0:0.2:1;
ylim = NaN;
%
x = xrho; 
y = P_rf;
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace2);
set(gca,'xtick',xtick);
%
if save_mode >= 0,
	 savefig_dke_yp(['P_rf'])
end
%
figure(nfig0+2),clf
%
ylab = 'J (MA/m^2)';
tit = 'Current Density';
%
y = J_rf;
%
graph1D_jd(x,y,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace2);
set(gca,'xtick',xtick);
set(gca,'ylim',[0,max(get(gca,'ylim'))])
%
if save_mode >= 0,
    savefig_dke_yp(['J_rf'])
end
%
figure(nfig0+3),clf
%
ylab = '\eta (A/W)';
tit = 'CD efficiency';
%
y = J_rf./P_rf/(2*pi*equilDKE.Rp);
%
graph1D_jd(x(1:15),y(1:15),0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker1,color2,width2,siz,gca,red,lspace,bspace2);
set(gca,'xtick',xtick);
%
if save_mode >= 0,
    savefig_dke_yp(['eta_rf'])
end
%
figure(nfig0+4),clf
%
[logXf0_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(dke_out10.XXf0(:,:,ir_display)),gridDKE.pn,gridDKE.mhu,display.dp_cyl);%Spherical to cylindrical coordinate transformation
Xf0_cyl_ref = exp(logXf0_cyl_ref);%For accurate representation in figures 
%
[logXfinit_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(log(dke_out10.XXfinit(:,:,ir_display)),gridDKE.pn,gridDKE.mhu,display.dp_cyl);%Spherical to cylindrical coordinate transformation
Xfinit_cyl_ref = exp(logXfinit_cyl_ref);%For accurate representation in figures 
%
xyD0_rf = ones(dke_out10.gridindex_rf.nr,1);
[ZXXD_rf] = raysum_rf_jd(dkeparam,dke_out10.ZXYD_rf,dke_out10.ZXYD_rf_tp,dke_out10.ZXYF_rf_tp,xyD0_rf,dke_out10.gridindex_rf);
[XDparpar_cyl_ref,ppar_cyl_ref,dppar_cyl_ref,pperp_cyl_ref,dpperp_cyl_ref] = s2c_dke_yp(ZXXD_rf.parpar_ij(:,:,ir_display),gridDKE.pn,gridDKE.mhu,display.dp_cyl);%Spherical to cylindrical coordinate transformation
%
Xppar_cyl_ref = ones(length(pperp_cyl_ref),1)*ppar_cyl_ref(:)';%Grid for the distribution functions only
Xpperp_cyl_ref = pperp_cyl_ref(:)*ones(1,length(ppar_cyl_ref));
Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
%
Xf0_cyl_ref = Xf0_cyl_ref.*(Xf0_cyl_ref>0);%Remove negative values
Xf0_cyl_ref = Xf0_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
Xf0_cyl_ref(isnan(Xf0_cyl_ref)) = 0;%Remove NaN values
Xf0_cyl_ref(abs(Xf0_cyl_ref) < eps) = 0;%Remove values less than computer accuracy

%
Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xfinit_cyl_ref>0);%Remove negative values
Xfinit_cyl_ref = Xfinit_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));%Remove values above max(ppar)
Xfinit_cyl_ref(isnan(Xfinit_cyl_ref)) = 0;%Remove NaN values
%


Xppar_cyl_ref(abs(Xf0_cyl_ref) < eps) = 0;
Xpperp_cyl_ref(abs(Xf0_cyl_ref) < eps) = 0;


ippar = find(Xppar_cyl_ref == max(max(Xppar_cyl_ref)));
ipperp = find(Xpperp_cyl_ref == max(max(Xpperp_cyl_ref)));
pparmaxcode = max(Xppar_cyl_ref(ippar));

pperpmaxcode = max(Xpperp_cyl_ref(ipperp));

pmaxcode = max([pparmaxcode,pperpmaxcode]);

%
Xp_cyl_ref = sqrt(Xppar_cyl_ref.*Xppar_cyl_ref + Xpperp_cyl_ref.*Xpperp_cyl_ref);
%
XDparpar_cyl_ref = XDparpar_cyl_ref.*(XDparpar_cyl_ref>0);
XDparpar_cyl_ref = XDparpar_cyl_ref.*(Xp_cyl_ref<max(ppar_cyl_ref));
XDparpar_cyl_ref(isnan(XDparpar_cyl_ref))=0;
%
Fpar0_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xf0_cyl_ref,1);
Fparinit_cyl_ref = 2*pi*integral_dke_jd(dpperp_cyl_ref,Xpperp_cyl_ref.*Xfinit_cyl_ref,1);		
%
%
pnmax_S = max(gridDKE.pn_S);
%
x1 = ppar_cyl_ref;
xlab1 = 'p_{||}/p_{Te}';
%xlim1 = [-pnmax_S,pnmax_S];
xlim1 = [-pmaxcode,pmaxcode];
%
x2 = pperp_cyl_ref;
xlab2 = 'p_{\perp}/p_{Te}';
%xlim2 = [0,pnmax_S];
xlim2 = [0,pmaxcode];
%
leg = ['f_{init}';'f_0     '];
%
y1 = Xfinit_cyl_ref;
y2 = Xf0_cyl_ref;
%
x9 = x1;
y9 = sqrt(pnmax_S^2 - x9.^2);
%
graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pmaxcode],0,style,color3,width,siz,red,max(max(y1)));
graph2D_jd(x1,x2,y2','','','',xlim1,xlim2,0,mksa.betath_ref,[0:0.5:pmaxcode],0,style,color2,width2,siz,1,max(max(y1)));
graph1D_jd(x9,y9,0,0,xlab1,xlab2,['2D Distribution function f_0 at \rho = ',num2str(gridDKE.xrho(ir_display))],NaN,xlim1,xlim2,style,marker,color1,width2,siz);
axis('equal');axis([xlim1,xlim2])
%
ripple = 0;
xpndetrap = dke_out10.Zmripple.xpndetrap;
xmhusupertrap = cos((90 - dke_out10.Zmripple.xthetaloss)*pi/180);
pparsupertrap = xpndetrap(ir_display)*gridDKE.mhu(abs(gridDKE.mhu)<=xmhusupertrap(ir_display));%For contour plot of the supertrapped domain
pperpsupertrap = xpndetrap(ir_display)*sqrt(1-gridDKE.mhu(abs(gridDKE.mhu)<=xmhusupertrap(ir_display)).^2);%For contour plot of the supertrapped domain

bounce_ripple_jd(dkeparam.bounce_mode,pnmax_S,gridDKE.xmhubounce2,ir_display,[]);
%
if save_mode >= 0,
    savefig_dke_yp(['f0_2D_ir',int2str(ir_display)])
end
%
figure(nfig0+5),clf
%
y1 = XDparpar_cyl_ref;
cont = 10;[0:ceil(max(max(XDparpar_cyl_ref)))];
%
graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style,NaN,width,siz,0.95);
graph1D_jd(x9,y9,0,0,xlab1,xlab2,'D_{|| ||LH} [\nu_e p_{Te}^2]',NaN,xlim1,xlim2,style,marker,color1,width2,siz);
axis('equal');axis([xlim1,xlim2])
bounce_ripple_jd(dkeparam.bounce_mode,pnmax_S,gridDKE.xmhubounce2,ir_display,[]);
colorbar
%            
%
%figure(4),
%graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style2,color4,width2,siz);
%legend(leg)
%
%
% ---------- parallel distribution difference-----------
%
if save_mode >= 0,
    savefig_dke_yp(['Dparpar_ir',int2str(ir_display)])
end
%
figure(nfig0+6),clf
%
y1 = Fpar0_cyl_ref - Fparinit_cyl_ref;
ylab = 'F_{||0} - F_{||M}';
ylim = NaN;
%
graph1D_jd(x1,y1,0,0,xlab1,ylab,'',NaN,xlim1,ylim,style,marker,color2,width2,siz,gca,red,lspace,bspace);
%
% ---------- parallel distribution -----------
%
if save_mode >= 0,
    savefig_dke_yp(['F0mFM_1D_ir',int2str(ir_display)])
end

figure(nfig0+7),clf
%
y1 = Fparinit_cyl_ref;
y2 = Fpar0_cyl_ref;
ylab = 'F_{0||}';
ylim = [eps,1];
%
graph1D_jd(x1,y1,0,1,'','','',NaN,xlim1,ylim,style,marker,color3,width,siz,gca,red,lspace,bspace);
graph1D_jd(x1,y2,0,1,xlab1,ylab,'',leg,xlim1,ylim,style,marker,color2,width2,siz);

%
if save_mode >= 0,
    savefig_dke_yp(['F0_1D_ir',int2str(ir_display)])
end
 
   



