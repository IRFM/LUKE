function [s,fields] = structtimes_jd(s,a)
%
% This function multiplies all fields from the structure s by the scalar a
% if applicable, in which case the field is return in 'fields'.
%
if nargin < 2,
    a = 1;
elseif ~isnumeric(a),
    error('Numerical array or scalar is requested as second argument in structtimes_jd');
end
if nargin < 1 || ~isstruct(s),
    error('Structure is requested as first argument in structtimes_jd');
end
%
fnames = fieldnames(s);
%
nfields = length(fnames);
%
flag = false(1,nfields);
%
sa = size(a);
%
for ifield = 1:nfields,
    %
    fname = fnames{ifield};
    %
    if isnumeric(s.(fname)),
        sf = size(s.(fname));
        %
        if isscalar(sa) || isscalar(sf) || (length(sf) == length(sa) && all(sf == sa)),
            s.(fname) = s.(fname).*a;
            flag(ifield) = true;
        end
    end
    %
end
%
fields = fnames(flag);