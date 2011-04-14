function s = structindex(s,slength,sindex,ignoredfields)
%
% This function returns the fields evaluated at the index sindex.
%  - Only fields with a dimension of length slength are concerned 
%  - If several dimensions have the length slength, only the first dimension is concerned
%
% by J. Decker 02/01/2011
%
if nargin <4,
    ignoredfields = {};
end
if nargin < 3,
    error('Not enough input arguments')
end
if ~isstruct(s),
    error('s must be s structure')
end
if ~isscalar(slength) || slength ~= round(slength) || slength <= 0,
    error('slength must be a positive integer scalar')
end
if ~isscalar(sindex) || sindex ~= round(sindex) || sindex <= 0,
    error('sindex must be a positive integer scalar')
end
if sindex > slength,
    error('sindex cannot be larger than slength')
end
%
sfields = fieldnames(s);
%
for is = 1:length(sfields),
    %
    sfield = sfields{is}; 
    %
    if any(strmatch(sfield,ignoredfields,'exact')),
        continue
    end
    %
    sval = s.(sfield);
    ssize = size(sval);
    idim = find(ssize == slength,1,'first');
    %
    if ~isempty(idim)
        ssize2 = ssize([idim:end,1:idim-1]);
        sval = shiftdim(sval,idim - 1);
        sval = reshape(sval(sindex,:),[1,ssize2(2:end)]);
        sval = shiftdim(sval,length(ssize) - idim + 1);
        s.(sfield) = sval;
    end
end
%