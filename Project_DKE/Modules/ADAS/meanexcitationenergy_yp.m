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
I0_ref{10} = [137.2,165.2,196.0,235.2,282.8,352.6,475,696.8,1409.2,1498.4];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
I0_ref{13} = [132,172.4,225.4,310.4,350.5,398.1,458.4,536.3,654.8,867.1,1238.3,2406.9,2523.2];%S. Sauer, J. Oddershede and J. Sabin, "The mean Excitation Energy of Atomic Ions, Advances in quantum chemistry, 71, (2015) 29  
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
%
display = 1;
%
if display
    %
    linestyle(1) = {'-'};
    linestyle(2) = {'--'};
    linestyle(3) = {'-.'};
    linestyle(4) = {':'};
    linestyle(5) = {'-'};
    linestyle(6) = {'--'};

    %
    linecolor(1) = {'r'};
    linecolor(2) = {'b'};
    linecolor(3) = {'g'};
    linecolor(4) = {'m'};
    linecolor(5) = {'c'};
    linecolor(6) = {'k'};
    %
    figure('Name',['Mean excitation energy of ',symbol])
    %
    xlab = 'Z_0';
    ylab = 'Mean excitation energy [eV]';
    siz = 20+14i;
    %
    tit = ['Mean excitation energy of ',symbol];
    %
    graph1D_jd(Z0,I0,0,1,xlab,ylab,tit,NaN,NaN,NaN,'none','o',linecolor{1},2,siz,gca); 
    graph1D_jd(Z0,I0_s,0,1,xlab,ylab,tit,NaN,NaN,NaN,linestyle{1},'none',linecolor{2},2,siz,gca); 
    %
    legend('Quantum calculations','Interpolation')
end
    
    
    


 