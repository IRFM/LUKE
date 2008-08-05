function [iar,sigman] = conductivity_model_yp(equil,model,xrho)
%
%  Conductivity calculated by various models for test only (circular concentric plasma cross-section)
%  
% by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (CEA-DRFC) <joan.decker@cea.fr>
%
if nargin < 2,
    error('Not enough input arguments in conductivity_model_yp.m !');
end
%
if nargin < 3,
    %
    [equilDKE] = equilibrium_jd(equil);%Magnetic equilibrium for DKE
    %    
else
    %
    xpsin_f = rho2psi_jd(equil,xrho);
    %
    radialDKE.xpsin_S_dke = NaN;
    radialDKE.xpsin_f = xpsin_f;
    %
    [equilDKE] = equilibrium_jd(equil,radialDKE);%Magnetic equilibrium for DKE
    %        
end
%
iar = equilDKE.xrho*equilDKE.ap/equilDKE.Rp;
%
if model == 1,
    sigman = 1 - 1.95*sqrt(iar) + 0.95*iar;%Sigmar-Coppi-Kim model (low inverse aspect ratio limit)
elseif model == 2, 
    Iho= hinton_oberman_integral_yp(equilDKE);%Hinton-Oberman Integral (Nucl. Fusion, 9 (1969) 319   
    sigman = Iho.*(1 + 0.039.*(1 - Iho))./(1 + 0.471.*(1 - Iho));
end
