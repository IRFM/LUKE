function Iphi = Iphi_luke(rhos_luke,thetas_luke,equil_val)
% Computes the toroidal current at any points {rho,theta} from equil_val

jphi = jphi_luke(rhos_luke,thetas_luke,equil_val);

r = equil_val.r;
dthetas = repmat(gradient(thetas_luke),length(rhos_luke),1);
dpsi_n = abs(repmat(gradient(equil_val.psin),1,length(thetas_luke)));
drhopsi_n = repmat(abs(equil_val.dpsindrho),1,length(thetas_luke));
cos_alpha = equil_val.calpha;
cos_alpha(1,:) = cos_alpha(2,:);
grad_rho = equil_val.gradrho;

fun_to_int = jphi.*r./(cos_alpha.*grad_rho.*drhopsi_n).*dpsi_n.*dthetas; % FORMULA TO USE
%fun_to_int = jt.*r.*(equil_val.drdrho.*drhos + equil_val.drdtheta.*dthetas).*dthetas; % geometrical formula
% both formula are in principle valid ; in practice there can be little
% differences between both

fun_to_int(1,:) = zeros(size(thetas_luke));

Iphi = cumsum(sum(fun_to_int,2),1);

end