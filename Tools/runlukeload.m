function [soutput] = runlukeload(job)
%
% This function saves the structure sinput in a mat file tagged by logname and timeid 
%
if isfield(job,'localdatapath') && ~isempty(job.localdatapath),% remote data location
    localdatapath = [job.localdatapath,filesep];
else
    localdatapath = '';
end
%
load_id = job.load_id;
soutput = load([localdatapath,load_id]);