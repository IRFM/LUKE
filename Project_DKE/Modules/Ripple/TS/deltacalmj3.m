% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function ripple=deltacalmj3(R,z);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% [delta,ddelta_dR,ddelta_dz,rho]=delta_fit(R,z);
% Approximation du ripple sur Tore Supra
% Formule Basiuk
% [R,z] scalaires, vecteurs ou matrices, unité=m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dernière modif. par LC le 03/08/00
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

x=R-2.04;
racine=sqrt(1+1.04*x-0.2704*z.*z);
rho2=1+0.52*x-racine;
rho1=sqrt(rho2);
ripple=2.2e-4*exp(13.6*rho1+11.83*rho2);
