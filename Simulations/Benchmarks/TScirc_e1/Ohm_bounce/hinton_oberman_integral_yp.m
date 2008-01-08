function [Iho] = hinton_oberman_integral_yp(equilDKE);
%
%  Hinton-Oberman Integral (Nucl. Fusion, 9 (1969) 319
%  
% by Y.Peysson (CEA-DRFC) <yves.peysson@cea.fr> and J. Decker (CEA-DRFC) <joan.decker@cea.fr>
%
if nargin < 1,
    error('Not enough input arguments in hinton_oberman_integral_yp.m !');
end
%
iar = equilDKE.xrho*equilDKE.ap/equilDKE.Rp;
ymhu0 = linspace(eps,1,301);%Positive mhu0 value only
xymhu0 = ones(length(iar),1)*ymhu0;
dmhu0 = ymhu0(2) - ymhu0(1);
[xymaskT,xylambda_p0p0,xylambda_p2m1,xylambda_p2m2p2,xylambda_b_p1p1,xylambda_b_p1m1p2,xylambda_b_p1m1,xylambda_b_p1m2,xylambda_b_p2m2p2,xylambda_b_p3m2,xylambda_b_p2,xylambda_b_p1m3p4,xylambda_b_p1m2p2] = bounce_dke_jd(0,ymhu0,equilDKE,0);
%
for im = 1:length(ymhu0),
    xy1(:,im) = sum(~xymaskT.*(xymhu0 <= ymhu0(im)).*dmhu0./xylambda_p2m1,2);
end
%
y2 = sum(~xymaskT.*xymhu0.*xy1*dmhu0,2);
%
Iho = 1 - 1./(1 + iar) + 3.*y2'./sqrt(1 - iar.^2);