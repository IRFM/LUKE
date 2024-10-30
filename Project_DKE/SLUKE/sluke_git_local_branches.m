function [active_branch,branches,username] = sluke_git_local_branches(sparams,ii)
%

[dkepath] = sluke_dkepath(sparams,ii);
%
[status, username] = unix('whoami');%local username
username = deblank(username);
%
warning_ssh = ['ERROR : The ssh connection to the local machine is not fully set or is broken. Before running this simulation, please type in a bash shell the following command: ' ...
 '''ssh YOURUSERNAME@THEMACHINEADDRESS'' and allow it to be trusted in the ssh server list by typing ''Yes''. '...
 'This operation should be done only once on all remote computers where LUKE is supposed to be running and the local machine itself (self ssh connection). '...
 'For the local machine ''THEMACHINEADDRESS'' is ''localhost'', and ''YOURUSERNAME'' may be obtained by typing the command ''whoami''.'];
%
[status, cmdout] = system(['timeout 10 ssh ',username,'@localhost "cd ',dkepath.luke_root,';git branch" || echo "',warning_ssh,'"']);
%
if strcmp(warning_ssh,deblank(cmdout))
    %
    error(warning_ssh);
    %
end
%
branches = strsplit(deblank(cmdout),'\n');
%
for ib = 1:length(branches)
    %
    branches{ib} = strtrim(branches{ib});
    %
    if strfind(branches{ib},'*')
        %
        active_branch = branches{ib}(3:end);
        branches{ib} = active_branch;
        %
    end
    %
end