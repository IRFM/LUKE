close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
[shotnum] = remote_tsdernier_choc(remote_enforce,remote_cluster);
%
disp(['Last shot number in database (TORE SUPRA or WEST) : ',int2str(shotnum)]);
