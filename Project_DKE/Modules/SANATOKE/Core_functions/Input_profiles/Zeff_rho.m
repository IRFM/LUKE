function Zeff = Zeff_rho(rho,equil)
%ZEFF_RHO Summary of this function goes here
%   Detailed explanation goes here

a = equil.a;
Zeff_0 = equil.Zeff.Zeff_0;
Zeff_a = equil.Zeff.Zeff_a;
eZeff = equil.Zeff.eZeff;

Zeff = (Zeff_0-Zeff_a).*(1-rho.^2./a.^2).^eZeff + Zeff_a;

end

