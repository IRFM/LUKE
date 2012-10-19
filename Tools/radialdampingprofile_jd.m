function [sdPdrho_dep,rho_dep] = radialdampingprofile_jd(srho,sP,rho_dep_S)
%
% calculates the radial power deposition profile of a ray for which the
% damping is already calculated
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 3,
    rho_dep_S = 40;
end
%
if nargin < 2,
    error('Not enough input arguments');
end
%
if length(rho_dep_S) == 1,% number of points is given
    rho_dep_S = linspace(0,1,rho_dep_S+1);
end
%
if rho_dep_S(1) > 0.000001,
    rho_dep_S = [0,rho_dep_S];
end
%
if rho_dep_S(end) < 0.999999,
    rho_dep_S = [rho_dep_S,1];
end
%
ns = length(srho);
%
rho_dep = (rho_dep_S(1:end-1) + rho_dep_S(2:end))/2;
drho_dep = diff(rho_dep_S);
nr_dep = length(rho_dep);
%
sdPdrho_dep = zeros(1,nr_dep);
srhop = srho(1);
irho_depp = find(srhop > rho_dep_S(1:end-1) & srhop <= rho_dep_S(2:end));
for is = 2:ns,
    srhom = srhop;
    irho_depm = irho_depp;
    srhop = srho(is);
    irho_depp = find(srhop > rho_dep_S(1:end-1) & srhop <= rho_dep_S(2:end));
    %
    sPm = sP(is-1);
    sPp = sP(is);
    %
    if isempty(irho_depm) || isempty(irho_depp),
        continue
    elseif irho_depm == irho_depp,
        sdPdrho_dep(irho_depm) = sdPdrho_dep(irho_depm) + ...
            (sPm - sPp)/drho_dep(irho_depm);
    elseif srhop > srhom,
        sdPdrho_dep(irho_depm) = sdPdrho_dep(irho_depm) + ...
            (sPm - sPp)*(rho_dep_S(irho_depm + 1) - srhom)/(srhop - srhom)/drho_dep(irho_depm);
        sdPdrho_dep(irho_depm+1:irho_depp-1) = sdPdrho_dep(irho_depm+1:irho_depp-1) + ...
            (sPm - sPp)*(rho_dep_S(irho_depm+2:irho_depp) - rho_dep_S(irho_depm+1:irho_depp-1))/(srhop - srhom)./drho_dep(irho_depm+1:irho_depp-1);
        sdPdrho_dep(irho_depp) = sdPdrho_dep(irho_depp) + ...
            (sPm - sPp)*(srhop - rho_dep_S(irho_depp))/(srhop - srhom)/drho_dep(irho_depp);
    else
        sdPdrho_dep(irho_depm) = sdPdrho_dep(irho_depm) + ...
            (sPm - sPp)*(srhom - rho_dep_S(irho_depm))/(srhom - srhop)/drho_dep(irho_depm);
        sdPdrho_dep(irho_depp+1:irho_depm-1) = sdPdrho_dep(irho_depp+1:irho_depm-1) + ...
            (sPm - sPp)*(rho_dep_S(irho_depp+2:irho_depm) - rho_dep_S(irho_depp+1:irho_depm-1))/(srhom - srhop)./drho_dep(irho_depp+1:irho_depm-1);
        sdPdrho_dep(irho_depp) = sdPdrho_dep(irho_depp) + ...
            (sPm - sPp)*(rho_dep_S(irho_depp + 1) - srhop)/(srhom - srhop)/drho_dep(irho_depp);
    end     
end
%

