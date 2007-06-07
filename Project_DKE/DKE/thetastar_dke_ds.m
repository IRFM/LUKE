function [XXthetastar1,XXthetastar2] = thetastar_dke_ds(equil,equil_fit,gridDKE,Zmomcoef,radialDKE)
%
%
% Calculation of the critical poloidal angle value theta_star for runaway avalanches
%
% INPUT:
%
%   - equil: magnetic equilibrium structure
%   - equil_fit: structure of the vectorial for of the magnetic equilibrium 
%   - gridDKE: grid structure
%   - Zmomcoef: momentum dynamics structure
%   - radialDKE: radial grid structure
%
% OUTPUT:
%
%   - XXthetastar1: poloidal angle value theta_star between 0 and pi [np,nmhu,nr]
%   - XXthetastar2: poloidal angle value theta_star between pi and 2*pi [np,nmhu,nr]
%
% by Y. PEYSSON (CEA/DRFC, yves.peysson@cea.fr) and D. SCHMITT (CEA/DRFC, damien.schmitt@cea.fr)
%
[equil_fit] = fitequil_yp(equil);%Vectorial form of the magnetic equilibrium
%
npn = size(gridDKE.XXmhu,1);
nmhu = size(gridDKE.XXmhu,2);
nr = size(gridDKE.XXmhu,3);
ntheta = length(equil.theta);
%
xpsin = radialDKE.xpsin_f;
%
XXB0 = permute(repmat(sqrt(equil.ptBx(:,1).^2 + equil.ptBy(:,1).^2 + equil.ptBPHI(:,1).^2),[1,npn,nmhu]),[2,3,1]);
XXBmax = permute(repmat(sqrt(equil.ptBx(:,(ntheta+1)/2).^2 + equil.ptBy(:,(ntheta+1)/2).^2 + equil.ptBPHI(:,(ntheta+1)/2).^2),[1,npn,nmhu]),[2,3,1]);
XXBstar = 2*XXB0./(1 + Zmomcoef.XXgamma.^2)./(1 - gridDKE.XXmhu.^2);
%
% *************** Put criterion that XXBstar >= XXB0 and XXBstar <= XXBmax**********************
%
options = optimset('Display','off');
%
for ip = 1:npn,
    for im = 1:nmhu,
        for ir =  1:nr,
            [thetas1,Bs1,flags1] = fsolve(@(theta) Bfit_dke_ds(theta,xpsin(ir),equil,equil_out,XXBstar(ip,im,ir)),pi/2);%Solution between [0,pi]
            [thetas2,Bs2,flags2] = fsolve(@(theta) Bfit_dke_ds(theta,xpsin(ir),equil,equil_out,XXBstar(ip,im,ir)),3*pi/2);%Solution between [pi,2*pi]
            if flags1 == 1, XXthetastar1(ip,im,ir) = thetas1; else XXthetastar1(ip,im,ir) = NaN; end
            if flags2 == 1, XXthetastar2(ip,im,ir) = thetas2; else XXthetastar2(ip,im,ir) = NaN; end
        end     
    end
end
%



