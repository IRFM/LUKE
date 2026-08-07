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