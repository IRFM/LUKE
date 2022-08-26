function [d2IT_0, d4IT_0, d6IT_0, d8IT_0] = ITCoeffs(equil)

a = equil.a;
IT_a = equil.current.IT.IT_a;

if isfield(equil.current.IT,'alpha_j')
    d2IT_0 = 2.*IT_a.*(1+equil.current.IT.alpha_j)./a.^2;
    d2IT_a = 0;
    d4IT_0 = -3./a.^4.*(12.*a.^2.*d2IT_0 - a.^2.*d2IT_a - 48.*IT_a);
    d6IT_0 = 180./a.^6.*(6.*a.^2.*d2IT_0 - a.^2.*d2IT_a - 32.*IT_a);
    d8IT_0 = -5040./a.^8.*(4.*a.^2.*d2IT_0 - a.^2.*d2IT_a - 24.*IT_a);

else

    rhos = (0:a/100:a)';
    IT_rhos = IT_rho_input(rhos,equil);

    % coeffs = [d2IT_0, d4IT_0]
    % d6IT_0 is replaced by a function of d2IT_0 and d4IT_0 such that IT(a) = IT_a
    options = optimoptions('fsolve') ;
    options = optimoptions(options,'Algorithm','Levenberg-Marquardt','MaxFunctionEvaluations',1e7,'MaxIterations',...
        1e4,'StepTolerance',eps,'FunctionTolerance',eps,'OptimalityTolerance',eps,'Display','off') ;
    fun = @(coeffs) IT_rhos - (coeffs(1)./2.*rhos.^2 + coeffs(2)./24.*rhos.^4 + coeffs(3)./720.*rhos.^6 ...
        + 40320./a.^8.*(IT_a - coeffs(1)./2.*a.^2 - coeffs(2)./24.*a.^4 - coeffs(3)./720.*a.^6)./40320.*rhos.^8) ;
    coeffs0 = [2/a^2*IT_a, 24/a^4*IT_a, 720/a^6*IT_a];

    sol = fsolve(fun,coeffs0,options);
    d2IT_0 = sol(1);
    d4IT_0 = sol(2);
    d6IT_0 = sol(3);
    d8IT_0 = 40320/a^8.*(IT_a - d2IT_0./2.*a.^2 - d4IT_0./24.*a.^4 - d6IT_0./720.*a.^6);

end


%{
% toroidal current profile near the agnetic axis : 
% IT(rho) = IT_a.*(1-(1-rho.^2./a.^2).^(1+alpha_j))

a = equil.a;
alpha_j = equil.current.IT.alpha_j;
IT_a = equil.current.IT.IT_a;

d2IT_0 = 2.*IT_a.*(1+alpha_j)./a.^2 ;
d4IT_0 = -12.*IT_a.*alpha_j.*(1+alpha_j)./a.^4 ;
%d6IT_0 = 120.*(alpha_j-1).*alpha_j.*(1+alpha_j)./a.^6 ;
d6IT_0 = 720./a.^6.*(IT_a - d2IT_0./2.*a.^2 - d4IT_0./24.*a.^4);
%}

end

