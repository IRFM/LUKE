function [YMdt,YMmask,YMF,YMPSIB,YMmhu0,YMmhu,YMR,xymaskT,nm2] = banana_dke_jd(ymhu0,Rp,Zp,XR,XZ,XBR,XBZ,XBphi);
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
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) 
%
[np,nt] = size(XR);
nmhu = length(ymhu0);
%
theta = linspace(0,2*pi,nt);%Poloidal angular grid
%
XBT = abs(XBphi);%Toroidal B-field
XBP = sqrt(XBR.^2 + XBZ.^2);%Poloidal B-field
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
xymaskT = abs(xymhu0) < xymhu0T;%Select trapped particles
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
clear Yimin Yimax
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
XtBR = XBR';
XtBZ = XBZ';
XtBphi = XBphi';
XtR = XR';
XtZ = XZ';
%
xyB1min =  reshape(XtB(Zi1min),[np,nmhu]);
xyB1max =  reshape(XtB(Zi1max),[np,nmhu]);
xyB2min =  reshape(XtB(Zi2min),[np,nmhu]);
xyB2max =  reshape(XtB(Zi2max),[np,nmhu]);
%
xyBR1min =  reshape(XtBR(Zi1min),[np,nmhu]);
xyBR1max =  reshape(XtBR(Zi1max),[np,nmhu]);
xyBR2min =  reshape(XtBR(Zi2min),[np,nmhu]);
xyBR2max =  reshape(XtBR(Zi2max),[np,nmhu]);
%
xyBZ1min =  reshape(XtBZ(Zi1min),[np,nmhu]);
xyBZ1max =  reshape(XtBZ(Zi1max),[np,nmhu]);
xyBZ2min =  reshape(XtBZ(Zi2min),[np,nmhu]);
xyBZ2max =  reshape(XtBZ(Zi2max),[np,nmhu]);
%
xyBphi1min =  reshape(XtBphi(Zi1min),[np,nmhu]);
xyBphi1max =  reshape(XtBphi(Zi1max),[np,nmhu]);
xyBphi2min =  reshape(XtBphi(Zi2min),[np,nmhu]);
xyBphi2max =  reshape(XtBphi(Zi2max),[np,nmhu]);
%
xyR1min =  reshape(XtR(Zi1min),[np,nmhu]);
xyR1max =  reshape(XtR(Zi1max),[np,nmhu]);
xyR2min =  reshape(XtR(Zi2min),[np,nmhu]);
xyR2max =  reshape(XtR(Zi2max),[np,nmhu]);
%
xyZ1min =  reshape(XtZ(Zi1min),[np,nmhu]);
xyZ1max =  reshape(XtZ(Zi1max),[np,nmhu]);
xyZ2min =  reshape(XtZ(Zi2min),[np,nmhu]);
xyZ2max =  reshape(XtZ(Zi2max),[np,nmhu]);
%
xyY1 = xyBR1min.*xyBR1max + xyBZ1min.*xyBZ1max + xyBphi1min.*xyBphi1max;
xyY2 = xyBR2min.*xyBR2max + xyBZ2min.*xyBZ2max + xyBphi2min.*xyBphi2max;
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
xymask1a = xyalpha1a >= 0 & xyalpha1a <= 1;
xymask1b = xyalpha1b >= 0 & xyalpha1b <= 1;
xymask2a = xyalpha2a >= 0 & xyalpha2a <= 1;
xymask2b = xyalpha2b >= 0 & xyalpha2b <= 1;
%
xymaskid1a = (xyBb == xyB1min);
xymaskid1b = (xyBb == xyB1max);
xymaskid2a = (xyBb == xyB2min);
xymaskid2b = (xyBb == xyB2max);
%
xymaskid1 = xymaskid1a + xymaskid1b;
xymaskid2 = xymaskid2a + xymaskid2b;
%
xyones = ones(np,nmhu);
%
if min(xymask1a.*xymaskT.*~xymaskid1 + xymask1b.*xymaskT.*~xymaskid1 == xyones.*xymaskT.*~xymaskid1) == 0,
	error('root 1 not determined');
end
if min(xymask2a.*xymaskT.*~xymaskid2 + xymask2b.*xymaskT.*~xymaskid2 == xyones.*xymaskT.*~xymaskid2) == 0,
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
xyBRT1 = xyBR1min + (xyBR1max - xyBR1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBRT2 = xyBR2min + (xyBR2max - xyBR2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyBZT1 = xyBZ1min + (xyBZ1max - xyBZ1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBZT2 = xyBZ2min + (xyBZ2max - xyBZ2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyBphiT1 = xyBphi1min + (xyBphi1max - xyBphi1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBphiT2 = xyBphi2min + (xyBphi2max - xyBphi2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyRT1 = xyR1min + (xyR1max - xyR1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyRT2 = xyR2min + (xyR2max - xyR2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyZT1 = xyZ1min + (xyZ1max - xyZ1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyZT2 = xyZ2min + (xyZ2max - xyZ2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);
%
xyBRT1(~xymaskT) = xyBR1min(~xymaskT);
xyBRT2(~xymaskT) = xyBR2min(~xymaskT);
%
xyBZT1(~xymaskT) = xyBZ1min(~xymaskT);
xyBZT2(~xymaskT) = xyBZ2min(~xymaskT);
%
xyBphiT1(~xymaskT) = xyBphi1min(~xymaskT);
xyBphiT2(~xymaskT) = xyBphi2min(~xymaskT);
%
xyRT1(~xymaskT) = xyR1min(~xymaskT);
xyRT2(~xymaskT) = xyR2min(~xymaskT);
%
xyZT1(~xymaskT) = xyZ1min(~xymaskT);
xyZT2(~xymaskT) = xyZ2min(~xymaskT);
%
Ytheta = repmat(theta',[1,np,nmhu]);
%
YBR = repmat(XBR',[1,1,nmhu]);	
YBZ = repmat(XBZ',[1,1,nmhu]);
YBphi = repmat(XBphi',[1,1,nmhu]);
YR = repmat(XR',[1,1,nmhu]);
YZ = repmat(XZ',[1,1,nmhu]);
%
xyBT1 = xyBb;
xyBT2 = xyBb;
xyBT1(~xymaskT) = xyB1min(~xymaskT);
xyBT2(~xymaskT) = xyB2min(~xymaskT);
%
YTtheta = [Ytheta;reshape(xyTthetaT1,[1,np,nmhu]);reshape(xyTthetaT2,[1,np,nmhu])];
YTB = [YB;reshape(xyBT1,[1,np,nmhu]);reshape(xyBT2,[1,np,nmhu])];
YTBR = [YBR;reshape(xyBRT1,[1,np,nmhu]);reshape(xyBRT2,[1,np,nmhu])];
YTBZ = [YBZ;reshape(xyBZT1,[1,np,nmhu]);reshape(xyBZT2,[1,np,nmhu])];
YTBphi = [YBphi;reshape(xyBphiT1,[1,np,nmhu]);reshape(xyBphiT2,[1,np,nmhu])];
YTR = [YR;reshape(xyRT1,[1,np,nmhu]);reshape(xyRT2,[1,np,nmhu])];
YTZ = [YZ;reshape(xyZT1,[1,np,nmhu]);reshape(xyZT2,[1,np,nmhu])];
%
nt2 = nt + 2;%Two poloidal angle values are added corresponding to banana tips
%
clear YB YBR YBZ YBphi YR YZ Ytheta
%
[YTtheta,YTiT] = sort(YTtheta);
ZTB = reshape(YTB,[nt2*np*nmhu,1]);
ZTBR = reshape(YTBR,[nt2*np*nmhu,1]);
ZTBZ = reshape(YTBZ,[nt2*np*nmhu,1]);
ZTBphi = reshape(YTBphi,[nt2*np*nmhu,1]);
ZTR = reshape(YTR,[nt2*np*nmhu,1]);
ZTZ = reshape(YTZ,[nt2*np*nmhu,1]);
%
if np > 1,
	ZTiT = reshape(YTiT + shiftdim(nt2*(cumsum(ones(np,nmhu,nt2)) - 1),2) + shiftdim(nt2*np*(cumsum(ones(nmhu,nt2,np)) - 1),1),[nt2*np*nmhu,1]);
else
	ZTiT = reshape(YTiT + reshape(nt2*(cumsum(ones(nmhu,nt2)) - 1)',[nt2,1,nmhu]),[nt2*np*nmhu,1]);
end
%
YTB = reshape(ZTB(ZTiT),[nt2,np,nmhu]);
YTBR = reshape(ZTBR(ZTiT),[nt2,np,nmhu]);
YTBZ = reshape(ZTBZ(ZTiT),[nt2,np,nmhu]);
YTBphi = reshape(ZTBphi(ZTiT),[nt2,np,nmhu]);
YTR = reshape(ZTR(ZTiT),[nt2,np,nmhu]);
YTZ = reshape(ZTZ(ZTiT),[nt2,np,nmhu]);
%
clear ZTB ZTBR ZTBZ ZTBphi ZTR ZTZ ZTiT
%
% Half grid in theta for integration
%
YMBR = (YTBR(1:nt2-1,:,:) + YTBR(2:nt2,:,:))/2;
clear YTBR
%
YMBZ = (YTBZ(1:nt2-1,:,:) + YTBZ(2:nt2,:,:))/2;
clear YTBZ
%
YMBphi = (YTBphi(1:nt2-1,:,:) + YTBphi(2:nt2,:,:))/2;
clear YTBphi
%
YMB = sqrt(YMBR.^2 + YMBZ.^2 + YMBphi.^2); 
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
YMR = (YTR(1:nt2-1,:,:) + YTR(2:nt2,:,:))/2;
YMZ = (YTZ(1:nt2-1,:,:) + YTZ(2:nt2,:,:))/2;
clear YTZ
%
YMmask = YMB <= YMBb;%Mask on the integration over B
%
clear YMBb
%
YMmhu = sign(YMmhu0).*sqrt(1 - YMPSIB.*(1 - YMmhu0.^2));%Pitch-angle cosine of (psi,theta,mhu)
YMmhu(~YMmask) = eps;%Avoid numerical singularities
YMF = YMB.*((YMR - Rp).^2 + (YMZ - Zp).^2).*YMmhu0./abs(YMBR.*(YMZ - Zp) - YMBZ.*(YMR - Rp))./YMmhu/Rp;
YMdt = diff(YTtheta);
