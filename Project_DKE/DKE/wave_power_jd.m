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
function [waves,byisel] = wave_power_jd(dkeparam,wavefiles,byPnonabs)
%
% INPUT
%    - dkeparam structure
%    - waves files structure
%
% OUTPUT:
%    - waves structure
%
% By Joan Decker (CEA-DRFC, joan.decker@cea.fr) and Yves Peysson (CEA-DRFC, yves.peysson@cea.fr)
%
if nargin < 2,
    error('Wrong number of input arguments in wave_distribution_yp.m.');
end
%
if nargin < 3,
    byPnonabs = NaN;
end
%
nw = length(wavefiles);
%
waves = cell(1,nw);
%
for iw = 1:nw,
    data = load(wavefiles{iw});
    waves{iw} = data.wave;
end
%
if isfield(dkeparam,'enforcepower') && dkeparam.enforcepower,
    %
    % Initial power in the waves
    %
    ny = zeros(1,nw);
    yPtot_inj = cell(1,nw);
    %
    for iw = 1:nw,% for each wave
        %
        wave = waves{iw};
        %
        % initialize non-absorbed power in each ray 
        %
        if isfield(wave.rayinit.launch,'bPlhtot'),%LH wave
            ny(iw) = length(wave.rayinit.launch.bPlhtot);
            yPtot_inj{iw} = wave.rayinit.launch.bPlhtot;%LH injected power at t=itn
        elseif isfield(wave.rayinit.launch,'yP_L'),%EC wave
            ny(iw) = length(wave.rayinit.launch.yP_L);
            yPtot_inj{iw} = wave.rayinit.launch.yP_L;%EC injected power at t=itn
        end
    end
    %
    % Add non-absorbed power from last simulation
    %
    if ~iscell(byPnonabs),% first time step, with fluctuations
        byPnonabs = cell(1,nw);
        for iw = 1:nw,% for each wave
            byPnonabs{iw} = zeros(1,ny(iw));
        end
    end
    %
    % byPnonabs contains the power not absorbed
    %
    if iscell(byPnonabs),%calculate fluctuation phases and adjust initial power in each ray
        for iw = 1:nw,
            waves{iw} = mod_wave_power_jd(waves{iw},yPtot_inj{iw} + byPnonabs{iw});
        end
    end    
    %
    % identify rays and lobes/beams
    %
    byisel = cell(1,nw);
    iray = 0;
    for iw = 1:nw,
        wave = waves{iw};
        %        
        byisel{iw} = cell(1,ny);
        %
        for iy = 1:ny,
            byisel{iw}{iy} = [];
        end
        %
        % byisel contains the ray number belonging to the same lobe with possibly different launching positions (LH) or
        % to the same beam with different beamlets (EC)
        %
        for ib = 1:length(wave.rays),
            iray = iray+1;
            %
            iy = wave.rays{ib}.rayinits{1}.yib;
            %
            byisel{iw}{iy} = [byisel{iw}{iy},iray];
        end
    end
else
    byisel = NaN;
end
%    
