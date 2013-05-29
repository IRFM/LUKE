function err = err_Tenefit_jd(fit,rho,f,boundsfac,enforce)
%
y = enforce;
y(isnan(enforce)) = fit;
%
%err = norm(f-Tenefit_jd(rho,y(1),y(2),y(3),y(4)));
err = norm(f-Tenefit_jd(rho,y(1),y(2),y(3),y(4))) + ...
    boundsfac*norm(f([1,end])-Tenefit_jd(rho([1,end]),y(1),y(2),y(3),y(4)));