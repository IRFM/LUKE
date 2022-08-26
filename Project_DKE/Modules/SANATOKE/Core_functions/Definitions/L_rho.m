function L = L_rho(rho,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,~,~,mu0] = pc_dke_yp;

amps = num2cell(amplitudes(1:18));
[a, Rm,d2R0_0,d4R0_0, ~,~,~, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    L1 = [];
else
    L1 = (1/2).*Rm.^(-1).*kappam.*mu0.*rho1.^2.*(1+(1/4).*Rm.^(-2).*rho1.^2.*(1+(-2).*((-1).*Rm.^2.*kappam.^(-1).*d2e_0+Rm.*d2R0_0)+4.*Rm.*dS2_0.*(1+(-2).*Rm.*dS2_0)+(-8).*(Rm.^2.*dA2_0.^2+a.^(-1).*Rm.^2.*dS3_0))+(1/24).*Rm.^(-4).*rho1.^4.*(3+6.*Rm.*d2R0_0.*((-1).*Rm.^2.*kappam.^(-1).*d2e_0+Rm.*d2R0_0)+Rm.^4.*kappam.^(-1).*d4e_0+(-1).*Rm.^3.*d4R0_0+48.*a.^(-1).*Rm.^2.*dA3_0.*(Rm.*dA2_0+(-1).*a.^(-1).*Rm.^2.*dA3_0)+(-12).*Rm.^2.*dA2_0.^2.*(1+4.*Rm.*dS2_0)+12.*Rm.*dS2_0.*(1+Rm.*dS2_0.*(1+(-4).*Rm.*dS2_0))+(-24).*a.^(-1).*Rm.^2.*dS3_0.*(1+2.*a.^(-1).*Rm.^2.*dS3_0)+3.*Rm.^2.*kappam.^(-1).*d2e_0.*(1+4.*Rm.*dS2_0.*(1+(-2).*Rm.*dS2_0)+(-8).*(Rm.^2.*dA2_0.^2+a.^(-1).*Rm.^2.*dS3_0))+(-3).*Rm.*d2R0_0.*(3+8.*Rm.*dS2_0.*(1+(-1).*Rm.*dS2_0)+(-8).*(Rm.^2.*dA2_0.^2+a.^(-1).*Rm.^2.*dS3_0))+(-16).*Rm.^4.*dA2_0.*d3A2_0+4.*Rm.^3.*(1+(-4).*Rm.*dS2_0).*d3S2_0+(-8).*a.^(-1).*Rm.^4.*d3S3_0));
end

if isempty(rho2)
    L2 = [];
else
    fun_to_int = @(theta) -mu0./(2.*pi).*Z_rho_theta(rho2,theta,equil,amplitudes) ...
        .*dthetaR_rho_theta(rho2,theta,equil,amplitudes) ...
        ./R_rho_theta(rho2,theta,equil,amplitudes);

    L2 = integral(fun_to_int,0,2*pi,'ArrayValued',true);
end

L = cat(1,L1,L2);

%{
L = zeros(size(rho));

for i=1:length(rho)
    r = rho(i);
    fun_to_int = @(rrho,theta) mu0./(2.*pi).*sqrt_g(rrho,theta,equil,amplitudes) ...
        ./h_zeta(rrho,theta,equil,amplitudes).^2;

    rhos = linspace(0,r,floor(200*r/a)+10)';
    thetas = 0:pi/100:2*pi;
    drho = rhos(2)-rhos(1);
    dtheta = thetas(2)-thetas(1);
    
    L(i) = sum(fun_to_int(rhos(2:end),thetas(2:end)),'all').*drho.*dtheta;

end
%}

end
