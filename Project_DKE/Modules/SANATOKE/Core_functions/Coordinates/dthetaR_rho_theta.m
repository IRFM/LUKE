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
function dthetaR = dthetaR_rho_theta(rho,theta,equil,amplitudes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes(1:18));
[a, ~,~,~, ~,~,~, ~,~,~, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,~, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    dthetaR1 = [];
else
    dthetaR1 = (-1).*rho1.*sin(theta)+rho1.^2.*(2.*cos(2.*theta).*dA2_0+(-4).*cos(theta).*sin(theta).*dS2_0)+rho1.^3.*(a.^(-1).*(cos(theta)+3.*cos(3.*theta)).*dA3_0+(-2).*a.^(-1).*(1+3.*cos(2.*theta)).*sin(theta).*dS3_0)+(1/3).*rho1.^4.*(cos(2.*theta).*d3A2_0+(-2).*cos(theta).*sin(theta).*d3S2_0);
end

if isempty(rho2)
    dthetaR2 = [];
else
    dthetaR2 = (-1).*rho2.*sin(theta)+a.^(-1).*rho2.^2.*(A3_rho(rho2,equil,amplitudes).*cos(theta)+S3_rho(rho2,equil,amplitudes).*sin(theta))+(-1).*rho2.*((-2).*A2_rho(rho2,equil,amplitudes).*cos(2.*theta)+2.*S2_rho(rho2,equil,amplitudes).*sin(2.*theta))+(-1).*a.^(-1).*rho2.^2.*((-3).*A3_rho(rho2,equil,amplitudes).*cos(3.*theta)+3.*S3_rho(rho2,equil,amplitudes).*sin(3.*theta));
end

dthetaR = cat(1,dthetaR1,dthetaR2);

end