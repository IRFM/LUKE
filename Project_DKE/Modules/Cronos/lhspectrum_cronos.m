function [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons,lob)
%
% Calculate initial N// et PLH for C3PO from simplified or full power spectrum (from SWAN coupling code for example)
%
%
%by Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC) and J. Decker <joan.decker@cea.fr> (CEA-DRFC)
%
if strcmp(lob,'Yes')
    Plhtot = abs(cons)*[directivity,1-directivity];%initial power in the ray (W) (main lobe) [n_antenna,m_lobe]
    Npar0 = [angle(cons),-6.0];%Initial Npar value (main lobe) [n_antenna,m_lobe]
else
    Plhtot = abs(cons)*directivity;%initial power in the ray (W) (main lobe) [n_antenna,m_lobe]
    Npar0 = angle(cons);%Initial Npar value (main lobe) [n_antenna,m_lobe]
end
%
% For CRONOS, N//> 0 means always co-current, whatever the toroidal Bfield or the direction of Ip
%
Npar0 = -signe.ip*signe.b0*Npar0;%Initial Npar value (main lobe) [n_antenna,m_lobe]
%

