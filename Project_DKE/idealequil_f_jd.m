function [filename] = idealequil_f_jd(tokamak,qopt,npsi,ntheta,savename)
%
%   This function generates the data file of an ideal cylindrical magnetic equilibrium with concentric circular 
%   magnetic flux surfaces based on the informations stored in ptok_dke_1yp.
%
%   INPUT:
%
%       - tokamak: tokamak scenario selected (in ptok_dke_1yp)
%       - qopt: option for q profile. (0): constant (default), (1): from qmin and eq
%       - npsi: size of the psi grid (default: 201)
%       - ntheta: size of the theta grid (default: 201)
%       - shift: Shafranov shift [1,npsi] (default: zeros(1,npsi))
%       - kappa: elongation (default: 1)
%       - delta: triangularity (default: 0)
%       - savename: file name for storing the equilibrium 
%           (default: same as tokamak)
%
%   OUTPUT:
%   
%       - filename: filename where data are stored
%
%   NOTE: 
%
%       - the psi grid is generated from the poloidal field on the basis of a uniform corresponding rho grid.
%       - the poloidal field is generated based on the total current.
%
%   WARNINGS: 
%       - corrections based to ideal non-circular-concentric surface 
%           parameters (shift, elongation, triangularity) are not yet implemented 
%
%   By J. Decker <jodecker@mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%
if nargin < 1,error('Tokamak name not specified');end
if nargin < 2,qopt = 0;end
if nargin < 3,npsi = 201;end
if nargin < 4,ntheta = 201;end
if nargin < 5,savename = tokamak;end
%    
[ap,Rp,Zp,xpoint,Bt,...
	 Ip,j0,ja,ej,qmin,eq,...
	 Te0,Tea,eTe,ne0,nea,ene,Ti0,Tia,eTi,...
	 Zi,mi,fi,Zeff0,Zeffa,eZeff,...
	 HXR] = ptok_dke_1yp(tokamak);        
%
zZi = Zi;%[1,ni]
zmi = mi;%[1,ni]
%
prho = linspace(0,1,npsi);%Uniform rho grid
theta = linspace(0,2*pi,ntheta);% Uniform theta grid
%
% Plasma parameters
%
pTe = (Te0 - Tea)*(1 - prho.^2).^eTe + Tea;% Electron temperature (keV)
pne = (ne0 - nea)*(1 - prho.^2).^ene + nea;% Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - prho.^2).^eTi + Tia;% Ion temperatures (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;% Effective charge (a.u.)
%
% Ion parameters
%
nz = length(zZi);
pzTi = repmat(pTi,[nz,1]);% Same temperature for all ion species
pzni = species_dke_yp(pne,pZeff,zZi,fi);
%
%Magnetic equilibrium
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section)
%
%Note: The following calculations are valid only for a circular concentric equilibrium. 
%Moreover, in the following expressions, term of order (ap/Rp)^2 or higher are neglected.
%
Xrho = repmat(prho',[1,ntheta]);
Xtheta = repmat(theta,[npsi,1]);
%
R = Rp + ap*Xrho.*cos(Xtheta);
Z = Zp + ap*Xrho.*sin(Xtheta);
%
qmax = ap/Rp*Bt/Bpa;%Cylindrical safety factor at the plasma edge
%
if qopt == 1,
    pq = (qmax - qmin)*prho.^eq + qmin;% Current profile defined by qmin and eq
else 
    pq = qmax*ones(1,npsi);% Current profile defined with constant q (uniform current density)
end
pBpp = prho*ap/Rp*Bt./pq;
%
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
ftra = [];%Approximate trapped fraction
%
filename = ['EQUIL_',savename,'.mat'];
%
[s,dossier,machine] = comput_dke_yp;
save([dossier,s,filename],'ppsi','theta','R','Z','BR','BZ','BPHI','pTe','pne','pzTi','pzni','zZi','zmi','ftra','HXR')

