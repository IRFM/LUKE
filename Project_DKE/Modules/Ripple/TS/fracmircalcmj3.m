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
% Calcul de la fraction restant dans les miroirs en fonction de l'energie :
% E = energie initiale en keV de la particule piegee 

function f=fracmircalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);

n=5000;
rho1=rhocalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);
nume=(rho1/2)*(1+erf(sqrt(n/2)*rho1))+(1/sqrt(2*pi*n))*exp((-1)*n*rho1^2/2);
deno=(rho1/2)*(1+erf(sqrt(1/2)*rho1))+(1/sqrt(2*pi))*exp((-1)*rho1^2/2);
f=nume/deno;
