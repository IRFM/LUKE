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
function [DSPX] = sluke_dspx(sparams,lukestructs,ii,equil)
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
if isfield(sparams.diags.DSPX,'exp') && sparams.diags.DSPX.exp{ii} == 1
    %
    id_data = [sparams.machine{ii},'_data_dspx_',sparams.discharge.shot{ii}];
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
            cprintf([1,0.5,0],'WARNING : no access to experimental DSPX data from remote access. Check the remote connection.');disp(' ')
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
    cprintf([1,0.5,0],'WARNING : no experimental DSPX data required.');disp(' ')
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
        hxrexp_averaged.profile(jj,:) = squeeze(sum(hxrexp.hxr(irefs,jj,:),1))'/length(irefs)/hxrexp_averaged.hxr_dt;%time averaging of the HXR signal (counts/s)
        %
        hxrexp_averaged.errorbars(jj,:) = sqrt(squeeze(sum(hxrexp.hxr(irefs,jj,:),1))'/length(irefs))/hxrexp_averaged.hxr_dt;%error bars (Poisson's statistics)
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
    if isfield(sparams,'diags') && isfield(sparams.diags,'DSPX') && isfield(sparams.diags.DSPX,'R5X2') && isfield(sparams.diags.DSPX.R5X2,'hxrparam') && isfield(sparams.diags.DSPX.R5X2.hxrparam,'screening') && isfield(sparams.diags.DSPX.R5X2.hxrparam.screening,'partial') && isfield(sparams.diags.DSPX.R5X2.hxrparam.screening.partial,'params') && isfield(sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params,'tables') && isfield(sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables,'Ecmax') && ~isempty(sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.Ecmax{ii})
        %
        if sparams.diags.DSPX.R5X2.hxrparam.screening.partial.params.tables.Ecmax{ii} < equil.Ecmax_ref
            %
            cprintf('*red','ERROR: partial screening effect in DPSX : max kinetic energy in Fokker-Planck exceeds max kinetic in bremsstrahlung tables. Reduce sparams.kinetics.dkeparam.pnmax_S or rebuild the tables (long).');disp(' ')
            error ('Calculation terminated.')
            %
        end
        %
    end
end
%
if ~isempty(lukestructs)
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
            data_in.hxrspec = sluke_DSPX_hxrspec(sparams,simul_id,ii);
            data_in.hxrparam = sluke_DSPX_hxrparam(sparams,simul_id,ii);
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
    hxrspec = sluke_DSPX_hxrspec(sparams,simul_id,ii);
    hxrparam = sluke_DSPX_hxrparam(sparams,simul_id,ii);
    %
    if ~isempty(hxrspec) && ~isempty(hxrparam)
        %
        DSPX.code = sparams.diags.DSPX.code{ii};
        DSPX.hxrspec = hxrspec;
        DSPX.hxrparam = hxrparam;
        %
        if isfield(sparams.diags.DSPX,'remote_calculations')
            %
            if sparams.simul.output{ii} == 0
                %
                DSPX.remote_calculations = 0;%local calculationsin this case
                %
                cprintf([1,0.5,0],['---> DSPX calculations are enforced locally since sparams.simul.output = 0.']);disp(' ')
                %
            else
                %
                DSPX.remote_calculations = sparams.diags.DSPX.remote_calculations{ii};%local calculations
                %
            end
            %
        else
            %
            DSPX.remote_calculations = 0;%local calculations
            %
        end
        %
    else
        %
        DSPX = [];
        %
        if isempty(hxrspec)
            %
            cprintf([1,0.5,0],'WARNING : hxrspec is empty. No calculations for DSPX.');disp(' ')
            %
        end
        %
        if isempty(hxrparam)
            %
            cprintf([1,0.5,0],'WARNING : hxrparam is empty. No calculations for DSPX.');disp(' ')
            %
        end
        %
    end
    %
end
%
end

function [hxrspec] = sluke_DSPX_hxrspec(sparams,simul_id,ii)
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
    elseif isfield(sparams.diags,'DSPX') && isfield(sparams.diags.DSPX,'hxrspec') && isfield(sparams.diags.DSPX.hxrspec,'source') && strcmp(sparams.diags.DSPX.hxrspec.source{ii},'file')
        %
        if isempty(sparams.diags.DSPX.hxrspec.path{ii})
            %
            if exist(sparams.diags.DSPX.hxrspec.file{ii},'file')
                %
                load(sparams.diags.DSPX.hxrspec.file{ii},'hxrspec');
                %
            else
                %
                cprintf([1,0.5,0],['WARNING : file ',sparams.diags.DSPX.hxrspec.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for DSPX are cancelled.']);disp(' ')
                hxrspec = '';
                %
            end
            %
        else
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
        end        
        %
    elseif isfield(sparams.diags,'DSPX') && isfield(sparams.diags.DSPX,'hxrspec') && isfield(sparams.diags.DSPX.hxrspec,'source') && strcmp(sparams.diags.DSPX.hxrspec.source{ii},'value')
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
        %{
        if isfield(hxrspec,'beta_hxr')
            %
            nc = length(hxrspec.beta_hxr);% number of chords
            %
            disp(['--> Number of chords in DSPX : ',int2str(nc),'.'])
            %
        end         
        %}
        save(['SLUKE_DIAGNOSTICS/DSPX_HXRSPEC_',simul_id,'.mat'],'hxrspec');
        %
    else
        %
        cprintf([1,0.5,0],'WARNING : ''hxrspec'' structure for DSPX calculations is not defined.');disp(' ')
        hxrspec = '';
        %
    end
    %
end

function [hxrparam] = sluke_DSPX_hxrparam(sparams,simul_id,ii)
%
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
                    load([sparams.diags.DSPX.R5X2.hxrparam.path{ii},'/',sparams.diags.DSPX.R5X2.hxrparam.file{ii}])
                    %
                else
                    %
                    cprintf([1,0.5,0],['WARNING : file ',sparams.diags.DSPX.R5X2.hxrparam.path{ii},sparams.diags.DSPX.R5X2.hxrparam.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for DSPX are cancelled.']);disp(' ')
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
            hxrparam.id = 'DSPX';
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
end

