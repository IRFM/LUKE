function [M,Z0,symbol,neutral_ground_state] = spinmultiplicity_yp(Z)
%
%   Calculation of atomic spin multiplicity for all ionization state of an
%   atom with atomic number Z. To be used by DFT programs to calculate the
%   atomic electron density like GAUSSIAN
%
%   INPUTS:
%
%       - Z : atomic number [1,1]
%
%   OUTPUTS:
%
%       - M : spin multiplicity [1,Z]
%       - Z0 : ionization states including neutral atom [1,Z+1]
%       - symbol : atom symbol [1,n]
%       - neutral_ground_state : ground state for neutral atom [1,m]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>, A. Jardin IJF/PAN <axel.jardin@ifj.edu.pl>, K. Krol IFJ/PAN <krzysztof.krol@ifj.edu.pl>
%
if nargin < 1
    error('Error: not enough input arguments in spinmultiplicity_yp.m.')
else
    if Z > 83
        error('Error: maximum Z value is 83.')
    end
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
% NIST database
% (https://physics.nist.gov/cgi-bin/Elements/elInfo.pl?element=74&context=frames) for tungsten
%
M_nist{74} = [5,6,5,4,3,2,1,2,3,2,3,4,1,2,3,4,5,4,5,6,7,8,7,6,5,4,3,2,1,2,3,4,5,4,3,4,3,2,1,2,3,2,3,2,1,2,1,2,3,4,5,6,5,4,3,2,1,2,3,2,3,2,1,2,1,2,3,2,3,2,1,2,1,2];%tungsten
M_nist{29} = [2,1,2,3,4,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%copper
M_nist{26} = [5,6,5,6,5,4,3,2,1,2,3,4,3,2,1,2,1,2,3,4,3,2,1,2,1,2];%iron
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

    
    
    


 