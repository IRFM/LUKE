function [pzni] = species_dke_yp(pne,pZeff,zZi,fi)
%
%   Calculates the ion densities from the simple one fully stripped light impurity like Carbon, and the charge neutrality
%   from the knowledge of the electron density and effective charge profiles.
%
%   By J. Decker <jodecker@mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%
if nargin < 4,error('Not enough arguments');end
%
nz = length(zZi);
npsi = length(pne);
%
pzni = zeros(nz,npsi);
%
if sum(zZi>1) > 1%More than one impurity species
	 error('need each species density from impurity transport code')
elseif sum(zZi>1) == 1%One impurity species
	 Zimp = max(zZi);
	 pnhyd = pne.*(Zimp - pZeff)/(Zimp - 1);  
	 pnimp = pne.*(pZeff - 1)/(Zimp - 1)/Zimp;
	 pzni(nz,:) = pnimp;
else %No Impurity
	 pnhyd = pne;
	 pnimp = 0*pne;
end
if sum(fi) == 1
	 pzni(1:3,:) = fi'*pnhyd;
else
	 error('Hydrogen isotopic fractions do not add to 1')
end   
clear fi	   

