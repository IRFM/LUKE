function y = interp_tprof_time_fxdrg(t,x,t_ref,method)
%
% Time interpolation
%
% by F-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr) and R. Goupillou (CEA/DSM/IRFM, romain.goupillou@cea.fr)
%
if nargin < 4,
    method = 'spline';
end
%
y = interp1(t,x,t_ref,method);