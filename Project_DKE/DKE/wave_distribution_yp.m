function [waves,wavestructs,byisel] = wave_distribution_yp(dkepath,dkeparam,wavestructs,f0struct,dt_fluct,byPnonabs)
%
% Split the M rays in each wavestructs into N*M rays with P/N power for averaging the effect of plasma fluctuations on ray propagation (C3PO code only). 
% May use distributed processing for reducing the overall computational time
%
% INPUT
%    - dkepath structure
%    - dkeparam structure
%    - wavestructs structure
%    - f0struct structure
%    - dt_fluct fluctuation correlation time (is s).
%
% OUTPUT:
%    - waves structure
%    - wavestructs structure (it is output since the phase has changed)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 3,
    error('Wrong number of input arguments in wave_distribution_yp.m.');
end
%
if nargin < 6,
    byPnonabs = NaN;
end
%
if nargin < 5,
    dt_fluct = Inf;
end
%
if nargin < 4,
    f0struct = [];
end
%
if isfield(dkeparam,'Nfluct'),
    Nfluct = max([1,round(dkeparam.Nfluct)]);
else
    Nfluct = 1;
end
%
nw = size(wavestructs,2);
%
% If Nfluct > 1, parallel fluctuation states are considered simultaneously
%
if ~iscell(byPnonabs) && ~isinf(dt_fluct),% first time step, with fluctuations
    %
    if size(wavestructs,1) > 1,
        error('byPnonabs must be provided if wavestruct structure already duplicated.')
    end
    %
    wavestructs = repmat(wavestructs,[Nfluct,1]);% copy wavestructs in Nfluct structures
    byPnonabs = cell(Nfluct,nw);
    %
    for ifluct = 1:Nfluct,
        %
        for iw = 1:nw,% for each wavestruct
            %
            % initialize power in each ray by deviding total power
            %
            if isfield(wavestructs{ifluct,iw}.launch,'bPlhtot'),%LH wave
                %
                wavestructs{ifluct,iw}.launch.bPlhtot_in = wavestructs{ifluct,iw}.launch.bPlhtot/Nfluct;%Total launched LH power is constant (sensitive to core and edge fluctuations)
                byPnonabs{ifluct,iw} = zeros(1,length(wavestructs{ifluct,iw}.launch.bPlhtot));
                %
            elseif isfield(wavestructs{ifluct,iw}.launch,'yP_L'),%EC wave
                %
                wavestructs{ifluct,iw}.launch.yP_L_in = wavestructs{ifluct,iw}.launch.yP_L/Nfluct;%Total launched EC power is constant (sensitive to core fluctuations only)
                byPnonabs{ifluct,iw} = zeros(1,length(wavestructs{ifluct,iw}.launch.yP_L));
                %
            end
            %
            % limit tfinal according to dtn_fluct
            %
            if ~isinf(dt_fluct),
                wavestructs{ifluct,iw}.rayparam.tfinal = dt_fluct*wavestructs{ifluct,iw}.launch.omega_rf;%ray tracing duration cannot exceed the fluctuation correlation time (x 2.3 approximately)
            end
            %
        end
    end
end
%
% byPnonabs contains the power not absorbed
%
if iscell(byPnonabs),%calculate fluctuation phases and adjust initial power in each ray
    %
    if size(wavestructs,1) ~= Nfluct,
        error('wavestruct structure must be already duplicated if byPnonabs is provided.')
    end
    %
    for ifluct = 1:Nfluct,
        %
        if isfield(wavestructs{ifluct,1}.equil_fit,'fluct_fit') && ~isempty(fieldnames(wavestructs{ifluct,1}.equil_fit.fluct_fit)),
            %
            fluct_fit = fluctphase_yp(wavestructs{ifluct,1}.equil_fit.fluct_fit);%Calculations with new random phase for each structure (equilibrium fluctuations). Spectrum fluctuations are done in main_rayinit_launch_jd.m
            %
            for iw = 1:nw,
                %
                wavestructs{ifluct,iw}.equil_fit.fluct_fit = fluct_fit;%Replicate the same fluctuation structure to all wavestructs (equilibrium fluctuations)
                %
            end
        end
        %
        for iw = 1:nw,
            if isfield(wavestructs{ifluct,iw}.launch,'bPlhtot'),%LH wave
                %
                wavestructs{ifluct,iw}.launch.bPlhtot = wavestructs{ifluct,iw}.launch.bPlhtot_in + byPnonabs{ifluct,iw};%Total launched LH power is constant
                %
            elseif isfield(wavestructs{iw}.launch,'yP_L'),%EC wave
                %
                wavestructs{ifluct,iw}.launch.yP_L = wavestructs{ifluct,iw}.launch.yP_L_in + byPnonabs{ifluct,iw};%Total launched LH power is constant
                %
            end          
        end 
    end          
end    
%
dkecluster = clustermode_luke(dkeparam.clustermode,'wave_solver_yp',dkepath);%MatLab distributed computing environment
%
if dkecluster.scheduler.mode >= 0,
    [flag,waves] = mdce_luke(@wave_solver_yp,{dkepath,'',f0struct},2,wavestructs(:),dkecluster);
else% remote computing
    [flag,waves] = mdce_luke(@wave_solver_yp,{'','',f0struct},2,wavestructs(:),dkecluster);
end    
%
% determines which rays actually enter the plasma and report the ray number in zP_0_2piRp_mod
%
byisel = cell(Nfluct,nw);
iray = 0;
for iw = 1:nw,
    for ifluct = 1:Nfluct,
        wave = waves{ifluct+Nfluct*(iw-1)};
        %
        if isfield(wavestructs{ifluct,iw}.launch,'bPlhtot'),%LH wave
            ny = length(wavestructs{ifluct,iw}.launch.bPlhtot);%number of lobes
        elseif isfield(wavestructs{iw}.launch,'yP_L'),%EC wave
            ny = length(wavestructs{ifluct,iw}.launch.yP_L);%number of rays
        end          
        %        
        byisel{ifluct,iw} = cell(1,ny);
        %
        for iy = 1:ny,
            byisel{ifluct,iw}{iy} = [];
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
            byisel{ifluct,iw}{iy} = [byisel{ifluct,iw}{iy},iray];
        end
    end
end
%    
