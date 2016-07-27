function [li] = internal_inductance_yp(rho,currprof)
% LUKE - calculation of the internal inductance for a given current density profile (cylindrical toroidal MHD equilibrium)
%
% Calculation of the internal inductance for a given current density profile (cylindrical toroidal MHD equilibrium)
%
% INPUT
%
%    - rho: normalized minor radius
%    - currprof: current density profile on rho grid (may not be normalized)
%
% OUTPUT: 
%
%    - li: normalized internal inductance li
%
% by Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CRPP-EPFL, joan.decker@epfl.ch)
%
drho = gradient(rho);
norm_curr = trapz(currprof.*rho.*drho);
%
currprofn = currprof/norm_curr;%normalisation
%
rho(1) = eps;
%
li = 2*trapz(trapz(triu((ones(length(rho),1)*(currprofn.*rho.*drho))')).^2.*drho./rho);
%
