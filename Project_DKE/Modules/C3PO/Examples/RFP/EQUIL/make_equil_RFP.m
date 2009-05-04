%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters for reverse field pinch (based on MST machine at Madison, Wisconsin, USA)
%
%   By J. Decker <joan.decker@cea.fr> and Y. Peysson <yves.peysson@cea.fr>
%
clear all
close all
clear functions
clear mex
%
equil.id = 'RFP';% scenario identification
%
npsi = 101;% number of points in psi grid
ntheta = 65;% number of points in theta grid
%
% Equilibrium parameters
%
ap = 0.5;%  Plasma minor radius on LFS midplane (m)
Rp = 1.5;%  Plasma major radius on axis (m)
Zp = 0;%  Global plasma vertical shift (m)
%
Ip = 0.3;%  Plasma current (MA)  
%
Bt = 0.2;%  Toroidal magnetic field on the magnetic axis (T) 
lambda = 2.2;%BFM magentic equilbrium model for RFP
%
Zi = [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0 = 1.3;%  Core electron temperature (keV)
Tea = 0.1*Te0;%  Edge electron temperature (keV)
eTe = 1.1;%  Exponent for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^2)^eTe + Tea)
%
ne0 = 1.4e19;%  Core electron density (m-3)
nea = 0.24*ne0;%  Edge electron density (m-3)
ene = 1.3;%  Exponent for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^2)^ene + nea)
%
Ti0 = 0.35;%  Core ion temperature (keV)
Tia = 0.1*Ti0;%  Edge ion temperature (keV)
eTi = 1.1;%  Exponent for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^2)^eTi + Tia)
%
Zeff0 = 2.0;%  Core effective charge (a.u.)
Zeffa = 2.0;%  Edge effective charge (a.u.)
eZeff = 0;%  Exponent for the effective charge (Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa)
%
equil.zZi = Zi;%[1,ni]
equil.zmi = mi;%[1,ni]
equil.fi = fi;%[1,3]
%
prho = linspace(0,1,npsi);%Uniform rho grid
equil.theta = linspace(0,2*pi,ntheta);% Uniform theta grid
%
% Plasma parameters
%
equil.pTe = (Te0 - Tea)*(1 - prho.^2).^eTe + Tea;% Electron temperature (keV)
equil.pne = (ne0 - nea)*(1 - prho.^2).^ene + nea;% Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - prho.^2).^eTi + Tia;% Ion temperatures (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;% Effective charge (a.u.)
%
% Ion parameters
%
nz = length(equil.zZi);
equil.pzTi = repmat(pTi,[nz,1]);% Same temperature for all ion species
equil.pzni = species_dke_yp(equil.pne,pZeff,equil.zZi,fi);
%
%Magnetic equilibrium
%
%Note: The following calculations are valid only for a circular concentric equilibrium. 
%Moreover, in the following expressions, term of order (ap/Rp)^2 or higher are neglected.
%
Xrho = repmat(prho',[1,ntheta]);
Xtheta = repmat(equil.theta,[npsi,1]);
%
equil.ptx = ap*Xrho.*cos(Xtheta);
equil.pty = ap*Xrho.*sin(Xtheta);
%
pBphi = Bt*besselj(0,lambda*prho);%RFP BFM model
pBpp = Bt*besselj(1,lambda*prho);%RFP BFM model
%
pq = prho.*besselj(0,lambda*prho)*ap./besselj(1,lambda*prho)/Rp;%Safety factor
%
spBpp = triu(repmat((pBpp(1:npsi-1) + pBpp(2:npsi))'/2,[1,npsi-1]));
pdprho = diff(prho);
equil.psi_apRp = [0,ap*ap*integral_dke_jd(pdprho,spBpp,1)'];
%
%psia = ap*Rp*Bpa/2; %poloidal flux at the edge
%ppsi = prho.^2*psia; %poloidal flux profile
%
XBpp = repmat(pBpp',[1,ntheta]);
equil.ptBx = -XBpp.*sin(Xtheta)*Rp./(equil.ptx + Rp);
equil.ptBy = XBpp.*cos(Xtheta)*Rp./(equil.ptx + Rp);
equil.ptBPHI = repmat(pBphi',[1,ntheta])*Rp./(equil.ptx + Rp);
%
equil.Rp = Rp;
equil.Zp = Zp;
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])
