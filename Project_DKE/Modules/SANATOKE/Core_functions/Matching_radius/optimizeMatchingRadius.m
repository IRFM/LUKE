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