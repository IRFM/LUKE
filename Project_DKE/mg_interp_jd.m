function [xyBb_rf,xyBPb_rf,xyrb_rf,xyRb_rf,xyZb_rf,xyBRb_rf,xyBZb_rf,xyBphib_rf] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_rf);
%
% This function interpolates the magnetic geometry data to given
% poloidal positions
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
nr = size(xythetab_rf,1);
for ir = 1:nr
    xyRb_rf(ir,:) = interp1(theta,XR(ir,:),xythetab_rf(ir,:));
    xyZb_rf(ir,:) = interp1(theta,XZ(ir,:),xythetab_rf(ir,:));
%        
    xyBRb_rf(ir,:) = interp1(theta,XBR(ir,:),xythetab_rf(ir,:));
    xyBZb_rf(ir,:) = interp1(theta,XBZ(ir,:),xythetab_rf(ir,:));
    xyBphib_rf(ir,:) = interp1(theta,XBphi(ir,:),xythetab_rf(ir,:));
end
xyrb_rf = sqrt((xyRb_rf - Rp).^2 + (xyZb_rf - Zp).^2);% minor radius at theta = thetab_rf
xyBPb_rf = sqrt(xyBRb_rf.^2 + xyBZb_rf.^2);% poloidal magnetic field at theta = thetab_rf
xyBb_rf = sqrt(xyBPb_rf.^2 + xyBphib_rf.^2);% magnetic field at theta = thetab_rf
