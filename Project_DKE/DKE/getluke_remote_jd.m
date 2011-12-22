function output = getluke_remote_jd(timeid,jobid,remote,debugmode)
%
if nargin < 4
    debugmode = 0;
end
%
output = '';
%
remoteset_jobid = remote.set_jobid;
remotecmd = remote.cmd;
xgridsearch = strfind(remotecmd,'xgrid');
%
[~,localhost] = unix('hostname');
localhost = localhost(1:end-1);
remotehost = remote.host;
remoteluke_root = remote.luke_root;
remotefields = fieldnames(remote);
remotepassword = remote.password{1};
%
if ~isempty(xgridsearch),
    user_root = ['/Users/',remote.(remotefields{end}),'/'];
    local_user_root = getenv('HOME');
    %
    if exist([local_user_root,'/Volume_',remotehost{1}]);%the remote disk must be unmounted first
        unix(['umount ',local_user_root,'/Volume_',remotehost{1}]);
        pause(0.1)
    end
    %
end
%
logname = getenv('USER');
%
if isfield(remote,logname) && ~isempty(remote.(logname)),
    remotelogname = remote.(logname);
else
    remotelogname = logname;
end
%
load_id = ['LUKE_OUT_',remotelogname,'_',timeid,'.mat'];
%
if ~isempty(remotehost),
    %
    if ~isempty(xgridsearch),
        [res,txt] = unix(['ssh ',remotelogname,'@',remotehost{2},' '' ',remoteset_jobid{1},remotehost{1},remotecmd{2},remotepassword,remoteset_jobid{2},jobid,'''']);
    else
        [res,txt] = unix(['ssh ',remotelogname,'@',remotehost{1},' '' ',remoteset_jobid{1},jobid,remoteset_jobid{2},'''']);
    end
    pause(0.1)
    %
else
    %
    [res,txt] = unix([remoteset_jobid{1},jobid,remoteset_jobid{2}]);
    %
end
%
txt(double(txt) == 10) = [];
%
if ~isempty(xgridsearch),
    if ~isempty(strfind(txt,remoteset_jobid{3})), % job still running
        return
    elseif ~isempty(strfind(txt,remoteset_jobid{4})), % job pending
        return
    else
        if isempty(strfind(txt,remoteset_jobid{5})), % job has a problem   
            disp(['Remote run check failed : ',txt]);
            return
        end
    end
    
else
    if res == 0,% job still running
        %
        return
        %
    elseif isempty(strfind(txt,remoteset_jobid{3})),
        %
        disp(['Remote run check failed : ',txt]);
        return
    end
    %
end
%
% disp(['    --> Run is completed, waiting 30 seconds to ensure output file is completely saved ...'])  
%
% pause(30)% to make sure the file is completely saved by LUKE
%
if ~isempty(remotehost),
    if ~isempty(xgridsearch),
        %
        disp(['    --> Local transfer of output files from remote host ',remotehost{2},' as user ',remotelogname,' ...'])  
        [res_mkdir,err_mkdir] = unix(['ssh ',remotelogname,'@',remotehost{2},' '' mkdir ',user_root,'xgrid_job_',jobid,'''']);
        pause(0.1)
        if ~res_mkdir,
            if debugmode
                [res_local,err_local] = unix(['ssh ',remotelogname,'@',remotehost{2},' '' ',remoteset_jobid{1},remotehost{1},remoteset_jobid{6},jobid,remoteset_jobid{7},user_root,'xgrid_job_',jobid,'/error_file_',timeid,'.txt',remoteset_jobid{8},user_root,'xgrid_job_',jobid,'/output_file_',timeid,'.txt',remoteset_jobid{9},user_root,'xgrid_job_',jobid,'''']);
                pause(0.1)
            else
                [res_local,err_local] = unix(['ssh ',remotelogname,'@',remotehost{2},' '' ',remoteset_jobid{1},remotehost{1},remoteset_jobid{6},jobid,remoteset_jobid{9},user_root,'xgrid_job_',jobid,'''']);
                pause(0.1)
            end
            %
            if ~res_local,
                disp([' ... done in ',user_root,'xgrid_job_',jobid]);
                %
                if strcmp(remotehost{1},remotehost{2}),%local distributed computing
                    [res_copy,err_copy] = unix(['scp ',getenv('USER'),'@',localhost,':',local_user_root,'/','xgrid_job_',jobid,'/',load_id,' ./']);
                    pause(0.1)
                else%transfer via scp
                    [res_copy,err_copy] = unix(['scp ',remotelogname,'@',remotehost{2},':','xgrid_job_',jobid,'/',load_id,' ./']);
                    pause(0.1)
                end
                %
                if res_copy,
                    disp(['File transfer failed : ',err_copy]);
                    return
                end                    
            else
                disp(['Local transfer of output files from remote host failed: ',err_local]);
                return
            end
            %
        else
            disp(['Output folder creation failed : ',err_mkdir]);
            return
        end   
    else
        %
        disp(['    --> Copying output file from remote host ',remotehost{1},' as user ',remotelogname,' ...'])  
        [res,err] = unix(['scp ',remotelogname,'@',remotehost{1},':',load_id,' ./']);
        %
        if res ~= 0,
            disp(['File transfer failed : ',err]);
            return
        end
        disp(' ... done');
        %
        disp(['    --> Removing output file from remote host ',remotehost{1},' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost{1},' ''rm -f ',load_id,'''']);
        %
        if res ~= 0,
            disp(['Warning, remote file delete failed : ',err])
        else
            disp(' ... done');          
        end
        %
        disp(['    --> Removing batch output files from remote host ',remotehost{1},' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost{1},' ''rm -f mrunluke_batch.e',jobid,' mrunluke_batch.o',jobid,'''']);
        %
        if res ~= 0,
            disp(['Warning, remote file delete failed : ',err])
        else
            disp(' ... done');          
        end
        %
    end
else
    %
    disp('    --> Removing batch output files ...')
    %
    efile = ['mrunluke_batch.e',jobid];
    ofile = ['mrunluke_batch.o',jobid];
    %
    if exist(efile,'file'),
        %
        delete(efile),
        delete(ofile),
        disp(' ... done');          
        %
    elseif exist([getenv('HOME'),'/',efile],'file'),
        %
        delete([getenv('HOME'),'/',efile]),
        delete([getenv('HOME'),'/',ofile]),
        disp(' ... done');          
        %
    else
        disp('Warning, remote file delete failed : batch output files not found')
    end
    %
end
%
if ~exist(load_id,'file'),
    output.err = {['Could not find output file ',load_id,'. Aborted']};
else
    disp(['    --> Loading results from local file ',load_id,' ...'])
    output = load(load_id);	
    disp(' ... done'); 
    %
    disp(['    --> Deleting local file ',load_id,' ...'])
    delete(load_id);
    disp(' ... done'); 
    %
    if ~isempty(xgridsearch),
        save_id = ['LUKE_RUN_',remotelogname,'_',timeid,'.mat'];
        disp(['    --> Deleting remote file ',save_id,' ...']);
        %
        [res_clean_run,err_clean_run] = unix(['ssh ',remotelogname,'@',remotehost{2},' ''rm ',user_root,save_id,'''']);
        pause(0.1)
        %
        if res_clean_run,
            disp(err_clean_run);
        else
            disp(' ... done'); 
        end
        %
        disp(['    --> Deleting remote folder ',user_root,'xgrid_job_',jobid,' ...']);
        %
        [res_clean_out,err_clean_out] = unix(['ssh ',remotelogname,'@',remotehost{2},' ''rm -rf ',user_root,'xgrid_job_',jobid,'''']);
        pause(0.1)
        %
        if res_clean_out,
            disp(err_clean_out);
        else
            disp(' ... done'); 
        end
        %
        disp(['    --> Deleting xgrid job id #',jobid,' ...']);
        %
        [res_clean_job,err_clean_job] = unix(['ssh ',remotelogname,'@',remotehost{2},' '' ',remoteset_jobid{1},remotehost{1},remoteset_jobid{10},jobid,'''']);        
        %
        if res_clean_job,
            disp(err_clean_job);
        else
            disp(' ... done'); 
        end
        %  
    end
end
%
if isfield(output,'err'),
    for istr = 1:length(output.err),
        disp(output.err{istr});
    end
end
%