function ray = radialdampingprofile_jd(ray,nr_dep,display_mode)
%
% calculates the radial power deposition profile of a ray for which the
% damping is already calculated
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 3,
    display_mode = 0;
end
%
ns = length(ray.ss);
%
rho_dep_S = linspace(0,1,nr_dep+1);
ray.rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
drho_dep = diff(rho_dep_S);
%
if isfield(ray,'sP_2piRp') & isfield(ray,'srho'),
    sP_2piRp_norm = ray.sP_2piRp/ray.sP_2piRp(1);
    %
    ray.dPnormdrho = zeros(1,nr_dep);
    srhop = ray.srho(1);
    irho_depp = find(srhop > rho_dep_S(1:end-1) & srhop <= rho_dep_S(2:end));
    for is = 2:ns,
        srhom = srhop;
        irho_depm = irho_depp;
        srhop = ray.srho(is);
        irho_depp = find(srhop > rho_dep_S(1:end-1) & srhop <= rho_dep_S(2:end));
        sPm = sP_2piRp_norm(is-1);
        sPp = sP_2piRp_norm(is);
        %
        if is == 302,
            is = 302;
        end

        %
        if irho_depm == irho_depp,
            ray.dPnormdrho(irho_depm) = ray.dPnormdrho(irho_depm) + ...
                (sPm - sPp)/drho_dep(irho_depm);
        elseif srhop > srhom,
            ray.dPnormdrho(irho_depm) = ray.dPnormdrho(irho_depm) + ...
                (sPm - sPp)*(rho_dep_S(irho_depm + 1) - srhom)/(srhop - srhom)/drho_dep(irho_depm);
            ray.dPnormdrho(irho_depm+1:irho_depp-1) = ray.dPnormdrho(irho_depm+1:irho_depp-1) + ...
                (sPm - sPp)*(rho_dep_S(irho_depm+2:irho_depp) - rho_dep_S(irho_depm+1:irho_depp-1))/(srhop - srhom)./drho_dep(irho_depm+1:irho_depp-1);
            ray.dPnormdrho(irho_depp) = ray.dPnormdrho(irho_depp) + ...
                (sPm - sPp)*(srhop - rho_dep_S(irho_depp))/(srhop - srhom)/drho_dep(irho_depm);
        else
            ray.dPnormdrho(irho_depm) = ray.dPnormdrho(irho_depm) + ...
                (sPm - sPp)*(srhom - rho_dep_S(irho_depm))/(srhom - srhop)/drho_dep(irho_depm);
            ray.dPnormdrho(irho_depp+1:irho_depm-1) = ray.dPnormdrho(irho_depp+1:irho_depm-1) + ...
                (sPm - sPp)*(rho_dep_S(irho_depp+2:irho_depm) - rho_dep_S(irho_depp+1:irho_depm-1))/(srhom - srhop)./drho_dep(irho_depp+1:irho_depm-1);
            ray.dPnormdrho(irho_depp) = ray.dPnormdrho(irho_depp) + ...
                (sPm - sPp)*(rho_dep_S(irho_depp + 1) - srhop)/(srhom - srhop)/drho_dep(irho_depm);
        end     
    end
    %
    if display_mode >= 1,
        info_dke_yp(2,['ray radial damping calculated']);
    end
else
    if display_mode >= 1,
        info_dke_yp(2,['ray radial damping cannot be calculated']);
    end
end


