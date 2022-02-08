function [xcleeth,xcleith,xpcleerel,xpcleirel] = coulomb_logarithm_yp(model,xne,xTe,prel)
%
%   Coulomb logarithm calculations. May be dependent or not of the electron momentum
%
%   INPUTS:
%
%       - model : coulomb logarithm model, (1) Sauter, (2) Peysson, (3) Wesson (e-e), (4) Wesson (e-i), (5): NRL
%       - xne : electron density (m-3) [n,1]
%       - xTe : electron temperature (keV) [n,1]
%       - prel : relativistic momentum (p/(mec) [1,m]
%
%   OUTPUTS:
%
%       - xcleeth : thermal e-e coulomb logarithm [n,1]
%       - xcleith : thermal e-i coulomb logarithm [n,1]
%       - xpcleerel : relativistic e-e coulomb logarithm [n,m]
%       - xpcleirel : relativistic e-i coulomb logarithm [n,m]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
if nargin < 3
    error('ERROR: not enough input arguments in coulomb_logarithm_yp');
end
%
xpcleerel = [];
xpcleirel = [];
%
xne = xne(:);
xTe = xTe(:);
%
if nargin > 3 && ~isempty(prel)
    prel = prel(:)';
end
%
if abs(model) == 1
    xcleeth = 31.3 - 0.5*log(xne) + log(xTe*1000);%from O. Sauter et al., Phys. Plasmas, 1999, 6, 7, pp. 2834-2839 (default LUKE)
elseif abs(model) == 2
    xcleeth = 14.9 - 0.5*log(xne/1e20) + log(xTe);%from J. Wesson, Tokamaks, Clarendon Press, 2004  
end
%
xcleith = xcleeth; % identical for the moment
%
if nargin > 3 && ~isempty(prel)
    %
    if isreal(model)
        %
        xpcleerel = xcleeth*ones(1,length(prel)) + log(1 + (2*(sqrt((ones(size(xcleeth))*prel).^2+1)-1)./(2*(xTe*ones(1,length(prel)))/511)).^2.5)/5;%cl_ee, thermal and high energy, Hesslow et al. 2018
        xpcleirel = xcleith*ones(1,length(prel)) + log(1 + (2*(ones(size(xcleith))*prel)./sqrt(2*(xTe*ones(1,length(prel)))/511)).^5)/5;%cl_ei, thermal and high energy, Hesslow et al. 2018
    else
        %
        xpcleerel = xcleeth*ones(1,length(prel));%
        xpcleirel = xcleith*ones(1,length(prel));%
    end
    %
end
%


