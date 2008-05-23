% script test_hottensor_jd
%
clear all
close all
%
var = 'beta';
%
base.a = 0.1;
base.y = 0.55;
base.beta = 0.1;
base.Npar = 0.3;
%
nx = 11;
%
list.a = linspace(0,1,nx);
list.y = linspace(0,1,nx);
list.beta = [5e-3,linspace(0.1/(nx-1),0.1,(nx-1))];
list.Npar = linspace(0,1,nx);
%
zZi = [1,1,1];
zmi = [1,2,3];
zfi = [0,1,0];
%
[qe,me,mp] = pc_dke_yp;
%
x = list.(var);
%
Nperpp = zeros(1,nx);
Nperpm = zeros(1,nx);
X_cold = zeros(3,3,nx);
X_hotp = zeros(3,3,nx);
X_hotm = zeros(3,3,nx);
dXdNpar_hotp = zeros(3,3,nx);
dXdNpar_hotm = zeros(3,3,nx);
dXdNperp_hotp = zeros(3,3,nx);
dXdNperp_hotm = zeros(3,3,nx);
%
for ix = 1:nx,
    %
    calc = base;
    calc.(var) = x(ix);
    %
    calc.sa = calc.a*[1;(zZi.^2.*zfi./zmi/(mp/me)).'];
    calc.sy = calc.y*[-1;(zZi./zmi/(mp/me)).'];
    calc.sbeta = calc.beta*[1;([1,1,1]).'];
    %
    [Nperpp(ix),Nperpm(ix),Kxyz] = coldtensor_jd(calc.sa,calc.sy,calc.Npar);
    %
    X_cold(:,:,ix) = Kxyz - eye(3);
    %
    [X_hotp(:,:,ix),dXdNpar_hotp(:,:,ix),dXdNperp_hotp(:,:,ix)] = hottensor_jd(calc.sa,calc.sy,calc.sbeta,calc.Npar,Nperpp(ix),1);
    [X_hotm(:,:,ix),dXdNpar_hotm(:,:,ix),dXdNperp_hotm(:,:,ix)] = hottensor_jd(calc.sa,calc.sy,calc.sbeta,calc.Npar,Nperpm(ix),1);
    %
end
    
    
    
    
    
    
    
    
    
    
