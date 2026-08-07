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
function luke_job = runluke_remote_jd(lukestructs,remote)
%
luke_job = matstandardjob_jd('runmat');
%
mat_input.fun = 'run_lukert';
mat_input.args_in = lukestructs;
mat_input.nargout = 2;
%
if isfield(lukestructs.dkeparam,'luke_memory'),
    luke_job.memory = lukestructs.dkeparam.luke_memory;% requested memory specified in dkeparam
elseif isfield(lukestructs,'transpfaste') && ~isempty(lukestructs.transpfaste), 
    luke_job.memory = 14000;%mb default value with transport
else
    luke_job.memory = 7000;%mb default value without transport
end
%
if isfield(lukestructs.dkeparam,'luke_ppn'),
    luke_job.nodes = 1;
    luke_job.ppn = lukestructs.dkeparam.luke_ppn;% requested memory specified in dkeparam
end
%
luke_job = remoterunbatch(remote,luke_job,mat_input);
%
