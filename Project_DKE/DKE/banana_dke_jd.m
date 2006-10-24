function [YMdt,YMmask,YMF,YMPSIB,YMmhu0,YMmhu,YMx,xymaskT,nm2] = banana_dke_jd(ymhu0,Rp,ap,Xx,Xy,XBx,XBy,XBphi);
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
%       - YMdt: dtheta
%       - YMmask: Mask on the integration over B
%       - YMF: B*[(R-Rp)^2+(Z-Zp)^2]/|BR*(Z-Zp)-BZ*(R-Rp)|/Rp, integrant that appears in the numerical bounce integrals (see notice)
%       - YMPSIB: Ratio of B-field to its minimum on flux surface, B/Bmin
%       - YMmhu0: Pitch-angle at Bmin
%       - YMmhu: Pitch-angle cosine of (psi,theta,mhu) at B
%       - YMR: Major radius of the flux surface (psi,theta) at B
%       - xymaskT: Trapped domain
%       - nm2: number of points in the new theta grid
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
xBmin = min(XB'); % Minimum of B on FS
xBmax = max(XB'); % Maximum of B on FS
%
YB = repmat(XB',[1,1,nmhu]);
%
y1mmhu02 = 1 - ymhu0.^2;
y1mmhu02(y1mmhu02 == 0) = eps;%Avoid numerical singularities
xyBb = xBmin'*(1./y1mmhu02);%B-field at turning point 
%
YBmin = repmat(xBmin,[nt,1,nmhu]);
Y1mmhu02 = repmat(reshape(y1mmhu02,[1,1,nmhu]),[nt,np,1]);
YBb = YBmin./Y1mmhu02;%B-field at turning point
%
clear Y1mmhu02 YBmin
%
Y1Bb = reshape(xyBb,[1,np,nmhu]);%B-field at turning point
Y1B0 = YB(1,:,:);%B-field at theta = 0
%
Y1maskg = Y1Bb >= Y1B0; 
Y1maskl = Y1Bb < Y1B0;
%
xmhu0T = sqrt(1 - xBmin./xBmax);%Pitch-angle at the trapped-passing boundary
%
xymhu0 = repmat(ymhu0,[np,1]);
xymhu0T = repmat(xmhu0T',[1,nmhu]);
%
xymaskT = abs(xymhu0) <= xymhu0T - 10*eps;%Select trapped particles (the eps is for access to very core plasma calculations)
%
YCS = cumsum(ones(nt,np,nmhu));
%
Yimin = (YB <= YBb).*YCS;
Yimax = (YB > YBb).*YCS;
%
clear YBb
%
Yimin(Yimin == 0) = NaN;
Yimax(Yimax == 0) = NaN;
%
xyi1max = reshape(min(Yimin).*Y1maskl + min(Yimax).*Y1maskg,[np,nmhu]);
xyi1min = reshape(min(Yimin - 1).*Y1maskl + min(Yimax - 1).*Y1maskg,[np,nmhu]);
xyi2min = reshape(max(Yimin).*Y1maskl + max(Yimax).*Y1maskg,[np,nmhu]);
xyi2max = reshape(max(Yimin + 1).*Y1maskl + max(Yimax + 1).*Y1maskg,[np,nmhu]);
%
%clear Yimin Yimax
%
xyi1min(~xymaskT) = 1;
xyi1max(~xymaskT) = 1;
xyi2min(~xymaskT) = 1;
xyi2max(~xymaskT) = 1;
%
xytheta1min =  theta(xyi1min);
xytheta1max =  theta(xyi1max);
xytheta2min =  theta(xyi2min);
xytheta2max =  theta(xyi2max);
%
if np > 1,
	Zi1min = reshape(xyi1min + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
	Zi1max = reshape(xyi1max + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
	Zi2min = reshape(xyi2min + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
	Zi2max = reshape(xyi2max + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
else
	Zi1min = xyi1min';
	Zi1max = xyi1max';
	Zi2min = xyi2min';
	Zi2max = xyi2max';
end
%	
XtB = XB';
XtBx = XBx';
XtBy = XBy';
XtBphi = XBphi';
Xtx = Xx';
Xty = Xy';
%
xyB1min =  reshape(XtB(Zi1min),[np,nmhu]);
xyB1max =  reshape(XtB(Zi1max),[np,nmhu]);
xyB2min =  reshape(XtB(Zi2min),[np,nmhu]);
xyB2max =  reshape(XtB(Zi2max),[np,nmhu]);
%
xyBx1min =  reshape(XtBx(Zi1min),[np,nmhu]);
xyBx1max =  reshape(XtBx(Zi1max),[np,nmhu]);
xyBx2min =  reshape(XtBx(Zi2min),[np,nmhu]);
xyBx2max =  reshape(XtBx(Zi2max),[np,nmhu]);
%
xyBy1min =  reshape(XtBy(Zi1min),[np,nmhu]);
xyBy1max =  reshape(XtBy(Zi1max),[np,nmhu]);
xyBy2min =  reshape(XtBy(Zi2min),[np,nmhu]);
xyBy2max =  reshape(XtBy(Zi2max),[np,nmhu]);
%
xyBphi1min =  reshape(XtBphi(Zi1min),[np,nmhu]);
xyBphi1max =  reshape(XtBphi(Zi1max),[np,nmhu]);
xyBphi2min =  reshape(XtBphi(Zi2min),[np,nmhu]);
xyBphi2max =  reshape(XtBphi(Zi2max),[np,nmhu]);
%
xyx1min =  reshape(Xtx(Zi1min),[np,nmhu]);
xyx1max =  reshape(Xtx(Zi1max),[np,nmhu]);
xyx2min =  reshape(Xtx(Zi2min),[np,nmhu]);
xyx2max =  reshape(Xtx(Zi2max),[np,nmhu]);
%
xyy1min =  reshape(Xty(Zi1min),[np,nmhu]);
xyy1max =  reshape(Xty(Zi1max),[np,nmhu]);
xyy2min =  reshape(Xty(Zi2min),[np,nmhu]);
xyy2max =  reshape(Xty(Zi2max),[np,nmhu]);
%
xyY1 = xyBx1min.*xyBx1max + xyBy1min.*xyBy1max + xyBphi1min.*xyBphi1max;
xyY2 = xyBx2min.*xyBx2max + xyBy2min.*xyBy2max + xyBphi2min.*xyBphi2max;
%
xydelta1 = sqrt((xyY1 - xyBb.^2).^2 - (xyBb.^2 - xyB1min.^2).*(xyBb.^2 - xyB1max.^2));
xydelta2 = sqrt((xyY2 - xyBb.^2).^2 - (xyBb.^2 - xyB2min.^2).*(xyBb.^2 - xyB2max.^2));
%
xyalpha1a = ((xyB1min.^2 - xyY1) + xydelta1)./(xyB1min.^2 + xyB1max.^2 - 2*xyY1);
xyalpha1b = ((xyB1min.^2 - xyY1) - xydelta1)./(xyB1min.^2 + xyB1max.^2 - 2*xyY1);
%
xyalpha2a = ((xyB2min.^2 - xyY2) + xydelta2)./(xyB2min.^2 + xyB2max.^2 - 2*xyY2);
xyalpha2b = ((xyB2min.^2 - xyY2) - xydelta2)./(xyB2min.^2 + xyB2max.^2 - 2*xyY2);
%
tol = 1e-5;
%
xymask1a = xyalpha1a >= -tol & xyalpha1a <= 1+tol;
xymask1b = xyalpha1b >= -tol & xyalpha1b <= 1+tol;
xymask2a = xyalpha2a >= -tol & xyalpha2a <= 1+tol;
xymask2b = xyalpha2b >= -tol & xyalpha2b <= 1+tol;
%
xymaskid1a = (xyBb == xyB1min);
xymaskid1b = (xyBb == xyB1max);
xymaskid2a = (xyBb == xyB2min);
xymaskid2b = (xyBb == xyB2max);
%
xymaskid1 = xymaskid1a | xymaskid1b;
xymaskid2 = xymaskid2a | xymaskid2b;
%
xyones = ones(np,nmhu);
%
if min(min(xymask1a.*xymaskT.*~xymaskid1 + xymask1b.*xymaskT.*~xymaskid1 == xyones.*xymaskT.*~xymaskid1)) == 0,
	error('root 1 not determined');
end
if min(min(xymask2a.*xymaskT.*~xymaskid2 + xymask2b.*xymaskT.*~xymaskid2 == xyones.*xymaskT.*~xymaskid2)) == 0,
	error('root 2 not determined');
end
%
xyalpha1 = (xymask1a.*xyalpha1a + ~xymask1a.*xyalpha1b).*~xymaskid1 + xymaskid1b;
xyalpha2 = (xymask2a.*xyalpha2a + ~xymask2a.*xyalpha2b).*~xymaskid2 + xymaskid2b;
%
xyTthetaT1 = xytheta1min + (xytheta1max - xytheta1min).*xyalpha1;
xyTthetaT2 = xytheta2min + (xytheta2max - xytheta2min).*xyalpha2;
%
xyTthetaT1(~xymaskT) = 0;
xyTthetaT2(~xymaskT) = 0;
%
xyBxT1 = xyBx1min + (xyBx1max - xyBx1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBxT2 = xyBx2min + (xyBx2max - xyBx2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyByT1 = xyBy1min + (xyBy1max - xyBy1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyByT2 = xyBy2min + (xyBy2max - xyBy2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyBphiT1 = xyBphi1min + (xyBphi1max - xyBphi1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBphiT2 = xyBphi2min + (xyBphi2max - xyBphi2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyxT1 = xyx1min + (xyx1max - xyx1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyxT2 = xyx2min + (xyx2max - xyx2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyyT1 = xyy1min + (xyy1max - xyy1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyyT2 = xyy2min + (xyy2max - xyy2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyBxT1(~xymaskT) = xyBx1min(~xymaskT);
xyBxT2(~xymaskT) = xyBx2min(~xymaskT);
%
xyByT1(~xymaskT) = xyBy1min(~xymaskT);
xyByT2(~xymaskT) = xyBy2min(~xymaskT);
%
xyBphiT1(~xymaskT) = xyBphi1min(~xymaskT);
xyBphiT2(~xymaskT) = xyBphi2min(~xymaskT);
%
xyxT1(~xymaskT) = xyx1min(~xymaskT);
xyxT2(~xymaskT) = xyx2min(~xymaskT);
%
xyyT1(~xymaskT) = xyy1min(~xymaskT);
xyyT2(~xymaskT) = xyy2min(~xymaskT);
%
Ytheta = repmat(theta',[1,np,nmhu]);
%
YBx = repmat(XBx',[1,1,nmhu]);	
YBy = repmat(XBy',[1,1,nmhu]);
YBphi = repmat(XBphi',[1,1,nmhu]);
Yx = repmat(Xx',[1,1,nmhu]);
Yy = repmat(Xy',[1,1,nmhu]);
%
xyBT1 = xyBb;
xyBT2 = xyBb;
xyBT1(~xymaskT) = xyB1min(~xymaskT);
xyBT2(~xymaskT) = xyB2min(~xymaskT);
%
YTtheta = [Ytheta;reshape(xyTthetaT1,[1,np,nmhu]);reshape(xyTthetaT2,[1,np,nmhu])];
YTB = [YB;reshape(xyBT1,[1,np,nmhu]);reshape(xyBT2,[1,np,nmhu])];
YTBx = [YBx;reshape(xyBxT1,[1,np,nmhu]);reshape(xyBxT2,[1,np,nmhu])];
YTBy = [YBy;reshape(xyByT1,[1,np,nmhu]);reshape(xyByT2,[1,np,nmhu])];
YTBphi = [YBphi;reshape(xyBphiT1,[1,np,nmhu]);reshape(xyBphiT2,[1,np,nmhu])];
YTx = [Yx;reshape(xyxT1,[1,np,nmhu]);reshape(xyxT2,[1,np,nmhu])];
YTy = [Yy;reshape(xyyT1,[1,np,nmhu]);reshape(xyyT2,[1,np,nmhu])];
%
nt2 = nt + 2;%Two poloidal angle values are added corresponding to banana tips
%
clear YB YBx YBy YBphi Yx Yy Ytheta
%
[YTtheta,YTiT] = sort(YTtheta);
ZTB = reshape(YTB,[nt2*np*nmhu,1]);
ZTBx = reshape(YTBx,[nt2*np*nmhu,1]);
ZTBy = reshape(YTBy,[nt2*np*nmhu,1]);
ZTBphi = reshape(YTBphi,[nt2*np*nmhu,1]);
ZTx = reshape(YTx,[nt2*np*nmhu,1]);
ZTy = reshape(YTy,[nt2*np*nmhu,1]);
%
if np > 1,
	csum1 = repmat(repmat([1:np]',1,nmhu),[1,1],nt2);% cumsum(ones(np,nmhu,nt2))
	csum2 = repmat(repmat([1:nmhu]',1,nt2),[1,1],np);;% cumsum(ones(nmhu,nt2,np))
	ZTiT = reshape(YTiT + shiftdim(nt2*(csum1 - 1),2) + shiftdim(nt2*np*(csum2 - 1),1),[nt2*np*nmhu,1]);
    % ZTiT = reshape(YTiT + shiftdim(nt2*(cumsum(ones(np,nmhu,nt2)) - 1),2) + shiftdim(nt2*np*(cumsum(ones(nmhu,nt2,np)) - 1),1),[nt2*np*nmhu,1]);
else
	ZTiT = reshape(YTiT + reshape(nt2*(cumsum(ones(nmhu,nt2)) - 1)',[nt2,1,nmhu]),[nt2*np*nmhu,1]);
end
%
YTB = reshape(ZTB(ZTiT),[nt2,np,nmhu]);
YTBx = reshape(ZTBx(ZTiT),[nt2,np,nmhu]);
YTBy = reshape(ZTBy(ZTiT),[nt2,np,nmhu]);
YTBphi = reshape(ZTBphi(ZTiT),[nt2,np,nmhu]);
YTx = reshape(ZTx(ZTiT),[nt2,np,nmhu]);
YTy = reshape(ZTy(ZTiT),[nt2,np,nmhu]);
%
clear ZTB ZTBx ZTBy ZTBphi ZTx ZTy ZTiT
%
% Half grid in theta for integration
%
YMBx = (YTBx(1:nt2-1,:,:) + YTBx(2:nt2,:,:))/2;
clear YTBx
%
YMBy = (YTBy(1:nt2-1,:,:) + YTBy(2:nt2,:,:))/2;
clear YTBy
%
YMBphi = (YTBphi(1:nt2-1,:,:) + YTBphi(2:nt2,:,:))/2;
clear YTBphi
%
YMB = sqrt(YMBx.^2 + YMBy.^2 + YMBphi.^2); 
%
nm2 = nt2 - 1;
%
YMBmin = repmat(xBmin,[nm2,1,nmhu]);
YMmhu0 = repmat(reshape(ymhu0,[1,1,nmhu]),[nm2,np,1]);
YM1mmhu02 = repmat(reshape(y1mmhu02,[1,1,nmhu]),[nm2,np,1]);
%
YMPSIB = YMB./YMBmin;%Ratio of B-field to its minimum on flux surface
YMBb = YMBmin./YM1mmhu02;%B-field at turning point
clear YM1mmhu02 YMBmin
%
YMx = (YTx(1:nt2-1,:,:) + YTx(2:nt2,:,:))/2;
YMy = (YTy(1:nt2-1,:,:) + YTy(2:nt2,:,:))/2;
clear YTy
%
YMmask = YMB <= YMBb;%Mask on the integration over B
%
clear YMBb
%
YMmhu = sign(YMmhu0).*sqrt(1 - YMPSIB.*(1 - YMmhu0.^2));%Pitch-angle cosine of (psi,theta,mhu)
YMmhu(~YMmask) = eps;%Avoid numerical singularities
YMF = YMB.*(YMx.^2 + YMy.^2).*YMmhu0./abs(YMBx.*YMy - YMBy.*YMx)./YMmhu/ap;
YMF(find(isinf(YMF))) = 1;%To avoid Inf and NaN
YMdt = diff(YTtheta);
%