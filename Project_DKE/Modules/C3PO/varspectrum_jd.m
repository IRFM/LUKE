function [nP0n,nnpar0,bdnpar] = varspectrum_jd(P0,npar0,dnpar,dnpar0,snpar,fnpar,opt)
%
% This function discretizes the spectrum characterized by the base
% Gaussian spectrum (npar0, dnpar, P0) and a Gaussian npar distribution
% characterized by dnpar0
%
% by J. Decker and Y. Peysson
%
%
if nargin < 7,
    opt = 1;
end
%
if nargin < 6,
    fnpar = sqrt(log(100));
end
%
if nargin < 5,
    snpar = 2*log(2);
end
%
if nargin < 4,
    dnpar0 = 0.0;
end
%
dnparb = sqrt(dnpar^2 + dnpar0^2);
%
if real(snpar) > 0,% snpar*dnpar is the separation between rays
    %
    %nparmin = npar0 - fnpar*dnparb;
    nparmax = npar0 + fnpar*dnparb;
    %
    %nmin = fix((npar0 - nparmin)/snpar/dnpar);
    nmax = fix((nparmax - npar0)/snpar/dnpar);
    %
else % imag(snpar) is the number of rays
    %
    nparmax = npar0 + fnpar*dnpar0;
    %
    nmax = imag(snpar);
    snpar = (nparmax - npar0)/(nmax + 1/2)/dnpar;
    %
end
%
n = -nmax:nmax;%-nmin:nmax;
nn = length(n);
%
nnpar0 = npar0 + snpar*n*dnpar;
%
if opt == 0,
    %
    nnpar_S = [-Inf,(nnpar0(1:nn-1) + nnpar0(2:nn))/2,Inf];
    nnparb_S = (nnpar_S - npar0)/dnparb;
    nP0n = (erf(nnparb_S(2:end)) - erf(nnparb_S(1:end-1)))/2;
    %
elseif opt == 1,
    %
    Xhnpar0 = repmat(nnpar0,[nn,1]);
    Xvnpar0 = repmat(nnpar0.',[1,nn]);
    XPn = exp(-(Xhnpar0 - Xvnpar0).^2/dnpar^2)/sqrt(pi)/dnpar;
    nPb = exp(-(nnpar0.' - npar0).^2/dnparb^2)/sqrt(pi)/dnparb;
    nP0n = (XPn\nPb).';
    %
    SP0n = sum(nP0n);
    disp(['- sum on P0n from inversion : ',num2str(SP0n)]);
    nP0n = nP0n/SP0n;
    %
elseif opt == 2,
    %
    nP0n = exp(-(nnpar0 - npar0).^2/dnpar0^2)/sqrt(pi)/dnpar0;
    %
    SP0n = sum(nP0n);
    nP0n = nP0n/SP0n;
    %
end
%
nP0n = nP0n*P0;
bdnpar = repmat(dnpar,[1,nn]);
%
