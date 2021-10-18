function diag = sluke_synthetic_diag(code,data_in)
%
if strcmp(code,'R5X2')
    %
    hxrspec = data_in.hxrspec;
    hxrparam = data_in.hxrparam;
    lukestructs = data_in.lukestructs;
    %
    dkedisplay.display_mode = 0;%to be checked
    dkedisplay.fhxr = 0;%to be checked
    dt = 1;%to be checked
    disp('**********TODO : sluke_synthetic_diag l.10 *****************')
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
        if ~isfield(hxrparam,'full_results') || (isfield(hxrparam,'full_results') && hxrparam.full_results == 0)
            %
            Zbremdiag = rmfield(Zbremdiag,'gkEinterp_out');%largest memory size
            diag.Zbremdiag = Zbremdiag;%results that can be compared to experimental measurements
            %
        else
            %
            diag.Zbremplasma = Zbremplasma;
            diag.Zbremchord = Zbremchord;
            diag.Zbremdiag = Zbremdiag;
            diag.equilHXR = equilHXR;
            %
        end  
        %
    else
        %
        diag = '';
        %
    end
    %
end