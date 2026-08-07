% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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