function [seBHE,seBH,Elwert,ec,e,t] = bhe_dke_yp(ec_in,k_in,t_in,Z)
%
%	Differential electron-ion bremstrahlung cross-section (dsigma/dk.domega)
%	Bethe-Heitler model including Elwert factor.
%
%	Input:
%
%		- ec: kinetic energy of the incoming electron (keV) [1,m] 
%		- k: photon energy (keV)  [1,n] 
%		- t: cosine of the angle between the direction of displacement of the incoming 
%		  electron and the photon emitted by bremsstrahlung (radian) [1,p]
%		  (default = 0)
%		- Z: target ion charge (default = 1) [1,1]
%
%	Output: 
%
%		- seBHE: Bethe-Heitler + Elwert factor bremstrahlung cross-section (m^2) [p,m,n]
%		- seBH: Bethe-Heitler bremstrahlung cross-section (m^2) [p,m,n]
%		- Elwert: Elwert correction factor [p,m,n]
%		- ec: kinetic energy of the incoming electron (mc2) [p,m,n] 
%		- e: photon energy (mc2)  [p,m,n] 
%		- t: angle between the direction of displacement of the incoming electron and the photon emitted by bremsstrahlung (radian) p,m,n
%
%	Warning: Cross-section units : m^2 but energies are in relativistic units. To get 
%			 cross-sections in standard m^2/keV units, seBH or seBHe must be divided 
%			 by 511 keV.
%
%
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and J. Decker MIT-RLE <jodecker@mit.edu>
%
if nargin < 4,
	infoyp(2,'Wrong number of input arguments for bhe_dke_yp');
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
ep = e0-k;d0 = e0-c.*p0;
ksi0 = alpha*Z*e0./p0;
ksi1 = alpha*Z*ep./p;
%
Elwert = (ksi1./ksi0).*((1-exp(-2*pi*ksi0))./(1-exp(-2*pi*ksi1)));
%
q = sqrt(p0.^2+k.^2-2*p0.*k.*c);
w1 = log((ep.*e0-1+p.*p0)./(ep.*e0-1-p.*p0));
w2 = log((ep+p)./(ep-p));
w3 = log((q+p)./(q-p));
s1 = 8*(s.^2).*(2*e0.^2+1).*(p0.^(-2)).*(d0.^(-4));
s2 = 2*(5*e0.^2+2*e0.*ep+3).*(p0.^(-2)).*(d0.^(-2));
s3 = 2*(p0.^2-k.^2).*(q.^(-2)).*(d0.^(-2));
s4 = 4*ep.*(p0.^(-2)).*(d0.^(-1));
s5 = 4*e0.*(s.^2).*(3*k-(p0.^2).*ep).*(p0.^(-2)).*(d0.^(-4));
s6 = 4*(e0.^2).*(e0.^2+ep.^2).*(p0.^(-2)).*(d0.^(-2));
s7 = (2-2*(7*e0.^2-3*e0.*ep+ep.^2)).*(p0.^(-2)).*(d0.^(-2));
s8 = 2*k.*(e0.^2+ep.*e0-1).*(p0.^(-2)).*(d0.^(-1));
s9 = 4*w2.*(p.^(-1)).*(d0.^(-1));
s10 = w3.*(p.^(-1)).*(q.^(-1));
s11 = 4*d0.^(-2);
s12 = 6*k.*d0.^(-1);
s13 = 2*k.*(p0.^2-k.^2).*(q.^(-2)).*(d0.^(-1));
s14 = w1.*(p.^(-1)).*(p0.^(-1));
%
s0 = s1-s2-s3+s4+s14.*(s5+s6+s7+s8)-s9+s10.*(s11-s12-s13);
a = alpha*Z^2*re^2*p./(8*pi*k.*p0);%Cross-section in cm^2 unit
%
seBH = s0.*a.*mask;
seBHE = seBH.*Elwert;
%
seBHE(isnan(seBHE)) = 0;
seBHE(~isreal(seBHE)) = 0;
