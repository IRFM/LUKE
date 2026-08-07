% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
