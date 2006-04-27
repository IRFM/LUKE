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
