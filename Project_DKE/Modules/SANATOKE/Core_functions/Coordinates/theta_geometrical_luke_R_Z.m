function theta_g = theta_geometrical_luke_R_Z(R,Z,amplitudes)
% geometrical angle theta ( ~ arctan(Z/R) ) between 0 and 2*pi

% The origin of theta_g is {Rm,Zm}
Rm = amplitudes(2);
Zm = amplitudes(5);
theta_g = zeros(size(R));

for i=1:size(R,1)
    for j=1:size(R,2)
        r = R(i,j)-Rm;
        z = Z(i,j)-Zm;
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
