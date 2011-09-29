function [y] = randg_yp(n,av,hwhm,test)
%
% White gaussian noise generator, with given mean and HWHM values.
%
%   INPUTS: 
%
%       - n: number of trials [1,n]
%       (default = 100000)
%       - av: average value [m,1]
%       (default = 0)
%       - hwhm: halfwidth at half maximum value [m,1]
%       (default = 0.5)
%       - test: display the distribution is > 0 [1,1]
%       (default = 0)
%
%
%   OUTPUTS: [qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB]
%   
%   - y: White gaussian noise [1,n]

%   - kB : Boltzmann's constant (J/K-1)
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
if nargin == 0, 
    n = 100000;
    av = 0;
    hwhm = 0.5;
    test = 1;
end
%
if nargin == 1, 
    av = 0;
    hwhm = 0.5;
    test = 0;
end
%
if nargin == 2, 
    hwhm = 0.5;
    test = 0;
end
%
if nargin == 3, 
    test = 0;
end
%
hwhm = hwhm(:);
av = av(:);
if size(av) ~= size(hwhm), error('Inconsistent size of av and hwhm in randg_yp.m');end
%
Xhwhm = repmat(hwhm,[1,n]);
Xav = repmat(av,[1,n]);
%
y = sqrt(-2*log(rand(size(Xav,1),n))).*cos(2*pi*rand(size(Xav,1),n)).*Xhwhm/sqrt(2*log(2)) + Xav;
%
if test,
    [z,x] = hist(y,100);
    figure(1),plot(x,z/max(z),'b',x,exp(-(x - av).^2/2/hwhm^2*2*log(2)),'r')
    hold off
end