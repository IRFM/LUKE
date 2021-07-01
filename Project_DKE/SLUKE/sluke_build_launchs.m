function launchs = sluke_build_launchs(sparams)
%
% LUKE - Build launchs array of cells for C3PO ray-tracing calculations (remote and distributed)
%
% INPUT :
%
%   - sparams : sluke parameters structure (reference : sparams.machine)
%
% OUTPUT :
%
%   - launchs : structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
launchs = {};
%
[err,status] = sluke_params_consistency(sparams);
%
if err == 0
    %
    for ii = 1:length(sparams.machine)
        %
        % Lower hybrid wave
        %
        if sparams.simul.enable{ii} && isfield(sparams,'launch')
            %
            if strcmp(sparams.launch.antenna.type{ii},'lh') || strcmp(sparams.launch.antenna.type{ii},'lh+ec')
                %
                if strcmp(sparams.launch.antenna.lh.spectrum.source.method{ii},'code')
                    %
                    if strcmp(sparams.launch.antenna.lh.spectrum.source.code{ii},'aloha')
                        %
                        flag_display_powerspectrum = 1;
                        %
                        if ~exist('ALOHA/Simulations/')
                            mkdir('ALOHA/Simulations/')
                        end
                        %
                        id_data = [sparams.machine{ii},'_data_lh_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                            '_',num2str(sparams.discharge.tmax{ii}),'_',sparams.launch.antenna.lh.spectrum.aloha.port{ii}];
                        %
                        if sparams.launch.antenna.lh.spectrum.aloha.optim.method{ii} == 0
                            id_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                                '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.launch.antenna.lh.spectrum.aloha.port{ii},...
                                '_ne_',num2str(sparams.launch.antenna.lh.spectrum.aloha.optim.ne_guess{ii}/1e17)];
                        else
                            id_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                                '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.launch.antenna.lh.spectrum.aloha.port{ii},'_ne_optim'];
                        end
                        %
                        if ~exist(['ALOHA/Simulations/',id_aloha,'.mat'])
                            %
                            aloha.optim.id = id_aloha;
                            aloha.optim.method = sparams.launch.antenna.lh.spectrum.aloha.optim.method{ii};
                            aloha.optim.remote.profile = sparams.launch.antenna.lh.spectrum.aloha.remote_profile{ii};
                            aloha.optim.ne_guess = sparams.launch.antenna.lh.spectrum.aloha.optim.ne_guess{ii};
                            %
                            if sparams.launch.antenna.lh.spectrum.aloha.optim.method{ii} == 1
                                %
                                aloha.optim.tolfun = sparams.launch.antenna.lh.spectrum.aloha.optim.tolfun{ii};
                                aloha.optim.tolx = sparams.launch.antenna.lh.spectrum.aloha.optim.tolx{ii};
                                aloha.optim.nitmax = sparams.launch.antenna.lh.spectrum.aloha.optim.nitmax{ii};
                            end
                            %
                            antennas = run_aloha_remote(sparams.machine{ii},sparams.launch.antenna.lh.spectrum.aloha.port{ii},...
                                sparams.discharge.shot{ii},sparams.discharge.tmin{ii},sparams.discharge.tmax{ii},...
                                sparams.launch.antenna.lh.spectrum.aloha.display.results{ii},aloha.optim);
                            %
                            for jj = 1:length(antennas)
                                antennas(jj).aloha.optim = aloha.optim;
                            end
                            %
                            save(['ALOHA/Simulations/',id_aloha,'.mat'],'antennas')
                            %
                            disp(['---> Simulation (',int2str(ii),',',id_aloha,'): started.'])
                            %
                            for jj = 1:length(antennas)
                                %
                                flag_job(ii,jj) = 1;
                                %
                            end
                            %
                        else
                            %                %
                            disp(['---> ALOHA simulation status (ID:',id_aloha,') :'])
                            %
                            load(['ALOHA/Simulations/',id_aloha,'.mat'],'antennas');%load results or job
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
                                    antennas(jj).aloha.optim = optim;
                                end
                                %
                            end
                            %
                            save(['ALOHA/Simulations/',id_aloha,'.mat'],'antennas');%save results or job
                            %
                            for jj = 1:length(antennas)
                                %
                                if isfield(antennas(jj).aloha,'job')
                                    disp([' - job #',int2str(jj),' for ',id_aloha,' is still running.'])
                                    flag_job(ii,jj) = 1;
                                elseif isfield(antennas(jj).aloha,'err')
                                     disp([' - job #',int2str(jj),' for ',id_aloha,' failed. Load ALOHA/Simulations/',id_aloha,'.mat' file and type antennas(',int2str(ii),').aloha.err(:) in the command to see the error log.'])
                                     flag_job(ii,jj) = -1;
                                else
                                    disp([' - job #',int2str(jj),' for ',id_aloha,' is completed.'])
                                    flag_job(ii,jj) = 0;
                                end
                                %
                            end
                            %
                            if flag_display_powerspectrum == 1 && sum(flag_job(ii,:)) == 0 % power spectra are independent of the density in front of the grill. Just the first is plotted
                                %
                                load(['ALOHA/Data/',id_data,'.mat'],'data_lh') 
                                %
                                display_lhdata(data_lh,sparams.launch.antenna.lh.spectrum.aloha.display.data{ii});
                                %
                                flag_display_powerspectrum = display_aloha_powerspectrum(flag_display_powerspectrum,data_lh,antennas,sparams.launch.antenna.lh.spectrum.aloha.display.results{ii})
                                %
                            end
                            %
                            %launchs = {launchs,sluke_aloha2launch(data_lh,antennas,sparams,ii)};%ALOHA -> C3PO (build launch structures)
                            %
                        end
                        %

                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                    else
                        %
                        disp('WARNING : unkown antenna coupling code for the Lower Hybrid wave');
                        %
                    end
                    %
                elseif strcmp(sparams.launch.antenna.lh.spectrum.source{ii},'file')
                    %
                    %TODO file option
                    %
                elseif strcmp(sparams.launch.antenna.lh.spectrum.source{ii},'value')
                    %
                    %TODO value option
                    %
                end
                    

            end
            %
            % Electron cyclotron wave
            %
            if strcmp(sparams.launch.antenna.type{ii},'ec') || strcmp(sparams.launch.antenna.type{ii},'lh+ec')
                %
                % TODO : implement EC wave
                %
                disp('EC wave not yet available')
                %
            end
            %
        else
            %
            launchs = {};%no rf waves
            %
        end
    end
    %
end





