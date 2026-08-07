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
function [d2p_0, d4p_0, d6p_0, d8p_0,p0] = pressureCoeffs(equil)

qe = pc_dke_yp;
a = equil.a;

if isfield(equil.temperature.electron,'eTe') && isfield(equil.density.electron,'ene')
    p0 = 1e3.*qe.*equil.density.electron.ne_0.*(equil.temperature.electron.Te_0+equil.temperature.ion.Ti_0./equil.Zeff.Zeff_0);
    alpha_p = equil.density.electron.ene+equil.temperature.electron.eTe;
    d2p_0 = -2.*p0.*alpha_p./a.^2;
    d2p_a = 0;
    d4p_0 = -3./a.^4.*(12.*a.^2.*d2p_0 - a.^2.*d2p_a + 48.*p0);
    d6p_0 = 180./a.^6.*(6.*a.^2.*d2p_0 - a.^2.*d2p_a + 32.*p0);
    d8p_0 = -5040./a.^8.*(4.*a.^2.*d2p_0 - a.^2.*d2p_a + 24.*p0);

else

    rhos = (0:a/100:a)';
    p_rhos = p_rho_input(rhos,equil);

    options = optimoptions('fsolve') ;
    options = optimoptions(options,'MaxFunctionEvaluations',1e7,'MaxIterations',...
    1e4,'StepTolerance',eps,'FunctionTolerance',eps,'OptimalityTolerance',eps,'Algorithm','Levenberg-Marquardt','Display','off') ;


    %%%% WITHOUT FIXING dp4_0 to have p(a) = p_a
    % coeffs = [d2p_0, d4p_0]
    % d8p_0 is replaced by a function of d2p_0, d4p_0 and d6p_0 such that p(a) = p_a
    p0 = p_rho_input(0,equil);
    p_a = p_rho_input(a,equil);
    fun = @(coeffs) p_rhos - (p0 + coeffs(1)./2.*rhos.^2 + coeffs(2)./24.*rhos.^4 + coeffs(3)./720.*rhos.^6 ...
        + 40320./a.^8.*(p_a - p0 - coeffs(1)./2.*a.^2 - coeffs(2)./24.*a.^4 - coeffs(3)./720.*a.^6)./40320.*rhos.^8 ) ;
    coeffs0 = [2/a^2*(p_a-p0), 24/a^4*(p_a-p0), 720/a^6*(p_a-p0)];

    sol = fsolve(fun,coeffs0,options);
    d2p_0 = sol(1);
    d4p_0 = sol(2);
    d6p_0 = sol(3);
    d8p_0 = 40320/a^8.*(p_a - p0 - d2p_0./2.*a.^2 - d4p_0./24.*a.^4 - d6p_0./720.*a.^6);

end








%{
%%%% BY FIXING dp4_0 to have p(a) = p_end
% coeffs = d2p_0
p0 = p_rho_input(0,equil);
pa = p_rho_input(a,equil);
fun = @(coeffs) p_rhos - (p0 + coeffs./2.*rhos.^2 + 24./a.^4.*(pa-p0-coeffs./2.*a.^2)./24.*rhos.^4) ;
coeffs0 = 2/a^2*(pa-p0);

d2p_0 = fsolve(fun,coeffs0,options);
d4p_0 = 24./a.^4.*(pa-p0-d2p_0./2.*a.^2);
%}

%{
qe = pc_dke_yp;
a = equil.a; 
ne_0 = equil.density.electron.ne_0;
ne_a = equil.density.electron.ne_a;
ene = equil.density.electron.ene;
Te_0 = equil.temperature.electron.Te_0;
Te_a = equil.temperature.electron.Te_a;
eTe = equil.temperature.electron.eTe;
Ti_0 = equil.temperature.ion.Ti_0;
Ti_a = equil.temperature.ion.Ti_a;
eTi = equil.temperature.ion.eTi;
Zeff_0 = equil.Zeff.Zeff_0;
Zeff_a = equil.Zeff.Zeff_a;
eZeff = equil.Zeff.eZeff;

d2p_0 = 1000.*qe.*((-2).*a.^(-2).*ene.*(ne_0+(-1).*ne_a).*Te_0+(-2).*a.^(-2).*eTe.*ne_0.*(Te_0+(-1).*Te_a)+(-2).*a.^(-2).*ene.*(ne_0+(-1).*ne_a).*Te_0.*Zeff_0.^(-1)+(-2).*a.^(-2).*eTi.*ne_0.*(Te_0+(-1).*Ti_a).* Zeff_0.^(-1)+2.*a.^(-2).*eZeff.*ne_0.*Te_0.*Zeff_0.^(-2).*(Zeff_0+(-1).*Zeff_a));

d4p_0 = 1000.*qe.*(12.*a.^(-4).*((-1)+ene).*ene.*(ne_0+(-1).*ne_a).*Te_0+12.*a.^(-4).*((-1)+eTe).*eTe.*ne_0.*(Te_0+(-1).*Te_a)+24.*a.^(-4).*ene.*eTe.*(ne_0+(-1).*ne_a).*(Te_0+(-1).*Te_a)+(12.*a.^(-4).*((-1)+ene).*ene.*(ne_0+(-1).*ne_a).*Ti_0+12.*a.^(-4).*((-1)+eTi).*eTi.*ne_0.*(Ti_0+(-1).*Ti_a)+24.*a.^(-4).*ene.*eTi.*(ne_0+(-1).*ne_a).*(Ti_0+(-1).*Ti_a)).*Zeff_0.^(-1)+ne_0.*Ti_0.*((-12).*a.^(-4).*((-1)+eZeff).*eZeff.*Zeff_0.^(-2).*(Zeff_0+(-1).*Zeff_a)+24.*a.^(-4).*eZeff.^2.*Zeff_0.^( -3).*(Zeff_0+(-1).*Zeff_a).^2)+12.*a.^(-2).*eZeff.*((-2).*a.^(-2).*ene.*(ne_0+(-1).*ne_a).*Ti_0+(-2).*a.^(-2).*eTi.*ne_0.*(Ti_0+(-1).*Ti_a)).*Zeff_0.^(-2).*(Zeff_0+(-1).*Zeff_a));
%}

end

