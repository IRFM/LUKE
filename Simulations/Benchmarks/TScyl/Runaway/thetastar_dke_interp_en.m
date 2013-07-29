function [XXthetastar1,XXthetastar2,XXalpha] = thetastar_dke_interp_en(dkepath,dkeparam,dkedisplay,equilDKE,gridDKE,Zmomcoef,ohm,radialDKE)
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
mhu0min=sqrt(1-2./(Zmomcoef.gamma+1));
mhu0max=sqrt(1-2*B0./(Zmomcoef.gamma+1)./Bmax);
%
for ip=1:npn
    [dummy,I]=min(abs(gridDKE.mhu-mhu0min(ip)))
    mhu0minLUKE(ip)=gridDKE.mhu(I);
    min_index(ip)=I;
    [dummy,J]=min(abs(gridDKE.mhu-mhu0max(ip)))
    max_index(ip)=J;
    mhu0maxLUKE(ip)=gridDKE.mhu(J);
    gridmhu_S(ip,:)=linspace(mhu0min(ip),mhu0max(ip),nmhu/2+1); %cells
    %
    for im=1:(length(gridmhu_S)-1) %half grid
        XXmhuip(ip,im)=(gridmhu_S(ip,im)+gridmhu_S(ip,im+1))./2;
        dmhuip(ip,im)=gridmhu_S(ip,im+1)-gridmhu_S(ip,im);
    end
    %
end
%
XXmhuim = -fliplr(XXmhuip);
dmhuim = fliplr(dmhuip);
%
XXmhui = [XXmhuim,XXmhuip];
dmhui = [dmhuim, dmhuip];
XXBstarnew = 2*XXB0./(1 + Zmomcoef.XXgamma)./(1 - XXmhui.^2);
%
XXBstarnew=permute(XXBstarnew,[3,1,2]);
%
keyboard
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
%XalphaNewINT = integral_dke_jd(dmhui(25,:),squeeze(XXalphaNew(1,25,:))',2)./sum(dmhui(25,:)); %integrate over mhu, pos n neg : /2
figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalphaNew(1,:,:)),'p','mhu','alphaNew',NaN,NaN,0,NaN,100); colorbar;
for ip=1:npn
    XalphaNewINT(ip) = integral_dke_jd(dmhui(ip,:),squeeze(XXalphaNew(1,ip,:))',2); %integrate over mhu, pos n neg : /2
end
figure
graph1D_jd(gridDKE.pn,XalphaNewINT,0,0,'p','XalphaNew','',NaN,NaN,NaN,'-','.','b')
%XalphaNewINT = integral_dke_jd(dmhui,squeeze(XXalphaNew(1,:,:)),2)./sum(dmhui(25,:)); %integrate over mhu, pos n neg : /2
%
b=1;

ind=0;


%%
%put points back onto the LUKE grid, no 'cell on edge' effect taken into
%account
alphajj=NaN(1,npn,nmhu);

for ip = 1:npn
    for ik=1:(max_index(ip)+1-min_index(ip))
        dxij = -gridDKE.dmhu(ip)/2 +gridDKE.dmhu(ip+ik)*(ik-1);
        dxij2 = gridDKE.dmhu(ip)/2 + gridDKE.dmhu(ip+ik)*(ik-1);
        dmhuif = ones(1,nmhu);
        dmhuif = dmhui(ip,:).*dmhuif;
        alphajj(1,ip,min_index(ip)+ik-1) = sum(XXalphaNew(1,ip,(gridDKE.mhu(min_index(ip))+dxij)<=XXmhui(ip,:) ...
            & XXmhui(ip,:) <=(gridDKE.mhu(min_index(ip))+dxij2))*dmhuif(min_index(ip)+ik-1))/gridDKE.dmhu(min_index(ip)+ik-1);
        alphajj(1,ip,nmhu-min_index(ip)+1-ik+1) = sum(XXalphaNew(1,ip,(gridDKE.mhu(nmhu-min_index(ip)+1)-dxij2)<=XXmhui(ip,:) ...
            & XXmhui(ip,:) <=(gridDKE.mhu(nmhu-min_index(ip)+1)-dxij))*dmhuif(nmhu-min_index(ip)+1))/gridDKE.dmhu(nmhu-min_index(ip)+1);
    end
end

%%
%try to divide the cells on the edge correctly
alphajj=NaN(1,npn,nmhu);
b=1;
ind=1;
for ip = 1:npn
    for ik=1:(max_index(ip)+1-min_index(ip))
        dxij = -gridDKE.dmhu(ip)/2 +gridDKE.dmhu(ip+ik)*(ik-1);
        dxij2 = gridDKE.dmhu(ip)/2 + gridDKE.dmhu(ip+ik)*(ik-1);
        edge_test = (abs(mhu0minLUKE(ip)+dxij2)>(XXmhui(ip,:)-dmhui(ip,ik)/2)).*(abs(mhu0minLUKE(ip)+dxij2)<(XXmhui(ip,:)+dmhui(ip,ik)/2)); %check if a cell is in 2 LUKE cells
        dmhuif = ones(1,nmhu);
        dmhuif(1,ind) = abs(b);
        dmhuif(1,nmhu-ind+1) = abs(b);
        ind = find(edge_test>0);
        a = abs(mhu0minLUKE(ip)+dxij2-(XXmhui(ip,ind)+dmhui(ip,ind)/2))/dmhui(ip,ind); %fraction belonging to 
        dmhuif(1,ind) = 1-a;
        dmhuif(1,nmhu-ind+1) = 1-a;
        dmhuif = dmhui(ip,:).*dmhuif;
        xip=(gridDKE.mhu(min_index(ip))+dxij)<=XXmhui(ip,:) & XXmhui(ip,:) <=(gridDKE.mhu(min_index(ip))+dxij2);
        xim=(gridDKE.mhu(nmhu-min_index(ip)+1)-dxij2)<=XXmhui(ip,:) & XXmhui(ip,:) <=(gridDKE.mhu(nmhu-min_index(ip)+1)-dxij);
       % 
       alphajj(1,ip,min_index(ip)+ik-1) = sum(XXalphaNew(1,ip,(gridDKE.mhu(min_index(ip))+dxij)<=XXmhui(ip,:) & XXmhui(ip,:) <=(gridDKE.mhu(min_index(ip))+dxij2))*dmhuif(min_index(ip)+ik-1))/gridDKE.dmhu(min_index(ip)+ik-1);
       alphajj(1,ip,nmhu-min_index(ip)+1-ik+1) = sum(XXalphaNew(1,ip,(gridDKE.mhu(nmhu-min_index(ip)+1)-dxij2)<=XXmhui(ip,:) & XXmhui(ip,:) <=(gridDKE.mhu(nmhu-min_index(ip)+1)-dxij))*dmhuif(nmhu-min_index(ip)+1))/gridDKE.dmhu(nmhu-min_index(ip)+1);
       %
       % alphajj(1,ip,min_index(ip)+ik-1) = sum(squeeze(XXalphaNew(1,ip,xip)).*dmhuif(ik:ik+sum(xip>0)-1)')/gridDKE.dmhu(min_index(ip)+ik-1);
       % alphajj(1,ip,nmhu-min_index(ip)+1-ik+1) = sum(squeeze(XXalphaNew(1,ip,xim)).*dmhuif(ik:nmhu-min_index(ip)+1-ik+1+sum(xim>0)-1)')/gridDKE.dmhu(nmhu-min_index(ip)+1-ik+1);
        b =a;
    end
end
%
figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(alphajj(1,:,:)),'p','mhu','alphajj',NaN,NaN,0,NaN,100); colorbar;
%
figure;
Xalphajj = squeeze(alphajj(1,:,1:100));
Xalphajj(isnan(Xalphajj)) = 0;
Xalphajjint = integral_dke_jd(gridDKE.dmhu,Xalphajj,2);
graph1D_jd(gridDKE.pn,Xalphajjint,0,0,'p','Xalphajj','',NaN,NaN,NaN,'-','.','b')
legend(sprintf( '%s: %d', 'rho'));
%nmhu/2+2+(nmhu/2-min_index(ip)-1)+ik-1
%nmhu-min_index(ip)+1)
%
XXBstar = 2*XXB0./(1 + Zmomcoef.XXgamma)./(1 - gridDKE.XXmhu.^2);
XXmaskBstar = XXBstar>=(XXB0) & XXBstar<(XXBmax);
% XXmaskBstar2=XXBstar>=(XXB0) & XXBstar<(XXB0);
% %
% [I,J,K]=ind2sub(size(XXmaskBstar2), find(XXmaskBstar2>0));
% XXBstar2=zeros(npn,nmhu,npsi);
% for ik=1:length(I)
%     XXBstar2(I(ik),J(ik),K(ik))=2*B0(K(ik))./(1 + (Zmomcoef.gamma(I(ik))-1*(gridDKE.dpn(I(ik))/10)*Zmomcoef.xz(I(ik),1)/(2*Zmomcoef.gamma(I(ik)))))./(1 - (gridDKE.mhu(J(ik))-0*sign(gridDKE.mhu(J(ik)).*gridDKE.dmhu(J(ik)+1)/2)).^2);
% % g=Zmomcoef.gamma(I(ik))
% % gcorr=Zmomcoef.gamma(I(ik))-1*(gridDKE.dpn(I(ik))/10)*Zmomcoef.xz(I(ik),1)/(2*Zmomcoef.gamma(I(ik)))
% end
%XXmaskBstar2 = double(XXmaskBstar2);
%XXBstar2=permute(XXBstar2,[3,1,2]);
XXmaskBstar = double(XXmaskBstar);
%XXmaskBstar(XXmaskBstar==0) = NaN;
XXBstar=(XXBstar.*XXmaskBstar);%+XXBstar2.*XXmaskBstar2);
XXBstar(XXBstar==0) = NaN;
XXBstar=permute(XXBstar,[3,1,2]);
%
XXthetastar1=NaN(npsi,npn,nmhu);
XXthetastar2=NaN(npsi,npn,nmhu);
XXalpha=NaN(npsi,npn,nmhu);
tic
    Br=equilDKE.XBx;
    Bz=equilDKE.XBy;
    Bphi=equilDKE.XBphi;
    for ipsi=1:npsi
        Bp=sqrt(Br(ipsi,:).^2+Bz(ipsi,:).^2);        %poloidal Bfield
        Bt=abs(Bphi(ipsi,:));                %toroidal Bfield
        B=sqrt(Bt.^2+Bp.^2);
        XXthetastar1(ipsi,:,:)=interp1(B(1:(ntheta+1)/2),theta(1:(ntheta+1)/2),XXBstar(ipsi,:,:),method);     %calc theta_k* <pi
        XXthetastar2(ipsi,:,:)=interp1(B((ntheta+1)/2:end),theta((ntheta+1)/2:end),XXBstar(ipsi,:,:),method);%calc theta_k* >pi
        [x1,y1,Bx1,By1,Bp1,dB1dtheta] = equilval_B_dB_en(equilDKE.equil_fit,equilDKE.xrho(ipsi),XXthetastar1(ipsi,:,:));
        [x2,y2,Bx2,By2,Bp2,dB2dtheta] = equilval_B_dB_en(equilDKE.equil_fit,equilDKE.xrho(ipsi),XXthetastar2(ipsi,:,:));
        XXalpha(ipsi,:,:)=B0(ipsi)^2.*equilDKE.xrho(ipsi)./abs(dB1dtheta)./Bp1 + B0(ipsi)^2.*equilDKE.xrho(ipsi)./abs(dB2dtheta)./Bp2;
    end
toc
% figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXthetastar1(1,:,:)),'p','mhu','theta^*_1',NaN,NaN,0,NaN,100); colorbar;
% figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXthetastar2(1,:,:)),'p','mhu','theta^*_2',NaN,NaN,0,NaN,100); colorbar;
% figure;graph2D_jd(gridDKE.pn,gridDKE.mhu,squeeze(XXalpha(1,:,:)),'p','mhu','XXalpha',NaN,NaN,0,NaN,100); colorbar;
%
% figure; hold on
% for k=1:100
%     plot(XXthetastar2(1,:,k),'b*')
%  plot(XXthetastar2new(1,:,k),'r*')
% end 
figure; hold on
for k=1:50
graph1D_jd(gridDKE.mhu,squeeze(XXalpha(1,k,:)),0,0,'mhu','alpha','',NaN,NaN,NaN,'none','.','b')
graph1D_jd(XXmhui(k,:),squeeze(XXalphaNew(1,k,:)),0,0,'mhu','alpha','',NaN,NaN,NaN,'none','.','r')
end