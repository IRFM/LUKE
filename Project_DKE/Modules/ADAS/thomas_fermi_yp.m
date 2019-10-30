function [phi1,phi2,phi3,x] = thomas_fermi_yp(model,nr)
%
if nargin == 0, 
    model = 1;
    nr = 10000;
elseif nargin == 1,
    nr = 10000;
end
%
x = linspace(0.1,10,nr);
%
if model == 1
    B = -1.588071;%value matching assympotic expansion
    %B = -1.6;%value matching assympotic expansion
    %B = -1.8;%value matching assympotic expansion
    phi1 = 1 + B*x + 4/3*x.^(3/2) ...
        + 2/5*B*x.^(5/2) + (1/3)*x.^3 + ((3/70)*B^2)*x.^(7/2)...
        + ((2/15)*B)*x.^(8/2) + (4/63)*(2/3 + B^3/16)*x.^(9/2);%...
        + ((B^2)/175)*x.^(10/2) + ((31/1485)*B + (B^4)/1056)*x.^(11/2);%Baker's model
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
    figure,clf
    %
    xlab = 'x';
    ylab = '\phi';
    tit = 'Thomas-Fermi-Dirac model';
    leg = {'Backer','Coulson and March','Sommerfeld-Dirac'};
    siz = 20+14i;
    %
    xlim = [0,max(max(x))];
    ylim = [1e-3,1];
    %
    graph1D_jd(x,phi1,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca);
    graph1D_jd(x,phi2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd(x,phi3,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','g',2,siz,gca);
    %
elseif model == 2
    %
    
end

    
 
