function dni = dni_rho(rho,equil)



if isfield(equil.density,'ion')
    if isfield(equil.density.ion,'profile')
        dni = interp1(equil.rhos,equil.density.ion.derivative_profile,rho,"spline","extrap");
    end
elseif isfield(equil,'Zeff')
    dni = (dne_rho(rho,equil).*Zeff_rho(rho,equil) - ne_rho(rho,equil).*dZeff_rho(rho,equil))./Zeff_rho(rho,equil).^2;
end

end