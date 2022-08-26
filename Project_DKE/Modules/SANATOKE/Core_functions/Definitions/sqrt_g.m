function sqrt_g = sqrt_g(rho,theta,equil,amplitudes)
% Jacobian

amps = num2cell(amplitudes(1:18));
[a, Rm,d2R0_0,d4R0_0, ~,d2Z0_0,d4Z0_0, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0,d3A3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    sqrt_g1 = [];
else
    sqrt_g1 = Rm.*kappam.*rho1+kappam.*rho1.^2.*(Rm.*sin(theta).*(kappam.^(-1).*d2Z0_0+(-2).*dA2_0)+cos(theta).*(1+Rm.*(d2R0_0+(-2).*dS2_0)))+(1/2).*kappam.*rho1.^3.*(2.*(d2R0_0+(-2).*dS2_0)+sin(2.*theta).*(kappam.^(-1).*d2Z0_0+(-4).*Rm.*(d2R0_0.*dA2_0+(-1).*kappam.^(-1).*d2Z0_0.*dS2_0))+cos(2.*theta).*(d2R0_0+(-1).*Rm.*(kappam.^(-1).*d2e_0+4.*(kappam.^(-1).*d2Z0_0+(-2).*dA2_0).*dA2_0+4.*(d2R0_0+(-2).*dS2_0).*dS2_0))+2.*Rm.*(kappam.^(-1).*d2e_0+(-4).*(dA2_0.^2+dS2_0.^2)+(-4).*a.^(-1).*dS3_0))+(1/12).*kappam.*rho1.^4.*(6.*sin(theta).*(d2R0_0.*(kappam.^(-1).*d2Z0_0+(-4).*dA2_0)+4.*a.^(-1).*dA3_0+2.*kappam.^(-1).*d2Z0_0.*dS2_0)+3.*cos(theta).*(3.*kappam.^(-1).*d2e_0+(-2).*dA2_0.*(kappam.^(-1).*d2Z0_0+6.*dA2_0)+2.*d2R0_0.*(d2R0_0+(-5).*dS2_0)+(-4).*dS2_0.^2+(-20).*a.^(-1).*dS3_0)+(-1).*cos(3.*theta).*(3.*kappam.^(-1).*d2e_0+18.*(kappam.^(-1).*d2Z0_0+(-2).*dA2_0).*dA2_0+(6.*d2R0_0+(-12).*dS2_0).*dS2_0+(-12).*a.^(-1).*dS3_0)+(-4).*cos(2.*theta).*sin(theta).*((-6).*a.^(-1).*dA3_0+(-9).*kappam.^(-1).*d2Z0_0.*dS2_0+3.*dA2_0.*(d2R0_0+4.*dS2_0)+Rm.*(3.*kappam.^(-1).*d2e_0.*dA2_0+6.*a.^(-1).*dA3_0.*(3.*d2R0_0+(-2).*dS2_0)+(-6).*a.^(-1).*(3.*kappam.^(-1).*d2Z0_0+(-2).*dA2_0).*dS3_0+(-2).*d3A2_0))+2.*Rm.*sin(theta).*(kappam.^(-1).*d4Z0_0+(-12).*kappam.^(-1).*d2e_0.*dA2_0+(-12).*a.^(-1).*dA3_0.*(d2R0_0+6.*dS2_0)+12.*a.^(-1).*(kappam.^(-1).*d2Z0_0+6.*dA2_0).*dS3_0+(-2).*d3A2_0)+2.*Rm.*cos(theta).*(d4R0_0+(-6).*a.^(-1).*(kappam.^(-1).*d2Z0_0+10.*dA2_0).*dA3_0+3.*kappam.^(-1).*d2e_0.*(d2R0_0+(-1).*dS2_0)+(-6).*a.^(-1).*(d2R0_0+10.*dS2_0).*dS3_0+(-4).*d3S2_0)+(-2).*Rm.*cos(3.*theta).*(6.*a.^(-1).*(3.*kappam.^(-1).*d2Z0_0+(-10).*dA2_0).*dA3_0+3.*kappam.^(-1).*d2e_0.*dS2_0+6.*a.^(-1).*(3.*d2R0_0+(-10).*dS2_0).*dS3_0+(-2).*d3S2_0))+(1/24).*kappam.*rho1.^5.*(4.*sin(4.*theta).*((-3).*dA2_0.*(kappam.^(-1).*d2e_0+(-4).*dA2_0.^2+4.*(d2R0_0+(-1).*dS2_0).*dS2_0)+6.*kappam.^(-1).*d2Z0_0.*((-1).*dA2_0.^2+dS2_0.^2)+6.*((-1).*a.^(-1).*d2R0_0.*dA3_0+2.*a.^(-1).*(kappam.^(-1).*d2Z0_0+(-1).*dA2_0).*dS3_0)+d3A2_0+2.*Rm.*(3.*kappam.^(-1).*d2e_0.*((-1).*a.^(-1).*dA3_0+2.*dA2_0.*dS2_0)+a.^(-1).*d3A3_0))+3.*(d4R0_0+6.*(d2R0_0+(-2).*dS2_0).*(kappam.^(-1).*d2e_0+(-4).*(dA2_0.^2+dS2_0.^2))+(-24).*(2.*a.^(-1).*dA2_0.*dA3_0+a.^(-1).*d2R0_0.*dS3_0)+(-4).*d3S2_0)+2.*sin(2.*theta).*(kappam.^(-1).*d4Z0_0+12.*kappam.^(-1).*d2Z0_0.*(d2R0_0+(-2).*dS2_0).*dS2_0+(-12).*dA2_0.*(d2R0_0.*(d2R0_0+(-2).*dS2_0)+4.*(dA2_0.^2+dS2_0.^2))+(-48).*(2.*a.^(-1).*dA3_0.*dS2_0+(-1).*a.^(-1).*dA2_0.*dS3_0)+4.*Rm.*(kappam.^(-1).*d4Z0_0.*dS2_0+(-3).*kappam.^(-1).*d2e_0.*dA2_0.*(d2R0_0+2.*dS2_0)+(-1).*(d2R0_0+2.*dS2_0).*d3A2_0+(-1).*dA2_0.*(d4R0_0+(-2).*d3S2_0)+kappam.^(-1).*d2Z0_0.*d3S2_0))+2.*cos(2.*theta).*(d4R0_0+(-12).*d2R0_0.*(kappam.^(-1).*d2Z0_0+(-2).*dA2_0).*dA2_0+12.*dS2_0.*(kappam.^(-1).*d2e_0+2.*(kappam.^(-1).*d2Z0_0+(-4).*dA2_0).*dA2_0+(-1).*d2R0_0.*(d2R0_0+(-4).*dS2_0)+(-8).*dS2_0.^2)+(-24).*(a.^(-1).*kappam.^(-1).*d2Z0_0.*dA3_0+a.^(-1).*(d2R0_0+2.*dS2_0).*dS3_0)+(-1).*Rm.*(kappam.^(-1).*d4e_0+(-24).*a.^(-1).*kappam.^(-1).*d2e_0.*dS3_0+4.*(kappam.^(-1).*d4Z0_0.*dA2_0+d4R0_0.*dS2_0+3.*kappam.^(-1).*d2e_0.*((-4).*dA2_0.^2+(d2R0_0+(-2).*dS2_0).*dS2_0)+(kappam.^(-1).*d2Z0_0+(-6).*dA2_0).*d3A2_0+(d2R0_0+(-6).*dS2_0).*d3S2_0)))+3.*Rm.*(kappam.^(-1).*d4e_0+(-48).*a.^(-2).*(dA3_0.^2+dS3_0.^2)+(-8).*(3.*kappam.^(-1).*d2e_0.*(dA2_0.^2+dS2_0.^2)+2.*(dA2_0.*d3A2_0+dS2_0.*d3S2_0))+(-8).*(3.*a.^(-1).*kappam.^(-1).*d2e_0.*dS3_0+a.^(-1).*d3S3_0))+(-4).*cos(4.*theta).*(3.*dS2_0.*(kappam.^(-1).*d2e_0+4.*(kappam.^(-1).*d2Z0_0+(-1).*dA2_0).*dA2_0+(-4).*dS2_0.^2)+6.*d2R0_0.*((-1).*dA2_0.^2+dS2_0.^2)+6.*(2.*a.^(-1).*(kappam.^(-1).*d2Z0_0+(-3).*dA2_0).*dA3_0+a.^(-1).*(d2R0_0+(-4).*dS2_0).*dS3_0)+(-1).*d3S2_0+(-2).*Rm.*(3.*kappam.^(-1).*d2e_0.*((-1).*dA2_0.^2+dS2_0.^2)+(-3).*a.^(-1).*kappam.^(-1).*d2e_0.*dS3_0+18.*a.^(-2).*(dA3_0.^2+dS3_0.^2)+a.^(-1).*d3S3_0)));
end

if isempty(rho2)
    sqrt_g2 = [];
else
    R = R_rho_theta(rho2,theta,equil,amplitudes);
    drhoR = drhoR_rho_theta(rho2,theta,equil,amplitudes);
    dthetaR = dthetaR_rho_theta(rho2,theta,equil,amplitudes);
    drhoZ = drhoZ_rho_theta(rho2,theta,equil,amplitudes);
    dthetaZ = dthetaZ_rho_theta(rho2,theta,equil,amplitudes);

    sqrt_g2 = R.*(drhoR.*dthetaZ - dthetaR.*drhoZ);
end

sqrt_g = cat(1,sqrt_g1,sqrt_g2);

end

