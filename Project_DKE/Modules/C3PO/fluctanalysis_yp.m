function [tn,tn_all,fluctres] = fluctanalysis_yp(tn,txJ,txP,tI,tP,racc,itnmin)
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
if nargin < 6,
	racc = NaN;
end
if nargin < 7,
    itnmin = 1;
end
%
if ~isstruct(racc),
    raccval = racc;
    racc = struct;
    racc.P = raccval;
    racc.I = raccval;
end
%
% fluctres.I.scocurr = sign(equilDKE.psia_apRp)*sign(equilDKE.XBphi(1,1));%cocurrent factor
%
txP_all = txP;
txP = txP(itnmin:end,:);
if isvector(txP_all),
    txP = txP(:).';
end
%
tn_all = tn;
tn = tn(itnmin:end);
%
fluctres.P.tP_all = tP;
fluctres.P.tnP_all = tn_all;
fluctres.P.tP = tP(itnmin:end);
[fluctres.P.iPtot,fluctres.P.Ptot,fluctres.P.Ptotm,fluctres.P.Ptots,fluctres.P.Ptotr,fluctres.P.iPtotr] = statanalysis_yp(fluctres.P.tP,racc.P);
%
fluctres.P.xP = txP(fluctres.P.iPtot,:);
fluctres.P.xPm = mean(fluctres.P.xP,1);
fluctres.P.xPs = std(fluctres.P.xP);
%
txJ_all = txJ;
txJ = txJ(itnmin:end,:);
if isvector(txJ_all),
    txJ = txJ(:).';
end
%
fluctres.I.tI_all = tI;
fluctres.I.tnI_all = tn_all;
fluctres.I.tI = tI(itnmin:end);
fluctres.I.tnI = tn(fluctres.P.iPtot);%new base time correponding to points where the absorbed RF power is consistent with input RF power
fluctres.I.tI = fluctres.I.tI(fluctres.P.iPtot);%keep only points where the absorbed RF power is consistent with input RF power
txJ = txJ(fluctres.P.iPtot,:);%keep only points where the absorbed RF power is consistent with input RF power
[fluctres.I.iItot,fluctres.I.Itot,fluctres.I.Itotm,fluctres.I.Itots,fluctres.I.Itotr,fluctres.I.iItotr] = statanalysis_yp(fluctres.I.tI,racc.I);
%
fluctres.I.xJ = txJ(fluctres.I.iItot,:);
fluctres.I.xJm = mean(fluctres.I.xJ,1);
fluctres.I.xJs = std(fluctres.I.xJ);
