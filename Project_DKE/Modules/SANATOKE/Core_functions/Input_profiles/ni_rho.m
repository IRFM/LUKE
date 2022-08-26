function ni = ni_rho(rho,equil)
%ZEFF_RHO Summary of this function goes here
%   Detailed explanation goes here

if isfield(equil.density,'ion')
    if isfield(equil.density.ion,'profile')
        ni = interp1(equil.rhos,equil.density.ion.profile,rho,"spline","extrap");
    end
elseif isfield(equil,'Zeff')
    ni = ne_rho(rho,equil)./Zeff_rho(rho,equil);
end

end
