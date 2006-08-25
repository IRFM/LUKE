function [] = testfitequil_yp(equil_in,equil_fit)
%
% Test the interpolated magnetic equilibrium
%
% INPUT
%    - equil_in: numerical magnetic equilibrium structure
%    - equil_fit: interpolated magnetic equilibrium structure
%
% OUTPUT: none
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
[equil_out] = equilibrium_jd(equil_in);
%
BP = sqrt(equil_out.XBR.^2 + equil_out.XBZ.^2);
r = sqrt((equil_out.XR - equil_out.Rp).^2 + (equil_out.XZ - equil_out.Zp).^2);
r(1,:) = eps;%to avoid singularity for cos(alpha) at psi = 0. 
BP(1,:) = eps;%to avoid singularity for cos(alpha) at psi = 0. 
calpha = (-equil_out.XBZ.*(equil_out.XR - equil_out.Rp) + equil_out.XBR.*(equil_out.XZ - equil_out.Zp))./r./BP;
salpha = (equil_out.XBZ.*(equil_out.XZ - equil_out.Zp) + equil_out.XBR.*(equil_out.XR - equil_out.Rp))./r./BP;
%
close all;
%
npsin_fit = 500;
ntheta_fit= length(equil_out.mtheta);%300;
%
psia = equil_fit.psia;
theta_fit = equil_out.mtheta';%linspace(0,2*pi,ntheta_fit)';
psin_fit = linspace(equil_out.xpsin(1),equil_out.xpsin(end),npsin_fit)';
rho_fit = interp1(equil_out.xpsin,equil_out.xrho,psin_fit)';
%
Te_fit = ppval(equil_fit.Te_fit.pp_f,psin_fit).';
Te_fit1 = ppval_yp(equil_fit.Te_fit.pp_f,psin_fit).';
%
ne_fit = ppval(equil_fit.ne_fit.pp_f,psin_fit).';
ne_fit1 = ppval_yp(equil_fit.ne_fit.pp_f,psin_fit).';
%
zTi_fit = ppval(equil_fit.zTi_fit.pp_f,psin_fit).';
zTi_fit1 = ppval_yp(equil_fit.zTi_fit.pp_f,psin_fit).';
%
zni_fit = ppval(equil_fit.zni_fit.pp_f,psin_fit).';
zni_fit1 = ppval_yp(equil_fit.zni_fit.pp_f,psin_fit).';
%
Zeff_fit = sum(zni_fit.*repmat((equil_fit.zZi.^2)',[1,npsin_fit]))./ne_fit;
Zeff_fit1 = sum(zni_fit1.*repmat((equil_fit.zZi.^2)',[1,npsin_fit]))./ne_fit1;
%
dTedpsin_fit = ppval(equil_fit.Te_fit.pp_dfdpsin,psin_fit).';
dTedpsin_fit1 = ppval_yp(equil_fit.Te_fit.pp_dfdpsin,psin_fit).';
%
dnedpsin_fit = ppval(equil_fit.ne_fit.pp_dfdpsin,psin_fit).';
dnedpsin_fit1 = ppval_yp(equil_fit.ne_fit.pp_dfdpsin,psin_fit).';
%
zdTidpsin_fit = ppval(equil_fit.zTi_fit.pp_dfdpsin,psin_fit).';
zdTidpsin_fit1 = ppval_yp(equil_fit.zTi_fit.pp_dfdpsin,psin_fit).';
%
zdnidpsin_fit = ppval(equil_fit.zni_fit.pp_dfdpsin,psin_fit).';
zdnidpsin_fit1 = ppval_yp(equil_fit.zni_fit.pp_dfdpsin,psin_fit).';
%
dZeffdpsin_fit = sum(zdnidpsin_fit.*repmat((equil_fit.zZi.^2)',[1,npsin_fit]))./ne_fit - dnedpsin_fit.*sum(zni_fit.*repmat((equil_fit.zZi.^2)',[1,npsin_fit]))./ne_fit./ne_fit;
dZeffdpsin_fit1 = sum(zdnidpsin_fit1.*repmat((equil_fit.zZi.^2)',[1,npsin_fit]))./ne_fit - dnedpsin_fit1.*sum(zni_fit1.*repmat((equil_fit.zZi.^2)',[1,npsin_fit]))./ne_fit1./ne_fit1;
%
psin_fit1 = equil_out.xpsin(1:10:end);%New normalized radial grid for display 2-D magnetic field
%
R_a0_fit = ppval(equil_fit.R_fit.pp_a0,psin_fit1);
R_an_fit = ppval(equil_fit.R_fit.pp_an,psin_fit1);
R_bn_fit = ppval(equil_fit.R_fit.pp_bn,psin_fit1);
R_da0dpsin_fit = ppval(equil_fit.R_fit.pp_da0dpsin,psin_fit1);
R_dandpsin_fit = ppval(equil_fit.R_fit.pp_dandpsin,psin_fit1);
R_dbndpsin_fit = ppval(equil_fit.R_fit.pp_dbndpsin,psin_fit1);
%
Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,psin_fit1);
Z_an_fit = ppval(equil_fit.Z_fit.pp_an,psin_fit1);
Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,psin_fit1);
Z_da0dpsin_fit = ppval(equil_fit.Z_fit.pp_da0dpsin,psin_fit1);
Z_dandpsin_fit = ppval(equil_fit.Z_fit.pp_dandpsin,psin_fit1);
Z_dbndpsin_fit = ppval(equil_fit.Z_fit.pp_dbndpsin,psin_fit1);
%
r_a0_fit = ppval(equil_fit.r_fit.pp_a0,psin_fit1);
r_an_fit = ppval(equil_fit.r_fit.pp_an,psin_fit1);
r_bn_fit = ppval(equil_fit.r_fit.pp_bn,psin_fit1);
r_da0dpsin_fit = ppval(equil_fit.r_fit.pp_da0dpsin,psin_fit1);
r_dandpsin_fit = ppval(equil_fit.r_fit.pp_dandpsin,psin_fit1);
r_dbndpsin_fit = ppval(equil_fit.r_fit.pp_dbndpsin,psin_fit1);
%
calpha_a0_fit = ppval(equil_fit.calpha_fit.pp_a0,psin_fit1);
calpha_an_fit = ppval(equil_fit.calpha_fit.pp_an,psin_fit1);
calpha_bn_fit = ppval(equil_fit.calpha_fit.pp_bn,psin_fit1);
calpha_da0dpsin_fit = ppval(equil_fit.calpha_fit.pp_da0dpsin,psin_fit1);
calpha_dandpsin_fit = ppval(equil_fit.calpha_fit.pp_dandpsin,psin_fit1);
calpha_dbndpsin_fit = ppval(equil_fit.calpha_fit.pp_dbndpsin,psin_fit1);
%
salpha_a0_fit = ppval(equil_fit.salpha_fit.pp_a0,psin_fit1);
salpha_an_fit = ppval(equil_fit.salpha_fit.pp_an,psin_fit1);
salpha_bn_fit = ppval(equil_fit.salpha_fit.pp_bn,psin_fit1);
salpha_da0dpsin_fit = ppval(equil_fit.salpha_fit.pp_da0dpsin,psin_fit1);
salpha_dandpsin_fit = ppval(equil_fit.salpha_fit.pp_dandpsin,psin_fit1);
salpha_dbndpsin_fit = ppval(equil_fit.salpha_fit.pp_dbndpsin,psin_fit1);
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,psin_fit1);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,psin_fit1);
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,psin_fit1);
BPHI_da0dpsin_fit = ppval(equil_fit.BPHI_fit.pp_da0dpsin,psin_fit1);
BPHI_dandpsin_fit = ppval(equil_fit.BPHI_fit.pp_dandpsin,psin_fit1);
BPHI_dbndpsin_fit = ppval(equil_fit.BPHI_fit.pp_dbndpsin,psin_fit1);
%
BP_a0_fit = ppval(equil_fit.BP_fit.pp_a0,psin_fit1);
BP_an_fit = ppval(equil_fit.BP_fit.pp_an,psin_fit1);
BP_bn_fit = ppval(equil_fit.BP_fit.pp_bn,psin_fit1);
BP_da0dpsin_fit = ppval(equil_fit.BP_fit.pp_da0dpsin,psin_fit1);
BP_dandpsin_fit = ppval(equil_fit.BP_fit.pp_dandpsin,psin_fit1);
BP_dbndpsin_fit = ppval(equil_fit.BP_fit.pp_dbndpsin,psin_fit1);
%
R_a0_fit1 = ppval_yp(equil_fit.R_fit.pp_a0,psin_fit1);
R_an_fit1 = ppval_yp(equil_fit.R_fit.pp_an,psin_fit1);
R_bn_fit1 = ppval_yp(equil_fit.R_fit.pp_bn,psin_fit1);
R_da0dpsin_fit1 = ppval_yp(equil_fit.R_fit.pp_da0dpsin,psin_fit1);
R_dandpsin_fit1 = ppval_yp(equil_fit.R_fit.pp_dandpsin,psin_fit1);
R_dbndpsin_fit1 = ppval_yp(equil_fit.R_fit.pp_dbndpsin,psin_fit1);
%
Z_a0_fit1 = ppval_yp(equil_fit.Z_fit.pp_a0,psin_fit1);
Z_an_fit1 = ppval_yp(equil_fit.Z_fit.pp_an,psin_fit1);
Z_bn_fit1 = ppval_yp(equil_fit.Z_fit.pp_bn,psin_fit1);
Z_da0dpsin_fit1 = ppval_yp(equil_fit.Z_fit.pp_da0dpsin,psin_fit1);
Z_dandpsin_fit1 = ppval_yp(equil_fit.Z_fit.pp_dandpsin,psin_fit1);
Z_dbndpsin_fit1 = ppval_yp(equil_fit.Z_fit.pp_dbndpsin,psin_fit1);
%
r_a0_fit1 = ppval_yp(equil_fit.r_fit.pp_a0,psin_fit1);
r_an_fit1 = ppval_yp(equil_fit.r_fit.pp_an,psin_fit1);
r_bn_fit1 = ppval_yp(equil_fit.r_fit.pp_bn,psin_fit1);
r_da0dpsin_fit1 = ppval_yp(equil_fit.r_fit.pp_da0dpsin,psin_fit1);
r_dandpsin_fit1 = ppval_yp(equil_fit.r_fit.pp_dandpsin,psin_fit1);
r_dbndpsin_fit1 = ppval_yp(equil_fit.r_fit.pp_dbndpsin,psin_fit1);
%
calpha_a0_fit1 = ppval_yp(equil_fit.calpha_fit.pp_a0,psin_fit1);
calpha_an_fit1 = ppval_yp(equil_fit.calpha_fit.pp_an,psin_fit1);
calpha_bn_fit1 = ppval_yp(equil_fit.calpha_fit.pp_bn,psin_fit1);
calpha_da0dpsin_fit1 = ppval_yp(equil_fit.calpha_fit.pp_da0dpsin,psin_fit1);
calpha_dandpsin_fit1 = ppval_yp(equil_fit.calpha_fit.pp_dandpsin,psin_fit1);
calpha_dbndpsin_fit1 = ppval_yp(equil_fit.calpha_fit.pp_dbndpsin,psin_fit1);
%
salpha_a0_fit1 = ppval_yp(equil_fit.salpha_fit.pp_a0,psin_fit1);
salpha_an_fit1 = ppval_yp(equil_fit.salpha_fit.pp_an,psin_fit1);
salpha_bn_fit1 = ppval_yp(equil_fit.salpha_fit.pp_bn,psin_fit1);
salpha_da0dpsin_fit1 = ppval_yp(equil_fit.salpha_fit.pp_da0dpsin,psin_fit1);
salpha_dandpsin_fit1 = ppval_yp(equil_fit.salpha_fit.pp_dandpsin,psin_fit1);
salpha_dbndpsin_fit1 = ppval_yp(equil_fit.salpha_fit.pp_dbndpsin,psin_fit1);
%
BPHI_a0_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_a0,psin_fit1);
BPHI_an_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_an,psin_fit1);
BPHI_bn_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_bn,psin_fit1);
BPHI_da0dpsin_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_da0dpsin,psin_fit1);
BPHI_dandpsin_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_dandpsin,psin_fit1);
BPHI_dbndpsin_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_dbndpsin,psin_fit1);
%
BP_a0_fit1 = ppval_yp(equil_fit.BP_fit.pp_a0,psin_fit1);
BP_an_fit1 = ppval_yp(equil_fit.BP_fit.pp_an,psin_fit1);
BP_bn_fit1 = ppval_yp(equil_fit.BP_fit.pp_bn,psin_fit1);
BP_da0dpsin_fit1 = ppval_yp(equil_fit.BP_fit.pp_da0dpsin,psin_fit1);
BP_dandpsin_fit1 = ppval_yp(equil_fit.BP_fit.pp_dandpsin,psin_fit1);
BP_dbndpsin_fit1 = ppval_yp(equil_fit.BP_fit.pp_dbndpsin,psin_fit1);

% Build interpolated magnetic fields
%
for ii = 1:ntheta_fit,
   R_fit(:,ii) = R_a0_fit + R_an_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
   dRdtheta_fit(:,ii) = -R_an_fit*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_bn_fit*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
   dRdpsin_fit(:,ii) = R_da0dpsin_fit + R_dandpsin_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_dbndpsin_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
%
   Z_fit(:,ii) = Z_a0_fit + Z_an_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -Z_an_fit*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_bn_fit*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
   dZdpsin_fit(:,ii) = Z_da0dpsin_fit + Z_dandpsin_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_dbndpsin_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
%
   r_fit(:,ii) = r_a0_fit + r_an_fit*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_bn_fit*sin(equil_fit.r_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -r_an_fit*(equil_fit.r_fit.n.*sin(equil_fit.r_fit.n*theta_fit(ii))) + r_bn_fit*(equil_fit.r_fit.n.*cos(equil_fit.r_fit.n*theta_fit(ii)));
   dZdpsin_fit(:,ii) = r_da0dpsin_fit + r_dandpsin_fit*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_dbndpsin_fit*sin(equil_fit.r_fit.n*theta_fit(ii));
%
   calpha_fit(:,ii) = calpha_a0_fit + calpha_an_fit*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_bn_fit*sin(equil_fit.calpha_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -calpha_an_fit*(equil_fit.calpha_fit.n.*sin(equil_fit.calpha_fit.n*theta_fit(ii))) + calpha_bn_fit*(equil_fit.calpha_fit.n.*cos(equil_fit.calpha_fit.n*theta_fit(ii)));
   dZdpsin_fit(:,ii) = calpha_da0dpsin_fit + calpha_dandpsin_fit*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_dbndpsin_fit*sin(equil_fit.calpha_fit.n*theta_fit(ii));
%
   salpha_fit(:,ii) = salpha_a0_fit + salpha_an_fit*cos(equil_fit.salpha_fit.n*theta_fit(ii)) + salpha_bn_fit*sin(equil_fit.salpha_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -salpha_an_fit*(equil_fit.salpha_fit.n.*sin(equil_fit.salpha_fit.n*theta_fit(ii))) + salpha_bn_fit*(equil_fit.salpha_fit.n.*cos(equil_fit.salpha_fit.n*theta_fit(ii)));
   dZdpsin_fit(:,ii) = salpha_da0dpsin_fit + salpha_dandpsin_fit*cos(equil_fit.salpha_fit.n*theta_fit(ii)) + salpha_dbndpsin_fit*sin(equil_fit.salpha_fit.n*theta_fit(ii));
%
   BPHI_fit(:,ii) = BPHI_a0_fit + BPHI_an_fit*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_bn_fit*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
   dBPHIdtheta_fit(:,ii) = -BPHI_an_fit*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta_fit(ii))) + BPHI_bn_fit*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta_fit(ii)));
   dBPHIdpsin_fit(:,ii) = BPHI_da0dpsin_fit + BPHI_dandpsin_fit*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_dbndpsin_fit*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
%
   BP_fit(:,ii) = BP_a0_fit + BP_an_fit*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_bn_fit*sin(equil_fit.BP_fit.n*theta_fit(ii));
   dBPdtheta_fit(:,ii) = -BP_an_fit*(equil_fit.BP_fit.n.*sin(equil_fit.BP_fit.n*theta_fit(ii))) + BP_bn_fit*(equil_fit.BP_fit.n.*cos(equil_fit.BP_fit.n*theta_fit(ii)));
   dBPdpsin_fit(:,ii) = BP_da0dpsin_fit + BP_dandpsin_fit*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_dbndpsin_fit*sin(equil_fit.BP_fit.n*theta_fit(ii));
%
   R_fit1(:,ii) = R_a0_fit1 + R_an_fit1*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit1*sin(equil_fit.R_fit.n*theta_fit(ii));
   dRdtheta_fit1(:,ii) = -R_an_fit1*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_bn_fit1*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
   dRdpsin_fit1(:,ii) = R_da0dpsin_fit1 + R_dandpsin_fit1*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_dbndpsin_fit1*sin(equil_fit.R_fit.n*theta_fit(ii));
%
   Z_fit1(:,ii) = Z_a0_fit1 + Z_an_fit1*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit1*sin(equil_fit.Z_fit.n*theta_fit(ii));
   dZdtheta_fit1(:,ii) = -Z_an_fit1*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_bn_fit1*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
   dZdpsin_fit1(:,ii) = Z_da0dpsin_fit1 + Z_dandpsin_fit1*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_dbndpsin_fit1*sin(equil_fit.Z_fit.n*theta_fit(ii));
%
   r_fit1(:,ii) = r_a0_fit1 + r_an_fit1*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_bn_fit1*sin(equil_fit.r_fit.n*theta_fit(ii));
   drdtheta_fit1(:,ii) = -r_an_fit1*(equil_fit.r_fit.n.*sin(equil_fit.r_fit.n*theta_fit(ii))) + r_bn_fit1*(equil_fit.r_fit.n.*cos(equil_fit.r_fit.n*theta_fit(ii)));
   drdpsin_fit1(:,ii) = r_da0dpsin_fit1 + r_dandpsin_fit1*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_dbndpsin_fit1*sin(equil_fit.r_fit.n*theta_fit(ii));
%
   calpha_fit1(:,ii) = calpha_a0_fit1 + calpha_an_fit1*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_bn_fit1*sin(equil_fit.calpha_fit.n*theta_fit(ii));
   dcalphadtheta_fit1(:,ii) = -calpha_an_fit1*(equil_fit.calpha_fit.n.*sin(equil_fit.calpha_fit.n*theta_fit(ii))) + calpha_bn_fit1*(equil_fit.calpha_fit.n.*cos(equil_fit.calpha_fit.n*theta_fit(ii)));
   dcalphadpsin_fit1(:,ii) = calpha_da0dpsin_fit1 + calpha_dandpsin_fit1*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_dbndpsin_fit1*sin(equil_fit.calpha_fit.n*theta_fit(ii));
%
   salpha_fit1(:,ii) = salpha_a0_fit1 + salpha_an_fit1*cos(equil_fit.salpha_fit.n*theta_fit(ii)) + salpha_bn_fit1*sin(equil_fit.salpha_fit.n*theta_fit(ii));
   dsalphadtheta_fit1(:,ii) = -salpha_an_fit1*(equil_fit.salpha_fit.n.*sin(equil_fit.salpha_fit.n*theta_fit(ii))) + salpha_bn_fit1*(equil_fit.salpha_fit.n.*cos(equil_fit.salpha_fit.n*theta_fit(ii)));
   dsalphadpsin_fit1(:,ii) = salpha_da0dpsin_fit1 + salpha_dandpsin_fit1*cos(equil_fit.salpha_fit.n*theta_fit(ii)) + salpha_dbndpsin_fit1*sin(equil_fit.salpha_fit.n*theta_fit(ii));
%
   BPHI_fit1(:,ii) = BPHI_a0_fit1 + BPHI_an_fit1*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_bn_fit1*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
   dBPHIdtheta_fit1(:,ii) = -BPHI_an_fit1*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta_fit(ii))) + BPHI_bn_fit1*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta_fit(ii)));
   dBPHIdpsin_fit1(:,ii) = BPHI_da0dpsin_fit1 + BPHI_dandpsin_fit1*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_dbndpsin_fit1*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
%
   BP_fit1(:,ii) = BP_a0_fit1 + BP_an_fit1*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_bn_fit1*sin(equil_fit.BP_fit.n*theta_fit(ii));
   dBPdtheta_fit1(:,ii) = -BP_an_fit1*(equil_fit.BP_fit.n.*sin(equil_fit.BP_fit.n*theta_fit(ii))) + BP_bn_fit1*(equil_fit.BP_fit.n.*cos(equil_fit.BP_fit.n*theta_fit(ii)));
   dBPdpsin_fit1(:,ii) = BP_da0dpsin_fit1 + BP_dandpsin_fit1*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_dbndpsin_fit1*sin(equil_fit.BP_fit.n*theta_fit(ii));
end
%
% Display results
%
figure('Name','Magnetic equilibrium profile parameters'),clf
set(gcf,'units','inches','position',[0.5,1,10,6]);
set(gca,'position',[0,0,1,1]);
%
subplot('position',[1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,psin_fit,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','b',2);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xpsin(1:10:end),0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'none','+','r',2);
subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,Te_fit,0,0,'\psi','T_e (keV)',equil_out.tokname,NaN,[0,1],[-eps,max(equil_out.xTe)],'-','none','b',2);
[ax] = graph1D_jd(rho_fit,Te_fit1,0,0,'\psi','T_e (keV)',equil_out.tokname,NaN,[0,1],[-eps,max(equil_out.xTe)],'-','none','c',1);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xTe(1:10:end),0,0,'\rho','T_e (keV)',equil_out.tokname,NaN,[0,1],[-eps,max(equil_out.xTe)],'none','+','r',2);
subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,ne_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_out.xne/1e19)],'-','none','b',2);
[ax] = graph1D_jd(rho_fit,ne_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_out.xne/1e19)],'-','none','c',1);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xne(1:10:end)/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(equil_out.xne/1e19)],'none','+','r',2);
subplot('position',[1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,zTi_fit,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_out.xzTi))],'-','none','b',2);
[ax] = graph1D_jd(rho_fit,zTi_fit1,0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_out.xzTi))],'-','none','c',1);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xzTi(:,1:10:end),0,0,'\rho','T_i (keV)','',NaN,[0,1],[-eps,max(max(equil_out.xzTi))],'none','+','r',2);
subplot('position',[1/3+1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,zni_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_out.xzni/1e19))],'-','none','b',2);
[ax] = graph1D_jd(rho_fit,zni_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_out.xzni/1e19))],'-','none','c',1);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xzni(:,1:10:end)/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,[0,1],[-eps,max(max(equil_out.xzni/1e19))],'none','+','r',2);
subplot('position',[2/3+1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,Zeff_fit,0,0,'\rho','Z_{eff}','',NaN,[0,1],[-eps,max(equil_out.xZeff)],'-','none','b',2);
[ax] = graph1D_jd(rho_fit,Zeff_fit1,0,0,'\rho','Z_{eff}','',NaN,[0,1],[-eps,max(equil_out.xZeff)],'-','none','c',1);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xZeff(1:10:end),0,0,'\rho','Z_{eff}','',NaN,[0,1],[-eps,max(equil_out.xZeff)],'none','+','r',2);
%
figure('Name','Derivatives of magnetic equilibrium profile parameters'),clf
set(gcf,'units','inches','position',[0.5,1,10,6]);
set(gca,'position',[0,0,1,1]);
%
subplot('position',[1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,psin_fit,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','b',2);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xpsin(1:10:end),0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'none','+','r',2);
subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,dTedpsin_fit,0,0,'\rho','T_e (keV)',equil_out.tokname,NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,dTedpsin_fit1,0,0,'\rho','T_e (keV)',equil_out.tokname,NaN,NaN,NaN,'-','none','c',1);
xdTedpsin = gradient(equil_out.xTe)./gradient(equil_out.xpsin);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xdTedpsin(1:10:end),0,0,'\rho','dT_ed/\psi_n (keV)',equil_out.tokname,NaN,NaN,NaN,'none','+','r',2);
subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,dnedpsin_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,dnedpsin_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','c',1);
xdnedpsin = gradient(equil_out.xne)./gradient(equil_out.xpsin);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xdnedpsin(1:10:end)/1e19,0,0,'\rho','dn_e/d\psi_n (10^{19} m^{-3})','',NaN,NaN,NaN,'none','+','r',2);
subplot('position',[1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,zdTidpsin_fit,0,0,'\rho','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,zdTidpsin_fit1,0,0,'\rho','','',NaN,NaN,NaN,'-','none','c',1);
xzdTidpsin = gradient(equil_out.xzTi)./(ones(size(equil_out.xzTi,1),1)*gradient(equil_out.xpsin)');
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xzdTidpsin(:,1:10:end),0,0,'\rho','dT_i/d\psi_n (keV)','',NaN,NaN,NaN,'none','+','r',2);
subplot('position',[1/3+1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,zdnidpsin_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,zdnidpsin_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','c',1);
xzdnidpsin = gradient(equil_out.xzni)./(ones(size(equil_out.xzTi,1),1)*gradient(equil_out.xpsin)');
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xzdnidpsin(:,1:10:end)/1e19,0,0,'\rho','dn_i/d\psi_n (10^{19} m^{-3})','',NaN,NaN,NaN,'none','+','r',2);
subplot('position',[2/3+1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,dZeffdpsin_fit,0,0,'\rho','dZ_{eff}/d\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,dZeffdpsin_fit1,0,0,'\rho','dZ_{eff}/d\psi_n','',NaN,NaN,NaN,'-','none','c',1);
xdZeffdpsin = gradient(equil_out.xZeff)./gradient(equil_out.xpsin);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xdZeffdpsin(1:10:end),0,0,'\rho','dZ_{eff}/d\psi_n','',NaN,NaN,NaN,'none','+','r',2);
%
% Magnetic equilibrium coordinates
%
figure('Name','R coordinate'),
[ax] = graph1D_jd(theta_fit,R_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,R_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,equil_out.XR(1:10:end,:),0,0,'\theta (rd)','R (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Z coordinate'),
[ax] = graph1D_jd(theta_fit,Z_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,Z_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,equil_out.XZ(1:10:end,:),0,0,'\theta (rd)','Z (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
% Magnetic equilibrium quantities 
%
figure('Name','r position'),
[ax] = graph1D_jd(theta_fit,r_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,r_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,r(1:10:end,:),0,0,'\theta (rd)','r (m)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','cos(alpha)'),
[ax] = graph1D_jd(theta_fit,calpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,calpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,calpha(1:10:end,:),0,0,'\theta (rd)','cos(\alpha)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','sin(alpha)'),
[ax] = graph1D_jd(theta_fit,salpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,salpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,salpha(1:10:end,:),0,0,'\theta (rd)','sin(\alpha)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','cos^2(alpha)+sin^2(alpha)'),
[ax] = graph1D_jd(theta_fit,salpha_fit.^2 + calpha_fit.^2,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,salpha_fit1.^2 + calpha_fit1.^2,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,salpha(1:10:end,:).^2 + calpha(1:10:end,:).^2,0,0,'\theta (rd)','sin(\alpha)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
%Magnetic fields
%
figure('Name','Toroidal magnetic field'),
[ax] = graph1D_jd(theta_fit,BPHI_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,BPHI_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,equil_out.XBphi(1:10:end,:),0,0,'\theta (rd)','B_{\phi} (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Poloidal magnetic field'),
[ax] = graph1D_jd(theta_fit,BP_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,BP_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,sqrt(equil_out.XBR(1:10:end,:).^2 + equil_out.XBZ(1:10:end,:).^2),0,0,'\theta (rd)','B_P (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
%Magnetic fields derivatives along psi and theta
%
[dXBphidtheta,dXBphidpsi] = gradient(equil_out.XBphi);%Toroidal magnetic field
%dxpsi = gradient(equil_out.xpsin*equil_out.psia);
dxpsin = gradient(equil_out.xpsin);
dtheta = gradient(equil_out.mtheta);
dXBphidtheta = dXBphidtheta./(ones(length(dxpsin),1)*dtheta);
dXBphidpsin = dXBphidpsi./(dxpsin*ones(1,length(dtheta)));
%
[dXBPdtheta,dXBPdpsi] = gradient(sqrt(equil_out.XBR.^2 + equil_out.XBZ.^2));%Poroidal magnetic field
dXBPdtheta = dXBPdtheta./(ones(length(dxpsin),1)*dtheta);
dXBPdpsin = dXBPdpsi./(dxpsin*ones(1,length(dtheta)));
%
figure('Name','Toroidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPHIdpsin_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPHIdpsin_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBphidpsin(1:10:end,:),0,0,'\theta (rd)','dB_{\phi}/d\psi (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Toroidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPHIdtheta_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPHIdtheta_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBphidtheta(1:10:end,:),0,0,'\theta (rd)','dB_{\phi}/d\theta (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Poloidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPdpsin_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPdpsin_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBPdpsin(1:10:end,:),0,0,'\theta (rd)','dB_P/d\psi (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Poloidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPdtheta_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPdtheta_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBPdtheta(1:10:end,:),0,0,'\theta (rd)','dB_P/d\theta (T)','Blue: ppval interp., Cyan: ppval_{yp} interp.',NaN,NaN,NaN,'--','none','r',1);
%
Rmin = min(min(equil_in.R));
Rmax = max(max(equil_in.R));
Zmin = min(min(equil_in.Z));
Zmax = max(max(equil_in.Z));
%
figure('Name','Magnetic equilibrium flux surface contour')
% 
[ax] = graph1D_jd(equil_out.XR(1:10:end,1:20:end),equil_out.XZ(1:10:end,1:20:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);drawnow
[ax] = graph1D_jd(equil_out.XR(1:10:end,:)',equil_out.XZ(1:10:end,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);
%
[ax] = graph1D_jd(R_fit(1:10:end,1:20:end),Z_fit(1:10:end,1:20:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
[ax] = graph1D_jd(R_fit(:,:)',Z_fit(:,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);
%
[ax] = graph1D_jd(R_fit1(1:10:end,1:20:end),Z_fit1(1:10:end,1:20:end),0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','c',1);drawnow
[ax] = graph1D_jd(R_fit1(:,:)',Z_fit1(:,:)',0,0,'R(m)','Z(m)','Flux-surfaces labeled by \rho=0,0.1,0.2...1',NaN,[Rmin,Rmax],[Zmin,Zmax],'--','none','c',1);
axis('equal');drawnow  
%
% Output for comparison with C raytracing_yp.c
%
psin = 0.25;
theta = 0.2;
%
Te = ppval(equil_fit.Te_fit.pp_f,psin);
dTedpsin = ppval_yp(equil_fit.Te_fit.pp_dfdpsin,psin);
ne = ppval(equil_fit.ne_fit.pp_f,psin);
dnedpsin = ppval_yp(equil_fit.ne_fit.pp_dfdpsin,psin);
zTi = ppval(equil_fit.zTi_fit.pp_f,psin);
dzTidpsin = ppval_yp(equil_fit.zTi_fit.pp_dfdpsin,psin);
zni = ppval(equil_fit.zni_fit.pp_f,psin);
dznidpsin = ppval_yp(equil_fit.zni_fit.pp_dfdpsin,psin);
%
R_a0 = ppval(equil_fit.R_fit.pp_a0,psin);
R_an = ppval(equil_fit.R_fit.pp_an,psin);
R_bn = ppval(equil_fit.R_fit.pp_bn,psin);
R_da0dpsin = ppval(equil_fit.R_fit.pp_da0dpsin,psin);
R_dandpsin = ppval(equil_fit.R_fit.pp_dandpsin,psin);
R_dbndpsin = ppval(equil_fit.R_fit.pp_dbndpsin,psin);
R = R_a0 + R_an'*cos(equil_fit.R_fit.n*theta) + R_bn'*sin(equil_fit.R_fit.n*theta);
dRdtheta = -R_an'*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta)) + R_bn'*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta));
dRdpsin = R_da0dpsin + R_dandpsin'*cos(equil_fit.R_fit.n*theta) + R_dbndpsin'*sin(equil_fit.R_fit.n*theta);
%
r_a0 = ppval(equil_fit.r_fit.pp_a0,psin);
r_an = ppval(equil_fit.r_fit.pp_an,psin);
r_bn = ppval(equil_fit.r_fit.pp_bn,psin);
r_da0dpsin = ppval(equil_fit.r_fit.pp_da0dpsin,psin);
r_dandpsin = ppval(equil_fit.r_fit.pp_dandpsin,psin);
r_dbndpsin = ppval(equil_fit.r_fit.pp_dbndpsin,psin);
r = r_a0 + r_an'*cos(equil_fit.r_fit.n*theta) + r_bn'*sin(equil_fit.r_fit.n*theta);
drdtheta = -r_an'*(equil_fit.r_fit.n.*sin(equil_fit.r_fit.n*theta)) + r_bn'*(equil_fit.r_fit.n.*cos(equil_fit.r_fit.n*theta));
drdpsin = r_da0dpsin + r_dandpsin'*cos(equil_fit.r_fit.n*theta) + r_dbndpsin'*sin(equil_fit.r_fit.n*theta);
%
BPHI_a0 = ppval(equil_fit.BPHI_fit.pp_a0,psin);
BPHI_an = ppval(equil_fit.BPHI_fit.pp_an,psin);
BPHI_bn = ppval(equil_fit.BPHI_fit.pp_bn,psin);
BPHI_da0dpsin = ppval(equil_fit.BPHI_fit.pp_da0dpsin,psin);
BPHI_dandpsin = ppval(equil_fit.BPHI_fit.pp_dandpsin,psin);
BPHI_dbndpsin = ppval(equil_fit.BPHI_fit.pp_dbndpsin,psin);
BPHI = BPHI_a0 + BPHI_an'*cos(equil_fit.BPHI_fit.n*theta) + BPHI_bn'*sin(equil_fit.BPHI_fit.n*theta);
dBPHIdtheta = -BPHI_an'*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta)) + BPHI_bn'*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta));
dBPHIdpsin = BPHI_da0dpsin + BPHI_dandpsin'*cos(equil_fit.BPHI_fit.n*theta) + BPHI_dbndpsin'*sin(equil_fit.BPHI_fit.n*theta);
%
BP_a0 = ppval(equil_fit.BP_fit.pp_a0,psin);
BP_an = ppval(equil_fit.BP_fit.pp_an,psin);
BP_bn = ppval(equil_fit.BP_fit.pp_bn,psin);
BP_da0dpsin = ppval(equil_fit.BP_fit.pp_da0dpsin,psin);
BP_dandpsin = ppval(equil_fit.BP_fit.pp_dandpsin,psin);
BP_dbndpsin = ppval(equil_fit.BP_fit.pp_dbndpsin,psin);
BP = BP_a0 + BP_an'*cos(equil_fit.BP_fit.n*theta) + BP_bn'*sin(equil_fit.BP_fit.n*theta);
dBPdtheta = -BP_an'*(equil_fit.BP_fit.n.*sin(equil_fit.BP_fit.n*theta)) + BP_bn'*(equil_fit.BP_fit.n.*cos(equil_fit.BP_fit.n*theta));
dBPdpsin = BP_da0dpsin + BP_dandpsin'*cos(equil_fit.BP_fit.n*theta) + BP_dbndpsin'*sin(equil_fit.BP_fit.n*theta);
%
calpha_a0 = ppval(equil_fit.calpha_fit.pp_a0,psin);
calpha_an = ppval(equil_fit.calpha_fit.pp_an,psin);
calpha_bn = ppval(equil_fit.calpha_fit.pp_bn,psin);
calpha_da0dpsin = ppval(equil_fit.calpha_fit.pp_da0dpsin,psin);
calpha_dandpsin = ppval(equil_fit.calpha_fit.pp_dandpsin,psin);
calpha_dbndpsin = ppval(equil_fit.calpha_fit.pp_dbndpsin,psin);
calpha = calpha_a0 + calpha_an'*cos(equil_fit.calpha_fit.n*theta) + calpha_bn'*sin(equil_fit.calpha_fit.n*theta);
dcalphadtheta = -calpha_an'*(equil_fit.calpha_fit.n.*sin(equil_fit.calpha_fit.n*theta)) + calpha_bn'*(equil_fit.calpha_fit.n.*cos(equil_fit.calpha_fit.n*theta));
dcalphadpsin = calpha_da0dpsin + calpha_dandpsin'*cos(equil_fit.calpha_fit.n*theta) + calpha_dbndpsin'*sin(equil_fit.calpha_fit.n*theta);
%
salpha_a0 = ppval(equil_fit.salpha_fit.pp_a0,psin);
salpha_an = ppval(equil_fit.salpha_fit.pp_an,psin);
salpha_bn = ppval(equil_fit.salpha_fit.pp_bn,psin);
salpha_da0dpsin = ppval(equil_fit.salpha_fit.pp_da0dpsin,psin);
salpha_dandpsin = ppval(equil_fit.salpha_fit.pp_dandpsin,psin);
salpha_dbndpsin = ppval(equil_fit.salpha_fit.pp_dbndpsin,psin);
salpha = salpha_a0 + salpha_an'*cos(equil_fit.salpha_fit.n*theta) + salpha_bn'*sin(equil_fit.salpha_fit.n*theta);
dsalphadtheta = -salpha_an'*(equil_fit.salpha_fit.n.*sin(equil_fit.salpha_fit.n*theta)) + salpha_bn'*(equil_fit.salpha_fit.n.*cos(equil_fit.salpha_fit.n*theta));
dsalphadpsin = salpha_da0dpsin + salpha_dandpsin'*cos(equil_fit.salpha_fit.n*theta) + salpha_dbndpsin'*sin(equil_fit.salpha_fit.n*theta);
%
disp(['equil_fit.zZi(4) = ',num2str(equil_fit.zZi(4))]);
disp('--------------');
disp(['equil_fit.Te_fit.pp_f.coefs(1) = ',num2str(equil_fit.Te_fit.pp_f.coefs(1))]);
disp(['equil_fit.Te_fit.pp_dfdpsin.coefs(1) = ',num2str(equil_fit.Te_fit.pp_dfdpsin.coefs(1))]);
disp(['equil_fit.BPHI_fit.n = ',num2str(equil_fit.BPHI_fit.n(1))]);
disp(['equil_fit.BPHI_fit.bn_f.coefs(1) = ',num2str(equil_fit.BPHI_fit.pp_bn.coefs(1))]);
disp(['equil_fit.BPHI_fit.bn_f.coefs(1) = ',num2str(equil_fit.BPHI_fit.pp_dbndpsin.coefs(1))]);
disp('--------------');
disp(['Te(0.25),dTedpsin(0.25) (keV) = ',num2str(Te),',',num2str(dTedpsin)]);
disp(['ne(0.25),dnedpsin(0.25) (10+19 m-3) = ',num2str(ne/1e19),',',num2str(dnedpsin/1e19)]);
disp(['zTi(2,0.25),dzTidpsin(2,0.25) (keV) = ',num2str(zTi(2)),',',num2str(dzTidpsin(2))]);
disp(['zni(2,0.25),dznidpsin(2,0.25) (10+19 m-3) = ',num2str(zni(2)/1e19),',',num2str(dznidpsin(2)/1e19)]);
disp(['R(0.25,0.2),dRdpsin(0.25,0.2),dRdtheta(0.25,0.2) (T) = ',num2str(R),',',num2str(dRdpsin),',',num2str(dRdtheta)]);
disp(['r(0.25,0.2),drdpsin(0.25,0.2),drdtheta(0.25,0.2) (T) = ',num2str(r),',',num2str(drdpsin),',',num2str(drdtheta)]);
disp(['BPHI(0.25,0.2),dBPHIdpsin(0.25,0.2),dBPHIdtheta(0.25,0.2) (T) = ',num2str(BPHI),',',num2str(dBPHIdpsin),',',num2str(dBPHIdtheta)]);
disp(['BP(0.25,0.2),dBPdpsin(0.25,0.2),dBPdtheta(0.25,0.2) (T) = ',num2str(BP),',',num2str(dBPdpsin),',',num2str(dBPdtheta)]);
disp(['calpha(0.25,0.2),dcalphadpsin(0.25,0.2),dcalphadtheta(0.25,0.2) (T) = ',num2str(calpha),',',num2str(dcalphadpsin),',',num2str(dcalphadtheta)]);
disp(['salpha(0.25,0.2),dsalphadpsin(0.25,0.2),dsalphadtheta(0.25,0.2) (T) = ',num2str(salpha),',',num2str(dsalphadpsin),',',num2str(dsalphadtheta)]);


