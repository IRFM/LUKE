close all
clear all
clc
%
shotnumbers = [27503,27549,32299]; 
%
tsclean(shotnumbers);
%
[youts] = remote_mtsexist(shotnumbers,'GPROFTEFIT');
%
if ~isempty(youts)
    for ii = 1:length(shotnumbers)
        if youts{ii}.cr == 0 && all(youts{ii}.certif > 0)
            disp(['TPROF data available for discharge #',int2str(shotnumbers(ii))])
        else
            disp(['TPROF data unavailable or partially available for discharge #',int2str(shotnumbers(ii))])
        end
    end
else
    disp('Error : no output data from remote_mtsexist')
end