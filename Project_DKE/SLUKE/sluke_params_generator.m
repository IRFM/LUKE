function sparams = sluke_params_generator(varargin)
%
% LUKE - Generator of simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : none (interactive mode), string (preset parameters) or 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
clc
%
if nargin == 0
    %
    sparams = struct;
    %
    sparams = sluke_params_generator_discharge(sparams);% Interactive mode : general parameters for machines and discharges
    %
    sparams = sluke_params_generator_simulation(sparams);% Interactive mode : general parameters for simulations
    %
    sparams = sluke_params_generator_equilibrium(sparams);% Interactive mode : parameters for the toroidal MHD equilibrium
     %
    sparams = sluke_params_generator_ohmic(sparams);% Interactive mode : parameters for the Ohmic field
    %
    sparams = sluke_params_generator_kinetics(sparams);% Interactive mode : parameters for kinetic calculations
    %
    sparams = sluke_params_generator_waves(sparams);% Interactive mode : parameters for waves calculations
    %
    %sparams = sluke_params_generator_transpfaste(sparams);% Interactive mode : parameters for anomalous fast electron transport
    %
    %sparams = sluke_params_generator_ripple(sparams);% Interactive mode : parameters for magnetic ripple losses
    %
    %sparams = sluke_params_help(sparams);% help 
    %
    %sparams = sluke_params_format(sparams);% help 
    %
else
    %
    if ~isstruct(varargin{1})
        %
        if ~strcmp(lower(varargin{1}),'help') || ~strcmp(lower(varargin{1}),'h')
            %
            sparams = sluke_params_preset(varargin{1});
            %  
        else
            %
            sparams = sluke_params_help(varargin{1});
            %
        end
        %
    end
end

        
        