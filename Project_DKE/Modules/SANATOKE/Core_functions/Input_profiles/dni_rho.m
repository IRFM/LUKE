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
function dni = dni_rho(rho,equil)



if isfield(equil.density,'ion')
    if isfield(equil.density.ion,'profile')
        dni = interp1(equil.rhos,equil.density.ion.derivative_profile,rho,"spline","extrap");
    end
elseif isfield(equil,'Zeff')
    dni = (dne_rho(rho,equil).*Zeff_rho(rho,equil) - ne_rho(rho,equil).*dZeff_rho(rho,equil))./Zeff_rho(rho,equil).^2;
end

end