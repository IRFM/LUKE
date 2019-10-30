function [Zeff] = zeff_adas_yp(adas,zZi,zmi,pzni,pzTi,pne,pTe)
%
%   Calculates radial profile of the  effective charge Zeff from fractions of all ionisation states of different species in a plasma of a given electron temperature profile. 
%   Use the Atomic Data and Analysis Structure (ADAS). 
%
%   INPUTS:
%
%       - adas : Atomic Data and Analysis Structure 
%       - zZi : vector of all ions atomic numbers (zZi = [1,1,1,Zi1,Zi2,...,Zim], the first three values are corresponding to different isotopes of hydrogen) [1,m]
%       - zmi : vector of all ions atomic weights (fH,fD,fT,mi1,mi2,...,mim] where fH+fD+fT=1 and fx are the relative fractions of hydrogen isotopes) [1,m]
%       - pzni : matrix of ion density profiles, Zi = sum(Zij) (m-3) [m,nr]
%       - pzTi : matrix of ion temperature profiles Zi = sum(Zij) (keV) [m,nr]
%       - pTe : electron temperature profile (keV) [1,nr]
%       - pne : electron density profile profile (m-3) [1,nr]
%
%   OUTPUTS:
%
%       - Zeff : effective charge radial profile [1,nr]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
[zZi,~,zmi,pzni,pzTi] = ionisation_adas_yp(adas,zZi,zmi,pzni,pzTi,pne,pTe);
%
pzZi = zZi(:)*ones(1,length(pne));
Zeff = sum(pzni.*pzZi.*pzZi)./pne;

