function [launchs,ids] = get_launchs_default
%
% This function contains the get_launchs_default characteristics of a LH antenna
%
type  = 'LH';
%
% ------- LH antenna -------
%
launchs{1}.id = 'default';
launchs{1}.type = type;
%
launchs{1}.omega_rf = 3.7*2*pi*1e9;% wave angular frequency (rad/s) [1,1]
launchs{1}.rZ0 = 0;% vertical launching positions (m) [1,m_pol]
%
launchs{1}.phi0 = 0;% toroidal angle position [1,1]
launchs{1}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{1}.default.bNpar0 = [2.0,-6.0];% values of N//0 the antenna ref full LHCD discharge # 013606 (Brambilla theory)
launchs{1}.default.bdNpar0 = [2.0,-6.0];% standard dN//0 values, related to antenna size (Brambilla theory)
launchs{1}.default.bPlhtot = 1e6*[0.7,0.3];% maximum coupled power (3.4658 MW for 4MW at the generators), standard directivity
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

