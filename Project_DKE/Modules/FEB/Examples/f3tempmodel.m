function [XXf] = f3tempmodel(equilDKE,momentumDKE,frac,Tpar,Tperp,Tback,Ecut)
%R5-X2 - Calculation of the electron momentum distribution function using the 3 temperatures model
%
% Calculation of the electron momentum distribution function using the 3
% temperatures model. Simple modeling of the fast electron tail driven by
% the LH wave, useful for benchmarking the Fast ELectron Bremsstrahlung
% calculations.
%
%INPUTS:
%
%   - equilDKE: magnetic equilibrium from LUKE [structure]
%   - momentumDKE: momentum space grid definitions from LUKE [structure]
%   - frac: fraction of fast electrons [1,1]
%   - Tpar: Forward temperature (keV) [1,1] 
%   - Tperp: Perpendicular temperature (keV) [1,1]
%   - Tback: Backward temperature (keV) [1,1]
%   - Ecut: Up limit of the distribution (keV) [1,1]
%
%by Y. Peysson (CEA/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/IRFM) (joan.decker@cea.fr)
%
Xpn = momentumDKE.pn'*ones(1,length(momentumDKE.mhu));
Xmhu = ones(length(momentumDKE.pn),1)*momentumDKE.mhu;
Xpperp2 = Xpn.*Xpn.*(1 - Xmhu.*Xmhu);
Xppar = Xpn.*Xmhu;
Xppar2 = Xppar.*Xppar;
%
maskp = Xppar >= 0;
maskm = 1 - maskp;
%
Tparn = repmat(Tpar,length(equilDKE.xTe),1)./equilDKE.xTe(:);
Tperpn = repmat(Tperp,length(equilDKE.xTe),1)./equilDKE.xTe(:);
Tbackn = repmat(Tback,length(equilDKE.xTe),1)./equilDKE.xTe(:);
%
ZTparn = shiftdim(repmat(Tparn,[1,size(Xppar,1),size(Xppar,2)]),1);
ZTperpn = shiftdim(repmat(Tperpn,[1,size(Xppar,1),size(Xppar,2),1]),1);
ZTbackn = shiftdim(repmat(Tbackn,[1,size(Xppar,1),size(Xppar,2),1]),1);
%
Zpperp2 = repmat(Xpperp2,[1,1,length(equilDKE.xTe)]);
Zppar2 = repmat(Xppar2,[1,1,length(equilDKE.xTe)]);
%
Zf = exp(-Zppar2./ZTparn).*exp(-Zpperp2./ZTperpn);



