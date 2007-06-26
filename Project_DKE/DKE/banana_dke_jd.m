function [YTdt,YTmask,YTF,YTPSIB,YTmhu0,YTmhu,YTx,xymaskT,nt2] = banana_dke_jd(ymhu0,ap,Xx,Xy,XBx,XBy,XBphi);
%
% Calculation of the poloidal positions of the two banana tips for accurate numerical integration over the poloidal angle
% close to the trapped/passing limit. All output quantities are given on this new grid 
%   (see the notice for explanations concerning notations)
%
%   INPUT:
%
%       - ymhu0: pitch-angle grid
%       - Plasma magnetic equilibrium parameters 
%
%   OUTPUT:
%   
%       - YTdt: dtheta
%       - YTmask: Mask on the integration over B
%       - YTF: B*[(R-Rp)^2+(Z-Zp)^2]/|BR*(Z-Zp)-BZ*(R-Rp)|/Rp, integrant that appears in the numerical bounce integrals (see notice)
%       - YTPSIB: Ratio of B-field to its minimum on flux surface, B/Bmin
%       - YTmhu0: Pitch-angle at Bmin
%       - YTmhu: Pitch-angle cosine of (psi,theta,mhu) at B
%       - YTR: Major radius of the flux surface (psi,theta) at B
%       - xymaskT: Trapped domain
%       - nt2: number of points in the new theta grid
%
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) 
%
[np,nt] = size(Xx);
nmhu = length(ymhu0);
%
theta = linspace(0,2*pi,nt);%Poloidal angular grid
%
XBT = abs(XBphi);%Toroidal B-field
XBP = sqrt(XBx.^2 + XBy.^2);%Poloidal B-field
XB = sqrt(XBT.^2 + XBP.^2);%Total B-field
%
xBmin = min(XB.'); % Minimum of B on FS
xBmax = max(XB.'); % Maximum of B on FS
%
y1mmhu02 = 1 - ymhu0.^2;
y1mmhu02(y1mmhu02 == 0) = eps;%Avoid numerical singularities
xyBb = xBmin.'*(1./y1mmhu02);%B-field at turning point 
%
xmhu0T = sqrt(1 - xBmin./xBmax);%Pitch-angle at the trapped-passing boundary
%
xymhu0 = repmat(ymhu0,[np,1]);
xymhu0T = repmat(xmhu0T.',[1,nmhu]);
%
xymaskT = abs(xymhu0) <= xymhu0T - 10*eps;%Select trapped particles (the eps is for access to very core plasma calculations)
%
XF = zeros(nt,np,5);
XF(:,:,1) = XBx.';
XF(:,:,2) = XBy.';
XF(:,:,3) = XBphi.';
XF(:,:,4) = Xx.';
XF(:,:,5) = Xy.';
%
[xythetaT1,xythetaT2,xyF1,xyF2] = interp_theta_jd(theta,XBx.',XBy.',XBphi.',xyBb,XF);
%
xythetaT1(~xymaskT) = theta(1);
xythetaT2(~xymaskT) = theta(1);
%
if any(isnan(xythetaT1(:))) | any(isnan(xythetaT2(:))),
    error('The theta interpolation failed.');
end
%
Ytheta = repmat(theta.',[1,np,nmhu]);
%
YBx = repmat(XBx.',[1,1,nmhu]);	
YBy = repmat(XBy.',[1,1,nmhu]);
YBphi = repmat(XBphi.',[1,1,nmhu]);
Yx = repmat(Xx.',[1,1,nmhu]);
Yy = repmat(Xy.',[1,1,nmhu]);
%
xyBxT1 = xyF1(:,:,1);
xyBxT2 = xyF2(:,:,1);
%
xyByT1 = xyF1(:,:,2);
xyByT2 = xyF2(:,:,2);
%
xyBphiT1 = xyF1(:,:,3);
xyBphiT2 = xyF2(:,:,3);
%
xyxT1 = xyF1(:,:,4);
xyxT2 = xyF2(:,:,4);
%
xyyT1 = xyF1(:,:,5);
xyyT2 = xyF2(:,:,5);
%
xyBxT1(~xymaskT) = YBx(1,~xymaskT);
xyBxT2(~xymaskT) = YBx(1,~xymaskT);
%
xyByT1(~xymaskT) = YBy(1,~xymaskT);
xyByT2(~xymaskT) = YBy(1,~xymaskT);
%
xyBphiT1(~xymaskT) = YBphi(1,~xymaskT);
xyBphiT2(~xymaskT) = YBphi(1,~xymaskT);
%
xyxT1(~xymaskT) = Yx(1,~xymaskT);
xyxT2(~xymaskT) = Yx(1,~xymaskT);
%
xyyT1(~xymaskT) = Yy(1,~xymaskT);
xyyT2(~xymaskT) = Yy(1,~xymaskT);
%
YTtheta = [Ytheta;reshape(xythetaT1,[1,np,nmhu]);reshape(xythetaT2,[1,np,nmhu])];
%
YTBx = [YBx;reshape(xyBxT1,[1,np,nmhu]);reshape(xyBxT2,[1,np,nmhu])];
YTBy = [YBy;reshape(xyByT1,[1,np,nmhu]);reshape(xyByT2,[1,np,nmhu])];
YTBphi = [YBphi;reshape(xyBphiT1,[1,np,nmhu]);reshape(xyBphiT2,[1,np,nmhu])];
YTx = [Yx;reshape(xyxT1,[1,np,nmhu]);reshape(xyxT2,[1,np,nmhu])];
YTy = [Yy;reshape(xyyT1,[1,np,nmhu]);reshape(xyyT2,[1,np,nmhu])];
%
clear YBx YBy YBphi Yx Yy Ytheta
%
nt2 = nt + 2;%Two poloidal angle values are added corresponding to banana tips
%
% Sort according to theta
%
[YTtheta,YTiT] = sort(YTtheta);
%
csum1 = repmat(0:np-1,[nt2,1,nmhu]);
csum2 = repmat(reshape(0:nmhu-1,[1,1,nmhu]),[nt2,np,1]);
YTiT = YTiT + nt2*(csum1 + np*csum2);
%
YTBx = YTBx(YTiT);
YTBy = YTBy(YTiT);
YTBphi = YTBphi(YTiT);
YTx = YTx(YTiT);
YTy = YTy(YTiT);
%
% Half grid in theta for integration
%
YTBx = (YTBx(1:nt2-1,:,:) + YTBx(2:nt2,:,:))/2;
YTBy = (YTBy(1:nt2-1,:,:) + YTBy(2:nt2,:,:))/2;
YTBphi = (YTBphi(1:nt2-1,:,:) + YTBphi(2:nt2,:,:))/2;
YTx = (YTx(1:nt2-1,:,:) + YTx(2:nt2,:,:))/2;
YTy = (YTy(1:nt2-1,:,:) + YTy(2:nt2,:,:))/2;
%
YTB = sqrt(YTBx.^2 + YTBy.^2 + YTBphi.^2); 
%
nt2 = nt2 - 1;
%
YTBmin = repmat(xBmin,[nt2,1,nmhu]);
YTmhu0 = repmat(reshape(ymhu0,[1,1,nmhu]),[nt2,np,1]);
%
YTPSIB = YTB./YTBmin;%Ratio of B-field to its minimum on flux surface
YTBb =  repmat(reshape(xyBb,[1,np,nmhu]),[nt2,1,1]);%B-field at turning point
%
YTmask = YTB < YTBb;%Mask on the integration over B
%
clear YTBb
%
YTmhu = sign(YTmhu0).*sqrt(1 - YTPSIB.*(1 - YTmhu0.^2));%Pitch-angle cosine of (psi,theta,mhu)
YTmhu(~YTmask) = 0;
YTmhu(YTmhu == 0) = eps;%Avoid numerical singularities
YTF = YTB.*(YTx.^2 + YTy.^2).*YTmhu0./abs(YTBx.*YTy - YTBy.*YTx)./YTmhu/ap;
YTF(find(isinf(YTF))) = 1;%To avoid Inf and NaN
YTdt = diff(YTtheta);
%