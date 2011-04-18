function plotchords_jd(equil,hxrspec,xvar,p_opt,c_opt,nr)
%
% This function plots the chords over the magnetic equilibrium
%
if nargin < 6,
    nr = 20;
end
%
if nargin < 5,
    c_opt = 0;
end
%
if nargin < 4,
    p_opt = -1;
end
%
if nargin < 3,
    xvar = 'g';
end
%
str = 'HXR chords';
method = 'spline';
%
figure(1),clf,set(1,'Name',str)
%   
rho = linspace(0,1,nr + 1);
%
if strcmp(xvar,'p'),
    prho = sqrt(equil.psi_apRp/equil.psi_apRp(end));
elseif strcmp(xvar,'g'),
    prho = equil.ptx(:,1)./ equil.ptx(end,1);
else
    error('Other rho not yet implemented')
end
%  
ptx = interp1(prho,equil.ptx,rho,method);
pty = interp1(prho,equil.pty,rho,method);
%
tpR = ptx.' + equil.Rp;
tpZ = pty.' + equil.Zp;
%
xlim = NaN;
ylim = NaN;
%
graph1D_jd(tpR,tpZ,0,0,'R(m)','Z(m)',str,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.5);
axis('equal');
%
if isstruct(hxrspec),
    %
    nc = length(hxrspec.beta_hxr);
    nL = 1000;
    %
    Lmax = 1.1*max(abs(tpZ(:,end) - hxrspec.Z_hxr(1)));
    %
    if c_opt == 0,%plot chord within plasma
        Lmin = -0.9*min(abs(tpZ(:,end) - hxrspec.Z_hxr(1)));
    else% plot entire chord
        Lmin = Lmax/10;
    end
    L = linspace(-Lmax,Lmin,nL).';%Chord length
    %
    R = zeros(nL,nc);
    Z = zeros(nL,nc);
    %    
    cstr = repmat(['#',repmat(' ',[1,length(num2str(nc))])],[nc,1]);
    %
    for ic = 1:nc,
        R(:,ic) = hxrspec.R_hxr(ic) + L*sin(hxrspec.beta_hxr(ic))*cos(hxrspec.alpha_hxr(ic));
        Z(:,ic) = hxrspec.Z_hxr(ic) + L*cos(hxrspec.beta_hxr(ic));
        cstr(ic,2:2+length(num2str(ic))-1) = num2str(ic);
    end
    %
    graph1D_jd(R,Z,0,0,'','','',NaN,xlim,ylim,'-','none','b',0.5);
    %        
    text(R(1,:),Z(1,:),cstr);
    %
    xmin = min([min(min(tpR)),min(min(R))])*0.9;
    xmax = max([max(max(tpR)),max(max(R))])*1.1;
    %
    ymin = min([min(min(tpZ)),min(min(Z))])*0.9;
    ymax = max([max(max(tpZ)),max(max(Z))])*1.1;
    %
    axis('equal');axis([xmin,xmax,ymin,ymax]);
    set(gca,'xtickmode','auto')
    set(gca,'ytickmode','auto')
end
%
print_jd(p_opt,['Fig_HXR_chords_',equil.id]);
%


