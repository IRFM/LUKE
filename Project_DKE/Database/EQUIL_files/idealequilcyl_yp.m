function [ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test,prho,pspsin,pspsinT] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,qmin_Rpap,eq,qopt,npsi,ntheta)
%
% Create ideal cylindrical magnetic equilibrium with circular concentric flux surfaces from parametric description
%
% by Y.Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin < 10,
    ntheta = 65;% 65 poloidal grid points by default
end
%
if nargin < 9,
    npsi = 101;% 101 radial profile grid points by default
end
%
[qe,me,mp,mn,e0,mu0] = pc_dke_yp;
%
Bpa = mu0*Ip*1e6/(2*pi*ap);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section). Moreover, in the following expressions, term of order (ap/Rp)^2 or higher are neglected.	
qmax_Rpap = abs(Bt/Bpa);%Normalized cylindrical safety factor at the plasma edge
%
prho = linspace(0,1,npsi);%Initial grid
theta = linspace(0,2*pi,ntheta);%Initial grid
%
Xrho = repmat(prho',[1,ntheta]);
Xtheta = repmat(theta,[npsi,1]);
%
x = ap*Xrho.*cos(Xtheta);
y = ap*Xrho.*sin(Xtheta);
%
if qopt == 1,
	 pq_Rpap = (qmax_Rpap - qmin_Rpap)*prho.^eq + qmin_Rpap;% Current profile defined by qmin and eq
	 pdq_Rpap = eq*(qmax_Rpap - qmin_Rpap)*prho.^(eq-1);
else 
	 pq_Rpap = qmax_Rpap*ones(1,npsi);% Current profile defined with constant q (uniform current density)
	 pdq_Rpap = zeros(1,npsi);
end
%
pBpp = sign(Bpa)*prho*abs(Bt)./pq_Rpap;
%
spBpp = triu(repmat((pBpp(1:npsi-1) + pBpp(2:npsi))'/2,[1,npsi-1]));
pdprho = diff(prho);
ppsi_apRp = [0,ap^2*integral_dke_jd(pdprho,spBpp,1)'];%psi_apRp = psi(poloidal usual)*ap/Rp for the cylindrical limit
ppsin = ppsi_apRp/max(ppsi_apRp);%Uniform normalized magnetic flux surface grid
%
pspsin = sqrt(ppsin);
%
ppsiT = pi*Bt*ap^2*prho.^2;%Toroidal magnetic flux
ppsinT = ppsiT/ppsiT(end);%Normalized toroidal magnetic flux
pspsinT = sqrt(ppsinT);
%
XBpp = repmat(pBpp',[1,ntheta]);
Bx = -XBpp.*sin(Xtheta)./(1 + x/Rp);
By = XBpp.*cos(Xtheta)./(1 + x/Rp);
BPHI = Bt./(1 + x/Rp);
%
pj = (Bt/ap/mu0).*(2./pq_Rpap - pdq_Rpap.*prho./pq_Rpap.^2);%Current density profile (A.m-2)
%
for ii = 1:length(prho),
    pIp(ii) = 2*pi*trapz_dke_yp([prho(1:ii)',prho(1:ii)'.*pj(1:ii)'])*ap*ap; 
    pmag(ii) = -trapz_dke_yp([prho(1:ii)',pBpp(1:ii)'.*pj(1:ii)'])*ap;
end
pIp(2) = pIp(1);
pmag(2) = pmag(1);
Ip_test = pIp(end)/1e6;%Plasma current (MA)
pmag = (pmag - pmag(end))/qe/1000;%Total pressure consistent with the cylindrical magnetic equilibrium. Pressure is enforced to zero at the plasma edge (special units for helmex77 in keV.m-3)
%
