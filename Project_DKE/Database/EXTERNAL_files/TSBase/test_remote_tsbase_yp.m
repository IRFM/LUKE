close all
clear all
clc
%
tsclean(45525);
[phyb,tlh] = remote_tsbase(45525,'gphyb');
%
plot(tlh,phyb);title(['Tore Supra, shot #45525']),xlabel('Time (s)');ylabel('Lower Hybrid power (MW)');
