function [xNperp] = disp_ebwES_jd(xB,xTe,xne,omega,guess_lambda,xguess_Nperp);
%
if nargin >= 6
    isNperp = 1;
else
    isNperp = 0;
end    
if nargin < 5
    guess_lambda = 10;
end
%    
N = 100;
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;
%
xwpe = sqrt(xne*qe^2/e0/me);
xwce = qe*xB/me;
xbetath = sqrt(xTe/mc2);
%
xabr = xwpe./xwce;
%
xq = omega./xwce;
%
if isNperp == 1
    xguess_lambda = (xguess_Nperp.*xq.*xbetath).^2;
else
    xguess_lambda = guess_lambda*ones(size(xB));
end
%
[lambda,Yval,Yflag] = inv_ebwES_jd(xq,N,xabr,xguess_lambda);
%
kprho = sqrt(lambda);
xNperp = kprho./xq./xbetath;
