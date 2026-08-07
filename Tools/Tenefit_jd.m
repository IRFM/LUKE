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
function f = Tenefit_jd(rho,f0,fa,e1,e2)
%
if all(imag(fa) == 0),%fa is edge value
    f = (f0 - fa).*(1 - rho.^e1).^e2 + fa;
elseif all(real(fa) == 0),%fa is edge/core value
    f = f0.*((1 - imag(fa)).*(1 - rho.^e1).^e2 + imag(fa));
else
    error('edge value not valid.')
end