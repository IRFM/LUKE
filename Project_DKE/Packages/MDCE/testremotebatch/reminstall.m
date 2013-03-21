function [remotehome] = reminstall(remote)
%
% This function transfers and copies functions for testremotebatch
%
disp('-------------------------------------------------------')
disp('---- setting folders and files for testremotebatch ----')
disp('-------------------------------------------------------')
%
remotehost = remote.host;%  hostname (empty for local host)
%
% get local user name
%
[res,logname] = unix('whoami');
%
if res ~= 0,
    error('Local login name could not be obtained')
end
%
% get remote user name
%
logname(double(logname) == 10) = [];% remove return character
%
if isfield(remote,'users') && isfield(remote.users,logname) && ~isempty(remote.users.(logname)),
    remotelogname = remote.users.(logname);
else
    remotelogname = logname;
end
%
remotecmd = 'echo $HOME';
%
if ~isempty(remotehost),%remote calculation 
    %
    [res,remotehome] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
    %
else
    %
    [res,remotehome] = unix(remotecmd);
    %
end
%
if res ~= 0,
    error(['File transfer failed : ',err])
end
disp(' ... done');
remotehome(double(remotehome) == 10) = [];% remove return character
%
% check if directories exist - create them if needed
%
remotedirtest_jd(remotehost,remotelogname,[remotehome,filesep,'remotebatchtest/'])
remotedirtest_jd(remotehost,remotelogname,[remotehome,filesep,'remotebatchtest/bin/'])
remotedirtest_jd(remotehost,remotelogname,[remotehome,filesep,'remotebatchtest/mat/'])
%
% copy test files into directory
%
remotefilecopy_jd(remotehost,remotelogname,which('matlabbatch.sh'),[remotehome,filesep,'remotebatchtest/bin/'])
remotefilecopy_jd(remotehost,remotelogname,'remotetest.m',[remotehome,filesep,'remotebatchtest/mat/'])
remotefilecopy_jd(remotehost,remotelogname,which('remotematrun.m'),[remotehome,filesep,'remotebatchtest/mat/'])
%
disp('-------------------------------------------------------')
disp('-------------------- setting done ---------------------')
disp('-------------------------------------------------------')
%
end
%
function remotedirtest_jd(remotehost,remotelogname,location)
    %
    % test if folder exists
    %
    disp(['testing if the remote folder ',location,'exists'])
    remotecmd = ['test -d ',location];% test if remote directory exists
    %
    if ~isempty(remotehost),
        res = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
    else
        res = unix(remotecmd);
    end
    %
    % create folder if needed
    %
    if res == 1,% remote directory does not exist
        remotecmd = ['mkdir ',location];%create remote directory
        disp(['    --> Creating remote data folder ',location])  
        if ~isempty(remotehost),
            [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        else
            [res,err] = unix(remotecmd);
        end
        if res ~= 0,
            error(['Remote data folder creation failed : ',err])
        end
        disp(' ... done');
    end   
end
%
function remotefilecopy_jd(remotehost,remotelogname,filename,location)
%     %
%     % test if file exists. 
%     %
%     disp(['testing if the remote file ',location,filename,'exists'])
%     remotecmd = ['test -f ',location,filename];% test if remote directory exists
%     %
%     if ~isempty(remotehost),
%         res = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
%     else
%         res = unix(remotecmd);
%     end
%     %
%     % delete remote files if they exist
%     %
%     if res == 0,% remote file does exist
%         remotecmd = ['rm ',location,filename];%create remote directory
%         disp(['    --> Deleting remote file ',location,filename])  
%         if ~isempty(remotehost),
%             [res,err] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
%         else
%             [res,err] = unix(remotecmd);
%         end
%         if res ~= 0,
%             error(['Remote file deletion failed : ',err])
%         end
%         disp(' ... done');
%     end   
    %
    % copy file into destimation
    %
    remotecmd = ['chmod a+x ',location,filename];
    %
    if ~isempty(remotehost),%remote calculation 
        %
        disp(['    --> Copying script file ',filename,' to remote host ',remotehost,':',location,' as user ',remotelogname,' ...'])  
        [res,err] = unix(['scp ',filename,' ',remotelogname,'@',remotehost,':',location]);
        [res2,txt2] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        %
    else
        %
        disp(['    --> Copying script file ',filename,' to ',location])  ;
        [res,err] = unix(['cp ',filename,' ',location]);
        [res2,txt2] = unix(remotecmd);
        %
    end
    %
    if res ~= 0,
        error(['File transfer failed : ',err])
    end
    disp(' ... done');
end
    
    

