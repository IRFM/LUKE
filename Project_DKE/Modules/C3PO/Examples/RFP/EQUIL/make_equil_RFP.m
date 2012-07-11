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
lambda = 2.2;%BFM magnetic equilbrium model for RFP
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
% Plasma parameters
%
[prho,equil_prof.pTe,equil_prof.pne,equil_prof.pzTi,equil_prof.pzni,equil_prof.zZi,equil_prof.zmi,equil_prof.fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,2,eTe,ne0,nea,2,ene,Ti0,Tia,2,eTi,Zeff0,Zeffa,eZeff,NaN,npsi);%Profiles
%
%Magnetic equilibrium
%
[ppsin,equil_mag.psi_apRp,equil_mag.theta,equil_mag.ptx,equil_mag.pty,equil_mag.ptBx,equil_mag.ptBy,equil_mag.ptBPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,[],[],[],npsi,ntheta,lambda);%Cylindrical magnetic equilibrium
%
equil_mag.Rp = Rp;
equil_mag.Zp = Zp;
%
equil = conc_struct_jd(equil_mag,equil_prof);
equil.id = 'RFP';% scenario identification 
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])


