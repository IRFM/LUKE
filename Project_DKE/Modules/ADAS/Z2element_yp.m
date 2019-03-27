function [elements,A] = Z2element_yp(adas,Z)
%
%   Calculation of the atomic number Z and atomic mass A of an element from the Atomic Data and Analysis Structure (ADAS). 
%
%   INPUTS:
%
%       - adas : Atomic Data and Analysis Structure
%       - Z: atomic number [1,n]
%       
%   OUTPUTS:
%
%       - elements : name of the elements (H,C,O,W,Cu....) {1,n}
%       - A:  atomic mass [1,n]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
elements = '';
A = [];
k = 1;
%
fields = fieldnames(adas);
for j = 1:length(Z),
    for i = 1:length(fieldnames(adas))
        if adas.(fields{i}).Z == Z(j)
            %
            elements{k} = fields{i};
            A(k) = adas.(fields{i}).A;
            k = k+1;
            break
            %
        end
    end
end
