function ne = ne_rho(rho,equil)

a = equil.a;

if isfield(equil.density.electron,'profile')
    ne = interp1(equil.rhos,equil.density.electron.profile,rho,"spline","extrap");
else
    ne_0 = equil.density.electron.ne_0;
    ne_a = equil.density.electron.ne_a;
    ene = equil.density.electron.ene;

    ne = (ne_0-ne_a).*(1-rho.^2./a.^2).^ene + ne_a;
end

end
