function [alpha_hxr,beta_hxr,R_hxr,Z_hxr,EG_hxr,kd_hxr,phf_hxr,res_hxr,ef_hxr,tf_hxr,ea_hxr,ta_hxr,ec_hxr,tc_hxr,ed_hxr,td_hxr,kdiag_hxr] = bremTSconvert_dke_yp(tokname,day,month,year);
%
% Convert old coodinate system used for DPSX (in partokyp.m for displaytt.m) in the new one used by DKE. Only useful for Tore Supra HXR diagnostic
% For other tokamak, use directly the correct system of coordinate
%
% INPUTS
%
%       - tokname: tokamak name [1,1]
%       - day: calibration day (1-31) [1,1]
%       - month: calibration month (1-12) [1,1]
%       - year: calibration year (19** or 20**) [1,1]
%
% OUTPUTS
%
%       - alpha_hxr: horizontal angle (with respect to R) [-pi...pi]
%       - beta_hxr: vertical angle (with respect to Z) [0...pi]
%       - R_hxr: reference major radius (m) [1,nchord]
%       - Z_hxr: reference vertical position (m) [1,nchord]
%       - EG_hxr: geometrical extend (m^2.str) [1,nchord]
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 4,
    error('Not enough arguments in bremTSconvert_dke_yp')
end	
%	
[tok,Rp,ap,epsip,hp,Rm,Ri,ai,fi,nv,nv0,tv,kv,mv,sd,r1,r2,lc,lf,lfp,EG,kdiag,ef,tf,ea,ta,ec,tc,td,res,lod,lad,ed,lpm,phf,kd,Gain,Offset,pur,chordstatus] = partok_dke_yp(tokname,day,month,year);
%
R_hxr = (Ri + ai*cos(tv*pi/180))/1000;% reference major radius (m)
Z_hxr = ai*sin(tv*pi/180)/1000;% reference vertical position (m)
%
alpha_hxr = -kv*pi/180;%horizontal angle (with respect to R) [-pi...pi]. The negative sign comes from the fact that kv is defined in a direct frame, while alpha_hxr corresponds to an indirect frame
beta_hxr = pi/2 - mv*pi/180;%vertical angle (with respect to Z) [0...pi]
%
EG_hxr = EG*1e-6;%geometrical extend (m^2) [1,nchord]
%
kd_hxr = kd;% reference energies for the photofraction [m,p]
%
phf_hxr = phf;% photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
%
res_hxr = res;%fit parameters of the energy resolution of the detectors [m,2]
%
ef_hxr = ef;% thickness of the vacuum window (mm) [1,m]
%
tf_hxr = tf;% type of material for the vacuum window (Al ou Be) [1,m]
%
ea_hxr = ea;%thickness of the absorber (mm) [1,m]
%
ta_hxr = ta;%type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
%
ec_hxr = ec;%thickness of the detector shield (mm) [1,m]
%
tc_hxr = tc;%type of material for the detector shield (Al ou Be) [1,m]
%
ed_hxr = ed;%thickness of the detector (mm) [1,m]
%
td_hxr = td;%type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
kdiag_hxr = kdiag;%Measured photon energy spectrum (keV) [1,k]
