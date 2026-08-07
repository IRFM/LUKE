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
function [rhos,thetas] = cart2curv(R,Z,equil,amplitudes)
% R and Z must have the same size
% theta is the analytical variable, not the geometrical angle
% rho and theta have the size of R and Z (can be matrices)

lb = [0,-100*pi];
ub = [equil.a,100*pi];

rhos = zeros(size(R));
thetas = zeros(size(R));

for i=1:size(R,1)
    for j=1:size(R,2)
        val = 1;
        RR = R(i,j);
        ZZ = Z(i,j);
        options = optimoptions('lsqnonlin') ;
        options = optimoptions(options,'MaxFunctionEvaluations',1e5,'MaxIterations',...
            1e3,'StepTolerance',1e-10,'FunctionTolerance',1e-10,'OptimalityTolerance',1e-15,'Display','off') ;

        while val > 1e-6 % precision of 1 mm on the position of (R,Z) => 1e-6 for the norm squared
            curv0 = [equil.a*rand, 2*pi*rand];
            [sol,val] = lsqnonlin(@(curv) systemCurvToCart(curv,[RR,ZZ],equil,amplitudes), curv0, lb, ub,options);
            if val>1e-6
                1;
            end
        end
        sol = num2cell(sol);
        [rho,theta] = sol{:};

        theta = theta-2*pi*floor(theta/2/pi); % to put theta back between 0 and 2*pi
        
        rhos(i,j) = rho;
        thetas(i,j) = theta;
        
        if val>1e-15
            1;
        end
    end
end

end

