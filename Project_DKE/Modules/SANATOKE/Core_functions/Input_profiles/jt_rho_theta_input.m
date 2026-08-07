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
function jt = jt_rho_theta_input(rho,theta,equil)
% only used if jt was given as an input

if isfield(equil.current,'jt')
    if isfield(equil.current.jt,'profile')
        jt = interp2(equil.current.jt.thetas,equil.current.jt.rhos,equil.current.jt.profile,theta,rho);
    end
else
    error('No input profile has been entered for jt');
end

end