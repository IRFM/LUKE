function [varargout] = listfields_jd(s,mode)
%
% This function list the fields of s and its substructures. 
% If mode is true, substructures themselves are ignored is the list.
%
if nargin < 2,
    mode = 1;
end
%
sfieldnames = fieldnames(s);
%
nfields = length(sfieldnames);
smask = false(1,nfields);
%
for ifield = 1:nfields,
    sfieldname = sfieldnames{ifield};
    if isstruct(s.(sfieldname)),
        sfieldnames = [sfieldnames;listfields_jd(s.(sfieldname),mode)];
        if mode,
            smask(ifield) = true;
        end
    end
end
%
sfieldnames(smask) = [];
sfieldnames = unique(sfieldnames);
%
if nargout > 0,
    varargout{1} = sfieldnames;
else
    disp('List of field names')
    disp('-------------------')
    disp(' ');
    for ifield = 1:length(sfieldnames);
        disp(sfieldnames{ifield});
    end
    disp(' ');
end