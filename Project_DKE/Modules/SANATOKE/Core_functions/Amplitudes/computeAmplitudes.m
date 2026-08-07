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
function [amplitudes,final_sol,sol_quality,final_val,exit_flag,output_message] = computeAmplitudes(equil,unique_iteration,test_ludwig)
% Computes the Fourier amplitudes that appear in the Taylor expansions of R
% and Z by solving the system defined in systemEquations.m
%
% amplitudes = [a, Rm,d2R0_0,d4R0_0, Zm,d2Z0_0,d4Z0_0, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0,d3A3_0, ...
%    R0_a,dR0_a,d2R0_a,d3R0_a, Z0_a,dZ0_a,d2Z0_a,d3Z0_a, e_a,de_a,d2e_a,d3e_a, S2_a,dS2_a,d2S2_a,d3S2_a, A2_a,dA2_a,d2A2_a,d3A2_a, ...
%    S3_a,dS3_a,d2S3_a,d3S3_a, A3_a,dA3_a,d2A3_a,d3A3_a];
%
%
% sol_quality = quality of the solution computed in terms of unicity:
% 1 = the solution is unique
% 2 = the solution seems to be unique but is not fully reliable
% 3 = the solver didn't find a unique solution, so the solution returned is
% not reliable at all
%
%
% final_val = value of the objective funtion associated with the computed solution
%
% set unique_iteration to true if you want the function to return the
% first computed solution without checking it ; otherwise ignore this argument
%
% if and only if unique_iteration is set to true, exit_flag and 
% output_message can be returned to describe the exit condition
%
% is_ludwig : true if we want to test exactly  the example taken by Luwig 
% in Mathematica, with all his definitions (especially the exact Dirichlet
% parameters he uses)


% value of rho_star
rho_star = equil.rho_star;

% dirichlet parameters
if nargin>2 && test_ludwig
    dirichlet = [6.2, 0.55, 2, 1.75718, 0.109542, -0.00344217, -0.00734624, -0.00817006];
else
    dirichlet = setDirichlet(equil) ;
end
dir=num2cell(dirichlet) ;
[R0_a,Z0_a,a,e_a,S2_a,A2_a,S3_a,A3_a] = dir{:} ;


% Computation of the useful pressure and current parameters
[d2p_0, d4p_0, ~, ~] = pressureCoeffs(equil) ;
p = [d2p_0, d4p_0];
[d2IT_0, d4IT_0, d6IT_0, ~] = ITCoeffs(equil) ;
IT = [d2IT_0, d4IT_0, d6IT_0] ;



% Unknowns : X = [Rm, Zm, kappam, dR0_a, dZ0_a, de_a, dS2_a, dA2_a, dS3_a, dA3_a]

% Lower and upper bounds on the solutions
lower_bounds = [0.98*R0_a, min(0.9*Z0_a,Z0_a-a/20), max(0.95,e_a/2), -R0_a/a, min(-5*Z0_a/a,-0.1), -5*e_a/a, -1, -1, -1, -1] ;
upper_bounds = [R0_a+0.5*a, max(1.1*Z0_a,Z0_a+a/20), 1.5*e_a, R0_a/a, max(5*Z0_a/a,0.1), 5*e_a/a, 1, 1, 1, 1] ;

% System solving
options = optimoptions('lsqnonlin') ;
options = optimoptions(options,'MaxFunctionEvaluations',1e3,'MaxIterations',...
    1e3,'StepTolerance',eps,'FunctionTolerance',eps,'OptimalityTolerance',eps,'Display','off');

if nargin>1 && unique_iteration  % we take the first solution computed by the solver, without checking it
    % Initial conditions
    X0 = [R0_a+0.3*a*rand, Z0_a*(1+0.1*(rand-0.5)), e_a*(1+0.6*(rand-0.5)), -0.12*R0_a/a*(1+0.6*(rand-0.5)), -0.06*Z0_a/a*(1+0.6*(rand-0.5)), ...
        0.09*e_a/a*(1+0.6*(rand-0.5)), -0.11*S2_a/a*(1+0.6*(rand-0.5)), 0.74*A2_a/a*(1+0.6*(rand-0.5)), 2.2*S3_a/a*(1+0.6*(rand-0.5)), 2.9*A3_a/a*(1+0.6*(rand-0.5))];
    
    [final_sol,final_val,~,exit_flag,output_message] = lsqnonlin(@(X) objectiveFunction(X,dirichlet,p,IT,rho_star),X0,lower_bounds,upper_bounds,options);
    num_iterations = 1;
    sol_quality = "undetermined";
    % fsolve
    %[final_sol,final_val] = fsolve(@(X) objectiveFunction(X,dirichlet,p,IT,rho_star),X0);

    % Grey Wolf Optimizer : doesn't seem to work well
    %fobj = @(X) objectiveFunction(X,dirichlet,p,IT,rho_star);
    %[final_val,final_sol,Convergence_curve] = GWO(50,1e3,lower_bounds,upper_bounds,10,fobj);
    
    % fmincon (constrained)
    %options = optimoptions('fmincon','Algorithm','active-set');
    %options = optimoptions(options,'MaxFunctionEvaluations',1e3,'MaxIterations',...
    %    1e3,'StepTolerance',eps,'FunctionTolerance',eps,'OptimalityTolerance',eps);
    %[final_sol,final_val] = fmincon(@(X) sum(objectiveFunction(X,dirichlet,p,IT,rho_star).^2),X0,[],[],[],[],lower_bounds,upper_bounds,[],options);

else
    num_iterations = 0; % total number of iterations of the solver
    n_max = 10; %maximum number of iterations
    solutions = [];
    vals = [];
    sol_is_ok = false;
    while num_iterations < n_max && ~sol_is_ok
        num_iterations = num_iterations + 1;

        %X0 = [R0_a+0.5*a*rand(), Z0_a*(0.9+0.2*rand()), e_a*(0.7+0.6*rand()),...
        %    2*rand()-1,2*rand()-1, 2*rand()-1, 2*rand()-1, 2*rand()-1,...
        %    2*rand()-1, 2*rand()-1] ;
        X0 = [R0_a+0.3*a*rand, Z0_a*(1+0.1*(rand-0.5)), 0.89*e_a*(1+0.6*(rand-0.5)), -0.12*R0_a/a*(1+0.6*(rand-0.5)), -0.06*Z0_a/a*(1+0.6*(rand-0.5)), ...
            0.09*e_a/a*(1+0.6*(rand-0.5)), -0.11*S2_a/a*(1+0.6*(rand-0.5)), 0.74*A2_a/a*(1+0.6*(rand-0.5)), 2.2*S3_a/a*(1+0.6*(rand-0.5)), 2.9*A3_a/a*(1+0.6*(rand-0.5))];
        
        [sol,val] = lsqnonlin(@(X) objectiveFunction(X,dirichlet,p,IT,rho_star),X0,lower_bounds,upper_bounds,options);            
        
        solutions = cat(1,solutions,sol);
        vals = cat(1,vals,val);
        % sorting the solutions by increasing objective function
        [vals,i_sort] = sort(vals);
        solutions = solutions(i_sort,:);

        if num_iterations >1
            rel_diff = abs((solutions(1,:)-solutions(2,:))./solutions(2,:)); % relative difference between the two best solutions
            rel_diff(isnan(rel_diff)) = 0;
            if rel_diff < 1e-3 % the two solutions are the same
                sol_is_ok = true;
                sol_quality = 1;
                
            end
        end
    end

    if ~sol_is_ok
        % the two best solutions are not identical
        % we look if they are close enough
        quite_similar = [1e-2 1e-2 1e-2 1e-1 1e-1 1e-1 1e-1 1e-1 1e-1 1e-1];
        % condtion for being "similar" : corresponding coefficients must have
        % relative differences < quite_similar OR must be < 1e-2
        condition = rel_diff < quite_similar | (abs(solutions(1,:))<1e-2 & abs(solutions(2,:))<1e-2);
        if condition
            sol_quality = 2;
        else
            sol_quality = 3;
        end
    end

    % in any case we keep the first solution
    final_sol = solutions(1,:);  
    final_val = vals(1);
%{
else
    solutions = []; % up to 3 solutions are computed to ensure their robustness
    vals = [] ; % values of the objective function associated with the computed solutions
    sol_is_ok = false;
    num_iterations = 0; % total number of iterations of the solver
    while ~sol_is_ok

        val = 1; % value of the objective function
        abs_tolerance = 1e-30; % absolute tolerance on the objective function
        num_trial = 0;
        while val > abs_tolerance

            num_trial = num_trial+1;
            num_iterations = num_iterations+1;
            if mod(num_trial,2)==0 && num_trial>4
                disp('The solver does not find any suitable solution. The precision is therefore being reduced.');
                abs_tolerance = 10*abs_tolerance;
            end

            % Initial conditions
            % X0 = [Rm, Zm, kappam, d2R0_0, d2Z0_0, d2e_0, dS2_0, dA2_0, dS3_0, dA3_0]
            X0 = [R0_a+0.5*a*rand(), Z0_a*(0.9+0.2*rand()), e_a*(0.7+0.6*rand()),...
                2*rand()-1,2*rand()-1, 2*rand()-1, 2*rand()-1, 2*rand()-1,...
                2*rand()-1, 2*rand()-1] ;
            X0 = [1.02*R0_a+0.3*a*rand, 1.01*Z0_a*+0.1*(rand-0.5), 0.89*e_a*(1+0.6*(rand-0.5)), -0.12*R0_a/a*(1+0.6*(rand-0.5)), -0.06*Z0_a/a*(1+0.6*(rand-0.5)), ...
                0.09*e_a/a*(1+0.6*(rand-0.5)), -0.11*S2_a/a*(1+0.6*(rand-0.5)), 0.74*A2_a/a*(1+0.6*(rand-0.5)), 2.2*S3_a/a*(1+0.6*(rand-0.5)), 2.9*A3_a/a*(1+0.6*(rand-0.5))];
                
            [sol,val] = lsqnonlin(@(X) objectiveFunction(X,dirichlet,p,IT,rho_star),X0,lower_bounds,upper_bounds,options);            

            if val > abs_tolerance
                disp('The computed solution is not satisfactory, the solver has been reinitialized');
                disp("Objective function = " + num2str(val) +  " > tolerance = " + num2str(abs_tolerance));

                if num_trial==1
                    val_first_iteration = val;
                end
                if num_trial==2 
                    abs_tolerance = min([val_first_iteration,val]);
                    % to calibrate the tolerance to the typical value (taking the min of the first 2 values) and speed up the resolution
                end
            end
        end

        solutions = cat(1,solutions,sol);
        vals = cat(1,vals,val);
        disp("Solution n°"+num2str(size(solutions,1))+" computed with objective function = "+num2str(val)+" < tolerance = "+num2str(abs_tolerance));

        if size(solutions,1)>1
            if size(solutions,1)==2
                rel_diff = abs((solutions(1,:)-solutions(2,:))./solutions(2,:)); % relative difference between both solutions
                rel_diff(isnan(rel_diff)) = 0;
                if rel_diff < 1e-3 % the two solutions are the same
                    sol_is_ok = true;
                    sol_quality = 1;
                    final_sol = solutions(1,:);  % we keep the first solution
                    final_val = vals(1);
                end
            elseif size(solutions,1)==3 % solutions 1 and 2 are not identical
                warning('The two first computed solutions are different (relative difference > 0.1%) : a third one has been computed to choose the valid solution');
                rel_diff12 = abs((solutions(1,:)-solutions(2,:))./solutions(2,:));
                rel_diff13 = abs((solutions(1,:)-solutions(3,:))./solutions(3,:));
                rel_diff23 = abs((solutions(2,:)-solutions(3,:))./solutions(3,:));
                rel_diff12(isnan(rel_diff12)) = 0;
                rel_diff13(isnan(rel_diff13)) = 0;
                rel_diff23(isnan(rel_diff23)) = 0;
                quite_similar = [1e-2 1e-2 1e-2 1e-1 1e-1 1e-1 1e-1 1e-1 1e-1 1e-1];
                cond12 = rel_diff12 < quite_similar | (abs(solutions(1,:))<5e-2 & abs(solutions(2,:))<5e-2);
                cond13 = rel_diff13 < quite_similar | (abs(solutions(1,:))<5e-2 & abs(solutions(3,:))<5e-2);
                cond23 = rel_diff23 < quite_similar | (abs(solutions(2,:))<5e-2 & abs(solutions(2,:))<5e-2);
                if rel_diff13 < 1e-3 % solutions 1 and 3 are the same
                    sol_is_ok = true;
                    sol_quality = 1;
                    final_sol = solutions(1,:); % we keep solution 1
                    final_val = vals(1);
                elseif rel_diff23 < 1e-3 % solutions 2 and 3 are the same
                    sol_is_ok = true;
                    sol_quality = 1;
                    final_sol = solutions(2,:);  % we keep solution 2
                    final_val = vals(2);
                elseif cond12
                    % solutions 1 and 2 are quite similar
                    warning('Solutions 1 and 2 are relatively similar (relative difference < 10%), but not identical. The final solution may not be robust.');
                    pause(2);
                    sol_is_ok = true;
                    sol_quality = 2;
                    final_sol = mean(solutions(1:2,:),1);
                    final_val = sum(objectiveFunction(final_sol,dirichlet,p,IT,rho_star).^2);
                elseif cond13
                    % solutions 1 and 3 are quite similar
                    warning('Solutions 1 and 3 are relatively similar (relative difference < 10%), but not identical. The final solution may not be robust.');
                    pause(2);
                    sol_is_ok = true;
                    sol_quality = 2;
                    final_sol = mean(solutions(1:2:3,:),1);
                    final_val = sum(objectiveFunction(final_sol,dirichlet,p,IT,rho_star).^2);
                elseif cond23
                    % solutions 2 and 3 are quite similar
                    warning('Solutions 2 and 3 are relatively similar (relative difference < 10%), but not identical. The final solution is not robust.');
                    pause(2);
                    sol_is_ok = true;
                    sol_quality = 2;
                    final_sol = mean(solutions(2:3,:),1);
                    final_val = sum(objectiveFunction(final_sol,dirichlet,p,IT,rho_star).^2);
                else
                    warning('The solver did not find a unique solution : the first computed solution is returned, but is not at all reliable');
                    disp("Solutions computed :");
                    disp(solutions);
                    sol_is_ok = true;
                    sol_quality = 3;
                    final_sol = solutions(1,:);
                    final_val = vals(1);
                    disp('The solver did not find a unique solution, the solution returned is not reliable')
                    disp('Execution is about to resume')
                    pause(3);
                end
            end
        end
    end
%}
end

solution = num2cell(final_sol) ;
[Rm, Zm, kappam, dR0_a, dZ0_a, de_a, dS2_a, dA2_a, dS3_a, dA3_a] = solution{:};
    

% Additional Fourier amplitudes appearing in the Taylor expansions of R and Z
% Direct computation of additional Fourier amplitudes appearing in the
% equations: these are computed using the boundary conditions at rho=rho_star
[d2R0_0,d4R0_0,d2R0_a,d3R0_a] = boundaryCondition_R0_like(a,R0_a,Rm,dR0_a,rho_star) ;
[d2Z0_0,d4Z0_0,d2Z0_a,d3Z0_a] = boundaryCondition_R0_like(a,Z0_a,Zm,dZ0_a,rho_star) ;
[d2e_0,d4e_0,d2e_a,d3e_a] = boundaryCondition_R0_like(a,e_a,kappam,de_a,rho_star) ;
[dS2_0,d3S2_0,d2S2_a,d3S2_a] = boundaryCondition_S2_like(a,S2_a,dS2_a,rho_star) ;
[dA2_0,d3A2_0,d2A2_a,d3A2_a] = boundaryCondition_S2_like(a,A2_a,dA2_a,rho_star) ;
[dS3_0,d3S3_0,d2S3_a,d3S3_a] = boundaryCondition_S2_like(a,S3_a,dS3_a,rho_star) ;
[dA3_0,d3A3_0,d2A3_a,d3A3_a] = boundaryCondition_S2_like(a,A3_a,dA3_a,rho_star) ;


amplitudes = [a, Rm,d2R0_0,d4R0_0, Zm,d2Z0_0,d4Z0_0, kappam,d2e_0,d4e_0, dS2_0,d3S2_0, dA2_0,d3A2_0, dS3_0,d3S3_0, dA3_0,d3A3_0, ...
    R0_a,dR0_a,d2R0_a,d3R0_a, Z0_a,dZ0_a,d2Z0_a,d3Z0_a, e_a,de_a,d2e_a,d3e_a, S2_a,dS2_a,d2S2_a,d3S2_a, A2_a,dA2_a,d2A2_a,d3A2_a, ...
    S3_a,dS3_a,d2S3_a,d3S3_a, A3_a,dA3_a,d2A3_a,d3A3_a];

disp("Total number of iterations of the solver : " + num2str(num_iterations));
disp("Quality of the solution : " + num2str(sol_quality));
disp("Final value of the objective function : " + num2str(final_val));
if isnumeric(sol_quality) && sol_quality == 2
    warning('The two best solutions were relatively similar (relative difference < 10%), but not identical. The final solution is not robust.');
elseif isnumeric(sol_quality) && sol_quality == 3
    warning('The solver did not find a unique solution : the best computed solution is returned, but is not at all reliable');
end

end
