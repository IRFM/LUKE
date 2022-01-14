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
    if ~exist('SLUKE_LOGS','dir')
    	mkdir('SLUKE_LOGS')
    end
    %
    diary(['SLUKE_LOGS/log_sluke_',varargin{2},'_',strrep(datestr(now),' ','_')]);  
    %
else
    %
    if ~exist('SLUKE_LOGS','dir')
    	mkdir('SLUKE_LOGS')
    end
    %
    diary(['SLUKE_LOGS/log_sluke_',strrep(datestr(now),' ','_')]);
    %
end
%
sparams_in = varargin{1};
%
sparams = sluke_params_time(sparams_in);%Expand all time steps if any
%
if isfield(sparams.simul,'max_simulations')
    %
    for ii = 1:length(sparams.machine)
        %
        kkmax(sluke_remote_profile(sparams,ii)+1) = sparams.simul.max_simulations{ii};
        %
    end
    %
else
    %
    for ii = 1:length(sparams.machine)
        %
        kkmax(sluke_remote_profile(sparams,ii)+1) = Inf;%No limit
        %
    end
    %
end
%
kk = zeros(size(kkmax));
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
if length(sparams.machine) > 1
    %
    disp([int2str(length(sparams.machine)),' simulations are considered'])
    %
else
    %
    disp([int2str(length(sparams.machine)),' simulation is considered'])
    %    
end
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
    flag_queing = 0;
    %
    disp(' ')
    %
    disp(['Simulation #',int2str(ii),' [machine : ',sparams.machine{ii},', shot : #',sparams.discharge.shot{ii},', tmin : ',num2str(sparams.discharge.tmin{ii}),' (s), tmax : ',num2str(sparams.discharge.tmax{ii}),'(s), ID : ',sparams.simul.id{ii},'] ...']);
    %
    if sparams.simul.enable{ii} == 1
        %
        simul_id = sluke_id(sparams,ii);
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
        if isfield(sparams.simul,'jprofileconsistency') && isfield(sparams.simul.jprofileconsistency,'nit') && sparams.simul.jprofileconsistency.nit{ii} >= 1
            %
            if exist(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'])
                %
                load(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat']);
                %
                if iscell(equil)
                    %
                    jit = length(equil);
                    %
                end
                %
                clear equil
                %
            end
            %
            jitmax = sparams.simul.jprofileconsistency.nit;
            %
        else
            %
            jitmax = 1;
            jit = 1;
            %
        end
        %
        if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']) && ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %~
            load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'],'lukestructs')
            %
            if ~isfield(lukestructs,'output')
                %
                dkepath = lukeschedulerparam('',0,sluke_remote_profile(sparams,ii),~sparams.simul.wait4results{ii});
                %
                lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
                %
            end
            %
        elseif ~exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']) && ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %
            if kk(sluke_remote_profile(sparams,ii)+1) < kkmax(sluke_remote_profile(sparams,ii)+1)
                %
                lukestructs.simul.id = simul_id;
                %lukestructs.simul.locid = '';
                lukestructs.simul.path = 'SLUKE_TEMP/';%for specific LUKE output
                %
                lukestructs.opt = sluke_opt(sparams,ii);
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
                lukestructs.transpfaste = sluke_transpfaste(sparams,ii);
                %
                lukestructs.ripple = sluke_ripple(sparams,ii);
                %
                lukestructs.diags =  sluke_diagnostics(sparams,ii,'',lukestructs.equil);
                %
                if sparams.simul.initial_distribution{ii} == -1
                    %
                    if exist(['SLUKE_RESULTS/PROC_LUKE_LUKE_DATA_',sluke_id(sparams,ii-1),'.mat'])
                        %
                        load(['SLUKE_RESULTS/LUKE_LUKE_DATA_',sluke_id(sparams,ii-1),'.mat'])
                        %
                        %TODO :calculate interpolated previous distribution on the new grid
                        %
                    else
                        %
                        break;%wait for previous time 
                        %
                    end
                    %
                end
                %
                if isempty(antenna_remote_status) || antenna_remote_status == 0  %antenna calculations are done or no antenna calculations
                    %
                    dkepath = lukeschedulerparam('',0,sluke_remote_profile(sparams,ii),~sparams.simul.wait4results{ii});
                    %
                    if sluke_remote_profile(sparams,ii) > 0
                        %
                        cprintf('*blue',['---> is being transferred to the remote computer']);disp(' ')
                        %
                    else
                        %
                        cprintf('*blue',['---> has started on the local computer']);disp(' ')
                        %
                    end
                    %
                    lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
                    %
                elseif antenna_remote_status == 1
                    %
                    cprintf('*green',['Antenna calculations are running for simulation #',int2str(ii),'. Restart the simulation script to get back antenna results and run LUKE calculations automatically.']);disp(' ')
                    %
                elseif antenna_remote_status == -1
                    %
                    cprintf('*red',['WARNING : Antenna calculations failed for simulation #',int2str(ii),'. Check files before restarting the simulation script to run LUKE calculations.']);disp(' ')
                    %
                end
                %
            else
                %
                cprintf('*blue',['---> is queing (max number of running simulations : ',int2str(kkmax(sluke_remote_profile(sparams,ii)+1)),')']);disp(' ')
                %
                flag_queing = 1;
                %
                lukestructs = [];
                %
            end
            %
        elseif exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %
            
            %
            if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'])
                %
                luke_data = load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
                %
                if exist('luke_data','var') && ~isempty(luke_data) && isfield(luke_data,'output') && ~isempty(luke_data.output)
                    %
                    cprintf('*green',['---> has been completed : full and processed results are saved.']);disp(' ')
                    %
                else
                    %
                    cprintf('*green',['---> has been completed : only processed results are saved.']);disp(' ')
                    %
                end
                %
            else
                %
                luke_data = [];
                %
                cprintf('*green',['---> has been completed : only processed results are saved.']);disp(' ')
                %
            end
            %
        end
        %
        if exist('lukestructs','var') && ~isempty(lukestructs) && exist('antenna_remote_status','var') && (isempty(antenna_remote_status) || antenna_remote_status == 0)
            %
            if (isfield(lukestructs,'data_proc') && ~isempty(lukestructs.data_proc)) || (isfield(lukestructs,'output') && ~isempty(lukestructs.output)) %job done
                %
                if jitmax > 1 %current density profile self-consistency
                    %
                    jit = sluke_jconsistencty(sparams,ii,lukestructs);%update toroidal MHD equilibrium a,d Ohmic electric field
                    %
                else
                    %
                    jit = 1;
                    %
                end
                %
                try
                    %
                    sluke_postprocessing(sparams,ii,lukestructs);% Data postprocessing
                    %
                catch
                    %
                    cprintf('*red',['---> error in postprocessing calculations.' ]);disp(' ')
                    %  
                end
                %
                try
                    %
                    sluke_diagnostics(sparams,ii,lukestructs);% Synthetic diagnostic calculations
                    %
                catch
                    %
                    cprintf('*red',['---> error in synthetic diagnostics calculations.' ]);disp(' ')
                    %  
                end
                %                
                try
                    %
                    sluke_save(sparams,ii,lukestructs);%save results and make them compatible with irunluke_jd for display or specific interactive run
                    %
                catch
                    %
                    cprintf('*red',['---> error in savings simulation results.' ]);disp(' ')
                    %  
                end
                %                
                kk(sluke_remote_profile(sparams,ii)+1) = kk(sluke_remote_profile(sparams,ii)+1) - 1;
                %
            elseif isfield(lukestructs,'err') %job failed
                %
                cprintf('*red',['---> has failed for the following reasons :' ]);disp(' ')
                %
                disperr_jd(lukestructs.err)
                %
                cprintf('*red',['---> is cancelled.']);disp(' ')
                %
                delete(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
                %
                kk(sluke_remote_profile(sparams,ii)+1) = kk(sluke_remote_profile(sparams,ii)+1) - 1;
                %
            elseif isfield(lukestructs,'job') %job run
                %
                if exist(['batch_',lukestructs.job.timeid],'dir') || strcmp(lukestructs.job.remotedatapath,lukestructs.job.localdatapath)
                    %
                    t1 = char(datetime(lukestructs.job.time.started));%GMT time
                    t2 = char(datetime('now','TimeZone','UTC'));%GMT time
                    duration_job = datetime(t2) - datetime(t1);
                    %
                    if ~isnan(duration_job)
                        elapsed_time_sluke = [' since ',char(duration_job),' '];
                        action_sluke = 'is running';
                    else
                        if isempty(lukestructs.job.time.started)
                            %
                            elapsed_time_sluke = ' ';
                            action_sluke = 'is idle';
                            %
                        else
                            %
                            elapsed_time_sluke = ' ';
                            action_sluke = 'has started';
                            %
                        end
                    end
                    %    
                    if isempty(lukestructs.job.remote.host)
                        %
                        cprintf('*blue',['---> ',action_sluke,' locally',elapsed_time_sluke,'with job id : ',lukestructs.job.timeid]);disp(' ')
                        %
                    else
                        %
                        cprintf('*blue',['---> ',action_sluke,elapsed_time_sluke,'on host ',lukestructs.job.remote.host,' with job id : ',lukestructs.job.timeid]);disp(' ')
                        %
                    end
                    %
                    sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd is calculations are done
                    %
                    kk(sluke_remote_profile(sparams,ii)+1) = kk(sluke_remote_profile(sparams,ii)+1) + 1;
                    %
                else
                    %
                    cprintf('*red',['---> is orphan. No more folder batch_',lukestructs.job.timeid,'. It is therefore canceled']);disp(' ')
                    %
                end
            else
                %
                cprintf('*red',['---> has a problem (output not recognized. Check if this not a just a connection problem before cancelling the simulation by deleting the results of the simulation).']);disp(' ')
                %
            end
            %
            if sparams.simul.enforce{ii} == 1
                %
                cprintf([1,0.5,0],['---> has been enforced. Set sparams.simul.enforce{',int2str(ii),'} to zero in the script file to avoid infinite calculation loop.']);disp(' ')
                %
            end
            %
        end
        %
        if jit < jitmax
            %
            lukestructs.simul.id = simul_id;
            %
            %lukestructs.simul.locid = '';
            %lukestructs.simul.path = 'SLUKE_RESULTS/';
            %
            lukestructs.opt = sluke_opt(sparams,ii);
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
            lukestructs.transpfaste = sluke_transpfaste(sparams,ii);
            %
            lukestructs.ripple = sluke_ripple(sparams,ii);
            %
            lukestructs.diags =  sluke_diagnostics(sparams,ii);
            %
            dkepath = lukeschedulerparam('',0,sluke_remote_profile(sparams,ii),~sparams.simul.wait4results{ii});
            %
            cprintf('*blue',['---> is being transferred to the remote computer']);disp(' ')
            lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
            %
            if exist(['batch_',lukestructs.job.timeid],'dir') || strcmp(lukestructs.job.remotedatapath,lukestructs.job.localdatapath)
                    %
                    t1 = char(datetime(lukestructs.job.time.started));%GMT time
                    t2 = char(datetime('now','TimeZone','UTC'));%GMT time
                    duration_job = datetime(t2) - datetime(t1);
                    %
                    if ~isnan(duration_job)
                        elapsed_time_sluke = [' since ',char(duration_job),' '];
                        action_sluke = 'is running';
                    else
                        elapsed_time_sluke = ' ';
                        action_sluke = 'has started';
                    end
                    %    
                    if isempty(lukestructs.job.remote.host)
                        %
                        cprintf('*blue',['---> ',action_sluke,' locally',elapsed_time_sluke,'with job id : ',lukestructs.job.timeid]);disp(' ')
                        %
                    else
                        %
                        cprintf('*blue',['---> ',action_sluke,elapsed_time_sluke,'on host ',lukestructs.job.remote.host,' with job id : ',lukestructs.job.timeid]);disp(' ')
                        %
                    end
                    %
                    sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd is calculations are done
                    %
                    kk(sluke_remote_profile(sparams,ii)+1) = kk(sluke_remote_profile(sparams,ii)+1) + 1;
            end
            %
        else
            %
            if exist('lukestructs','var') && isempty(lukestructs) && ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat']) && flag_queing == 0
                %
                cprintf('*red',['---> failed likely because of a Matlab error. Please run the simulation locally.']);disp(' ')
                %
            end  
            %
            clear lukestructs dkepath
            %
        end
        %
    else
        %
        cprintf('*[1,0.5,0]',['---> is not enabled.']);disp(' ')
        %
    end
    %
end
%
diary off
%
if exist('SLUKE_LOGS','dir')
    %
    filelist = dir;%local scan
    %
    for jj = 1:length(filelist)
        %
        if strfind(filelist(jj).name,'matlab_diary.')
            %
            movefile(filelist(jj).name,'SLUKE_LOGS/'); %move all diary done remotely in folder that contains logs
            %
        end
    end
    %
end
%
cprintf('black','');disp(' ');%return to default color black

