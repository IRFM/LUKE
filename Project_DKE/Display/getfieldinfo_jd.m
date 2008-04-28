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




