clear, warning off

memax = 128*1e6; % Available memory
tokamak = 'test';
filename = ['EQUIL_',tokamak];
%filename = 'equihelena';
method = 'linear';
%super = 1;
nmhu = 81;
ymhu0 = linspace(-1,1,nmhu); % Pitch-angle cosine at minimum of B-field

eval(['load ',filename,'.mat R Z BR BZ BPHI psi'])

XR = R;
XZ = Z;
XBR = BR;
XBZ = BZ;
XBphi = BPHI;
xpsi = psi;

xqtilde = qtilde_dke_jd(filename);

clear R Z BR BZ BPHI psi 

%[np,nti] = size(XR);
[np,nt] = size(XR);
%thetai = linspace(0,2*pi,nti); % Angular grid

%super = round(super);
%nt = nti*super;
theta = linspace(0,2*pi,nt); % Angular grid

%if super > 1
%	XR = interp1(thetai,XR',theta,method)';		
%	XZ = interp1(thetai,XZ',theta,method)';		
%	XBR = interp1(thetai,XBR',theta,method)';		
%	XBZ = interp1(thetai,XBZ',theta,method)';		
%	XBphi = interp1(thetai,XBphi',theta,method)';		
%end	
	
R0 = XR(1,1); % R of Magnetic Axix
Z0 = XZ(1,1); % Z of Magnetic Axix

xr = XR(:,1)' - R0; % Radial distance on LFS horizontal midplane
a = max(xr); 

XBT = abs(XBphi); % Toroidal B-field
XBP = sqrt(XBR.^2 + XBZ.^2); % Poloidal B-field
XB = sqrt(XBT.^2 + XBP.^2); % Total B-field

xBmin = min(XB'); % Minimum of B on FS
xBmax = max(XB'); % Maximum of B on FS

YB = repmat(XB',[1,1,nmhu]);

y1mmhu02 = 1 - ymhu0.^2;
y1mmhu02(y1mmhu02 == 0) = eps;
xyBb = xBmin'*(1./y1mmhu02); % B-field at turning point 

YBmin = repmat(xBmin,[nt,1,nmhu]);
Y1mmhu02 = shiftdim(repmat(y1mmhu02',[1,nt,np]),1);
YBb = YBmin./Y1mmhu02; % B-field at turning point

clear Y1mmhu02 YBmin

Y1Bb = reshape(xyBb,[1,np,nmhu]); % B-field at turning point
Y1B0 = YB(1,:,:); % B-field at theta = 0

Y1maskg = Y1Bb >= Y1B0; 
Y1maskl = Y1Bb < Y1B0;

xmhu0T = sqrt(1 - xBmin./xBmax); % Pitch-angle at the trapped-passing boundary

xymhu0 = repmat(ymhu0,[np,1]);
xymhu0T = repmat(xmhu0T',[1,nmhu]);

xymaskT = abs(xymhu0) < xymhu0T; % Select trapped particles

YCS = cumsum(ones(nt,np,nmhu));

Yimin = (YB <= YBb).*YCS;
Yimax = (YB > YBb).*YCS;

clear YBb

Yimin(Yimin == 0) = NaN;
Yimax(Yimax == 0) = NaN;

xyi1max = squeeze(min(Yimin).*Y1maskl + min(Yimax).*Y1maskg);
xyi1min = squeeze(min(Yimin - 1).*Y1maskl + min(Yimax - 1).*Y1maskg);
xyi2min = squeeze(max(Yimin).*Y1maskl + max(Yimax).*Y1maskg);
xyi2max = squeeze(max(Yimin + 1).*Y1maskl + max(Yimax + 1).*Y1maskg);

clear Yimin Yimax

xyi1min(~xymaskT) = 1;
xyi1max(~xymaskT) = 1;
xyi2min(~xymaskT) = 1;
xyi2max(~xymaskT) = 1;

xytheta1min =  theta(xyi1min);
xytheta1max =  theta(xyi1max);
xytheta2min =  theta(xyi2min);
xytheta2max =  theta(xyi2max);

Zi1min = reshape(xyi1min + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
Zi1max = reshape(xyi1max + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
Zi2min = reshape(xyi2min + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);
Zi2max = reshape(xyi2max + nt*(cumsum(ones(np,nmhu)) - 1),[np*nmhu,1]);

XtB = XB';
XtBR = XBR';
XtBZ = XBZ';
XtBphi = XBphi';
XtR = XR';
XtZ = XZ';


xyB1min =  reshape(XtB(Zi1min),[np,nmhu]);
xyB1max =  reshape(XtB(Zi1max),[np,nmhu]);
xyB2min =  reshape(XtB(Zi2min),[np,nmhu]);
xyB2max =  reshape(XtB(Zi2max),[np,nmhu]);

xyBR1min =  reshape(XtBR(Zi1min),[np,nmhu]);
xyBR1max =  reshape(XtBR(Zi1max),[np,nmhu]);
xyBR2min =  reshape(XtBR(Zi2min),[np,nmhu]);
xyBR2max =  reshape(XtBR(Zi2max),[np,nmhu]);

xyBZ1min =  reshape(XtBZ(Zi1min),[np,nmhu]);
xyBZ1max =  reshape(XtBZ(Zi1max),[np,nmhu]);
xyBZ2min =  reshape(XtBZ(Zi2min),[np,nmhu]);
xyBZ2max =  reshape(XtBZ(Zi2max),[np,nmhu]);

xyBphi1min =  reshape(XtBphi(Zi1min),[np,nmhu]);
xyBphi1max =  reshape(XtBphi(Zi1max),[np,nmhu]);
xyBphi2min =  reshape(XtBphi(Zi2min),[np,nmhu]);
xyBphi2max =  reshape(XtBphi(Zi2max),[np,nmhu]);

xyR1min =  reshape(XtR(Zi1min),[np,nmhu]);
xyR1max =  reshape(XtR(Zi1max),[np,nmhu]);
xyR2min =  reshape(XtR(Zi2min),[np,nmhu]);
xyR2max =  reshape(XtR(Zi2max),[np,nmhu]);

xyZ1min =  reshape(XtZ(Zi1min),[np,nmhu]);
xyZ1max =  reshape(XtZ(Zi1max),[np,nmhu]);
xyZ2min =  reshape(XtZ(Zi2min),[np,nmhu]);
xyZ2max =  reshape(XtZ(Zi2max),[np,nmhu]);

xyY1 = xyBR1min.*xyBR1max + xyBZ1min.*xyBZ1max + xyBphi1min.*xyBphi1max;
xyY2 = xyBR2min.*xyBR2max + xyBZ2min.*xyBZ2max + xyBphi2min.*xyBphi2max;

%xysign1 = (xyY1 <= xyB1max.^2) - (xyY1 > xyB1max.^2);
%xysign2 = (xyY2 <= xyB2max.^2) - (xyY2 > xyB2max.^2);

%xyalpha1 = ((xyB1min.^2 - xyY1) + xysign1.*sqrt((xyY1 - xyBb.^2).^2 - (xyBb.^2 - xyB1min.^2).*(xyBb.^2 - xyB1max.^2)))./(xyB1min.^2 + xyB1max.^2 - 2*xyY1);
%xyalpha2 = ((xyB2min.^2 - xyY2) + xysign2.*sqrt((xyY2 - xyBb.^2).^2 - (xyBb.^2 - xyB2min.^2).*(xyBb.^2 - xyB2max.^2)))./(xyB2min.^2 + xyB2max.^2 - 2*xyY2);

xydelta1 = sqrt((xyY1 - xyBb.^2).^2 - (xyBb.^2 - xyB1min.^2).*(xyBb.^2 - xyB1max.^2));
xydelta2 = sqrt((xyY2 - xyBb.^2).^2 - (xyBb.^2 - xyB2min.^2).*(xyBb.^2 - xyB2max.^2));

xyalpha1a = ((xyB1min.^2 - xyY1) + xydelta1)./(xyB1min.^2 + xyB1max.^2 - 2*xyY1);
xyalpha1b = ((xyB1min.^2 - xyY1) - xydelta1)./(xyB1min.^2 + xyB1max.^2 - 2*xyY1);

xyalpha2a = ((xyB2min.^2 - xyY2) + xydelta2)./(xyB2min.^2 + xyB2max.^2 - 2*xyY2);
xyalpha2b = ((xyB2min.^2 - xyY2) - xydelta2)./(xyB2min.^2 + xyB2max.^2 - 2*xyY2);

xymask1a = xyalpha1a >= 0 & xyalpha1a <= 1;
xymask1b = xyalpha1b >= 0 & xyalpha1b <= 1;
xymask2a = xyalpha2a >= 0 & xyalpha2a <= 1;
xymask2b = xyalpha2b >= 0 & xyalpha2b <= 1;

xyones = ones(np,nmhu);

if min(xymask1a.*xymaskT + xymask1b.*xymaskT == xyones.*xymaskT) == 0
	error('root 1 not determined');
end
if min(xymask2a.*xymaskT + xymask2b.*xymaskT == xyones.*xymaskT) == 0
	error('root 2 not determined');
end

xyalpha1 = xymask1a.*xyalpha1a + ~xymask1a.*xyalpha1b;
xyalpha2 = xymask2a.*xyalpha2a + ~xymask2a.*xyalpha2b;

xyTthetaT1 = xytheta1min + (xytheta1max - xytheta1min).*xyalpha1;
xyTthetaT2 = xytheta2min + (xytheta2max - xytheta2min).*xyalpha2;

xyTthetaT1(~xymaskT) = 0;
xyTthetaT2(~xymaskT) = 0;

xyBRT1 = xyBR1min + (xyBR1max - xyBR1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBRT2 = xyBR2min + (xyBR2max - xyBR2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);

xyBZT1 = xyBZ1min + (xyBZ1max - xyBZ1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBZT2 = xyBZ2min + (xyBZ2max - xyBZ2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);

xyBphiT1 = xyBphi1min + (xyBphi1max - xyBphi1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyBphiT2 = xyBphi2min + (xyBphi2max - xyBphi2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);

xyRT1 = xyR1min + (xyR1max - xyR1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyRT2 = xyR2min + (xyR2max - xyR2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);

xyZT1 = xyZ1min + (xyZ1max - xyZ1min).*(xyTthetaT1 - xytheta1min)./(xytheta1max - xytheta1min);
xyZT2 = xyZ2min + (xyZ2max - xyZ2min).*(xyTthetaT2 - xytheta2min)./(xytheta2max - xytheta2min);

xyBRT1(~xymaskT) = xyBR1min(~xymaskT);
xyBRT2(~xymaskT) = xyBR2min(~xymaskT);

xyBZT1(~xymaskT) = xyBZ1min(~xymaskT);
xyBZT2(~xymaskT) = xyBZ2min(~xymaskT);

xyBphiT1(~xymaskT) = xyBphi1min(~xymaskT);
xyBphiT2(~xymaskT) = xyBphi2min(~xymaskT);

xyRT1(~xymaskT) = xyR1min(~xymaskT);
xyRT2(~xymaskT) = xyR2min(~xymaskT);

xyZT1(~xymaskT) = xyZ1min(~xymaskT);
xyZT2(~xymaskT) = xyZ2min(~xymaskT);

Ytheta = repmat(theta',[1,np,nmhu]);

YBR = repmat(XBR',[1,1,nmhu]);	
YBZ = repmat(XBZ',[1,1,nmhu]);
YBphi = repmat(XBphi',[1,1,nmhu]);
YR = repmat(XR',[1,1,nmhu]);
YZ = repmat(XZ',[1,1,nmhu]);

xyBT1 = xyBb;
xyBT2 = xyBb;
xyBT1(~xymaskT) = xyB1min(~xymaskT);
xyBT2(~xymaskT) = xyB2min(~xymaskT);

YTtheta = [Ytheta;reshape(xyTthetaT1,[1,np,nmhu]);reshape(xyTthetaT2,[1,np,nmhu])];
YTB = [YB;reshape(xyBT1,[1,np,nmhu]);reshape(xyBT2,[1,np,nmhu])];
YTBR = [YBR;reshape(xyBRT1,[1,np,nmhu]);reshape(xyBRT2,[1,np,nmhu])];
YTBZ = [YBZ;reshape(xyBZT1,[1,np,nmhu]);reshape(xyBZT2,[1,np,nmhu])];
YTBphi = [YBphi;reshape(xyBphiT1,[1,np,nmhu]);reshape(xyBphiT2,[1,np,nmhu])];
YTR = [YR;reshape(xyRT1,[1,np,nmhu]);reshape(xyRT2,[1,np,nmhu])];
YTZ = [YZ;reshape(xyZT1,[1,np,nmhu]);reshape(xyZT2,[1,np,nmhu])];

nt2 = nt + 2;

clear YB YBR YBZ YBphi YR YZ Ytheta

[YTtheta,YTiT] = sort(YTtheta);
ZTB = reshape(YTB,[nt2*np*nmhu,1]);
ZTBR = reshape(YTBR,[nt2*np*nmhu,1]);
ZTBZ = reshape(YTBZ,[nt2*np*nmhu,1]);
ZTBphi = reshape(YTBphi,[nt2*np*nmhu,1]);
ZTR = reshape(YTR,[nt2*np*nmhu,1]);
ZTZ = reshape(YTZ,[nt2*np*nmhu,1]);

ZTiT = reshape(YTiT + shiftdim(nt2*(cumsum(ones(np,nmhu,nt2)) - 1),2) + shiftdim(nt2*np*(cumsum(ones(nmhu,nt2,np)) - 1),1),[nt2*np*nmhu,1]);

YTB = reshape(ZTB(ZTiT),[nt2,np,nmhu]);
YTBR = reshape(ZTBR(ZTiT),[nt2,np,nmhu]);
YTBZ = reshape(ZTBZ(ZTiT),[nt2,np,nmhu]);
YTBphi = reshape(ZTBphi(ZTiT),[nt2,np,nmhu]);
YTR = reshape(ZTR(ZTiT),[nt2,np,nmhu]);
YTZ = reshape(ZTZ(ZTiT),[nt2,np,nmhu]);

clear ZTB ZTBR ZTBZ ZTBphi ZTR ZTZ ZTiT

% Half grid in theta for integration

YMBR = (YTBR(1:nt2-1,:,:) + YTBR(2:nt2,:,:))/2;
clear YTBR

YMBZ = (YTBZ(1:nt2-1,:,:) + YTBZ(2:nt2,:,:))/2;
clear YTBZ

YMBphi = (YTBphi(1:nt2-1,:,:) + YTBphi(2:nt2,:,:))/2;
clear YTBphi

YMR = (YTR(1:nt2-1,:,:) + YTR(2:nt2,:,:))/2;
clear YTR

YMZ = (YTZ(1:nt2-1,:,:) + YTZ(2:nt2,:,:))/2;
clear YTZ

nm2 = nt2 - 1;

YMB = sqrt(YMBR.^2 + YMBZ.^2 + YMBphi.^2); 

YMBmin = repmat(xBmin,[nm2,1,nmhu]);
YMmhu0 = shiftdim(repmat(ymhu0',[1,nm2,np]),1);

YM1mmhu02 = shiftdim(repmat(y1mmhu02',[1,nm2,np]),1);

YMPSIB = YMB./YMBmin; % Ratio of B-field to its minimum on FS
YMBb = YMBmin./YM1mmhu02; % B-field at turning point
clear YM1mmhu02 YMBmin

YMmask = YMB <= YMBb; % mask on the intergration over B

clear YMBb

YMmhu = sign(YMmhu0).*sqrt(1 - YMPSIB.*(1 - YMmhu0.^2)); % Pitch-angle cosine of (psi,theta,mhu)
YMmhu(~YMmask) = eps;

clear YTPSIB

YMF = YMmask.*YMB.*((YMR - R0).^2 + (YMZ - Z0).^2).*YMmhu0./abs(YMBR.*(YMZ - Z0) - YMBZ.*(YMR - R0))./YMmhu/R0;

clear YTmask YMB YMR YMZ YMBR YMBZ YMmhu0 YMmhu

YMdt = diff(YTtheta);

xyInt = squeeze(sum(YMF.*YMdt)/(2*pi));
	
ymask = find(ymhu0 == 0);
if ~isempty(ymask)
	xyInt(:,ymask) = 0;
end

xyqtilde = repmat(xqtilde',[1,nmhu]);

xylambda = xyInt./xyqtilde;

psimin = min(xpsi);
psimax = max(xpsi);


%figure(1),clf

%[ax] = graph2Djd(xr,ymhu0,xylambda,'','','',[0,a],[min(ymhu0),max(ymhu0)],0,NaN,[0:0.2:2],1,'-','r',2,0.9,NaN);
%hold on
%[ax] = graph1Djd(xr,xmhu0T,'r','\xi','\lambda',[0,a],[min(ymhu0),max(ymhu0)],'--','none','b',2,gca,1,0.7,0.5);
%hold off

figure(2),clf

xmask = [2,round(np/4),round(np/2),round(np*3/4),np]

[ax] = graph1Djd(ymhu0,xylambda(xmask,:),'\xi','\lambda','',[min(ymhu0),max(ymhu0)],[0,3],'-','none','r',2,gca,0.9,0.7,0.7);

if 1,
	xia = xr/R0;
	xmhutrap2 = 2*xia./(1+xia);
	m = 30;
	for ir = xmask
		[ylambda,ydelta,ysstar,ysstar_tp,ylambda_tp] = bounce_dke_jd(xmhutrap2(ir),ymhu0,m);
		xylambda_c(ir,:) = ylambda;	
		xydelta_c(ir,:) = ydelta;
		xysstar_c(ir,:) = ysstar;
		xysstar_tp_c(ir,:) = ysstar_tp;
		xylambda_tp_c(ir,:) = ylambda_tp;
	end

	figure(2)
	hold on
	[ax] = graph1Djd(ymhu0,xylambda_c,'\xi','\lambda','',[min(ymhu0),max(ymhu0)],[0,3],'-','none','b',0.5,gca,0.9,0.7,0.7);
	hold off
end	
