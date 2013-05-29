function f = Tenefit_jd(rho,f0,fa,e1,e2)
%
if all(imag(fa) == 0),%fa is edge value
    f = (f0 - fa).*(1 - rho.^e1).^e2 + fa;
elseif all(real(fa) == 0),%fa is edge/core value
    f = f0.*((1 - imag(fa)).*(1 - rho.^e1).^e2 + imag(fa));
else
    error('edge value not valid.')
end