clear, warning off

memax = 128*1e6; % Available memory
filename = 'equihelena';
method = 'linear';
super = 1;
nmhu = 41;
ymhu0 = linspace(0,1,nmhu); % Pitch-angle cosine at minimum of B-field


eval(['load ',filename,'.mat'])

XR = R;
XZ = Z;
XBR = BR;
XBZ = BZ;
XBphi = BPHI;

xpsi = psi;
xq = q;

clear R Z BR BZ BPHI psi q

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
YBmin = repmat(xBmin,[nt,1,nmhu]);
Ymhu0 = shiftdim(repmat(ymhu0',[1,nt,np]),1);

y1mmhu02 = 1 - ymhu0.^2;
y1mmhu02(y1mmhu02 == 0) = eps;
Y1mmhu02 = shiftdim(repmat(y1mmhu02',[1,nt,np]),1);

YPSIB = YB./YBmin; % Ratio of B-field to its minimum on FS
YBb = YBmin./Y1mmhu02; % B-field at turning point
clear Y1mmhu02

xmhu0T = sqrt(1 - xBmin./xBmax); % Pitch-angle at the trapped-passing boundary

xymhu0 = repmat(ymhu0,[np,1]);
xymhu0T = repmat(xmhu0T',[1,nmhu]);
xyBb = xBmin'*(1./y1mmhu02); % B-field at turning point 

Y1Bb = YBb(1,:,:); % B-field at turning point
Y1B0 = YB(1,:,:); % B-field at theta = 0

Y1maskg = Y1Bb >= Y1B0; 
Y1maskl = Y1Bb < Y1B0;
xymaskT = abs(xymhu0) < xymhu0T; % Select trapped particles

YCS = cumsum(ones(nt,np,nmhu));

Yimin = (YB <= YBb).*YCS;
Yimax = (YB > YBb).*YCS;

Yimin(Yimin == 0) = NaN;
Yimax(Yimax == 0) = NaN;

xyi1max = squeeze(min(Yimin).*Y1maskl + min(Yimax).*Y1maskg);
xyi1min = squeeze(min(Yimin - 1).*Y1maskl + min(Yimax - 1).*Y1maskg);
xyi2min = squeeze(max(Yimin).*Y1maskl + max(Yimax).*Y1maskg);
xyi2max = squeeze(max(Yimin + 1).*Y1maskl + max(Yimax + 1).*Y1maskg);

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

xyB1min =  reshape(XtB(Zi1min),[np,nmhu]);
xyB1max =  reshape(XtB(Zi1max),[np,nmhu]);
xyB2min =  reshape(XtB(Zi2min),[np,nmhu]);
xyB2max =  reshape(XtB(Zi2max),[np,nmhu]);


xyB1max(~xymaskT) = xyB1min(~xymaskT) + eps;
xyB2max(~xymaskT) = xyB2min(~xymaskT) + eps;

xyTthetaT1 = xytheta1min + (xytheta1max - xytheta1min).*(xyBb - xyB1min)./(xyB1max - xyB1min);
xyTthetaT2 = xytheta2min + (xytheta2max - xytheta2min).*(xyBb - xyB2min)./(xyB2max - xyB2min);

Ytheta = repmat(theta',[1,np,nmhu]);

YTtheta = [Ytheta;reshape(xyTthetaT1,[1,np,nmhu]);reshape(xyTthetaT2,[1,np,nmhu])];
YTB = [YB;repmat(reshape(xyBb,[1,np,nmhu]),[2,1,1])];

[YTtheta,YTiT] = sort(YTtheta);
ZTB = reshape(YTB,[(nt + 2),np,nmhu]);
ZTiT = reshape(YTiT,[(nt + 2),np,nmhu]);

YTB = reshape(ZTB(ZTiT),[(nt + 2),np,nmhu]);

YTBR = interp1(Ytheta,YBR,YTtheta);


Ymask = YB <= YBb; % mask on the intergration over theta



clear YBmin YBb

Ymhu = sign(Ymhu0).*sqrt(1 - YPSIB.*(1 - Ymhu0.^2)); % Pitch-angle cosine of (psi,theta,mhu)
Ymhu(~Ymask) = eps;

clear YPSIB

YBR = repmat(XBR',[1,1,nmhu]);	
YBZ = repmat(XBZ',[1,1,nmhu]);
YR = repmat(XR',[1,1,nmhu]);
YZ = repmat(XZ',[1,1,nmhu]);



dt = theta(2) - theta(1);
tdt = [dt/2, dt*ones(1,nt - 2), dt/2];

xyInt = integral_dke_jd( tdt/(2*pi), Ymask.*YB.*((YR - R0).^2 + (YZ - Z0).^2).*Ymhu0./abs(YBR.*(YZ - Z0) - YBZ.*(YR - R0))./Ymhu, 1);
	
ymask = find(ymhu0 == 0);
if ~isempty(ymask)
	xyInt(:,ymask) = 0;
end

xyr = repmat(xr',[1,nmhu]);
xyq = repmat(xq',[1,nmhu]);

xylambda = xyInt./xyr./sqrt(1 + (R0*xyq./xyr).^2);

psimin = min(xpsi);
psimax = max(xpsi);


figure(1),clf

[ax] = graph2Djd(xr,ymhu0,xylambda,'','','',[0,a],[min(ymhu0),max(ymhu0)],0,NaN,[0:0.2:2],1,'-','r',2,0.9,NaN);
hold on
[ax] = graph1Djd(xr,xmhu0T,'r','\xi','\lambda',[0,a],[min(ymhu0),max(ymhu0)],'--','none','b',2,gca,1,0.7,0.5);
hold off

figure(2),clf

xmask = [2,round(np/4),round(np/2),round(np*3/4),np]

[ax] = graph1Djd(ymhu0,xylambda(xmask,:),'\xi','\lambda','',[min(ymhu0),max(ymhu0)],[0,3],'-','none','r',2,gca,0.9,0.7,0.7);



