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
   diary(['SLUKE_LOGS/log_sluke_',varargin{2},'_',strrep(datestr(now),' ','_')]);
    %
else
    %
    diary(['SLUKE_LOGS/log_sluke_',strrep(datestr(now),' ','_')]);
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
           % lukestructs.diags =  sluke_diagnostics(sparams,ii);
            %
            if isempty(antenna_remote_status) || antenna_remote_status == 0  %antenna calculations are done or no antenna calculations
                %
                dkepath = lukeschedulerparam('',0,sparams.simul.remote_profile{ii},~sparams.simul.wait4results{ii});
                lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
                %
            elseif antenna_remote_status == 1
                %
                cprintf('*green',['Antenna calculations are running for simulation ',int2str(ii),'. Restart the simulation script to get back antenna results and run LUKE calculations automatically.']);disp(' ')
                %
            elseif antenna_remote_status == -1
                %
                cprintf('*red',['WARNING : Antenna calculations failed for simulation ',int2str(ii),'. Check files before restarting the simulation script to run LUKE calculations.']);disp(' ')
                %
            end
            %
        elseif exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
            %
            cprintf('*green',['---> is completed but full simulation is not saved, just processed results.']);disp(' ')
            %
            if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'])
                %
                load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'],'lukestructs');
                %
            else
                %
                lukestructs = [];
                %
            end
            %
        end
        %
        if ~isempty(lukestructs) && exist('antenna_remote_status','var') && (isempty(antenna_remote_status) || antenna_remote_status == 0)
            %
            if isfield(lukestructs,'output') %job done
                %
                try
                    %
                    sluke_postprocessing(sparams,ii,lukestructs);% Data postprocessing
                    sluke_diagnostics(sparams,ii,lukestructs);% Synthetic diagnostic calculations
                    sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd for display or specific interactive run
                    %
                catch
                    %
                    cprintf('*red',['---> error in postprocessing or synthetic diagnostics calculations. Full LUKE results are temporarily backed-up.' ]);disp(' ')
                    %
                    save (['SLUKE_RESULTS/BACKUP_LUKE_DATA_',simul_id,'.mat'],'sparams','lukestructs','ii');
                    %
                end
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
            elseif isfield(lukestructs,'job') %job run
                %
                if exist(['batch_',lukestructs.job.timeid],'dir')
                    %
                    cprintf('*blue',['---> is running on host : ',lukestructs.job.remote.host,' with job id : ',lukestructs.job.timeid]);disp(' ')
                    %
                    sluke_save(sparams,ii,lukestructs);%save results and make them comptible with irunluke_jd is calculations are done
                    %
                else
                    %
                    cprintf('*red',['---> is orphan. No more folder batch_',lukestructs.job.timeid,'. It is therefore canceled']);disp(' ')
                    %delete results
                    %
                end
            else
                %
                cprintf('*red',['---> has a problem (output not recognized. Check if this not a just a connection problem before cancelling the simulation by deleting the LUKE_DATA file).']);disp(' ')
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
        clear lukestructs dkepath
        %
    else
        cprintf('*blue',['---> is not enabled.']);disp(' ')
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

