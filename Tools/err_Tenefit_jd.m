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
function err = err_Tenefit_jd(fit,rho,f,boundsfac,enforce)
%
y = enforce;
y(isnan(enforce)) = fit;
%
%err = norm(f-Tenefit_jd(rho,y(1),y(2),y(3),y(4)));
err = norm(f-Tenefit_jd(rho,y(1),y(2),y(3),y(4))) + ...
    boundsfac*norm(f([1,end])-Tenefit_jd(rho([1,end]),y(1),y(2),y(3),y(4)));