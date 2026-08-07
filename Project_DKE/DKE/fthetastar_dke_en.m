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
function [y] = fthetastar_dke_en(theta,rho,equil_fit,B0,ksi0,gamma)
%

%
y = NaN(1,length(theta));
%
for itheta = 1:length(theta),
    %
    equil_val = equilval_yp(equil_fit,rho,theta(itheta));
    %
    y(itheta) = equil_val.B/B0 - 2.0/(1 - ksi0*ksi0)/(gamma + 1.0);
    %
end

