function [s] = putinfo_yp(s,struct_name,fexcept)
%
% This function paste up to date informations on each field of any structure used by C3PO/LUKE. Recursive in sub-structures
% It also set-up the expert mode for each field.
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
if nargin < 3,
    fexcept = {'info','expert','values'};
end
%
for ifield = 1:length(fexcept),
    if isfield(s,fexcept{ifield}),
        s = rmfield(s,fexcept{ifield});
    end
end
%
fnames = fieldnames(s);
%
for ifield = 1:length(fnames),
    [s.info.(fnames{ifield}),s.expert.(fnames{ifield}),s.values.(fnames{ifield})] = structinfo_yp(struct_name,fnames{ifield});
    if isstruct(s.(fnames{ifield})),
        [s.(fnames{ifield})] = putinfo_yp(s.(fnames{ifield}),fnames{ifield},fexcept);
    end
end
    

