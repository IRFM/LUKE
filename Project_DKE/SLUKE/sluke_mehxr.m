function [MEHXR] = sluke_mehxr(sparams,lukestructs,ii,equil)
%
if nargin < 4
    equil = '';
end
%
simul_id = sluke_id(sparams,ii);
%
if ~exist('SLUKE_DIAGNOSTICS/Data/')
    %
    mkdir('SLUKE_DIAGNOSTICS/Data/')
    %
end
%
if isfield(sparams.diags.MEHXR,'exp') && sparams.diags.MEHXR.exp{ii} == 1
    %
    id_data = [sparams.machine{ii},'_data_mehxr_',sparams.discharge.shot{ii}];
    %
    if ~exist(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'])
        %
        [hxrexp.energy,hxrexp.hxr,hxrexp.t,hxrexp.beta,hxrexp.filter_thickness,hxrexp.filter_material,hxrexp.all_hxr_data] = collect_hxr_forLUKE_jd(sparams.machine{ii},sparams.discharge.shot{ii});
        %
        if ~isempty(hxrexp.t)
            %
            save(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'],'hxrexp')
            %
        else
            %
            hxrexp = '';
            cprintf([1,0.5,0],'WARNING : no access to MEHXR data from remote access. Check the remote connection.');disp(' ')
            %
        end
        %
    else
        %
        load(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'],'hxrexp');
        %
    end
    %
else
    %
    hxrexp = '';
    cprintf([1,0.5,0],'WARNING : no experimental MEHXR data required.');disp(' ')
    %
end
%
if ~isempty(hxrexp) && isfield(hxrexp,'t')
    %
    irefs = find((hxrexp.t > sparams.discharge.tmin{ii}) & (hxrexp.t <= sparams.discharge.tmax{ii}));%time interval
    %
    hxrexp_averaged.hxr_dt = hxrexp.t(2)-hxrexp.t(1);%experimental sampling time (s). 
    %
    for jj = 1:length(hxrexp.energy)
        %
        hxrexp_averaged.profile{jj} = sum(cell2mat(hxrexp.hxr(irefs,jj)),1)/length(irefs)/hxrexp_averaged.hxr_dt;%time averaging of the HXR signal (counts/s)
        %
        hxrexp_averaged.errorbars{jj} = sqrt(sum(cell2mat(hxrexp.hxr(irefs,jj)),1)/length(irefs))/hxrexp_averaged.hxr_dt;%error bars (Poisson's statistics)
        %
    end
    %
    hxrexp_averaged.energy = hxrexp.energy;
    %
else
    %
    hxrexp_averaged = '';
    %
end
%
if ~isempty(equil)
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'R5X2') && isfield(sparams.diags.MEHXR.R5X2,'hxrparam') && isfield(sparams.diags.MEHXR.R5X2.hxrparam,'screening') && isfield(sparams.diags.MEHXR.R5X2.hxrparam.screening,'partial') && isfield(sparams.diags.MEHXR.R5X2.hxrparam.screening.partial,'params') && isfield(sparams.diags.MEHXR.R5X2.hxrparam.screening.partial.params,'tables') && isfield(sparams.diags.MEHXR.R5X2.hxrparam.screening.partial.params.tables,'Ecmax') && ~isempty(sparams.diags.MEHXR.R5X2.hxrparam.screening.partial.params.tables.Ecmax{ii})
        %
        if sparams.diags.MEHXR.R5X2.hxrparam.screening.partial.params.tables.Ecmax{ii} < equil.Ecmax_ref
            %
            cprintf('*red','ERROR: partial screening effect in MEHXR : max kinetic energy in Fokker-Planck exceeds max kinetic in bremsstrahlung tables. Reduce sparams.kinetics.dkeparam.pnmax_S or rebuild the tables (long).');disp(' ')
            error ('Calculation terminated.')
            %
        end
        %
    end
    %
end
%
if ~isempty(lukestructs)
    %
    if strcmp(sparams.diags.MEHXR.code{ii},'R5X2')  
        %
        if isfield(lukestructs,'diags') && isfield(lukestructs.diags,'MEHXR') && isfield(lukestructs.diags.MEHXR,'R5X2') && ~isempty(lukestructs.diags.MEHXR.R5X2)
            %
            MEHXR.R5X2 = lukestructs.diags.MEHXR.R5X2;% remote calculations in run_lukert done locally
            %
        else
            %
            MEHXR.R5X2 = '';
            %
        end
        %
        if isempty(MEHXR.R5X2)   
            %
            data_in.lukestructs = lukestructs;
            data_in.hxrspec = sluke_MEHXR_hxrspec(sparams,simul_id,ii);
            data_in.hxrparam = sluke_MEHXR_hxrparam(sparams,simul_id,ii,data_in.hxrspec);
            %
            data_in.dkedisplay.display_mode = 0;
            data_in.dkedisplay.fhxr = 0;
            %
            MEHXR.R5X2 = sluke_synthetic_diag(sparams.diags.MEHXR.code{ii},data_in);%local calculations
            %
        end
        %
        if ~isempty(MEHXR.R5X2)
            %
            MEHXR.hxrexp_averaged = hxrexp_averaged;
            %
        end
        %
    end
    %
else
    %
    hxrspec = sluke_MEHXR_hxrspec(sparams,simul_id,ii);
    hxrparam = sluke_MEHXR_hxrparam(sparams,simul_id,ii,hxrspec);
    %
    if ~isempty(hxrspec) && ~isempty(hxrparam)
        %
        MEHXR.code = sparams.diags.MEHXR.code{ii};
        MEHXR.hxrspec = hxrspec;
        MEHXR.hxrparam = hxrparam;
        %
        if isfield(sparams.diags.MEHXR,'remote_calculations')
            %
            if sparams.simul.output{ii} == 0
                %
                MEHXR.remote_calculations = 0;%local calculationsin this case
                %
                cprintf([1,0.5,0],['---> MEHXR calculations are enforced locally since sparams.simul.output = 0.']);disp(' ')
                %
            else
                %
                MEHXR.remote_calculations = sparams.diags.MEHXR.remote_calculations{ii};%local calculations
                %
            end
            %
        else
            %
            MEHXR.remote_calculations = 0;%local calculations
            %
        end
        %
    else
        %
        MEHXR = [];
        %
        if isempty(hxrspec)
            %
            cprintf([1,0.5,0],'WARNING : hxrspec is empty. No calculations for MEHXR.');disp(' ')
            %
        end
        %
        if isempty(hxrparam)
            %
            cprintf([1,0.5,0],'WARNING : hxrparam is empty. No calculations for MEHXR.');disp(' ')
            %
        end
        %
    end
    %
end
%
end

function [hxrspec] = sluke_MEHXR_hxrspec(sparams,simul_id,ii)
%
    %
    % MEHXR diagnostic technical specifications (hxrspec).
    %
    if isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'hxrspec') && isfield(sparams.diags.MEHXR.hxrspec,'source') && isempty(sparams.diags.MEHXR.hxrspec.source{ii})
        %
        if exist(['SLUKE_DIAGNOSTICS/MEHXR_HXRSPEC_',simul_id,'.mat'],'file')
            %
            load(['SLUKE_DIAGNOSTICS/MEHXR_HXRSPEC_',simul_id,'.mat'],'hxrspec');
            %
        else
            %
            if strcmp(sparams.machine{ii},'TS') ||  strcmp(sparams.machine{ii},'WEST')
                %   
                [hxrspec,~] = get_mehxrspec_forLUKE_yp('WEST',str2num(sparams.discharge.shot{ii}),'','','');
                % 
            else
                %
                hxrspec = '';
                %
            end
            %
        end
        %
    elseif isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'hxrspec') && isfield(sparams.diags.MEHXR.hxrspec,'source') && strcmp(sparams.diags.MEHXR.hxrspec.source{ii},'file')
        %
        if isempty(sparams.diags.MEHXR.hxrspec.path{ii})
            %
            if exist(sparams.diags.MEHXR.hxrspec.file{ii},'file')
                %
                load(sparams.diags.MEHXR.hxrspec.file{ii},'hxrspec');
                %
                hxrspec2 = sluke_params_value(sparams.diags.MEHXR.hxrspec,ii);
                %
                f = fieldnames(hxrspec2);
                %
                for i = 1:length(f)
                   %
                   hxrspec.(f{i}) = hxrspec2.(f{i});
                   %
                end
                %
            else
                %
                cprintf([1,0.5,0],['WARNING : file ',sparams.diags.MEHXR.hxrspec.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')
                hxrspec = '';
                %
            end
            %
        else
            %
            if exist([sparams.diags.MEHXR.hxrspec.path{ii},'/',sparams.diags.MEHXR.hxrspec.file{ii}],'file')
                %
                load([sparams.diags.MEHXR.hxrspec.path{ii},'/',sparams.diags.MEHXR.hxrspec.file{ii}],'hxrspec');
                %
            else
                %
                cprintf([1,0.5,0],['WARNING : file ',sparams.diags.MEHXR.hxrspec.path{ii},'/',sparams.diags.MEHXR.hxrspec.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')
                hxrspec = '';
                %                
            end
            %
        end
        %
    elseif isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'hxrspec') && isfield(sparams.diags.MEHXR.hxrspec,'source') && strcmp(sparams.diags.MEHXR.hxrspec.source{ii},'value')
        %
        hxrspec = sluke_params_value(sparams.diags.MEHXR.hxrspec,ii);
        %
    else
        %
        hxrspec = '';
        %
    end
    %
    if ~isempty(hxrspec)
        %
        if isfield(sparams.diags.MEHXR.hxrspec,'chordstatus_hxr')
            %
            hxrspec.chordstatus_hxr = sparams.diags.MEHXR.hxrspec.chordstatus_hxr{ii};
            %
        end
        %{
        if isfield(hxrspec,'beta_hxr')
            %
            nc = length(hxrspec.beta_hxr);% number of chords
            %
            disp(['--> Number of chords in MEHXR : ',int2str(nc),'.'])
            %
        end         
        %}
        save(['SLUKE_DIAGNOSTICS/MEHXR_HXRSPEC_',simul_id,'.mat'],'hxrspec');
        %
    else
        %
        cprintf([1,0.5,0],'WARNING : ''hxrspec'' structure for MEHXR calculations is not defined.');disp(' ')
        hxrspec = '';
        %
    end
    %
end

function [hxrparam] = sluke_MEHXR_hxrparam(sparams,simul_id,ii,hxrspec)
%
%
    % DPSX simulations parameters
    %
    if strcmp(sparams.diags.MEHXR.code{ii},'R5X2')
        %
        if isfield(sparams.diags.MEHXR.R5X2,'hxrparam') && isfield(sparams.diags.MEHXR.R5X2.hxrparam,'source') && isempty(sparams.diags.MEHXR.R5X2.hxrparam.source{ii})
            %
            if exist(['SLUKE_DIAGNOSTICS/MEHXR_HXRPARAM_',simul_id,'.mat'],'file')
                %
                load(['SLUKE_DIAGNOSTICS/MEHXR_HXRPARAM_',simul_id,'.mat'],'hxrparam');
                %
            else
                %
                cprintf([1,0.5,0],['WARNING : file SLUKE_DIAGNOSTICS/MEHXR_HXRPARAM_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',simul_id,'.mat that contains R5X2 simulations parameters is not found. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')
                hxrparam = '';
                %
            end
            % 
        elseif isfield(sparams.diags.MEHXR.R5X2,'hxrparam') && isfield(sparams.diags.MEHXR.R5X2.hxrparam,'source') && strcmp(sparams.diags.MEHXR.R5X2.hxrparam.source{ii},'file')
            %
            if isfield(sparams.diags.MEHXR.R5X2.hxrparam,'file') && isfield(sparams.diags.MEHXR.R5X2.hxrparam,'path')
                %
                if exist([sparams.diags.MEHXR.R5X2.hxrparam.path{ii},'/',sparams.diags.MEHXR.R5X2.hxrparam.file{ii}],'file')
                    %
                    load([sparams.diags.MEHXR.R5X2.hxrparam.path{ii},'/',sparams.diags.MEHXR.R5X2.hxrparam.file{ii}])
                    %
                else
                    %
                    cprintf([1,0.5,0],['WARNING : file ',sparams.diags.MEHXR.R5X2.hxrparam.path{ii},sparams.diags.MEHXR.R5X2.hxrparam.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')
                    hxrparam = '';
                    %
                end
                %
            else
                %
                hxrparam = '';
                %
            end
            %
        elseif isfield(sparams.diags.MEHXR.R5X2,'hxrparam') && isfield(sparams.diags.MEHXR.R5X2.hxrparam,'source') && strcmp(sparams.diags.MEHXR.R5X2.hxrparam.source{ii},'value')
            %
            hxrparam = sluke_params_value(sparams.diags.MEHXR.R5X2.hxrparam,ii);
            %
        else
            %
            hxrparam = '';
            %
        end
        %
        if ~isempty(hxrparam)
            %
            hxrparam.id = 'MEHXR';
            save(['SLUKE_DIAGNOSTICS/MEHXR_HXRPARAM_',simul_id,'.mat'],'hxrparam');
            %
        else
            %
            cprintf([1,0.5,0],'WARNING : ''hxrparam'' structure for MEHXR calculations is not defined.');disp(' ')
            hxrparam = '';
            %
        end
        %
    else
        %
        cprintf('red',['WARNING : the code ',sparams.diags.MEHXR.code{ii},' is not implemented. Synthetic diagnostic calculations are cancelled.']);disp(' ')
        MEHXR = '';
        return
        %
    end
%
end

