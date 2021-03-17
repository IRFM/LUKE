close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
[shotdate] = remote_tsdate(45525,remote_enforce,remote_cluster);
%
disp(['Tore Supra discharge has been done at the date : ',shotdate]);
