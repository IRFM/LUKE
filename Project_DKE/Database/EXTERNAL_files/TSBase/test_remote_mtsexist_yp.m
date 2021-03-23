close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
shotnumbers = [27503;27549;32299];
%
[youts] = remote_mtsexist(shotnumbers,'GPROFTEFIT',remote_enforce,remote_cluster);
%
for ii = 1:length(shotnumbers)
    if youts{ii}.cr == 0
        disp(['TPROF data availabel for discharge #',int2str(shotnumbers(ii))])
    else
        disp(['TPROF data unavailabel for discharge #',int2str(shotnumbers(ii))])
    end
end