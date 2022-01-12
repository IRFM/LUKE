function [launchs,remote_status] = sluke_build_launchs(sparams,ii,kk)
%
% LUKE - Build antenna array of cells for C3PO ray-tracing calculations (remote and distributed)
%
% INPUT :
%
%   - sparams : sluke parameters structure (reference : sparams.machine)
%   - ii : index in the structure
%   - kk : index in the substructure
%
% OUTPUT :
%
%   - antennas : structure for antennas.
%   - remote_status : status of remote calculations
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if ~ismember('mute_sluke_build_launchs', who('global'))
    mute_sluke_build_launchs = 0;
else
    global mute_sluke_build_launchs
end
%
if nargin == 2
    %
    kk = 1;
    %
end
%
launchs = {};
remote_status = 0;
%
[err,status] = sluke_params_consistency(sparams);
%
if err == 0
    %
    % Lower hybrid wave
    %
    if sparams.simul.enable{ii} && isfield(sparams,'rfwaves')
        %
        for kk = 1:length(sparams.rfwaves.antenna.type{ii})
            %
            if strfind(sparams.rfwaves.antenna.type{ii}{kk},'LH')
                %
                if strcmp(sparams.rfwaves.antenna.source{ii}{kk},'code')
                    %
                    if strcmp(sparams.rfwaves.antenna.code{ii}{kk},'ALOHA')
                        %
                        flag_display_powerspectrum = 1;
                        %
                        if exist('SLUKE_RFWAVES')
                            %
                            rfwaves_folder = 'SLUKE_RFWAVES/';
                            %
                        else
                            %
                            rfwaves_folder = '';
                            %
                        end
                        %
                        if ~exist([rfwaves_folder,'ALOHA/Simulations/'])
                        	mkdir([rfwaves_folder,'ALOHA/Simulations/'])
                        end
                        %
                        id_data = [sparams.machine{ii},'_data_lh_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                            '_',num2str(sparams.discharge.tmax{ii}),'_',sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk}];
                        %
                        if sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.method{ii}{kk} == 0
                            id_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                                '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},...
                                '_ne_',num2str(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.ne_guess{ii}{kk}/1e17)];
                        else
                            id_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                                '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},'_ne_optim'];
                        end
                        %
                        if ~exist([rfwaves_folder,'ALOHA/Simulations/',id_aloha,'.mat'])
                            %
                            aloha.remote.profile = sluke_remote_profile(sparams,ii,kk);
                            aloha.id = id_aloha;
                            aloha.optim.id = id_aloha;
                            aloha.optim.id_data = id_data;
                            aloha.optim.method = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.method{ii}{kk};
                            aloha.optim.ne_guess = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.ne_guess{ii}{kk};
                            %
                            if sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.method{ii}{kk} == 1
                                %
                                aloha.optim.tolfun = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.tolfun{ii}{kk};
                                aloha.optim.tolx = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.tolx{ii}{kk};
                                aloha.optim.nitmax = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.nitmax{ii}{kk};
                            end
                            %
                            if abs(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).display.data.mode{ii}{kk})
                                %
                                display_data.display_mode = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).display.data.mode{ii}{kk};
                                display_data.display_save = sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).display.data.save{ii}{kk};
                                display_data.display_path = [rfwaves_folder,'ALOHA/'];
                                %
                            else
                                %
                                display_data.display_mode = 0;%no display
                                display_data.display_save = 0;%no display
                                display_data.display_path = '';
                                %
                            end
                            %
                            if isfield(sparams.simul,'dataload') && isfield(sparams.simul.dataload,'remote_enforce') && ~isempty(sparams.simul.dataload.remote_enforce{ii})
                                %
                                dataload_remote_enforce = sparams.simul.dataload.remote_enforce{ii};
                                %
                            else
                                %
                                dataload_remote_enforce = 0;
                                %
                            end
                            %
                            if sparams.simul.remote_profile{ii} == 0 || strcmp(sparams.simul.remote_profile{ii},'local') %local sluke calculations done. Wait for results
                                %
                                aloha.remote.timeout = 30;%
                                %
                            end
                            %
                            antennas = run_aloha_remote(sparams.machine{ii},...
                                sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},...
                                sparams.discharge.shot{ii},sparams.discharge.tmin{ii},...
                                sparams.discharge.tmax{ii},...
                                sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).display.results{ii}{kk},...
                                aloha,display_data);
                            %
                            flag_run = 0;
                            %
                            for jj = 1:length(antennas)
                                antennas(jj).aloha.optim = aloha.optim;
                                %
                                if isfield(antennas(jj).aloha,'job')
                                    %
                                    flag_run = flag_run + 1;
                                    %
                                end
                            end
                            %
                            save([rfwaves_folder,'ALOHA/Simulations/',id_aloha,'.mat'],'antennas')
                            % 
                            if flag_run > 0
                                %
                                cprintf('*blue',['---> ALOHA antenna calculations (',id_aloha,') are in progress.']);disp(' ');
                                %
                            else
                                %
                                cprintf('*blue',['---> ALOHA antenna calculations (',id_aloha,') are done.']);disp(' ');
                                %
                            end
                            %
                            for jj = 1:length(antennas) %full or half antenna
                                %
                                if isfield(aloha.remote,'timeout') &&  aloha.remote.timeout > 0
                                    %
                                    flag_job(ii,jj) = 0;%results are obtained. 
                                    %
                                else
                                    %
                                    flag_job(ii,jj) = 1;
                                    %
                                end
                                %
                                launchs{jj}.remote_status = flag_job(ii,jj);
                                %
                                launchs{jj}.antennas = antennas(jj);
                                %
                            end
                            %
                        else
                            %
                            if mute_sluke_build_launchs == 0
                                disp(['---> ALOHA simulation status (ID:',id_aloha,') :'])
                            end
                            %
                            load([rfwaves_folder,'ALOHA/Simulations/',id_aloha,'.mat'],'antennas');%load results or job
                            %
                            if isfield(antennas(1).aloha,'optim')
                                %
                                optim = antennas(1).aloha.optim;
                                %
                            end
                            %
                            antennas = run_aloha_remote(antennas);
                            %
                            if ~isfield(antennas(1).aloha,'optim') &&  ~isfield(antennas(1).aloha,'err')
                                %
                                for jj = 1:length(antennas)
                                    %
                                    antennas(jj).aloha.optim = optim;
                                    %
                                end
                                %
                            end
                            %
                            save([rfwaves_folder,'ALOHA/Simulations/',id_aloha,'.mat'],'antennas');%save results or job
                            %
                            for jj = 1:length(antennas)
                                %
                                if isfield(antennas(jj).aloha,'job')
                                    %
                                    cprintf('*blue',[' - ALOHA antenna calculations for job #',int2str(jj),' for ',id_aloha,' are still in progress.']);disp(' ');
                                    flag_job(ii,jj) = 1;
                                    %
                                elseif isfield(antennas(jj).aloha,'err')
                                	%
                                    cprintf('*red',[' - ALOHA antenna calculations for job #',int2str(jj),' for ',id_aloha,' failed. Load SLUKE_RFWAVES/ALOHA/Simulations/',id_aloha,'.mat file and type antennas.aloha in the command to see the error.']);disp(' ');
                                    flag_job(ii,jj) = -1;
                                    %
                                else
                                    %
                                    cprintf('*green',[' - ALOHA antenna calculations for job #',int2str(jj),' for ',id_aloha,' are done.']);disp(' ');
                                    flag_job(ii,jj) = 0;
                                    %
                                end
                                %
                            end
                            %
                            if sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.comparison{ii}{kk} == 1 && sum(abs(flag_job(ii,:))) == 0 % power spectra are independent of the density in front of the grill. Just the first is plotted
                                %
                                load([rfwaves_folder,'ALOHA/Data/',id_data,'.mat'],'data_lh') 
                                %
                                display_lhdata(data_lh,sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).display.data{ii}{kk});
                                %
                                flag_display_powerspectrum = display_aloha_powerspectrum(flag_display_powerspectrum,data_lh,antennas,sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).display.results{ii}{kk});
                                %
                            end
                            %
                        end
                        %
                        for jj = 1:length(antennas)  %full or half antenna
                            %
                            launchs{jj}.flag_job = flag_job(ii,jj);
                            %
                            launchs{jj}.antennas = antennas(jj);
                            %
                        end
                        %
                        for jj = 1:length(antennas)  %full or half antenna
                            %
                            if abs(flag_job(ii,jj)) == 1
                                %
                                remote_status = flag_job(ii,jj);
                                break
                                %
                            end
                            %
                        end
                        %
                    else
                        %
                        disp('WARNING : unkown antenna coupling code for the Lower Hybrid wave');
                        return;
                        %
                    end
                    %
                elseif strcmp(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).source{ii},'file')
                    %
                    %TODO file option
                    %
                elseif strcmp(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).source{ii},'value')
                    %
                    %TODO value option
                    %
                end
                %
            elseif strcmp(sparams.rfwaves.antenna.type{ii}{kk},'EC')
                %
                % TODO : implement EC wave
                %
                disp('EC wave not yet available')
                return;
                %
            end
            %
        end
        %
    end
    %
else
    %
    disp('WARNING : inconsistencies in sparams structure.')
    %
end





