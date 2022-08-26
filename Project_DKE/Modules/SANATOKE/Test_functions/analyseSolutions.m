function [amps,vals,exit_conditions,exit_messages,algorithms] = analyseSolutions(equil,num_solutions)

if nargin<2
    num_solutions=20;
end

amps = [];
vals = [];
exit_conditions = [];
num_iterations = [];
algorithms = [];
exit_messages = [];

for i=1:num_solutions
    [amp,~,~,val,exit_flag,output_message] = computeAmplitudes(equil,true);
    
    amps = cat(1,amps,amp);
    vals = cat(1,vals,val);
    
    switch exit_flag
        case 1
            exit_conditions = cat(1,exit_conditions,"lsqnonlin converged to a solution");
        case 2
            exit_conditions = cat(1,exit_conditions,"Change in X too small");
        case 3
            exit_conditions = cat(1,exit_conditions,"Change in objective function too small");
        case 4
            exit_conditions = cat(1,exit_conditions,"Computed search direction too small.");
        case 0
            exit_conditions = cat(1,exit_conditions,"Too many function evaluations or iterations.");
        case -1
            exit_conditions = cat(1,exit_conditions,"Stopped by output/plot function.");
        case -2
            exit_conditions = cat(1,exit_conditions,"Bounds are inconsistent.");
    end
    
    num_iterations = cat(1,num_iterations,output_message.iterations);
    algorithms = cat(1,algorithms,string(output_message.algorithm));
    exit_messages = cat(1,exit_messages,string(output_message.message));
end

% sorting the solutions according to their objective function
[vals,i_sort] = sort(vals);
amps = amps(i_sort,:);
exit_conditions = exit_conditions(i_sort,:);
exit_messages = exit_messages(i_sort,:);
algorithms = algorithms(i_sort,:);

% plot the objective function
figure;
semilogy(vals);
xlabel('Index of the computed solution');
ylabel('Objective function (log scale)');
title("Value of the objective function for each computed solution");

% plot of the coefficients
name_amps = ["a", "Rm","d2R0_0","d4R0_0", "Zm","d2Z0_0","d4Z0_0", "kappam","d2e_0","d4e_0", "dS2_0","d3S2_0", "dA2_0","d3A2_0", "dS3_0","d3S3_0", "dA3_0","dA3_0"];
for j=1:length(name_amps) 
    figure;
    plot(amps(:,j));
    xlabel('Index of the computed solution');
    ylabel(name_amps(j));
    title("Value of "+name_amps(j)+" for each computed solution");
end

% plot the magnetic surfaces of the best equilibrium
plotEquilibrium(equil,amps(1,:));

end

