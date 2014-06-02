%
% Global parameters for the vectorial magnetic equilibrium
%
clear all
close all
clear functions
%
load('/Users/yves/Projets/LUKE/Simulations/Examples/EAST/EAST_040235/040235_004000_ne_av=2p5/EQUIL_EAST_040235_004000.mat');
load('/Users/yves/Projets/LUKE/Simulations/Examples/EAST/EAST_040235/040235_004000_ne_av=2p5/LUKE_DATA_EAST_040235_004000_C3PO_antenna_2p45Ghz_VLOOP.mat','output');
%
XXf0 = output.dke_out.XXf0{1};
psin = output.radialDKE.xpsin_f;
mhu = output.momentumDKE.mhu;
pn = output.momentumDKE.pn;
mksa = output.mksa;
%
ntheta = 71;
%
ripple = bananatip_yp(ntheta,psin,pn,mhu,equil,XXf0,mksa);
%
