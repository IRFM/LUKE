function [Zbremchord,Zbremdiag,Zbremplasma,equilHXR,hxrexp_averaged] = sluke_mehxr(sparams,lukestructs,ii)
%
Zbremchord = '';
Zbremdiag = '';
Zbremplasma = '';
equilHXR = '';
hxrexp_averaged = struct;
%
simul_id = sluke_id(sparams,ii,'simul');
%
% Get experimental data
%
if ~exist('SLUKE_DIAGNOSTICS/Data/')
    %
    mkdir('SLUKE_DIAGNOSTICS/Data/')
    %
end
%
id_data = [sparams.machine{ii},'_data_mehxr_',sparams.discharge.shot{ii}];
%
if ~exist(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'])
    %
    %[hxrexp.energy,hxrexp.hxr,hxrexp.t,hxrexp.beta,hxrexp.filter_thickness,hxrexp.filter_material,hxrexp.all_hxr_data] = collect_hxr_forLUKE_jd(sparams.machine{ii},sparams.discharge.shot{ii});
    hxrexp.t = '';
    %
    if ~isempty(hxrexp.t)
        %
        save(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'],'hxrexp')
        %
    else
        %
        %cprintf([1,0.5,0],'WARNING : no access to MEHXR data from remote access. Check the remote connection.');disp(' ')
        cprintf([1,0.5,0],'WARNING : MEHXR data are net yet available');disp(' ')
        %
    end
    %
else
    %
    load(['SLUKE_DIAGNOSTICS/Data/',id_data,'.mat'],'hxrexp');
    %
end
%
% MEHXR diagnostic technical specifications (hxrspec).
%
if isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'hxrspec') && isfield(sparams.diags.MEHXR.hxrspec,'source') && isempty(sparams.diags.MEHXR.hxrspec.source{ii})
    %
    if exist(['SLUKE_DIAGNOSTICS/MEHXR_HXRSPEC_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat'],'file')
        %
        load(['SLUKE_DIAGNOSTICS/MEHXR_HXRSPEC_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat'],'hxrspec');
        %
    else
        %
        if strcmp(sparams.machine{ii},'WEST')
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
elseif isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'hxrspec') && isfield(sparams.diags.MEHXR.hxrspec,'source') && strcmp(sparams.diags.MEHXR.hxrspec.source,'file')
    %
    if exist([sparams.diags.MEHXR.hxrspec.path{ii},'/'sparams.diags.MEHXR.hxrspec.file{ii}],'file')
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
elseif isfield(sparams.diags,'MEHXR') && isfield(sparams.diags.MEHXR,'hxrspec') && isfield(sparams.diags.MEHXR.hxrspec,'source') && strcmp(sparams.diags.MEHXR.hxrspec.source,'value')
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
    %
    if isfield(hxrspec,'beta_hxr')
        %
        nc = length(hxrspec.beta_hxr);% number of chords
        %
        disp(['--> Number of chords in MEHXR : ',int2str(nc),'.'])
        %
    end         
    %
    save(['SLUKE_DIAGNOSTICS/MEHXR_HXRSPEC_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat'],'hxrspec');
    %
else
    %
    cprintf([1,0.5,0],'WARNING : ''hxrspec'' structure for MEHXR calculations is not defined.');disp(' ')
    return
    %
end
%
hxrspec.kfit = hxrspec.kphot(1:2:end);
%
% MEHXR simulations parameters
%
if strcmp(sparams.diags.MEHXR.code{ii},'R5X2')
    %
    if isfield(sparams.diags.MEHXR.R5X2,'hxrparam') && isfield(sparams.diags.MEHXR.R5X2.hxrparam,'source') && isempty(sparams.diags.MEHXR.R5X2.hxrparam.source{ii})
        %
        if exist(['SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat'],'file')
            %
            load(['SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat'],'hxrparam');
            %
        else
            %
            cprintf([1,0.5,0],['WARNING : file SLUKE_DIAGNOSTICS/DSPX_HXRPARAM_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat that contains R5X2 simulations parameters is not found. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')
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
                load([sparams.diags.MEHXR.R5X2.hxrparam.path{ii},'/',sparams.diags.MEHXR.R5X2.hxrparam.file{ii},'.mat'])
                %
            else
                %
                cprintf([1,0.5,0],['WARNING : file ',sparams.diags.MEHXR.R5X2.hxrparam.path{ii},'/',sparams.diags.MEHXR.R5X2.hxrparam.file{ii},' that contains technical specifications is not found. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')

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
	elseif strcmp(sparams.diags.MEHXR.R5X2.hxrparam.source{ii},'value')
        %
        hxrparam = sluke_params_value(sparams.diags.MEHXR.R5X2.hxrparam,ii);
        %
        hxrparam.kphot = hxrspec.kphot;
        hxrparam.kmin = hxrspec.kmin;
        hxrparam.kmax = hxrspec.kmax;
        %
    else
        %
        hxrparam = '';
        %
    end
    %
    if ~isempty(hxrparam)
        %
        save(['SLUKE_DIAGNOSTICS/MEHXR_HXRPARAM_',sparams.machine{ii},'_',sparams.discharge.shot{ii},'.mat'],'hxrparam');
        %
    else
        %
        cprintf([1,0.5,0],'WARNING : ''hxrparam'' structure for MEHXR calculations is not defined.');disp(' ')
        return
        %
    end
    %
    % DPSX calculations
    %
    dkedisplay.display_mode = 0;
    dkedisplay.fhxr = 0;
    dt = 1;
    disp('**********TODO : sluke_hxr l.176 *****************')
    %
    if exist('hxrspec','var') && exist('hxrparam','var') && ~isempty(hxrspec) && ~isempty(hxrparam) 
        %
        dke_out = lukestructs.output.dke_out;
        equilDKE = lukestructs.output.equilDKE;
        radialDKE = lukestructs.output.radialDKE;
        momentumDKE = lukestructs.output.momentumDKE;
        mksa = lukestructs.output.mksa;
        Zmomcoef = lukestructs.output.Zmomcoef;
        equil = lukestructs.equil;
        %
        radialHXR.xpsin_S_dke = radialDKE.xpsin_S_dke;% warning : check in DKE mode
        radialHXR.xpsin_f = radialDKE.xpsin_f_dke;% select only FP points
        %
        [equilHXR] = equilibrium_jd(equil,radialHXR,dkedisplay,'spline',hxrparam.mfactor);%Magnetic equilibrium for MEHXR at points of the distribution function
        %
        % FEB emissivity on LUKE equilibrium
        %
        if iscell(dke_out.XXf0),% select only FP points
            XXf0 = dke_out.XXf0{end}(:,:,radialDKE.r_dke);
        else % older LUKE versions
            XXf0 = dke_out.XXf0(:,:,radialDKE.r_dke);
        end    
        %
        [Zbremplasma] = bremsstrahlung_dke_yp(equilHXR,mksa,momentumDKE,Zmomcoef,XXf0,hxrparam,dkedisplay);
        %
        [Zbremchord] = bremchord_dke_yp(equilHXR,radialHXR,hxrspec,hxrparam);% HXR diagnostic lines of sight
        %
        [Zbremplasma] = bremchordemission_dke_jd(Zbremplasma,Zbremchord,hxrspec);% FEB emission along the lines of sight
        %
        [Zbremdiag] = bremdiag_dke_yp(Zbremplasma,hxrspec,hxrparam,dt);% HXR synthetic diagnostic signal
        %
        if exist(hxrexp,'var') && ~isempty(hxrexp.t) 
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
    end
    %
else
    %
    cprintf('red',['WARNING : the code ',sparams.diags.MEHXR.code{ii},' is not implemented for MEHXR. Synthetic diagnostic calculations for MEHXR are cancelled.']);disp(' ')
    return;
    %
end
%



