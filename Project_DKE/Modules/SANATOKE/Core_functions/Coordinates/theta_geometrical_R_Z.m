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
