close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
[phyb,tlh] = remote_tsbase(45525,'gphyb',remote_enforce,remote_cluster);
%
plot(tlh,phyb);title(['Tore Supra, shot #45525]),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
