function [alpha_hxr,beta_hxr,R_hxr,Z_hxr,EG_hxr] = bremTSconvert_dke_yp(day,month,year);
%
% Convert old coodinate system used for DPSX (in partokyp.m for displaytt.m) in the new one used by DKE. Only useful for Tore Supra HXR diagnostic
% For other tokamak, use directly the correct system of coordinate
%
% INPUTS
%
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
if nargin < 3,
    error('Not enough arguments in bremTSconvert_dke_yp')
end	
%	
[tok,Rp,ap,epsip,hp,Rm,Ri,ai,fi,nv,nv0,tv,kv,mv,sd,r1,r2,lc,lf,lfp,EG,kdiag,ef,tf,ea,ta,ec,tc,td,res,lod,lad,ed,lpm,phf,kd,Gain,Offset,pur,chordstatus] = partokyp('TS',day,month,year);
%
R_hxr = (Ri + ai*cos(tv*pi/180))/1000;% reference major radius (m)
Z_hxr = ai*sin(tv*pi/180)/1000;% reference vertical position (m)
%
alpha_hxr = kv*pi/180;%horizontal angle (with respect to R) [-pi...pi]
beta_hxr = pi/2 - mv*pi/180;%vertical angle (with respect to Z) [0...pi]
%
EG_hxr = EG*1e-6;%geometrical extend (m^2) [1,nchord]
