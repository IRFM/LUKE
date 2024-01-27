function equil = sluke_equil(sparams,ii,jit)
%
% LUKE - Calculations of the toroidal MHD equilibrium for sluke. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - sparams : initial 'sparams' structure
%   - ii : simulation index in the sparams structure
%   - jit : j selfconsistency interation index
%
% OUTPUT :
%
%   - equil : toroidal MHD equilibrium structure for sluke
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
equil_id = sluke_id(sparams,ii);
%
if exist(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'])
    %
    load(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat']);
    %
    equil0 = equil;
    %
    if iscell(equil0)
        %
        if nargin < 3
            %
            equil = equil0{end};%last equil for j consistency loop
            %
        else
            %
            equil = equil0{jit};%last equil for j consistency loop 
            %
        end
        %
    else
        %
        equil = equil0;
        %
    end
    %
else
    %
    if isfield(sparams.equil,'source') && isempty(sparams.equil.source{ii})
        %
        if ~isfield(sparams.equil,'file') && ~isfield(sparams.equil,'path') && isfield(sparams.equil,'code') && ~isempty(sparams.equil.code{ii}) 
            %
            sparams.equil.source{ii} = 'code';
            %
        elseif isfield(sparams.equil,'file') && isfield(sparams.equil,'path') && ~isfield(sparams.equil,'code') && ~isempty(sparams.equil.file{ii}) && ~isempty(sparams.equil.path{ii}) 
            %
            sparams.equil.source{ii} = 'file';
            %
        else     
            %
            error('ERROR : sparams.equil.source inconsistently defined. Rebuild the sparams structure.')
            %
        end
        %
    end
    %
    if strcmp(sparams.equil.source{ii},'code')
        %
        if strcmp(sparams.equil.code{ii},'autoTSmetis') % spectific to Tore Supra tokamak
            %
            [dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = sluke_autoTSmetis(sparams,ii);
            %
        elseif strcmp(sparams.equil.code{ii},'EFIT') % EFIT code from agnetic measurements
            %
            if isfield(sparams.equil,'EFIT') && isstruct(sparams.equil.EFIT)
                %
                flag_EFIT = 1;
                %
                if isfield(sparams.equil.EFIT,'type') && ~isempty(sparams.equil.EFIT.type{ii})
                    %
                    EFIT_type = sparams.equil.EFIT.type{ii};
                    %
                else
                    %
                    flag_EFIT = 0;
                    %
                end
                %
                if isfield(sparams.equil.EFIT,'Zeff') && ~isempty(sparams.equil.EFIT.Zeff{ii})
                    %
                    EFIT_Zeff = sparams.equil.EFIT.type{ii};
                    %
                else
                    %
                    Zeff_EFIT = 0;
                    %
                end
                %
                if isfield(sparams.equil.EFIT,'display') && ~isempty(sparams.equil.EFIT.display{ii})
                    %
                    EFIT_display = sparams.equil.EFIT.display{ii};
                    %
                else
                    %
                    cprintf([1,0.5,0],['WARNING : the parameter ''display'' of the code ',sparams.equil.code{ii},' is not defined. It is enforced to 2.']);disp(' ')
                    EFIT_display = 2;
                    %
                end
                %
                if isfield(sparams.equil.EFIT,'p_opt') && ~isempty(sparams.equil.EFIT.p_opt{ii})
                    %
                    EFIT_p_opt = sparams.equil.EFIT.p_opt{ii};
                    %
                else
                    %
                    cprintf([1,0.5,0],['WARNING : the parameter ''p_opt'' of the code ',sparams.equil.code{ii},' is not defined. It is enforced to 2.']);disp(' ')
                    EFIT_p_opt = -1;
                    %
                end
                %
                if flag_EFIT == 1
                    %
                    equil = equil_EFIT_jd([sparams.equil.path{ii},'/',sparams.equil.file{ii}],EFIT_type,EFIT_display,EFIT_p_opt,equil_id,equil_id,EFIT_Zeff);
                    delete(['EQUIL_',equil_id,'.mat']);
                    %
                else
                    %
                    cprintf('*red',['ERROR : some parameters of the code ',sparams.equil.code{ii},' are not defined.']);disp(' ')
                    %
                end
                %   
            else
                %
                cprintf('*red',['ERROR : the parameters of the code ',sparams.equil.code{ii},' are not defined.']);disp(' ')
                %
            end
        else
            %
            cprintf([1,0.5,0],['WARNING : the code ',sparams.equil.code{ii},' is not yet implemented.']);disp(' ')
            %
        end
        %
    elseif strcmp(sparams.equil.source{ii},'file')
        %
        equil_file = sparams.equil.file{ii};
        equil_path = sparams.equil.path{ii};
        %
        if strcmp(sparams.equil.path{ii},'.')
            equil_path = [pwd,'/'];
        else
            if strcmp(sparams.equil.path{ii}(end),'/')
                equil_path = sparams.equil.path{ii};
            else
                equil_path = [sparams.equil.path{ii},'/'];
            end
        end
        %
        data = load([equil_path,equil_file]);
        %
        if isfield(data,'post') % equilibrium from metis simulations
            %
            [dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = sluke_metis2luke(sparams,ii,data.post);
            equil.id = equil_id;
            %
        elseif isfield(data,'equil') % LUKE equilibrium format
            %
            if iscell(data.equil)
                %
                equil = data.equil{end};
                %
            else
                %
                equil = data.equil;
                %
            end
            %
        else    
            error([]);
        end
        %
    else
        %
        %TODO for simple models
        %
    end
    %
    equil.jnit = 1;%current index j consistency loop
    equil.jnitmax = 1;%max index j consistency loop
    %
    if isfield(sparams.simul,'jprofileconsistency') && isfield(sparams.simul.jprofileconsistency,'nit') && ~isempty(sparams.simul.jprofileconsistency.nit{ii}) && sparams.simul.jprofileconsistency.nit{ii} >= 1
        %
        equil.jnitmax = sparams.simul.jprofileconsistency.nit{ii};   
        %
    end
    %
end
%
% Full or partial screening for Coulomb collisions
%
if isfield(sparams,'kinetics') && isfield(sparams.kinetics,'elements') %for full or partial screening effects
    %
    if isfield(sparams.kinetics.elements,'coulog_model')
        %
        equil.coulog_model = sparams.kinetics.elements.coulog_model{ii};%Coulomb logarithm model
    %
    else
        %
        if isfield(equil,'coulog_model')
            %
            equil = rmfield(equil,'coulog_model');
            equil.coulog_model = 0;
            cprintf([1,0.5,0],['---> Default Coulomb logarithm without p-dependence is considered.']);disp(' ')
            %
        end
        %
    end
    %
    if isfield(sparams.kinetics.elements,'screening') && isfield(sparams.kinetics.elements.screening,'ADAS') && ~isempty(sparams.kinetics.elements.screening.ADAS{ii})
        %
        equil.ADAS = sparams.kinetics.elements.screening.ADAS{ii};% ADAS.mat for default LUKE or full path for ADAS file outside the LUKE path
        %
        if isfield(sparams.kinetics.elements.screening,'partial') && isfield(sparams.kinetics.elements.screening.partial,'elastic') && ~isempty(sparams.kinetics.elements.screening.partial.elastic{ii})
            %
            equil.screening.elastic = sparams.kinetics.elements.screening.partial.elastic{ii};
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'elastic')
                %
                equil.screening = rmfield(equil.screening,'elastic');
                cprintf([1,0.5,0],['---> Elastic scattering is not considered for partial screening calculations.']);disp(' ')
                %
            end
            %
        end
        %
        if isfield(sparams.kinetics.elements.screening,'partial') && isfield(sparams.kinetics.elements.screening.partial,'inelastic') && ~isempty(sparams.kinetics.elements.screening.partial.inelastic{ii})
            %
            equil.screening.inelastic = sparams.kinetics.elements.screening.partial.inelastic{ii};
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'inelastic')
                %
                equil.screening = rmfield(equil.screening,'inelastic');
                cprintf([1,0.5,0],['---> Inelastic scattering is not considered for partial screening calculations.']);disp(' ')
                %
            end
            %
        end
        %
        if isfield(sparams.kinetics.elements.screening,'partial') && isfield(sparams.kinetics.elements.screening.partial,'dftpath')
            %
            equil.screening.dftpath = sparams.kinetics.elements.screening.partial.dftpath{ii};%path for DFT files outside the LUKE path if not empty. Should be accessible on a remote machine
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'dftpath')
                %
                equil.screening = rmfield(equil.screening,'dftpath');
                cprintf([1,0.5,0],['---> Specific DFT file external to LUKE is not considered for partial screening calculations.']);disp(' ')
                %
            end
            %
        end
        %
    else
        %
        if isfield(equil,'ADAS')
            %
            equil = rmfield(equil,'ADAS');
            %
        end
        %
        if isfield(equil,'screening')
            %
            equil = rmfield(equil,'screening');%no partial screening calculations without ADAS table
            %
        end
        %
        cprintf([1,0.5,0],['---> No ADAS file definition in sparams : effect of full or partial screening is not considered, impurities are considered as fully stripped.']);disp(' ')
        %
    end
    %
    % Modify density of the impurity selection (Zi > 1)
    %
    if ~isfield(equil,'flag_Zi')   
        %
        if isfield(sparams.kinetics.elements,'Zi_ref') && ~isempty(sparams.kinetics.elements.Zi_ref{ii})
            %
            for mm = 4:length(equil.zZi) % the three first elements are hydrogen isotops
                %
                if ~isnan(sparams.kinetics.elements.Zi_ref{ii})
                    %
                    for nn = 1:length(sparams.kinetics.elements.Zi_ref{ii})
                        %
                        if equil.zZi(mm) == sparams.kinetics.elements.Zi_ref{ii}(nn)
                            %
                            if isfield(sparams.kinetics.elements,'Zi_density_factor') && ~isempty(sparams.kinetics.elements.Zi_density_factor{ii}) && ~isnan(sparams.kinetics.elements.Zi_density_factor{ii})
                                %
                                equil.pzni(mm,:) = equil.pzni(mm,:)*sparams.kinetics.elements.Zi_density_factor{ii};%no impurity for this Zi value
                                cprintf([1,0.5,0],['---> Density of impurity with atomic number ',int2str(equil.zZi(mm)),' has been mutiplied by factor x',num2str(sparams.kinetics.elements.Zi_density_factor{ii}),' (for tests).']);disp(' ')
                                break
                                %
                            end
                            %
                        end
                        %
                    end
                    %
                end
                %
            end
            %
            equil.flag_Zi = 1;%to avoid this loop in other call of sluke_equil.m when file EQUIL_*;m file is loaded
            %
        end
    end
    %
    if ~isfield(sparams.kinetics.elements,'coulog_model') && isfield(sparams.kinetics.elements,'screening') && isfield(sparams.kinetics.elements.screening,'elastic') && ~isempty(sparams.kinetics.elements.screening.elastic{ii})
        %
        equil.coulog_model = 1;%Coulomb logarithm model (Sauter)
        cprintf([1,0.5,0],['---> Default Coulomb logarithm value (Sauter) with p-dependence is enforced for partial screening.']);disp(' ')
        %
    end
    %
end
%
flag_equil_fit = 0;
%
% fitequil (for C3PO and equil consistency calculations
%
if ~isfield(equil,'equil_fit')
    %
    if isfield(sparams.equil,'fit')
        %
        equil.equil_fit = fitequil_yp(equil,sparams.equil.fit.mode_equil{ii},sparams.equil.fit.method{ii},sparams.equil.fit.ngridresample{ii},sparams.equil.fit.nharm{ii});
        %
    else
        %
        equil.equil_fit = fitequil_yp(equil);%default values
        %
    end
    %
    flag_equil_fit = 1;
end
%
% equilibrium consistency calculations
%
flag_equil_consistency = 0;
%
if ~isfield(equil,'consistency')
    %
    if isfield(sparams.equil,'equilconsistency')
        %
        if isfield(equil,'equil_fit')
            %
            equil = equilconsistency_yp(equil,equil.equil_fit,sparams.equil.equilconsistency.auto_mode{ii},sparams.equil.equilconsistency.display_mode{ii},sparams.equil.equilconsistency.prho{ii},sparams.equil.equilconsistency.mtheta{ii},sparams.equil.fit);
            %
        else
            %
            equil = equilconsistency_yp(equil,'',sparams.equil.equilconsistency.auto_mode{ii},sparams.equil.equilconsistency.display_mode,sparams.equil.equilconsistency.prho{ii},sparams.equil.equilconsistency.mtheta{ii},sparams.equil.fit);
            %
        end
        %
        flag_equil_consistency = 1;
        %
    else
        %
        cprintf([1,0.5,0],['---> Consistency of the toroidal MHD equilibrium cannot be calculated.']);disp(' ')
        %equil = equilconsistency_yp(equil,'',real(sparams.equil.equilconsistency.display_mode));
        %
    end
    %
   
end
%
% Determination of the upper kinetic energy limit
%
radialDKE.r_dke = equil.ptx(:,1);
mksa = mksacoefbuilder_dke_yp(sluke_dkeparam(sparams,ii),'',equilibrium_jd(equil,radialDKE.r_dke),radialDKE);
equil.Ecmax_ref = mksa.Ecmax_ref;%keV
clear mksa radialDKE
%
if ~exist(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'])
    %
    equil = {equil};
    %
    save(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'],'equil');
    %
    equil = equil{1};
    %
else
    %
    if flag_equil_consistency == 1 || flag_equil_fit == 1
        %
        if nargin < 3
            %
            equil0(end) = {equil};
            %
        else
            %
            equil0(jit) = {equil};
            %
        end
        %
        equil = equil0;
        %
        save(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'],'equil');
        %
        if nargin < 3
            %
            equil = equil0{end};
            %
        else
            %
            equil = equil0{jit};
            %
        end
        %
    end
    %
end  
%
% Save Ohmic field structure when it is created by the same code
%
if exist('ohm','var') == 1
    %
    ohm_id = sluke_id(sparams,ii);
    %
    if strcmp(sparams.equil.source{ii},sparams.ohm.source{ii})
        %
        if isfield(sparams.equil,'code') && isfield(sparams.ohm,'code') && strcmp(sparams.equil.code{ii},sparams.ohm.code{ii})
            %
            save(['SLUKE_OHMS/OHM_',ohm_id,'.mat'],'ohm');
            %
            disp(['WARNING : ohm structure from the same code ''',sparams.ohm.code{ii},''' has been also saved.'])
            %
        elseif isfield(sparams.equil,'file') && isfield(sparams.ohm,'file') && strcmp(sparams.equil.file{ii},sparams.ohm.file{ii})
            %
            save(['SLUKE_OHMS/OHM_',ohm_id,'.mat'],'ohm');
            %
            disp(['WARNING : ohm structure from the same input file ''',sparams.ohm.path{ii},sparams.ohm.file{ii},''' has been also saved.'])
            %
        end
        % 
    end
    %
end
%
dd = dir(['INPUTS/before_luke@*.mat']);
%
if ~isempty(dd)
    %
    delete(['INPUTS/before_luke@*.mat']);%delete all before_luke@ files to avoid wrong files if they come from different METIS simulations
    %
end
%
if isfield(equil,'fluct') && isfield(equil.fluct,'enable') && equil.fluct.enable{ii} == 1
    %
    %[fluct] = fluctstruct_yp(equil,id_fluct,naequilp);
    %fluct.naequilp = naequilp;
    %
    %equil.fluct = fluct;
    %equil.fluct.fitparam = fluct_fitparam;
    %
end
    
    
    