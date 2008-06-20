%******************************************** HARD X-RAY CONFIGURATION ********************************************
%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat
% 
%by Y.Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/IRFM, joan.decker@cea.fr)
%
clc
clear all
close all
%
hxr_id = 'TScirc';
%
Ri = 2360;ai = 800;fi = [1.0,0.0,0.0];
%
mv = [-90];
tv = [-90];
kv = [0];
%
sd = [2];
r1 = [5];
r2 = [5];
lc = 1*ones(1,1);
lf = 1000*ones(1,1);
lfp= 1000*ones(1,1);
kdiag = [20,40,60,80,100,120,140,160,50;40,60,80,100,120,140,160,180,110];
ef = [1];
tf = ['Al'];
ea = [0.4];
ta = ['Fe'];
ec = [0.5];
tc = ['Al'];
ed = [2];
lod = [5];
lad = [5];
lpm = [0];
td = ['CdTe'];
kd = ones(1,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parametres a peu pres adaptées aux spectres de 57Co et 241Am enregistrées en labo.
phf = ones(1,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parametres aà peu pres adapetés aux spectres de 57Co et 241Am enregistreés en labo.
res = ones(1,1)*[6,-0.9];%Parametres aà peu pres adapetés aux spectres de 57Co et 241Am enregistreés en labo.
Gain = [1];   
Offset = [0];
pur = [0];
chordstatus = [1];  
%			
EG = [1]*1e-3;%Etendue geéomeétrique petite camera
%
R_TS = (Ri + ai*cos(tv*pi/180))/1000;% reference major radius (m)
Z_TS = ai*sin(tv*pi/180)/1000;% reference vertical position (m)
%
L = [-4:1:4];%Chord length
R = zeros(length(mv),length(L));
Z = zeros(length(mv),length(L));
%
% Display Tore Supra chamber for chord arrangement
%
npoints = 1000;
theta = [0:(npoints-1) 0] * 2 * pi / npoints;
Rc = Ri/1000;
Zc = 0;
radius = ai/1000;
RR = (radius * cos(theta) + Rc * ones(1,npoints+1));
ZZ = (radius * sin(theta) + Zc * ones(1,npoints+1));
figure(1), plot(RR,ZZ,'r-');hold on
for chord = 1:length(mv),
	   R(chord,:) = R_TS(chord) + L*cos(mv(chord)*pi/180);
	   Z(chord,:) = Z_TS(chord) + L*sin(mv(chord)*pi/180);
end
plot(R',Z'),
hold off
axis('equal')
xlabel('R(m)');ylabel('Z(m)')
%
% Build 
%
hxr.R_hxr = R_TS;% reference major radius (m)
hxr.Z_hxr = Z_TS;% reference vertical position (m)
%
hxr.alpha_hxr = -kv*pi/180;%horizontal angle (with respect to R) [-pi...pi]. The negative sign comes from the fact that kv is defined in a direct frame, while alpha_hxr corresponds to an indirect frame
hxr.beta_hxr = pi/2 - mv*pi/180;%vertical angle (with respect to Z) [0...pi]
%
hxr.EG_hxr = EG*1e-6;%geometrical extend (m^2) [1,nchord]
%
hxr.kd_hxr = kd;% reference energies for the photofraction [m,p]
%
hxr.phf_hxr = phf;% photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
%
hxr.res_hxr = res;%fit parameters of the energy resolution of the detectors [m,2]
%
hxr.ef_hxr = ef;% thickness of the vacuum window (mm) [1,m]
%
hxr.tf_hxr = tf;% type of material for the vacuum window (Al ou Be) [1,m]
%
hxr.ea_hxr = ea;%thickness of the absorber (mm) [1,m]
%
hxr.ta_hxr = ta;%type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
%
hxr.ec_hxr = ec;%thickness of the detector shield (mm) [1,m]
%
hxr.tc_hxr = tc;%type of material for the detector shield (Al ou Be) [1,m]
%
hxr.ed_hxr = ed;%thickness of the detector (mm) [1,m]
%
hxr.td_hxr = td;%type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
hxr.kdiag_hxr = kdiag;%Measured photon energy spectrum (keV) [1,k]
%
hxr.kphot = [20:10:180];%Photon energy in keV
%
% HXR parameter
%
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);


