function rho_S = optgrid_dke_jd(waves,rho_S,display_mode);
%
% This function generates a non-uniform radial grid of nr points based on
% the linear damping of waves such that there are more points in regions of
% large absorption.
%
% by J. Decker and Y. Peysson (joan.decker@cea.fr)
%
if nargin < 3,
    display_mode = 0;
end
%
if length(rho_S) ~= 1 | rho_S <= 1,
    return
else
    nr = rho_S;
    clear rho_S
end
%
nr_dep = 1000;%number of grid point in radial damping calculations
finefac = 1;%fineness factor
%
dP = zeros(1,nr_dep);
%
rho_dep_S = linspace(0,1,nr_dep+1);
rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
drho_dep = 1/nr_dep;
%
for iw = 1:length(waves);
    %
    for iray = 1:length(waves{iw}.rays),
        %
        ray = radialdampingprofile_jd(waves{iw}.rays{iray},nr_dep,display_mode);
        %
        if isfield(ray,'sP_2piRp')  & isfield(ray,'srho'),
            dP = dP + ray.dPnormdrho*ray.sP_2piRp(1)*drho_dep;
        end
        %
    end
end
%
Ptot = sum(dP);
%
if Ptot == 0,
    dP0 = 1;
else
    dP0 = Ptot/finefac/nr_dep;
end
%
dP = dP + dP0*ones(1,nr_dep);
rP = [0,cumsum(dP)];
P = rP(end);
%
rho_S = interp1(rP,rho_dep_S,P*linspace(0,1,nr+1));
%














