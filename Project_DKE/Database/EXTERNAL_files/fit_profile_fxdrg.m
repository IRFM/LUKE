function [y0,ya,ey1,ey2,chi2] = fit_profile_fxdrg(x,y,model,init)
%
% Fit profile for a monotonous function
%
% by F-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr) and R.Goupillou (CEA/DSM/IRFM, romain.goupillou@cea.fr)
%
if nargin == 2,
    model = 1;
    init = [2,1];
end
%
y0 = y(1);
ya = y(end);
%
if model == 1,
    [z,chi2] = fminsearch(@(z) sum((y - ((y0 - ya)*(1 - x.^z(1)).^z(2) + ya)).^2),init);
    ey1 = z(1);
    ey2 = z(2);
elseif model == 2,
    [z,chi2] = fminsearch(@(z) sum((y - ((y0 - ya)*(exp(z) - exp(z*x.*x))/(exp(z)-1) + ya)).^2),init);
    ey1 = z;
    ey2 = NaN;
end
%



