numshot = 2;
numrun_in = 551;
numrun_out = 502;%single ray: 502, beam: 503
timeslice = 0;
%
time_interp = 1;%nearest point
%
wordkir = pwd;
%
[flag,~,external] = matremote_jd(@load_externaldata_ITM,{workdir,numshot,numrun,timeslice,time_interp,opt_gui,select},remote