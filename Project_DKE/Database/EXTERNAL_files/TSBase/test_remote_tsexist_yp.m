close all
clear all
clc
%
shotnumber = 32299;%27503,27549,32299 
%
tsclean(shotnumber);
%
[cr,nb_mesures,num_version,certif,date,heure] = remote_tsexist(shotnumber,'GPROFTEFIT');
%
if cr == 0 && all(certif > 0)
    %
    disp(['TPROF data available for discharge #',int2str(shotnumber)])
    %
else
    %
    disp(['TPROF data unavailable or partially available for discharge #',int2str(shotnumber)])
    %
end