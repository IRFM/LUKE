function f = Tenefit_jd(rho,f0,fa,e1,e2)
%
f = (f0 - fa).*(1 - rho.^e1).^e2 + fa;