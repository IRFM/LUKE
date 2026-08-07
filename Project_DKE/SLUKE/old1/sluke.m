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
function [data] = sluke(data)
%   
%    Calculates electron distribution function inside the separatrix on nested magnetic flux surfaces. Script may be called recursively for numerical and physical purposes. 
%
%    Input: 
%
%       - data : LUKE data file name or data structure or simulation presets   
%
%    Output:
%
%       - data : LUKE data structure      
%
% by Y.PEYSSON CEA-IRFM <yves.peysson@cea.fr>
%
clc
%
scolor = sluke_color;
%
if nargin == 1
    %
    if ischar(data)
        %
        if strfind(data,'SLUKE_DATA_')
            filename = data;
            data = load(filename);
        else
            error('ERROR: file name must start with ''SLUKE_DATA_''')
        end
    end
    %
else
    %
    error('ERROR: file name must start with ''SLUKE_DATA_''')
    %
end
%
if isstruct(data)
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load existing data file and perform postprocessing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_postproc(data);%post processing
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display simulation status and results
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_display(data);
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_save(data);%save data
    %
else
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load and run simulation settings script
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if ~isempty(preset)
        data = sluke_start(preset);
    else
        data = sluke_start;
    end
    %
    if isempty(data),
        %
        scolor = 'red';
        %
        cprintf(scolor,['-----> The global settings file ''sluke_settings.m'' in ''',workdir,''' folder must be filled. Then type sluke_settings in the matlab command window.\n'])
        %
        return;
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load advanced simulation settings 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_advanced_settings(data);
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Validation data consistency and preprocessing
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_preproc(data);
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build simulation id
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_id(data);
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Start calculations and save data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_run(data);%run LUKE and related modules
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    data = sluke_save(data);
    %
end
