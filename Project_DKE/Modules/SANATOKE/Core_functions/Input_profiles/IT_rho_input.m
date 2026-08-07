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

