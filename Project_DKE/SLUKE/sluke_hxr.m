function [Zbremchord,Zbremdiag,Zbremplasma,equilHXR,hxrexp] = sluke_hxr(sparams,lukestructs,ii)
%
Zbremchord = '';
Zbremdiag = '';
Zbremplasma = '';
equilHXR = '';
hxrexp = '';
%
% HXR diagnostic technical specifications
%
if strcmp(sparams.diags.hxr.hxrspec.source{ii},'code')
    %
    if strcmp(sparams.diags.hxr.hxrspec.code{ii},'R5X2')
        %
        if strcmp(sparams.machine{ii},'TS') ||  strcmp(sparams.machine{ii},'WEST')
            %
            [hxrspec,~] = get_hxrspec_forLUKE_jd('TS',str2num(sparams.discharge.shot{ii}),'','','');
            %
            if ~isempty(hxrspec)
                %
                if isfield(sparams.diags.hxr.hxrspec,'chordstatus_hxr')
                    %
                    hxrspec.chordstatus_hxr = sparams.diags.hxr.hxrspec.chordstatus_hxr{ii};%overwrite chord status if any need
                    %
                end
                %
                save(['SLUKE_HXRSPECS/HXRSPEC_',simul_id,'.mat'],'hxrspec');
                %
            else
                %
                disp('WARNING : ''hxrspec'' structure for HXR calculations is not defined. Values may be defined in sparams structure.')
                %
            end
            %
        else
            %
            disp(['WARNING : ''hxrspec'' structure cannot be calculated by the code ',sparams.diags.hxr.hxrspec.code{ii},' for the machine : ',sparams.machine{ii},'. Use file or value inputs in sparams structure.'])
            %
        end
    else
        %
        disp(['WARNING : ''hxrspec'' structure cannot be calculated by the code ',sparams.diags.hxr.hxrspec.code{ii},' for the machine : ',sparams.machine{ii},'. Use file or value inputs in sparams structure.'])
        %
    end
    %
elseif strcmp(sparams.diags.hxr.hxrspec.source{ii},'file')
    %
    if ~isfield(sparams.diags.hxr.hxrspec,'path') || ~isfield(sparams.diags.hxr.hxrspec,'file')
        %
        disp(['WARNING : path or file name for HXR diagnostic technical specifications are note defined. Search a default file for the machine : ',sparams.diagnostic.machine{ii}])
        %
        hxrspec_file = which(['HXR_',sparams.diagnostic.machine{ii},'.mat']);
        %
        if isempty(hxrspec_file)
            %
            disp('WARNING : file that contains HXR diagnostic technical specifications is not found. HXR synthetic diagnostic calculations are cancelled.')
            %
            return;
            %
        else
            %
            disp(['--> hxrspec file : ',hxrhxrspec_file,' found.'])
            %
            load(hxrparam_file);
            %
            if exist('hxr','var')
                %
                hxrspec = hxr;%backward compatibility
                clear hxr
                %
            end
            %
            if isfield(hxrspec,'beta_hxr')
                %
                nc = length(hxrspec.beta_hxr);% number of chords
                %
                disp(['--> number of chords : ',int2str(nc),'.'])
                %
                if ~strcmp(['SLUKE_HXRSPECS/HXRSPEC_',simul_id,'.mat'],hxrspec_file)
                    %
                    save(['SLUKE_HXRSPECS/HXRSPEC_',simul_id,'.mat'],'hxrspec');
                    %
                end
                %
            else
                %
                nc = 0;% no camera defined
                %
                disp(['--> no camera defined (zero chords). HXR synthetic diagnostic calculations are cancelled.'])
                %
            end

            %
        end
    %
elseif strcmp(sparams.diags.hxr.hxrspec.source{ii},'value')
    %
    if isfield(sparams.diags.hxr,'hxrspec')
        %
        hxrspec = sluke_correct_missing_fields(sluke_params_value(sparams.diags.hxr.hxrspec,ii));
        %
        save(['SLUKE_HXRSPECS/HXRSPEC_',simul_id,'.mat'],'hxrspec');
    end
    %
end
%
% HXR simulations parameters
%
if strcmp(sparams.diags.hxr.hxrparam.source{ii},'file')
    %
    if isfield(sparams.diags.hxr.hxrparam,'file') && isfield(sparams.diags.hxr.hxrparam,'path')
        %
        load([sparams.diags.hxr.hxrparam.path{ii},sparams.diags.hxr.hxrparam.file{ii},'.mat']))
        %
        if exist('hxrparam','var') && ~isempty(hxrparam)
            %
            hxrparam = sluke_correct_missing_fields(hxrparam);%correct missing default terms
            %
        else
            %
            disp('WARNING : hxrparam structure for HXR simulations is empty. HXR synthetic diagnostic calculations are cancelled.')
            return 
            %
        end
        %
    else
        %
        disp('WARNING : file or path for that contain hxrparam structure for HXR simulations are not defined. HXR synthetic diagnostic calculations are cancelled.')
        return
        %
    end   
    %
elseif strcmp(sparams.diags.hxr.hxrparam.source{ii},'value')
    %
    hxrparam = sluke_params_value(sparams.diags.hxr.hxrparam,ii);
    %
    hxrparam = sluke_correct_missing_fields(hxrparam);
    %
end
%
if ~isempty(hxrparam)
    %
    save(['SLUKE_HXRPARAMS/HXRPARAM_',simul_id,'.mat'],'hxrparam');
    %
else
    %
    disp('WARNING : ''hxrparam'' structure for HXR calculations is not defined. Values may be defined in sparams structure.')
    return
    %
end    
%
% HXR calculations
%
dkedisplay = 0
dt = 1
    
%
if exist('hxrspec','var') && exist('hxrparam','var') && ~isempty(hxrspec) && ~isempty(hxrparam) 
    %
    dke_out = lukestructs.output.dke_out;
    equilDKE = lukestructs.output.equilDKE;
    radialDKE = lukestructs.output.radialDKE;
    momentumDKE = lukestructs.output.momentumDKE;
    mksa = lukestructs.output.mksa;
    Zmomcoef = lukestructs.output.Zmomcoef;
    equil = lukestructs.dke_out.equil;
    %
    radialHXR.xpsin_S_dke = radialDKE.xpsin_S_dke;% warning : check in DKE mode
    radialHXR.xpsin_f = radialDKE.xpsin_f_dke;% select only FP points
    %
    [equilHXR] = equilibrium_jd(equil,radialHXR,dkedisplay,'spline',hxrparam.mfactor);%Magnetic equilibrium for HXR at points of the distribution function
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
end
