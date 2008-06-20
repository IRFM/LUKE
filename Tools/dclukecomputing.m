function [flag,results] = dclukecomputing(fun,args_in,arg_index,arg_range,nargout_in)
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
    try,
    	dirini = pwd;
		if exist(fullfile(getenv('HOME'),'tmp'))
			cd(fullfile(getenv('HOME'),'tmp'));
			filelist = ls;
			if isempty(filelist),
				delete('*');
			end
		end
		cd(dirini);
		%
		dcluke(0,'RESET');
		%
    	for j_range = 1:length(arg_range),
        	args_in{arg_index} = arg_range{j_range};
        	id(j_range) =  dcluke(func2str(fun),args_in{:});      
    	end
    	%
    	dcluke;
    	%
    	for j_range = 1:length(arg_range),
        	cmd = ['[arg_out{1,',int2str(j_range),'}'];
        	if nargout_in-1 > 1,
            	for j_nargout = 2:nargout_in-1,
                	cmd = [cmd,',arg_out{',int2str(j_nargout),',',int2str(j_range),'}'];
            	end
        	end
        	cmd = [cmd,'] = dcluke(',int2str(id(j_range)),');'];      
        	eval(cmd);
    	end
    	%
    	for j_nargout = 1:nargout_in-1,
        	results{j_nargout} = reshape(arg_out(j_nargout,:),length(arg_range),1);
    	end
    	%
    	flag = 2;
    catch
        for j_nargout = 1:nargout_in-1,
        	results{j_nargout} = '';
    	end
    	flag = -2;
    end
    %
end