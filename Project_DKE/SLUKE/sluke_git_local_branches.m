
function [active_branch,branches,username] = sluke_git_local_branches(sparams,ii)
%

[dkepath] = sluke_dkepath(sparams,ii);
%
[status, username] = unix('whoami');%local username
username = deblank(username);
%
[status, cmdout] = system(['timeout 10 ssh ',username,'@localhost "cd ',dkepath.luke_root,';git branch"']);
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