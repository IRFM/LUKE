function scheduler = sluke_remote_scheduler(sparams,ii)
%
scheduler = [];%no enforcement by default
%
if isfield(sparams.simul,'remote') & isfield(sparams.simul.remote,'scheduler') & ~isempty(sparams.simul.remote.scheduler{ii})
    %
    if strcmp(sparams.simul.remote.scheduler{ii},'pbs') %pbs scheduler options (see pbs documentation)
        %
        if isfield(sparams.simul.remote.pbs,'nodes') & ~isempty(sparams.simul.remote.pbs.nodes{ii}) & ~isnan(sparams.simul.remote.pbs.nodes{ii})
            %
            scheduler.nodes = sparams.simul.remote.pbs.nodes{ii};
            %   
        end
        %     
        if isfield(sparams.simul.remote.pbs,'ppn') & ~isempty(sparams.simul.remote.pbs.ppn{ii}) & ~isnan(sparams.simul.remote.pbs.ppn{ii})
            %
            scheduler.ppn = sparams.simul.remote.pbs.ppn{ii};
            %   
        end
        %

        if isfield(sparams.simul.remote.pbs,'select') & ~isempty(sparams.simul.remote.pbs.select{ii}) & ~isnan(sparams.simul.remote.pbs.select{ii})
            %
            scheduler.select = sparams.simul.remote.pbs.select{ii};
            %   
        end 
        %
        if isfield(sparams.simul.remote.pbs,'ncpus') & ~isempty(sparams.simul.remote.pbs.ncpus{ii}) & ~isnan(sparams.simul.remote.pbs.ncpus{ii})
            %
            scheduler.ncpus = sparams.simul.remote.pbs.ncpus{ii};
            %   
        end
        %
        if isfield(sparams.simul.remote.pbs,'memory') & ~isempty(sparams.simul.remote.pbs.memory{ii}) & ~isnan(sparams.simul.remote.pbs.memory{ii})
            %
            scheduler.memory = sparams.simul.remote.pbs.memory{ii};
            %   
        end
        %
        if isfield(sparams.simul.remote.pbs,'walltime') & ~isempty(sparams.simul.remote.pbs.walltime{ii}) & ~isnan(sparams.simul.remote.pbs.walltime{ii})
            %
            scheduler.walltime = sparams.simul.remote.pbs.walltime{ii};
            %   
        end
        %
    elseif strcmp(sparams.simul.remote.scheduler{ii},'torque') %torque scheduler options (see torque documentation)
        %
        cprintf('*[1,0.5,0]',['Specific options for ''torque'' scheduler not yet implemented. Default options for the remote profile ',sparams.simul.remote.profile{ii},' are considered.']);disp(' ')
        %
    elseif strcmp(sparams.simul.remote.scheduler{ii},'slurm') %slurm scheduler options (see slurm documentation)
        %
        cprintf('*[1,0.5,0]',['Specific options for ''slurm'' scheduler not yet implemented. Default options for the remote profile ',sparams.simul.remote.profile{ii},' are considered.']);disp(' ')
        %
    elseif strcmp(sparams.simul.remote.scheduler{ii},'htcondor') %htcondor scheduler options (see htcondor documentation)
        %
        cprintf('*[1,0.5,0]',['Specific options for ''htcondor'' scheduler not yet implemented. Default options for the remote profile ',sparams.simul.remote.profile{ii},' are considered.']);disp(' ')
        %
    else
        %
        cprintf('*[1,0.5,0]',['Scheduler ',sparams.simul.remote.scheduler{ii},' not recognized. ']);disp(' ')        
        %
    end
end
%
