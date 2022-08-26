function dne = dne_rho(rho,equil)

a = equil.a;

if isfield(equil.density.electron,'profile')
    dne = interp1(equil.rhos,equil.density.electron.derivative_profile,rho,"spline","extrap");
else
    ne_0 = equil.density.electron.ne_0;
    ne_a = equil.density.electron.ne_a;
    ene = equil.density.electron.ene;

    dne = -2.*rho./a.^2.*ene.*(ne_0-ne_a).*(1-rho.^2./a.^2).^(ene-1);
end

end