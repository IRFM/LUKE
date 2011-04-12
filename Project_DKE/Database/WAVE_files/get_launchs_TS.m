function launchs = get_launchs_TS
%
freq_GHz = 3.7;
%
launchs{1}.id = 'Coupleur_C1';
launchs{1}.type = 'LH';
%
launchs{1}.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{1}.directivity = 0.7;%Antenna directivity [1,1]
launchs{1}.dNpar0 = 0.2;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
launchs{1}.rZ0 = [-0.155,-0.075,0.075,0.155];%vertical launching positions (m) [1,m_pol]
% 
launchs{1}.m0 = 0;%initial poloidal mode number [1,1]
launchs{1}.phi0 = 0;%toroidal angle position [1,1]
launchs{1}.i_ref = -1;%Initial radial position index [1,1]
launchs{1}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
launchs{1}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
% ------- LH antenna #2 (C2) -------
%
freq_GHz = 3.7;
%
launchs{2}.id = 'Coupleur_C2';
launchs{2}.type = 'LH';
%
launchs{2}.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1]
launchs{2}.directivity = 0.7;%Antenna directivity [1,1]
launchs{2}.dNpar0 = 0.2;%ray spectral width for Fokker-Planck calculations [1,n_lobe]
%
launchs{2}.rZ0 = [-0.244,-0.162,-0.080,0.080,0.162,0.244];%vertical launching positions (m) [1,m_pol]
% 
launchs{2}.m0 = 0;%initial poloidal mode number [1,1]
launchs{2}.phi0 = 0;%toroidal angle position [1,1]
launchs{2}.i_ref = -1;%Initial radial position index [1,1]
launchs{2}.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
launchs{2}.mmode = -1;% (-1) for slow wave, (1) for fast wave
%
