close all
clear all
clc
%
shot_list = [9816,28353,32299,45525,54555];  
%
[date_list] = remote_mtsdate(shot_list);
%
for ii = 1:length(shot_list)
    %
    disp(['Date of discharge #',int2str(shot_list(ii)),' : ',date_list{ii}])
    % 
end
