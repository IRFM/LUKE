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
%
close all;
%
npsi_fit = 500;
ntheta_fit= length(equil_out.mtheta);%300;
%
theta_fit = equil_out.mtheta';%linspace(0,2*pi,ntheta_fit)';
psi_fit = linspace(equil_out.xpsin(1),equil_out.xpsin(end)*equil_out.psia,npsi_fit)';
rho_fit = interp1(equil_out.xpsin,equil_out.xrho,psi_fit/equil_out.psia)';
%
Te_fit = ppval(equil_fit.Te_fit.pp_f,psi_fit).';
Te_fit1 = ppval_yp(equil_fit.Te_fit.pp_f,psi_fit).';
%
ne_fit = ppval(equil_fit.ne_fit.pp_f,psi_fit).';
ne_fit1 = ppval_yp(equil_fit.ne_fit.pp_f,psi_fit).';
%
zTi_fit = ppval(equil_fit.zTi_fit.pp_f,psi_fit).';
zTi_fit1 = ppval_yp(equil_fit.zTi_fit.pp_f,psi_fit).';
%
zni_fit = ppval(equil_fit.zni_fit.pp_f,psi_fit).';
zni_fit1 = ppval_yp(equil_fit.zni_fit.pp_f,psi_fit).';
%
Zeff_fit = sum(zni_fit.*repmat((equil_fit.zZi.^2)',[1,npsi_fit]))./ne_fit;
Zeff_fit1 = sum(zni_fit1.*repmat((equil_fit.zZi.^2)',[1,npsi_fit]))./ne_fit1;
%
dTedpsi_fit = ppval(equil_fit.Te_fit.pp_dfdpsi,psi_fit).';
dTedpsi_fit1 = ppval_yp(equil_fit.Te_fit.pp_dfdpsi,psi_fit).';
%
dnedpsi_fit = ppval(equil_fit.ne_fit.pp_dfdpsi,psi_fit).';
dnedpsi_fit1 = ppval_yp(equil_fit.ne_fit.pp_dfdpsi,psi_fit).';
%
zdTidpsi_fit = ppval(equil_fit.zTi_fit.pp_dfdpsi,psi_fit).';
zdTidpsi_fit1 = ppval_yp(equil_fit.zTi_fit.pp_dfdpsi,psi_fit).';
%
zdnidpsi_fit = ppval(equil_fit.zni_fit.pp_dfdpsi,psi_fit).';
zdnidpsi_fit1 = ppval_yp(equil_fit.zni_fit.pp_dfdpsi,psi_fit).';
%
dZeffdpsi_fit = sum(zdnidpsi_fit.*repmat((equil_fit.zZi.^2)',[1,npsi_fit]))./ne_fit - dnedpsi_fit.*sum(zni_fit.*repmat((equil_fit.zZi.^2)',[1,npsi_fit]))./ne_fit./ne_fit;
dZeffdpsi_fit1 = sum(zdnidpsi_fit1.*repmat((equil_fit.zZi.^2)',[1,npsi_fit]))./ne_fit - dnedpsi_fit1.*sum(zni_fit1.*repmat((equil_fit.zZi.^2)',[1,npsi_fit]))./ne_fit1./ne_fit1;
%
psi_fit1 = equil_out.xpsin(1:10:end)*equil_out.psia;%New grid for display 2-D magnetic field
%
R_a0_fit = ppval(equil_fit.R_fit.pp_a0,psi_fit1);
R_an_fit = ppval(equil_fit.R_fit.pp_an,psi_fit1);
R_bn_fit = ppval(equil_fit.R_fit.pp_bn,psi_fit1);
R_da0dpsi_fit = ppval(equil_fit.R_fit.pp_da0dpsi,psi_fit1);
R_dandpsi_fit = ppval(equil_fit.R_fit.pp_dandpsi,psi_fit1);
R_dbndpsi_fit = ppval(equil_fit.R_fit.pp_dbndpsi,psi_fit1);
%
Z_a0_fit = ppval(equil_fit.Z_fit.pp_a0,psi_fit1);
Z_an_fit = ppval(equil_fit.Z_fit.pp_an,psi_fit1);
Z_bn_fit = ppval(equil_fit.Z_fit.pp_bn,psi_fit1);
Z_da0dpsi_fit = ppval(equil_fit.Z_fit.pp_da0dpsi,psi_fit1);
Z_dandpsi_fit = ppval(equil_fit.Z_fit.pp_dandpsi,psi_fit1);
Z_dbndpsi_fit = ppval(equil_fit.Z_fit.pp_dbndpsi,psi_fit1);
%
r_a0_fit = ppval(equil_fit.r_fit.pp_a0,psi_fit1);
r_an_fit = ppval(equil_fit.r_fit.pp_an,psi_fit1);
r_bn_fit = ppval(equil_fit.r_fit.pp_bn,psi_fit1);
r_da0dpsi_fit = ppval(equil_fit.r_fit.pp_da0dpsi,psi_fit1);
r_dandpsi_fit = ppval(equil_fit.r_fit.pp_dandpsi,psi_fit1);
r_dbndpsi_fit = ppval(equil_fit.r_fit.pp_dbndpsi,psi_fit1);
%
calpha_a0_fit = ppval(equil_fit.calpha_fit.pp_a0,psi_fit1);
calpha_an_fit = ppval(equil_fit.calpha_fit.pp_an,psi_fit1);
calpha_bn_fit = ppval(equil_fit.calpha_fit.pp_bn,psi_fit1);
calpha_da0dpsi_fit = ppval(equil_fit.calpha_fit.pp_da0dpsi,psi_fit1);
calpha_dandpsi_fit = ppval(equil_fit.calpha_fit.pp_dandpsi,psi_fit1);
calpha_dbndpsi_fit = ppval(equil_fit.calpha_fit.pp_dbndpsi,psi_fit1);
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,psi_fit1);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,psi_fit1);
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,psi_fit1);
BPHI_da0dpsi_fit = ppval(equil_fit.BPHI_fit.pp_da0dpsi,psi_fit1);
BPHI_dandpsi_fit = ppval(equil_fit.BPHI_fit.pp_dandpsi,psi_fit1);
BPHI_dbndpsi_fit = ppval(equil_fit.BPHI_fit.pp_dbndpsi,psi_fit1);
%
BP_a0_fit = ppval(equil_fit.BP_fit.pp_a0,psi_fit1);
BP_an_fit = ppval(equil_fit.BP_fit.pp_an,psi_fit1);
BP_bn_fit = ppval(equil_fit.BP_fit.pp_bn,psi_fit1);
BP_da0dpsi_fit = ppval(equil_fit.BP_fit.pp_da0dpsi,psi_fit1);
BP_dandpsi_fit = ppval(equil_fit.BP_fit.pp_dandpsi,psi_fit1);
BP_dbndpsi_fit = ppval(equil_fit.BP_fit.pp_dbndpsi,psi_fit1);
%
R_a0_fit1 = ppval_yp(equil_fit.R_fit.pp_a0,psi_fit1);
R_an_fit1 = ppval_yp(equil_fit.R_fit.pp_an,psi_fit1);
R_bn_fit1 = ppval_yp(equil_fit.R_fit.pp_bn,psi_fit1);
R_da0dpsi_fit1 = ppval_yp(equil_fit.R_fit.pp_da0dpsi,psi_fit1);
R_dandpsi_fit1 = ppval_yp(equil_fit.R_fit.pp_dandpsi,psi_fit1);
R_dbndpsi_fit1 = ppval_yp(equil_fit.R_fit.pp_dbndpsi,psi_fit1);
%
Z_a0_fit1 = ppval_yp(equil_fit.Z_fit.pp_a0,psi_fit1);
Z_an_fit1 = ppval_yp(equil_fit.Z_fit.pp_an,psi_fit1);
Z_bn_fit1 = ppval_yp(equil_fit.Z_fit.pp_bn,psi_fit1);
Z_da0dpsi_fit1 = ppval_yp(equil_fit.Z_fit.pp_da0dpsi,psi_fit1);
Z_dandpsi_fit1 = ppval_yp(equil_fit.Z_fit.pp_dandpsi,psi_fit1);
Z_dbndpsi_fit1 = ppval_yp(equil_fit.Z_fit.pp_dbndpsi,psi_fit1);
%
r_a0_fit1 = ppval_yp(equil_fit.r_fit.pp_a0,psi_fit1);
r_an_fit1 = ppval_yp(equil_fit.r_fit.pp_an,psi_fit1);
r_bn_fit1 = ppval_yp(equil_fit.r_fit.pp_bn,psi_fit1);
r_da0dpsi_fit1 = ppval_yp(equil_fit.r_fit.pp_da0dpsi,psi_fit1);
r_dandpsi_fit1 = ppval_yp(equil_fit.r_fit.pp_dandpsi,psi_fit1);
r_dbndpsi_fit1 = ppval_yp(equil_fit.r_fit.pp_dbndpsi,psi_fit1);
%
calpha_a0_fit1 = ppval_yp(equil_fit.calpha_fit.pp_a0,psi_fit1);
calpha_an_fit1 = ppval_yp(equil_fit.calpha_fit.pp_an,psi_fit1);
calpha_bn_fit1 = ppval_yp(equil_fit.calpha_fit.pp_bn,psi_fit1);
calpha_da0dpsi_fit1 = ppval_yp(equil_fit.calpha_fit.pp_da0dpsi,psi_fit1);
calpha_dandpsi_fit1 = ppval_yp(equil_fit.calpha_fit.pp_dandpsi,psi_fit1);
calpha_dbndpsi_fit1 = ppval_yp(equil_fit.calpha_fit.pp_dbndpsi,psi_fit1);
%
BPHI_a0_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_a0,psi_fit1);
BPHI_an_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_an,psi_fit1);
BPHI_bn_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_bn,psi_fit1);
BPHI_da0dpsi_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_da0dpsi,psi_fit1);
BPHI_dandpsi_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_dandpsi,psi_fit1);
BPHI_dbndpsi_fit1 = ppval_yp(equil_fit.BPHI_fit.pp_dbndpsi,psi_fit1);
%
BP_a0_fit1 = ppval_yp(equil_fit.BP_fit.pp_a0,psi_fit1);
BP_an_fit1 = ppval_yp(equil_fit.BP_fit.pp_an,psi_fit1);
BP_bn_fit1 = ppval_yp(equil_fit.BP_fit.pp_bn,psi_fit1);
BP_da0dpsi_fit1 = ppval_yp(equil_fit.BP_fit.pp_da0dpsi,psi_fit1);
BP_dandpsi_fit1 = ppval_yp(equil_fit.BP_fit.pp_dandpsi,psi_fit1);
BP_dbndpsi_fit1 = ppval_yp(equil_fit.BP_fit.pp_dbndpsi,psi_fit1);

% Build interpolated magnetic fields
%
for ii = 1:ntheta_fit,
   R_fit(:,ii) = R_a0_fit + R_an_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
   dRdtheta_fit(:,ii) = -R_an_fit*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_bn_fit*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
   dRdpsi_fit(:,ii) = R_da0dpsi_fit + R_dandpsi_fit*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_dbndpsi_fit*sin(equil_fit.R_fit.n*theta_fit(ii));
%
   Z_fit(:,ii) = Z_a0_fit + Z_an_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -Z_an_fit*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_bn_fit*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
   dZdpsi_fit(:,ii) = Z_da0dpsi_fit + Z_dandpsi_fit*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_dbndpsi_fit*sin(equil_fit.Z_fit.n*theta_fit(ii));
%
   r_fit(:,ii) = r_a0_fit + r_an_fit*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_bn_fit*sin(equil_fit.r_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -r_an_fit*(equil_fit.r_fit.n.*sin(equil_fit.r_fit.n*theta_fit(ii))) + r_bn_fit*(equil_fit.r_fit.n.*cos(equil_fit.r_fit.n*theta_fit(ii)));
   dZdpsi_fit(:,ii) = r_da0dpsi_fit + r_dandpsi_fit*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_dbndpsi_fit*sin(equil_fit.r_fit.n*theta_fit(ii));
%
   calpha_fit(:,ii) = calpha_a0_fit + calpha_an_fit*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_bn_fit*sin(equil_fit.calpha_fit.n*theta_fit(ii));
   dZdtheta_fit(:,ii) = -calpha_an_fit*(equil_fit.calpha_fit.n.*sin(equil_fit.calpha_fit.n*theta_fit(ii))) + calpha_bn_fit*(equil_fit.calpha_fit.n.*cos(equil_fit.calpha_fit.n*theta_fit(ii)));
   dZdpsi_fit(:,ii) = calpha_da0dpsi_fit + calpha_dandpsi_fit*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_dbndpsi_fit*sin(equil_fit.calpha_fit.n*theta_fit(ii));
%
   BPHI_fit(:,ii) = BPHI_a0_fit + BPHI_an_fit*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_bn_fit*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
   dBPHIdtheta_fit(:,ii) = -BPHI_an_fit*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta_fit(ii))) + BPHI_bn_fit*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta_fit(ii)));
   dBPHIdpsi_fit(:,ii) = BPHI_da0dpsi_fit + BPHI_dandpsi_fit*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_dbndpsi_fit*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
%
   BP_fit(:,ii) = BP_a0_fit + BP_an_fit*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_bn_fit*sin(equil_fit.BP_fit.n*theta_fit(ii));
   dBPdtheta_fit(:,ii) = -BP_an_fit*(equil_fit.BP_fit.n.*sin(equil_fit.BP_fit.n*theta_fit(ii))) + BP_bn_fit*(equil_fit.BP_fit.n.*cos(equil_fit.BP_fit.n*theta_fit(ii)));
   dBPdpsi_fit(:,ii) = BP_da0dpsi_fit + BP_dandpsi_fit*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_dbndpsi_fit*sin(equil_fit.BP_fit.n*theta_fit(ii));
%
   R_fit1(:,ii) = R_a0_fit1 + R_an_fit1*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_bn_fit1*sin(equil_fit.R_fit.n*theta_fit(ii));
   dRdtheta_fit1(:,ii) = -R_an_fit1*(equil_fit.R_fit.n.*sin(equil_fit.R_fit.n*theta_fit(ii))) + R_bn_fit1*(equil_fit.R_fit.n.*cos(equil_fit.R_fit.n*theta_fit(ii)));
   dRdpsi_fit1(:,ii) = R_da0dpsi_fit1 + R_dandpsi_fit1*cos(equil_fit.R_fit.n*theta_fit(ii)) + R_dbndpsi_fit1*sin(equil_fit.R_fit.n*theta_fit(ii));
%
   Z_fit1(:,ii) = Z_a0_fit1 + Z_an_fit1*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_bn_fit1*sin(equil_fit.Z_fit.n*theta_fit(ii));
   dZdtheta_fit1(:,ii) = -Z_an_fit1*(equil_fit.Z_fit.n.*sin(equil_fit.Z_fit.n*theta_fit(ii))) + Z_bn_fit1*(equil_fit.Z_fit.n.*cos(equil_fit.Z_fit.n*theta_fit(ii)));
   dZdpsi_fit1(:,ii) = Z_da0dpsi_fit1 + Z_dandpsi_fit1*cos(equil_fit.Z_fit.n*theta_fit(ii)) + Z_dbndpsi_fit1*sin(equil_fit.Z_fit.n*theta_fit(ii));
%
   r_fit1(:,ii) = r_a0_fit1 + r_an_fit1*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_bn_fit1*sin(equil_fit.r_fit.n*theta_fit(ii));
   dZdtheta_fit1(:,ii) = -r_an_fit1*(equil_fit.r_fit.n.*sin(equil_fit.r_fit.n*theta_fit(ii))) + r_bn_fit1*(equil_fit.r_fit.n.*cos(equil_fit.r_fit.n*theta_fit(ii)));
   dZdpsi_fit1(:,ii) = r_da0dpsi_fit1 + r_dandpsi_fit1*cos(equil_fit.r_fit.n*theta_fit(ii)) + r_dbndpsi_fit1*sin(equil_fit.r_fit.n*theta_fit(ii));
%
   calpha_fit1(:,ii) = calpha_a0_fit1 + calpha_an_fit1*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_bn_fit1*sin(equil_fit.calpha_fit.n*theta_fit(ii));
   dZdtheta_fit1(:,ii) = -calpha_an_fit1*(equil_fit.calpha_fit.n.*sin(equil_fit.calpha_fit.n*theta_fit(ii))) + calpha_bn_fit1*(equil_fit.calpha_fit.n.*cos(equil_fit.calpha_fit.n*theta_fit(ii)));
   dZdpsi_fit1(:,ii) = calpha_da0dpsi_fit1 + calpha_dandpsi_fit1*cos(equil_fit.calpha_fit.n*theta_fit(ii)) + calpha_dbndpsi_fit1*sin(equil_fit.calpha_fit.n*theta_fit(ii));
%
   BPHI_fit1(:,ii) = BPHI_a0_fit1 + BPHI_an_fit1*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_bn_fit1*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
   dBPHIdtheta_fit1(:,ii) = -BPHI_an_fit1*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta_fit(ii))) + BPHI_bn_fit1*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta_fit(ii)));
   dBPHIdpsi_fit1(:,ii) = BPHI_da0dpsi_fit1 + BPHI_dandpsi_fit1*cos(equil_fit.BPHI_fit.n*theta_fit(ii)) + BPHI_dbndpsi_fit1*sin(equil_fit.BPHI_fit.n*theta_fit(ii));
%
   BP_fit1(:,ii) = BP_a0_fit1 + BP_an_fit1*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_bn_fit1*sin(equil_fit.BP_fit.n*theta_fit(ii));
   dBPdtheta_fit1(:,ii) = -BP_an_fit1*(equil_fit.BP_fit.n.*sin(equil_fit.BP_fit.n*theta_fit(ii))) + BP_bn_fit1*(equil_fit.BP_fit.n.*cos(equil_fit.BP_fit.n*theta_fit(ii)));
   dBPdpsi_fit1(:,ii) = BP_da0dpsi_fit1 + BP_dandpsi_fit1*cos(equil_fit.BP_fit.n*theta_fit(ii)) + BP_dbndpsi_fit1*sin(equil_fit.BP_fit.n*theta_fit(ii));
end
%
% Display results
%
figure('Name','Magnetic equilibrium profile parameters'),clf
set(gcf,'units','inches','position',[0.5,1,10,6]);
set(gca,'position',[0,0,1,1]);
%
subplot('position',[1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,psi_fit/equil_out.psia,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','b',2);
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
[ax] = graph1D_jd(rho_fit,psi_fit/equil_out.psia,0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'-','none','b',2);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),equil_out.xpsin(1:10:end),0,0,'\rho','\psi_n','',NaN,[0,1],[-eps,1],'none','+','r',2);
subplot('position',[1/3+1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,dTedpsi_fit,0,0,'\psi','T_e (keV)',equil_out.tokname,NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,dTedpsi_fit1,0,0,'\psi','T_e (keV)',equil_out.tokname,NaN,NaN,NaN,'-','none','c',1);
xdTedpsi = gradient(equil_out.xTe)./gradient(equil_out.xpsin*equil_out.psia);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xdTedpsi(1:10:end),0,0,'\rho','dT_ed/\psi (keV)',equil_out.tokname,NaN,NaN,NaN,'none','+','r',2);
subplot('position',[2/3+1/12,0.5+1/16,5/24,5/16])
[ax] = graph1D_jd(rho_fit,dnedpsi_fit/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,dnedpsi_fit1/1e19,0,0,'\rho','n_e (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','c',1);
xdnedpsi = gradient(equil_out.xne)./gradient(equil_out.xpsin*equil_out.psia);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xdnedpsi(1:10:end)/1e19,0,0,'\rho','dn_e/d\psi (10^{19} m^{-3})','',NaN,NaN,NaN,'none','+','r',2);
subplot('position',[1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,zdTidpsi_fit,0,0,'\rho','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,zdTidpsi_fit1,0,0,'\rho','','',NaN,NaN,NaN,'-','none','c',1);
xzdTidpsi = gradient(equil_out.xzTi)./(ones(size(equil_out.xzTi,1),1)*gradient(equil_out.xpsin*equil_out.psia)');
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xzdTidpsi(:,1:10:end),0,0,'\rho','dT_i/d\psi (keV)','',NaN,NaN,NaN,'none','+','r',2);
subplot('position',[1/3+1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,zdnidpsi_fit/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,zdnidpsi_fit1/1e19,0,0,'\rho','n_i (10^{19} m^{-3})','',NaN,NaN,NaN,'-','none','c',1);
xzdnidpsi = gradient(equil_out.xzni)./(ones(size(equil_out.xzTi,1),1)*gradient(equil_out.xpsin*equil_out.psia)');
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xzdnidpsi(:,1:10:end)/1e19,0,0,'\rho','dn_i/d\psi (10^{19} m^{-3})','',NaN,NaN,NaN,'none','+','r',2);
subplot('position',[2/3+1/12,1/8,5/24,5/16])
[ax] = graph1D_jd(rho_fit,dZeffdpsi_fit,0,0,'\rho','dZ_{eff}/d\psi','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(rho_fit,dZeffdpsi_fit1,0,0,'\rho','dZ_{eff}/d\psi','',NaN,NaN,NaN,'-','none','c',1);
xdZeffdpsi = gradient(equil_out.xZeff)./gradient(equil_out.xpsin*equil_out.psia);
[ax] = graph1D_jd(equil_out.xrho(1:10:end),xdZeffdpsi(1:10:end),0,0,'\rho','dZ_{eff}/d\psi','',NaN,NaN,NaN,'none','+','r',2);
%
% Magnetic equilibrium coordinates
%
figure('Name','R coordinate'),
[ax] = graph1D_jd(theta_fit,R_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,R_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,equil_out.XR(1:10:end,:),0,0,'\theta (rd)','R (m)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Z coordinate'),
[ax] = graph1D_jd(theta_fit,Z_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,Z_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,equil_out.XZ(1:10:end,:),0,0,'\theta (rd)','Z (m)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
% Magnetic equilibrium quantities 
%
figure('Name','r position'),
[ax] = graph1D_jd(theta_fit,r_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,r_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,r(1:10:end,:),0,0,'\theta (rd)','r (m)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','cos(alpha)'),
[ax] = graph1D_jd(theta_fit,calpha_fit,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,calpha_fit1,0,0,'','','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,calpha(1:10:end,:),0,0,'\theta (rd)','cos(\alpha)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
%Magnetic fields
%
figure('Name','Toroidal magnetic field'),
[ax] = graph1D_jd(theta_fit,BPHI_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,BPHI_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,equil_out.XBphi(1:10:end,:),0,0,'\theta (rd)','B_{\phi} (T)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Poloidal magnetic field'),
[ax] = graph1D_jd(theta_fit,BP_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,BP_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,sqrt(equil_out.XBR(1:10:end,:).^2 + equil_out.XBZ(1:10:end,:).^2),0,0,'\theta (rd)','B_P (T)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
%Magnetic fields derivatives along psi and theta
%
[dXBphidtheta,dXBphidpsi] = gradient(equil_out.XBphi);%Toroidal magnetic field
dxpsi = gradient(equil_out.xpsin*equil_out.psia);
dtheta = gradient(equil_out.mtheta);
dXBphidtheta = dXBphidtheta./(ones(length(dxpsi),1)*dtheta);
dXBphidpsi = dXBphidpsi./(dxpsi*ones(1,length(dtheta)));
%
[dXBPdtheta,dXBPdpsi] = gradient(sqrt(equil_out.XBR.^2 + equil_out.XBZ.^2));%Poroidal magnetic field
dXBPdtheta = dXBPdtheta./(ones(length(dxpsi),1)*dtheta);
dXBPdpsi = dXBPdpsi./(dxpsi*ones(1,length(dtheta)));
%
figure('Name','Toroidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPHIdpsi_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPHIdpsi_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBphidpsi(1:10:end,:),0,0,'\theta (rd)','dB_{\phi}/d\psi (T)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Toroidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPHIdtheta_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPHIdtheta_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBphidtheta(1:10:end,:),0,0,'\theta (rd)','dB_{\phi}/d\theta (T)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Poloidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPdpsi_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPdpsi_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBPdpsi(1:10:end,:),0,0,'\theta (rd)','dB_P/d\psi (T)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
%
figure('Name','Poloidal magnetic field'),
[ax] = graph1D_jd(theta_fit,dBPdtheta_fit,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','b',2);
[ax] = graph1D_jd(theta_fit,dBPdtheta_fit1,0,0,'\rho','\psi_n','',NaN,NaN,NaN,'-','none','c',1);
[ax] = graph1D_jd(equil_out.mtheta,dXBPdtheta(1:10:end,:),0,0,'\theta (rd)','dB_P/d\theta (T)','Blue: ppval interp., Cyan: ppval_yp interp.',NaN,NaN,NaN,'--','none','r',1);
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
psi = 0.25;
theta = 1.7;
%
Te = ppval(equil_fit.Te_fit.pp_f,psi);
dTedpsi = ppval_yp(equil_fit.Te_fit.pp_dfdpsi,psi);
zni = ppval(equil_fit.zni_fit.pp_f,psi);
dznidpsi = ppval_yp(equil_fit.zni_fit.pp_dfdpsi,psi);
BPHI_a0 = ppval(equil_fit.BPHI_fit.pp_a0,psi);
BPHI_an = ppval(equil_fit.BPHI_fit.pp_an,psi);
BPHI_bn = ppval(equil_fit.BPHI_fit.pp_bn,psi);
BPHI_da0dpsi = ppval(equil_fit.BPHI_fit.pp_da0dpsi,psi);
BPHI_dandpsi = ppval(equil_fit.BPHI_fit.pp_dandpsi,psi);
BPHI_dbndpsi = ppval(equil_fit.BPHI_fit.pp_dbndpsi,psi);
BPHI = BPHI_a0 + BPHI_an'*cos(equil_fit.BPHI_fit.n*theta) + BPHI_bn'*sin(equil_fit.BPHI_fit.n*theta);
dBPHIdtheta = -BPHI_an'*(equil_fit.BPHI_fit.n.*sin(equil_fit.BPHI_fit.n*theta)) + BPHI_bn'*(equil_fit.BPHI_fit.n.*cos(equil_fit.BPHI_fit.n*theta));
dBPHIdpsi = BPHI_da0dpsi + BPHI_dandpsi'*cos(equil_fit.BPHI_fit.n*theta) + BPHI_dbndpsi'*sin(equil_fit.BPHI_fit.n*theta);
%
disp(['equil_fit.Te_fit.pp_f.coefs(1) = ',num2str(equil_fit.Te_fit.pp_f.coefs(1))]);
disp(['equil_fit.zZi(4) = ',num2str(equil_fit.zZi(4))]);
disp(['Te(0.25),dTdpsi(0.25) (keV) = ',num2str(Te),',',num2str(dTedpsi)]);
disp(['zni(2,0.25),dznidpsi(2,0.25) (10+19 m-3) = ',num2str(zni(2)/1e19),',',num2str(dznidpsi(2)/1e19)]);
disp(['BPHI(0.25,1.7),dTdpsi(0.25,1.7) (T) = ',num2str(BPHI),',',num2str(dBPHIdpsi),',',num2str(dBPHIdtheta)]);


