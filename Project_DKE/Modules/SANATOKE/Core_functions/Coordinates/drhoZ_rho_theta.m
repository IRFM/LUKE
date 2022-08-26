function drhoZ = drhoZ_rho_theta(rho,theta,equil,amplitudes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes(1:18));
[a, ~,~,~, ~,~,~, ~,~,~, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,~, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    drhoZ1 = [];
else
    drhoZ1 = (-1).*rho.*sin(theta)+rho.^2.*(2.*cos(2.*theta).*dA2_0+(-4).*cos(theta).*sin(theta).*dS2_0)+rho.^3.*(a.^(-1).*(cos(theta)+3.*cos(3.*theta)).*dA3_0+(-2).*a.^(-1).*(1+3.*cos(2.*theta)).*sin(theta).*dS3_0)+(1/3).*rho.^4.*(cos(2.*theta).*d3A2_0+(-2).*cos(theta).*sin(theta).*d3S2_0);
end


if isempty(rho2)
    drhoZ2 = [];
else
    drhoZ2 = drhoZ0_rho(rho2,equil,amplitudes) ...
        + drhoe_rho(rho2,equil,amplitudes).*(rho2.*sin(theta)+a.^(-1).*rho2.^2.*(A3_rho(rho2,equil,amplitudes).*(1+(-1).*cos(theta))+(-1).*S3_rho(rho2,equil,amplitudes).*sin(theta))+(-1).*rho2.*(A2_rho(rho2,equil,amplitudes).*(1+(-1).*cos(2.*theta))+S2_rho(rho2,equil,amplitudes).*sin(2.*theta))+(-1).*a.^(-1).*rho2.^2.*(A3_rho(rho2,equil,amplitudes).*(1+(-1).*cos(3.*theta))+S3_rho(rho2,equil,amplitudes).*sin(3.*theta))) ...
        + e_rho(rho2,equil,amplitudes).*( ...
        sin(theta) ...
        - ((1-cos(2.*theta)).*A2_rho(rho2,equil,amplitudes) + sin(2.*theta).*S2_rho(rho2,equil,amplitudes)) ...
        - rho2.*((1-cos(2.*theta)).*drhoA2_rho(rho2,equil,amplitudes) + sin(2.*theta).*drhoS2_rho(rho2,equil,amplitudes)) ...
        + 2.*rho2./a.*((cos(3.*theta)-cos(theta)).*A3_rho(rho2,equil,amplitudes) - (sin(theta)+sin(3.*theta)).*S3_rho(rho2,equil,amplitudes)) ...
        + rho2.^2./a.*((cos(3.*theta)-cos(theta)).*drhoA3_rho(rho2,equil,amplitudes) - (sin(theta)+sin(3.*theta)).*drhoS3_rho(rho2,equil,amplitudes)) ...
        );
end

drhoZ = cat(1,drhoZ1,drhoZ2);

end