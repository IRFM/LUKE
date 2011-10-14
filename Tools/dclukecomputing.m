function [flag,varargout] = dclukecomputing(fun_handle,args_in,arg_index,arg_range,scheduler)
% LUKE - LUKE distributed computing environment
%
%   Distributed computing using the LUKE distributed computing environment
%
%   INPUT:
%
%       - fun_handle: function handle
%       - args_in: input arguments list of the function {1,nargin}
%       - arg_index: index in the argument list args_in which must be changed [1,1]
%       - arg_range: list of values for the input argument arg_index [1,nrange]
%           => nrange = length(arg_range) = number of jobs 
%       - scheduler: scheduler information
%
%   OUTPUT:
%
%       - flag: status of the computation : scheduler.mode (OK with dclukecomputing) or -2 (failed) [1,nrange]
%       - varargout: output arguments list of the function {1,nargout-1}.
%           => Each element is a list of size {nrange,1}
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
nrange = length(arg_range);
varargout_array = cell(nrange,nargout-1);
flag = scheduler.mode*ones(1,nrange);
%
id = NaN(1,nrange);
%
try
    %
    dcluke(scheduler,0,'RESET');%initialisation
    %
    for j_range = 1:nrange,
        args_in{arg_index} = arg_range{j_range};
        id(j_range) = dcluke(scheduler,func2str(fun_handle),args_in{:});%submit jobs      
    end
    %
    dcluke(scheduler);%wait for job completion
    %
    for j_range = 1:nrange,
        %
        try
            [varargout_array{j_range,:}] = dcluke(scheduler,id(j_range));
        catch me_load
            disp(['Error loading the results for run ',int2str(j_range),'/',int2str(nrange),' : flagged for sequential run']);
            disp(['===> Error : ',getReport(me_load)]);
            flag(j_range) = -2;
        end
        %
    end
    %
catch me_dcluke
    disp('Error running dclukecomputing : flagged for sequential run');
    disp(['===> Error : ',getReport(me_dcluke)]);
    flag = -2*ones(1,nrange);
end
%
varargout = cell(1,nargout-1);
%
%[varargout{:}] = deal(cell(N_range,1)); keep this line as an example of use of the function deal
%
for j_argout = 1:nargout-1,
    %
    varargout{j_argout} = varargout_array(:,j_argout);
    %
end
%