function [I0,I0_s,Z0,symbol] = meanexcitationenergy_yp(Z)
%
%   Calculation of mean excitation energy to be used in Bethe stopping
%   electron formula. Calculated from a simple heuristic rule from neutral
%   atom to hydrogenoid ion or exact, if available from quantum relativistic
%   calculations.
%
%   INPUTS:
%
%       - Z : atomic number [1,1]
%
%   OUTPUTS:
%
%       - I0 : full quantum relativistic calculated mean excitation energy (eV) [1,Z]
%       - I0_s : Simple law for mean excitation energy (if I0 do not exist, I0 = I0_s) (eV) [1,Z]
%       - Z0 : ionization states including neutral atom [1,Z+1]
%       - symbol : atom symbol [1,n]
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
% From publications (units eV)
%
I0 = [];
%
I0_ref{1} = [13.6];
I0_ref{2} = [42.68,59.88];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
I0_ref{3} = [33.1,108.1,134.1];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
I0_ref{6} = [65.9,92.6,134.8,214.2,486.2,539.5];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
I0_ref{10} = [92.5,95.3,98.9,103.7,110.6,120.9,138.1,211.8,497.8,497.8];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
I0_ref{13} = [122.8,160.0,223.7,310.9,325.5,390.4,457.5,530.8,643.0,817.9,1236.0,2372.0,2372.0];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
I0_ref{18} = [188.5,219.4,253.8,293.4,339.1,394.5,463.4,568.0,728.0,795.9,879.8,989.9,1138.1,1369.5,1791.2,2497.0,4677.2,4838.2];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
%
symbol = elements.symbol{Z};
%
if Z <= length(I0_ref) && ~isempty(I0_ref{Z}) 
    %
    I0 = I0_ref{Z};
    %
end
%
I0_min = 10*Z;%eV 
I0_max = 13.6*Z^2;%eV
%
b = log(I0_min);
a = log(I0_max) - b;
%
I0_s = exp(a*Z0./(Z-1)+b);
%
if isempty(I0)
    I0 = I0_s;
end
%
if Z == 1
    I0_s = I0; % specific case of Hydrogen
end
    

    
    
    


 