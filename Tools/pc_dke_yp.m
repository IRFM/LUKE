function [qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp
%
% Calculates the universal physics constants
% (see www.tcaep.co.uk/science/constant)
%
%   INPUTS: None
%
%
%   OUTPUTS:
%   
%   - qe : Absolute value of the electron charge (C)
%   - me : Electron rest mass (Kg)
%   - mp : Proton rest mass (Kg)
%   - mn : Neutron rest mass (Kg)
%   - e0 : Free space permeability (F/m)
%   - mu0 : Free space magnetic permeability (H/m)
%   - re : Classical electron radius (m)
%   - mc2 : Electron energy rest mass (keV)
%   - clum : Speed of light (m/s)
%   - alpha : Fine structure constant
%
% by Joan Decker <jodecker@mit.edu> (MIT/RLE) and Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
%
qe = 1.602176462e-19;%Absolute value of the electron charge (C)
me = 9.10938188e-31;%Electron rest mass (Kg)
mp = 1.67262158e-27;%Proton rest mass (Kg)
mn = 1.67492716e-27;%Neutron rest mass (Kg)
e0 = 8.854187818e-12;%Free space permittivity (F/m)
mu0 = 12.566370614e-7;%Free space permeability (F/m)
re = 2.817940285e-15;%Classical electron radius (m)
mc2 = 510.998902;%Electron energy rest mass (keV)
clum = 299792458;%Speed of light (m/s)
alpha = 7.297352533e-3;%Fine structure constant (~1/137)
   
