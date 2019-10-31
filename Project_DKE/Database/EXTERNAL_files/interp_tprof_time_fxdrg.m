function y = interp_tprof_time_fxdrg(t,x,t_ref,t1,t2,method)
%
% Time interpolation
%
% by F-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr) and R. Goupillou (CEA/DSM/IRFM, romain.goupillou@cea.fr)
%
if nargin < 4,
    method = 'spline';
end
%
if t1 == t2
    y = interp1(t,x,t_ref,method);
elseif t1 ~= t2
    dt = t2-t1;
    for it = 1:length(t_ref)
        y(it,:) = mean(interp1(t(:,1),x,t(t(:,1)>t_ref-dt/2 & t(:,1)<t_ref+dt/2)',method),1);
    end
end
    