% calculation of ripple losscone angles 
%
Ip   = Ip*1000000;
alfap1 = 4;
B0R0   = B0*R0;
CBP    = 2e-7*Ip;
NBOB   = 18;
B0     = B0R0/R0;
Z0     = 0;
a2     = a*a;
Raxe   = R0 + D0;
c0     = D0/a2;
rc2    = c0*c0;
dc2    = 2*rc2;
qc2    = 4*rc2;
%
ag         = 1.2;
RR         = 1.54:0.025:1.54+ag*11/8;
ZZ         = 0:0.025:1.2;
[R,Z]      = meshgrid(RR,ZZ);
zerR       = zeros(size(R));
X          = (R-Raxe);
Y          = 1-2*c0*X;
rs2        = (Y-sqrt(Y.*Y-qc2*(X.^2+(Z-Z0).^2)))/dc2;
rs         = sqrt(rs2);
cr2        = max(zerR,1-rs2/a2);
BpM        = CBP*(1-cr2.^alfap1)./rs;
D          = D0*(1-rs2/a2);
Dprime     = -2*D0*rs/a2;
cteta      = (R-R0-D)./rs;
Bp         = BpM.*(R0+D)./(R.*(1+Dprime.*cteta));
%
BpR        = Bp.*((Z-Z0)./rs);
BpZ        = -Bp.*cteta;
BF         = B0R0./R;
%
teta       = (0:0.005:1)*2*pi;
Rbord      = R0+a*cos(teta);
Zbord      = Z0+a*sin(teta);
%
ripple        = deltacalmj3(R,Z);
alfastar      = abs(BpR./(NBOB*ripple.*BF));

rhos  = rho*a;
Rcs   = R0+D0*(1-(rhos/a).^2);
Zcs   = zeros(size(rhos));
Rmini = Rcs-rhos;
Rmaxi = Rcs+rhos;

cc=contour(RR,ZZ,alfastar,[-1 1]);clf;close
Rastar   = cc(1,2:cc(2,1));
Zastar   = cc(2,2:cc(2,1));
Rastar(end+1) = Rastar(1);
Zastar(end+1) = Zastar(1);
centreR=mean(Rastar);centreZ=mean(Zastar);
angastar=unwrap(angle((Rastar-centreR)+i*(Zastar-centreZ)));

newang      = linspace(angastar(1),angastar(end),1000);
newang(end) = [];
nRastar     = interp1(angastar,Rastar,newang,'linear');
nZastar     = interp1(angastar,Zastar,newang,'linear');
nRastar(isnan(nRastar)) = -ones(size(nRastar(isnan(nRastar))));
nZastar(isnan(nZastar)) = -ones(size(nZastar(isnan(nZastar))));

R           = linspace(Rmaxi-1e-6,Rmini+1e-6,1000);
Z           = sqrt(rhos^2-(R-Rcs).^2);
nZ          = sqrt(rhos^2-(nRastar-Rcs).^2);
ind         = find(~imag(nZ));
if isempty(ind)

  disp(['no intersection between the good confinement area and the fkux surface, rho=',num2str(rhos,4)])
  mulim           = zeros(size(rhos));
  thetabanane     = zeros(size(rhos));
  thetaloss       = zeros(size(rhos));
  thetaZBC        = zeros(size(rhos));
  return

end
dis         = nZ-nZastar;
dis1        = cat(2,dis(ind),0);
dis2        = cat(2,0,dis(ind));
indval         = find((dis1.*dis2) <=0);
%if length(indval) > 1,
%   indval(1)      = [];
%   indval(end)    = [];
%else 
%   indval =[];
%end
indval(1)      = [];
indval(end)    = [];
indRb        = ind(indval-1);
Rb           = nRastar(indRb);
Zb           = nZastar(indRb);
[Rb,iRb]     = max(Rb);
Zb           = Zb(iRb);

if rho>0.7 & length(indRb) ==0 
   Rb = 10;
   Zb = 10;
end

mulim           = zeros(size(rhos));
thetabanane     = zeros(size(rhos));
thetaloss       = zeros(size(rhos));
thetaZBC        = zeros(size(rhos));

mubanane        = sqrt(2*rhos./(R0+rhos));
thetabanane     = asin(mubanane)*180/pi;

ind1            = find(Rb>0&Rb<10&(Rb-R0)>0);
thetaZBC(ind1)  = atan(Zb(ind1)./(Rb(ind1)-R0));
ind2            = find(Rb>0&Rb<10&(Rb-R0)<=0);
thetaZBC(ind2)  = 0.5*pi+atan((R0-Rb(ind2))./Zb(ind2));
ind3            = find(Rb==10);
thetaZBC(ind3)  = pi*ones(1,length(ind3));
thetaZBC        = thetaZBC*180/pi;

ind             = [ind1 ind2];
mulim(ind)      = sqrt(rhos(ind).*(1-cos(thetaZBC(ind)*pi/180))./(rhos(ind)+R0));
mulim(ind3)     = sqrt(2*rhos(ind3)./(R0+rhos(ind3)));
thetaloss(ind)  = asin(mulim(ind))*180/pi;
thetaloss(ind3) = asin(mulim(ind3))*180/pi;
