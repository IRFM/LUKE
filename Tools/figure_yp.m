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
% by Y. Peysson (CEA-IRFM,yves.peysson@cea.fr) and J. Decker (joan.decker@cea.fr)
%
fh = findall(0,'type','figure');%find the list of existing figures
%
if nargin == 0,
    if isempty(fh),
        h = figure(1);
    else
        h = figure(max(fh)+1);
    end
else
    if number > 0 & ~isempty(number) & ~isnan(number),
        h = figure(number);
    else
        if isempty(fh),
            h = figure(1);
        else
            h = figure(max(fh)+1);
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
    
    
    
    
    
    