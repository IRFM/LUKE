function dIT = dIT_rho_input(rho,equil)

if isfield(equil.current.IT,'profile')
    dIT = interp1(equil.rhos,equil.current.IT.derivative_profile,rho,"spline","extrap");
elseif isfield(equil.current.IT,'alpha_j')
    [d2IT_0, d4IT_0, d6IT_0, d8IT_0] = ITCoeffs(equil);
    dIT = d2IT_0.*rho + d4IT_0./6.*rho.^3 + d6IT_0./120.*rho.^5 + d8IT_0./5040.*rho.^7;
else
    error('No input for toroidal current profile');
end

end

