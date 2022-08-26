function Z = Z_rho_theta(rho,theta,equil,amplitudes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here


amps = num2cell(amplitudes(1:18));
[a, ~,~,~, Zm,d2Z0_0,d4Z0_0, kappam,d2e_0,~, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,~, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    Z1 = [];
else
    Z1 = Zm+kappam.*rho1.*sin(theta)+(1/2).*kappam.*rho1.^2.*(kappam.^(-1).*d2Z0_0+(-2).*(1+(-1).*cos(2.*theta)).*dA2_0+(-2).*sin(2.*theta).*dS2_0)+(1/2).*kappam.*rho1.^3.*sin(theta).*(kappam.^(-1).*d2e_0+(-8).*a.^(-1).*cos(theta).*(sin(theta).*dA3_0+cos(theta).*dS3_0))+(1/24).*kappam.*rho1.^4.*(kappam.^(-1).*d4Z0_0+(-12).*kappam.^(-1).*d2e_0.*dA2_0+(-4).*d3A2_0+4.*cos(2.*theta).*(3.*kappam.^(-1).*d2e_0.*dA2_0+d3A2_0)+(-4).*sin(2.*theta).*(3.*kappam.^(-1).*d2e_0.*dS2_0+d3S2_0));
end

if isempty(rho2)
    Z2 = [];
else
    Z2 = Z0_rho(rho2,equil,amplitudes)+e_rho(rho2,equil,amplitudes).*(rho2.*sin(theta)+a.^(-1).*rho2.^2.*(A3_rho(rho2,equil,amplitudes).*(1+(-1).*cos(theta))+(-1).*S3_rho(rho2,equil,amplitudes).*sin(theta))+(-1).*rho2.*(A2_rho(rho2,equil,amplitudes).*(1+(-1).*cos(2.*theta))+S2_rho(rho2,equil,amplitudes).*sin(2.*theta))+(-1).*a.^(-1).*rho2.^2.*(A3_rho(rho2,equil,amplitudes).*(1+(-1).*cos(3.*theta))+S3_rho(rho2,equil,amplitudes).*sin(3.*theta)));
end

Z = cat(1,Z1,Z2);

end