function [xNperp] = disp_ebwES_jd(xB,xTe,xne,omega);
%
N = 100;
xguess = ones(size(xB));
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;
%
xwpe = sqrt(xne*qe^2/e0/me);
xwce = qe*xB/me;
xbetath = sqrt(xTe/mc2);
%
xabr = xwpe./xwce;
%
xq = omega/xwce;
%
[lambda,Yval,Yflag] = inv_ebwES_jd(xq,N,xabr,xguess);
%
kprho = sqrt(lambda);
xNperp = kprho./xq./xbetath;
