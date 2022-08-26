function F = objectiveFunction(X,dirichlet,p,IT,rho_star)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

dirich=num2cell(dirichlet) ;
[R0_a,Z0_a,a,e_a] = dirich{1:4} ;

% X_typical = typical value of [Rm, Zm, kappam, dR0_a, dZ0_a, de_a, dS2_a, dA2_a, dS3_a, dA3_a]
% used by Ludwig as initial condition (only for kappam, he takes 0.89*e_a)
X_typical = [R0_a+a/20, Z0_a+a/20, e_a+0.05, -1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2, 1e-2];
F_typical = systemEquations(X_typical,dirichlet,p,IT,rho_star) ; % typical value of the objective function
F = systemEquations(X,dirichlet,p,IT,rho_star)./F_typical ; % to normalize the objective function

% F = F.*[1,1,1,1,1,1,1,1,1,1]; % to give more importance on the equations that are difficult to solve

end

