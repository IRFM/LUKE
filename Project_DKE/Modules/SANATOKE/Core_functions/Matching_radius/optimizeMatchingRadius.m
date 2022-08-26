function [rho_star_opt,has_converged] = optimizeMatchingRadius(equil)
% finds the rho_star that maximizes the internal energy U(a)

a = equil.a;

max_iter = 50;

options = optimset('Display','off','MaxIter',max_iter);
[rho_star_opt,~,~,output] = fminbnd(@(rho_star) -fun_to_min(rho_star,equil),1e-5,a,options);

if output.iterations < max_iter
    has_converged = true;
else
    has_converged = false;
end

end


function Ua = fun_to_min(rho_star,equil)

equil.rho_star = rho_star;
amplitudes = computeAmplitudes(equil);

Ua = U_a(equil,amplitudes);

end