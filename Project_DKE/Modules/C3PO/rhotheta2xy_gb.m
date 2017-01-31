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
