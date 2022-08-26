function drhoR = drhoR_rho_theta(rho,theta,equil,amplitudes)

amps = num2cell(amplitudes(1:18));
[a, ~,d2R0_0,d4R0_0, ~,~,~, ~,~,~, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0,d3A3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    drhoR1 = [];
else
    drhoR1 = cos(theta)+rho1.*(d2R0_0+2.*cos(theta).*sin(theta).*dA2_0+sin(2.*theta).*dA2_0+(-4).*sin(theta).^2.*dS2_0)+12.*a.^(-1).*rho1.^2.*sin(theta).*(cos(theta).^2.*dA3_0+(-1).*cos(theta).*sin(theta).*dS3_0)+(1/6).*rho1.^3.*(d4R0_0+6.*cos(theta).*sin(theta).*d3A2_0+sin(2.*theta).*d3A2_0+(-8).*sin(theta).^2.*d3S2_0)+(10/3).*a.^(-1).*rho1.^4.*sin(theta).*(cos(theta).^2.*d3A3_0+(-1).*cos(theta).*sin(theta).*d3S3_0);
end

if isempty(rho2)
    drhoR2 = [];
else
    drhoR2 = drhoR0_rho(rho2,equil,amplitudes) + cos(theta) ...
        + (cos(2.*theta)-1).*S2_rho(rho2,equil,amplitudes) + sin(2.*theta).*A2_rho(rho2,equil,amplitudes) ...
        + rho2.*((cos(2.*theta)-1).*drhoS2_rho(rho2,equil,amplitudes) + sin(2.*theta).*drhoA2_rho(rho2,equil,amplitudes)) ...
        + 2.*rho2./a.*((cos(3.*theta)-cos(theta)).*S3_rho(rho2,equil,amplitudes) + (sin(theta)+sin(3.*theta)).*A3_rho(rho2,equil,amplitudes)) ...
        + rho2.^2./a.*((cos(3.*theta)-cos(theta)).*drhoS3_rho(rho2,equil,amplitudes) + (sin(theta)+sin(3.*theta)).*drhoA3_rho(rho2,equil,amplitudes)) ;
end

drhoR = cat(1,drhoR1,drhoR2);

end