function [Ytheta1,Ytheta2,YF1,YF2] = interp_theta_jd(theta,XBx,XBy,XBz,YBb,XF)
%
% This function calculates the positions Ytheta1 and Ytheta2 located respectively between two grid 
% positions Xtheta(i1a) and Xtheta(i1b) for Ytheta1, and Xtheta(i2a) and Xtheta(i2b) for Ytheta2,
% obtained by interpolation with the condition B(theta) = YBb, meaning such that, for j=1,2 :
%
% - XBx(ija)*alpha + XBx(ijb)*(1-alpha) := Bxj
% - XBy(ija)*alpha + XBy(ijb)*(1-alpha) := Byj
% - XBz(ija)*alpha + XBz(ijb)*(1-alpha) := Bzj
% - sqrt(Bxj^2 + Byj^2 + Bzj^2) := Bj = YBb
%
% This function is restricted to the case where XB=sqrt(XBx^2 + XBy^2 + XBz^2) has only one maximum 
% and one minimum, such that the equation B(theta) = YBb has either 2 solutions or none.
% The function also interpolates the data XF at the theta location  
%
%   INPUT :
%
%       - theta : poloidal grid [1,nt]. Must be periodic with Xtheta(nt) = Xtheta(1)
%       - XBx : x component of the magnetic field [nt,np]. Must be periodic with XBx(nt,:) = XBx(1,:)
%       - XBy : y component of the magnetic field [nt,np]. Must be periodic with XBy(nt,:) = XBy(1,:)
%       - XBz : z component of the magnetic field [nt,np]. Must be periodic with XBz(nt,:) = XBz(1,:)
%       - YBb : magnetic field amplitude at position theta [np,nb].
%       - XF : data to be interpolated (optional) [nt,np,nf,...].
%
%   OUTPUT :
%
%       - Ytheta1 : interpolated position, solution 1 [np,nb]. Ytheta1[ip,iY] = NaN if there no solution.
%       - Ytheta2 : interpolated position, solution 2 [np,nb]. Ytheta2[ip,iY] = NaN if there no solution.
%       - XF : data interpolated at theta = theta1 (optional) [np,nb,nf,...].
%       - XF : data interpolated at theta = theta2 (optional) [np,nb,nf,...].
%
% by J. Decker (joan.decker@cea.fr) and Y. Peysson (yves.peysson@cea.fr)
%
%
if nargin < 5,
    error('Not enough input arguments');
end
%
theta = theta(:);
nt = length(theta);
if nt < 3,
    error('The number of theta points must be at least 3');
end
%
sBx = size(XBx);
sBy = size(XBy);
sBz = size(XBz);
sBb = size(YBb);
%
if length(sBx) ~= 2 | sBx(1) ~= nt,
    error('Input variables dimensions mismatch');
else
    np = sBx(2);
end
%
if length(sBy) ~= 2 | length(sBz) ~= 2 | sBy ~= sBx | sBz ~= sBx | sBb(1) ~= np,
    error('Input variables dimensions mismatch');
end
%
nb = size(YBb,2);
%
if nargin < 6,
    XF = zeros(np,nb,0);
end
%
sF = size(XF); 
if sF(1) ~= nt | sF(2) ~= np,
    error('Input variables dimensions mismatch');
end
%
% ----------------------------------------------------------------
%
XB = sqrt(XBx.^2 + XBy.^2 + XBz.^2);
%
% calculation of the number of extrema of B
%
pnextr = sum(diff(sign(diff(XB([1:nt,2],:),1,1)),1,1) ~= 0,1);
if pnextr ~= 2*ones(1,np),
    error('The magnetic field must have one minimum and one maximum only');
end
%
% for each p point, the theta grid is temporarily shifted such that the minimum of B field
% is located at i=1 (and also i=nt);
%
pBmin = (XB(1:nt-1,:) == repmat(min(XB,[],1),[nt-1,1]));
pBmax = (XB(1:nt-1,:) == repmat(max(XB,[],1),[nt-1,1]));
%
if sum(pBmin,1) ~= ones(1,np),
    error('The magnetic field must have one minimum only');
end
if sum(pBmax,1) ~= ones(1,np),
    error('The magnetic field must have one maximum only');
end
%    
XCS = cumsum(ones(nt-1,np),1);
%
pit_Bmin = sum(pBmin.*XCS);
pit_Bmax = sum(pBmax.*XCS);
%
% construction of the matrix of indices
%
Xit_Bmin = XCS + repmat(pit_Bmin,[nt-1,1]) - 1;
Xit_Bmin(Xit_Bmin > nt-1) = Xit_Bmin(Xit_Bmin > nt-1) - (nt-1);
%
Xit_Bmin = Xit_Bmin + nt*(cumsum(ones(nt-1,np),2)-1);
%
% permutation of the magnetic field matrices
%
XBx = XBx(Xit_Bmin);XBx = [XBx;XBx(1,:)];
XBy = XBy(Xit_Bmin);XBy = [XBy;XBy(1,:)];
XBz = XBz(Xit_Bmin);XBz = [XBz;XBz(1,:)];
XB = XB(Xit_Bmin);XB = [XB;XB(1,:)];
%
XbBb = repmat(reshape(YBb,[1,np,nb]),[nt,1,1]);
XbB = repmat(XB,[1,1,nb]);
%
XbBb = reshape(XbBb,[nt,np*nb]);
XbB = reshape(XbB,[nt,np*nb]);
%
Ymask = XbB(1,:) <= XbBb(1,:) & sum(XbB > XbBb,1) > 0;
Ymask1 = max(XbB,[],1) == XbBb(1,:);% particular case where B(theta) = max(XB)
%
XbCS = cumsum(ones(nt,np*nb));
%
Xbimax = (XbB > XbBb).*XbCS;
YBb = XbBb(1,Ymask);
nY = length(YBb);
%
% clear XbBb XbB XbCS
%
Xbimax(Xbimax == 0) = NaN;
%
Yi1max = min(Xbimax,[],1);
Yi1min = Yi1max - 1;
Yi2min = max(Xbimax,[],1);
Yi2max = Yi2min + 1;
%
% clear Xbimax
%
%
%xytheta1min =  theta(xyi1min);
%xytheta1max =  theta(xyi1max);
%xytheta2min =  theta(xyi2min);
%xytheta2max =  theta(xyi2max);
%
Yipshift = nt*(repmat((1:np),[1,nb])-1);
%
YiX1min = Yi1min(Ymask) + Yipshift(Ymask);
YiX1max = Yi1max(Ymask) + Yipshift(Ymask);
YiX2min = Yi2min(Ymask) + Yipshift(Ymask);
YiX2max = Yi2max(Ymask) + Yipshift(Ymask);
%
YBx1min = reshape(XBx(YiX1min),[1,nY]);
YBx1max = reshape(XBx(YiX1max),[1,nY]);
YBx2min = reshape(XBx(YiX2min),[1,nY]);
YBx2max = reshape(XBx(YiX2max),[1,nY]);
%
YBy1min = reshape(XBy(YiX1min),[1,nY]);
YBy1max = reshape(XBy(YiX1max),[1,nY]);
YBy2min = reshape(XBy(YiX2min),[1,nY]);
YBy2max = reshape(XBy(YiX2max),[1,nY]);
%
YBz1min = reshape(XBz(YiX1min),[1,nY]);
YBz1max = reshape(XBz(YiX1max),[1,nY]);
YBz2min = reshape(XBz(YiX2min),[1,nY]);
YBz2max = reshape(XBz(YiX2max),[1,nY]);
%
YB1min = reshape(XB(YiX1min),[1,nY]);
YB1max = reshape(XB(YiX1max),[1,nY]);
YB2min = reshape(XB(YiX2min),[1,nY]);
YB2max = reshape(XB(YiX2max),[1,nY]);
%
Y1 = YBx1min.*YBx1max + YBy1min.*YBy1max + YBz1min.*YBz1max;
Y2 = YBx2min.*YBx2max + YBy2min.*YBy2max + YBz2min.*YBz2max;
%
Ydelta1 = sqrt((Y1 - YBb.^2).^2 - (YBb.^2 - YB1min.^2).*(YBb.^2 - YB1max.^2));
Ydelta2 = sqrt((Y2 - YBb.^2).^2 - (YBb.^2 - YB2min.^2).*(YBb.^2 - YB2max.^2));
%
Yalpha1a = ((YB1min.^2 - Y1) + Ydelta1)./(YB1min.^2 + YB1max.^2 - 2*Y1);
Yalpha1b = ((YB1min.^2 - Y1) - Ydelta1)./(YB1min.^2 + YB1max.^2 - 2*Y1);
%
Yalpha2a = ((YB2min.^2 - Y2) + Ydelta2)./(YB2min.^2 + YB2max.^2 - 2*Y2);
Yalpha2b = ((YB2min.^2 - Y2) - Ydelta2)./(YB2min.^2 + YB2max.^2 - 2*Y2);
%
tol = 1e-5;
%
Ymask1a = Yalpha1a >= -tol & Yalpha1a <= 1+tol;
Ymask1b = Yalpha1b >= -tol & Yalpha1b <= 1+tol;
Ymask2a = Yalpha2a >= -tol & Yalpha2a <= 1+tol;
Ymask2b = Yalpha2b >= -tol & Yalpha2b <= 1+tol;
%
if Ymask1a + Ymask1b ~= ones(1,length(Ymask1a)),
	error('root 1 not determined');
end
if Ymask2a + Ymask2b ~= ones(1,length(Ymask1a)),
	error('root 2 not determined');
end
%
Yalpha1 = (Ymask1a.*Yalpha1a + ~Ymask1a.*Yalpha1b);
Yalpha2 = (Ymask2a.*Yalpha2a + ~Ymask2a.*Yalpha2b);
%
Yit_Bmin = repmat(pit_Bmin,[1,nb]);
Yit_Bmax = repmat(pit_Bmax,[1,nb]);
%
Ytheta1 = NaN*ones(np,nb);
Ytheta2 = NaN*ones(np,nb);
Ytheta1(Ymask1) = theta(Yit_Bmax(Ymask1));
Ytheta2(Ymask1) = theta(Yit_Bmax(Ymask1));
%
Yi1min = Yi1min(Ymask) + Yit_Bmin(Ymask) - 1;
Yi1max = Yi1max(Ymask) + Yit_Bmin(Ymask) - 1;
Yi2min = Yi2min(Ymask) + Yit_Bmin(Ymask) - 1;
Yi2max = Yi2max(Ymask) + Yit_Bmin(Ymask) - 1;
%
Yi1min(Yi1min > nt - 1) = Yi1min(Yi1min > nt - 1) - (nt-1); 
Yi1max(Yi1max > nt - 1) = Yi1max(Yi1max > nt - 1) - (nt-1); 
Yi2min(Yi2min > nt - 1) = Yi2min(Yi2min > nt - 1) - (nt-1); 
Yi2max(Yi2max > nt - 1) = Yi2max(Yi2max > nt - 1) - (nt-1); 
%
Ytheta1(Ymask) = theta(Yi1min).'.*(1 - Yalpha1) + theta(Yi1max).'.*Yalpha1;
Ytheta2(Ymask) = theta(Yi2min).'.*(1 - Yalpha2) + theta(Yi2max).'.*Yalpha2;
%
if nargout > 2,
    %
    if length(sF) == 2,
        sF = [sF,1];
    end
    %
    sFp = prod(sF(3:end));
    %
    YF1 = NaN*ones(np*nb,sFp);
    YF2 = NaN*ones(np*nb,sFp);
    %
    XF = reshape(XF,[nt*np,sFp]);
    %
    YF1(Ymask1,:) = XF(Yit_Bmax(Ymask1) + Yipshift(Ymask1),:);
    YF2(Ymask1,:) = XF(Yit_Bmax(Ymask1) + Yipshift(Ymask1),:);
    %
    Yalpha1 = repmat(Yalpha1.',[1,sFp]);
    Yalpha2 = repmat(Yalpha2.',[1,sFp]);    
    %
    YF1(Ymask,:) = XF(Yi1min + Yipshift(Ymask),:).*(1 - Yalpha1) + XF(Yi1max + Yipshift(Ymask),:).*Yalpha1;
    YF2(Ymask,:) = XF(Yi2min + Yipshift(Ymask),:).*(1 - Yalpha2) + XF(Yi2max + Yipshift(Ymask),:).*Yalpha2;
    %
    YF1 = reshape(YF1,[np,nb,sFp]);
    YF2 = reshape(YF2,[np,nb,sFp]);    
    %
end




