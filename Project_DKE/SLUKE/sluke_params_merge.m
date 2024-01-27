function sparams_out = sluke_params_merge(varargin)
%
% LUKE - Merge fields of simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structures for modifications (one -> identical output, 2 -> merged structures is created)
%
% OUTPUT :
%
%   - sparams : merged structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
sparams_out = {};
%
if nargin == 1
    %
    sparams_out = varargin{1};
    return
    %
elseif nargin == 2  
    %
    sparams_in1 = varargin{1};
    sparams_in2 = varargin{2};
    %
else
    error('Wrong number of input arguments in sluke_params_merge function');
end
%
[err1,status1] = sluke_params_consistency(sparams_in1);
[err2,status2] = sluke_params_consistency(sparams_in2);
%
if err1 == 0 && err2 == 0
    %
    fns_in1 = fieldnamesr(sparams_in1);
    ihelp1 = find(contains_yp(fns_in1,'help'));
    if ~isempty(ihelp1)
        fns1 = fns_in1(1:ihelp1(1)-1);
    else
        fns1 = fns_in1;
    end
    %
    fns_in2 = fieldnamesr(sparams_in2);
    ihelp2 = find(contains_yp(fns_in2,'help'));
    if ~isempty(ihelp2)
        fns2 = fns_in2(1:ihelp2(1)-1);
    else
        fns2 = fns_in2;
    end
    %
    flag = 0;
    %
    if length(fns1) == length(fns2)
        %
        for ii = 1:length(fns1)
            %
            if ~strcmp(fns1{ii},fns2{ii}) 
                %
                flag = flag + 1;
                %
            end
        end
        %
        if flag == 0
            %
            if isfield(sparams_in1,'help') && isfield(sparams_in1,'format')
                %
                sparams_out = rmfield(sparams_in1,{'help','format'});
                %
            else
                %
                sparams_out = sparams_in1;
                %
            end
            %
            nf1 = length(sparams_in1.machine);
            nf2 = length(sparams_in2.machine);
            %
            for ii = 1:length(fns1)
                %
                eval(['sparams_out.',fns1{ii},' = [sparams_in1.',fns1{ii},',sparams_in2.',fns2{ii},'];']);
                %
            end
            %
        else
            %
            disp('WARNING : The sparams structures are not compatible for the merge. Some fields are inconsistent. Modify them first.');
            %
        end
        %
    else
        %
        disp('WARNING : Both sparams structures are not compatible for the merge. Their length is different'); 
        %
    end
    %
end
%
if isfield(sparams_in1,'help') && isfield(sparams_in1,'format')
    sparams_out.help = sparams_in1.help;
    sparams_out.format = sparams_in1.format;
end
%