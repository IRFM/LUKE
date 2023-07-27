function [M,Z0,symbol,neutral_ground_state] = spinmultiplicity_yp(Z,nonist)
%
%   Calculation of atomic spin multiplicity and orbital quantum number for 
%   all ionization ground state of an atom with atomic number Z. 
%   To be used by DFT or MCDHF programs to calculate the
%   atomic electron density like GAUSSIAN and GRASP2018. Use Hund's rules (valid for
%   low-Z elements, NIST data otherwise. If NIST data are not available,
%   Hund's rule are applied for specific shells
%
%   INPUTS:
%
%       - Z : atomic number [1,1]
%       - nonist : force Hund's rules if NIST data are not available
%
%   OUTPUTS:
%
%       - M : spin multiplicity [1,Z]
%       - L : azimuthal quantum number [1,Z]
%       - Z0 : ionization states including neutral atom [1,Z+1]
%       - symbol : atom symbol [1,n]
%       - neutral_ground_state : ground state for neutral atom [1,m]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, K. Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
if nargin < 1
    error('Error: not enough input arguments in spinmultiplicity_yp.m.')
else
    %
    if Z > 83
        error('Error: maximum Z value is 83.')
    else
        if nargin == 1
            nonist = 0;
        end
    end
    %
end
%
Z0 = [0:1:Z-1];
N = Z - Z0;
%
elements.Z = [1:1:83];
elements.symbol = {'H','He','Li','Be','B','C','N','O','F','Ne','Na','Mg','Al','Si','P','S','Cl','Ar','K','Ca','Sc','Ti','V','Cr','Mn','Fe',...
            'Co','Ni','Cu','Zn','Ga','Ge','As','Se','Br','Kr','Rb','Sr','Y','Zr','Nb','Mo','Tc','Ru','Rh','Pd','Ag','Cd','In','Sn','Sb','Te','I','Xe',...
            'Cs','Ba','La','Ce','Pr','Nd','Pm','Sm','Eu','Gd','Tb','Dy','Ho','Er','Tm','Yb','Lu','Hf','Ta','W','Re','Os','Ir','Pt','Au','Hg','Tl','Pb','Bi'};
%
elements.ground_state = {'1s1','1s2','[He] 2s1','[He] 2s2','[He] 2s2 2p1','[He] 2s2 2p2','[He] 2s2 2p3','[He] 2s2 2p4','[He] 2s2 2p5','[He] 2s2 2p6',...
                '[Ne] 3s1','[Ne] 3s2','[Ne] 3s2 3p1','[Ne] 3s2 3p2','[Ne] 3s2 3p3','[Ne] 3s2 3p4','[Ne] 3s2 3p5','[Ne] 3s2 3p6','[Ar] 4s1',...
                '[Ar] 4s2','[Ar] 4s2 3d1','[Ar] 4s2 3d2','[Ar] 4s2 3d3','[Ar] 4s1 3d5','[Ar] 4s2 3d5','[Ar] 4s2 3d6','[Ar] 4s2 3d7','[Ar] 4s2 3d8',...
                '[Ar] 4s1 3d10','[Ar] 4s2 3d10','[Ar] 4s2 3d10 4p1','[Ar] 4s2 3d10 4p2','[Ar] 4s2 3d10 4p3','[Ar] 4s2 3d10 4p4','[Ar] 4s2 3d10 4p5','[Ar] 4s2 3d10 4p6',...
                '[Kr] 5s1','[Kr] 5s2','[Kr] 5s2 4d1','[Kr] 5s2 4d2','[Kr] 5s1 4d4','[Kr] 5s1 4d5','[Kr] 5s2 4d5','[Kr] 5s1 4d7','[Kr] 5s1 4d8','[Kr] 4d10',...
                '[Kr] 5s1 4d10','[Kr] 5s2 4d10','[Kr] 5s2 4d10 5p1','[Kr] 5s2 4d10 5p2','[Kr] 5s2 4d10 5p3','[Kr] 5s2 4d10 5p4','[Kr] 5s2 4d10 5p5','[Kr] 5s2 4d10 5p6',...
                '[Xe] 6s1','[Xe] 6s2','[Xe] 6s2 5d1','[Xe] 6s2 4f1 5d1','[Xe] 6s2 4f3','[Xe] 6s2 4f4','[Xe] 6s2 4f5','[Xe] 6s2 4f6','[Xe] 6s2 4f7','[Xe] 6s2 4f7 5d1',...
                '[Xe] 6s2 4f9','[Xe] 6s2 4f10','[Xe] 6s2 4f11','[Xe] 6s2 4f12','[Xe] 6s2 4f13','[Xe] 6s2 4f14','[Xe] 6s2 4f14 5d1','[Xe] 6s2 4f14 5d2','[Xe] 6s2 4f14 5d3',...
                '[Xe] 6s2 4f14 5d4','[Xe] 6s2 4f14 5d5','[Xe] 6s2 4f14 5d6','[Xe] 6s2 4f14 5d7','[Xe] 6s1 4f14 5d9','[Xe] 6s1 4f14 5d10','[Xe] 6s2 4f14 5d10',...
                '[Xe] 6s2 4f14 5d10 6p1','[Xe] 6s2 4f14 5d10 6p2','[Xe] 6s2 4f14 5d10 6p3'};
%
for iN = elements.Z(1):elements.Z(end)
    M_nist{iN} = [];%initialize NIST multiplicity
    L_nist{iN} = [];%initialize NIST azimuthal quantum number
end
%
% NIST database -> 
%   https://physics.nist.gov/cgi-bin/Elements/elInfo.pl?element=74&context=frames for tungsten
%   https://physics.nist.gov/cgi-bin/Elements/elInfo.pl?element=79&context=frames for gold
%   Once on the page, click on Ground States and Ionization energies button
%   Select the Ground Level 5th column
%   The rows are from the neutral to the Rydberg atom. The spin
%   multiplicity is 2 for neutral Gold for example (2S1/2), then 1 (1S0)
%   for Au1+ etc. Some spin multiplicity are missing. They are replaced by
%   Hund's rule, or posibly 0 when a mixed multiplicity is indicated
%   (0,3/2) for Au71+ (Nitrogen number of bound electrons). The spin
%   multiplicity start from the neutral (left) to the Rydberg atom (right)
%   in M_nist{Z}. For low-Z elements, M_nist = M_hund
%   The M_hund does not work for high-Z elements weakly ionized. Failure in
%   Gaussian DFT calculations. However, when spin multiplicity is zero from NIST database, it
%   is replaced by the Hund's value, otherwise, the density may be zero.
%
if nonist == 0
    %
    M_nist{24} = [7,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Chromium Cr
    L_nist{24} = [0,0,2,3,3,2,0,1,1,0,1,1,0,0,0,1,1,0,1,1,0,0,0,0];%Chromium Cr
    %
    M_nist{26} = [5,6,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Iron Fe
    L_nist{26} = [2,2,2,0,2,3,3,2,0,1,1,0,1,1,0,0,0,1,1,0,1,1,0,0,0,0];%Chromium Cr
    %
    M_nist{28} = [3,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Nickel Ni
    M_nist{29} = [2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Copper Cu
    %
    M_nist{32} = [3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Germanium Ge
    %
    M_nist{36} = [1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Krypton Kr
    M_nist{37} = [2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Rubidium Rb
    M_nist{38} = [1,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Strontium Sr
    M_nist{39} = [2,1,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Yttrium Y
    M_nist{40} = [3,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Zirconium Zr  
    M_nist{41} = [6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Niobium Nb
    M_nist{42} = [7,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Molybdenum Mo
    M_nist{43} = [6,7,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Technetium Tc
    M_nist{44} = [5,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Ruthenium Ru
    M_nist{45} = [4,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Rhodium Rh
    M_nist{46} = [1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Palladium Pd
    M_nist{47} = [2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Silver Ag
    M_nist{48} = [1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Cadmium Cd
    M_nist{49} = [2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Indium In
    M_nist{50} = [3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Tin Sn
    M_nist{51} = [4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Antimony Sb
    M_nist{52} = [3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Tellurium Te
    M_nist{53} = [2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Iodine I
    M_nist{54} = [1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Xenon Xe
    M_nist{55} = [2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Cesium Cs
    M_nist{56} = [1,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Barium Ba
    M_nist{57} = [2,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Lanthanum La
    M_nist{58} = [1,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Cerium Ce
    M_nist{59} = [4,0,4,3,2,1,0,0,0,0,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Praseodymium Pr
    M_nist{60} = [5,6,5,4,3,0,0,0,0,0,0,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Neodymium Nd
    M_nist{61} = [6,7,6,5,4,0,0,0,0,0,0,0,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Promethium Pm
    M_nist{62} = [7,8,7,6,5,4,0,0,0,0,0,0,0,2,0,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Samarium Sm
    M_nist{63} = [8,9,8,7,6,0,0,0,0,0,0,0,0,0,0,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Europium Eu
    M_nist{64} = [9,10,9,8,7,0,0,0,0,0,0,0,0,6,0,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Gadolinium Gd
    M_nist{65} = [6,0,6,7,8,0,0,0,0,0,0,0,0,0,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Terbium Tb
    M_nist{66} = [5,0,5,6,7,0,0,0,0,0,0,0,0,0,0,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Dysprosium Dy
    M_nist{67} = [4,0,4,5,6,0,0,0,0,0,0,0,0,0,0,0,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Holmium Ho
    M_nist{68} = [3,0,3,4,5,0,0,0,0,0,0,0,0,0,0,8,7,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Erbium Er
    M_nist{69} = [2,0,2,3,4,5,0,0,0,0,4,0,0,0,6,7,8,7,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Thulium Tm
    M_nist{70} = [1,2,1,2,3,0,0,0,0,0,3,4,0,0,0,6,7,8,7,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Ytterbium Yb
    M_nist{71} = [2,1,2,1,2,3,0,0,4,0,0,3,4,0,0,0,6,7,8,7,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Lutetium Lu
    M_nist{72} = [3,2,3,2,1,2,0,0,0,4,0,0,3,4,5,0,0,6,7,8,7,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Hafnium Hf
    M_nist{73} = [4,5,4,3,2,1,2,0,0,0,4,0,2,3,4,5,0,0,6,7,8,7,6,5,4,3,2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,0,0,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];% Tantalum Ta 
    %
    M_nist{74} = [5,6,5,4,3,2,1,2,3,2,3,4,1,2,3,4,5,4,5,6,7,8,7,6,5,4,3,2,1,2,3,4,5,4,3,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,2,3,2,1,2,1,2];%Tungsten W
    L_nist{74} = [2,2,2,3,3,2,0,3,1,1,1,3,0,3,5,6,6,6,6,5,3,0,3,5,6,6,5,3,0,2,3,3,2,1,1,3,3,2,0,1,1,2,1,1,0,0,0,2,i,i,i,i,i,i,i,2,0,1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,0];%Tungsten W
    %
    M_nist{78} = [3,2,3,4,5,6,5,4,3,2,1,2,3,2,3,2,1,2,3,2,3,4,5,6,7,8,7,6,5,4,3,2,1,2,3,4,5,4,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,4,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Gold Au
    M_nist{79} = [2,1,2,3,4,5,6,5,4,3,2,1,2,3,2,3,2,1,2,3,2,3,4,5,6,7,8,7,6,5,4,3,2,1,2,3,4,5,4,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,5,4,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%Gold Au
    %












end
%
symbol = elements.symbol{Z};
neutral_ground_state = elements.ground_state{Z};
%
if ~isempty(M_nist{Z})
    %
    M = M_nist{Z};
    %
    return;
    %
end
%
base{1} = elements.ground_state{Z}(2:strfind(elements.ground_state{Z},']')-1);
%
if ~isempty(elements.ground_state{Z}(strfind(elements.ground_state{Z},']')+2:end))
    extra_shells{1} = split(elements.ground_state{Z}(strfind(elements.ground_state{Z},']')+2:end),' ');
else
    extra_shells{1} = {elements.ground_state{Z}};
end
%
ii = 2;
%
while 1
    %
    iZ0 = find(strcmp(elements.symbol,base{ii-1})==1);
    %
    if ~isempty(iZ0) && ~isempty(elements.ground_state{elements.Z(iZ0)}(2:strfind(elements.ground_state{elements.Z(iZ0)},']')-1)) && ~isempty(base{1})
        base{ii} = elements.ground_state{elements.Z(iZ0)}(2:strfind(elements.ground_state{elements.Z(iZ0)},']')-1);
        extra_shells{ii} = split(elements.ground_state{elements.Z(iZ0)}(strfind(elements.ground_state{elements.Z(iZ0)},']')+2:end),' ');
        ii = ii + 1;
    else
        if ~isempty(iZ0)
            base{ii} = elements.ground_state{elements.Z(iZ0)}(2:strfind(elements.ground_state{elements.Z(iZ0)},']')-1);
            extra_shells{ii} = {elements.ground_state{elements.Z(iZ0)}};
        end
        %
        break;
    end
end
%
iZ = 1;
%
for ibase = 1:length(base)
    %
    for ishell = length(extra_shells{ibase}):-1:1
        %
        if iscell(extra_shells{ibase})
            extra_shells_type = extra_shells{ibase}{ishell}(2);
            extra_shells_N = str2num(extra_shells{ibase}{ishell}(3:end));
        end
        %
        for n = extra_shells_N:-1:1
            %
            M(iZ) = multiplicity(extra_shells_type,n);
            %
            iZ = iZ + 1;
            %
        end
        %
    end
end
%
function M = multiplicity(type,n)
    %
    if strcmp(type,'s')
        n_shell = 2;
    elseif strcmp(type,'p')
        n_shell = 6;
    elseif strcmp(type,'d')
        n_shell = 10;
    elseif strcmp(type,'f')
        n_shell = 14;
    elseif strcmp(type,'g')
        n_shell = 18;
    end
    %
    if n <= n_shell/2
        M = n + 1;
    elseif n > n_shell/2
        M = n_shell - n + 1;
    end
    %
end
%
end

    
    
    


 