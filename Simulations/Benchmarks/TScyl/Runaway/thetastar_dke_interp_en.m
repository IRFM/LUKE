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
%Bmax=sqrt(equilDKE.XBx(:,(ntheta+1)/2).^2 +
%equilDKE.XBy(:,(ntheta+1)/2).^2 + equilDKE.XBphi(:,(ntheta+1)/2).^2);
Bmax = max((sqrt(equilDKE.XBx.^2 + equilDKE.XBy.^2 + equilDKE.XBphi.^2)),[],2)';
XXB0 = permute(repmat(B0',[1,npn,nmhu]), [2,3,1]);
XXBmax = permute(repmat(Bmax',[1,npn,nmhu]), [2,3,1]);
%
XXBstar = 2*XXB0./(1 + Zmomcoef.XXgamma)./(1 - gridDKE.XXmhu.^2);
XXmaskBstar = XXBstar>=(XXB0) & XXBstar<(XXBmax);
XXmaskBstar2=XXBstar>=(XXB0) & XXBstar<(XXB0);
%
[I,J,K]=ind2sub(size(XXmaskBstar2), find(XXmaskBstar2>0));
XXBstar2=zeros(npn,nmhu,npsi);
for ik=1:length(I)
    XXBstar2(I(ik),J(ik),K(ik))=2*B0(K(ik))./(1 + (Zmomcoef.gamma(I(ik))-1*(gridDKE.dpn(I(ik))/10)*Zmomcoef.xz(I(ik),1)/(2*Zmomcoef.gamma(I(ik)))))./(1 - (gridDKE.mhu(J(ik))-0*sign(gridDKE.mhu(J(ik)).*gridDKE.dmhu(J(ik)+1)/2)).^2);
% g=Zmomcoef.gamma(I(ik))
% gcorr=Zmomcoef.gamma(I(ik))-1*(gridDKE.dpn(I(ik))/10)*Zmomcoef.xz(I(ik),1)/(2*Zmomcoef.gamma(I(ik)))
end
XXmaskBstar2 = double(XXmaskBstar2);
%XXBstar2=permute(XXBstar2,[3,1,2]);
XXmaskBstar = double(XXmaskBstar);
%XXmaskBstar(XXmaskBstar==0) = NaN;
XXBstar=(XXBstar.*XXmaskBstar+XXBstar2.*XXmaskBstar2);
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