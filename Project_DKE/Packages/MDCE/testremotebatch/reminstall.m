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
    error(['File transfer failed : ',remotehome])
end
disp(' ... done');
remotehome(double(remotehome) == 10) = [];% remove return character
%
% check if directories exist - create them if needed
%
remotedirtest_jd(remotehost,remotelogname,[remotehome,filesep,'remotebatchtest/'])
pause(2);
remotedirtest_jd(remotehost,remotelogname,[remotehome,filesep,'remotebatchtest/bin/'])
pause(2);
remotedirtest_jd(remotehost,remotelogname,[remotehome,filesep,'remotebatchtest/mat/'])
pause(2);
%
% copy test files into directory
%

filename = which('matlabbatch.sh');
ifilesep = strfind(filename,filesep);
local_path = filename(1:ifilesep(end));
filename = filename(ifilesep(end)+1:end);
remotefilecopy_jd(remotehost,remotelogname,local_path,filename,[remotehome,filesep,'remotebatchtest/bin/'])
%
filename = 'remotetest.m';
local_path = [pwd,'/'];
remotefilecopy_jd(remotehost,remotelogname,local_path,filename,[remotehome,filesep,'remotebatchtest/mat/'])
%
filename = which('remotematrun.m');
ifilesep = strfind(filename,filesep);
local_path = filename(1:ifilesep(end));
filename = filename(ifilesep(end)+1:end);
remotefilecopy_jd(remotehost,remotelogname,local_path,filename,[remotehome,filesep,'remotebatchtest/mat/'])
%
filename = which('runmat.m');
ifilesep = strfind(filename,filesep);
local_path = filename(1:ifilesep(end));
filename = filename(ifilesep(end)+1:end);
remotefilecopy_jd(remotehost,remotelogname,local_path,filename,[remotehome,filesep,'remotebatchtest/mat/'])
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
function remotefilecopy_jd(remotehost,remotelogname,local_path,filename,remote_path)
%     %
%     % test if file exists. 
%     %
%     disp(['testing if the remote file ',location,filename,'exists'])
%     remotecmd = ['test -f ',remote_path,filename];% test if remote directory exists
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
%         remotecmd = ['rm ',remote_path,filename];%create remote directory
%         disp(['    --> Deleting remote file ',remote_path,filename])  
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
    %
    remotecmd = ['chmod a+x ',remote_path,filename];
    %
    if ~isempty(remotehost),%remote calculation 
        %
        disp(['    --> Copying script file ',local_path,filename,' to remote host ',remotehost,':',remote_path,' as user ',remotelogname,' ...'])  
        [res,err] = scp2remote_yp(remotelogname,remotehost,filename,local_path,remote_path);
        [res2,txt2] = unix(['ssh ',remotelogname,'@',remotehost,' ''',remotecmd,'''']);
        %
    else
        %
        disp(['    --> Copying script file ',local_path,filename,' to ',remote_path])  ;
        [res,err] = unix(['cp ',local_path,filename,' ',remote_path]);
        [res2,txt2] = unix(remotecmd);
        %
    end
    %
    if res ~= 0,
        error(['File transfer failed : ',err])
    end
    disp(' ... done');
end
    
    

