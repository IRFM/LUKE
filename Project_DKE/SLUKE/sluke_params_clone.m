function sparams_out = sluke_params_clone(varargin)
%
% LUKE - Clone fields of simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : modified structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams_out = {};
%
if nargin == 2
    %
    sparams_in = varargin{1};
    jclone = varargin{2};
    %
elseif nargin == 1
    %
    sparams_in = varargin{1};
    %
else
    %
    error('Wrong number of input arguments in sluke_params_clone function');
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
        jclone = input_dke_yp(['Which indexes to clone (index max = ',int2str(nf0),')'],1,[1:nf0]);
        %
    end
    %
    if isfield(sparams_in,'help') && isfield(sparams_in,'format')
        %
        sparams_out = rmfield(sparams_in,{'help','format'});
        %
    else
        %
        sparams_out = sparams_in;
        %
    end
    %
    for jj = 1:length(jclone)
        %
        for ii = 1:length(fns)
            %
            eval(['sparams_out.',fns{ii},'{',int2str(nf0+jj),'} = sparams_in.',fns{ii},'{',int2str(jclone(jj)),'};']);
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


