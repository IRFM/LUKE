function [xcurr_hir_ref_fsav,xcurr_sau_ref_fsav,xcurr_hin_ref_fsav,xcurr_i_ref_fsav] = ...
    hsneomodels_dke_jd(xrho,ap,Rp,Zi,xq,Bt,xTe,xne,xTi)
% 
% Calculates the bootstrap current from neoclassical models by Hinton & Hazeltine, Hirshman and Sauter (in the limit of large aspect ratio)
%
%   INPUTS: 
%       - xrho: normalized radius positions [1,nr]
%       - ap: minor radius (m)
%       - Rp: major radius (m)
%       - Zi: ion charge 
%       - xq: safety factor [1,nr]
%       - Bt: magnetic field on axis (T)
%       - Te0: central electron temperature (keV)
%       - Tea: edge electron temperature (keV)
%       - eTe: exponent for electron temperature profile
%       - ne0: central electron density (keV)
%       - nea: edge electron density (keV)
%       - ene: exponent for electron density profile
%       - Ti0: central ion temperature (keV)
%       - Tia: edge ion temperature (keV)
%       - eTi: exponent for ion temperature profile
%
%   OUTPUTS:
%       - xcurr_hir_ref_fsav: Electron bootstrap current from Hirsman model (MA/m2) [1,nr]
%       - xcurr_sau_ref_fsav: Electron bootstrap current from Sauter model (MA/m2) [1,nr]
%       - xcurr_hin_ref_fsav: Electron bootstrap current from Hinton & Hazeltine model (MA/m2) [1,nr]
%       - xcurr_i_ref_fsav: Ion contribution to total bootstrap current for Hirschman, Sauter and Hinton & Hazeltine models (MA/m2) [1,nr]
%       - xcurr_tag_e_ref_fsav: Electron bootstrap current from Taguchi model (anistropic electron distribution) (MA/m2) [1,nr] 
%       - xcurr_tag_i_ref_fsav: Ion bootstrap current from Taguchi model (anistropic electron distribution) (MA/m2) [1,nr] 
%
%by Joan Decker 09/24/2001 
%last update 29/07/2002 by Y. Peysson CEA-DRFC <yves.peysson@cea.fr>
%
qe = 1.6e-19;
%
nr = length(xTe);
drho = diff(xrho);
%
dTedr = diff(xTe)./drho/ap;
dTedr = [dTedr(1),(dTedr(1:nr-2) + dTedr(2:nr-1))/2,dTedr(nr-1)]; 
dnedr = diff(xne)./drho/ap;
dnedr = [dnedr(1),(dnedr(1:nr-2) + dnedr(2:nr-1))/2,dnedr(nr-1)]; 
dTidr = diff(xTi)./drho/ap;
dTidr = [dTidr(1),(dTidr(1:nr-2) + dTidr(2:nr-1))/2,dTidr(nr-1)]; 
%
dlnTedr = 1./(xTe+eps).*dTedr;
dlnnedr = 1./(xne+eps).*dnedr;
dlnTidr = 1./(xTi+eps).*dTidr;
dlnnidr = dlnnedr;
%
xpe = xne.*xTe;
dlnpedr = dlnTedr + dlnnedr;
dlnpidr = dlnTidr + dlnnidr;
%
ia = xrho*ap/Rp;
%
x = (1.46*ia.^(0.5) + 2.40*ia)./(1 - ia).^(1.5);
%
Dx = 1.414*Zi + Zi^2 + x*(0.754 + 2.657*Zi + 2*Zi^2) + x.^2*(0.348 + 1.243*Zi + Zi^2);
%
L31 = x.*(0.754 + 2.21*Zi + Zi^2 + x*(0.348 + 1.243*Zi + Zi^2))./Dx;
L32 = -x*(0.884 + 2.074*Zi)./Dx;
L34 = L31;
alpha = -1.172./(1 + 0.462*Zi);
%
% Sauter Correction for L32 in case of large aspect ratio limit (S.Schultz thesis p 92)
%
x_s = 1 - (1 - ia).^2./sqrt(1-ia.^2)./(1 + 1.46*sqrt(ia));
L32_s = -(0.51 + 1.31*Zi)/Zi/(1 + 0.44*Zi)*(x_s - x_s.^4)...
        +(5.95 + 3.57*Zi)/(1 + 2.70*Zi + 0.546*Zi^2)*(x_s.^2 - x_s.^4)...
        -(3.92 + 3.57*Zi)/(1 + 2.70*Zi + 0.546*Zi^2)*(x_s.^3 - x_s.^4);
%
A1 = dlnpedr + xTi./(Zi*xTe).*dlnpidr;
A2 = dlnTedr;
A4 = alpha.*xTi./(Zi*xTe).*dlnTidr;
%
Jbavnorm = -xpe.*xq./ia.*(L31.*A1 + L32.*A2 + L34.*A4); 
Jbavnorm_s = -xpe.*xq./ia.*(L31.*A1 + L32_s.*A2 + L34.*A4); 
Jbavnorm_hh = -xpe.*xq./sqrt(ia).*(0.69*dlnTedr + 2.44*dlnnedr); 
%
xcurr_hir_ref_fsav = Jbavnorm/Bt*qe*1e-6*1e3; 
xcurr_sau_ref_fsav = Jbavnorm_s/Bt*qe*1e-6*1e3;
xcurr_hin_ref_fsav_e = Jbavnorm_hh/Bt*qe*1e-6*1e3;
%
% Ion Flux to be added in the fluid limit: Hinton & Hazeltine, Hirshman and Sauter relations use the same term
%
A1_i = xTi./(Zi*xTe).*dlnpidr;
Jbavnorm_i = -xpe.*xq./ia.*(L31.*A1_i + L34.*A4);
xcurr_i_ref_fsav = Jbavnorm_i/Bt*qe*1e-6*1e3; 
%
xcurr_hin_ref_fsav = xcurr_hin_ref_fsav_e + xcurr_i_ref_fsav;
%
%Taguchi's model for anisotropic electron distribution function (Ref: J. Physical Soc. Japan, 65,11 (1996) 3530)
%
xcurr_tag_e_ref_fsav = NaN;
xcurr_tag_i_ref_fsav = NaN;
