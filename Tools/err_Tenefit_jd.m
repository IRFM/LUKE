function err = err_Tenefit_jd(fit,rho,f)
%
%err = norm(f-Tenefit_jd(rho,fit(1),fit(2),fit(3),fit(4)));
err = norm(f-Tenefit_jd(rho,fit(1),fit(2),fit(3),fit(4))) + ...
    0.2*norm(f([1,end])-Tenefit_jd(rho([1,end]),fit(1),fit(2),fit(3),fit(4)));