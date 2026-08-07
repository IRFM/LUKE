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
function [ifig] = figbyname_yp(figname,flag)
%
% Retrieve the handle h of the figure whos name is figname. If the figure
% does not exist, then it creates a new figure with this name
%
% INPUT
%    - figname: figure name [1,n]
%       (default = '')
%    - flag [1,1]: 
%            0 -> No action
%            1 -> a figure is created or cleared if existing
%            2 -> a figure is created but not cleared if existing
%       (default = 1)
%
% OUTPUT: 
%    - ifig = figure handle
%
if nargin < 1
    figname = '';
end
%
if nargin < 2
    flag = 1;
end
%
ifig = 1;
%
while ishghandle(ifig)
    if strfind(get(ifig,'Name'),figname),
        if flag == 1,
            clf(ifig);
        end
        flag = 0;
        break;
    else
        ifig = ifig + 1;
    end
end
% 
if flag >= 1,
    figure('Name',figname);
end