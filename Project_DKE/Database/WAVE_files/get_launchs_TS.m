function launchs = get_launchs_TS
%
% This function contains the characteristics of the LH antennas of the Tore
% Supra tokamak
%
freq_GHz = 3.7;
type  = 'LH';
%
% ------- LH antenna #1 (C2) -------
%
launchs{1}.id = 'C2';
launchs{1}.type = type;
%
launchs{1}.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
%
launchs{1}.phi0 = 0;%toroidal angle position [1,1]
launchs{1}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{1}.default.bNpar0 = [2.0,-6.0];% values of N//0 the antenna is optimized for
launchs{1}.default.bdNpar0 = [0.2,0.2];% standard dN//0 values (related to antenna size)
launchs{1}.default.bPlhtot = 3e6*[0.7,0.3];% maximum coupled power and standard directivity
launchs{1}.default.m0 = 0;% default initial poloidal mode number [1,1]
launchs{1}.default.i_ref = -1;% Initial radial position index [1,1]
launchs{1}.default.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #2 (C3 - FAM) -------
%
launchs{2}.id = 'C3';
launchs{2}.type = type;
%
launchs{2}.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
% 
launchs{2}.phi0 = 0;%toroidal angle position [1,1]
launchs{2}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{2}.default.bNpar0 = [2.0,-6.0];% values of N//0 the antenna is optimized for
launchs{2}.default.bdNpar0 = [0.2,0.2];% standard dN//0 values (related to antenna size)
launchs{2}.default.bPlhtot = 3.7e6*[0.7,0.3];% maximum coupled power and standard directivity
launchs{2}.default.m0 = 0;% default initial poloidal mode number [1,1]
launchs{2}.default.i_ref = -1;% Initial radial position index [1,1]
launchs{2}.default.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #3 (C4 - PAM) -------
%
launchs{3}.id = 'C4';
launchs{3}.type = type;
%
launchs{3}.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{3}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
% 
launchs{3}.phi0 = 0;%toroidal angle position [1,1]
launchs{3}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launchs{3}.default.bNpar0 = [1.7,-2.9];% values of N//0 the antenna is optimized for
launchs{3}.default.bdNpar0 = [0.2,0.2];% standard dN//0 values (related to antenna size)
launchs{3}.default.bPlhtot = 3.7e6*[0.7,0.3];% maximum coupled power and standard directivity
launchs{3}.default.m0 = 0;% default initial poloidal mode number [1,1]
launchs{3}.default.i_ref = -1;% Initial radial position index [1,1]
launchs{3}.default.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
