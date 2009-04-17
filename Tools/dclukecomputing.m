function [flag,results] = dclukecomputing(fun,args_in,arg_index,arg_range,nargout_in,dkecluster)
%LUKE - LUKE distributed computing environment
%
%   Distributed computing using the LUKE distributed computing environment
%
%   INPUT:
%
%       - fun: function handle
%       - args_in: input arguments list of the function
%       - arg_index: index in the argument list args_in which must be changed
%       - arg_range: list of values to be calculated for the input argument arg_index, length(arg_range) = number of times a calculation must be performed
%       - nargout_in: number of output arguments in the parent function
%
%   OUTPUT:
%
%		- flag: status of the computing (OK = 0, ERROR = 1)
%       - results: output arguments list of the function
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
results = cell(1,nargout_in);
narg_range = length(arg_range);
%
try
    %
    dcluke(dkecluster,0,'RESET');
    %
    id = NaN(1,narg_range);
    arg_out = cell(nargout_in,narg_range);
    %
    for j_range = 1:narg_range,
        args_in{arg_index} = arg_range{j_range};
        id(j_range) = dcluke(dkecluster,func2str(fun),args_in{:});      
    end
    %
    dcluke(dkecluster);
    %
    for j_range = 1:narg_range,
        %
        outcmd = '';
        %
        for j_nargout = 1:nargout_in,
            %
            if j_nargout == 1,
                outcmd = '[,';
            end
            %
            outcmd = [outcmd,'arg_out{',int2str(j_nargout),',',int2str(j_range),'}'];
            %
            if j_nargout == nargout_in,
                outcmd = [outcmd,'] = '];
            else
                outcmd = [outcmd,','];
            end
        end
        %
        cmd = [outcmd,'dcluke(dkecluster,',int2str(id(j_range)),');'];      
        %
        eval(cmd);
        %
    end
    %
    for j_nargout = 1:nargout_in,
        results{j_nargout} = reshape(arg_out(j_nargout,:),narg_range,1);
    end
    %
    flag = 2;
catch
    for j_nargout = 1:nargout_in,
        results{j_nargout} = '';
    end
    flag = -2;
end
%