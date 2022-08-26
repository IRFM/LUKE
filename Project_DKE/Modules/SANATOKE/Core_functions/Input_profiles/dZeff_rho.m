function dZeff = dZeff_rho(rho,equil)

a = equil.a;
Zeff_0 = equil.Zeff.Zeff_0;
Zeff_a = equil.Zeff.Zeff_a;
eZeff = equil.Zeff.eZeff;

dZeff = -2.*rho./a.^2.*eZeff.*(Zeff_0-Zeff_a).*(1-rho.^2./a.^2).^(eZeff-1);

end