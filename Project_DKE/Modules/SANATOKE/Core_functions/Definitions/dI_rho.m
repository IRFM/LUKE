function dI = dI_rho(rho,equil,amplitudes)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


rhos = (0:equil.a/200:equil.a)';
I_rhos = I_rho(rhos,equil,amplitudes);
dI_rhos = gradient(I_rhos,rhos);
dI = interp1(rhos,dI_rhos,rho,"spline","extrap");

end