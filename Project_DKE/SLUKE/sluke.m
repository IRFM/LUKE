function [varargout] = sluke(varargin)
%
varargout{1} = '';
%
sparams_in = varargin{1};
%
sparams = sluke_params_time(sparams_in);%Expand all time steps if any
%
[success,messages] = sluke_create_folders;
%
if ~success
    disp('ERROR : cannot create sluke folders in the local directory')
    return;
end
%
% run sluke locally or remotely
%
for ii = 1:length(sparams.machine)
    %
    if sparams.simul.enable{ii} == 1
        %
        simul_id = sluke_id(sparams,ii,'simul');
        %
        if sparams.simul.enforce{ii} == 1;
            %
            sluke_clear_folders(sparams,ii);
            %
        end
        %
        if exist(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'])
            %
            load(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat'])
            %
            dkepath = lukeschedulerparam('',0,sparams.simul.remote_profile{ii},~sparams.simul.wait4results{ii});
            %
            lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
            %
        else
            %
            lukestructs.simul_in = simul_id;
            lukestructs.equil = sluke_equil(sparams,ii);
            %
            load('INPUTS/before_luke@WEST_54802_3.7000_ADAS.mat','dkeparam');
            load('INPUTS/before_luke@WEST_54802_3.7000_ADAS.mat','dkedisplay');
            load('INPUTS/before_luke@WEST_54802_3.7000_ADAS.mat','ohm');
            %
            lukestructs.dkeparam = dkeparam;
            lukestructs.dkedisplay = dkedisplay;
            lukestructs.ohm = ohm;
            
            %{
            %lukestructs.dkeparam = sluke_dkeparam(sparams,ii);
            %lukestructs.dkedisplay = sluke_dkedisplay(sparams,ii);
            %lukestructs.ohm = '';% sluke_ohm(sparams,ii);
            %}
            lukestructs.wavestructs = '';%waves{ii};sluke_launch(sparams)
            lukestructs.transpfaste = '';% sluke_transp(sparams,ii);
            lukestructs.ripple = '';% sluke_ripple(sparams,ii);
            %
            dkepath = lukeschedulerparam('',0,sparams.simul.remote_profile{ii},~sparams.simul.wait4results{ii});
            %
            lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
            %
        end
        %
        if isfield(lukestructs,'output'),%job was run successfully
            %
            disp(['LUKE simulation #',int2str(ii),' is completed. You can use irunluke_jd to display results or perform specific calculations.']);
            %
            sluke_save(sparams,simul_id,lukestructs);%save results and make them comptible with irunluke_jd is calculations are done
            %
        elseif isfield(lukestructs,'err') %job failed
            %
            disp(['LUKE simulation #',int2str(ii),' has failed for the following reasons :' ]);
            %
            disperr_jd(lukestructs.err)
            %
            disp(['Simulation #',int2str(ii),' is cancelled.'])
            %
            delete(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
            %
        elseif isfield(lukestructs,'job') %job running, to be checked later
            %
            disp(['LUKE simulation #',int2str(ii),' is running.']);
            %
            sluke_save(sparams.machine{ii},simul_id,lukestructs);%save results and make them comptible with irunluke_jd is calculations are done
            %
            %luke_job = lukestructs.job;
            %
        else
            %
            disp(['LUKE output for simulation #',int2str(ii),' is not recognized. Simulation is cancelled.'])
            %
            delete(['SLUKE_RESULTS/LUKE_DATA_',simul_id,'.mat']);
            %
        end
        %
        clear lukestructs dkepath
        %
    else
        disp(['WARNING : simulation #',int2str(ii),' is not enabled. Modify the sparams file to enable it.'])
    end
    %
end