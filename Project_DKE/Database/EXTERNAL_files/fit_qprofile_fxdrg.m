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
