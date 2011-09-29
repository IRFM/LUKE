function [xx,yy,varargout] = build_tensor_yp(x,y,z)
%
% Build 2-D (matrix) or 3-D (tensor) from vectors, whatever their dimensions
%
% INPUT
%    - x: first vecteur [1,nx] or [nx,1]
%    - y: first vecteur [1,ny] or [ny,1]
%    - z: first vecteur [1,nz] or [nz,1] (optional)
%
% OUTPUT:
%
%    - xx: matrix or tensor [nx,ny,(nz)]
%    - yy: matrix or tensor [nx,ny,(nz)]
%    - zz: matrix or tensor [nx,ny,(nz)] (optional)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in build_tensor_yp.m !');end
%
xx = repmat(x(:),[1,length(y)]);
yy = repmat(y(:)',[length(x),1]);
%
if nargin > 2,
    xx = repmat(xx,[1,1,length(z)]);
    yy = repmat(yy,[1,1,length(z)]);
    varargout = {shiftdim(repmat(repmat(z,[length(y),1]),[1,1,length(x)]),2)};
else
    varargout = {};
end
