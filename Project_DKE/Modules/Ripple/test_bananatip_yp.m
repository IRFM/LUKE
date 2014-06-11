%
% Global parameters for the vectorial magnetic equilibrium
%
clear all
close all
clear functions
%
%load('/Users/yves/Projets/LUKE/Simulations/Examples/EAST/EAST_040235/040235_004000_ne_av=2p5/EQUIL_EAST_040235_004000.mat');
%load('/Users/yves/Projets/LUKE/Simulations/Examples/EAST/EAST_040235/040235_004000_ne_av=2p5/LUKE_DATA_EAST_040235_004000_C3PO_antenna_2p45Ghz_VLOOP.mat','output');
load('LUKE_RESULTS_WEST_149293_39.9683_ES_METIS_C3PO_C4_Npar_2.1.mat')
output = lukestructs.output;
equil = lukestructs.equil;
%
XXf0 = output.dke_out.XXf0{1};
psin = output.radialDKE.xpsin_f;
dpsin = output.radialDKE.xdpsin_f_dke;
mhu = output.momentumDKE.mhu;
pn = output.momentumDKE.pn;
mksa = output.mksa;
%
pn2dpn = output.momentumDKE.pn(:).*output.momentumDKE.pn(:).*output.momentumDKE.dpn(:);
%
ntheta = 71;
%
ripple = bananatip_yp(ntheta,psin,dpsin,pn,mhu,equil,XXf0,pn2dpn,mksa);
%
nR = 101;
nZ = 51;
nlevel = 11;
Ec = [mksa.Te_ref,20,100,200];%keV
%
R_tip = linspace(min(min(ripple.R_tip)),max(max(ripple.R_tip)),nR);
Z_tip = linspace(min(min(ripple.Z_tip)),max(max(ripple.Z_tip)),nZ);
%
XR_tip = R_tip(:)*ones(1,nZ);
XZ_tip = ones(nR,1)*Z_tip(:)';
%
maxDNeDphi_tip = max(max(max(ripple.DNeDphi_tip)));
%
for iEc = 1:length(Ec),
    XDNeDphi_tip = griddata(ripple.R_tip,ripple.Z_tip,squeeze(ripple.DNeDphi_tip(sum(ripple.Ec_tip < Ec(iEc)),:,:)),XR_tip,XZ_tip)';
    subplot(2,2,iEc),ax = graph2D_jd(XR_tip,XZ_tip,XDNeDphi_tip,'R (m)','Z(m)',['Number of electron banana tips @ ',num2str(ripple.Ec_tip(sum(ripple.Ec_tip < Ec(iEc)))),' (keV)'],NaN,NaN,1,NaN,nlevel);colorbar
end
%
disp(['Max number of electron banana tips (electron/rd) : ',num2str(maxDNeDphi_tip)])