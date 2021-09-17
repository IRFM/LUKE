function sparams_out = sluke_params_value(varargin)
%
% LUKE - Extract value from a simulation parameters substructure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin{1} : initial 'sparams' substructure
%   - varargin{2} : index of sparams substructure to extract
%   - varargin{3} : index of sparams subsubstructure to extract (for rf waves)
%
% OUTPUT :
%
%   - sparams_out : extracted structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams_out = {};
%
if nargin == 3
    %
    sparams_in = varargin{1};
    jextract = varargin{2};
    kextract = varargin{3};
    %
elseif nargin == 2
    %
    sparams_in = varargin{1};
    jextract = varargin{2};
    %
elseif nargin == 1
    %
    sparams_in = varargin{1};
    jextract = 1;
    %
else
    %
    error('Wrong number of input arguments in sluke_params_value function');
    %
end
%
fns_in = fieldnamesr(sparams_in);
%
for ii = 1:length(fns_in)
    %
    if nargin <3
        %
        try
            eval(['sparams_out.',fns_in{ii},' = sparams_in.',fns_in{ii},'{',int2str(jextract),'};']);
        catch
            error(['ERROR: value of sluke_params_value.m for sparams_in.',fns_in{ii},' cannot be read'])
        end
        %
    else
        %
        try
            eval(['sparams_out.',fns_in{ii},' = sparams_in.',fns_in{ii},'{',int2str(jextract),'}{',int2str(kextract),'};']);
        catch
             error(['ERROR: value of sluke_params_value.m for sparams_in.',fns_in{ii},' cannot be read'])
        end
        %
    end
    %
end

