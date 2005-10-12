function Z = Zplasma(x,N);
%
% Plasma dispersion function
%
if imag(x) ~= 0,
    error('Not yet implemented for complex arguments')
end
%
if nargin < 2
    N = 100;
end
%
if x < 0,
    s = -1;
    x = -x;
else
    s = 1;
end
%
dt = x/N;
t = dt/2:dt:x;
%
f = -2*exp(t.^2 - x^2);
%
Z = s*sum(f*dt) + i*sqrt(pi)*exp(-x^2);
%
