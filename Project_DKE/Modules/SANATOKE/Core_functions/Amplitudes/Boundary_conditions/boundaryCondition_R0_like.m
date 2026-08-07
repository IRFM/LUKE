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
function [d2R0_0,d4R0_0,d2R0_a,d3R0_a] = boundaryCondition_R0_like(a,R0_a,Rm,dR0_a,rho_star)

d2R0_a = (8.*(Rm-R0_a)+(8.*a-3.*rho_star).*dR0_a)./(a.*(4.*a-3.*rho_star)) ;

d2R0_0 = (-12.*(3.*a-rho_star).*(Rm-R0_a) - 6.*(2.*a-rho_star).^2.*dR0_a + (a-rho_star).*(6.*a.^2-4.*a.*rho_star+rho_star.^2).*d2R0_a) ./ ((8.*a.^2-a.*rho_star-rho_star.^2).*rho_star);

d4R0_0 = (72.*(a+rho_star).*(Rm-R0_a) + 24.*(2.*a.^2+2.*a.*rho_star-rho_star.^2).*dR0_a - 12.*a.*(a-rho_star).*(a+2.*rho_star).*d2R0_a) ./ ((8.*a.^2-a.*rho_star-rho_star.^2).*rho_star.^3);

d3R0_a = -6.*(8.*(Rm-R0_a) + (8.*a-3.*rho_star).*dR0_a - a.*(4.*a-3.*rho_star).*d2R0_a) ./ ((8.*a.^2-a.*rho_star-rho_star.^2).*(a-rho_star));

end