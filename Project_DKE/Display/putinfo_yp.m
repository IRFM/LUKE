function [s] = putinfo_yp(s,struct_name)
%
% This function paste up to date informations on each field of any structure used by C3PO/LUKE. Recursive in sub-structures
% It also set-up the expert mode for each field.
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
fnames = fieldnames(s);
nfield = length(fnames);
%
for ifield = 1:nfield,
    [s.info.(fnames{ifield}),s.expert.(fnames{ifield})] = structinfo_yp(struct_name,fnames{ifield});
    if isstruct(s.(fnames{ifield})) && ~strcmp(fnames{ifield},'info') && ~strcmp(fnames{ifield},'expert'),
        [s.(fnames{ifield})] = putinfo_yp(s.(fnames{ifield}),fnames{ifield});
    end
end
    

