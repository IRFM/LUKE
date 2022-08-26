function system = systemCurvToCart(curv,cart,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

curv = num2cell(curv);
[rho,theta] = curv{:};

cart = num2cell(cart);
[R,Z] = cart{:};


system(1) = R_rho_theta(rho,theta,equil,amplitudes) - R ;
system(2) = Z_rho_theta(rho,theta,equil,amplitudes) - Z ;

end

