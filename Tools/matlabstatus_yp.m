function [matv,testtoolbox] = matlabstatus_yp(toolboxname)  
%LUKE - This function specifies the current version of matlab and if a toolbox exists
%
% This function specifies the current version of matlab and if a toolbox exists
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
v = ver('matlab');
matv = round(100*str2num(v.Version));
%
vt = ver;
%
testtoolbox = [];
%
if nargin > 0,
    for ivt = 1:length(vt),
        testtoolbox = strcmp(char(vt(ivt).Name),toolboxname);
        if testtoolbox,break;end
    end
end
%