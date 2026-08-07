% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function [Z,A] = element2ZA_yp(adas,elements)
%
%
%   Calculation of the atomic number Z and atomic mass A of an element from the Atomic Data and Analysis Structure (ADAS). 
%
%   INPUTS:
%
%       - adas : Atomic Data and Analysis Structure
%       - elements : name of the elements (H,C,O,W,Cu....) {1,n}
%
%   OUTPUTS:
%
%       - Z: atomic number [1,n]
%       - A:  atomic mass [1,n]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
Z = [];
A = [];
%
if nargin == 1 || isempty(elements),
    fields = fieldnames(adas);
    for j = 1:length(fields),
        %
        Z(j) = adas.(fields{j}).Z;
        A(j) = adas.(fields{j}).A;
        %
    end
else
    for j = 1:length(elements),
        if isfield(adas,elements{j})
            %
            Z(j) = adas.(elements{j}).Z;
            A(j) = adas.(elements{j}).A;
            %
        end
    end
end
%
Z = sort(Z);
A = sort(A);
%
%if ~isempty(Z) && Z(2) ~= 1 
%    Z = [1,1,1,Z(2:end)];
%    A = [1,2,3,A(2:end)];
%end