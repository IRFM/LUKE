function dL = dL_rho(rho,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

[~,~,~,~,~,mu0] = pc_dke_yp;

amps = num2cell(amplitudes(1:18));
[a, Rm,d2R0_0,d4R0_0, ~,~,~, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    dL1 = [];
else
    dL1 = Rm.^(-1).*kappam.*mu0.*rho1+(-1/2).*a.^(-1).*Rm.^(-3).*mu0.*rho1.^3.*(a.*((-2).*Rm.^2.*d2e_0+kappam.*((-1)+2.*Rm.*(d2R0_0+(-2).*dS2_0)+8.*Rm.^2.*(dA2_0.^2+dS2_0.^2)))+8.*Rm.^2.*kappam.*dS3_0)+(-1/8).*a.^(-2).*Rm.^(-5).*mu0.*rho1.^5.*(48.*Rm.^4.*kappam.*(dA3_0.^2+dS3_0.^2)+a.^2.*(Rm.^2.*((-1).*Rm.^2.*d4e_0+3.*d2e_0.*((-1)+2.*Rm.*(d2R0_0+(-2).*dS2_0)+8.*Rm.^2.*(dA2_0.^2+dS2_0.^2)))+kappam.*((-3)+3.*Rm.*(3.*d2R0_0+(-4).*dS2_0)+(-6).*Rm.^2.*(d2R0_0.^2+(-2).*dA2_0.^2+(-4).*d2R0_0.*dS2_0+2.*dS2_0.^2)+16.*Rm.^4.*(dA2_0.*d3A2_0+dS2_0.*d3S2_0)+Rm.^3.*(d4R0_0+(-4).*((-12).*dA2_0.^2.*dS2_0+(-12).*dS2_0.^3+6.*d2R0_0.*(dA2_0.^2+dS2_0.^2)+d3S2_0))))+8.*a.*Rm.^2.*(3.*kappam.*dS3_0+(-3).*Rm.*kappam.*(2.*dA2_0.*dA3_0+d2R0_0.*dS3_0)+Rm.^2.*(3.*d2e_0.*dS3_0+kappam.*d3S3_0)));
end

if isempty(rho2)
    dL2 = [];
else
    fun_to_int = @(theta) mu0./(2.*pi).*sqrt_g(rho2,theta,equil,amplitudes) ...
        ./h_zeta(rho2,theta,equil,amplitudes).^2;

    dL2 = integral(fun_to_int,0,2*pi,'ArrayValued',true);
end

dL = cat(1,dL1,dL2);

%{
rhos = (0:equil.a/200:equil.a)';
L_rhos = L_rho(rhos,equil,amplitudes);
dL_rhos = gradient(L_rhos,rhos);
dL = interp1(rhos,dL_rhos,rho,"spline","extrap");
%}

end
