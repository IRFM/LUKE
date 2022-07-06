function [ff] = formfactornum_yp(rn,dens,q);
%
% Numerical calculation of the atomic form factor
%
%   INPUTS:
%
%       - rn : atomic radius normalized to a0 [1,n]
%       - dens : electron density [1,n]
%       - q : recoil momentum normalized to mec units [1,p]
%
%   OUTPUTS:
%
%       - ff : atomic form factor [1,p]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
[~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
%
xrn = rn(:)*ones(1,length(q));
xdens = dens(:)*ones(1,length(q));
xq = ones(length(rn),1)*q(:)';
%
ff = 4*pi*alpha*trapz(rn(:),xdens.*xrn.*sin(xq.*xrn/alpha)./xq);
%