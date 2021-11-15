function equil = sluke_equil(sparams,ii)
%
% LUKE - Calculations of the toroidal MHD equilibrium for sluke. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin{1} : initial 'sparams' structure
%   - varargin{2} : simulation index in the sparams structure
%
% OUTPUT :
%
%   - equil : toroidal MHD equilibrium structure for sluke
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
equil_id = sluke_id(sparams,ii,'equil');
%
if exist(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'])
    %
    load(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat']);
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
        else
            %
            disp(['WARNING : the code ',sparams.equil.code{ii},' is not yet implemented'])
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
            equil = data.equil;
            equil.id = data.equil.id;
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
end
%
if isfield(sparams,'impurities') %full or partial screening effect
    %
    if isfield(sparams.impurities,'coulog_model')
        %
        equil.coulog_model = sparams.impurities.coulog_model{ii};%Coulomb logarithm model
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
    if isfield(sparams.impurities,'screening') && isfield(sparams.impurities.screening,'ADAS') && ~isempty(sparams.impurities.screening.ADAS{ii})
        %
        equil.ADAS = sparams.impurities.screening.ADAS{ii};% ADAS.mat for default LUKE or full path for ADAS file outside the LUKE path
        %
        if isfield(sparams.impurities.screening,'partial') && isfield(sparams.impurities.screening.partial,'elastic') && ~isempty(sparams.impurities.screening.partial.elastic{ii})
            %
            equil.screening.elastic = sparams.impurities.screening.partial.elastic{ii};
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'elastic')
                %
                equil.screening = rmfield(equil.screening,'elastic');
                cprintf([1,0.5,0],['---> Elastic scattering is not considered in partial screening calculations.']);disp(' ')
                %
            end
            %
        end
        %
        if isfield(sparams.impurities.screening,'partial') && isfield(sparams.impurities.screening.partial,'inelastic') && ~isempty(sparams.impurities.screening.partial.inelastic{ii})
            %
            equil.screening.inelastic = sparams.impurities.screening.partial.inelastic{ii};
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'inelastic')
                %
                equil.screening = rmfield(equil.screening,'inelastic');
                cprintf([1,0.5,0],['---> Inelastic scattering is not considered in partial screening calculations.']);disp(' ')
                %
            end
            %
        end
        %
        if isfield(sparams.impurities.screening,'partial') && isfield(sparams.impurities.screening.partial,'dftpath')
            %
            equil.screening.dftpath = sparams.impurities.screening.partial.dftpath{ii};%path for DFT files outside the LUKE path if not empty. Should be accessible on a remote machine
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'dftpath')
                %
                equil.screening = rmfield(equil.screening,'dftpath');
                %
            end
            %
        end
        %
        if isfield(sparams.impurities.screening,'partial') && isfield(sparams.impurities.screening.partial,'bremsstrahlung') && isfield(sparams.impurities.screening.partial.bremsstrahlung,'params')
            %
            equil.screening.params = sluke_params_value(sparams.impurities.screening.partial.bremsstrahlung.params,ii);%params for bremsstrahlung calculations with partial screening (see bremsstrahlung_dke_yp.m)
            %
        else
            %
            if isfield(equil,'screening') && isfield(equil.screening,'params')
                %
                equil.screening = rmfield(equil.screening,'params');
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
    % Remove impurity selection (Zi > 1)
    %
    if isfield(sparams.impurities,'removed_Zi') && ~isempty(sparams.impurities.removed_Zi{ii})
        %
        for mm = 4:length(equil.zZi) % the three first elements are hydrogen isotops
            %
            if ~isnan(sparams.impurities.removed_Zi{ii})
                %
                for nn = 1:length(sparams.impurities.removed_Zi{ii})
                    %
                    if equil.zZi(mm) == sparams.impurities.removed_Zi{ii}(nn)
                        %
                        equil.pzni(mm,:) = equil.pzni(mm,:)*0;%no impurity for this Zi value
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
    if ~isfield(sparams.equil,'coulog') && isfield(equil,'screening')
        %
        equil.coulog = 1;%Coulomb logarithm model (Sauter)
        cprintf([1,0.5,0],['---> Default Coulomb logarithm value (Sauter) with p-dependence is enforced for screening.']);disp(' ')
        %
    end
    %
end
%
% fitequil (for C3PO and equil consistency calculations
%
if isfield(sparams.equil,'fit')
    %
    fit_id = sluke_id(sparams,ii,'fit');
    equil.source.fit = ['SLUKE_EQUILS/FITEQUIL_',fit_id,'.mat'];
    equil.equil_fit = fitequil_yp(equil,sparams.equil.fit.mode_equil{ii},sparams.equil.fit.method{ii},sparams.equil.fit.ngridresample{ii},sparams.equil.fit.nharm{ii});
    %
else
    %
    if ~isfield(equil,'equil_fit')
        %
        equil.equil_fit = fitequil_yp(equil);%default values
        %
    end
    %
end
%
% equilibrium consistency calculations
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
else
    %
    equil = equilconsistency_yp(equil,'',real(sparams.equil.equilconsistency.display_mode));
    %
end
%
save(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'],'equil');
%
% Save Ohmic field structure when it is created by the same code
%
if exist('ohm','var') == 1
    %
    ohm_id = sluke_id(sparams,ii,'ohm');
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


    
    
    