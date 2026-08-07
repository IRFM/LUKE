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
function scheduler = sluke_remote_scheduler(scheduler_type,sparams,ii)
%
scheduler = [];%no enforcement by default
%
if isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'scheduler')
    %
    if isfield(sparams.simul.remote.scheduler,scheduler_type) %pbs scheduler options (see pbs documentation)
        %
        if strcmp(scheduler_type,'pbs') || strcmp(scheduler_type,'torque')
            %
            if isfield(sparams.simul.remote.scheduler.(scheduler_type),'nodes') & ~isempty(sparams.simul.remote.scheduler.(scheduler_type).nodes{ii}) & ~isnan(sparams.simul.remote.scheduler.(scheduler_type).nodes{ii})
                %
                scheduler.nodes = sparams.simul.remote.scheduler.(scheduler_type).nodes{ii};
                %   
            end
            %     
            if isfield(sparams.simul.remote.scheduler.(scheduler_type),'ppn') & ~isempty(sparams.simul.remote.scheduler.(scheduler_type).ppn{ii}) & ~isnan(sparams.simul.remote.scheduler.(scheduler_type).ppn{ii})
                %
                scheduler.ppn = sparams.simul.remote.scheduler.(scheduler_type).ppn{ii};
                %   
            end
            %

            if isfield(sparams.simul.remote.scheduler.(scheduler_type),'select') & ~isempty(sparams.simul.remote.scheduler.(scheduler_type).select{ii}) & ~isnan(sparams.simul.remote.scheduler.(scheduler_type).select{ii})
                %
                scheduler.select = sparams.simul.remote.scheduler.(scheduler_type).select{ii};
                %   
            end 
            %
            if isfield(sparams.simul.remote.scheduler.(scheduler_type),'ncpus') & ~isempty(sparams.simul.remote.scheduler.(scheduler_type).ncpus{ii}) & ~isnan(sparams.simul.remote.scheduler.(scheduler_type).ncpus{ii})
                %
                scheduler.ncpus = sparams.simul.remote.scheduler.(scheduler_type).ncpus{ii};
                %   
            end
            %
            if isfield(sparams.simul.remote.scheduler.(scheduler_type),'memory') & ~isempty(sparams.simul.remote.scheduler.(scheduler_type).memory{ii}) & ~isnan(sparams.simul.remote.scheduler.(scheduler_type).memory{ii})
                %
                scheduler.memory = sparams.simul.remote.scheduler.(scheduler_type).memory{ii};
                %   
            end
            %
            if isfield(sparams.simul.remote.scheduler.(scheduler_type),'walltime') & ~isempty(sparams.simul.remote.scheduler.(scheduler_type).walltime{ii}) & ~isnan(sparams.simul.remote.scheduler.(scheduler_type).walltime{ii})
                %
                scheduler.walltime = sparams.simul.remote.scheduler.(scheduler_type).walltime{ii};
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
