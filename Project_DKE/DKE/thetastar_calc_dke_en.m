function [XXthetastar1,XXthetastar2,XXalpha] = thetastar_calc_dke_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE)
% Calculation of the critical poloidal angle value theta_star for runaway avalanches
%
% INPUT:
%
%   - equil: magnetic equilibrium structure
%   - gridDKE: grid structure
%   - Zmomcoef: momentum dynamics structure
%   - radialDKE: radial grid structure
%
% OUTPUT:
%
%   - XXthetastar1: poloidal angle value theta_star between 0 and pi
%       [np,nmhu,nr] on each flux surface ie [np,nmhu,length(B)]
%   - XXthetastar2: poloidal angle value theta_star between pi and 2*pi
%   -the sum sig [npn,nmhu,l]
%
% By E. Nilsson (CEA-IRFM, emelie.nilsson@cea.fr) Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker
% (CEA-DRFC, joan.decker@cea.fr)
%
method='spline';%'linear';
npn = size(gridDKE.XXmhu,1);
nmhu = size(gridDKE.XXmhu,2);
npsi=size(equilDKE.XBx,1); %nr of radial positions
theta=equilDKE.mtheta;
ntheta = length(theta);
xpsin = equilDKE.xpsin;
ap=equilDKE.ap;
Rp=equilDKE.Rp;Zp=equilDKE.Zp;
B0=equilDKE.xB0;
Bmax = max((sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2)),[],2)';
XXB0 = permute(repmat(B0',[1,npn,nmhu]), [2,3,1]);
XXBmax = permute(repmat(Bmax',[1,npn,nmhu]), [2,3,1]);
%
keyboard
mhu0min=sqrt(1-2./(Zmomcoef.gamma+1));
mhu0max=sqrt(1-2*B0./(Zmomcoef.gamma+1)./Bmax);
%
keyboard
mhuF = 700; %factor of increase in mhu grid points >=1
noP = mhuF*nmhu/2+1; %nr of cells on HALF the refined grid
%
gridmhu_S=NaN(npn,noP);
%
for ip=1:npn
    gridmhu_S(ip,:)=linspace(mhu0min(ip),mhu0max(ip),noP); %cells
end
XXmhuip=(gridmhu_S(:,1:(end-1))+gridmhu_S(:,(2:end)))./2;
dmhuip=gridmhu_S(:,(2:end))-gridmhu_S(:,1:(end-1));
%
XXmhuim = -fliplr(XXmhuip);
dmhuim = fliplr(dmhuip);
%
XXmhui = [XXmhuim,XXmhuip];
dmhui = [dmhuim, dmhuip];
%
XXgammai=permute(repmat(Zmomcoef.gamma,[noP*2-2,1]),[2,1]);
XXB0i=permute(repmat(B0',[1,npn,noP*2-2]), [2,3,1]);
XXBstarnew = 2*XXB0i./(1 + XXgammai)./(1 - XXmhui.^2);
%
XXBstarnew=permute(XXBstarnew,[3,1,2]);
%
Br=equilDKE.XBx;
Bz=equilDKE.XBy;
Bphi=equilDKE.XBphi;
for ipsi=1:npsi
    Bp=sqrt(Br(ipsi,:).^2+Bz(ipsi,:).^2);        %poloidal Bfield
    Bt=abs(Bphi(ipsi,:));                %toroidal Bfield
    B=sqrt(Bt.^2+Bp.^2);
    XXthetastar1new(ipsi,:,:)=interp1(B(1:(ntheta+1)/2),theta(1:(ntheta+1)/2),XXBstarnew(ipsi,:,:),method);     %calc theta_k* <pi
    XXthetastar2new(ipsi,:,:)=interp1(B((ntheta+1)/2:end),theta((ntheta+1)/2:end),XXBstarnew(ipsi,:,:),method);%calc theta_k* >pi
    [x1,y1,Bx1,By1,Bp1,dB1dtheta] = equilval_B_dB_en(equilDKE.equil_fit,equilDKE.xrho(ipsi),XXthetastar1new(ipsi,:,:));
    [x2,y2,Bx2,By2,Bp2,dB2dtheta] = equilval_B_dB_en(equilDKE.equil_fit,equilDKE.xrho(ipsi),XXthetastar2new(ipsi,:,:));
    XXalphaNew(ipsi,:,:)=B0(ipsi)^2.*equilDKE.xrho(ipsi)./abs(dB1dtheta)./Bp1 + B0(ipsi)^2.*equilDKE.xrho(ipsi)./abs(dB2dtheta)./Bp2;
end
%
keyboard
XXalpha=NaN(npsi,npn,nmhu);
yp=gridDKE.mhu(nmhu/2:end)+gridDKE.dmhup(nmhu/2:end)/2;
ym=gridDKE.mhu(1:nmhu/2+1)-gridDKE.dmhup(1:nmhu/2+1)/2;
%
for ipsi = 1:npsi;
    difINT=0;
    for ip = 1:npn;
        xp = gridmhu_S(ip,:);
        xm = -fliplr(xp);
        fp = XXalphaNew(ipsi,ip,noP:end);
        fm = XXalphaNew(ipsi,ip,1:noP-1);
        [XXalpha(ipsi,ip,1:nmhu/2), difINT1] = redistrib_jd(xm,fm,ym,1);
        [XXalpha(ipsi,ip,nmhu/2+1:end),difINT2] = redistrib_jd(xp,fp,yp,1);
        difINT=difINT1+difINT2+difINT;
    end
    disp(['The total relative difference on the integral is : ',num2str(difINT)])
end
%
%figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalphaNew(1,:,:)),'p','mhu','alphaNew',NaN,NaN,0,NaN,100); colorbar;
%
for ip=1:npn
    XalphaNewINT(ip) = integral_dke_jd(dmhui(ip,:),squeeze(XXalphaNew(1,ip,:))',2); %integrate over mhu, pos n neg : /2
end
figure
graph1D_jd(gridDKE.pn,XalphaNewINT,0,0,'p','XalphaNew','',NaN,NaN,NaN,'-','.','b')
%
figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalpha(1,:,:)),'p','mhu','alpha LUKE',NaN,NaN,0,NaN,100); colorbar;
%
figure;
Xalpha = squeeze(XXalpha(1,:,:));
Xalpha(isnan(Xalpha)) = 0;
Xalpha_int = integral_dke_jd(gridDKE.dmhu,Xalpha,2);
graph1D_jd(gridDKE.pn,Xalpha_int,0,0,'p','Xalpha LUKE','',NaN,NaN,NaN,'-','.','b')
legend(sprintf( '%s: %d', 'rho'));
%
figure
hold on
for ip=1:npn
plot(plot(XXmhui(ip,:),squeeze(XXalphaNew(1,ip,:)),'o'))
plot(gridDKE.mhu,squeeze(XXalpha(1,ip,:)),'r*')
end

% figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXthetastar1(1,:,:)),'p','mhu','theta^*_1',NaN,NaN,0,NaN,100); colorbar;
% figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXthetastar2(1,:,:)),'p','mhu','theta^*_2',NaN,NaN,0,NaN,100); colorbar;
% figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalpha(1,:,:)),'p','mhu','XXalpha',NaN,NaN,0,NaN,100); colorbar;
%
% figure; hold on
% for k=1:100
%     plot(XXthetastar2(1,:,k),'b*')
%  plot(XXthetastar2new(1,:,k),'r*')
% end 
% figure; hold on
% for k=1:50
% graph1D_jd(XXmhui(k,:),squeeze(XXalphaNew(1,k,:)),0,0,'mhu','alpha','',NaN,NaN,NaN,'none','.','r')
% end