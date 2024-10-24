function [wavestructs,remote_status] = sluke_wavestructs(sparams,ii)

wavestructs = {};
%
remote_status = 0;
%
if ~isfield(sparams,'rfwaves')
    %
    cprintf([1,0.5,0],'No rf waves are defined in sparams');disp(' ');
    wavestructs = [];
    remote_status = [];
    return
    %
end
%
wavestructs_id = sluke_id(sparams,ii);
%
if exist(['SLUKE_RFWAVES/WAVESTRUCTS_',wavestructs_id,'.mat'])
    %
    load(['SLUKE_RFWAVES/WAVESTRUCTS_',wavestructs_id,'.mat']);
    %
else
    %
    if strcmp(sparams.rfwaves.source{ii},'file')
        %
        rfwaves_file = sparams.rfwaves.file{ii};
        rfwaves_path = sparams.rfwaves.path{ii};
        %
        if strcmp(sparams.rfwaves.path{ii},'.')
            rfwaves_path = [pwd,'/'];
        else
            if strcmp(sparams.rfwaves.path{ii}(end),'/')
                rfwaves_path = sparams.rfwaves.path{ii};
            else
                rfwaves_path = [sparams.rfwaves.path{ii},'/'];
            end
        end
        %
        data = load([rfwaves_path,rfwaves_file]);
        %
        if isfield(data,'post') % ohmic field from metis simulations
            %
            sparams.equil.equilconsistencyparam.run = 0;
            [~,~,~,~,~,~,wavestructs] = auto_extract_metisdata_for_luke(data.post,sparams.discharge.tmin{ii});
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.rfwaves);
            %
            for jj = 1:7
                %
                if strcmp(fns{jj},'solver') || strcmp(fns{jj},'antenna')
                    %
                    eval(['source.',fns{jj},' = sparams.rfwaves.',fns{jj},'.code{',int2str(ii),'};']);
                    %
                else
                    %
                    eval(['source.',fns{jj},' = sparams.rfwaves.',fns{jj},'{',int2str(ii),'};']);
                    %
                end
                %
            end
            %
            rfwaves.source = source;
            %
            clear source
            %
            save(['SLUKE_RFWAVES/WAVESTRUCTS_',wavestructs_id,'.mat'],'wavestructs');
            %
        elseif isfield(data,'wavestructs') % ohmic field from metis simulations
            %
            wavestructs = data.wavestructs;
            save(['SLUKE_RFWAVES/WAVESTRUCTS_',wavestructs_id,'.mat'],'wavestructs');
            %
            return
            %
        else
            %
            cprintf([1,0.5,0],['---> WARNING : data format is not recognized for wavestructs from file.']);disp(' ')
            return
            %
        end
        %
    else
        %
        %remote_status = 0;
        %
        kk1 = 1;
        %
        for kk = 1:length(sparams.rfwaves.solver.type{ii})
            %
            if isempty(sparams.rfwaves.antenna.type{ii}{kk})
                %
                cprintf([1,0.5,0],['---> WARNING : the antenna #',int2str(kk),' in simulation #',int2str(ii),' is not considered in the calculations.']);disp(' ')
                break % this antenna is removed from calculations
                %
            end
            %
            wavestructs{kk1}.id = wavestructs_id;
            wavestructs{kk1}.equil_id = sluke_id(sparams,ii);
            wavestructs{kk1}.wavesolver = sparams.rfwaves.solver.code{ii}{kk};
            %
            if strcmp(sparams.rfwaves.solver.code{ii}{kk},'C3PO')
                %
                wavestructs{kk1}.rayparam = sluke_params_value(sparams.rfwaves.solver.C3PO.rayparam,ii,kk);
                wavestructs{kk1}.raydisplay = sluke_params_value(sparams.rfwaves.solver.C3PO.raydisplay,ii,kk);
                wavestructs{kk1}.waveparam = sluke_params_value(sparams.rfwaves.solver.C3PO.waveparam,ii,kk);
                wavestructs{kk1}.C3POparam = sluke_params_value(sparams.rfwaves.solver.C3PO.C3POparam,ii,kk);
                wavestructs{kk1}.fitequilparam = sluke_params_value(sparams.equil.fit,ii); 
                %
                wavestructs{kk1}.launch = sluke_params_value(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).C3PO.launch,ii,kk);
                wavestructs{kk1}.launch.id = sluke_id(sparams,ii);
                wavestructs{kk1}.launch.type = sparams.rfwaves.antenna.type{ii}{kk};
                %
                if strcmp(sparams.rfwaves.antenna.type{ii}{kk},'LH')
                    %
                    if strcmp(sparams.rfwaves.antenna.source{ii}{kk},'code')
                        %
                        if strcmp(sparams.rfwaves.antenna.code{ii}{kk},'ALOHA')
                            %
                            [aloha_launchs,remote_status0] = sluke_build_launchs(sparams,ii,kk);
                            %
                            remote_status = remote_status + remote_status0;
                            %
                            if remote_status0 == 0
                                %
                                load(['SLUKE_RFWAVES/ALOHA/Data/',aloha_launchs{1}.antennas.aloha.optim.id_data,'.mat'],'data_lh');
                                %
                                equil = sluke_equil(sparams,ii);
                                sign_Ip = sign(equil.psi_apRp(end));%+1 if clockwise
                                sign_Bt = sign(equil.ptBPHI(1,1));%+1 if clockwise
                                %
                                if isfield(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum,'globalspectrum') && ~isempty(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum{ii}{kk})
                                    %
                                    globalspectrum = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.globalspectrum{ii}{kk};
                                    %
                                end
                                %
                                if length(sparams.rfwaves.antenna.LH.ALOHA.optim.ne_guess{ii}{kk}) == 1
                                    %
                                    globalspectrum = 1;%enforced because no specific difference is made between top and bottom modules
                                    %
                                    cprintf('*[1,0.5,0]','--->  globalspectrum = 1 is enforced because no specific difference is made between top and bottom modules (ALOHA.optim.ne_guess is fixed).');disp(' ')
                                end
                                %
                                for mm = 1:length(aloha_launchs)
                                    %
                                    if mm > 1 && globalspectrum == 0
                                        %
                                        kk1 = kk1 + 1;
                                        wavestructs{kk1} = wavestructs{kk1-1};
                                        %
                                    end
                                    %
                                    aloha_launchs{mm}.antennas.aloha.C3PO = struct;
                                    %
                                    wavestructs{kk1}.launch.aloha = aloha_launchs{mm}.antennas.aloha;
                                    %
                                    zN_in = aloha_launchs{mm}.antennas.aloha.results.nz;
                                    zdN_in = aloha_launchs{mm}.antennas.aloha.results.dnz*ones(size(aloha_launchs{mm}.antennas.aloha.results.nz));
                                    zdP_in = real(aloha_launchs{mm}.antennas.aloha.results.dP_nz);
                                    param_in.nlobes = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.nlobes{ii}{kk};
                                    param_in.dir = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.dir{ii}{kk};
                                    param_in.mode = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_tor.mode{ii}{kk};
                                    Pin_in = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.Pin_in{ii}{kk};
                                    %param_in.ny = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.param_pol.ny{ii}{kk};
                                    opt_optim = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.opt_optim{ii}{kk};
                                    %
                                    if isfield(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum,'sdisplay') && isfield(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay,'inter') && ~isempty(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.inter{ii}{kk})
                                        %
                                        sdisplay.inter = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.inter{ii}{kk};
                                        %
                                    else
                                        %
                                        sdisplay.inter = 0;
                                        %
                                    end
                                    %
                                    if isfield(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum,'sdisplay') && isfield(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay,'mode') && ~isempty(sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.mode{ii}{kk})
                                        %
                                        sdisplay.mode = sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.sdisplay.mode{ii}{kk};
                                        %
                                    else
                                        %
                                        sdisplay.mode = 0;
                                        %
                                    end  
                                    %
                                    % ALOHA to C3PO power spectrum
                                    %
                                    [wavestructs{kk1}.launch.aloha(mm).C3PO.yN,wavestructs{kk1}.launch.aloha(mm).C3PO.ydN,wavestructs{kk1}.launch.aloha(mm).C3PO.yP,wavestructs{kk1}.launch.aloha(mm).C3PO.param_out,wavestructs{kk1}.launch.aloha(mm).C3PO.Pin,wavestructs{kk1}.launch.aloha(mm).C3PO.zyfac] = proc_aloha_spec_jd(zN_in,NaN,zdP_in,Pin_in,param_in,opt_optim,sdisplay);%zdN_in not used -> NaN, automatic grid step calculated
                                    %
                                    isempty_yN = isempty(wavestructs{kk1}.launch.aloha(mm).C3PO.yN);
                                    isempty_ydN = isempty(wavestructs{kk1}.launch.aloha(mm).C3PO.ydN);
                                    isempty_yP = isempty(wavestructs{kk1}.launch.aloha(mm).C3PO.yP);
                                    isempty_yparam_out = isempty(wavestructs{kk1}.launch.aloha(mm).C3PO.param_out);
                                    isempty_yPin = isempty(wavestructs{kk1}.launch.aloha(mm).C3PO.Pin);
                                    isempty_zyfac = isempty(wavestructs{kk1}.launch.aloha(mm).C3PO.zyfac);
                                    %
                                    flag_LH_problem = 0;
                                    %
                                    if isempty_yN + isempty_ydN + isempty_yP + isempty_yparam_out + isempty_yPin + isempty_zyfac == 6
                                        %
                                        cprintf('*red',['WARNING : experimental LH power has a problem. ALOHA calculations are corrupted -> LH power is enforced to zero.']);disp(' ')
                                        flag_LH_problem = 1;
                                        %
                                    end
                                    %
                                    if -1*sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent{ii}{kk}*sign(wavestructs{kk1}.launch.aloha(mm).C3PO.yN(find(wavestructs{kk1}.launch.aloha(mm).C3PO.yP == max(wavestructs{kk1}.launch.aloha(mm).C3PO.yP))))*sign_Ip*sign_Bt < 0
                                        %
                                        %
                                        if globalspectrum == 1 && mm > 1 %upper half is considered for global spectrum
                                            %
                                            %wavestructs{kk1}.launch.bPlhtot = wavestructs{kk1}.launch.bPlhtot + fliplr(wavestructs{kk1}.launch.aloha(mm).C3PO.yP);%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                            %
                                            if flag_LH_problem == 1
                                                %
                                                wavestructs{kk1}.launch.bPlhtot = zeros(size(wavestructs{kk1}.launch.bPlhtot));%zero LH power enforced because of antenna problem
                                                wavestructs{kk1}.launch.bNpar0 = zeros(size(wavestructs{kk1}.launch.bNpar0)) + 10/sqrt(equil.pTe(1));%zero LH power power because of antenna problem
                                                %
                                            else
                                                %
                                                wavestructs{kk1}.launch.bPlhtot = wavestructs{kk1}.launch.bPlhtot*(1+sum(fliplr(wavestructs{kk1}.launch.aloha(mm).C3PO.yP))/sum(wavestructs{kk1}.launch.bPlhtot));
                                            end
                                            %
                                        else
                                            %
                                            if flag_LH_problem == 1
                                                %
                                                wavestructs{kk1}.launch.bPlhtot = zeros(size(wavestructs{kk1}.launch.bPlhtot));%zero LH power enforced because of antenna problem
                                                wavestructs{kk1}.launch.bNpar0 = zeros(size(wavestructs{kk1}.launch.bNpar0)) + 10/sqrt(equil.pTe(1));%zero LH power power because of antenna problem
                                                %
                                            else
                                                %
                                                wavestructs{kk1}.launch.bNpar0 = -fliplr(wavestructs{kk1}.launch.aloha(mm).C3PO.yN);%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                                wavestructs{kk1}.launch.bdNpar0 = fliplr(wavestructs{kk1}.launch.aloha(mm).C3PO.ydN);%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                                wavestructs{kk1}.launch.bPlhtot = fliplr(wavestructs{kk1}.launch.aloha(mm).C3PO.yP);%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                                %
                                            end
                                            %
                                        end  
                                        %
                                    else
                                        %
                                        if flag_LH_problem == 1
                                            %
                                            wavestructs{kk1}.launch.bPlhtot = zeros(size(wavestructs{kk1}.launch.bPlhtot));%zero LH power enforced because of antenna problem
                                            wavestructs{kk1}.launch.bNpar0 = zeros(size(wavestructs{kk1}.launch.bNpar0)) + 10/sqrt(equil.pTe(1));%zero LH power power because of antenna problem
                                            %
                                        else
                                            %
                                            wavestructs{kk1}.launch.bPlhtot = wavestructs{kk1}.launch.aloha(mm).C3PO.yP;%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                            %
                                        end
                                        if globalspectrum == 1 && mm > 1%upper half is considered for global spectrum
                                            %
                                            %wavestructs{kk1}.launch.bPlhtot = wavestructs{kk1}.launch.bPlhtot + wavestructs{kk1}.launch.aloha(mm).C3PO.yP;%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                            %
                                            if flag_LH_problem == 1
                                                %
                                                wavestructs{kk1}.launch.bPlhtot = zeros(size(wavestructs{kk1}.launch.bPlhtot));%zero LH power enforced because of antenna problem
                                                wavestructs{kk1}.launch.bNpar0 = zeros(size(wavestructs{kk1}.launch.bNpar0)) + 10/sqrt(equil.pTe(1));%zero LH power power because of antenna problem
                                                %
                                            else
                                                %
                                                wavestructs{kk1}.launch.bPlhtot = wavestructs{kk1}.launch.bPlhtot*(1+sum(wavestructs{kk1}.launch.aloha(mm).C3PO.yP)/sum(wavestructs{kk1}.launch.bPlhtot));
                                                %
                                            end
                                            %
                                        else
                                            if flag_LH_problem == 1
                                                %
                                                wavestructs{kk1}.launch.bPlhtot = zeros(size(wavestructs{kk1}.launch.bPlhtot));%zero LH power enforced because of antenna problem
                                                wavestructs{kk1}.launch.bNpar0 = zeros(size(wavestructs{kk1}.launch.bNpar0)) + 10/sqrt(equil.pTe(1));%zero LH power power because of antenna problem
                                                %
                                            else
                                                %
                                                wavestructs{kk1}.launch.bNpar0 = wavestructs{kk1}.launch.aloha(mm).C3PO.yN;%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                                wavestructs{kk1}.launch.bdNpar0 = wavestructs{kk1}.launch.aloha(mm).C3PO.ydN;%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                                wavestructs{kk1}.launch.bPlhtot = wavestructs{kk1}.launch.aloha(mm).C3PO.yP;%for co- or counter-current depending upon sign of sparams.rfwaves.antenna.LH.C3PO.ALOHA.spectrum.cocurrent
                                                %
                                            end
                                        end  
                                        %
                                    end
                                    %
                                    if globalspectrum == 1
                                        %
                                        wavestructs{kk1}.launch.rZ0 = data_lh.rows_z_positions;
                                        %
                                    else
                                        %
                                        if mm == 1
                                            %
                                            wavestructs{kk1}.launch.rZ0 = data_lh.rows_z_positions(length(data_lh.rows_z_positions)/2+1:end);% upper half grill
                                            %
                                        else
                                            %
                                            wavestructs{kk1}.launch.rZ0 = data_lh.rows_z_positions(1:length(data_lh.rows_z_positions)/2);% lower half grill
                                            %
                                        end
                                        %
                                    end
                                    %
                                    imainlobe = find(wavestructs{kk1}.launch.bPlhtot == max(wavestructs{kk1}.launch.bPlhtot));
                                    %
                                    wavestructs{kk1}.launch.mainlobe.imainlobe = imainlobe;
                                    wavestructs{kk1}.launch.mainlobe.bNpar0 = wavestructs{kk1}.launch.bNpar0(imainlobe);
                                    wavestructs{kk1}.launch.mainlobe.bPlhtot = wavestructs{kk1}.launch.bPlhtot(imainlobe);
                                    %
                                    if isfield(sparams.rfwaves.antenna.LH.C3PO.launch,'mainlobeshift') && exist('flag_LH_problem','var') && flag_LH_problem == 0
                                        %
                                        mainlobeshift = sparams.rfwaves.antenna.LH.C3PO.launch.mainlobeshift{ii}{kk}; 
                                        %
                                        wavestructs{kk1}.launch.bNpar0(imainlobe) = (abs(wavestructs{kk1}.launch.bNpar0(imainlobe)) + mainlobeshift)*sign(wavestructs{kk1}.launch.bNpar0(imainlobe));
                                        %
                                        wavestructs{kk1}.launch.mainlobe.bNpar0 = wavestructs{kk1}.launch.bNpar0(imainlobe);
                                        %
                                    end
                                    %
                                    % Display LH propagation domain
                                    %
                                    wavestructs{kk1}.launch.mainlobe.bNparmax = 20;
                                    wavestructs{kk1}.launch.mainlobe.resolution = 0;%low resolution (fast calculations): 0, high resolution (slow calculations): 1
                                    wavestructs{kk1}.launch.mainlobe.ray = '';%no ray in the propagation domain
                                    %
                                    if isfield(sparams.rfwaves.antenna.LH.C3PO.launch,'propagationdomain') && sparams.rfwaves.antenna.LH.C3PO.launch.propagationdomain{ii}{kk} == 1
                                        %
                                        equil_propdomain = load(['SLUKE_EQUILS/EQUIL_',wavestructs{kk1}.equil_id,'.mat']);
                                        %
                                        if strcmp(sparams.rfwaves.antenna.code{ii}{kk},'ALOHA')
                                            %    
                                            if mm == 1 && globalspectrum == 0%up
                                                %
                                                figname = ['SLUKE_RFWAVES/ALOHA/Simulations/Figures/PropDomain_',aloha_launchs{1}.antennas.aloha.optim.id_data,'_',aloha_launchs{1}.antennas.aloha.optim.optim_mode,'_',sparams.rfwaves.antenna.comment{ii}{kk},'_UP_'];                                  
                                                %
                                            elseif mm == 2 && globalspectrum == 0% down
                                                %
                                                figname = ['SLUKE_RFWAVES/ALOHA/Simulations/Figures/PropDomain_',aloha_launchs{1}.antennas.aloha.optim.id_data,'_',aloha_launchs{1}.antennas.aloha.optim.optim_mode,'_',sparams.rfwaves.antenna.comment{ii}{kk},'_DOWN_'];   
                                                %
                                            elseif mm == 1 && globalspectrum == 1
                                                %
                                                figname = ['SLUKE_RFWAVES/ALOHA/Simulations/Figures/PropDomain_',aloha_launchs{1}.antennas.aloha.optim.id_data,'_',aloha_launchs{1}.antennas.aloha.optim.optim_mode,'_',sparams.rfwaves.antenna.comment{ii}{kk},'_GLOBAL']; 
                                                %
                                            end
                                        else
                                            %
                                            figname = ['SLUKE_RFWAVES/PropDomain_',wavestructs_id,'_'];
                                            %
                                        end
                                        %
                                        if ~isempty(wavestructs{kk1}.launch.mainlobe.ray)
                                            %
                                            ray = wavestructs{kk1}.launch.mainlobe.ray;
                                            %
                                        else
                                            %
                                            ray = '';
                                            %
                                        end
                                        %
                                        [wavestructs{kk1}.launch.mainlobe.na,...
                                            wavestructs{kk1}.launch.mainlobe.gamma_KAM_exact,...
                                            wavestructs{kk1}.launch.mainlobe.gamma_KAM_approximate,...
                                            wavestructs{kk1}.launch.mainlobe.open_upperboundaries_propagationdomain,...
                                            wavestructs{kk1}.launch.mainlobe.intersection,...
                                            wavestructs{kk1}.launch.mainlobe.Npar_gap_min,...
                                            wavestructs{kk1}.launch.mainlobe.R_kinematic_gap_min] = LH_acces_yp(...
                                            equil_propdomain.equil{1},...
                                            wavestructs{kk1}.launch.omega_rf,...
                                            ray,...
                                            abs(wavestructs{kk1}.launch.mainlobe.bNpar0),...
                                            wavestructs{kk1}.launch.mainlobe.bNparmax,...
                                            wavestructs{kk1}.launch.mainlobe.resolution,...
                                            figname);
                                        %
                                    else
                                        %
                                        cprintf('*red','The propagation domain is not calculated. Set the option of sparams.rfwaves.antenna.LH.C3PO.launch.propagationdomain to 1');disp(' ');
                                        %
                                    end
                                    %
                                end
                                %
                            end
                            %
                        else
                            %
                            disp(['WARNING: The code ',sparams.rfwaves.antenna.type{ii}{kk},' is not yet implemented for antenna calculation'])
                            break
                            %
                        end
                        %
                    end

                    %
                elseif strcmp(sparams.rfwaves.antenna.type{ii}{kk},'EC')
                    %
                    if strcmp(sparams.rfwaves.antenna.source{ii}{kk},'code')

                    else

                    end
                    %
                elseif strcmp(sparams.rfwaves.antenna.type{ii}{kk},'EBW')
                    %
                    if strcmp(sparams.rfwaves.antenna.source{ii}{kk},'code')

                    else

                    end
                    %
                else
                    %
                    cprintf([1,0.5,0],['WARNING: The type of wave ',sparams.rfwaves.antenna.type{ii}{kk},' is not yet implemented.'])
                    break
                    %
                end
                %
            elseif strcmp(sparams.rfwaves.solver.code{ii}{kk},'GENRAY')
                %


                %
            elseif strcmp(sparams.rfwaves.solver.code{ii}{kk},'CRAYON') %for EBW
                %


                %
            else 
                %
                cprintf([1,0.5,0],['WARNING: This wavesolver ',sparams.rfwaves.solver.code{ii}{kk},' is not yet implemented'])
                break
                %
            end
            %
            kk1 = kk1 + 1;
            %
        end
        %
        if remote_status == 0
            %
            save(['SLUKE_RFWAVES/WAVESTRUCTS_',wavestructs_id,'.mat'],'wavestructs');
            %
        end
        %
    end
end
%                            
                            