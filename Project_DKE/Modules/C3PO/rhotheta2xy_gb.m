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
function [x,y] = rhotheta2xy_gb(equil_fit,rho,theta)
%
% Find the curvilinear couple associated to a cartesian one
%
% INPUT
%    - equil_fit: interpolated structure
%    - x : Cartesian coordinate x
%    - y : Cartesian coordinate y

% OUTPUT: 
%    - rho : Normalized radial coordinate
%    - theta : Poloidal angle

% By Guillaume Brochard (CEA-IRFM, guillaume.brochard@cea.fr)
data = equilval_yp(equil_fit,rho,theta);
x = data.x;
y = data.y;
end
