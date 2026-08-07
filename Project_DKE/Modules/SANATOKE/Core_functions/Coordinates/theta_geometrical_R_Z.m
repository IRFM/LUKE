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
function theta_g = theta_geometrical_R_Z(R,Z,rhos,equil,amplitudes)
% geometrical angle theta ( ~ arctan(Z/R) )

% The origin of theta_g is {R0(rho),Z0(rho)}
R0 = R0_rho(rhos,equil,amplitudes);
Z0 = Z0_rho(rhos,equil,amplitudes);
theta_g = zeros(size(R));

for i=1:size(R,1)
    for j=1:size(R,2)
        r = R(i,j)-R0(i);
        z = Z(i,j)-Z0(i);
        if r>0 && z>=0, theta_g(i,j) = atan(z/r);
        elseif r>0 && z<0, theta_g(i,j) = 2*pi + atan(z/r);
        elseif r<0, theta_g(i,j) = pi+atan(z/r);
        elseif r==0 && z>0, theta_g(i,j) = pi/2;
        elseif r==0 && z<0, theta_g(i,j) = 3*pi/2;
        else, theta_g(i,j) = 0;
        end
    end
end

end
