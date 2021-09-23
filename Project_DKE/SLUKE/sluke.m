function sluke(varargin)
%
% LUKE - Full calculations of LUKE with sub-time intervals (option). All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structure
%
% OUTPUT : none
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 2
    %
   diary(['log_sluke_',varargin{2},'_',strrep(datestr(now),' ','_')]);
    %
else
    %
    diary(['log_sluke_',strrep(datestr(now),' ','_')]);
    %
end
%
sparams_in = varargin{1};
%
sparams = sluke_params_time(sparams_in);%Expand all time steps if any
%
disp(' ')
disp('---------------------------------------------')
disp(['SLUKE simulation environment'])
%
if nargin == 2
    %
    disp(['Script source : ',varargin{2},'.m']);
    %
end
disp([int2str(length(sparams.machine)),' simulations are considered'])
%
disp('---------------------------------------------')
%
[success,messages] = sluke_create_folders;
%
if ~success
    %
    disp('ERROR : cannot create sluke folders in the local directory')
    return;
    %
end
%
% run sluke locally or remotely
%
for ii = 1:length(sparams.machine)
    %
    antenna_remote_status = 0;
    %
    disp(' ')
    disp(['Simulation #',int2str(ii),' [machine : ',sparams.machine{ii},', shot : #',sparams.discharge.shot{ii},', tmin : ',num2str(sparams.discharge.tmin{ii}),' (s), tmax : ',num2str(sparams.discharge.tmax{ii}),'(s), ID : ',sparams.simul.id{ii},'] ...']);
    %
    if sparams.simul.enable{ii} == 1
        %
        simul_id = sluke_id(sparams,ii,'simul');
        %
        if sparams.simul.enforce{ii} == 1
            %
            sluke_clear_folders(sparams,ii);
            %
        end
        %
        mute = sluke_params_value(sparams.simul.mute,ii);
        mute_fns = fieldnames(mute);
        %
        for jj = 1:length(mute_fns)
            %
            eval(['global mute_',mute_fns{jj},'; mute_',mute_fns{jj},' = ',int2str(mute.(mute_fns{jj})),';']);
            %
        end
        %
        if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']) && ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %~
            load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'],'lukestructs')
            %
            if ~isfield(lukestructs,'output')
                %
                dkepath = lukeschedulerparam('',0,sparams.simul.remote_profile{ii},~sparams.simul.wait4results{ii});
                %
                lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
                %
            end
            %
        elseif ~exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']) && ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %
            lukestructs.simul.id = simul_id;
            %lukestructs.simul.locid = '';
            %lukestructs.simul.path = 'SLUKE_RESULTS/';
            %
            if isfield(sparams.kinetics,'opt')
                %
                lukestructs.opt = sparams.kinetics.opt;
                %
            end
            %
            lukestructs.dkeparam = sluke_dkeparam(sparams,ii);
            %
            lukestructs.dkedisplay = sluke_dkedisplay(sparams,ii);
            %
            lukestructs.equil = sluke_equil(sparams,ii);
            %
            lukestructs.ohm = sluke_ohm(sparams,ii);
            %
            [lukestructs.wavestructs,antenna_remote_status] = sluke_wavestructs(sparams,ii);
            %
            lukestructs.transpfaste = '';% sluke_transp(sparams,ii);
            %
            lukestructs.ripple = '';% sluke_ripple(sparams,ii);
            %
            if isempty(antenna_remote_status) || antenna_remote_status == 0  %antenna calculations are done or no antenna calculations
                %
                dkepath = lukeschedulerparam('',0,sparams.simul.remote_profile{ii},~sparams.simul.wait4results{ii});
                lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
                %
            elseif antenna_remote_status == 1
                %
                cprintf('*green',['Antenna calculations are running for simulation ',int2str(ii),'. Restart the simulation script to get back antenna results and run LUKE calculations.'])
                %
            elseif antenna_remote_status == -1
                %
                cprintf('*red',['WARNING : Antenna calculations failed for simulation ',int2str(ii),'. Check files before restarting the simulation script to run LUKE calculations.'])
                %
            end
            %
        elseif exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %
            lukestructs = [];
            %
            cprintf('*green',['---> is completed but full simulation is not saved, just processed results.']);
            %
        end
        %
        if ~isempty(lukestructs) && exist('antenna_remote_status','var') && (isempty(antenna_remote_status) || antenna_remote_status == 0)
            %
            if isfield(lukestructs,'output') %job done
                %
                try
                    %
                    sluke_postprocessing(sparams,lukestructs,ii);% Data postprocessing
                    sluke_diagnostics(sparams,lukestructs,ii);% Synthetic diagnostic calculations
                    sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd for display or specific interactive run
                    %
                catch
                    %
                     sparams.simul.save{ii} = 1;%Full simulaton backup is enforced 
                     sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd for display or specific interactive run
                    %
                end
                %
            elseif isfield(lukestructs,'err') %job failed
                %
                cprintf('*red',['---> has failed for the following reasons :' ]);
                %
                disperr_jd(lukestructs.err)
                %
                cprintf('*red',['---> is cancelled.'])
                %
                delete(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
                %
            elseif isfield(lukestructs,'job') %job run
                %
                cprintf('*blue',['---> is running on host : ',lukestructs.job.remote.host,' with job id : ',lukestructs.job.timeid]);
                %
                sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd is calculations are done
                %
            else
                %
                cprintf('*red',['---> has a problem (output not recognized. Check if this not a just a connection problem before cancelling the simulation by deleting the LUKE_DATA file).'])
                %
            end
            %
            if sparams.simul.enforce{ii} == 1
                %
                cprintf([1,0.5,0],['---> has been enforced. Set sparams.simul.enforce{',int2str(ii),'} to zero in the script file to avoid infinite calculation loop.'])
                %
            end
            %
        end
        %
        clear lukestructs dkepath
        %
    else
        cprintf('*blue',['---> is not enabled.'])
    end
    %
end
%
diary off
%
cprintf('black',' ');%return to default color black
%

