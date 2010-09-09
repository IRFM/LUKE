function [Ec_ref] = pn2Ec_yp(mksa,momentumDKE)
%LUKE - Calculation of kinetic energy of the fast electrons (in keV)
%
%   Calculation of kinetic energy of the fast electrons (in keV)
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
Ec_ref = mc2*(sqrt(1 + momentumDKE.pn.*momentumDKE.pn*mksa.betath_ref^2) - 1);%Fast electron kinetic energy in keV
