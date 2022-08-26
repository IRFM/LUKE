function IT = IT_rho_input(rho,equil)

if isfield(equil.current.IT,'profile')
    IT = interp1(equil.rhos,equil.current.IT.profile,rho,"spline","extrap");
elseif isfield(equil.current.IT,'alpha_j')
    [d2IT_0, d4IT_0, d6IT_0, d8IT_0] = ITCoeffs(equil);
    IT = d2IT_0./2.*rho.^2 + d4IT_0./24.*rho.^4 + d6IT_0./720.*rho.^6 + d8IT_0./40320.*rho.^8;
else
    error('No input for toroidal current profile');
end


end

