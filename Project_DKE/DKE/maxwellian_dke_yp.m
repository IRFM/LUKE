function [fM] = maxwellian_dke_yp(gamma,pn2,dpn,xne_norm,xTe_norm,ir)
%
%Relativistic Maxwellian distribution generator normalized to the local density
%
%By Joan Decker (CEA-DRFC,joan.decker@cea.fr) and Yves Peysson (CEA-DRFC,yves.peysson@cea.fr)
%
if nargin < 6,
	error('Wrong number of input arguments in maxwellian_dke_yp')
end
%
fM = exp(-pn2./(1 + gamma)/xTe_norm(ir))/2/pi/xTe_norm(ir)/sqrt(2*pi*xTe_norm(ir));
normfM = 4*pi*integral_dke_jd(dpn,pn2.*fM,1);
fM = fM*xne_norm(ir)/normfM;

