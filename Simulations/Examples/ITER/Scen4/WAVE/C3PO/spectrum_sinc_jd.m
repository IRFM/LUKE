function [dNpar0] = spectrum_sinc_jd(Npar0,width)
%
nx = 1001;
xfac = 10;
%
npar = linspace(Npar0 - xfac*width,Npar0 + xfac*width,nx);
x = 2*pi*(npar - Npar0)/(2*width);
Plh_norm = sin(x).^2./x.^2;
%
ipeak = 501;
iw = min(find(Plh_norm > exp(-1)));
dNpar0 = abs(npar(ipeak) - npar(iw));
%
