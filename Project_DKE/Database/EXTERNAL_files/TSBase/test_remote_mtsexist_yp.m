close all
clear all
clc
%
remote_enforce = 0;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
%
shotnumbers = [27503,27549,32299];
%
[youts] = remote_mtsexist(shotnumbers,'GPROFTEFIT',remote_enforce);
%
if ~isempty(youts)
    for ii = 1:length(shotnumbers)
        if youts{ii}.cr == 0
            disp(['TPROF data available for discharge #',int2str(shotnumbers(ii))])
        else
            disp(['TPROF data unavailable for discharge #',int2str(shotnumbers(ii))])
        end
    end
else
    disp('Error : no output data from remote_mtsexist')
end