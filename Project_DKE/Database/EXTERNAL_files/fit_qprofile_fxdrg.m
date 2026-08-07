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
function [qmin,qmax,eq,qopt,chi2] = fit_qprofile_fxdrg(rho,q)
%
% Fit q-profile
%
% by F-X Duthoit (CEA/DSM/IRFM, francois-xavier.duthoit@cea.fr) and R. Goupillou (CEA/DSM/IRFM, romain.goupillou@cea.fr)
%
qopt = 1;%from LUKE reference
qmin = min(q);
qmax = max(q);
%
[eq,chi2] = fminsearch(@(x) sum((q - ((qmax - qmin).*rho.^x + qmin)).^2),1);
