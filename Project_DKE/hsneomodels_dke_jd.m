function [prho,pcurr_hir_ref_fsav,pcurr_sau_ref_fsav,pcurr_hin_ref_fsav,pcurr_i_ref_fsav] = ...
    hsneomodels_dke_jd(tokname)
% 
% Calculates the bootstrap current from neoclassical models by Hinton & Hazeltine, Hirshman and Sauter 
% (in the limit of large aspect ratio)
% Note: The calculation is based on the model of circular concentric
% flux-surface, with parameters derived from the magnetic geometry.
%
%   INPUTS: 
%
%       - tokname: Name of the tokamak
%
%   OUTPUTS:
%
%       - prho: radial grid [1,np]
%       - pcurr_hir_ref_fsav: Electron bootstrap current from Hirsman model (MA/m2) [1,np]
%       - pcurr_sau_ref_fsav: Electron bootstrap current from Sauter model (MA/m2) [1,np]
%       - pcurr_hin_ref_fsav: Electron bootstrap current from Hinton & Hazeltine model (MA/m2) [1,np]
%       - pcurr_i_ref_fsav: Ion contribution to total bootstrap current for Hirschman, Sauter and Hinton & Hazeltine models (MA/m2) [1,np]
%       - pcurr_tag_e_ref_fsav: Electron bootstrap current from Taguchi model (anistropic electron distribution) (MA/m2) [1,np] 
%       - pcurr_tag_i_ref_fsav: Ion bootstrap current from Taguchi model (anistropic electron distribution) (MA/m2) [1,np] 
%
%by Joan Decker <jodecker@alum.mit.edu> and Y. Peysson CEA-DRFC <yves.peysson@cea.fr>
%
qe = 1.6e-19;
%
filename = ['EQUIL_',tokname,'.mat'];
[s,dossier,machine] = comput_dke_yp;
eval(['load ',dossier,s,filename,' BPHI BR BZ R Z ppsi pTe pne pzTi zZi']);
np = length(ppsi);
Bt = BPHI(1,1);
Rp = R(1,1);
Zp = Z(1,1);
ap = R(np,1) - Rp;
prho = (R(:,1) - Rp)'/ap;
pq = qfactors_dke_yp(Rp,Zp,R,Z,BR,BZ,BPHI);
%
% note: model with one ion species only. to be completed
%
pTi = pzTi(1,:);
Zi = zZi(1);
%
drho = diff(prho);
%
dTedr = diff(pTe)./drho/ap;
dTedr = [dTedr(1),(dTedr(1:np-2) + dTedr(2:np-1))/2,dTedr(np-1)]; 
dnedr = diff(pne)./drho/ap;
dnedr = [dnedr(1),(dnedr(1:np-2) + dnedr(2:np-1))/2,dnedr(np-1)]; 
dTidr = diff(pTi)./drho/ap;
dTidr = [dTidr(1),(dTidr(1:np-2) + dTidr(2:np-1))/2,dTidr(np-1)]; 
%
dlnTedr = 1./(pTe+eps).*dTedr;
dlnnedr = 1./(pne+eps).*dnedr;
dlnTidr = 1./(pTi+eps).*dTidr;
dlnnidr = dlnnedr;
%
ppe = pne.*pTe;
dlnpedr = dlnTedr + dlnnedr;
dlnpidr = dlnTidr + dlnnidr;
%
pia = prho*ap/Rp;
%
px = (1.46*pia.^(0.5) + 2.40*pia)./(1 - pia).^(1.5);
%
Dx = 1.414*Zi + Zi^2 + px*(0.754 + 2.657*Zi + 2*Zi^2) + px.^2*(0.348 + 1.243*Zi + Zi^2);
%
L31 = px.*(0.754 + 2.21*Zi + Zi^2 + px*(0.348 + 1.243*Zi + Zi^2))./Dx;
L32 = -px*(0.884 + 2.074*Zi)./Dx;
L34 = L31;
alpha = -1.172./(1 + 0.462*Zi);
%
% Sauter Correction for L32 in case of large aspect ratio limit (S.Schultz thesis p 92)
%
px_s = 1 - (1 - pia).^2./sqrt(1-pia.^2)./(1 + 1.46*sqrt(pia));
L32_s = -(0.51 + 1.31*Zi)/Zi/(1 + 0.44*Zi)*(px_s - px_s.^4)...
        +(5.95 + 3.57*Zi)/(1 + 2.70*Zi + 0.546*Zi^2)*(px_s.^2 - px_s.^4)...
        -(3.92 + 3.57*Zi)/(1 + 2.70*Zi + 0.546*Zi^2)*(px_s.^3 - px_s.^4);
%
A1 = dlnpedr + pTi./(Zi*pTe).*dlnpidr;
A2 = dlnTedr;
A4 = alpha.*pTi./(Zi*pTe).*dlnTidr;
%
Jbavnorm = -ppe.*pq./pia.*(L31.*A1 + L32.*A2 + L34.*A4); 
Jbavnorm_s = -ppe.*pq./pia.*(L31.*A1 + L32_s.*A2 + L34.*A4); 
Jbavnorm_hh = -ppe.*pq./sqrt(pia).*(0.69*dlnTedr + 2.44*dlnnedr); 
%
pcurr_hir_ref_fsav = Jbavnorm/Bt*qe*1e-6*1e3; 
pcurr_sau_ref_fsav = Jbavnorm_s/Bt*qe*1e-6*1e3;
pcurr_hin_ref_fsav_e = Jbavnorm_hh/Bt*qe*1e-6*1e3;
%
% Ion Flux to be added in the fluid limit: Hinton & Hazeltine, Hirshman and Sauter relations use the same term
%
A1_i = pTi./(Zi*pTe).*dlnpidr;
Jbavnorm_i = -ppe.*pq./pia.*(L31.*A1_i + L34.*A4);
pcurr_i_ref_fsav = Jbavnorm_i/Bt*qe*1e-6*1e3; 
%
pcurr_hin_ref_fsav = pcurr_hin_ref_fsav_e + pcurr_i_ref_fsav;
%
%Taguchi's model for anisotropic electron distribution function (Ref: J. Physical Soc. Japan, 65,11 (1996) 3530)
%
pcurr_tag_e_ref_fsav = NaN;
pcurr_tag_i_ref_fsav = NaN;
