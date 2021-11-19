function [DSPX] = sluke_dspx(sparams,lukestructs,ii)
%
simul_id = sluke_id(sparams,ii,'simul');
%
if ~exist('SLUKE_DIAGNOSTICS/Data/')
    %
    mkdir('SLUKE_DIAGNOSTICS/Data/')
    %
end
%
id_data = [sparams.machine{ii},'_data_dspx_',sparams.discharge.shot{ii}];
%
if ~isempty(lukestructs)
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
            cprintf([1,0.5,0],'WARNING : no access to DSPX data from remote access. Check the remote connection.');disp(' ')
            %
        end
        %
    else
        %
        load(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'],'hxrexp');
        %
    end
    %
    if ~isempty(hxrexp) && isfield(hxrexp,'t')
        %
        irefs = find((hxrexp.t > sparams.discharge.tmin{ii}) & (hxrexp.t < sparams.discharge.tmax{ii}));%time interval
        %
        hxrexp_averaged.hxr_dt = hxrexp.t(2)-hxrexp.t(1);%experimental sampling time (s). 
        %
        for jj = 1:length(hxrexp.energy)
            %
            hxrexp_averaged.profile(jj,:) = sum(squeeze(hxrexp.hxr(irefs,jj,:)),1)/length(irefs)/hxrexp_averaged.hxr_dt;%time averaging of the HXR signal (counts/s)
            %
            hxrexp_averaged.errorbars(jj,:) = sqrt(sum(squeeze(hxrexp.hxr(irefs,jj,:)),1)/length(irefs))/hxrexp_averaged.hxr_dt;%error bars (Poisson's statistics)
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
    if strcmp(sparams.diags.DSPX.code{ii},'R5X2')  
        %
        if isfield(lukestructs,'diags') && isfield(lukestructs.diags,'DSPX') && isfield(lukestructs.diags.DSPX,'R5X2') && ~isempty(lukestructs.diags.DSPX.R5X2)
            %
            DSPX.R5X2 = lukestructs.diags.DSPX.R5X2;% remote calculations in run_lukert done locally
            %
        else
            %
            DSPX.R5X2 = '';
            %
        end
        %
        if isempty(DSPX.R5X2)   
            %
            data_in.lukestructs = lukestructs;
            data_in.hxrspec = hxrspec;
            data_in.hxrparam = hxrparam;
            %
            data_in.dkedisplay.display_mode = 0;
            data_in.dkedisplay.fhxr = 0;
            %
            DSPX.R5X2 = sluke_synthetic_diag(sparams.diags.DSPX.code{ii},data_in);%local calculations
            %
        end
        %
        if ~isempty(DSPX.R5X2)
            %
            DSPX.hxrexp_averaged = hxrexp_averaged;
            %
        end
        %
    end
    %
else
    %
    % DSPX diagnostic technical specifications (hxrspec).
    %
    if isfield(sparams.diags,'DSPX') && isfield(sparams.diags.DSPX,'hxrspec') && isfield(sparams.diags.DSPX.hxrspec,'source') && isempty(sparams.diags.DSPX.hxrspec.source{ii})
        %
        if exist(['SLUKE_DIAGNOSTICS/DSPX_HXRSPEC_',simul_id,'.mat'],'file')
            %
            load(['SLUKE_DIAGNOSTICS/DSPX_HXRSPEC_',simul_id,'.mat'],'hxrspec');
            %
        else
            %
            if strcmp(sparams.machine{ii},'TS') ||  strcmp(sparams.machine{ii},'WEST')
                %   
                [hxrspec,~] = get_hxrspec_forLUKE_jd('TS',str2num(sparams.discharge.shot{ii}),'','','');
                % 
            else
                %
                hxrspec = '';
                %
            end
            %
        end
        %
    elseif isfield(sparams.diags,'DSPX') && isfield(sparams.diags.DSPX,'hxrspec') && isfield(sparams.diags.DSPX.hxrspec,'source') && strcmp(sparams.diags.DSPX.hxrspec.source,'file')
        %
        if exist([sparams.diags.DSPX.hxrspec.path{ii},'/',sparams.diags.DSPX.hxrspec.file{ii}],'file')
            %
            load([sparams.diags.DSPX.hxrspec.path{ii},'/',sparams.diags.DSPX.hxrspec.file{ii}],'hxrspec');
            %
        else
            %
            cprintf([1,0.5,0],['WARNING : file ',sparams.diags.DSPX.hxrspec.path{ii},'/',sparams.diags.DSPX.hxrspec.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for DSPX are cancelled.']);disp(' ')
            hxrspec = '';
            %
        end
        %
    elseif isfield(sparams.diags,'DSPX') && isfield(sparams.diags.DSPX,'hxrspec') && isfield(sparams.diags.DSPX.hxrspec,'source') && strcmp(sparams.diags.DSPX.hxrspec.source,'value')
        %
        hxrspec = sluke_params_value(sparams.diags.DSPX.hxrspec,ii);
        %
    else
        %
        hxrspec = '';
        %
    end
    %
    if ~isempty(hxrspec)
        %
        hxrspec.kfit = hxrspec.kphot(1:2:end);
        %
        if isfield(sparams.diags.DSPX.hxrspec,'chordstatus_hxr')
            %
            hxrspec.chordstatus_hxr = sparams.diags.DSPX.hxrspec.chordstatus_hxr{ii};
            %
        end
        %
        if isfield(hxrspec,'beta_hxr')
            %
            nc = length(hxrspec.beta_hxr);% number of chords
            %
            disp(['--> Number of chords in DSPX : ',int2str(nc),'.'])
            %
        end         
        %
        save(['SLUKE_DIAGNOSTICS/DSPX_HXRSPEC_',simul_id,'.mat'],'hxrspec');
        %
    else
        %
        cprintf([1,0.5,0],'WARNING : ''hxrspec'' structure for DSPX calculations is not defined.');disp(' ')
        hxrspec = '';
        %
    end
    %
    % DPSX simulations parameters
    %
    if strcmp(sparams.diags.DSPX.code{ii},'R5X2')
        %
        if isfield(sparams.diags.DSPX.R5X2,'hxrparam') && isfield(sparams.diags.DSPX.R5X2.hxrparam,'source') && isempty(sparams.diags.DSPX.R5X2.hxrparam.source{ii})
            %
            if exist(['SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',simul_id,'.mat'],'file')
                %
                load(['SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',simul_id,'.mat'],'hxrparam');
                %
            else
                %
                cprintf([1,0.5,0],['WARNING : file SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',simul_id,'.mat that contains R5X2 simulations parameters is not found. Synthetic diagnostic calculations for DSPX are cancelled.']);disp(' ')
                hxrparam = '';
                %
            end
            % 
        elseif isfield(sparams.diags.DSPX.R5X2,'hxrparam') && isfield(sparams.diags.DSPX.R5X2.hxrparam,'source') && strcmp(sparams.diags.DSPX.R5X2.hxrparam.source{ii},'file')
            %
            if isfield(sparams.diags.DSPX.R5X2.hxrparam,'file') && isfield(sparams.diags.DSPX.R5X2.hxrparam,'path')
                %
                if exist([sparams.diags.DSPX.R5X2.hxrparam.path{ii},'/',sparams.diags.DSPX.R5X2.hxrparam.file{ii}],'file')
                    %
                    load([sparams.diags.DSPX.R5X2.hxrparam.path{ii},'/',sparams.diags.DSPX.R5X2.hxrparam.file{ii},'.mat'])
                    %
                else
                    %
                    cprintf([1,0.5,0],['WARNING : file ',sparams.diags.DSPX.R5X2.hxrparam.path{ii},'/',sparams.diags.DSPX.R5X2.hxrparam.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for DSPX are cancelled.']);disp(' ')
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
        elseif isfield(sparams.diags.DSPX.R5X2,'hxrparam') && isfield(sparams.diags.DSPX.R5X2.hxrparam,'source') && strcmp(sparams.diags.DSPX.R5X2.hxrparam.source{ii},'value')
            %
            hxrparam = sluke_params_value(sparams.diags.DSPX.R5X2.hxrparam,ii);
            %
            %hxrparam.kphot = hxrspec.kphot;
            %hxrparam.kmin = hxrspec.kmin;
            %hxrparam.kmax = hxrspec.kmax;
            %
        else
            %
            hxrparam = '';
            %
        end
        %
        if ~isempty(hxrparam)
            %
            save(['SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',simul_id,'.mat'],'hxrparam');
            %
        else
            %
            cprintf([1,0.5,0],'WARNING : ''hxrparam'' structure for DSPX calculations is not defined.');disp(' ')
            hxrparam = '';
            %
        end
        %
    else
        %
        cprintf('red',['WARNING : the code ',sparams.diags.DSPX.code{ii},' is not implemented. Synthetic diagnostic calculations are cancelled.']);disp(' ')
        DSPX = '';
        return
        %
    end
    %
    if ~isempty(hxrspec) && ~isempty(hxrparam)
        %
        DSPX.code = sparams.diags.DSPX.code{ii};
        DSPX.hxrspec = hxrspec;
        DSPX.hxrparam = hxrparam;
        %
        if isfield(sparams.diags.DSPX,'remote_calculations')
            %
            DSPX.remote_calculations = sparams.diags.DSPX.remote_calculations{ii};%local calculations
            %
        else
            %
            DSPX.remote_calculations = 0;%local calculations
            %
        end
        %
    end
    %
end
%



