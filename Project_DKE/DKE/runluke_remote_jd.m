function [timeid,jobid] = runluke_remote_jd(luke_input,remote)
%
id_simul = luke_input.id_simul;
dkeparam = luke_input.dkeparam;
dkedisplay = luke_input.dkedisplay;
equil = luke_input.equil;
wavestructs = luke_input.wavestructs;
waves = luke_input.waves;
ohm = luke_input.ohm;
transpfaste = luke_input.transpfaste;
ripple = luke_input.ripple;
%
if isfield(luke_input,'Zf0_interp')
    Zf0_interp = luke_input.Zf0_interp;
else
    Zf0_interp = '';
end
if isfield(luke_input,'XXsinksource')
    XXsinksource = luke_input.XXsinksource;
else
    XXsinksource = '';
end
%
if isfield(luke_input,'opt_save')
    opt_save = luke_input.opt_save;
else
    opt_save = 0;
end
%
if isfield(luke_input,'dkepath'),
    dkepath = luke_input.dkepath;
else
    dkepath  ='';
end
%
timeid = timeid_jd(clock);
%
remotecmd = remote.cmd;
xgridsearch = strfind(remotecmd,'xgrid');
%
remotehost = remote.host;
remoteluke_root = remote.luke_root;
remotefields = fieldnames(remote);
remotepassword = remote.password;
%
if ~isempty(xgridsearch),
    user_root = ['/Users/',remote.(remotefields{end}),'/xgrid/'];
end
%
remotemem = '';
if isfield(remote,'mem'),% memory allocation if applicable
    if ~isempty(remote.mem)
        if isempty(transpfaste),% no transport
            remotemem = [remote.mem{1},remote.mem{3},remote.mem{2}];
        else% with transport
            remotemem = [remote.mem{1},remote.mem{4},remote.mem{2}];
        end
    end
end
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
[err,remote_localhost] = unix(['ssh ',remotelogname,'@',remotehost{1},' ''hostname''']);
remote_localhost = remote_localhost(1:end-1);
%
save_id = ['LUKE_RUN_',remotelogname,'_',timeid,'.mat'];
save(save_id,'id_simul','wavestructs','waves','dkeparam','dkepath','equil','dkedisplay','ohm','transpfaste','ripple','Zf0_interp','XXsinksource','opt_save');
%
if ~isempty(remotehost),
    %
    if ~isempty(xgridsearch),
        disp(['    --> Copying run and batch files to remote host ',remotehost{1},' as user ',remotelogname,' ...'])
        %
        [res,err] = unix(['scp ',save_id,' ',remotelogname,'@',remotehost{1},':xgrid']);
    else
        disp(['    --> Copying run file to remote host ',remotehost{1},' as user ',remotelogname,' ...'])
    %
    [res,err] = unix(['scp ',save_id,' ',remotelogname,'@',remotehost{1},':']);
    end
    %
    delete(save_id);
    %
    if res ~= 0,
        error(['File transfer failed : ',err])
    end
    %
    if ~isempty(xgridsearch),
        batch_id = xgrid_batch2xml_yp(timeid,remote.luke_root,id_simul,remote.(remotefields{end}),remote.matlabroot,remote.prefdir,remote.luke_root,'mrunluke_batch_xgrid.sh',user_root,remote_localhost);
        %
        [res_batch,err_batch] = unix(['scp ',batch_id,' ',remotelogname,'@',remotehost{1},':xgrid']);
        %
        delete(batch_id);
        %
        if res_batch ~= 0,
            error(['Batch file transfer failed : ',err_batch])
        end    
    end
    %
    disp(' ... done');
    %
end
%
if ~isempty(xgridsearch),
    disp(['    --> Starting run with command ',remotecmd{1},remote_localhost,remotecmd{2},'******',remotecmd{3},user_root,remotecmd{4},' ...'])
else
    disp(['    --> Starting run with command ',remotecmd,' ...'])
end
%
if ~isempty(remotehost),
    %
    if ~isempty(xgridsearch),
        [res,txt] = unix(['ssh ',remotelogname,'@',remotehost{1},' ''',remotecmd{1},remote_localhost,remotecmd{2},remotepassword{1},remotecmd{3},user_root,remotecmd{4},timeid,'.plist''']);%execute xgrid job
        %
        [res_clean_batch,err_clean_batch] = unix(['ssh ',remotelogname,'@',remotehost{1},' ''rm ',user_root,remotecmd{4},timeid,'.plist''']);%remove plist file             
        %
        if res_clean_batch,disp(err_clean_batch);end
    else
        [res,txt] = unix(['ssh ',remotelogname,'@',remotehost{1},...
        ' ''',remotecmd,remotemem,' -v LUKE_timeid=',timeid,',LUKE_path=',remoteluke_root,' ',remoteluke_root,'mrunluke_batch''']);
    end
    %
else
    %
    [res,txt] = unix([remotecmd,remotemem,' -v LUKE_matlabroot=',matlabroot,'/bin/,LUKE_timeid=',timeid,',LUKE_path=',remoteluke_root,',LUKE_datapath=',pwd,'/ ',remoteluke_root,'mrunluke_batch']);
    %
end
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
