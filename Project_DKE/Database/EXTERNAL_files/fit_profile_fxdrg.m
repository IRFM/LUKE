function [y0,ya,ey1,ey2,chi2] = fit_profile_fxdrg(x,y,model,init,dispfit)
%
% Fit profile for a monotonous function
%
% by F-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr) and R.Goupillou (CEA/DSM/IRFM, romain.goupillou@cea.fr)
%
if nargin == 2,
    model = 1;
    init = [2,2];
    dispfit = 0;
elseif nargin == 3,
    init = [2,2];
    dispfit = 0;
elseif nargin == 4,
    dispfit = 0;
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
if dispfit,
	if model == 1,
		yfit = (y0 - ya)*(1 - x.^ey1).^ey2 + ya;
	elseif model == 2,
		yfit = (y0 - ya)*(exp(z) - exp(ey1*x.*x))/(exp(ey1)-1) + ya;	
	end
	figure('Name','Fit profile'),plot(x,y,'r',x,yfit,'b-');legend('Data','Fit')
end
%


