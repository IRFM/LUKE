close all
clear all
clc
%
remote_enforce = 1;%Let the program decide (0) or not (1). If (1), use the remote profile remote_CEA_ALTAIR.m or remote_CEA_ANDROMEDE.m 
remote_cluster = 'ALTAIR';%'SIRRAH','ANDROMEDE;
%
shotnumber = 32299;
gas = 2;%Helium (1: hydrogen)
%
[data] = remote_autoTSmetis(shotnumber,gas);
%[post,tprofok] = remote_autoTSmetis(32299,2,'','','',remote_enforce,remote_cluster);
%
if ~isempty(data)
    disp(['Successful run of autoTSmetis for discharge #',int2str(shotnumber),'.'])
else
    disp(['WARNING : run of autoTSmetis for discharge #',int2str(shotnumber),' failed.'])
end
%
