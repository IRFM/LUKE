close all
clear all
clc
%
remote_enforce = 0;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
%
shotnumber = 32299;%27503,27549,32299 
%
[cr,nb_mesures,num_version,certif,date,heure] = remote_tsexist(shotnumber,'GPROFTEFIT',remote_enforce);
%
if cr == 0
    disp(['TPROF data available for discharge #',int2str(shotnumber)])
else
    disp(['TPROF data unavailable for discharge #',int2str(shotnumber)])
end