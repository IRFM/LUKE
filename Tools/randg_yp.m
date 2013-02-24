function [y] = randg_yp(n,av,fwhm,display_mode)
%
% White gaussian noise generator, with given mean and FWHM values.
%
%   INPUTS: 
%
%       - n: number of trials [1,n]
%       (default = 100000)
%       - av: average value [m,1]
%       (default = 0)
%       - fwhm: fullwidth at half maximum value [m,1]
%       (default = 0.5)
%       - display_mode: display the distribution is > 0 and is the number of bin of the histogram  [1,1]
%       (default = 0)
%
%
%   OUTPUTS: [qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB]
%   
%   - y: white gaussian noise [1,n]
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA/DSM/IRFM) and Joan Decker <joan.decker@cea.fr> (CEA/DSM/IRFM)
%
if nargin == 0, 
    n = 100000;
    av = 0;
    fwhm = 0.5;
    display_mode = 1;
end
%
if nargin == 1, 
    av = 0;
    fwhm = 0.5;
    display_mode = 0;
end
%
if nargin == 2, 
    fwhm = 0.5;
    display_mode = 0;
end
%
if nargin == 3, 
    display_mode = 0;
end
%
fwhm = fwhm(:);
av = av(:);
if size(av) ~= size(fwhm), error('Inconsistent size of av and hwhm in randg_yp.m');end
%
sigma = fwhm/sqrt(2*log(2))/2;%standard deviation
Xsigma = repmat(sigma,[1,n]);
Xav = repmat(av,[1,n]);
%
y = sqrt(-2*log(rand(size(Xav,1),n))).*cos(2*pi*rand(size(Xav,1),n)).*Xsigma + Xav;
%
if display_mode,
    [z,x] = hist(y,display_mode);%display_mode is the number of bin for the histogram
    normz = sum(z)*(x(2)-x(1));
    figure(1),plot(x,z/normz,'b',x,exp(-(x - av).^2/2/sigma^2)/sqrt(2*pi)/sigma,'r');
    norm_th = sum(exp(-(x - av).^2/2/sigma^2))/sqrt(2*pi)/sigma*(x(2)-x(1));
    title('Gaussian white noise distribution function (normalized to 1)')
    xlabel('y');ylabel('f(y)')
    legend('Numerical','Theoretical')
    hold off
end