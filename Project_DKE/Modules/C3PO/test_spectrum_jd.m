% script test_varspectrum_jd
%
clear all,
close all,
%
npar0 = 1.8;
dnpar = 0.1;
dnpar0 = 0.5;
%
nnpar = 10001;
fnpar = sqrt(log(100));%3;%
%snpar = 2*log(2);%2;%
snpar = 4i;
%
opt = 2;
%
% ------------------
%
[nP0n,nnpar0] = varspectrum_jd(1,npar0,dnpar,dnpar0,snpar,fnpar,opt);
%
dnparb = sqrt(dnpar^2 + dnpar0^2);
%
nparmin = npar0 - fnpar*dnparb;
nparmax = npar0 + fnpar*dnparb;
%
nn = length(nP0n);
%
xnpar = linspace(nparmin,nparmax,nnpar);
dxnpar = xnpar(2) - xnpar(1);
%
xP = exp(-(xnpar - npar0).^2/dnpar^2)/sqrt(pi)/dnpar;
xf = exp(-(xnpar - npar0).^2/dnpar0^2)/sqrt(pi)/dnpar0;
xPb = exp(-(xnpar - npar0).^2/dnparb^2)/sqrt(pi)/dnparb;
%
xnnpar = repmat(xnpar.',[1,nn]);
xnnpar0 = repmat(nnpar0,[nnpar,1]);
xnP0n = repmat(nP0n,[nnpar,1]);
%
xnPn = xnP0n.*exp(-(xnnpar - xnnpar0).^2/dnpar^2)/sqrt(pi)/dnpar;
xPn = sum(xnPn,2);
%
SP0n = sum(nP0n);
IP = sum(dxnpar.*xP);
If = sum(dxnpar.*xf);
IPb = sum(dxnpar.*xPb);
IPn = sum(dxnpar.*xPn);
%
% ------------------
%
disp(['- sum on P0n : ',num2str(SP0n)]);
disp(['- integral on P : ',num2str(IP)]);
disp(['- integral on f : ',num2str(If)]);
disp(['- integral on Pb : ',num2str(IPb)]);
disp(['- integral on Pn : ',num2str(IPn)]);
%
style = '-';
marker = 'none';
color1 = 'b';
color2 = 'r';
color3 = 'g';
color4 = 'm';
color5 = 'k';
width0 = 0.5;
width = 2;
siz = 20 + 14i;
red = 0.9;
lspace = 0.5;
bspace = 0.7;
%
figure(1),clf
%
xlab = 'n_{||}';
ylab = '';
tit = '';
%
xlim = [nparmin,nparmax];
ylim = NaN;
%
leg = {'P(n_{||})','f(n_{||0})','<P(n_{||})>','Sum[ P_n(n_{||}) ]'};
%
graph1D_jd(xnpar,xP,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca);
graph1D_jd(xnpar,xf,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width,siz,gca);
graph1D_jd(xnpar,xPb,0,0,'','','',NaN,xlim,ylim,style,marker,color3,width,siz,gca);
graph1D_jd(xnpar,xPn,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color4,width,siz,gca,red,lspace,bspace);
for in = 1:nn,
    graph1D_jd(xnpar,xnPn(:,in),0,0,'','','',NaN,xlim,ylim,style,marker,color5,width0,siz,gca);
end




