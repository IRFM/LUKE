function [Zbremchord,Zbremdiag,Zbremplasma,equilHXR,hxrexp] = sluke_dspx(sparams,lukestructs,ii)
%
Zbremchord = '';
Zbremdiag = '';
Zbremplasma = '';
equilHXR = '';
hxrexp = struct;
%
simul_id = sluke_id(sparams,ii,'simul');
%
% DSPX diagnostic technical specifications
%
if strcmp(sparams.diags.DSPX.hxrspec.source{ii},'code')
    %
    if strcmp(sparams.diags.DSPX.hxrspec.code{ii},'R5X2')
        %
        if strcmp(sparams.machine{ii},'TS') ||  strcmp(sparams.machine{ii},'WEST') 
            %
            [hxrspec,~] = get_hxrspec_forLUKE_jd('TS',str2num(sparams.discharge.shot{ii}),'','','');
            %
            if ~isempty(hxrspec)
                %
                if isfield(sparams.diags.DSPX.hxrspec,'chordstatus_hxr')
                    %
                    hxrspec.chordstatus_hxr = sparams.diags.DSPX.hxrspec.chordstatus_hxr{ii};%overwrite chord status if any need
                    %
                end
                %
                save(['SLUKE_DIAGNOSTICS/DSPX_SPEC_',simul_id,'.mat'],'hxrspec');
                %
            else
                %
                disp('WARNING : ''hxrspec'' structure for DSPX calculations is not defined. Values may be defined in sparams structure.')
                %
            end
            %
        else
            %
            disp(['WARNING : ''hxrspec'' structure cannot be calculated by the code ',sparams.diags.DSPX.hxrspec.code{ii},' for the machine : ',sparams.machine{ii},'. Use file or value inputs in sparams structure.'])
            %
        end
    else
        %
        disp(['WARNING : ''hxrspec'' structure cannot be calculated by the code ',sparams.diags.DSPX.hxrspec.code{ii},' for the machine : ',sparams.machine{ii},'. Use file or value inputs in sparams structure.'])
        %
    end
    %
elseif strcmp(sparams.diags.DSPX.hxrspec.source{ii},'file')
    %
    if ~isfield(sparams.diags.DSPX.hxrspec,'path') || ~isfield(sparams.diags.DSPX.hxrspec,'file')
        %
        disp(['WARNING : path or file name for DSPX diagnostic technical specifications are note defined. Search a default file for the machine : ',sparams.diagnostic.machine{ii}])
        %
        hxrspec_file = which(['HXR_',sparams.diagnostic.machine{ii},'.mat']);
        %
        if isempty(hxrspec_file)
            %
            disp('WARNING : file that contains DSPX diagnostic technical specifications is not found. synthetic diagnostic calculations are cancelled.')
            %
            return;
            %
        else
            %
            disp(['--> hxrspec file : ',hxrhxrspec_file,' found.'])
            %
            load(hxrspec_file);
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
                if ~strcmp(['SLUKE_DIAGNOSTICS/DSPX_SPEC_',simul_id,'.mat'],hxrspec_file)
                    %
                    save(['SLUKE_DIAGNOSTICS/DSPX_SPEC_',simul_id,'.mat'],'hxrspec');
                    %
                end
                %
            else
                %
                nc = 0;% no camera defined
                %
                disp(['--> no camera defined (zero chords). Synthetic diagnostic calculations for DSPX are cancelled.'])
                %
            end
            %
        end
    else
        %
        load([sparams.diags.DSPX.hxrspec.path{ii},sparams.diags.DSPX.hxrspec.file{ii}]);
        %
        if exist('hxr','var')
            %
            hxrspec = hxr;%backward compatibility
            clear hxr
            %
        end
        %
    end
    %
elseif strcmp(sparams.diags.DSPX.hxrspec.source{ii},'value')
    %
    if isfield(sparams.diags.dspx,'hxrspec')
        %
        hxrspec = sluke_correct_missing_fields(sluke_params_value(sparams.diags.DSPX.hxrspec,ii));
        %
        save(['SLUKE_DIAGNOSTICS/DSPX_SPEC_',simul_id,'.mat'],'hxrspec');
    end
    %
end
%
hxrspec.kfit = hxrspec.kphot(1:2:end);
%
% DPSX simulations parameters
%
if strcmp(sparams.diags.DSPX.hxrparam.source{ii},'file')
    %
    if isfield(sparams.diags.DSPX.hxrparam,'file') && isfield(sparams.diags.DSPX.hxrparam,'path')
        %
        load([sparams.diags.DSPX.hxrparam.path{ii},sparams.diags.DSPX.hxrparam.file{ii},'.mat'])
        %
        if exist('hxrparam','var') && ~isempty(hxrparam)
            %
            hxrparam = sluke_correct_missing_fields(hxrparam);%correct missing default terms
            %
        else
            %
            disp('WARNING : hxrparam structure for DSPX simulations is empty. Synthetic diagnostic calculations for DSPX are cancelled.')
            return 
            %
        end
        %
    else
        %
        disp('WARNING : file or path for that contain hxrparam structure for DSPX simulations are not defined. Synthetic diagnostic calculations for DSPX are cancelled.')
        return
        %
    end   
    %
elseif strcmp(sparams.diags.DSPX.hxrparam.source{ii},'value')
    %
    hxrparam = sluke_params_value(sparams.diags.DSPX.hxrparam,ii);
    %
    hxrparam.kphot = hxrspec.kphot;
    hxrparam.kmin = hxrspec.kmin;
    hxrparam.kmax = hxrspec.kmax;
    %
%    hxrparam = sluke_correct_missing_fields(sparams,ii,hxrparam);
    %
end
%
if ~isempty(hxrparam)
    %
    save(['SLUKE_DIAGNOSTICS/DSPX_PARAM_',simul_id,'.mat'],'hxrparam');
    %
else
    %
    disp('WARNING : ''hxrparam'' structure for DSPX calculations is not defined. Values may be defined in sparams structure.')
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
    [equilHXR] = equilibrium_jd(equil,radialHXR,dkedisplay,'spline',hxrparam.mfactor);%Magnetic equilibrium for DSPX at points of the distribution function
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
    [hxrexp.energy,hxrexp.hxr,hxrexp.t,hxrexp.beta,hxrexp.filter_thickness,hxrexp.filter_material,hxrexp.all_hxr_data] = collect_hxr_forLUKE_jd(sparams.machine{ii},sparams.discharge.shot{ii});
    %
end
%

