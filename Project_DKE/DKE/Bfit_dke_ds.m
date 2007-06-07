function [varargout] = Bfit_dke_ds(theta,psin,equil,equil_fit,Bsolve)
%
% Calculation of B and dBdtheta (option) on a psi grid for any poloidal
% angle value
%
% INPUT:
%
%   - theta: poloidal angle [1,1]
%   - psin: normalized poloidal flux grid [nr,1] 
%   - equil: magnetic equilibrium structure
%   - equil_fit: structure of the vectorial for of the magnetic equilibrium
%   - Bsolve: reference magnetic field value (for use with thetastar_dke_ds.m only with fsolve matlab function) (T) [1,1]
%
% OUTPUT:
%
%   - B_fit: magnetic field at theta value (T) [nr,1]
%   - dBdtheta_fit: poloidal derivative of the magnetic field at theta value (T) [nr,1]
%     (optional)
%
% by Y. PEYSSON (CEA/DRFC, yves.peysson@cea.fr) and D. SCHMITT (CEA/DRFC, damien.schmitt@cea.fr)
%
if nargin < 5, Bsolve = 0;end
%
rho = psi2rho_jd(equil,psin);%psi to rho conversion
%
Bx_a0_fit = ppval_yp(equil_fit.Bx_fit.pp_a0,rho);
Bx_an_fit = ppval_yp(equil_fit.Bx_fit.pp_an,rho);
Bx_bn_fit = ppval_yp(equil_fit.Bx_fit.pp_bn,rho);
%
By_a0_fit = ppval_yp(equil_fit.By_fit.pp_a0,rho);
By_an_fit = ppval_yp(equil_fit.By_fit.pp_an,rho);
By_bn_fit = ppval_yp(equil_fit.By_fit.pp_bn,rho);
%
BPHI_a0_fit = ppval_yp(equil_fit.BPHI_fit.pp_a0,rho);
BPHI_an_fit = ppval_yp(equil_fit.BPHI_fit.pp_an,rho);
BPHI_bn_fit = ppval_yp(equil_fit.BPHI_fit.pp_bn,rho);
%
% Build interpolated quantities
%
[BR_fit,dBRdtheta_fit] = calcval_yp(equil_fit,theta,Bx_a0_fit(:),Bx_an_fit,Bx_bn_fit);
[BZ_fit,dBZdtheta_fit] = calcval_yp(equil_fit,theta,By_a0_fit(:),By_an_fit,By_bn_fit);
[BPHI_fit,dBPHIdtheta_fit] = calcval_yp(equil_fit,theta,BPHI_a0_fit(:),BPHI_an_fit,BPHI_bn_fit);
%
BP_fit = sqrt(BR_fit(:).^2 + BZ_fit(:).^2);
dBPdtheta_fit = (BR_fit(:).*dBRdtheta_fit(:) + BZ_fit(:).*dBZdtheta_fit(:))./BP_fit(:);
%
B_fit = sqrt(BR_fit(:).^2 + BZ_fit(:).^2 + BPHI_fit(:).^2);
dBdtheta_fit = (BR_fit(:).*dBRdtheta_fit(:) + BZ_fit(:).*dBZdtheta_fit(:) + BPHI_fit(:).*dBPHIdtheta_fit(:))./B_fit(:);
%
B_fitsolve = B_fit - Bsolve;%for finding theta value corresponding to B_fitsolve = 0 if Bsolve is defined. 
%
if nargout >= 1, varargout{1} = B_fitsolve;end
if nargout >= 2, varargout{2} = dBdtheta_fit;end
