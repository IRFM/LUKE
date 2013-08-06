function [XXS,XXthetastar1, XXthetastar2] = avalanche_en(dkepath,dkeparam,dkedisplay,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,equilDKE,radialDKE)
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
npn = size(gridDKE.XXmhu,1);
nmhu = size(gridDKE.XXmhu,2);
npsi=size(equilDKE.XBx,1); %nr of radial positions
%

 if Zbouncecoef.XXlambda~=1
    [XXalpha_an,XXmask_ctsa,thetastar_an,thetastar_an2]=S_anal(equilDKE,gridDKE,Zmomcoef,npsi,nmhu,npn);
    tic
    [XXthetastar1,XXthetastar2,XXalpha] = thetastar_calc_dke_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE);%calc the critical poloidal angle value theta_star for runaway avalanches
    toc
%     tic
%     [XXthetastar1f,XXthetastar2f,XXalphaf] = thetastar_dke_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE);%calc the critical poloidal angle value theta_star for runaway avalanches
%     toc
      %thetastar_an(isnan(thetastar_an)) = 0;
  %XXthetastar1(isnan(XXthetastar1)) = 0;
    %keyboard
%     figure; hold on;
%     for ip=1:npn
%         graph1D_jd(gridDKE.mhu,squeeze(XXalpha_an(1,ip,:)-XXalpha(1,ip,:)),0,0,'mhu','Xalpha an-Xalphaip','',NaN,NaN,NaN,'-','.','r')
%     end
%     figure;hold on;
%     for ip=1:npn
%         graph1D_jd(gridDKE.mhu,squeeze(thetastar_an(1,ip,:)-XXthetastar1(1,ip,:)),0,0,'mhu','theta an-XXtheta1ip','',NaN,NaN,NaN,'none','.','r')
%     end
%     figure; hold on;
% %     for ip=1:npn
% %         graph1D_jd(gridDKE.mhu,squeeze(thetastar_an(1,ip,:)-XXthetastar1f(1,ip,:)),0,0,'mhu','theta an-XXtheta1fz','',NaN,NaN,NaN,'none','.','r')
% %     end
% %     %
 else
    XXalpha=ones(npsi,npn,nmhu);
    XXthetastar1=0;
    XXthetastar2=0;
    XXalpha_an=ones(npsi,npn,nmhu);
 end
%
Lambd = mksa.lnc_e_ref;
ne_ref=mksa.ne_ref;
ne=equilDKE.xne/ne_ref;
beta=mksa.betath_ref;
ap=equilDKE.ap; % should be a_p like in the rest of LUKE, in literature it is Rp. Check this!
Rp=equilDKE.Rp;
nr=0.1*ne;
%
B0=equilDKE.xB0;
Bmax = max((sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2)),[],2)';
mhuT=sqrt(1-B0./Bmax);
%
for ipsi=1:npsi
  Srp(ipsi,:)=1/(4*pi)*beta^2/log(Lambd)*ne(ipsi)*nr(ipsi)./(gridDKE.pn.*Zmomcoef.gamma.*(Zmomcoef.gamma-1).^2); %rosenbluth (S*)
end
XXSrp=permute(repmat(Srp, [1,1,nmhu]),[1,2,3]);
if Zbouncecoef.XXlambda~=1
C=NaN(npsi,npn,nmhu);
for ipsi=1:npsi 
    for m=1:nmhu
    C(ipsi,:,m)=2/pi./(Zmomcoef.gamma+1)./(Zbouncecoef.Xxlambda(m,ipsi).*Zbouncecoef.xqtilde(ipsi)).*abs(gridDKE.mhu(m))./(1-gridDKE.mhu(m).^2).^2; 
    end
end
else 
    C=ones(npsi,npn,nmhu);
end
%
XXS_an=XXSrp.*C.*XXalpha_an;
XXbouncef=C.*XXalpha;
XXS=XXSrp.*XXbouncef; %<S()>
XXS=squeeze(permute(XXS,[2,3,1]));
XXSrp_xis=XXSrp.*XXmask_ctsa;
%
%display section:
% if dkedisplay.display_mode>0
% %ir=2; %nr of the flux surface to be displayed
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
% plot(gridDKE.pn.*mhuT(ipsi),gridDKE.pn.*sqrt(1-mhuT(ipsi).^2),'m')
% plot(-gridDKE.pn.*mhuT(ipsi),gridDKE.pn.*sqrt(1-mhuT(ipsi).^2),'m')
% end
% %
% 
%         figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(thetastar_an2(ir,:,:)),'p','mhu','theta^*_2 anal.',NaN,NaN,0,NaN,30); colorbar;   
%         figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalpha_an(ir,:,:)),'p','mhu','XXalpha analytical',NaN,NaN,0,NaN,100); colorbar;
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
%         figure
%         %
%     for g=1:npsi
%         XS = squeeze(XXS(g,:,:));
%         XS(isnan(XS)) = 0;
%         XSint = integral_dke_jd(gridDKE.dmhu,XS,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
%         %semilogy(gridDKE.pn,XSint,'.-')
%         %legend(sprintf( '%s: %d', 'rho', gridDKE.xrho(ir)));
%         graph1D_jd(gridDKE.pn,XSint,0,1,'p','S_{bounce}','S on each flux surface',NaN,NaN,NaN,'-','.')
%         hold all,
%     end
%         semilogy(gridDKE.pn, Srp(g,:),'rx');title('Rosenbluth theory (red x)'); xlabel('p'); ylabel('S')   
% %as fcn of mhu, for each slize of p
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
%     Xbouncefint = integral_dke_jd(gridDKE.dmhu,Xbouncef,2)/sum(gridDKE.dmhu); %integrate over mhu, pos n neg : /2
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
