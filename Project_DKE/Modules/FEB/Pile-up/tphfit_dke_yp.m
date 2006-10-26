function [Tph,eTph,A,eA,Q] = tphfit_dke_yp(Ei,Ni,dNi)
%
%	Determination of the photon temperature from the energy spectrum,
%   taking into account of an appropriate weight for each energy channel
%   log(Ei*Ni/dE) = a+b*Ei -> Tph = -1/b
%   See Numerical Recipes, W H. Press et al., Cambridge University Press, 2nd Edition, 1994
%
%	Input:
%
%		- Ei: Photon energy grid (keV) [n,m]
%		- Ni: Number of counts (Counts) [n,m]
%		- dNi: Uncertainty of the number of counts (Counts) [n,m]
%
%	Output:
%
%		- Tph: Estimated photon temperature (keV) [1,m]
%		- eT: Estimated absolute error on the photon temperature (keV) [1,m]
%		- A: Amplitude of the energy spectrum (Counts) [1,m]
%		- eA: Estimated absolute error on the amplitude of the energy spectrum (Counts) [1,m]
%       - Q: Goodness-of-fit of the data to the model (Q > 0.1 for the fit to be believable) [1,m]
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
if nargin < 3,
	error('Wrong number of input arguments for tphfit_dke_yp');
end
%
sNi = size(Ni);
sEi = size(Ei);
sdNi = size(dNi);
if sEi(1)~=sNi(1) | sEi(1)~=sdNi(1) ,
	error('Size of data are not consistent !!!');
end
%
Tph = zeros(1,sNi(2));
eTph = zeros(1,sNi(2));
A = zeros(1,sNi(2));
eA = zeros(1,sNi(2));
Q = zeros(1,sNi(2));
chi2 = zeros(1,sNi(2));
%
dE = Ei(2,1)-Ei(1,1);
yi = log(Ei.*Ni/dE);
pi = (Ni./dNi).^2;% weigth
xpiyi = sum(pi.*yi);
xpiEiyi = sum(pi.*Ei.*yi);
%
xpi = sum(pi);
xpiEi = sum(pi.*Ei);
xpiEi2 = sum(pi.*Ei.*Ei);
%
%	Determination of the least square fit for each energy spectrum
%
for i =1:length(xpi),
	S = [xpi(i),xpiEi(i);xpiEi(i),xpiEi2(i)];
    Y = [xpiyi(i);xpiEiyi(i)];
	X = S\Y;
	E = sqrt([xpiEi2(i);xpi(i)]/det(S));
%
	Tph(i) = -1.0/X(2);
	eTph(i) = E(2)*Tph(i)*Tph(i);	
	A(i) = exp(X(1));
	eA(i) = A(i)*E(1);
%
%	goodness-of-fit of the data to the model (Q > 0.1 for the fit to be believable)
%
    chi2(i) = sum(((yi(:,i) - X(1) - X(2)*Ei(:,i))./pi(:,i)).^2);
	Q(i) = gammainc((sEi(1)-2)/2,chi2(i)/2);
%
	clear X Y S
end





