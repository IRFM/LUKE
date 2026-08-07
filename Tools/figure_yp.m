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
function h = figure_yp(number,name,cmd)
%
% This function creates a figure with more flexible possible that given in Matlab 
%
% INPUTS
%
%       - number: figure number [1,1]
%       - name: figure name [1,n]
%       - cmd: command associated to the figure creation [1,n]
%
% OUTPUTS
%       
%       - h: figure handle [1,1]
%
fh = findall(0,'type','figure');%find the list of existing figures
%
if nargin == 0,
    if isempty(fh),
        h = figure(1);
    else
        h = figure(max(length(fh))+1);
    end
else
    if number > 0 & ~isempty(number) & ~isnan(number),
        h = figure(number);
    else
        if isempty(fh),
            h = figure(1);
        else
            h = figure(max(length(fh))+1);
        end
    end
    %
    if nargin >= 2,
        if ~isempty(name)
            set(h,'name',name)
        end
    end
    %
    if nargin >= 3,
        if ~isempty(cmd)
            eval(cmd);
        end
    end
end
    
    
    
    
    
    