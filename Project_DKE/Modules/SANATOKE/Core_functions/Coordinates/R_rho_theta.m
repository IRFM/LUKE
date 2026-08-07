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
function R = R_rho_theta(rho,theta,equil,amplitudes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes(1:18));
[a, Rm,d2R0_0,d4R0_0, ~,~,~, ~,~,~, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,~, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    R1 = [];
else
    R1 = Rm+rho1.*cos(theta)+(1/2).*rho1.^2.*(d2R0_0+2.*sin(2.*theta).*dA2_0+(-4).*sin(theta).^2.*dS2_0)...
        +(-2).*a.^(-1).*rho1.^3.*sin(2.*theta).*((-1).*cos(theta).*dA3_0+sin(theta).*dS3_0)+(1/24).*rho1.^4.*...
        (d4R0_0+4.*sin(2.*theta).*d3A2_0+(-8).*sin(theta).^2.*d3S2_0);
end

if isempty(rho2)
    R2 = [];
else
    R2 = rho2.*cos(theta)+R0_rho(rho2,equil,amplitudes)+a.^(-1).*rho2.^2.*((1+(-1).*cos(theta)).*S3_rho(rho2,equil,amplitudes)+A3_rho(rho2,equil,amplitudes).*sin(theta))+(-1).*rho2.*((1+(-1).*cos(2.*theta)).*S2_rho(rho2,equil,amplitudes)+(-1).*A2_rho(rho2,equil,amplitudes).*sin(2.*theta))+(-1).*a.^(-1).*rho2.^2.*((1+(-1).*cos(3.*theta)).*S3_rho(rho2,equil,amplitudes)+(-1).*A3_rho(rho2,equil,amplitudes).*sin(3.*theta));
end

R = cat(1,R1,R2);

end