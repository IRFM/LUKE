function [XXS,XXthetastar1,XXthetastar2]=avalanche_en(mksa,gridDKE,Zmomcoef,Zbouncecoef,ohm,equil,equilDKE,radialDKE,display)
%
% This function calculates the avalanche source term
%
% INPUT
%    - gridDKE: grid structure, XXmhu
%    - equil: axisymmetric toroidal magnetic equilibrium
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
display_mode = display.display_mode;
npn = size(gridDKE.XXmhu,1);
nmhu = size(gridDKE.XXmhu,2);
npsi=length(equil.ptBx);
%
 if Zbouncecoef.XXlambda~=1
    [XXthetastar1,XXthetastar2,XXsig] = thetastar_dke_en(equilDKE,gridDKE,Zmomcoef,ohm,equil,radialDKE);%calc the critical poloidal angle value theta_star for runaway avalanches
else
    XXsig=ones(npn,nmhu,npsi);
    XXthetastar1=0;
    XXthetastar2=0;
end
%
Lambd=mksa.lnc_e_ref;
ne_ref=mksa.ne_ref;
ne=equil.pne/ne_ref;
beta=mksa.betath_ref;
ap=equilDKE.ap; % should be a_p like in the rest of LUKE, in literature it is Rp. Check this!
Rp=equil.Rp;
nr=0.1*ne;
%
B0=sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2);
%B0=min(sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2));
for l=1:npsi
  Srp(:,l)=1/(4*pi)*beta^2/log(Lambd)*ne(l)*nr(l)./(Zmomcoef.xz(:,1).*Zmomcoef.XXgamma(:,1).*(Zmomcoef.XXgamma(:,1)-1).^2); %rosenbluth (S*)
end
Srp2=permute(repmat(Srp, [1,1,nmhu]),[1,3,2]);
if Zbouncecoef.XXlambda~=1
C=NaN(npn,nmhu,npsi);
for l=1:npsi 
    for m=1:nmhu
    C(:,m,l)=2/pi.*1/Rp./(Zmomcoef.XXgamma(:,m)+1)*B0(l)./(Zbouncecoef.XXlambda(:,m).*Zbouncecoef.xqtilde).*abs(gridDKE.XXmhu(:,m))./(1-gridDKE.XXmhu(:,m).^2).^2; 
    end
end
else 
    C=ones(npn,nmhu,npsi);
end
%
XXS=Srp2.*C.*XXsig; %<S()>
%
%display section:
if display_mode>0
    if Zbouncecoef.XXlambda~=1
        l=round(display.rho_display*npsi); %nr of the flux surface to be displayed
        figure;graph2D_jd(Zmomcoef.xz(:,1),gridDKE.XXmhu(1,:),XXthetastar1(:,:,l),'p','mhu','theta^*_1',NaN,NaN,0,NaN,30); colorbar;
        figure;graph2D_jd(Zmomcoef.xz(:,1),gridDKE.XXmhu(1,:),XXthetastar2(:,:,l),'p','mhu','theta^*_2',NaN,NaN,0,NaN,30);colorbar;
        figure;graph2D_jd(Zmomcoef.xz(:,1),gridDKE.XXmhu(1,:),log(XXS(:,:,l)),'p','mhu','log(S)',NaN,NaN,1,NaN,30);colorbar;
        %figure;graph2D_jd(Zmomcoef.xz.*gridDKE.XXmhu,Zmomcoef.xz.*sqrt(1-gridDKE.XXmhu.^2),log(XXS(:,:,l)),'p_{par}/p_{th}','p_{perp}/p_{th}','log(S)',NaN,NaN,1,NaN,30);colorbar;
        figure;graph2D_jd(Zmomcoef.xz(:,1),gridDKE.XXmhu(1,:),C(:,:,l),'p/p_{th}','mhu','C',NaN,NaN,0,NaN,30);
        figure;graph2D_jd(Zmomcoef.xz(:,1),gridDKE.XXmhu(1,:),log(XXsig(:,:,l)),'p/p_{th}','mhu','log(XXsig)',NaN,NaN,0,NaN,50);
        %check that the thetas appear in the same place in matrix:
        figure;hold on
        for n=1:npsi
            graph1D_jd(1:length(sum(~isnan(XXthetastar1(:,:,n)))),sum(~isnan(XXthetastar1(:,:,n))),0,0,'','','',NaN,NaN,NaN,'-','o','b')
            graph1D_jd(1:length(sum(~isnan(XXthetastar2(:,:,n)))),sum(~isnan(XXthetastar2(:,:,n))),0,0,'row in theta matrix','nr of non NaN per column','',NaN,NaN,NaN,'-','.','r')
        end
%        figure;hold on %for all mhu plot theta*(p)
%         for k=1:nmhu
%             %graph1D_jd(Zmomcoef.xz,XXthetastar1(:,k,55)','p','theta');
%             %graph1D_jd(Zmomcoef.xz,XXthetastar2(:,k,55)','p','theta');
%             plot(Zmomcoef.xz,XXthetastar1(:,k,55),'b');
%             plot(Zmomcoef.xz,XXthetastar2(:,k,55),'r');
%         end
  %      figure; graph2D_jd(Zmomcoef.xz.*gridDKE.XXmhu,Zmomcoef.xz.*sqrt(1-gridDKE.XXmhu.^2),XXthetastar1(:,:,l)'/pi,'p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_1/pi',NaN,NaN,0,NaN,60);colorbar;
  %      figure; graph2D_jd(Zmomcoef.xz.*gridDKE.XXmhu,Zmomcoef.xz.*sqrt(1-gridDKE.XXmhu.^2),XXthetastar2(:,:,l)'/pi,'p_{par}/p_{th}','p_{perp}/p_{th}','theta^*_2/pi',NaN,NaN,0,NaN,60);colorbar;
    end
    
    figure
    for g=1:npsi
        XS=XXS(:,:,g);
        XS(isnan(XS)) = 0;
        XS(:,g) = integral_dke_jd(gridDKE.dmhu,XS,2)/2; %integrate over mhu, pos n neg : /2
        semilogy(Zmomcoef.xz,XS(:,g),'.-')
        %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
        hold all,
    end
        figure
    for g=l
        XS=XXS(:,:,g);
        XS(isnan(XS)) = 0;
        XS(:,g) = integral_dke_jd(gridDKE.dmhu,XS,2)/2; %integrate over mhu, pos n neg : /2
        semilogy(Zmomcoef.xz(:,1),XS(:,g),'.-')
        %graph1D_jd(Zmomcoef.xz,XS,0,1,'S_{bounce}','p','S on each flux surface',NaN,NaN,NaN,'-','.')
        hold all,
    end
        semilogy(Zmomcoef.xz(:,1), Srp(:,g),'rx');title('Rosenbluth theory (red x)'); xlabel('p'); ylabel('S')
     
end
%