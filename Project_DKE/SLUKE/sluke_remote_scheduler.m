function scheduler = sluke_remote_scheduler(scheduler_type,sparams,ii)
%
scheduler = [];%no enforcement by default
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'scheduler')
    %
    if isfield(sparams.simul.remote.scheduler,scheduler_type) %pbs scheduler options (see pbs documentation)
        %
        if strcmp(scheduler_type,'pbs')
            %
            if isfield(sparams.simul.remote.scheduler.pbs,'nodes') & ~isempty(sparams.simul.remote.scheduler.pbs.nodes{ii}) & ~isnan(sparams.simul.remote.scheduler.pbs.nodes{ii})
                %
                scheduler.nodes = sparams.simul.remote.scheduler.pbs.nodes{ii};
                %   
            end
            %     
            if isfield(sparams.simul.remote.scheduler.pbs,'ppn') & ~isempty(sparams.simul.remote.scheduler.pbs.ppn{ii}) & ~isnan(sparams.simul.remote.scheduler.pbs.ppn{ii})
                %
                scheduler.ppn = sparams.simul.remote.scheduler.pbs.ppn{ii};
                %   
            end
            %

            if isfield(sparams.simul.remote.scheduler.pbs,'select') & ~isempty(sparams.simul.remote.scheduler.pbs.select{ii}) & ~isnan(sparams.simul.remote.scheduler.pbs.select{ii})
                %
                scheduler.select = sparams.simul.remote.scheduler.pbs.select{ii};
                %   
            end 
            %
            if isfield(sparams.simul.remote.scheduler.pbs,'ncpus') & ~isempty(sparams.simul.remote.scheduler.pbs.ncpus{ii}) & ~isnan(sparams.simul.remote.scheduler.pbs.ncpus{ii})
                %
                scheduler.ncpus = sparams.simul.remote.scheduler.pbs.ncpus{ii};
                %   
            end
            %
            if isfield(sparams.simul.remote.scheduler.pbs,'memory') & ~isempty(sparams.simul.remote.scheduler.pbs.memory{ii}) & ~isnan(sparams.simul.remote.scheduler.pbs.memory{ii})
                %
                scheduler.memory = sparams.simul.remote.scheduler.pbs.memory{ii};
                %   
            end
            %
            if isfield(sparams.simul.remote.scheduler.pbs,'walltime') & ~isempty(sparams.simul.remote.scheduler.pbs.walltime{ii}) & ~isnan(sparams.simul.remote.scheduler.pbs.walltime{ii})
                %
                scheduler.walltime = sparams.simul.remote.scheduler.pbs.walltime{ii};
                %   
            end
            %
        elseif strcmp(scheduler_type,'torque') %torque scheduler options (see torque documentation)
            %
            cprintf('*[1,0.5,0]',['Specific options for ''torque'' scheduler not yet implemented. Default options for the remote profile ',sparams.simul.remote.profile{ii},' are considered.']);disp(' ')
            %
        elseif strcmp(scheduler_type,'slurm') %slurm scheduler options (see slurm documentation)
            %
            cprintf('*[1,0.5,0]',['Specific options for ''slurm'' scheduler not yet implemented. Default options for the remote profile ',sparams.simul.remote.profile{ii},' are considered.']);disp(' ')
            %
        elseif strcmp(scheduler_type,'htcondor') %htcondor scheduler options (see htcondor documentation)
            %
            cprintf('*[1,0.5,0]',['Specific options for ''htcondor'' scheduler not yet implemented. Default options for the remote profile ',sparams.simul.remote.profile{ii},' are considered.']);disp(' ')
            %
        else
            %
            cprintf('*[1,0.5,0]',['Scheduler ',scheduler_type,' not recognized. ']);disp(' ')        
            %
        end
        %
    end
    %
end
%
