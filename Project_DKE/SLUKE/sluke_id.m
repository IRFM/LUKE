function [id] = sluke_id(sparams,ii)
%
id_root = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),'_',num2str(sparams.discharge.tmax{ii}),'_',num2str(sparams.discharge.nt{ii})];
%
if isfield(sparams.simul,'id') && ~isempty(sparams.simul.id)
    %
    id = [id_root,'_',sparams.simul.id{ii},'_'];
    %
else
    %
    id = [id_root,'_'];
    %    
end
%
id = strrep(id,' ','_');
id = strrep(id,',','_');
id = strrep(id,';','_');
%
if strcmp(id(end),'_')
    %
    id = [id,'#',int2str(ii)];
    %
else
    %
    id = [id,'_#',int2str(ii)];
    %
end
