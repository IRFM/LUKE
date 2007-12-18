function [xq,xqtilde,xqbar,xqhat,xqcronos] = qfactors_dke_yp(equil_mode,Rp,ap,Xx,Xy,XBx,XBy,XBphi,xx0,xB0,xBT0,xBp0);
%
% Calculation of the different q factors needed for solving the bounce averaged drift-kinetic-equation for
% arbitrary equilibrium (see the notice for explanations concerning notations)
%
%   INPUT:
%
%       - Plasma equilibrium parameters 
%
%   OUTPUT:
%   
%       - xq (safety factor) [1,nr]
%       - xqtilde [1,nr]
%       - xqbar [1,nr]
%       - xqhat [1,nr]
%       - xqcronos [1,nr]
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC) and Joan Decker <jodecker@alum.mit.edu> (MIT/RLE)  
%
if equil_mode == 1,
    Xx = Xx';
    Xy = Xy';
    XBx = XBx';
    XBy = XBy';
    XBphi = XBphi';
    %
    [nt,np] = size(Xx);
    %
    theta = linspace(0,2*pi,nt); % Angular grid
    Xtheta = repmat(theta',[1,np]);
    %
    XBT = abs(XBphi); % Toroidal B-field
    XBP = sqrt(XBx.^2 + XBy.^2); % Poloidal B-field
    XB = sqrt(XBT.^2 + XBP.^2); % Total B-field
    %
    % Half grid in theta for integration
    %
    XMBx = (XBx(1:nt-1,:) + XBx(2:nt,:))/2;
    XMBy = (XBy(1:nt-1,:) + XBy(2:nt,:))/2;
    XMBphi = (XBphi(1:nt-1,:) + XBphi(2:nt,:))/2;
    XMB = sqrt(XMBx.^2 + XMBy.^2 + XMBphi.^2);
    XMBmin = ones(nt-1,1)*min(XMB);
    %
    XMx = (Xx(1:nt-1,:) + Xx(2:nt,:))/2;
    XMy = (Xy(1:nt-1,:) + Xy(2:nt,:))/2;
    %
    nm = nt - 1;
    %
    XMdt = diff(Xtheta);
    %
    XMr2 = XMx.^2 + XMy.^2;
    XMrBpcos = abs(XMBx.*XMy - XMBy.*XMx);
    %
    %q (safety factor)
    %
    XMF = abs(XMBphi).*XMr2./XMrBpcos./(1 + XMx/Rp)/ap;
    xq = squeeze(sum(XMF.*XMdt))/(2*pi);
    %
    %qtilde
    %
    XMF = XMB.*XMr2./XMrBpcos./ap;
    xqtilde = squeeze(sum(XMF.*XMdt))/(2*pi);
    %
    %qbar
    %
    XMF = XMBmin.*XMr2./XMrBpcos./(1 + XMx/Rp)/ap;
    xqbar = squeeze(sum(XMF.*XMdt))/(2*pi);
    %
    %qhat 
    %
    XMF = XMBmin.*XMr2./XMrBpcos./ap;
    xqhat = squeeze(sum(XMF.*XMdt))/(2*pi);
    %
    %qcronos
    %
    XMF = XMB.*XMB.*XMr2./XMrBpcos./XMBmin./ap;
    xqcronos = squeeze(sum(XMF.*XMdt))/(2*pi);
    %
else
    xrho = xx0/ap; %note: for the sake of bounce-averaged calculations in the
                          %      analytical limit of circ. conc.
                          %      flux-surfaces, we need theta0 = 0, thus
                          %      this definition of xrho. Of course, when
                          %      the configuration is circ. conc. ro start
                          %      with, the two definitions coincide.
    xia = xrho*ap/Rp;
    xq = xrho.*xBT0./xBp0./sqrt(1 - xia.^2);
    xqtilde = xrho.*xB0./xBp0;
    xqbar = xrho.*xB0./xBp0./(1 + xia);
    xqhat = xqbar;
    xqcronos = xrho.*xB0.*sqrt((1+xia)./(1-xia))./xBp0;
end
%
    
