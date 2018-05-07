close all
clear all
clc
%
[shotdate,phyb,tlh] = remote_tsbase(45525,'gphyb');
%
plot(tlh,phyb);title(['Tore Supra, #45525, shot date: ',shotdate]),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
