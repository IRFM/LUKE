function [err,status] = sluke_params_consistency(sparams_in)
%
% LUKE - Check the consistency of the structure of simulation parameters for sluke calculations. All parameters are in an arrays of cells of the SAME SIZE. 
% 
% INPUT :
%
%   - sparams_in : sluke parameters structure (reference : sparams.machine)
%
% OUTPUT :
%
%   - err : error flag (0: no error, 1: error)
%   - status : list of field names where an error occurs (type status{:})
%
% NOTE : the consistency of the parameters themselves is not verified
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%

%
fns_in = fieldnamesr(sparams_in);
ihelp = find(contains(fns_in,'help'));
%
if ~isempty(ihelp)
    fns = fns_in(1:ihelp(1)-1);
else
    fns = fns_in;
end
%
nmachine = 0;
status = {};
err = 0;
%
for ii = 1:length(fns)
    %
    if strcmp(fns{ii},'machine')
        %
        nmachine = length(sparams_in(ii).machine);%reference number of simulations
        %
        break
    end
end
%
if nmachine == 0
    %
    status = 'ERROR in sparams structure : machine substructure is missing';
    err = 1;
    return;
    %
end
%
struct_maxdepth = 1;
%
kk = 1;
%
for ii = 1:length(fns)
    %
    if length(strfind(fns{ii},'.'))+1 > struct_maxdepth
        %
        struct_maxdepth = length(strfind(fns{ii},'.'))+1;
        %
    end
    %
    if length(eval(['sparams_in.',fns{ii}])) ~= nmachine
        %
        err = 1;
        status{kk} = ['Inconsistency --> length(sparams.',fns{ii},') not equal to ',int2str(nmachine)];
        kk = kk + 1;
        %
    end
    %
end
%