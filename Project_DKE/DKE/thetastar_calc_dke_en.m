function [XXthetastar1,XXthetastar2,XXalpha] = thetastar_calc_dke_en(equilDKE,gridDKE,Zmomcoef,pnRA,dpnRA,npnRA, gammaRA)
% Calculation of the equilibrium dependent factor alpha of the bouncefactor C*alpha for runaway
% avalanches, by applying a refined mhu grid, then redistributing it on the
% LUKE mhu grid.
%
% INPUT:
%
%   - equil: magnetic equilibrium structure
%   - gridDKE: grid structure
%   - Zmomcoef: momentum dynamics structure
%
% OUTPUT:
%
%   - XXalpha: poloidal angle value theta_star between 0 and pi
%       [nr,np,nmhu] on each flux surface
%   - XXthetastar1: poloidal angle value theta_star between 0 and pi
%       [nr,np,nmhu] on each flux surface
%   - XXthetastar2: poloidal angle value theta_star between pi and 2*pi
%   -the sum sig [nr,npn,nmhu]
%
% By E. Nilsson (CEA-IRFM, emelie.nilsson@cea.fr) Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker
% (CEA-DRFC, joan.decker@cea.fr)
%
method='spline';%'linear';
%
npsi = gridDKE.nr;
npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
%
theta=equilDKE.mtheta;
ntheta = length(theta);
xpsin = equilDKE.xpsin;
ap=equilDKE.ap;
Rp=equilDKE.Rp;Zp=equilDKE.Zp;
B0=equilDKE.xB0;
Bmax = max((sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2)),[],2)';
XXB0 = permute(repmat(B0',[1,npnRA,nmhu]), [2,3,1]);
XXBmax = permute(repmat(Bmax',[1,npnRA,nmhu]), [2,3,1]);
%
mhu0min=repmat(sqrt(1-2./(gammaRA+1)),[3,1]);
for ipsi=1:npsi
    mhu0max(ipsi,:)=sqrt(1-2*B0(ipsi)./(gammaRA+1)./Bmax(ipsi));
end
%
for ipo = 2;
mhuF = ipo; %factor of increase in mhu grid points >=1
noP = mhuF*nmhu/2+1; %nr of cells on HALF the refined grid
%
gridmhu_S = NaN(npsi,npnRA,noP);
XXthetastar1new = NaN(npsi,npnRA,mhuF*nmhu);
XXthetastar2new = NaN(npsi,npnRA,mhuF*nmhu);
XXalphaNew = NaN(npsi,npnRA,mhuF*nmhu);
%
for ipsi=1:npsi
    for ip=1:npnRA
        gridmhu_S(ipsi,ip,:)=linspace(mhu0min(ipsi,ip),mhu0max(ipsi,ip),noP); % refined grid cells
    end
end
%
XXmhuip=(gridmhu_S(:,:,1:(end-1))+gridmhu_S(:,:,(2:end)))./2;
dmhuip=gridmhu_S(:,:,(2:end))-gridmhu_S(:,:,1:(end-1));
%
XXmhuim = -flipdim(XXmhuip,3);
dmhuim =  flipdim(dmhuip,3);
%
XXmhui = cat(3, XXmhuim, XXmhuip); %concatenate [-xi,0] and [0,xi]
dmhui = cat(3, dmhuim, dmhuip);
%
XXmhuiper = permute(XXmhui,[2,3,1]); %permute for Bstar calc
XXgammai=permute(repmat(gammaRA,[noP*2-2,1,npsi]),[2,1,3]);
XXB0i=permute(repmat(B0',[1,npnRA,noP*2-2]),[2,3,1]);
XXBstarnew = 2*XXB0i./(1 + XXgammai)./(1 - XXmhuiper.^2);
%
XXBstarnew=permute(XXBstarnew,[3,1,2]);
%
tic
Br=equilDKE.XBx;
Bz=equilDKE.XBy;
Bphi=equilDKE.XBphi;
for ipsi=1:npsi
    Bp=sqrt(Br(ipsi,:).^2+Bz(ipsi,:).^2);        %poloidal Bfield
    Bt=abs(Bphi(ipsi,:));                %toroidal Bfield
    B=sqrt(Bt.^2+Bp.^2);
    XXthetastar1new(ipsi,:,:)=interp1(B(1:(ntheta+1)/2),theta(1:(ntheta+1)/2),XXBstarnew(ipsi,:,:),method);     %calc theta_k* <pi
    XXthetastar2new(ipsi,:,:)=interp1(B((ntheta+1)/2:end),theta((ntheta+1)/2:end),XXBstarnew(ipsi,:,:),method);%calc theta_k* >pi
    %
    [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
    x1,dummy,dummy,dummy,dummy,y1,dummy,dummy,dummy,dummy,...
    dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
    Bx1,dBx1dtheta,dummy,dummy,dummy,By1,dBy1dtheta,dummy,dummy,dummy,...
    Bz1,dB1zdtheta,dummy,dummy,dummy,Bp1,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
    dummy,dummy,dummy] = equilval_yp(equilDKE.equil_fit,equilDKE.xrho(ipsi),XXthetastar1new(ipsi,:,:));
    %
    B1 = sqrt(Bx1.^2 + By1.^2 + Bz1.^2);
    dB1dtheta = (Bx1.*dBx1dtheta + By1.*dBy1dtheta + Bz1.*dB1zdtheta)./B1;
    %
    [dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
    x2,dummy,dummy,dummy,dummy,y2,dummy,dummy,dummy,dummy,...
    dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
    Bx2,dBx2dtheta,dummy,dummy,dummy,By2,dBy2dtheta,dummy,dummy,dummy,...
    Bz2,dB2zdtheta,dummy,dummy,dummy,Bp2,dummy,dummy,dummy,dummy,dummy,dummy,dummy,dummy,...
    dummy,dummy,dummy] = equilval_yp(equilDKE.equil_fit,equilDKE.xrho(ipsi),XXthetastar2new(ipsi,:,:));
    %
    B2 = sqrt(Bx2.^2 + By2.^2 + Bz2.^2);
    dB2dtheta = (Bx2.*dBx2dtheta + By2.*dBy2dtheta + Bz2.*dB2zdtheta)./B2;
    r1Rp=sqrt(x1.^2+y1.^2)./equilDKE.ap; %LUKE definition with ap
    r2Rp=sqrt(x2.^2+y2.^2)./equilDKE.ap;
    XXalphaNew(ipsi,:,:) = B0(ipsi)^2.*r1Rp./abs(dB1dtheta)./Bp1 + B0(ipsi)^2.*r2Rp./abs(dB2dtheta)./Bp2;
end
%
XXalpha=NaN(npsi,npnRA,nmhu);
XXthetastar1=NaN(npsi,npnRA,nmhu);
XXthetastar2=NaN(npsi,npnRA,nmhu);
%
yp=gridDKE.mhu(nmhu/2:end)+gridDKE.dmhup(nmhu/2:end)/2;
ym=gridDKE.mhu(1:nmhu/2+1)-gridDKE.dmhup(1:nmhu/2+1)/2;
%
for ipsi = 1:npsi;
    for ip = 1:npnRA;
        xp = squeeze(gridmhu_S(ipsi,ip,:))';
        xm = -fliplr(xp);
        fp = XXalphaNew(ipsi,ip,noP:end);
        fm = XXalphaNew(ipsi,ip,1:noP-1);
        XXalpha(ipsi,ip,1:nmhu/2) = redistrib_jd(xm,fm,ym,1);
        XXalpha(ipsi,ip,nmhu/2+1:end) = redistrib_jd(xp,fp,yp,1);
        fpt1 = XXthetastar1new(ipsi,ip,noP:end);
        fmt1 = XXthetastar1new(ipsi,ip,1:noP-1);
        XXthetastar1(ipsi,ip,1:nmhu/2) = redistrib_jd(xm,fmt1,ym,0);
        XXthetastar1(ipsi,ip,nmhu/2+1:end) = redistrib_jd(xp,fpt1,yp,0);
        fpt2 = XXthetastar2new(ipsi,ip,noP:end);
        fmt2 = XXthetastar2new(ipsi,ip,1:noP-1);
        XXthetastar2(ipsi,ip,1:nmhu/2) = redistrib_jd(xm,fmt2,ym,0);
        XXthetastar2(ipsi,ip,nmhu/2+1:end) = redistrib_jd(xp,fpt2,yp,0);
    end
end
%
dmhu = permute(repmat(gridDKE.dmhu',[1,1,npnRA,]), [2,3,1]);
XXalpha = XXalpha;
%
t(ipo) = toc;
%
for ip = 1:npnRA
    ind = find(XXalpha(1,ip,1:nmhu/2));
    alphmin(ipo,ip) = XXalpha(1,ip,ind(1));
    alphmax(ipo,ip) = XXalpha(1,ip,ind(end));
end
end
%plot the convergence test
% figure; graph1D_jd((1:ipo)*nmhu,alphmin,0,0,'nr of points in refined grid','alpha(ximin,p=const)','',NaN,NaN,NaN,'-','.','b')
% figure; graph1D_jd((1:ipo)*nmhu,alphmax,0,0,'nr of points in refined grid','alpha(ximax,p=const)','',NaN,NaN,NaN,'-','.','r')
% figure; graph1D_jd((1:ipo)*nmhu,t,0,0,'nr of points in refined grid','time (s) for calc.','',NaN,NaN,NaN,'-','.','b')
%
%figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalphaNew(1,:,:)),'p','mhu','alphaNew',NaN,NaN,0,NaN,100); colorbar;
%
figure
hold on
for ipsi=1:npsi
    for ip=1:npnRA
        XalphaNewINT(ip) = integral_dke_jd(dmhui(ipsi,ip,:),squeeze(XXalphaNew(ipsi,ip,:))',2); %integrate over mhu
    end
    graph1D_jd(pnRA,XalphaNewINT,0,0,'p','XalphaNew','',NaN,NaN,NaN,'-','.','b')
end
%
figure;graph2D_jd(pnRA,gridDKE.mhu,squeeze(XXalpha(1,:,:)),'p','mhu','alpha LUKE',NaN,NaN,0,NaN,100); colorbar;
%
figure;
hold on
for ipsi=1:npsi
Xalpha = squeeze(XXalpha(ipsi,:,:));
Xalpha(isnan(Xalpha)) = 0;
Xalpha_int = integral_dke_jd(gridDKE.dmhu,Xalpha,2);
graph1D_jd(pnRA,Xalpha_int,0,0,'p','Xalpha LUKE','',NaN,NaN,NaN,'-','.','b')
end
hold off
%
% figure
% hold on
% for ip=1:npn
% plot(plot(XXmhui(1,ip,:),squeeze(XXalphaNew(1,ip,:)),'o'))
% plot(gridDKE.mhu,squeeze(XXalpha(1,ip,:)),'r*')
% end

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