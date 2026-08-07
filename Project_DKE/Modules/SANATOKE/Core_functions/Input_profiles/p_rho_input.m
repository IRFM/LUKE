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
function p = p_rho_input(rho,equil)
% p = kB * (ne*Te + sum(ni*Ti))

qe = pc_dke_yp;

if isfield(equil.temperature.electron,'eTe') && isfield(equil.density.electron,'ene')
    [d2p_0, d4p_0, d6p_0, d8p_0,p0] = pressureCoeffs(equil);
    p = p0 + d2p_0./2.*rho.^2 + d4p_0./24.*rho.^4 + d6p_0./720.*rho.^6 + d8p_0./40320.*rho.^8;
else
    p = 1e3.*qe.*(ne_rho(rho,equil).*Te_rho(rho,equil) + sum(ni_rho(rho,equil).*Ti_rho(rho,equil),2));
end

end