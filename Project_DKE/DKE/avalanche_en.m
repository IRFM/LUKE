function [XXSavalanches_norm,xnre_init,xnre_out_norm] = avalanche_en(dkepath,dkeparam,dkedisplay,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,equilDKE,radialDKE)
%
% This function calculates the avalanche source term
%
% INPUT
%    - gridDKE: grid structure, XXmhu
%    - display: dkedisplay structure
%    - Zmomcoef
%    - Zbouncecoef
%    - equilDKE
%    - radialDKE
%
% OUTPUT:
%    - The full avalanche operator S(p,mhu,l) (source term for runaways)
%
% By E. Nilsson (CEA-IRFM, emelie.nilsson@cea.fr) Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker
% (CEA-DRFC, joan.decker@cea.fr) 
%
npsi = gridDKE.nr;
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
pnmax_S = dkeparam.pnmax_S;
f_pmax = dkeparam.f_pmax; % multiplication of p grid. f_pmax*p_max
%
%extending the grid so that we can count the avalanche created beyond pmax
npnRA = f_pmax*gridDKE.npn;
pnRA = gridDKE.pn;
dpnRA = gridDKE.dpn;
%
for ig = 1:(f_pmax-1)
    pnRA = [pnRA, gridDKE.pn + ig*pnmax_S];
    dpnRA = [dpnRA, gridDKE.dpn];
end
%
pnRA2 = pnRA.^2;
XXpnRA2 = permute(repmat(pnRA.^2,[nmhu 1]),[2,1]);
XXpnRA = permute(repmat(pnRA,[nmhu 1]),[2,1]);
gammaRA = sqrt(1+(pnRA*mksa.betath_ref).^2);
xnre_init = ohm.xnre_init;
%
if Zbouncecoef.XXlambda~=1
    %[XXalpha_an,XXmask_ctsa,thetastar_an,thetastar_an2]=S_anal_en(equilDKE,gridDKE,Zmomcoef, pnRA, dpnRA, npnRA, gammaRA); %calculates alpha and theta* with analytical formula in circ concentric case
    tic
    [XXthetastar1,XXthetastar2,XXalpha] = thetastar_calc_dke_en(equilDKE,gridDKE,Zmomcoef, pnRA, dpnRA, npnRA, gammaRA);%calc the critical poloidal angle value theta_star for runaway avalanches with interp1
    toc
    %     tic
    %     [XXthetastar1f,XXthetastar2f,XXalphaf] =
    %     thetastar_dke_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE);%calc the critical poloidal angle value theta_star for runaway avalanches with fzero
    %     toc
else
    XXalpha=ones(npsi,npnRA,nmhu);
    XXthetastar1=0;
    XXthetastar2=0;
    XXalpha_an=ones(npsi,npnRA,nmhu);
end
%
Lambd = mksa.lnc_e_ref;
ne_ref=mksa.ne_ref;
ne=equilDKE.xne/ne_ref;
beta=mksa.betath_ref;
ap=equilDKE.ap;
Rp=equilDKE.Rp;
%nr=0.05*ne;
%
B0=equilDKE.xB0;
Bmax = max((sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2)),[],2)';
%
mhuT=sqrt(1-B0./Bmax);
%
keyboard
for ipsi=1:npsi
    pthmask = pnRA >= dkeparam.pnmin_S; %only take p>p0
    Srp(ipsi,:) = beta^3*1/2*beta^3*1/(4*pi)/Lambd*ne(ipsi)./(beta*pnRA.*gammaRA.*(gammaRA-1).^2).*pthmask; % rosenbluth (S*), first beta3 is from the Jacobian
end
%
for ip0=1:length(pnRA)
p0mask = pnRA >= pnRA(ip0);
I(ip0) = 2*pi*integral_dke_jd(dpnRA,p0mask.*Srp(gridDKE.rdke,:).*pnRA2(gridDKE.rdke,:),2); 
end
%
figure;graph1D_jd(pnRA,I/I(1),0,0,'p>p0','integral over S [p0,pmax]','',NaN,NaN,NaN,'-','.','b',2);
%
XXSrp=permute(repmat(Srp, [1,1,nmhu]),[1,2,3]);
%
delt = zeros(npsi,npnRA,nmhu);
%
%delta function in the cylindrical + analytical case
%
for ip=1:npnRA
    xistar(ip) = sqrt((gammaRA(ip)-1)/(gammaRA(ip)+1));
    dxistar=gridDKE.dmhu(1);
    xigrid = linspace(xistar(ip)-1/2*dxistar,xistar(ip)+1/2*dxistar,2);
    fdel = 1*nmhu/2;
    mhu_S = linspace(gridDKE.mhu(1)-gridDKE.dmhu(1)/2, gridDKE.mhu(end)+gridDKE.dmhu(end)/2,nmhu+1);
    delt(:,ip,:) = redistrib_jd(xigrid,fdel,mhu_S,0);
end
%[dummy,I] = min(abs(gridDKE.mhu - sqrt((gammaRA(ip)-1)/(gammaRA(ip)+1))))
%delt(:,ip,I) = 1;
%delt(:,ip,nmhu-I+1) = 1;

if Zbouncecoef.XXlambda~=1
C=NaN(npsi,npnRA,nmhu);
%
for ipsi=1:npsi
    for m=1:nmhu
        C(ipsi,:,m)=2/pi./(gammaRA+1)./(Zbouncecoef.Xxlambda(m,ipsi).*Zbouncecoef.xqtilde(ipsi)).*abs(gridDKE.mhu(m))./(1-gridDKE.mhu(m).^2).^2;
        %
        %XXS_an=XXSrp.*C.*XXalpha_an;
        ximask = zeros(npsi,npnRA,nmhu);
        ximask(:,:,nmhu/2+1:end) = 1; %positiv xi
        XXbouncef=C.*XXalpha.*ximask; %numerical
    end
end
%
else 
    C=ones(npsi,npnRA,nmhu).*delt; %cylindrical case
    XXbouncef=C.*XXalpha;
end

%
XXSl = XXSrp.*XXbouncef; %<S()> numerical
%
XXSrp_xis=XXSrp.*delt; %3D analytical rosenbluth operator, non bounce averaged
XXSl2=XXSrp_xis;
XXSavalanches_normtot = permute(XXSl,[2,3,1]);
%
%check the operator, compare with theory RP NF 1997
alpha = 1:0.5:10;%E/Ec
Zi = -1;
betath2 = 0.01;%
%
for ia = 1:length(alpha)
pc = 1/sqrt((alpha(ia)-1)*betath2);
%calculate secondary growth rate pmax<p<pext NORMALIZED to nr
XXRintmask = XXpnRA > pc;
Srp_int_norm_nr(ia) = mksa.nhu_ref*2*pi*integral_dke_jd(gridDKE.dmhu,integral_dke_jd(dpnRA,XXSavalanches_normtot(:,:,gridDKE.rdke).*XXRintmask.*XXpnRA2(:,:,gridDKE.rdke),1),1)'; %
end
%
RR_an = RR_rosenbluth_en(alpha, Zi, mksa.ne_ref, mksa.lnc_e_ref, equilDKE.ap*equilDKE.xrho/equilDKE.Rp); %analytic AVALANCHE growth rate Rosenbluth Putvinski NF 1997
%
figure;graph1D_jd(alpha,Srp_int_norm_nr./RR_an,0,0,'E/E_c','growth rate (s^-1)','Numerical growth rate',NaN,NaN,NaN,'-','o','b',2);hold on
graph1D_jd(alpha,RR_an./RR_an,0,0,'','','',NaN, NaN,NaN,'-','none','r',3);hold off
figure;graph1D_jd(alpha,Srp_int_norm_nr,0,0,'E/E_c','growth rate (s^-1)','Numerical growth rate',NaN,NaN,NaN,'-','o','b',2);hold on
graph1D_jd(alpha,RR_an,0,0,'','','',NaN, NaN,NaN,'-','none','r',3);hold off
%
if f_pmax>1
    xnre_out_norm(1,gridDKE.rdke) =beta^3*2*pi*integral_dke_jd(gridDKE.dmhu*nmhu/2,integral_dke_jd(dpnRA((npn+1):end),XXSavalanches_normtot((npn+1):end,:,gridDKE.rdke).*XXpnRA2((npn+1):end,:,gridDKE.rdke),1),1)'; % runaway electrons created outisde pmax THIS IS A RATE! (per collision time)
else
    xnre_out_norm(1,gridDKE.rdke) = 0;
end
%
XXSavalanches_norm = XXSavalanches_normtot(1:npn,:,:); %the avalanche part with p < pmax
%
%
%display section:
% if dkedisplay.display_mode>0
%ir=1; %nr of the flux surface to be displayed
%     if Zbouncecoef.XXlambda~=1
% 
%        ir=1
%         figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXthetastar1(ir,:,:)),'p','mhu','theta^*_1',NaN,NaN,0,NaN,30); colorbar;
%         figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXthetastar2(ir,:,:)),'p','mhu','theta^*_2',NaN,NaN,0,NaN,30); colorbar;
%         figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXS(ir,:,:)),'p','mhu','S',NaN,NaN,0,NaN,30); colorbar;
%         for ipsi=1:npsi
%             figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXbouncef(ipsi,:,:)),'p','mhu','Bouncefactor',NaN,NaN,0,NaN,100); colorbar;
%             figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalpha(ipsi,:,:)),'p','mhu','XXalpha',NaN,NaN,0,NaN,100); colorbar;
%             figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(C(ipsi,:,:)),'p','mhu','C',NaN,NaN,0,NaN,100); colorbar;
%         end

% for ipsi=1:npsi
% figure;graph2D_jd(gridDKE.xpn.*gridDKE.Xmhu,gridDKE.xpn.*sqrt(1-gridDKE.Xmhu.^2),squeeze(XXbouncef(ipsi,:,:))','p_{par}/p_{th}','p_{perp}/p_{th}','BF',NaN,NaN,0,NaN,30); colorbar;
%  hold on 
% h = plot(gridDKE.pn.*mhuT(ipsi),gridDKE.pn.*sqrt(1-mhuT(ipsi).^2));
% %h2 = plot(-gridDKE.pn.*mhuT(ipsi),gridDKE.pn.*sqrt(1-mhuT(ipsi).^2));
% set(h,'Color','k','LineWidth',2)
% %set(h2,'Color','k','LineWidth',2)
% end
%
% 
%         figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(thetastar_an2(ir,:,:)),'p','mhu','theta^*_2 anal.',NaN,NaN,0,NaN,30); colorbar;   
%         figure;graph2D_jd(pnRA,gridDKE.mhu,squeeze(XXalpha_an(ir,:,:)),'p','mhu','XXalpha analytical',NaN,NaN,0,NaN,100); colorbar;
% figure;graph2D_jd(gridDKE.xpn.*gridDKE.XXmhu,gridDKE.xpn.*sqrt(1-gridDKE.XXmhu.^2),squeeze(thetastar_an(ir,:,:))','p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_1 anal.',NaN,NaN,0,NaN,30); colorbar;
%         %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),XXthetastar2(:,:,l),'p','mhu','theta^*_2',NaN,NaN,0,NaN,30);colorbar;
%         %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),log(XXS(:,:,l)),'p','mhu','log(S)',NaN,NaN,1,NaN,30);colorbar;
%         %figure;graph2D_jd(Zmomcoef.xz.*gridDKE.XXmhu,Zmomcoef.xz.*sqrt(1-gridDKE.XXmhu.^2),log(XXS(:,:,l)),'p_{par}/p_{th}','p_{perp}/p_{th}','log(S)',NaN,NaN,1,NaN,30);colorbar;
%         %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),C(:,:,l),'p/p_{th}','mhu','C',NaN,NaN,0,NaN,30);
%         %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),XXalpha(:,:,l),'p/p_{th}','mhu','XXalpha',NaN,NaN,0,NaN,50);colorbar;
%         %check that the thetas appear in the same place in matrix:
%         figure;hold on
%         for n=1:npsi
%             graph1D_jd(1:nmhu,sum(~isnan(squeeze(XXthetastar1(n,:,:)))),0,0,'','','',NaN,NaN,NaN,'-','o','b')
%             graph1D_jd(1:nmhu,sum(~isnan(squeeze(XXthetastar2(n,:,:)))),0,0,'column in theta matrix','nr of non NaN per row','',NaN,NaN,NaN,'-','.','r')
%         end
% %       figure; graph2D_jd(gridDKE.pn(:).*gridDKE.XXmhu(1,:,l),gridDKE.pn(:).*sqrt(1-gridDKE.XXmhu(1,:,l).^2),XXthetastar1(:,:,l)'/pi,'p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_1/pi',NaN,NaN,0,NaN,60);colorbar;
% %       figure; graph2D_jd(gridDKE.pn(:).*gridDKE.XXmhu(1,:,l),gridDKE.pn(:).*sqrt(1-gridDKE.XXmhu(1,:,l).^2),XXthetastar2(:,:,l)'/pi,'p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_2/pi',NaN,NaN,0,NaN,60);colorbar;
%     end
%     %
% figure
% ylabel('XXalpha')
% hold on
% for h=1:nmhu
% plot(XXalpha(1,:,h),'r*')
% end
% figure
% ylabel('XXalpha anal.')
% hold on
% for h=1:nmhu
% plot(XXalpha_an(1,:,h),'r*')
% end
%     figure
%     for g=1:npsi
%         XS=squeeze(XXS(g,:,:));
%         XS(isnan(XS)) = 0;
%         XSint = integral_dke_jd(gridDKE.dmhu,XS,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%         graph1D_jd(gridDKE.pn,XSint,0,1,'p','S_{bounce}','S on each flux surface',NaN,NaN,NaN,'-','.')
%         hold all,
%     end
%     
%         figure
%     for g=1:npsi
%         XS=squeeze(XXS(g,:,:));
%         XS(isnan(XS)) = 0;
%         XSint = integral_dke_jd(gridDKE.pn,XS,1)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%         graph1D_jd(gridDKE.mhu,XSint,0,0,'mhu','S_{bounce}','S on each flux surface',NaN,NaN,NaN,'-','.')
%         hold all,
%     end
%     figure
%     for g=1:npsi
%         XSan=squeeze(XXS_an(g,:,:));
%         XSan(isnan(XSan)) = 0;
%         XSan_int = integral_dke_jd(gridDKE.dmhu,XSan,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%         graph1D_jd(gridDKE.pn,XSan_int,0,1,'p','S_{bounce} analytical','S on each flux surface',NaN,NaN,NaN,'-','.')
%     end
%     %compare analytic alpha
%          figure
%     for g=1:npsi
%         XSan=squeeze(XXS_an(g,:,:));
%         XSan(isnan(XSan)) = 0;
%         XSan_int = integral_dke_jd(gridDKE.pn,XSan,1)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%         graph1D_jd(gridDKE.mhu,XSan_int,0,0,'mhu','S_{bounce} anal.','S on each flux surface',NaN,NaN,NaN,'-','.')
%         hold all,
%     end
%     
        figure
        %
    for g=1:npsi
        XS = squeeze(XXSl(g,:,:));
        XS(isnan(XS)) = 0;
        XSint = integral_dke_jd(ones(1,nmhu),XS,2);
        %semilogy(gridDKE.pn,XSint,'.-')
        %legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(ir)));
        graph1D_jd(pnRA,XSint,0,1,'p','S_{bounce} LUKE','S on each flux surface',NaN,NaN,NaN,'-','.')
        hold all,
    end
        semilogy(pnRA, Srp(g,:),'rx');title('Rosenbluth theory (red x)'); xlabel('p'); ylabel('S')   
 %       
          figure
        %
    for g=1:npsi
        XSrp = squeeze(XXSrp_xis(g,:,:)); %integrate the 3D analytical S_RP, should get same as plotting the 2D Srp
        XSrpint = integral_dke_jd(ones(1,nmhu),XSrp,2);%/(gridDKE.dmhu(1)); %integrate over mhu, pos n neg : /2
        %semilogy(gridDKE.pn,XSint,'.-')
        %legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(ir)));
        graph1D_jd(pnRA,XSrpint,0,1,'p','S_{RP}','S on each flux surface',NaN,NaN,NaN,'-','.')
        hold all,
    end
        semilogy(pnRA, Srp(g,:),'rx');title('S_RP compared to Rosenbluth theory (red x)'); xlabel('p'); ylabel('S')   
%as fcn of mhu, for each slize of p
% figure
% hold on
% for ip=1:npn 
%         XS = squeeze(XXS(1,:,:));
% graph1D_jd(gridDKE.mhu,XS(ip,:),0,0,'mhu','S','',NaN,NaN,NaN,'-','.','b')
% end
% %
% figure
% for g=1:npsi
%     Xbouncef = squeeze(XXbouncef(g,:,:));
%     Xbouncef(isnan(Xbouncef)) = 0;
%     Xbouncefint = integral_dke_jd(ones(1,length(gridDKE.dmhu)),Xbouncef,2); %integrate over mhu, pos n neg : /2
%     graph1D_jd(gridDKE.pn,Xbouncefint,0,0,'p','Bounce factor','',NaN,NaN,NaN,'-','.','b')
%     legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(g)));
%     %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
%     hold all,
% end
% figure
% for g=1:npsi
%     Xalpha = squeeze(XXalpha(g,:,:));
%     Xalpha(isnan(Xalpha)) = 0;
%     Xalphaint = integral_dke_jd(gridDKE.dmhu,Xalpha,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%     graph1D_jd(gridDKE.pn,Xalphaint,0,0,'p','Xalpha','',NaN,NaN,NaN,'-','.','b')
%     legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(g)));
%     %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
%     hold all,
% end
% figure
%     for g=1:npsi
%         Xalpha_anal=squeeze(XXalpha_an(g,:,:));
%         Xalpha_anal(isnan(Xalpha_anal)) = 0;
%         Xalpha_anal_int = integral_dke_jd(gridDKE.dmhu,Xalpha_anal,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%         graph1D_jd(gridDKE.pn,Xalpha_anal_int,0,0,'p','Xalpha analytical','alpha on each flux surface',NaN,NaN,NaN,'-','.')
%     end
% figure
% for g=1:ir
%     Xmask = squeeze(XXmask_ctsa(g,:,:));
%     Xmaskint = integral_dke_jd(gridDKE.dmhu,Xmask,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%     graph1D_jd(gridDKE.pn,Xmaskint,0,0,'p','Xmask','',NaN,NaN,NaN,'-','.','b')
%     legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(ir)));
%     %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
%     hold all,
% end
% figure
% hold on
% for ip=1:npn 
%         Xalpha = squeeze(XXalpha(3,:,:));
% graph1D_jd(gridDKE.mhu,Xalpha(ip,:),0,0,'mhu','Xalpha','',NaN,NaN,NaN,'-','.','b')
% end
% figure
% hold on
% for ip=1:npn 
%         Xalphaan = squeeze(XXalpha_an(1,:,:));
% graph1D_jd(gridDKE.mhu,Xalphaan(ip,:),0,0,'mhu','Xalpha anal.','',NaN,NaN,NaN,'-','.','b')
% end
% figure
% hold on
% for g=1:npsi
%     XC = squeeze(C(g,:,:));
%     XC(isnan(XC)) = 0;
%     XCint = integral_dke_jd(gridDKE.dmhu,XC,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%     graph1D_jd(gridDKE.pn,XCint,0,0,'p','XC','',NaN,NaN,NaN,'-','.','b')
%     legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(g)));
%     %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
%     hold all,
% end
% figure
% hold on
% for ip=1:npn 
%         XC = squeeze(C(3,:,:));
% graph1D_jd(gridDKE.mhu,XC(ip,:),0,0,'mhu','C','',NaN,NaN,NaN,'-','.','b')
% end
% 
% end
