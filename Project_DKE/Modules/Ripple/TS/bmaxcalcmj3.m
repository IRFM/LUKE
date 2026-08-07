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
% E en keV 
% on se place dans la limite alfastar<<1
% on neglige la variation de la transformee rotationnelle

function deltaBmax=bmaxcalcmj3(E,delta,a,R0,B0,NBOB);

me=9.107e-31;
qe=1.602e-19;
c=3e8;

Ej=1.602e-16*E;
v=c*sqrt(1-1/(1+Ej/(me*c^2))^2);

Talfa=12;
lambdadelta=R0/(NBOB);
const=Talfa*me/(2*qe*B0*NBOB*lambdadelta);
deltaBmax=const*v*sqrt(delta);
