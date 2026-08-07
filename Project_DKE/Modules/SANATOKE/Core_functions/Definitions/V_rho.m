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
function V = V_rho(rho,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes(1:18));
[a, Rm,d2R0_0,d4R0_0, ~,~,~, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star/2);
rho2 = rho(rho>equil.rho_star/2);

if isempty(rho1)
    V1 = [];
else
    V1 = 2.*pi.^2.*Rm.*kappam.*rho1.^2.*(1+(1/2).*Rm.^(-2).*rho1.^2.*(Rm.^2.*kappam.^(-1).*d2e_0+Rm.*d2R0_0+(-4).*Rm.^2.*dA2_0.^2+(-2).*Rm.*dS2_0.*(1+2.*Rm.*dS2_0)+(-4).*a.^(-1).*Rm.^2.*dS3_0)+(1/24).*Rm.^(-4).*rho1.^4.*(6.*Rm.^3.*kappam.^(-1).*d2e_0.*d2R0_0+Rm.^4.*kappam.^(-1).*d4e_0+Rm.^3.*d4R0_0+(-48).*a.^(-1).*Rm.^2.*dA3_0.*(Rm.*dA2_0+a.^(-1).*Rm.^2.*dA3_0)+48.*Rm.*dS2_0.*(Rm.^2.*dA2_0.^2+Rm.^2.*dS2_0.^2)+(-24).*Rm.*d2R0_0.*(Rm.^2.*dA2_0.^2+Rm.^2.*dS2_0.^2+a.^(-1).*Rm.^2.*dS3_0)+(-12).*Rm.^2.*kappam.^(-1).*d2e_0.*(Rm.*dS2_0.*(1+2.*Rm.*dS2_0)+2.*(Rm.^2.*dA2_0.^2+a.^(-1).*Rm.^2.*dS3_0))+(-16).*Rm.^4.*dA2_0.*d3A2_0+(-4).*Rm.^3.*(1+4.*Rm.*dS2_0).*d3S2_0+(-8).*(6.*a.^(-2).*Rm.^4.*dS3_0.^2+a.^(-1).*Rm.^4.*d3S3_0)));
end

if isempty(rho2)
    V2 = [];
else
    fun_to_int = @(theta) pi*R_rho_theta(rho2,theta,equil,amplitudes).^2 ...
        .*dthetaZ_rho_theta(rho2,theta,equil,amplitudes);
    V2 = integral(fun_to_int,0,2*pi,'ArrayValued',true);
end

V = cat(1,V1,V2);


%{
a_amp = num2cell(a_amplitudes);
[a,Rm, ~, kappam, d2R0_0, ~, d2e_0, dS2_0, dA2_0,dS3_0, dA3_0,...
    d4R0_0, ~, d4e_0, d3S2_0, d3A2_0, d3S3_0, ~] = a_amp{:};

V = 2.*pi.^2.*Rm.*kappam.*rho.^2.*(1+(1/2).*Rm.^(-2).*rho.^2.*(Rm.^2.*kappam.^(-1).*d2e_0+Rm.*d2R0_0+(-4).*Rm.^2.*dA2_0.^2+(-2).*Rm.*dS2_0.*(1+2.*Rm.*dS2_0)+(-4).*a.^(-1).*Rm.^2.*dS3_0)+(1/24).*Rm.^(-4).*rho.^4.*(6.*Rm.^3.*kappam.^(-1).*d2e_0.*d2R0_0+Rm.^4.*kappam.^(-1).*d4e_0+Rm.^3.*d4R0_0+(-48).*a.^(-1).*Rm.^2.*dA3_0.*(Rm.*dA2_0+a.^(-1).*Rm.^2.*dA3_0)+48.*Rm.*dS2_0.*(Rm.^2.*dA2_0.^2+Rm.^2.*dS2_0.^2)+(-24).*Rm.*d2R0_0.*(Rm.^2.*dA2_0.^2+Rm.^2.*dS2_0.^2+a.^(-1).*Rm.^2.*dS3_0)+(-12).*Rm.^2.*kappam.^(-1).*d2e_0.*(Rm.*dS2_0.*(1+2.*Rm.*dS2_0)+2.*(Rm.^2.*dA2_0.^2+a.^(-1).*Rm.^2.*dS3_0))+(-16).*Rm.^4.*dA2_0.*d3A2_0+(-4).*Rm.^3.*(1+4.*Rm.*dS2_0).*d3S2_0+(-8).*(6.*a.^(-2).*Rm.^4.*dS3_0.^2+a.^(-1).*Rm.^4.*d3S3_0)));



for i=1:length(rho)
    r = rho(i);
    fun_to_int = @(rrho,theta) 2.*pi.*sqrt_g(rrho,theta,equil,amplitudes);

    rhos = linspace(0,r,floor(200*r/a)+10)';
    thetas = 0:pi/100:2*pi;
    drho = rhos(2)-rhos(1);
    dtheta = thetas(2)-thetas(1);
    
    V(i) = sum(fun_to_int(rhos(2:end),thetas(2:end)),'all').*drho.*dtheta;
end
%}

end

