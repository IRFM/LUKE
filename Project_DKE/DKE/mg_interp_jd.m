function [xyBb_rf,xyBPb_rf,xyrb_rf,xycosb_rf,xyxb_rf,xyyb_rf,xyBxb_rf,xyByb_rf,xyBphib_rf] = mg_interp_jd(theta,Xx,Xy,XBx,XBy,XBphi,xythetab_rf,method);
%
% This function interpolates the magnetic geometry data to given
% poloidal positions
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
if nargin < 8
    method = 'linear';
end
nr = size(Xx,1);
if size(xythetab_rf,1) == 1,
    xythetab_rf = repmat(xythetab_rf,[nr,1]);
end
for ir = 1:nr
    xyxb_rf(ir,:) = interp1(theta,Xx(ir,:),xythetab_rf(ir,:),method);
    xyyb_rf(ir,:) = interp1(theta,Xy(ir,:),xythetab_rf(ir,:),method);
%        
    xyBxb_rf(ir,:) = interp1(theta,XBx(ir,:),xythetab_rf(ir,:),method);
    xyByb_rf(ir,:) = interp1(theta,XBy(ir,:),xythetab_rf(ir,:),method);
    xyBphib_rf(ir,:) = interp1(theta,XBphi(ir,:),xythetab_rf(ir,:),method);
end
xyrb_rf = sqrt(xyxb_rf.^2 + xyyb_rf.^2);% minor radius at theta = thetab_rf
xyBPb_rf = sqrt(xyBxb_rf.^2 + xyByb_rf.^2);% poloidal magnetic field at theta = thetab_rf
xyBb_rf = sqrt(xyBPb_rf.^2 + xyBphib_rf.^2);% magnetic field at theta = thetab_rf
xycosb_rf = abs(xyBxb_rf.*xyyb_rf - xyByb_rf.*xyxb_rf)./xyrb_rf./xyBPb_rf;
