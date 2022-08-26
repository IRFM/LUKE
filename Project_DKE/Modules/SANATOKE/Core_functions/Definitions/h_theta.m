function h_theta = h_theta(rho,theta,equil,amplitudes)
% Poloidal scale factor

amps = num2cell(amplitudes(1:18));
[a, ~,~,~, ~,~,~, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0,d3A3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    h_theta1 = [];
else
    h_theta1 = sqrt(rho1.^2.*(kappam.^2.*cos(theta).^2+sin(theta).^2)+(-4).*rho1.^3.*(cos(2.*theta).*(sin(theta).*dA2_0+kappam.^2.*cos(theta).*dS2_0)+(-1).*sin(2.*theta).*((-1).*kappam.^2.*cos(theta).*dA2_0+sin(theta).*dS2_0))+rho1.^4.*(kappam.*cos(theta).^2.*d2e_0+4.*((-1).*cos(2.*theta).*dA2_0+2.*cos(theta).*sin(theta).*dS2_0).^2+(-2).*a.^(-1).*sin(theta).*((cos(theta)+3.*cos(3.*theta)).*dA3_0+(sin(theta)+(-3).*sin(3.*theta)).*dS3_0)+kappam.^2.*(4.*(sin(2.*theta).*dA2_0+cos(2.*theta).*dS2_0).^2+(-2).*a.^(-1).*cos(theta).*((-1).*(sin(theta)+(-3).*sin(3.*theta)).*dA3_0+(cos(theta)+3.*cos(3.*theta)).*dS3_0)))+(-1/3).*rho1.^5.*(12.*kappam.*cos(theta).*d2e_0.*(sin(2.*theta).*dA2_0+cos(2.*theta).*dS2_0)+12.*a.^(-1).*((-1).*cos(2.*theta).*dA2_0+sin(2.*theta).*dS2_0).*((cos(theta)+3.*cos(3.*theta)).*dA3_0+(sin(theta)+(-3).*sin(3.*theta)).*dS3_0)+(-2).*sin(theta).*((-1).*cos(2.*theta).*d3A2_0+sin(2.*theta).*d3S2_0)+(-1).*kappam.^2.*(12.*a.^(-1).*(sin(2.*theta).*dA2_0+cos(2.*theta).*dS2_0).*((-1).*(sin(theta)+(-3).*sin(3.*theta)).*dA3_0+(cos(theta)+3.*cos(3.*theta)).*dS3_0)+(-2).*cos(theta).*(sin(2.*theta).*d3A2_0+cos(2.*theta).*d3S2_0)))+(1/12).*rho1.^6.*(kappam.^2.*cos(theta).^2.*(3.*kappam.^(-2).*d2e_0.^2+kappam.^(-1).*d4e_0)+12.*a.^(-2).*((cos(theta)+3.*cos(3.*theta)).*dA3_0+(sin(theta)+(-3).*sin(3.*theta)).*dS3_0).^2+12.*kappam.*d2e_0.*(4.*(sin(2.*theta).*dA2_0+cos(2.*theta).*dS2_0).^2+(-2).*a.^(-1).*cos(theta).*((-1).*(sin(theta)+(-3).*sin(3.*theta)).*dA3_0+(cos(theta)+3.*cos(3.*theta)).*dS3_0))+16.*((-1).*cos(2.*theta).*dA2_0+sin(2.*theta).*dS2_0).*((-1).*cos(2.*theta).*d3A2_0+sin(2.*theta).*d3S2_0)+(-4).*a.^(-1).*sin(theta).*((cos(theta)+3.*cos(3.*theta)).*d3A3_0+(sin(theta)+(-3).*sin(3.*theta)).*d3S3_0)+4.*kappam.^2.*(3.*a.^(-2).*((-1).*(sin(theta)+(-3).*sin(3.*theta)).*dA3_0+(cos(theta)+3.*cos(3.*theta)).*dS3_0).^2+4.*(sin(2.*theta).*dA2_0+cos(2.*theta).*dS2_0).*(sin(2.*theta).*d3A2_0+cos(2.*theta).*d3S2_0)+(-1).*a.^(-1).*cos(theta).*((-1).*(sin(theta)+(-3).*sin(3.*theta)).*d3A3_0+(cos(theta)+3.*cos(3.*theta)).*d3S3_0))));
end

if isempty(rho2)
    h_theta2 = [];
else
    dthetaR = dthetaR_rho_theta(rho2,theta,equil,amplitudes);
    dthetaZ = dthetaZ_rho_theta(rho2,theta,equil,amplitudes);
    h_theta2 = sqrt(dthetaR.^2+dthetaZ.^2);
end

h_theta = cat(1,h_theta1,h_theta2);

end

