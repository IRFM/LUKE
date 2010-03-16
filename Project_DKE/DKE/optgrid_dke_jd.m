function [rho_S,pnmax_S] = optgrid_dke_jd(waves,rho_S,pnmax_S,equil,w_mask,display_mode)
%
% This function generates a non-uniform radial grid of nr points based on
% the linear damping of waves such that there are more points in regions of
% large absorption.
%
% by J. Decker (joan.decker@cea.fr) (CEA/DSM/IRFM) and Y. Peysson (yves.peysson@cea.fr) (CEA/DSM/IRFM) 
%
if nargin < 6,
    display_mode = 0;
end
%
if nargin < 5 || any(isnan(w_mask)),
    w_mask = 1:length(waves);
elseif max(w_mask) > length(waves)
    info_dke_yp(2,'Warning : max(w_mask) > length(waves), dismissed.');
    iw = w_mask > length(waves);
    w_mask(iw) = [];
end
%
if length(rho_S) ~= 1 || rho_S <= 1,
    return
else
    nr = rho_S;
    clear rho_S
    info_dke_yp(2,'Radial grid automaticaly generated for optimizing the RF absorption.');
end
%
nr_dep = 1000;%number of grid point in radial damping calculations
finefac = 1;%fineness factor
%
dP = zeros(1,nr_dep);
%
rho_dep_S = linspace(0,1,nr_dep+1);
drho_dep = 1/nr_dep;
%
for iw = w_mask;
    %
    for iray = 1:length(waves{iw}.rays),
        %
        ray = radialdampingprofile_jd(waves{iw}.rays{iray},nr_dep,display_mode);
        %
        if isfield(ray,'sP_2piRp')  && isfield(ray,'srho'),
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
	%
	if pnmax_S < 0,
		%
		pnmax_S = -pnmax_S;
		%
		rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
		irmax = find(dP == max(dP));
		rhoabs = rho_dep(irmax(1));
		%
		prho = equil.ptx(:,1)/equil.ptx(end,1);
		pTe = equil.pTe;
		%
		te0 = max(pTe);
		teabs = interp1(prho,pTe,rhoabs);
		%
		pnmax_S = max([pnmax_S*sqrt(teabs/te0),5]);% 5 is minimum to avoid losses in maxwellian
	end
	%
    dP0 = Ptot/finefac/nr_dep;
end
%
dP = dP + dP0*ones(1,nr_dep);
rP = [0,cumsum(dP)];
P = rP(end);
%
rho_S = interp1(rP,rho_dep_S,P*linspace(0,1,nr+1));
%














