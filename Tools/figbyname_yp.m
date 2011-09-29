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
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
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