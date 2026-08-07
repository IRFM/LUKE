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
function dV = dV_rho(rho,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

amps = num2cell(amplitudes(1:18));
[a, Rm,d2R0_0,d4R0_0, ~,~,~, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0] = amps{:};

rho1 = rho(rho<=equil.rho_star);
rho2 = rho(rho>equil.rho_star);

if isempty(rho1)
    dV1 = [];
else
    dV1 = 4.*pi.^2.*Rm.*kappam.*rho1+4.*a.^(-1).*pi.^2.*rho1.^3.*(a.*(kappam.*(d2R0_0+(-2).*dS2_0)+Rm.*(d2e_0+(-4).*kappam.*(dA2_0.^2+dS2_0.^2)))+(-4).*Rm.*kappam.*dS3_0)+(1/2).*a.^(-2).*pi.^2.*rho1.^5.*((-48).*Rm.*kappam.*(dA3_0.^2+dS3_0.^2)+a.^2.*(6.*d2e_0.*(d2R0_0+(-2).*(dS2_0+2.*Rm.*(dA2_0.^2+dS2_0.^2)))+kappam.*(d4R0_0+(-4).*((-12).*dA2_0.^2.*dS2_0+(-12).*dS2_0.^3+6.*d2R0_0.*(dA2_0.^2+dS2_0.^2)+d3S2_0))+Rm.*(d4e_0+(-16).*kappam.*(dA2_0.*d3A2_0+dS2_0.*d3S2_0)))+(-8).*a.*(3.*Rm.*d2e_0.*dS3_0+kappam.*(6.*dA2_0.*dA3_0+3.*d2R0_0.*dS3_0+Rm.*d3S3_0)));
end

if isempty(rho2)
    dV2 = [];
else
    fun_to_int = @(theta) 2.*pi*sqrt_g(rho2,theta,equil,amplitudes);
    dV2 = integral(fun_to_int,0,2*pi,'ArrayValued',true);
end

dV = cat(1,dV1,dV2);

%{
a_amp = num2cell(a_amplitudes);
[a,Rm, ~, kappam, d2R0_0, ~, d2e_0, dS2_0, dA2_0,dS3_0, dA3_0,...
    d4R0_0, ~, d4e_0, d3S2_0, d3A2_0, d3S3_0, ~] = a_amp{:};

dV = 4.*pi.^2.*Rm.*kappam.*rho+4.*a.^(-1).*pi.^2.*rho.^3.*(a.*(kappam.*(d2R0_0+(-2).*dS2_0)+Rm.*(d2e_0+(-4).*kappam.*(dA2_0.^2+dS2_0.^2)))+(-4).*Rm.*kappam.*dS3_0)+(1/2).*a.^(-2).*pi.^2.*rho.^5.*((-48).*Rm.*kappam.*(dA3_0.^2+dS3_0.^2)+a.^2.*(6.*d2e_0.*(d2R0_0+(-2).*(dS2_0+2.*Rm.*(dA2_0.^2+dS2_0.^2)))+kappam.*(d4R0_0+(-4).*((-12).*dA2_0.^2.*dS2_0+(-12).*dS2_0.^3+6.*d2R0_0.*(dA2_0.^2+dS2_0.^2)+d3S2_0))+Rm.*(d4e_0+(-16).*kappam.*(dA2_0.*d3A2_0+dS2_0.*d3S2_0)))+(-8).*a.*(3.*Rm.*d2e_0.*dS3_0+kappam.*(6.*dA2_0.*dA3_0+3.*d2R0_0.*dS3_0+Rm.*d3S3_0)));

rhos = (0:equil.a/200:equil.a)';
V_rhos = V_rho(rhos,equil,a_amplitudes,boundary_amplitudes);
dV_rhos = gradient(V_rhos,rhos);
dV = interp1(rhos,dV_rhos,rho,"spline","extrap");
%}


end

