% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
drho = gradient(rho);
norm_curr = trapz(currprof.*rho.*drho);
%
currprofn = currprof/norm_curr;%normalisation
%
rho(1) = eps;
%
li = 2*trapz(trapz(triu((ones(length(rho),1)*(currprofn.*rho.*drho))')).^2.*drho./rho);
%
