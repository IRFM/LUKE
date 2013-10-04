function [XXalpha_an,XXmask_ctsa,thetastar_an,thetastar_an2] = S_anal_en(equilDKE,gridDKE,Zmomcoef,pnRA,dpnRA,npnRA,gammaRA)
%
% This function calculates the avalanche source term with analytical
% formula for equilibrium of circular concentric flux surfaces
%
% INPUT
%    - equilDKE
%    - gridDKE: grid structure, XXmhu
%    - Zmomcoef
%
% OUTPUT:
%    - XXalpha_an: The term alpha for the bounce averaged source term for
%    secondary runaways analytically for equilibrium of circular concentric flux surfaces
%
% By E. Nilsson (CEA-IRFM, emelie.nilsson@cea.fr) Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr) 
%
%
npsi = gridDKE.nr;
%npn = gridDKE.npn;
nmhu = gridDKE.nmhu;
%
epsilon=equilDKE.ap*equilDKE.xrho/equilDKE.Rp;
costhetastar_an=NaN(npsi,npnRA,nmhu);
%
for ipsi=1:npsi
    for m=1:nmhu
        costhetastar_an(ipsi,:,m)=1/epsilon(ipsi) *(((1-gridDKE.mhu(m).^2).*(gammaRA+1).*(1+epsilon(ipsi)))./2-1);
    end
end
%
XXmask_ctsa = costhetastar_an>-1 & costhetastar_an<1;
XXcosthetastar_an=costhetastar_an.*XXmask_ctsa;
XXcosthetastar_an(XXcosthetastar_an==0) = NaN;
thetastar_an=acos(XXcosthetastar_an);
thetastar_an2=2*pi-acos(XXcosthetastar_an);
%
[qe,me,mp,mn,e0,mu0] = pc_dke_yp;
%
Ip=1; %plasma current [MA]
D = equilDKE.xrho.*mu0*Ip*1e6./(equilDKE.ap*2*pi); %Bp in cylindrical case, from Amperes law
%
for ipsi=1:npsi
    for m=1:nmhu
dPsi1(ipsi,:,m)=epsilon(ipsi).*sin(thetastar_an(ipsi,:,m)).*(1+epsilon(ipsi))./(1+epsilon(ipsi).*cos(thetastar_an(ipsi,:,m))).^2;
dPsi2(ipsi,:,m)=epsilon(ipsi).*sin(thetastar_an2(ipsi,:,m)).*(1+epsilon(ipsi))./(1+epsilon(ipsi).*cos(thetastar_an2(ipsi,:,m))).^2;
Bp1(ipsi,:,m)=D(ipsi)./(1+epsilon(ipsi).*cos(thetastar_an(ipsi,:,m)));
Bp2(ipsi,:,m)=D(ipsi)./(1+epsilon(ipsi).*cos(thetastar_an2(ipsi,:,m)));  
    end
XXalpha_an(ipsi,:,:)=equilDKE.xB0(ipsi)*XXmask_ctsa(ipsi,:,:).*equilDKE.xrho(ipsi)./abs(dPsi1(ipsi,:,:))./Bp1(ipsi,:,:)...
    + equilDKE.xB0(ipsi)*XXmask_ctsa(ipsi,:,:).*equilDKE.xrho(ipsi)./abs(dPsi2(ipsi,:,:))./Bp2(ipsi,:,:); %should be normalized to ap instead ?, now its Rp
end