% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [q,ff] = formfactornum_yp(rn,dens,q);
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
if nargin < 3
    %
    nq = 1000;
    q = logspace(-4,1,nq);%normalized recoil momentum normalized to mec 
    %
end
%
[~,~,~,~,~,~,re,mc2,~,alpha] = pc_dke_yp;%Physics constant
%
xrn = rn(:)*ones(1,length(q));
xdens = dens(:)*ones(1,length(q));
xq = ones(length(rn),1)*q(:)';
%
ff = 4*pi*alpha*trapz(rn(:),xdens.*xrn.*sin(xq.*xrn/alpha)./xq);
%