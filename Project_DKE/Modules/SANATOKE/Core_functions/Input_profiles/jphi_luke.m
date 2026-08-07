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
function jphi = jphi_luke(rhos_luke,thetas_luke,equil_val)
% From eq 49 of "Consistency of the toroidal MHD equilibrium" (Y. Peysson) 
% Computes the surfacic toroidal current at any points {rhos,thetas} from a
% luke equilibrium : equil_val = equilval_yp(equil_fit,rhos,thetas) 
% and equil_fit = fitequil_yp(equil)
% where equil is a loaded equilibrium structure from luke

[~,~,~,~,~,mu0] = pc_dke_yp;

r = equil_val.r;
sin_alpha = equil_val.salpha;
%sin_alpha(1,:) = sin_alpha(2,:);
cos_alpha = equil_val.calpha;
%cos_alpha(1,:) = cos_alpha(2,:);
BP = equil_val.BP;
gamma = 1+equil_val.x/equil_val.Rp;
grad_rho = abs(equil_val.gradrho);
%grad_rho(1,:) = grad_rho(2,:);

[~,grad1] = gradient(r.*BP./cos_alpha,thetas_luke,rhos_luke); % derivative in rho
grad2 = gradient(sin_alpha./(gamma.*cos_alpha),thetas_luke,rhos_luke); % derivative in theta

jphi = cos_alpha.*grad_rho./(mu0.*r).*grad1 - gamma.*BP.*cos_alpha./r.*grad2;

[~,ind_pi] = min(abs(thetas_luke-pi));
n = length(rhos_luke);
grad_jt = abs(gradient(jphi(:,1),rhos_luke));
max_grad = max(grad_jt(floor(n/10):floor(2*n/10)));
first_ok = 1;
while grad_jt(first_ok)>2*max_grad || isnan(grad_jt(first_ok))
    first_ok = first_ok+1;
end
if first_ok>1
    jphi(1,:) = mean(jphi(first_ok,1)+jphi(first_ok,ind_pi))./2*ones(1,length(thetas_luke));
    if first_ok>2
        for i=2:first_ok-1
            jphi(i,:) = ((first_ok-i).*jphi(1,:)+(i-1).*jphi(first_ok,:))./(first_ok-1);
        end
    end
end

end