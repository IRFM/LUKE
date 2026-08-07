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
function sigma=sigmacalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);

% on se place dans la limite alfastar<<1 
% constantes :

logcou=17;               % logarithme coulombien
me=9.107e-31;            % masse de l'electron (kg)
qe=1.602e-19;            % charge de l'electron (C)
epsi0=8.854e-12;         % permittivite dans le vide (F.m-1)
c=3e8;                   % vitesse de la lumiere (m.s-1)

Ej=1.602e-16*E;         %energie en joules
v=c*sqrt(1-1/(1+Ej/(me*c^2))^2);
frecoll=(zeff+1)*ne*logcou*qe^4/(4*pi*epsi0^2*me^2*v^3);
Lalfa=16/pi;
deltastar=2*delta;
sigma2=R0*frecoll*Lalfa/(v*NBOB*sqrt(deltastar));
sigma=sqrt(sigma2);
