function sparams_out = sluke_params_extract(varargin)
%
% LUKE - Extract substructures from a simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin{1} : initial 'sparams' structure for modifications
%   - varargin{2} : index of sparams to extract
%
% OUTPUT :
%
%   - sparams_out : extracted structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams_out = {};
%
if nargin == 2
    %
    sparams_in = varargin{1};
    jextract = varargin{2};
    %
elseif nargin == 1
    %
    sparams_in = varargin{1};
    %
else
    %
    error('Wrong number of input arguments in sluke_params_extract function');
    %
end
%
[err,status] = sluke_params_consistency(sparams_in);
%
if err == 0
    %
    fns_in = fieldnamesr(sparams_in);
    ihelp = find(contains(fns_in,'help'));
    if ~isempty(ihelp)
        fns = fns_in(1:ihelp(1)-1);
    else
        fns = fns_in;
    end
    %
    nf0 = length(sparams_in.machine);
    %
    if nargin == 1
        %
        jextract = input_dke_yp(['Which indexes to extract (index max = ',int2str(nf0),')'],1,[1:nf0]);
        %
    end
    %
    for jj = 1:length(jextract)
        %
        for ii = 1:length(fns)
            %
            eval(['sparams_out.',fns{ii},'{',int2str(jj),'} = sparams_in.',fns{ii},'{',int2str(jextract(jj)),'};']);
            %
        end
    end
    %
end
%
if isfield(sparams_in,'help') && isfield(sparams_in,'format')
    sparams_out.help = sparams_in.help;
    sparams_out.format = sparams_in.format;
end
%