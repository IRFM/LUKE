function [seHC,seH,fee,ec,e,t] = haug_dke_yp(ec_in,k_in,t_in)
%
%	Differential electron-electron bremstrahlung cross-section (dsigma/dk.domega)
%	Haug model including Coulomb correction factor.
%
%	Input:
%
%		- ec: kinetic energy of the incoming electron (keV) [1,m] 
%		  (default = 500)
%		- e: photon energy (keV)  [1,n] 
%		- t: angle between the speed direction of the incoming electron and 
%		  the direction of emission of the bremsstrahlung photon (radian) [1,p]
%		  (default = 0)
%
%	Output: 
%
%		- seHC: Haug + Coulomb factor bremstrahlung cross-section (m^2) [p,m,n]
%		- seH: Haug bremstrahlung cross-section (m^2) [p,m,n]
%		- fee: Elwert correction factor [p,m,n]
%		- ec: kinetic energy of the incoming electron (mec2) [p,m,n] 
%		- e: photon energy (mec2) [p,m,n] 
%		- t: angle between the direction of displacement of the incoming electron and the photon emitted by bremsstrahlung (radian) [p,m,n] 
%
%	Warning: Cross-section units : m^2 but energies are in relativistic units. To get 
%			 cross-sections in standard m^2/keV units, seH or seHC must be divided 
%			 by 511 keV.
%

%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and J. Decker MIT-RLE <jodecker@mit.edu>
%
if nargin < 3,
	infoyp(2,'Wrong number of input arguments for haug_dke_yp');
	return;
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Physics constant
%
ec = repmat(ones(length(t_in),1)*ec_in(:)'/mc2,[1,1,length(k_in)]);%Relativistic units
k = shiftdim(repmat(ones(length(ec_in),1)*k_in(:)'/mc2,[1,1,length(t_in)]),2);%Relativistic units
c = repmat(t_in(:)*ones(1,length(ec_in)),[1,1,length(k_in)]);
%
s = sqrt(1-c.^2);
%
mask = ec > k;%Photon are only emitted by electron of higher energies
%
e0 = ec+1;
p0 = sqrt(e0.^2-1);
v0 = p0./e0;
p = sqrt((e0-k).^2-1);
ep = e0-k;
%
%Calculation parameters
%
x1 = k.*(e0-p0.*c);
x2 = k;
w2 = 2.*(e0+1);
x = x1+x2;
rho2 = w2-2.*x;
w24 = w2-4;
rho24 = rho2-4;
w22 = w2-2;
rho22 = rho2-2;
%
%Coulomb correction factor
%
betaw = sqrt(w2).*sqrt(w24)./w22;
betarho = sqrt(rho2).*sqrt(rho24)./rho22;
ap = alpha./betaw;
a2 = alpha./betarho;
fee = (a2./ap).*(exp(2.*pi.*ap)-1)./(exp(2.*pi.*a2)-1);
%
r1 = rho24+4*x1+4*(x1.^2)./rho2;
r2 = rho24+2*x1;
gw2 = sqrt(x2.*(rho24.*x2./4+2*x.*x1./rho2));
gw4 = sqrt(w24.*(w24.*rho24./4+4*x1.*x2./rho2));
xl = log((r2+sqrt(rho24.*r1)).*sqrt(rho2)./(4.*x1));
xl1 = log((sqrt(rho2)+sqrt(rho24))./2);
xl2 = log(1+rho2.*(rho24.*x2+2*sqrt(rho24).*gw2)./(4*x.*x1));
xl3 = log(((sqrt(w2).*sqrt(rho24)+sqrt(rho2).*sqrt(w24)).^2)./(8*x));
xl4 = log(1+rho2.*(w24.*rho24+2*sqrt(rho24).*gw4)./(8*x1.*x2));
%
%Main expression
%
s0 = sqrt(rho24);
s1 = (w2+rho2).*(((x1-x2)./x).^2)./(4*x1.*x2);
s2 = -0.25*((1./x1-1./x2).^2);
s3 = -rho2./(2*(x.^2));
s4 = 2*(1+1./w24).*(rho2./(w24.*x1.*x2));
s5 = 4*rho2./(w2.*w24.*x1.*x1.*x1.*x1);
s6 = 3*(w22.^2).*x1.*x2./w24;
s7 = -2*(x.^2).*(1+6*1./(w2.*w24));
s8 = -4*rho2.*x./(w24.*x1.*x1.*x1);
s9 = rho2.*(4*1./w2-1.5-8*1./(w2.*(w24.^2))+w22.*x./(w2.*w24))./(x1.^2);
s10 = -rho2./(w24.*x1);
s11 = (w2-4*x2)./rho2;
s12 = -w2.*w24./(4*x1.*x2);
s13 = -4./x1;
s14 = (w2-w22.*(rho2./2))./(x1.^2);
%
z1 = (s1+s2+s3+s4+s5.*(s6+s7)+s8+s9+s10+(s11+s12+s13+s14)./r1).*s0;
%
s0 = xl./sqrt(r1);
s1 = 4+(10-w2./2)./x2;
s2 = -2*(2.*w2-x2+4)./x1;
s3 = 3*w2.*w24./(4*x1.*x2);
s4 = 4.0./(x1.*r2);
s5 = x2-3*x1+4+2*(rho2-3)./x1;
s6 = (w24-4*x1.*x2./rho2)./(x1.*r1);
s7 = w2.*r2./(4*x2)-rho22-2*x1;
%
z2 = s0.*(s1+s2+s3+s4.*s5+s6.*s7);
%
z3 = sqrt(rho2).*xl1.*((rho2+2)./(x.^2)+8*1./(x1.^2));
%
s0 = xl2./gw2;
s1 = 2*w22./x2;
s2 = -(rho22-x2)./x1;
s3 = rho22.*(rho2+x1)./(2*x);
s4 = w24./r2-2+rho22.*((w24+rho2).^2)./(8*x.*x1);
s5 = 1./(r2.*x1);
s6 = rho22.*(x2.*(w24+rho2)./2-w22)-2*(x2.^2)-4*x2;
s7 = 1./(r2.*x);
s8 = 0.5*rho22.*(3*rho24-w2.*(rho2-5))+2.*(x1.^2)-6*x1+w22.*x2;
%
z4 = s0.*(s1+s2+s3+s4+s5.*s6+s7.*s8);
%
s0 = 2*sqrt(rho2).*xl3./(sqrt(w2).*sqrt(w24).*x1);
s1 = 4+8*w22./(w24.^2);
s2 = -3*0.5*w22./x2;
s3 = ((x2.^2)-2*w2-(w2-1).*x2+0.5*(w22.^2))./x1;
s4 = (0.5*rho2.*rho22./x)-(x2.*w22.*0.5./x);
s5 = -((w22.^2).*(rho2+w24))./(4*x.*x2);
s6 = x./(4*x1.*x2);
s7 = ((w22.^2)+rho22.*rho24)-8*rho22./w24;
s8 = 4*(x.^2)./(w2.*w24.*x1);
s9 = -(2*rho22.*x2+w24.*x-4*w22+w22.*(8-rho2)./(2*x1))./r2;
s10 = (rho22.*0.5.*(3*rho24-w2.*(rho2-5))-x1.*(w2+4-2*x1))./(x.*r2);
s11 = 2*(w2.*w22.*rho24-2*rho22+4*rho2./w2)./((w24.^2).*x1);
s12 = 4*w22.*x./(w24.*(x1.^2));
s13 = (12*x./(w2.*w24))-rho22./2;
s14 = 1-x./(w2.*x1);
%
z5 = s0.*(s1+s2+s3+s4+s5+s6.*s7+s8+s9+s10+s11+s12.*s13.*s14);
%
s0 = (-1).*xl4./gw4;
s1 = 1;
s2 = rho22./(8.*x1.*x2);
s3 = w22.^2+(rho22.^2)-6.*(w24+rho2)+16.*x./w24;
s4 = 2.*(1-x1-(x1.^2))./(x1.*x2);
s5 = (rho24-8./w24)./w24;
%
z6 = s0.*(s1+s2.*s3+s4+s5);
%
z7a = z1+z2+z3+z4+z5+z6;
%
x0 = x1;
x1 = x2;
x2 = x0;
%
r1 = rho24+4*x1+4*(x1.^2)./rho2;
r2 = rho24+2*x1;
gw2 = sqrt(x2.*(rho24.*x2./4+2*x.*x1./rho2));
gw4 = sqrt(w24.*(w24.*rho24./4+4*x1.*x2./rho2));
xl = log((r2+sqrt(rho24.*r1)).*sqrt(rho2)./(4.*x1));
xl1 = log((sqrt(rho2)+sqrt(rho24))./2);
xl2 = log(1+rho2.*(rho24.*x2+2*sqrt(rho24).*gw2)./(4*x.*x1));
xl3 = log(((sqrt(w2).*sqrt(rho24)+sqrt(rho2).*sqrt(w24)).^2)./(8*x));
xl4 = log(1+rho2.*(w24.*rho24+2*sqrt(rho24).*gw4)./(8*x1.*x2));
%
%Main expression...
%
s0 = sqrt(rho24);
s1 = (w2+rho2).*(((x1-x2)./x).^2)./(4*x1.*x2);
s2 = -0.25*((1./x1-1./x2).^2);
s3 = -rho2./(2*(x.^2));
s4 = 2*(1+1./w24).*(rho2./(w24.*x1.*x2));
s5 = 4*rho2./(w2.*w24.*x1.*x1.*x1.*x1);
s6 = 3*(w22.^2).*x1.*x2./w24;
s7 = -2*(x.^2).*(1+6./(w2.*w24));
s8 = -4*rho2.*x./(w24.*x1.*x1.*x1);
s9 = rho2.*(4./w2-1.5-8./(w2.*(w24.^2))+w22.*x./(w2.*w24))./(x1.^2);
s10 = -rho2./(w24.*x1);
s11 = (w2-4*x2)./rho2;
s12 = -w2.*w24./(4*x1.*x2);
s13 = -4./x1;
s14 = (w2-w22.*(rho2./2))./(x1.^2);
%
z1 = (s1+s2+s3+s4+s5.*(s6+s7)+s8+s9+s10+(s11+s12+s13+s14)./r1).*s0;
%
s0 = xl./sqrt(r1);
s1 = 4+(10-w2./2)./x2;
s2 = -2*(2.*w2-x2+4)./x1;
s3 = 3*w2.*w24./(4*x1.*x2);
s4 = 4./(x1.*r2);
s5 = x2-3*x1+4+2*(rho2-3)./x1;
s6 = (w24-4*x1.*x2./rho2)./(x1.*r1);
s7 = w2.*r2./(4*x2)-rho22-2*x1;
%
z2 = s0.*(s1+s2+s3+s4.*s5+s6.*s7);
%
z3 = sqrt(rho2).*xl1.*((rho2+2)./(x.^2)+8./(x1.^2));
%
s0 = xl2./gw2;
s1 = 2*w22./x2;
s2 = -(rho22-x2)./x1;
s3 = rho22.*(rho2+x1)./(2*x);
s4 = w24./r2-2+rho22.*((w24+rho2).^2)./(8*x.*x1);
s5 = 1./(r2.*x1);
s6 = rho22.*(x2.*(w24+rho2)./2-w22)-2*(x2.^2)-4*x2;
s7 = 1./(r2.*x);
s8 = 0.5*rho22.*(3*rho24-w2.*(rho2-5))+2.*(x1.^2)-6*x1+w22.*x2;
%
z4 = s0.*(s1+s2+s3+s4+s5.*s6+s7.*s8);
%
s0 = 2*sqrt(rho2).*xl3./(sqrt(w2).*sqrt(w24).*x1);
s1 = 4+8*w22./(w24.^2);
s2 = -3*0.5*w22./x2;
s3 = ((x2.^2)-2*w2-(w2-1).*x2+0.5*(w22.^2))./x1;
s4 = (0.5*rho2.*rho22./x)-(x2.*w22.*0.5./x);
s5 = -((w22.^2).*(rho2+w24))./(4*x.*x2);
s6 = x./(4*x1.*x2);
s7 = ((w22.^2)+rho22.*rho24)-8*rho22./w24;
s8 = 4*(x.^2)./(w2.*w24.*x1);
s9 = -(2*rho22.*x2+w24.*x-4*w22+w22.*(8-rho2)./(2*x1))./r2;
s10 = (rho22.*0.5.*(3*rho24-w2.*(rho2-5))-x1.*(w2+4-2*x1))./(x.*r2);
s11 = 2*(w2.*w22.*rho24-2*rho22+4*rho2./w2)./((w24.^2).*x1);
s12 = 4*w22.*x./(w24.*(x1.^2));
s13 = (12*x./(w2.*w24))-rho22./2;
s14 = 1-x./(w2.*x1);
%
z5 = s0.*(s1+s2+s3+s4+s5+s6.*s7+s8+s9+s10+s11+s12.*s13.*s14);
%
s0 = (-1).*xl4./gw4;
s1 = 1;
s2 = rho22./(8.*x1.*x2);
s3 = w22.^2+(rho22.^2)-6.*(w24+rho2)+16.*x./w24;
s4 = 2.*(1-x1-(x1.^2))./(x1.*x2);
s5 = (rho24-8./w24)./w24;
%
z6 = s0.*(s1+s2.*s3+s4+s5);
%
z7b = z1+z2+z3+z4+z5+z6;
%
z8 = z7a+z7b;
seH = alpha*(re^2).*k.*z8./(pi*sqrt(w2).*sqrt(rho2).*sqrt(w24));
seHC = alpha*(re^2).*k.*z8.*fee./(pi*sqrt(w2).*sqrt(rho2).*sqrt(w24));
%
fee(find(imag(fee)~=0)) = 0;
seH(find(imag(seH)~=0)) = 0;
seHC(find(imag(seHC)~=0)) = 0;
seHC(isnan(seHC)) = 0;
seH(isnan(seH)) = 0;
seHC(isnan(seHC)) = 0;