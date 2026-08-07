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
function R0 = R0_like_rho(rho,rho_star,a,Rm,d2R0_0,d4R0_0,R0_a,dR0_a,d2R0_a,d3R0_a)
%S2_LIKE_RHO Summary of this function goes here
%   Detailed explanation goes here

rho1 = rho(rho<=rho_star);
rho2 = rho(rho>rho_star);

R0_1 = Rm + 1./2.*d2R0_0.*rho1.^2 + 1./24.*d4R0_0.*rho1.^4 ;
R0_2 = R0_a - dR0_a.*(a-rho2) + 1./2.*d2R0_a.*(a-rho2).^2 - 1./6.*d3R0_a.*(a-rho2).^3;

R0 = cat(1,R0_1,R0_2) ;

end
