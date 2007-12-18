function [Plhtot,Npar0] = lhspectrum_cronos(directivity,signe,cons,cons_spec)
%
% Calculate initial N// et PLH for C3PO from simplified or full power spectrum (from SWAN coupling code for example)
%
%
%by Y.Peysson <yves.peysson@cea.fr> (CEA-DRFC) and J. Decker <joan.decker@cea.fr> (CEA-DRFC)
%
if 1,%length(cons_spec) == 1,%no input power spectrum from coupling code like SWAN
    %
    Plhtot = abs(cons)*[directivity,1-directivity];%initial power in the ray (W) (main lobe) [n_antenna,m_lobe]
    Npar0 = [angle(cons),-6.0];%Initial Npar value (main lobe) [n_antenna,m_lobe]
    %
else
  	
  	
 %%WARNING the signe is not properly set here %%%%%%% 	
  	
  	for ia = 1:size(cons_spec.npar,3),%loop on the number of LH antennas
	   Npar_p = cons_spec.npar(1,find(cons_spec.npar(1,:,ia) > 0),ia);
	   Plh_p = cons_specpow(1,find(cons_spec.npar(1,:,ia) > 0),ia);
	   Npar_m = cons_spec.npar(1,find(cons_spec.npar(1,:,ia) < 0),ia);
	   Plh_m = cons_specpow(1,find(cons_spec.npar(1,:,ia) < 0),ia);
%
	   Plhtot(ia,:) = [trapz_dke_yp([Npar_p(:),Plh_p(:)]),trapz_dke_yp([Npar_m(:),Plh_m(:)])];
	   Npar0(ia,:) = [Npar_p(find(Plh_p == max(Plh_p))),Npar_m(find(Plh_m == max(Plh_m)))];
   end
end
%
% For CRONOS, N//> 0 means always co-current, whatever the toroidal Bfield or the direction of Ip
%
Npar0 = -signe.ip*signe.b0*Npar0;%Initial Npar value (main lobe) [n_antenna,m_lobe]
%

