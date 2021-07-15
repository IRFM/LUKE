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
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.equil.source{ii},'value')
        %
        %TODO for simple models
        %
    end
    %
    % fitequil (for C3PO and equil consistency calculations
    %
    if isfield(sparams.equil,'fit')
        %
        fit_id = sluke_id(sparams,ii,'fit');
        equil.source.fit = ['SLUKE_FITEQUILS/FITEQUIL_',fit_id,'.mat'];
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
    %
end

    
    
    