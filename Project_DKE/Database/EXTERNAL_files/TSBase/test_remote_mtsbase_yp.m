close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
[data] = remote_mtsbase(45525,{'gphyb','sipmes','svsur'},remote_enforce,remote_cluster);
%
phyb = data(1).yout1;
thyb = data(1).yout2;
%
sipmes = data(2).yout1;
tsipmes = data(2).yout2;
%
svsur = data(3).yout1;
tsvsur = data(3).yout2;
%
subplot(3,1,1),plot(thyb,phyb);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
subplot(3,1,2),plot(tsipmes,sipmes);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Plasma current (MA)');
subplot(3,1,3),plot(tsvsur,svsur);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Surface voltage (V)');axis([min(tsvsur),max(tsvsur),-1,1])
%