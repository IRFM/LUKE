close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1)
remote_cluster = 'SIRRAH';%'ANDROMEDE'
[shotdate,phyb,tlh] = remote_tsbase(45525,'gphyb',remote_enforce,remote_cluster);
%
plot(tlh,phyb);title(['Tore Supra, #45525, shot date: ',shotdate]),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
