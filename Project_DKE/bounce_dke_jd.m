function [xq,xqtilde,xqbar,xqhat,xymaskT,...
    xylambda_p0p0,xylambda_p2m1,xylambda_p2m2p2,xylambda_b_p1p1,xylambda_b_p1m1p2,xylambda_b_p1m1,xylambda_b_p1m2,xylambda_b_p2m2p2,xylambda_b_p3m2,xylambda_b_p2,xylambda_b_p1m3p4]...
= bounce_dke_jd(equil_mode,ymhu0,XR,XZ,XBR,XBZ,XBphi,xmhubounce2,xB0,xR0,xBT0,xBp0,Rp,Zp,ap,xymaskT_in,sign)
%
% calculates bounce averaging coefficients needed for solving the electron drift-kinetic-equation. 
%
%   INPUTS:
%
%       - ymhu0: pitch angle grid [1,nmhu]
%       - plasma magnetic equilibrium
%
%   OUTPUTS:
%   
%
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
if nargin < 16,
	sign = 0;
	xymaskT_in = NaN;
end
if nargin == 16,
	error('Inconsistent number of arguments');
end
if nargin < 15,
	error('Not enough arguments');
end
%
% Case of a numerical equilibrium
%
nmhu = length(ymhu0);
[nr,nt] = size(XR);
%
if equil_mode == 1,
	[YMdt,YMmask,YMF,YMPSIB,YMmhu0,YMmhu,YMR,xymaskT,nm2] = banana_dke_jd(ymhu0,Rp,Zp,XR,XZ,XBR,XBZ,XBphi);	
elseif equil_mode == 0,
	for ir = 1:nr   
		xymaskT(ir,:) = ymhu0.^2 < xmhubounce2(ir);		
	end
end			
%
if ~isnan(xymaskT_in),%for correct grid mask position 
	xymaskT = xymaskT_in;
	for ir = 1:size(xymaskT_in,1),
		xjmhut_min(ir) = min(find(xymaskT_in(ir,:) == 1));
		xjmhut_max(ir) = max(find(xymaskT_in(ir,:) == 1));
	end
	if sign == 1,xymaskT(:,xjmhut_min-1) = xymaskT_in(:,xjmhut_min);end
	if sign == -1,xymaskT(:,xjmhut_max+1) = xymaskT_in(:,xjmhut_max);end
end
%
if equil_mode == 1
%
    [xq,xqtilde,xqbar,xqhat] = qfactors_dke_yp(Rp,Zp,XR,XZ,XBR,XBZ,XBphi);%q factors calculations
    xyqtilde = repmat(xqtilde',[1,nmhu]);
%
    YMR0 = repmat(xR0,[nm2,1,nmhu]);
%
    Yweight_p0p0 = (YMmhu./YMmhu0).^(0).*YMPSIB.^(0);
    xylambda_p0p0 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p0p0)/(2*pi),[nr,nmhu])./xyqtilde;
%
%For flux surface averaged Ohmic electric field
%
    Yweight_p1m3p4 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-3).*(YMR0./YMR).^(4);
    xylambda_p1m3p4 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m3p4)/(2*pi),[nr,nmhu])./xyqtilde;
    xylambda_b_p1m3p4 = ~xymaskT.*xylambda_p1m3p4;
%
%Fokker-Planck weights
%
    Yweight_p2m1 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-1);
    xylambda_p2m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m1)/(2*pi),[nr,nmhu])./xyqtilde;
%
    Yweight_p1p1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(1);
    xylambda_p1p1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1p1)/(2*pi),[nr,nmhu])./xyqtilde;
    xylambda_b_p1p1 = ~xymaskT.*xylambda_p1p1;
%
    Yweight_p1m1p2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1).*(YMR0./YMR).^(2);
    xylambda_p1m1p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1p2)/(2*pi),[nr,nmhu])./xyqtilde;
    xylambda_b_p1m1p2 = ~xymaskT.*xylambda_p1m1p2;%Equivalent form: xq.*xRmin.*xB0./xqtilde/R0./xBTmin                                              
%
%Drift kinetic weights
%
    Yweight_p1m1 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-1);
    xylambda_p1m1 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m1)/(2*pi),[nr,nmhu])./xyqtilde;
    xylambda_b_p1m1 = ~xymaskT.*xylambda_p1m1;
%
    Yweight_p1m2 = (YMmhu./YMmhu0).^(1).*YMPSIB.^(-2);
    xylambda_p1m2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p1m2)/(2*pi),[nr,nmhu])./xyqtilde;
    xylambda_b_p1m2 = ~xymaskT.*xylambda_p1m2;%In old notation: 1-delta/mhu0^2
%
    Yweight_p2m2p2 = (YMmhu./YMmhu0).^(2).*YMPSIB.^(-2).*(YMR0./YMR).^(2);    
    xylambda_p2m2p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2m2p2)/(2*pi),[nr,nmhu])./xyqtilde;%************probl?me sur le courant en mode numŽrique (grille uniforme ou non)
    xylambda_b_p2m2p2 = ~xymaskT.*xylambda_p2m2p2;
%
    Yweight_p3m2 = (YMmhu./YMmhu0).^(3).*YMPSIB.^(-2);
    xylambda_p3m2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p3m2)/(2*pi),[nr,nmhu])./xyqtilde;
    xylambda_b_p3m2 = ~xymaskT.*xylambda_p3m2;
%
    Yweight_p2 = (YMmhu./YMmhu0).^(2);
    xylambda_p2 = reshape(sum(YMmask.*YMdt.*YMF.*Yweight_p2)/(2*pi),[nr,nmhu])./xyqtilde;%In old notation: s*_tilde
    xylambda_b_p2 = ~xymaskT.*xylambda_p2;
%
    ymask = find(ymhu0 == 0);
    if ~isempty(ymask),
    	xylambda_p0p0(:,ymask) = eps;
    	xylambda_p2m1(:,ymask) = eps;
    	xylambda_b_p1p1(:,ymask) = eps;
    	xylambda_b_p1m1p2(:,ymask) = eps;
%
    	xylambda_b_p1m1(:,ymask) = eps;
    	xylambda_b_p1m2(:,ymask) = eps;
    	xylambda_b_p2m2p2(:,ymask) = eps;
    	xylambda_b_p3m2(:,ymask) = eps;
    	xylambda_b_p2(:,ymask) = eps;
    end
else,%Ideal equilibrium with circular concentric flux-surfaces.
    m = 30;
    xrho = (xR0 - Rp)/ap; %note: for the sake of bounce-averaged calculations in the
                          %      analytical limit of circ. conc.
                          %      flux-surfaces, we need theta0 = 0, thus
                          %      this definition of xrho. Of course, when
                          %      the configuration is circ. conc. ro start
                          %      with, the two definitions coincide.
    xia = xrho*ap/Rp;
%    
    xq = xia.*xBT0./xBp0./sqrt(1 - xia.^2);
    xqtilde = xia.*xB0./xBp0;
    xqbar = xia.*xB0./xBp0./(1 + xia);
    xqhat = xqbar;
%
    ymhu0(find(ymhu0==0)) = eps;%Avoid numerical singularities
    ymhu2 = ymhu0.^2;
%
    for ir = 1:nr 
        YJ = jseries_dke_jd(sqrt(xmhubounce2(ir)),ymhu0,m); 
%   
        chim = zeros(m+1,1);
        chim_tp = zeros(m+1,1);
        mhutrap2m = zeros(m+1,1);
        chim(1) = 1;
        chim_tp(1) = 1;
        mhutrap2m(1) = 1;
        for i = 1:m,
        	chim(i+1) = (2*i - 3)/(2*i)*chim(i);
        	chim_tp(i+1) = (2*i - 1)/(2*i)*chim_tp(i);
        	mhutrap2m(i+1) = xmhubounce2(ir)*mhutrap2m(i);
        end
%
        Ymchim = chim*ones(1,nmhu);
        Ymchim_tp = chim_tp*ones(1,nmhu);
        Ymmhutrap2m = mhutrap2m*ones(1,nmhu);
        Ymmhu2 = ones(m-1,1)*ymhu2;
        Ymhu2 = ones(m,1)*ymhu2;
        Ymhu2(Ymhu2==0) = eps;
        Ymmhu2(Ymmhu2==0) = eps;
%    
        ysstar = 1/sqrt(1- xmhubounce2(ir)).*ones(1,nmhu);
        ylambda = 2/pi*sum(Ymchim(1:m,:).*Ymmhutrap2m(1:m,:).*YJ(1:m,:));
        ylambda(ylambda==0) = eps;
        ydeltalambda = 2/pi*sum(Ymchim(1:m,:).*Ymmhutrap2m(2:m+1,:).*YJ(2:m+1,:));
        ysstar_tp = 2/pi*sum((Ymchim(1:m,:) - Ymchim_tp(1:m,:).*(1-Ymhu2)).*Ymmhutrap2m(1:m,:)./Ymhu2.*YJ(1:m,:));
%        
        if m > 2,
        	ylambda_tp = 2/pi*(YJ(1,:) + sum((Ymchim(2:m,:) - Ymchim(1:m-1,:)./Ymmhu2).*Ymmhutrap2m(2:m,:).*YJ(2:m,:)) - Ymchim(m,:)./ymhu2.*Ymmhutrap2m(m+1,:).*YJ(m+1,:));
        elseif m == 2,
        	ylambda_tp = 2/pi*(YJ(1,:) + (Ymchim(2,:) - Ymchim(1,:)./Ymmhu2).*Ymmhutrap2m(2,:).*YJ(2,:) - Ymchim(2,:)./ymhu2.*Ymmhutrap2m(3,:).*YJ(3,:));
        end
%
        xylambda_p0p0(ir,:) = ylambda;
        xylambda_p2m1(ir,:) = ylambda - ydeltalambda./ymhu2;
        xylambda_p2m2p2(ir,:) = ysstar_tp;
        xylambda_b_p1p1(ir,:) = ~xymaskT(ir,:).*ysstar;
        xylambda_b_p1m1(ir,:) = ~xymaskT(ir,:)/(1 + xia(ir));
        xylambda_b_p1m2(ir,:) = ~xymaskT(ir,:)*(1 + xia(ir)^2/2)/(1 + xia(ir)).^2;
        xylambda_b_p3m2(ir,:) = ~xymaskT(ir,:).*(ymhu2 - xia(ir)*(1 - xia(ir)/2)/(1 + xia(ir)))/(1 + xia(ir))./ymhu2; 
    end
    xylambda_b_p2m2p2 = ~xymaskT.*xylambda_p2m2p2;
    xylambda_b_p2 = xylambda_b_p2m2p2;
    xylambda_b_p1m1p2 = xylambda_b_p1p1;
    xylambda_b_p1m3p4 = xylambda_b_p1p1;
 end      
  