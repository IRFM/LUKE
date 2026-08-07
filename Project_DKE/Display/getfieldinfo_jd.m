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
function finfo = getfieldinfo_jd(s,fname)
%
% This function returns the info for the field fname of the structure s
%
finfo = '';
%
if ~isfield(s,fname),
    warning([fname,' is not a valid structure field.'])
    return
end
%
if ~isfield(s,'info'),
    warning('The structure has no info field');
    return
end
%
if ~isfield(s.info,fname),
    warning(['There is no info for the field ',fname,'.']);
    return
end
%
finfo = getfield(s.info,fname);
%




