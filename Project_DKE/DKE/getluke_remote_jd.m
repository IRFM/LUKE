function output = getluke_remote_jd(timeid,jobid,remote)
%
output = '';
%
remotehost = remote.host;
remoteset_jobid = remote.set_jobid;
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
load_id = ['LUKE_OUT_',remotelogname,'_',timeid,'.mat'];
%
if ~isempty(remotehost),
    %
    [res,txt] = unix(['ssh ',remotelogname,'@',remotehost,' ''qstat ',remoteset_jobid{1},jobid,remoteset_jobid{2},'''']);
    %
else
    %
    [res,txt] = unix(['qstat ',remoteset_jobid{1},jobid,remoteset_jobid{2}]);
    %
end
%
txt(double(txt) == 10) = [];
%
if res == 0,% job still running
    %
    return
    %
elseif isempty(strfind(txt,remoteset_jobid{3})),
    %
    error(['Remote run check failed : ',txt])
    %
else
    %
    % disp(['    --> Run is completed, waiting 30 seconds to ensure output file is completely saved ...'])  
    %
    % pause(30)% to make sure the file is completely saved by LUKE
    %
    if ~isempty(remotehost),
        %
        disp(['    --> Copying output file from remote host ',remotehost,' as user ',remotelogname,' ...'])  
        [res,err] = unix(['scp ',remotelogname,'@',remotehost,':',load_id,' ./']);
        %
        if res ~= 0,
            error(['File transfer failed : ',err])
        end
        disp(' ... done');
        %
        disp(['    --> Removing output file from remote host ',remotehost,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''rm -f ',load_id,'''']);
        %
        if res ~= 0,
            disp(['Warning, remote file delete failed : ',err])
        else
            disp(' ... done');          
        end
        %
        disp(['    --> Removing batch output files from remote host ',remotehost,' as user ',remotelogname,' ...'])
        [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''rm -f mrunluke_batch.e',jobid,' mrunluke_batch.o',jobid,'''']);
        %
        if res ~= 0,
            disp(['Warning, remote file delete failed : ',err])
        else
            disp(' ... done');          
        end
        %
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
    disp(['    --> Loading results from local file ',load_id,' ...'])
    output = load(load_id);	
    disp(' ... done'); 
    %
    disp(['    --> Deleting local file ',load_id,' ...'])
    delete(load_id);   
    disp(' ... done'); 
    %
    if isfield(output,'err'),
    	for istr = 1:length(output.err),
    		disp(output.err{istr});
    	end
        error('Remote LUKE run failed, aborted.')
    end
    %
end   

