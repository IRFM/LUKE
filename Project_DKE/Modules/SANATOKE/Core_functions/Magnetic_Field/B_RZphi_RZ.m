function [B_R,B_Z,B_phi] = B_RZphi_RZ(R,Z,equil,amplitudes)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if length(R)>1 || length(Z)>1
attention risque de ne pas fonctionner, car rho_R_Z(R,Z) et theta_R_Z(R,Z) donnent des matrices
Or B_RZphi_rhotheta a besoin de vecteurs rho et theta
end

[B_R,B_Z,B_phi] = B_RZphi_rhotheta(rho_R_Z(R,Z,equil,amplitudes),theta_R_Z(R,Z,equil,amplitudes),equil,amplitudes);

end

