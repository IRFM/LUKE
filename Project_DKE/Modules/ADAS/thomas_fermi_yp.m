function [phi,phi1a,phi1b,phi2,phi3,x] = thomas_fermi_yp
%
%   Normalized Thomas-Fermi potential and its approximate expressions.
%
%	Input: 
%
%		- xmax: upper limit of the radial grid (normalized to Thomas-Fermi length) [1,1]
%        (default = 20)
%
%	Output: 
%
%       - phi: Normalized Thomas-Fermi potential (numerical solution) 
%		- phi1a: Baker solution near nucleus, from ref. from ref. S. Lundqvist and N. H. March (1983) [1,n]
%		- phi1b: Baker solution near nucleus from Baker original paper [1,n]
%		- phi2: Coulson and March model far from the nucleus [1,n]
%		- phi3: Sommerfeld-Dirac solution [1,n]
%		- x: radius normalized to the Thomas-Fermi characteristic length [1,n]
%
% by Y.Peysson CEA-DRFC <yves.peysson@cea.fr>
%
if nargin == 0
    %
    xmax = 6;
    %
end
%
close all
%
nr = 10000;
%
x = linspace(0.1,xmax,nr);
%
[s0,B,err,s,y,exitflag] = tf_potential_yp(0,xmax);
phi = y(:,1);
%
B = -1.588071;%value matching assympotic expansion (Majorana value for neutral atoms)
%B = -1.6;%value matching assympotic expansion
%B = -1.8;%value matching assympotic expansion
phi1a = 1 + B*x + 4/3*x.^(3/2) ...
    + 2/5*B*x.^(5/2) + (1/3)*x.^3 + ((3/70)*B^2)*x.^(7/2)...
    + ((2/15)*B)*x.^(8/2) + (2/27 + (1/252)*B^3)*x.^(9/2);%...
    + ((B^2)/175)*x.^(10/2) + ((31/1485)*B + (B^4)/1056)*x.^(11/2);%Baker's model from ref. S. Lundqvist and N. H. March (1983). Coefficient of x.^(9/2) is different in original Baker's paper 
%
phi1b = 1 + B*x + 4/3*x.^(3/2) ...
    + 2/5*B*x.^(5/2) + (1/3)*x.^3 + ((3/70)*B^2)*x.^(7/2)...
    + ((2/15)*B)*x.^(8/2) + (4/63)*(2/3 + B^3/16)*x.^(9/2);%Baker's model from ref. S. Lundqvist and N. H. March (1983). Coefficient of x.^(9/2) is different in original Baker's paper 
%
c = (sqrt(73)-7)/2;
F1 = 13.271;
F2 = 0.62570*F1^2;
F3 = 0.31339*F1^3;
F4 = 0.13739*F1^4;
F5 = 0.05508*F1^5;
F6 = 0.02071*F1^6;
F7 = 0.00741*F1^7;
F8 = 0.00256*F1^8;
F9 = 0.00085*F1^9;
F10 = 0.00028*F1^10;
%
phi2 = 144*(1 - F1./(x.^c) + F2./(x.^(2*c)) - F3./(x.^(3*c))...
       + F4./(x.^(4*c)) - F5./(x.^(5*c)) + F6./(x.^(6*c))...
       - F7./(x.^(7*c)) + F8./(x.^(8*c)) - F9./(x.^(9*c))...
       + F10./(x.^(10*c)))./x.^3;%Coulson and March model
%
a = 12^(2/3);
d = (sqrt(73)-7)/2;
c = -3.886;
phi3 = (1 + (x/a).^d).^c;%Sommerfeld model
%
xlab = '\chi_{s}';
ylab = 'Thomas-Fermi potential \phi';
tit = 'Thomas-Fermi model for neutral atom (q_{0s} = 0)';
leg = {'Exact numerical solution','Backer (ref. lun83)','Backer (ref. bak30)','Coulson and March','Sommerfeld-Dirac'};
siz = 20+14i;
%
xlim = [0,max(max(x))];
ylim = [1e-3,1];
%
ix = find(x < 3);
%
figure('Name',tit),clf
graph1D_jd(s.*s,phi,0,0,xlab,ylab,tit,'',xlim,ylim,'-','none','k',2,siz,gca);
graph1D_jd(x(ix),phi1a(ix),0,0,xlab,ylab,tit,'',xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(x(ix),phi1b(ix),0,0,xlab,ylab,tit,'',xlim,ylim,'-.','none','r',2,siz,gca);
graph1D_jd(x,phi2,0,0,xlab,ylab,tit,'',xlim,ylim,':','none','b',2,siz,gca);
graph1D_jd(x,phi3,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','g',2,siz,gca);
%
drawnow;
print_jd(2,'Thomas_Fermi_model_and_approximations','./Figs',get(gcf,'Number'));



    
 
