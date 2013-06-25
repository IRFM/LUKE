function [XXS,XXthetastar] = avalanche_en(dkepath,dkeparam,dkedisplay,mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,equilDKE,radialDKE)
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
    [XXthetastar1,XXthetastar2,XXalpha] = thetastar_dke_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE);%calc the critical poloidal angle value theta_star for runaway avalanches
else
    XXalpha=ones(npsi,nmhu,npn);
    XXthetastar1=0;
    XXthetastar2=0;
end
%
keyboard
Lambd=mksa.lnc_e_ref;
ne_ref=mksa.ne_ref;
ne=equilDKE.xne/ne_ref;
beta=mksa.betath_ref;
ap=equilDKE.ap; % should be a_p like in the rest of LUKE, in literature it is Rp. Check this!
Rp=equilDKE.Rp;
nr=0.1*ne;
%
B0=equilDKE.xB0;
%B0=sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2);
%B0=min(sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2));
for l=1:npsi*0+1
  Srp(l,:)=1/(4*pi)*beta^2/log(Lambd)*ne(l)*nr(l)./(gridDKE.pn.*Zmomcoef.gamma.*(Zmomcoef.gamma-1).^2); %rosenbluth (S*)
end
Srp2=permute(repmat(Srp, [1,1,nmhu]),[1,3,2]);
if Zbouncecoef.XXlambda~=1
C=NaN(npsi,nmhu,npn);
for ipsi=1:npsi 
    for m=1:nmhu
    C(ipsi,m,:)=2/pi.*1/Rp./(Zmomcoef.gamma'+1)*B0(ipsi)./(Zbouncecoef.XXlambda(:,m).*Zbouncecoef.xqtilde(ipsi)).*abs(gridDKE.XXmhu(:,m))./(1-gridDKE.XXmhu(:,m).^2).^2; 
    end
end
else 
    C=ones(npsi,nmhu,npn);
end
%
XXS=Srp2.*C.*XXalpha; %<S()>
XXthetastar{1}=XXthetastar1;
XXthetastar{2}=XXthetastar2;
%
%display section:
if dkedisplay.display_mode>0
    if Zbouncecoef.XXlambda~=1
        l=1; %nr of the flux surface to be displayed
        keyboard
        figure;graph2D_jd(gridDKE.pn,gridDKE.XXmhu(l,:,1),squeeze(XXthetastar1(l,:,:))','p','mhu','theta^*_1',NaN,NaN,0,NaN,30); colorbar;
        figure;graph2D_jd(gridDKE.pn,gridDKE.XXmhu(l,:,1),squeeze(XXthetastar2(l,:,:))','p','mhu','theta^*_2',NaN,NaN,0,NaN,30); colorbar;
        %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),XXthetastar2(:,:,l),'p','mhu','theta^*_2',NaN,NaN,0,NaN,30);colorbar;
        figure;graph2D_jd(gridDKE.pn,gridDKE.XXmhu(l,:,1),squeeze(log(XXS(l,:,:)))','p','mhu','log(S)',NaN,NaN,0,NaN,30); colorbar;
        %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),log(XXS(:,:,l)),'p','mhu','log(S)',NaN,NaN,1,NaN,30);colorbar;
        %figure;graph2D_jd(Zmomcoef.xz.*gridDKE.XXmhu,Zmomcoef.xz.*sqrt(1-gridDKE.XXmhu.^2),log(XXS(:,:,l)),'p_{par}/p_{th}','p_{perp}/p_{th}','log(S)',NaN,NaN,1,NaN,30);colorbar;
        %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),C(:,:,l),'p/p_{th}','mhu','C',NaN,NaN,0,NaN,30);
        %figure;graph2D_jd(gridDKE.pn(:),gridDKE.XXmhu(1,:,l),XXalpha(:,:,l),'p/p_{th}','mhu','XXalpha',NaN,NaN,0,NaN,50);colorbar;
        %check that the thetas appear in the same place in matrix:
        figure;hold on
        for n=1:npsi
            graph1D_jd(1:nmhu,sum(~isnan(squeeze(XXthetastar1(n,:,:))')),0,0,'','','',NaN,NaN,NaN,'-','o','b')
            graph1D_jd(1:nmhu,sum(~isnan(squeeze(XXthetastar2(n,:,:))')),0,0,'column in theta matrix','nr of non NaN per row','',NaN,NaN,NaN,'-','.','r')
        end
%        figure;hold on %for all mhu plot theta*(p)
%         for k=1:nmhu
%             %graph1D_jd(Zmomcoef.xz,XXthetastar1(:,k,55)','p','theta');
%             %graph1D_jd(Zmomcoef.xz,XXthetastar2(:,k,55)','p','theta');
%             plot(Zmomcoef.xz,XXthetastar1(:,k,55),'b');
%             plot(Zmomcoef.xz,XXthetastar2(:,k,55),'r');
%         end
%        figure; graph2D_jd(gridDKE.pn(:).*gridDKE.XXmhu(1,:,l),gridDKE.pn(:).*sqrt(1-gridDKE.XXmhu(1,:,l).^2),XXthetastar1(:,:,l)'/pi,'p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_1/pi',NaN,NaN,0,NaN,60);colorbar;
%       figure; graph2D_jd(gridDKE.pn(:).*gridDKE.XXmhu(1,:,l),gridDKE.pn(:).*sqrt(1-gridDKE.XXmhu(1,:,l).^2),XXthetastar2(:,:,l)'/pi,'p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_2/pi',NaN,NaN,0,NaN,60);colorbar;
    end
    
%     figure
%     for g=1:npsi
%         XS=squeeze(XXS(g,:,:));
%         XS(isnan(XS)) = 0;
%         XS = integral_dke_jd(gridDKE.dmhu,XS,1)/2; %integrate over mhu, pos n neg : /2
%         semilogy(gridDKE.pn(:),XS,'.-')
%         %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
%         hold all,
%     end
        figure
    for g=l
        XS=XXS(g,:,:);
        XS(isnan(XS)) = 0;
        XS(g,:) = integral_dke_jd(gridDKE.dmhu,XS,1)/2; %integrate over mhu, pos n neg : /2
        semilogy(gridDKE.pn(:),XS,'.-')
        %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
        hold all,
    end
        semilogy(gridDKE.pn(:), Srp(g,:),'rx');title('Rosenbluth theory (red x)'); xlabel('p'); ylabel('S')
     
end
%
