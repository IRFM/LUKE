function [launchs,ids] = get_launchs_EAST
%
% This function contains the characteristics of the LH antennas of the EAST Chinese tokamak
%
type  = 'LH';
%
% ------- LH antenna #1 (3.70 GHz - PAM) -------
%
launchs{1}.id = 'antenna_3p70Ghz';
launchs{1}.type = type;
%
launchs{1}.omega_rf = 3.70*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{1}.rZ0 = [-0.12021    -0.04207     0.04207     0.12021];%vertical launching positions (m) [1,m_pol]
%
launchs{1}.phi0 = 0;%toroidal angle position [1,1]
launchs{1}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{1}.default.bNpar0 = [-2.7500 2.7500];% values of N//0 the antenna ref full LHCD discharge # 013606 (Brambilla theory)
launchs{1}.default.bdNpar0 = [0.1200 0.1200];% standard dN//0 values, related to antenna size (Brambilla theory)
launchs{1}.default.bPlhtot = 1e6*[0.0122 0.0248];% maximum coupled power (3.4658 MW for 4MW at the generators), standard directivity
launchs{1}.default.m0 = 0;% default initial poloidal mode number [1,1]
launchs{1}.default.i_ref = -1;% Initial radial position index [1,1]
launchs{1}.default.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- ids -------
%
nlaunchs = length(launchs);
ids = cell(1,nlaunchs);
for ilaunch = 1:nlaunchs,
    ids{ilaunch} = launchs{ilaunch}.id;
end

