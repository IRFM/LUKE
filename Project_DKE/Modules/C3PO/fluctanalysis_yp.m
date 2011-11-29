function [tn,tn_all,fluctres] = fluctanalysis_yp(equilDKE,ZP0,Zcurr,dkeparam,mksa,racc,itnmin)
%
% This function makes the statistical analysis of the power and rf current when fluctuations are present 
%
%   INPUT :
%
%       - equilDKE: 
%       - ZP0:
%       - Zcurr:
%       - mksa:
%       - racc: minimum relative accuracy of the mean value [1,1]
%           (default = 0.05)
%       -itnmin: minimum index of the time evolution [1,1]
%           (default = 1)
%
%   OUTPUT :
%
%       - tn: processed time index [1,m]
%       - tn_all: all time index [1,ntn]
%       - fluctres: output structure
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin == 5,
	racc = 0.05;
    itnmin = 1;
elseif nargin == 6,
    itnmin = 1;
end
%
fluctres.I.scocurr = sign(equilDKE.psia_apRp)*sign(equilDKE.XBphi(1,1));%cocurrent factor
%
if isfield(equilDKE,'xdV_dke'),
    xdV = equilDKE.xdV_dke(:)';
else
    xdV = equilDKE.xdV_2piRp_dke(:)'*2*pi*equilDKE.Rp;
end
%
xdA = equilDKE.xdA_dke;
%
ZP0_t_x_rf_fsav = ZP0.t_x_rf_fsav(itnmin:end,:);
if isvector(ZP0.t_x_rf_fsav),ZP0_t_x_rf_fsav = ZP0_t_x_rf_fsav(:)';end
%
tn = Zcurr.xtn(itnmin:end);
tn_all = Zcurr.xtn;
%
fluctres.P.tP_all = ZP0.t_x_rf_fsav*mksa.P_ref*xdV(:);
fluctres.P.tnP_all = tn_all;
fluctres.P.tP = ZP0_t_x_rf_fsav*mksa.P_ref*xdV(:);
[fluctres.P.iPtot,fluctres.P.Ptot,fluctres.P.Ptotm,fluctres.P.Ptots,fluctres.P.Ptotr,fluctres.P.iPtotr] = statanalysis_yp(fluctres.P.tP,racc);
%
fluctres.P.xP = ZP0_t_x_rf_fsav(fluctres.P.iPtot,:)*mksa.P_ref;
fluctres.P.xPm = mean(fluctres.P.xP,1);
fluctres.P.xPs = std(fluctres.P.xP);
%
Zcurr_t_x_0_fsav = Zcurr.t_x_0_fsav(itnmin:end,:);
if isvector(Zcurr_t_x_0_fsav),Zcurr_t_x_0_fsav = Zcurr_t_x_0_fsav(:)';end
%
fluctres.I.tI_all = Zcurr.t_x_0_fsav*mksa.j_ref*xdA(:);
fluctres.I.tnI_all = tn_all;
fluctres.I.tI = Zcurr_t_x_0_fsav*mksa.j_ref*xdA(:);
fluctres.I.tnI = tn(fluctres.P.iPtot);%new base time correponding to points where the absorbed RF power is consistent with input RF power
fluctres.I.tI = fluctres.I.tI(fluctres.P.iPtot);%keep only points where the absorbed RF power is consistent with input RF power
[fluctres.I.iItot,fluctres.I.Itot,fluctres.I.Itotm,fluctres.I.Itots,fluctres.I.Itotr,fluctres.I.iItotr] = statanalysis_yp(fluctres.I.tI,racc);
%
fluctres.I.xJ = Zcurr_t_x_0_fsav(fluctres.I.iItot,:)*mksa.j_ref;
fluctres.I.xJm = mean(fluctres.I.xJ,1);
fluctres.I.xJs = std(fluctres.I.xJ);
