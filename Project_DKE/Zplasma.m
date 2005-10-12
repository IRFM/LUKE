function [Z,Zp,Zpp] = Zplasma(x,N);
%
% Plasma dispersion function and derivatives
%
if imag(x) ~= 0,
    error('Not yet implemented for complex arguments')
end
%
if nargin < 2
    N = 10000;
end
%
xlim = 5;
gamma = 0.845;
%
n = 0:N;
%
sx = size(x);
ndim = length(sx);
%
signx = sign(x);
x = abs(x);
%
Xx = shiftdim(repmat(x,[ones(1,ndim),N]),ndim);
%
Xrho_S = shiftdim(repmat(x,[ones(1,ndim),N+1]),ndim)/xlim;
%
Xn_S = repmat(n',[1,sx]);
Xnt_S = N./(1 + (1 - gamma)*log((Xrho_S - gamma)/(1 - gamma)));  
%
Xt_S1 = xlim*Xrho_S.*Xn_S/N;
Xt_S2 = xlim*Xn_S./Xnt_S;
Xt_S3 = xlim*(gamma + (Xrho_S - gamma).*((1 - gamma)./(Xrho_S - gamma)).^((N - Xn_S)./(N - Xnt_S)));
%
Xmasklim_S = (Xrho_S <= 1);
Xmasknt_S = (Xn_S <= Xnt_S);
%
Xt_S = zeros([N+1,sx]);
Xt_S(Xmasklim_S) = Xt_S1(Xmasklim_S);
Xt_S(~Xmasklim_S & Xmasknt_S) = Xt_S2(~Xmasklim_S & Xmasknt_S);
Xt_S(~Xmasklim_S & ~Xmasknt_S) = Xt_S3(~Xmasklim_S & ~Xmasknt_S);
%
Xdt = diff(Xt_S);
str = ',:';
strtot = [];
for idim = 1:ndim,
    strtot = [strtot,str];
end
eval(['Xt = (Xt_S(1:N',strtot,') + Xt_S(2:N+1',strtot,'))/2;'])
%
Xf = Xt.*exp(-Xt.^2)./sqrt(Xx.^2 - Xt.^2);
%
Z = -2*signx.*shiftdim(sum(Xf.*Xdt,1),1) + i*sqrt(pi)*exp(-x.^2);
%
Xfp = Xt.*exp(-Xt.^2).*(Xx./sqrt(Xx.^2 - Xt.^2) - 1);
%
Zp = -2*(exp(-x.^2) - 2*shiftdim(sum(Xfp.*Xdt,1),1)) - 2*i*sqrt(pi)*signx.*x.*exp(-x.^2);
%
%
Xfpp = Xt.*exp(-Xt.^2).*(2*Xx + (Xt.^2 - 1)./Xx - (2*Xx.^2 - 1)./sqrt(Xx.^2 - Xt.^2));
%
Zpp = 4*signx.*(x.*exp(-x.^2) + shiftdim(sum(Xfpp.*Xdt,1),1)) - 2*i*sqrt(pi)*(1 + x.^2).*exp(-x.^2);
%
