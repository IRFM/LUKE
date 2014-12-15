function [Zbci] = interpequilxy_yp(f_in,dfdx_in,dfdy_in,d2fdxdy_in)
% C3PO: Bicubic interpolation of the magnetic equilibrium
%
% Build interpolated toroidal MHD magnetic equilibrium from its numerical counterpart
% Bicubic interpolation (x = R-Rp, y = Z-Zp). 
%
% INPUT
%
%    - f_in: 2-D (x,y) function to interpolate [nz*nx,nx]
%    - dfdx_in: 2-D (x,y) 1st order derivative of the function to interpolate along x direction [nz*nx,nx]
%    - dfdy_in: 2-D (x,y) 1st order derivative of the function to interpolate along y direction [nz*nx,nx]
%    - d2fdxdy_in: 2-D (x,y) 2nd order cross-derivative of the function to interpolate along x and y directions [nz*nx,nx]
%
% OUTPUT
%
%    - Zbci: structure of bicubic interpolation
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@epfl.ch)
%
if nargin < 4,
    error('ERROR: not enough input arguments in interpequilxy_yp');
end
%
wt_d = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
-3, 0, 0, 3, 0, 0, 0, 0,-2, 0, 0,-1, 0, 0, 0, 0;
2, 0, 0,-2, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0;
0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
0, 0, 0, 0,-3, 0, 0, 3, 0, 0, 0, 0,-2, 0, 0,-1;
0, 0, 0, 0, 2, 0, 0,-2, 0, 0, 0, 0, 1, 0, 0, 1;
-3, 3, 0, 0,-2,-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, 0, 0, 0, 0, 0,-3, 3, 0, 0,-2,-1, 0, 0;
9,-9, 9,-9, 6, 3,-3,-6, 6,-6,-3, 3, 4, 2, 1, 2;
-6, 6,-6, 6,-4,-2, 2, 4,-3, 3, 3,-3,-2,-1,-1,-2;
2,-2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
0, 0, 0, 0, 0, 0, 0, 0, 2,-2, 0, 0, 1, 1, 0, 0;
-6, 6,-6, 6,-3,-3, 3, 3,-4, 4, 2,-2,-2,-2,-1,-1;
4,-4, 4,-4, 2, 2,-2,-2, 2,-2,-2, 2, 1, 1, 1, 1];%weights (see note on redmine)
%
nwt_d = size(wt_d,1);
%
for jj = 1:size(f_in,1)/size(f_in,2),
%
    f = f_in((jj-1)*size(f_in,2)+1:jj*size(f_in,2),:);
    dfdx = dfdx_in((jj-1)*size(f_in,2)+1:jj*size(f_in,2),:);
    dfdy = dfdy_in((jj-1)*size(f_in,2)+1:jj*size(f_in,2),:);
    d2fdxdy = d2fdxdy_in((jj-1)*size(f_in,2)+1:jj*size(f_in,2),:);
    %
    F_ij = f(1:size(f,1)-1,1:size(f,2)-1);
    F_ipj = f(2:size(f,1),1:size(f,2)-1);
    F_ijp = f(1:size(f,1)-1,2:size(f,2));
    F_ipjp = f(1:size(f,1)-1,2:size(f,2));
    %
    dFdx_ij = dfdx(1:size(f,1)-1,1:size(f,2)-1);
    dFdx_ipj = dfdx(2:size(f,1),1:size(f,2)-1);
    dFdx_ijp = dfdx(1:size(f,1)-1,2:size(f,2));
    dFdx_ipjp = dfdx(1:size(f,1)-1,2:size(f,2));
    %
    dFdy_ij = dfdy(1:size(f,1)-1,1:size(f,2)-1);
    dFdy_ipj = dfdy(2:size(f,1),1:size(f,2)-1);
    dFdy_ijp = dfdy(1:size(f,1)-1,2:size(f,2));
    dFdy_ipjp = dfdy(1:size(f,1)-1,2:size(f,2));
    %
    d2Fdxdy_ij = d2fdxdy(1:size(f,1)-1,1:size(f,2)-1);
    d2Fdxdy_ipj = d2fdxdy(2:size(f,1),1:size(f,2)-1);
    d2Fdxdy_ijp = d2fdxdy(1:size(f,1)-1,2:size(f,2));
    d2Fdxdy_ipjp = d2fdxdy(1:size(f,1)-1,2:size(f,2));
    %
    NN = size(F_ij,1)*size(F_ij,2);
    %
    FF = [F_ipj(:),F_ipjp(:),F_ijp(:),F_ij(:),dFdx_ipj(:),dFdx_ipjp(:),dFdx_ijp(:),dFdx_ij(:),dFdy_ipj(:),dFdy_ipjp(:),dFdy_ijp(:),dFdy_ij(:),d2Fdxdy_ipj(:),d2Fdxdy_ipjp(:),d2Fdxdy_ijp(:),d2Fdxdy_ij(:)].';
    FF = FF(:);
    %
    clear F_ij F_ipj F_ijp F_ipjp dFdx_ij dFdx_ipj dFdx_ijp dFdx_ipjp dFdy_ij dFdy_ipj dFdy_ijp dFdy_ipjp d2Fdxdy_ij d2Fdxdy_ipj d2Fdxdy_ijp d2Fdxdy_ipjp
    %
    %M_test = kron(speye(NN),sparse(wt_d));%not efficient when NN is very large
    %CC_test = reshape(M_test*FF,nwt_d,NN).';;%Create bicubic interpolation coefficients
    %
    CC = zeros(NN*nwt_d,1);
    NM0 = min(NN,1000);%1000 gives minium time to calculate CC usually.
    M0 = sparse(NM0*nwt_d,NM0*nwt_d);
    M0 = kron(speye(NM0),sparse(wt_d));
    %
    for ii = 1:floor(NN*nwt_d/size(M0,1))
        CC(size(M0,1)*(ii-1)+1:size(M0,1)*ii,1) = M0*FF(size(M0,1)*(ii-1)+1:size(M0,1)*ii,1);%Create bicubic interpolation coefficients
    end
    %
    NM1 = NN - floor(NN*nwt_d/size(M0,1))*NM0;
    M1 = sparse(NM1*nwt_d,NM1*nwt_d);
    M1 = kron(speye(NM1),sparse(wt_d));
    %
    CC(NN*nwt_d-size(M1,1)+1:NN*nwt_d,1) = M1*FF(NN*nwt_d-size(M1,1)+1:NN*nwt_d,1);%Create last bicubic interpolation coefficients
    %
    Zbci.CC(:,:,jj) = reshape(CC,nwt_d,NN).';
    %
end