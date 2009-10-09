%
% This script generates the data file for an idealized EARth equilibrium.
%
% By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%
clear all
%
id = 'EARTH';% scenario identification
%
RE = 6371e3;% earth radius (m)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
npsi = 101;% number of points in psi grid
ntheta = 161;%65;% number of points in theta grid
%
% Equilibrium parameters
%
RL = 5*RE;%  Average limit of the plasmasphere from earth center (m)
%
M = -7.84e22;% 1990 measurements
%
equil_prof.zZi = [1,1,1];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
equil_prof.zmi = [1,2,3];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
zfi = [1,0,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0 = 0.2e-3;%  Core electron temperature (keV)
Tea = 1.2e-3;%  Edge electron temperature (keV)
%
ne0 = 1e10;%  Core electron density (m-3)
nea = 1e9;%  Edge electron density (m-3)
%
Ti0 = Te0;%  Core ion temperature (keV)
Tia = Tea;%  Edge ion temperature (keV)
%
% Plasma parameters
%
prho = linspace(0,1,npsi); 
%
equil_prof.pTe = Te0 + prho*(Tea-Te0);%linear approximation
pTi = Ti0 + prho*(Tia-Ti0);%linear approximation
%
equil_prof.pne = ne0*exp(log(nea/ne0)*prho); 
pni = equil_prof.pne;
%
equil_prof.pzTi = ones(3,1)*pTi;
equil_prof.pzni = zfi.'*pni;
%
%Magnetic equilibrium
%
equil_magnetic = equildipole_fxd(RL-RE,RE,M,prho,ntheta);
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
equil.id = id;
%
filename = ['EQUIL_',equil.id,'.mat'];
%
save(filename,'equil');
%