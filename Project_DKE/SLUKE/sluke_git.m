function sluke_git(sparams,ii)
%
[dkepath] = sluke_dkepath(sparams,ii);
%
[active_local_branch,local_branches,username] = sluke_git_local_branches(sparams,ii);%get local git branches and the active one
%
[remote_profile_num,remote_profile_char] = sluke_remote_profile(sparams,ii,0,1);
%
[status, hostname] = unix('hostname');%local hostname
hostname = deblank(hostname);
hostname1 = strsplit(hostname,'.');
hostname = hostname1{1};%first term for local connection 
%
warning_ssh = ['ERROR : The ssh connection to the local machine whose hostname is ''',hostname,''' is not fully set or is broken. ' ...
 'Before running this simulation, please type in a bash shell the following command: ' ...
 '''ssh YOURUSERNAME@',hostname,''' and allow it to be trusted in the ssh server list by typing ''Yes''. '...
 'This operation should be done only once on all remote computers where LUKE is supposed to be running and the local machine itself (self ssh connection). '...
 'The ''YOURUSERNAME'' may be obtained by typing the command ''whoami''.'];
%
if isfield(sparams,'simul') && isfield(sparams.simul,'git') && isfield(sparams.simul.git,'branch')  && isfield(sparams.simul.git.branch,'luke') && ~isempty(sparams.simul.git.branch.luke{ii})
    %
    lukegitbranch = sparams.simul.git.branch.luke{ii};
    %
else
    %
    if isfield(dkepath,'luke_gitbranch')
        %
        lukegitbranch = dkepath.luke_gitbranch;
        %
    else
        %
        lukegitbranch = '';
        %
    end
end
%
if remote_profile_num > 0
    %
    remote = dkepath.remote(remote_profile_num);
    %
    jj = strfind(remote.env.luke_root,'/');
    remotelukeproject = remote.env.luke_root(jj(end-1)+1:jj(end)-1);
    remotelukerootproject = remote.env.luke_root(1:jj(end-1));
    %
    remote.gitbranch = lukegitbranch;
    %
else
    %
    locallukeproject = dkepath.luke_project;
    locallukerootproject = strrep(dkepath.luke_root,[locallukeproject,'/'],'');
    %
end
%
% enforce git branch if specified in sluke simulation parameters on the local computer (will be enforced on the remote using the remote structure)
%
if isempty(lukegitbranch)
    %
    cprintf('*[1,0.5,0]',['---> WARNING : No local git branch specified in sparams for ''',dkepath.luke_project,'''. The default active local branch ''',active_local_branch,''' is used on the local computer and will be enforced on the remote one.']);disp(' ')
    %
else
    %
    flag_active_branch = 0;
    %
    for ib = 1:length(local_branches)
        %
        if strcmp(lukegitbranch,local_branches{ib}) && flag_active_branch == 0
            %
            [local_status, local_cmdout] = system(['timeout 10 ssh ',username,'@',hostname,' "cd ',dkepath.luke_root,';git checkout ',lukegitbranch,'" || echo "',warning_ssh,'"']);
            %
            if strcmp(warning_ssh,deblank(local_cmdout))
                %
                error(warning_ssh);
                %
            end
            %
            if local_status == 0
                %
                cprintf('*green',['---> The git branch ''',local_branches{ib},''' specified in sluke simulation parameters for ''',dkepath.luke_project,''' is made active on the local computer.']);disp(' ')
                flag_active_branch = 1;
                %
                disp('-------------------------')
                disp(local_cmdout)
                %
            elseif local_status == 1
                %
                cprintf('*red',['---> The git branch ''',local_branches{ib},''' specified in sluke simulation parameters for ''',dkepath.luke_project,''' is not active on the local computer.']);disp(' ')
                disp('-------------------------')
                disp(local_cmdout)
                return
                %
            end
            %
            if remote_profile_num > 0
                %
                [remote_status,remote_cmdout] = matremotecmd(remote,'',['cd ',remotelukerootproject,remotelukeproject,';git checkout ',remote.gitbranch]);
                %
                if remote_status == 0
                    %
                    cprintf('*green',['---> The git branch ''',local_branches{ib},''' specified in sluke simulation parameters for ''',dkepath.luke_project,''' is made active on the remote computer (',remote_profile_char,').']);disp(' ')
                    %
                    disp('-------------------------')
                    disp(remote_cmdout)
                    %
                elseif remote_status == 1
                    %
                    cprintf('*red',['---> The git branch ''',local_branches{ib},''' specified in sluke simulation parameters for ''',dkepath.luke_project,''' is not active on the remote computer (',remote_profile_char,').']);disp(' ')
                    disp('-------------------------')
                    disp(remote_cmdout)
                    return
                    %
                end
                %
            end
            %
        end
        %
    end
    %
    if flag_active_branch == 0
        %
        cprintf('*red',['---> WARNING : The requested git branch ''',lukegitbranch,''' specified in sluke simulation parameters for ''',dkepath.luke_project,''' does not exist locally. Check available git branches.']);disp(' ')
        return;
        %
    end
    %
end
%
% git pull of LUKE and related toolboxes on request
%
if isfield(sparams,'simul') && isfield(sparams.simul,'git') && isfield(sparams.simul.git,'pull')  && ~isempty(sparams.simul.git.pull{ii}) && sparams.simul.git.pull{ii} == 1
    %
    if isfield(sparams.simul.git,'projects')
        %
        if isfield(sparams.simul.git,'display') && ~isempty(sparams.simul.git.display{ii})
            %
            displaymode = sparams.simul.git.display{ii};
            %
        else
            %
            displaymode = 0;
            %
        end
        %
        kk = 1;
        %
        for jj = 1:length(sparams.simul.git.projects{ii})
            %
            if strcmp(sparams.simul.git.projects{ii}{jj},'MatRemote')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootproject,'MatRemote;git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootproject,'MatRemote;git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0 && ~isempty(txt{kk})
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the remote project MatRemote (',remote_profile_char,') failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the local project MatRemote failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    end
                    %
                else
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*green',['---> Last ''git pull'' of the remote project MatRemote (',remote_profile_char,') has been successfully performed.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*green',['---> Last ''git pull'' of the local project MatRemote has been successfully performed.']);disp(' ')
                        %
                    end
                    %
                end
                %
                if displaymode || err(kk) > 0
                    %
                    disp(txt{kk});
                    %
                end
                kk = kk + 1;
            end
            %
            if strcmp(sparams.simul.git.projects{ii}{jj},'MatTools')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootproject,'MatTools;git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootproject,'MatTools;git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0 && ~isempty(txt{kk})
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the remote project MatTools (',remote_profile_char,') failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the local project MatTools failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    end
                    %
                else
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*green',['---> Last ''git pull'' of the remote project MatTools (',remote_profile_char,') has been successfully performed.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*green',['---> Last ''git pull'' of the local project MatTools has been successfully performed.']);disp(' ')
                        %
                    end
                    %
                end
                %
                if displaymode || err(kk) > 0
                    %
                    disp(txt{kk});
                    %
                end
                kk = kk + 1;
            end
            %
            if strcmp(sparams.simul.git.projects{ii}{jj},'MatHelp')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootproject,'MatHelp;git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootproject,'MatHelp;git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0 && ~isempty(txt{kk})
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the remote project MatHelp (',remote_profile_char,') failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the local project MatHelp failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    end
                    %
                else
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*green',['---> Last ''git pull'' of the remote project MatHelp (',remote_profile_char,') has been successfully performed.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*green',['---> Last ''git pull'' of the local project MatHelp has been successfully performed.']);disp(' ')
                        %
                    end
                    %
                end
                %
                if displaymode || err(kk) > 0
                    %
                    disp(txt{kk});
                    %
                end
                kk = kk + 1;
            end
            %
            %
            if strfind(sparams.simul.git.projects{ii}{jj},'LUKE')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootproject,remotelukeproject,';git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootproject,locallukeproject,';git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0 && ~isempty(txt{kk})
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the remote project ',remotelukeproject,' (',remote_profile_char,') failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the local project ',locallukeproject,' failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    end
                    %
                else
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*green',['---> Last ''git pull'' of the remote project ',remotelukeproject,' (',remote_profile_char,') has been successfully performed.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*green',['---> Last ''git pull'' of the local project ',locallukeproject,' has been successfully performed.']);disp(' ')
                        %
                    end
                    %
                end
                %
                if displaymode || err(kk) > 0
                    %
                    disp(txt{kk});
                    %
                end
                kk = kk + 1;
            end
            %
        end
        %
    else
        %
        cprintf([1,0.5,0],['---> No project defined in sparams.simul.git. Git pull is not performed']);disp(' ')
        %
    end
    %
else
    %

    %
end
%
% git hash generation of all LUKE suite of codes (MatRemore, MatTools, MatHelp and all LUKE branches. Mandatory for traceability
%
if remote_profile_num > 0
    %
    if isfield(remote,'env') && isfield(remote.env,'luke_root') && ~isempty(remote.env.luke_root) %active LUKE
        %
        [err,txt] = matremotecmd(remote,'',['cd ',remote.env.luke_root,';git rev-parse --verify HEAD > lastgithash.txt']);
        %
        if isempty(txt) || err == 0
            %
            cprintf('*green',['---> Last git hash of the remote project ',remotelukeproject,' (',remote_profile_char,') has been successfully generated.']);disp(' ')
            %
        else
            %
            cprintf([1,0.5,0],['---> Last git hash of the remote project ',remotelukeproject,' (',remote_profile_char,') failed : ',txt]);disp(' ')
            %
        end
    else
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project ',remotelukeproject,' (',remote_profile_char,') cannot be generated because luke_root is not defined for the remote machine ',remote.host,'.']);disp(' ')
        %
    end
    %
    [err1,txt1] = matremotecmd(remote,'',['cd ',remotelukerootproject,'MatRemote/;git rev-parse --verify HEAD > lastgithash.txt']);
    [err2,txt2] = matremotecmd(remote,'',['cd ',remotelukerootproject,'MatTools/;git rev-parse --verify HEAD > lastgithash.txt']);
    [err3,txt3] = matremotecmd(remote,'',['cd ',remotelukerootproject,'MatHelp/;git rev-parse --verify HEAD > lastgithash.txt']);
    %
    if ~isempty(txt1) && err1 > 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project MatRemote (',remote_profile_char,') failed : ',txt1]);disp(' ')
        %
    end
    %
    if ~isempty(txt2) && err2 > 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project MatTools (',remote_profile_char,') failed : ',txt2]);disp(' ')
        %
    end
    %
    if ~isempty(txt3) && err3 > 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project MatHelp (',remote_profile_char,') failed : ',txt3]);disp(' ')
        %
    end
    %
    if (isempty(txt1) && isempty(txt2) && isempty(txt3)) || (err1 + err2 + err3 == 0)
        %
        cprintf('*green',['---> Last git hash of the remote projects MatRemote, MatTools and MatHelp (',remote_profile_char,') have all been successfully generated.']);disp(' ')
        %
    end

else
    %
    if isfield(dkepath,'luke_root')
        %
        initdir = pwd;
        %
        [err,txt] = unix(['cd ',dkepath.luke_root,';git rev-parse --verify HEAD > lastgithash.txt']);
        %
        cd(initdir);
        %
        if err == 0
            %
            cprintf('*green',['---> Last git hash of the local project ',locallukeproject,' has been successfully generated.']);disp(' ')
            %
        else
            %
            cprintf([1,0.5,0],['---> Last git hash of the local project ',locallukeproject,' failed : ',txt]);disp(' ')
            %
        end
        %
    else
        %
        cprintf([1,0.5,0],['---> Last git hash of the local project ',locallukeproject,' cannot be generated because luke_root is not defined for the local machine.']);disp(' ')
        %
    end
    %
    initdir = pwd;
    cd(locallukerootproject)
    %
    [err1,txt1] = unix('cd MatRemote/;git rev-parse --verify HEAD > lastgithash.txt;cd ..');
    [err2,txt2] = unix('cd MatTools/;git rev-parse --verify HEAD > lastgithash.txt;cd ..');
    [err3,txt3] = unix('cd MatHelp/;git rev-parse --verify HEAD > lastgithash.txt;cd ..');
    %
    cd(initdir);
    %
    if err1 ~= 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the local project MatRemote failed : ',txt1]);disp(' ')
        %
    end
    %
    if err2 ~= 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the local project MatTools failed : ',txt2]);disp(' ')
        %
    end
    %
    if err3 ~= 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the local project MatHelp failed : ',txt3]);disp(' ')
        %
    end
    %
    if err1 + err2 + err3 == 0
        %
        cprintf('*green',['---> Last git hash of the local projects MatRemote, MatTools and MatHelp have all been successfully generated.']);disp(' ')
        %
    end
    %
end

