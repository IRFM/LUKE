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
function [elements,A] = Z2element_yp(adas,Z,display_mode)
%
%   Calculation of the atomic number Z and atomic mass A of an element from the Atomic Data and Analysis Structure (ADAS). 
%
%   INPUTS:
%
%       - adas : Atomic Data and Analysis Structure
%           (default : ADAS.mat file is loaded from '~/LUKE_CEA/Project_DKE/Modules/ADAS')
%       - Z: atomic number, multiple values may be entered [1,n]
%           (default : Z =74, tungsten)
%       - display_mode : (0) no display, (1) display in command window
%            (default : 0)
%       
%   OUTPUTS:
%
%       - elements : name of the elements (H,C,O,W,Cu....) {1,n}
%       - A:  atomic mass [1,n]
%
%   By Y. Peysson CEA-IRFM <yves.peysson@cea.fr>
%
if nargin == 0
    %
    load('ADAS.mat')
    %
    adas = tabmat;
    Z = 74;%tungsten
    display_mode = 0; 
    %
elseif nargin == 1
    %
    Z = 74;%tungsten
    display_mode = 0; 
    %
elseif nargin == 2
    %
    display_mode = 0; 
    %    
end
%
elements = '';
A = [];
k = 1;
%
fields = fieldnames(adas);
for j = 1:length(Z)
    for i = 1:length(fieldnames(adas))
        if adas.(fields{i}).Z == Z(j)
            %
            elements{k} = fields{i};
            A(k) = adas.(fields{i}).A;
            %
            if display_mode
                %
                disp(['Element : ',elements{k},', Masse atomique A = ',num2str(A(k))])
                %
            end
            %
            k = k+1;
            break
            %
        end
    end
end
