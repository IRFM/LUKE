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
function dirichlet = setDirichlet(equil)
% Determines the Dirichlet parameters [R0_a,Z0_a,a,e_a,S2_a,A2_a,S3_a,A3_a]
% from some input parameters describing the plasma boundary:
% boundary = [R0_a,Z0_a,a,R1,Z1,R2,Z2,R3,Z3,{R4,Z4,...}]

boundary = equil.boundary;

n = length(boundary) ;
if mod(n-3,2)~=0
    error('Invalid boundary parameters, it must be on the form: boundary_parameters = [R0_a,Z0_a,a,R1,Z1,R2,Z2,R3,Z3,{R4,Z4,...}]');
elseif n<9
    error('Not enough points: boundary_parameters must contain at least the coordinates [R,Z] of 3 points'); 
end

input = num2cell(boundary(1:3));
[R0_a,Z0_a,a] = input{:};
entry_R = boundary(4:2:end);
entry_Z = boundary(5:2:end);
entry_thetas = zeros(1,(n-3)/2);

% calculation of entry thetas
for i=1:(n-3)/2
    r = entry_R(i)-R0_a;
    z = entry_Z(i)-Z0_a;
    if r>0 && z>=0, theta = atan(z/r);
    elseif r>0 && z<0, theta = atan(z/r) + 2*pi;
    elseif r<0, theta = pi+atan(z/r);
    elseif r==0 && z>0, theta = pi/2;
    elseif r==0 && z<0, theta = 3*pi/2;
    else, theta = 0;
    end
    entry_thetas(i) = theta;
end

% Deleting repeted points and sorting in thetas
[entry_thetas,indexes,~] = unique(entry_thetas);
entry_R = entry_R(indexes);
entry_Z = entry_Z(indexes);

% Initial conditions:
% x = [e_a,S2_a,A2_a,S3_a,A3_a]
x0 = [rand+1,2*rand-1,2*rand-1,2*rand-1,2*rand-1] ;

% bounds
lb = [0.5,-1,-1,-1,-1];
ub = [3,1,1,1,1];

options = optimoptions('lsqnonlin') ;
options = optimoptions(options,'MaxFunctionEvaluations',1e7,'MaxIterations',...
    1e4,'StepTolerance',eps,'FunctionTolerance',eps,'OptimalityTolerance',eps,'Display','off') ;
sol = lsqnonlin(@(x) systemDirichlet(x,R0_a,Z0_a,a,entry_thetas,entry_R,entry_Z),x0,lb,ub,options);

% dirichlet = [R0_a,Z0_a,a,e_a,S2_a,A2_a,S3_a,A3_a]
dirichlet = cat(2,[R0_a,Z0_a,a],sol(1:5)) ;


end