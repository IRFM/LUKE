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
function rho1=rhocalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);

Ej=1.602e-16*E; 

deltaBmax=bmaxcalcmj3(E,delta,a,R0,B0,NBOB);
sigma=sigmacalcmj3(E,delta,ne,zeff,a,R0,B0,NBOB);
rho1=5*deltaBmax/(2*sigma*sqrt(2*delta));
% facteur 5 devant rho <==> meme resultats que precedents 
