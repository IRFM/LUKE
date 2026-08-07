% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function varargout = F_help_scheduler(key)
%   F_help_scheduler()
%   help = F_help_scheduler(key)
%
%plot help for scheduler substruct or find help for specific field of 
%scheduler defined in key

tp.nodes    = "Number of nodes requested or node names (see PBS syntax). If empty or NaN, default value. For pbs, type 'pbsnodes -a' to get the list of node names";
tp.ppn      = "Number of processors requested on the same node. if empty or NaN, default value requested.";
tp.select   = "Number of separate nodes. If empty or NaN, default value. Type 'pbsnodes -a' to get the list of nodesand their charateristics";
tp.ncpus    = "Number of cpus per node (must be even number). If empty or NaN, default value.";
tp.memory   = "Job memory in Mbytes (should be increased for large calculation grids). See the cluster limitations";
tp.walltime = "Job walltime in hours";
tp.ncores   = "Number of cores. If empty or NaN, default value";

if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end