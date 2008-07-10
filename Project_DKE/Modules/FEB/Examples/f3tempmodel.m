 function [XXf,xnorm] = f3tempmodel(equilDKE,momentumDKE,lambda,pmin,Tfor,Tperp,Tback,Ecut,mode)
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
%   - lambda: fraction of fast electrons [1,1]
%   - pmin : boundary between Maxwellian distribution and tail distribution [nr,1]
%   - Tfor: Forward temperature (keV) [1,1] 
%   - Tperp: Perpendicular temperature (keV) [1,1]
%   - Tback: Backward temperature (keV) [1,1]
%   - Ecut: Up limit of the distribution (keV) [1,1]
%   - mode: test mode activated if 1 [1,1]
%
%OUTPUT:
%
%   - XXf: distribution function normalized to unity [npn,nmhu,nr]
%   - xnorm: normalisation of the distribution function (must be unity) [nr,1]
%
%by Y. Peysson (CEA/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/IRFM) (joan.decker@cea.fr)
% Modified by F.-X Duthoit (CEA/IRFM) (francois-xavier.duthoit@cea.fr)
%
if nargin < 7
    error('Wrong number of input arguments in f3tempmodel');
end
%
if nargin == 7,
    xnorm = [];
    mode = 0;
end
%
Xpn = momentumDKE.pn'*ones(1,length(momentumDKE.mhu));
Xmhu = ones(length(momentumDKE.pn),1)*momentumDKE.mhu;
Xpperp2 = Xpn.*Xpn.*(1 - Xmhu.*Xmhu);
Xppar = Xpn.*Xmhu;
Xppar2 = Xppar.*Xppar;
%
Xmask = Xppar >= 0;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
% Normalisation reference values
%
T_ref = max(equilDKE.xTe);
beta_ref = sqrt(T_ref/mc2);
%
% Temperature and energy normalisation
%
Ten = equilDKE.xTe/T_ref;
Tforn = repmat(Tfor,length(equilDKE.xTe),1)/T_ref;
Tperpn = repmat(Tperp,length(equilDKE.xTe),1)/T_ref;
Tbackn = repmat(Tback,length(equilDKE.xTe),1)/T_ref;
Ecutn = repmat(Ecut,length(equilDKE.xTe),1)/mc2;
%
pmax = 1/beta_ref*sqrt((Ecutn+1).^2-1);
%
ZTen = shiftdim(repmat(Ten',[1,size(Xppar,1),size(Xppar,2)]),1);
ZTforn = shiftdim(repmat(Tforn,[1,size(Xppar,1),size(Xppar,2)]),1);
ZTperpn = shiftdim(repmat(Tperpn,[1,size(Xppar,1),size(Xppar,2),1]),1);
ZTbackn = shiftdim(repmat(Tbackn,[1,size(Xppar,1),size(Xppar,2),1]),1);
ZEcutn = shiftdim(repmat(Ecutn,[1,size(Xppar,1),size(Xppar,2)]),1);
%
Zpn = repmat(Xpn,[1,1,length(equilDKE.xTe)]);
Zpperp2 = repmat(Xpperp2,[1,1,length(equilDKE.xTe)]);
Zppar2 = repmat(Xppar2,[1,1,length(equilDKE.xTe)]);
%
Zpmax = shiftdim(repmat(pmax,[1,size(Xppar,1),size(Xppar,2)]),1);
Zpmin = shiftdim(repmat(pmin,[1,size(Xppar,1),size(Xppar,2)]),1);
%
fMmask = (Zpn - Zpmin < 0).*(Zpn >= 0);
f3Tmask = (Zpn - Zpmax <= 0).*(Zpn - Zpmin >= 0);
Zmask = repmat(Xmask,[1,1,length(equilDKE.xTe)]);
%
Zgamma = sqrt(Zpn.*Zpn*beta_ref^2 + 1);
%
% Maxwellian distribution
%
Zm = exp(-Zpn.*Zpn./((Zgamma + 1).*ZTen));
%
% 3T distribution
%
Zf_for = Zmask.*exp(-Zppar2./ZTforn/2).*exp(-Zpperp2./ZTperpn/2);
Zf_back = (1-Zmask).*exp(-Zppar2./ZTbackn/2).*exp(-Zpperp2./ZTperpn/2);
Zf = Zf_for + Zf_back;
%
% Normalisation coefficients
%
alphaM = beta_ref^3*(4*pi*exp((Ten*beta_ref^2).^(-1))*4/3*gamma(3/2+1)/sqrt(pi).*besselk(2,(Ten*beta_ref^2).^(-1)).*(Ten*beta_ref^2)).^(-1);
alpha3T = (sqrt(2*pi^3)*Tperpn.*(sqrt(Tforn)+sqrt(Tbackn))).^(-1);
ZalphaM = shiftdim(repmat(alphaM',[1,size(Xppar,1),size(Xppar,2)]),1);
Zalpha3T = shiftdim(repmat(alpha3T,[1,size(Xppar,1),size(Xppar,2)]),1);
%
% Step vectors
%
dx = repmat(momentumDKE.dpn',[1,length(equilDKE.xTe)]);
dxmhu = momentumDKE.dmhu;
%
% Norm calculations
%
fMnorm = alphaM'.*fnorm(fMmask.*Zm);
f3Tnorm = alpha3T.*fnorm(f3Tmask.*Zf);
%
% Distribution weight coefficients
%
lambdaM = (1 - lambda)*fMnorm.^(-1);
lambda3T = lambda*f3Tnorm.^(-1);
ZlambdaM = shiftdim(repmat(lambdaM,[1,size(Xppar,1),size(Xppar,2)]),1);
Zlambda3T = shiftdim(repmat(lambda3T,[1,size(Xppar,1),size(Xppar,2)]),1);
%
% Distribution function
%
XXf = ZlambdaM.*ZalphaM.*Zm.*fMmask + Zlambda3T.*Zalpha3T.*Zf.*f3Tmask;
xnorm = fnorm(XXf);
%
% Norm function
%
     function y = fnorm(x)
         y = 2*pi*integral_dke_jd(ones(size(Xppar,1),1),dx.*integral_dke_jd(dxmhu,Zpn.*Zpn.*x,2),1);
     end
 end