function [Zmomcoef] = momentumcoefbuilder_dke_yp(gridDKE,mksa)
%
%   Calculate basic momentum coefficients for the 3D electron relativistic drift kinetic solver.
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;%Universal physics constants
%
z = mksa.betath_ref*gridDKE.pn;
z2 = z.*z;
z3 = z2.*z;
zm = mksa.betath_ref*gridDKE.pnm;
z2m = zm.*zm;
zp = mksa.betath_ref*gridDKE.pnp;
z2p = zp.*zp;
xz = z'*ones(1,length(z));
xz2 = xz.*xz;
xz3 = xz2.*xz;
%
gamma = sqrt(1 + z2);
gamma2 = gamma.*gamma;
gammam = sqrt(1 + z2m);
gamma2m = gammam.*gammam;
gammap = sqrt(1 + z2p);
gamma2p = gammap.*gammap;
xgamma = gamma'*ones(1,length(gamma));
xgamma2 = xgamma.*xgamma;
Xgamma = gamma'*ones(1,gridDKE.nmhu);
XXgamma = repmat(Xgamma,[1,1,gridDKE.nr]);
Xgammam = gammam'*ones(1,gridDKE.nmhu);
XXgammam = repmat(Xgammam,[1,1,gridDKE.nr]);
Xgammap = gammap'*ones(1,gridDKE.nmhu);
XXgammap = repmat(Xgammap,[1,1,gridDKE.nr]);
%
gammamm = [1,gamma(1:gridDKE.npn-1)];
gammapp = [gamma(2:gridDKE.npn),gamma(gridDKE.npn)];
Xgammamm = gammamm'*ones(1,gridDKE.nmhu);
Xgammapp = gammapp'*ones(1,gridDKE.nmhu);
XXgammamm = repmat(Xgammamm,[1,1,gridDKE.nr]);
XXgammapp = repmat(Xgammapp,[1,1,gridDKE.nr]);
%
sigma = asinh(z);
sigmam = asinh(zm);
sigmap = asinh(zp);
xsigma = sigma'*ones(1,length(sigma));
%
J1 = -3*gamma + sigma.*(3.0./z + 2*z);
J2 = gamma - sigma./z -2*gamma.*z2/3;
J3 = -3*gamma.*sigma./z2 + 3.0./z + z - 2*z2.*z/5;
J4 = gamma.*sigma.*(15.0./z2 + 6) - 15.0./z - 11*z;
xJ1 = -3*xgamma + xsigma.*(3.0./xz + 2*xz);
xJ2 = xgamma - xsigma./xz - 2*xgamma.*xz2/3;
xJ3 = -3*xgamma.*xsigma./xz2 + 3.0./xz + xz - 2*xz2.*xz/5;
xJ4 = xgamma.*xsigma.*(15.0./xz2 + 6) - 15.0./xz - 11*xz;
%
v = gridDKE.pn./gamma;
v2 = v.*v;
vm = gridDKE.pnm./gammam;
v2m = vm.*vm;
vp = gridDKE.pnp./gammap;
v2p = vp.*vp;
xv = v'*ones(1,length(v));
xv2 = xv.*xv;
Xv = v'*ones(1,gridDKE.nmhu);
%
% Fill structure gridDKE for output
%
Zmomcoef.z = z;
Zmomcoef.z2 = z2;
Zmomcoef.z3 = z3;
Zmomcoef.zm = zm;
Zmomcoef.z2m = z2m;
Zmomcoef.zp = zp;
Zmomcoef.z2p = z2p;
Zmomcoef.xz = xz;
Zmomcoef.xz2 = xz2;
Zmomcoef.xz3 = xz3;
%
Zmomcoef.gamma = gamma;
Zmomcoef.gamma2 = gamma2;
Zmomcoef.gammam = gammam;
Zmomcoef.gamma2m = gamma2m;
Zmomcoef.gammap = gammap;
Zmomcoef.gamma2p = gamma2p;
Zmomcoef.xgamma = xgamma;
Zmomcoef.xgamma2 = xgamma2;
Zmomcoef.Xgamma = Xgamma;
Zmomcoef.XXgamma = XXgamma;
Zmomcoef.Xgammam = Xgammam;
Zmomcoef.XXgammam = XXgammam;
Zmomcoef.Xgammap = Xgammap;
Zmomcoef.XXgammap = XXgammap;
%
Zmomcoef.gammamm = gammamm;
Zmomcoef.gammapp = gammapp;
Zmomcoef.Xgammamm = Xgammamm;
Zmomcoef.Xgammapp = Xgammapp;
Zmomcoef.XXgammamm = XXgammamm;
Zmomcoef.XXgammapp = XXgammapp;
%
Zmomcoef.sigma = sigma;
Zmomcoef.sigmam = sigmam;
Zmomcoef.sigmap = sigmap;
Zmomcoef.xsigma = xsigma;
%
Zmomcoef.J1 = J1;
Zmomcoef.J2 = J2;
Zmomcoef.J3 = J3;
Zmomcoef.J4 = J4;
Zmomcoef.xJ1 = xJ1;
Zmomcoef.xJ2 = xJ2;
Zmomcoef.xJ3 = xJ3;
Zmomcoef.xJ4 = xJ4;
%
Zmomcoef.v = v;
Zmomcoef.v2 = v2;
Zmomcoef.vm = vm;
Zmomcoef.v2m = v2m;
Zmomcoef.vp = vp;
Zmomcoef.v2p = v2p;
Zmomcoef.xv = xv;
Zmomcoef.xv2 = xv2;
Zmomcoef.Xv = Xv;
%
Zmomcoef.Xpnpar = gridDKE.Xpn.*gridDKE.Xmhu;
Zmomcoef.Xpnperp2 = gridDKE.Xpn2 - Zmomcoef.Xpnpar.*Zmomcoef.Xpnpar;
Zmomcoef.Xvpar = (v'*ones(1,gridDKE.nmhu)).*(ones(length(v),1)*gridDKE.mhu);
%
Zmomcoef.Ec_ref = mc2*(sqrt(1 + gridDKE.pn.*gridDKE.pn*mksa.betath_ref^2) - 1);%Fast electron kinetic energy in keV
Ec_ref_S = mc2*(sqrt(1 + gridDKE.pn_S.*gridDKE.pn_S*mksa.betath_ref^2) - 1);%Fast electron kinetic energy in keV
Zmomcoef.dEc_ref = diff(Ec_ref_S);%Fast electron kinetic energy in keV


