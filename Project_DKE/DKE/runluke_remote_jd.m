function [timeid,jobid] = runluke_remote_jd(luke_input,remote)
%
id_simul = luke_input.id_simul;
dkeparam = luke_input.dkeparam;
dkedisplay = luke_input.dkedisplay;
equil = luke_input.equil;
waves = luke_input.waves;
ohm = luke_input.ohm;
transpfaste = luke_input.transpfaste;
ripple = luke_input.ripple;
%
timeid = timeid_jd(clock);
%
remotehost = remote.host;
remoteluke_root = remote.luke_root;
remotecmd = remote.cmd;
remoteget_jobid = remote.get_jobid;
%
[res,logname] = unix('whoami');
%
if res ~= 0,
    error('Local login name could not be obtained')
end
%
logname(double(logname) == 10) = [];
%
if isfield(remote,logname),
    remotelogname = remote.(logname);
else
    remotelogname = logname;
end
%
save_id = ['LUKE_RUN_',remotelogname,'_',timeid,'.mat'];
save(save_id,'id_simul','waves','dkeparam','equil','dkedisplay','ohm','transpfaste','ripple');
%
disp(['    --> Copying run file to remote host ',remotehost,' as user ',remotelogname,' ...'])  
[res,err] = unix(['scp ',save_id,' ',remotelogname,'@',remotehost,':']);
%
delete(save_id);
%
if res ~= 0,
    error(['File transfer failed : ',err])
end
disp(' ... done');
%
disp(['    --> Starting run with command ',remotecmd,' ...']) 
%
[res,txt] = unix(['ssh ',remotelogname,'@',remotehost,...
    ' ''',remotecmd,' -v timeid=',timeid,',LUKE=',remoteluke_root,' ',remoteluke_root,'mrunluke_batch''']);
%
if res ~= 0,
    error(['Remote run start failed : ',err])
end
%
txt(double(txt) == 10) = [];
%
if ~isempty(remoteget_jobid{1}),
    strl1 = length(remoteget_jobid{1});
    istr0 = strl1 + min(strfind(txt,remoteget_jobid{1}));
    if isempty(istr0),
        error('Job ID could not be retrieved')
    end
else
    istr0 = 1;
end
%
if ~isempty(remoteget_jobid{2}),
    istr1 = min(strfind(txt(istr0:end),remoteget_jobid{2})) + istr0 - 2;
    if isempty(istr1),
        error('Job ID could not be retrieved')
    end
else
    istr1 = length(txt);
end
%
jobid = txt(istr0:istr1);
%
disp([' ... started with Job id ',jobid]);
