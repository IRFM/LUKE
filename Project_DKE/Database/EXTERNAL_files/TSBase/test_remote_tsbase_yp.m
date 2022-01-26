close all
clear all
clc
%
[phyb,tlh] = remote_tsbase(45525,'gphyb');
%
plot(tlh,phyb);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
