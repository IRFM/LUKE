function s = cell2mat_jd(c,dim,numopt,dispmode)
    %
    % this function builds a structure s from the cell array of structures c
    % where each field of s is a concatenation of the compatible arrays from fields c 
    %
    %   INPUTS : 
    %       - c : cell array of structures
    %       - dim : dim can be either : 
    %           o the dimension along which to concatenate fields of c (default : 2 for columns) 
    %           o the field defining the number of new elements from each cell
    %       - numopt : restrict to numerical arrays
    %       - dispmode : disply warnings
    %
    if nargin < 4,
        dispmode = false;
    end
    %
    if nargin < 3 || ~islogical(numopt),
        numopt = false;
    end
    %
    if nargin < 2,
        dim = 2;
    end
    %
    s = struct;
    %
    if ~iscell(c) || isempty(c),
        disp_jd(dispmode,'WARNING : c must be a non-empty cell array');
        return
    else
        c = c(:);
    end
    %
    if ~isstruct(c{1}),
        disp_jd(dispmode,'WARNING : c must be a cell array of structures');
        return
    else
        s = c{1};
    end
    %
    sfd = fieldnames(s);
    nsfd = length(sfd);
    mask = false(1,nsfd);
    %
    if numopt,
        for isfd = 1:nsfd,
            mask(isfd) = ~isnumeric(s.(sfd{isfd}));
            if mask(isfd),
                disp_jd(dispmode,['WARNING : field ''',sfd{isfd},''' is not numeric. Discarded.']);
            end
        end
    end
    %
    if ischar(dim),
        if isfield(s,dim),
            snumel = numel(s.(dim));
            dim = ones(1,nsfd);
            %
            for isfd = 1:nsfd,
                szs = size(s.(sfd{isfd}));
                iszs = find(szs == snumel);
                if isempty(iszs),
                    disp_jd(dispmode,['WARNING : field ''',sfd{isfd},''' has no dimension with ',num2str(snumel),' elements. Discarded.']);
                    mask(isfd) = true;
                elseif length(iszs) > 1,
                    disp_jd(dispmode,['WARNING : field ''',sfd{isfd},''' has more than one dimension with ',num2str(snumel),' elements. Lowest dimension enforced.']);
                    dim(isfd) = iszs(1);
                else
                    dim(isfd) = iszs;
                end
            end
        else
            dim = repmat(2,[1,nsfd]);
        end
    else
        dim = repmat(dim,[1,nsfd]);
    end
    %
    nc = length(c);
    %
    for ic = 2:nc,
        if ~isstruct(c{ic}),
            disp_jd(dispmode,['WARNING : c{',num2str(ic),'} is not a structure. Discarded.']);
            continue
        end
        %
        fd = fieldnames(c{ic});
        nfd = length(fd);
        %
        for ifd = 1:nfd,
            if ~isfield(s,fd{ifd}),
                disp_jd(dispmode,['WARNING : field ''',fd{ifd},''' is not present in all structures of cell array. Discarded.']);
            else
                isfd = strcmp(sfd,fd{ifd});%index is s field array
                %
                if mask(isfd),
                    continue
                end
                %
                if numopt && ~isnumeric(c{ic}.(fd{ifd})),
                    disp_jd(dispmode,['WARNING : field ''',fd{ifd},''' is not numeric in all structures of cell array. Discarded.']);
                    mask(isfd) = true;
                    continue
                end
                %
                szs = size(s.(sfd{isfd}));
                szc = size(c{ic}.(fd{ifd}));
                %
                if length(szs) ~= length(szc) || any(szs([1:dim(isfd)-1,dim(isfd)+1:end]) ~= szc([1:dim(isfd)-1,dim(isfd)+1:end])),
                    disp_jd(dispmode,['WARNING : field ''',fd{ifd},''' cannot be concatenated between all structures of cell array. Discarded.']);
                    mask(isfd) = true;
                    continue
                end
                %
                s.(sfd{isfd}) = shiftdim([shiftdim(s.(sfd{isfd}),dim(isfd)-1);shiftdim(c{ic}.(fd{ifd}),dim(isfd)-1)],length(szs) - dim(isfd) + 1);
                %
            end
        end
    end
    %
    s = rmfield(s,fd(mask));
    %
end
%
function disp_jd(dispmode,str)
    %
    if dispmode,
        disp(str)
    end
end
