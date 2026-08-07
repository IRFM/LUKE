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
function system = systemDirichlet(x,R0_a,Z0_a,a,entry_thetas,entry_R,entry_Z)
% Defines the system to be solved to determine the Dirichlet parameters
% x = [e_a,S2_a,A2_a,S3_a,A3_a]

dirichlet = cat(2,R0_a,Z0_a,a,x);

np = length(entry_thetas);
computed_thetas = zeros(1,np);
computed_R = zeros(1,np);
computed_Z = zeros(1,np);

% calculation of computed points and thetas
for i=1:np
    RZ = RZ_a(entry_thetas(i),dirichlet)' ;
    R = RZ(1);
    Z = RZ(2);
    computed_R(i) = R;
    computed_Z(i) = Z;
    
    r = R-R0_a;
    z = Z-Z0_a;
    if r>0 && z>=0, theta = atan(z/r);
    elseif r>0 && z<0, theta = atan(z/r) + 2*pi;
    elseif r<0, theta = pi+atan(z/r);
    elseif r==0 && z>0, theta = pi/2;
    elseif r==0 && z<0, theta = 3*pi/2;
    else, theta = 0;
    end
    computed_thetas(i) = theta;
end

% Points on a regular grid of thetas
entry_R_interpolant = griddedInterpolant(entry_thetas,entry_R);
entry_Z_interpolant = griddedInterpolant(entry_thetas,entry_Z);
% If computed_thetas is not sorted (first iterations), we use entry_thetas instead
if ~issorted(computed_thetas), computed_thetas = entry_thetas; end
computed_R_interpolant = griddedInterpolant(computed_thetas,computed_R);
computed_Z_interpolant = griddedInterpolant(computed_thetas,computed_Z);

regular_thetas = linspace(0,2*pi,np);
entry_R = entry_R_interpolant(regular_thetas);
entry_Z = entry_Z_interpolant(regular_thetas);
computed_R = computed_R_interpolant(regular_thetas);
computed_Z = computed_Z_interpolant(regular_thetas);

% Definition of the equations
system(1:np) = computed_R - entry_R;
system(np+1:2*np) = computed_Z - entry_Z;

end
