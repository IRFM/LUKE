function idealequil_f_jd(tokamak,npsi,ntheta,qopt,shift,kappa,delta,savename)
%
%   This function generates the data file of an ideal equilibrium based on
%   the information stored in ptok_dke_1yp.
%
%   INPUTS:
%
%       - tokamak: tokamak scenario selected (in ptok_dke_1yp)
%       - npsi: size of the psi grid (default: 101)
%       - ntheta: size of the theta grid (default: 101)
%       - shift: Shafranov shift [1,npsi] (default: zeros(1,npsi))
%       - kappa: elongation (default: 1)
%       - delta: triangularity (default: 0)
%       - savename: file name for storing the equilibrium 
%           (default: same as tokamak)
%       - qopt: option for q profile. (0): constant (default), (1): from qmin and eq
%
%   NOTE: 
%
%       - the psi grid is generated from the poloidal field on the basis 
%           of a uniform corresponding rho grid.
%       - the poloidal field is generated based on the total current. The
%           current profile is assumed to be flat.
%       - the plasma elevation with respect to the Z axis is taken to be
%           zero.
%
%   WARNINGS: 
%       - corrections based to ideal non-circular-concentric surface 
%           parameters (shift, elongation, triangularity) are not yet implemented 
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
if nargin < 8
	savename = tokamak;
end
if nargin < 7
	delta = 0;
end
if nargin < 6
	kappa = 1;
end
if nargin < 5
	shift = zeros(1,npsi);
end
if nargin < 4
	qopt = 0;
end
if nargin < 3
	ntheta = 201;
end
if nargin < 2
	npsi = 201;
end
if nargin < 1
	error('Tokamak not specified');
end
%
[ap,Rp,Ip,Bt,Ncoils,Zi,mi,fi,BeLi,...
	qmin,eq,Te0,Tea,eTe,eTe_ref,...
	ne0,nea,ene,ene_ref,Ti0,Tia,eTi,Zeff0,Zeffa,eZeff] = ...
		ptok_dke_1yp(tokamak);
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
%
prho = linspace(0,1,npsi);% uniform rho grid
theta = linspace(0,2*pi,ntheta);% uniform theta grid
%
%Plasma parameters
%
pTe = (Te0 - Tea)*(1 - prho.^2).^eTe + Tea;%Electron temperature (keV)
pne = (ne0 - nea)*(1 - prho.^2).^ene + nea;%Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - prho.^2).^eTi + Tia;%Ion temperatures (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;%Effective charge (a.u.)
%
%Ion parameters
%
nz = length(zZi);
pzTi = repmat(pTi,[nz,1]); %same temperature for all ion species
pzni = zeros(nz,npsi);
%
if sum(zZi>1) > 1 %More than one impurity species
    % need each species density
elseif sum(zZi>1) == 1 % One impurity species
    Zimp = max(zZi);
    pnhyd = pne.*(Zimp - pZeff)/(Zimp - 1);  
    pnimp = pne.*(pZeff - 1)/(Zimp - 1)/Zimp;
    pzni(nz,:) = pnimp;
else % No Impurity
    pnhyd = pne;
    pnimp = 0*pne;
end
if sum(fi) == 1
    pzni(1:3,:) = fi'*pnhyd;
else
    error('Hydrogen isotopic fractions do not add to 1')
end    
%
%Magnetic equilibrium
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap); %Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section)
%
%Note: The following calculations are valid only for a circular concentric equilibrium. 
%   Moreover, in the following expressions, term of order (ap/Rp)^2 or
%   higher are neglected.
%
Xrho = repmat(prho',[1,ntheta]);
Xtheta = repmat(theta,[npsi,1]);
%
Zp = 0;
%
R = Rp + ap*Xrho.*cos(Xtheta);
Z = Zp + ap*Xrho.*sin(Xtheta);
%
qmax = ap/Rp*Bt/Bpa;
%
if qopt == 1 %case with current profile defined by qmin and eq
    pq = (qmax - qmin)*prho.^eq + qmin;
else %case with constant q (uniform current density)
    pq = qmax*ones(1,npsi);
end
pBpp = prho*ap/Rp*Bt./pq;
%
%sprho = repmat(prho',[1,npsi]);
spBpp = triu(repmat((pBpp(1:npsi-1) + pBpp(2:npsi))'/2,[1,npsi-1]));
pdprho = diff(prho);
ppsi = [0,ap*Rp*integral_dke_jd(pdprho,spBpp,1)'];
%
%psia = ap*Rp*Bpa/2; %poloidal flux at the edge
%ppsi = prho.^2*psia; %poloidal flux profile
%
XBpp = repmat(pBpp',[1,ntheta]);
BR = -XBpp.*sin(Xtheta)*Rp./R;
BZ = XBpp.*cos(Xtheta)*Rp./R;
BPHI = Bt*Rp./R;
%
filename = ['EQUIL_',savename,'.mat'];
%
eval(['save ',filename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi Ncoils BeLi'])

