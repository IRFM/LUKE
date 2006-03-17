function [hxr] = bremTSconvert_dke_yp(day,month,year);
%
% Convert old coodinate system used for DPSX (in partokyp.m for displaytt.m) in the new one used by DKE. Only useful for Tore Supra HXR diagnostic
% For other tokamak, use directly the correct system of coordinate. For
% Tore Supra use only
%
% INPUTS
%%       - day: calibration day (1-31) [1,1]
%       - month: calibration month (1-12) [1,1]
%       - year: calibration year (19** or 20**) [1,1]
%
% OUTPUTS
%
%       - hxr: HXR diagnostic parameter structure
%      
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 3,
    error('Not enough arguments in bremTSconvert_dke_yp')
end	
%	
[tok,Rp,ap,epsip,hp,Rm,Ri,ai,fi,nv,nv0,tv,kv,mv,sd,r1,r2,lc,lf,lfp,EG,kdiag,ef,tf,ea,ta,ec,tc,td,res,lod,lad,ed,lpm,phf,kd,Gain,Offset,pur,chordstatus] = partok_dke_yp('TS',day,month,year);
%
hxr.R_hxr = (Ri + ai*cos(tv*pi/180))/1000;% reference major radius (m)
hxr.Z_hxr = ai*sin(tv*pi/180)/1000;% reference vertical position (m)
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
