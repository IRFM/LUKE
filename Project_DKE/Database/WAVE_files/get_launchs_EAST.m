function launchs = get_launchs_EAST
%
% This function contains the characteristics of the LH antennas of the EAST Chinese tokamak
%
type  = 'LH';
%
% ------- LH antenna #1 (2.45 GHz - FAM) -------
%
launchs{1}.id = '2p45';
launchs{1}.type = type;
%
launchs{1}.omega_rf = 2.45*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{1}.rZ0 = [-0.2920,-0.1460,0,0.1460,0.2920];%vertical launching positions (m) [1,m_pol]
%
launchs{1}.phi0 = 0;%toroidal angle position [1,1]
launchs{1}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{1}.default.bNpar0 = [-7.2000,-6.3000,2.1000,2.5000,3.1000];% values of N//0 the antenna ref full LHCD discharge # 013606 (Brambilla theory)
launchs{1}.default.bdNpar0 = [0.2200,0.2100,0.2300,0.1400,0.2100];% standard dN//0 values, related to antenna size (Brambilla theory)
launchs{1}.default.bPlhtot = 0.8665*1e6*[0.3900,0.2124,2.8344,0.1130,0.4500];% maximum coupled power (3.4658 MW for 4MW at the generators), standard directivity
launchs{1}.default.m0 = 0;% default initial poloidal mode number [1,1]
launchs{1}.default.i_ref = -1;% Initial radial position index [1,1]
launchs{1}.default.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #2 (4.60 GHz - FAM) -------
%
launchs{2}.id = '4p60';
launchs{2}.type = type;
%
launchs{2}.omega_rf = 4.60*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{2}.rZ0 = [-0.2910,-0.0970,0.291,0.0970];%vertical launching positions (m) [1,m_pol]
% 
launchs{2}.phi0 = 0;%toroidal angle position [1,1]
launchs{2}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{2}.default.bNpar0 = [-7.2000,-6.3000,2.1000,2.5000,3.1000];% values of N//0 the antenna ref full LHCD discharge # 013606 (Brambilla theory)
launchs{2}.default.bdNpar0 = [0.2200,0.2100,0.2300,0.1400,0.2100];% standard dN//0 values, related to antenna size (Brambilla theory)
launchs{2}.default.bPlhtot = 0.8667*1e6*[0.5862,0.3185,4.2508,0.1708,0.6738];% maximum coupled power (5.2003 MW for 6MW at the generators), standard directivity
launchs{2}.default.m0 = 0;% default initial poloidal mode number [1,1]
launchs{2}.default.i_ref = -1;% Initial radial position index [1,1]
launchs{2}.default.mmode = -1;% (-1) for slow wave, (1) for fast wave

