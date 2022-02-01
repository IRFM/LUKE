function scheduler = sluke_remote_scheduler(sparams,ii)
%
scheduler = [];%no enforcement by default
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'scheduler') && ~isempty(sparams.simul.remote.scheduler{ii})
    %
    if strcmp(sparams.simul.remote.scheduler{ii},'pbs') %pbs scheduler options (see pbs documentation)
        %
        if isfield(sparams.simul.remote.pbs,'ncpus') && ~isempty(sparams.simul.remote.pbs.ncpus{ii})
            %
            scheduler.ncpus = sparams.simul.remote.pbs.ncpus{ii};
            %   
        end
        %
        if isfield(sparams.simul.remote.pbs,'memory') && ~isempty(sparams.simul.remote.pbs.memory{ii})
            %
            scheduler.memory = sparams.simul.remote.pbs.memory{ii};
            %   
        end
        %
        if isfield(sparams.simul.remote.pbs,'walltime') && ~isempty(sparams.simul.remote.pbs.walltime{ii})
            %
            scheduler.walltime = sparams.simul.remote.pbs.walltime{ii};
            %   
        end
        %
        if isfield(sparams.simul.remote.pbs,'node') && ~isempty(sparams.simul.remote.pbs.node{ii})
            %
            scheduler.node = sparams.simul.remote.pbs.node{ii};
            %   
        end
        %
    end
    %
end
%
