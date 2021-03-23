close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
shotnumber = 27549;%27503;%32299;
%
[cr,nb_mesures,num_version,certif,date,heure] = remote_tsexist(shotnumber,'GPROFTEFIT',remote_enforce,remote_cluster);
%
if cr == 0
    disp(['TPROF data availabel for discharge #',int2str(shotnumber)])
else
    disp(['TPROF data unavailabel for discharge #',int2str(shotnumber)])
end