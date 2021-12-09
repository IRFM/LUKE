close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
%
shot_list = [9816,28353,32299,45525,54555];
%
[date_list] = remote_mtsdate(shot_list,remote_enforce);
%
for ii = 1:length(shot_list)
    %
    disp(['Date of discharge #',int2str(shot_list(ii)),' : ',date_list{ii}])
    % 
end
