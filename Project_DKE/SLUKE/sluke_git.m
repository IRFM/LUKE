function sluke_git(sparams,ii)
%
[dkepath] = sluke_dkepath(sparams,ii);
%
[remote_profile_num,remote_profile_char] = sluke_remote_profile(sparams,ii,0,1);
%
if remote_profile_num > 0
    %
    remote = dkepath.remote(remote_profile_num);
    %
    jj = strfind(remote.env.luke_root,'/');
    remotelukebranch = remote.env.luke_root(jj(end-1)+1:jj(end)-1);
    remotelukerootfolder = remote.env.luke_root(1:jj(end-1));
    %
else
    %
    locallukebranch = dkepath.luke_branch;
    locallukerootfolder = dkepath.local_root;
    %
end
%
% git pull of LUKE and related toolboxes on request
%
if isfield(sparams,'simul') && isfield(sparams.simul,'remote') && isfield(sparams.simul.remote,'git') && isfield(sparams.simul.remote.git,'pull')  && ~isempty(sparams.simul.remote.git.pull{ii}) && sparams.simul.remote.git.pull{ii} == 1
    %
    if isfield(sparams.simul.remote.git,'projects')
        %
        if isfield(sparams.simul.remote.git,'display') && ~isempty(sparams.simul.remote.git.display{ii})
            %
            displaymode = sparams.simul.remote.git.display{ii};
            %
        else
            %
            displaymode = 0;
            %
        end
        %
        kk = 1;
        %
        for jj = 1:length(sparams.simul.remote.git.projects{ii})
            %
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'MatRemote')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootfolder,'MatRemote;git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootfolder,'MatRemote;git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0
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
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'MatTools')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootfolder,'MatTools;git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootfolder,'MatTools;git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0
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
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'MatHelp')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootfolder,'MatHelp;git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootfolder,'MatHelp;git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0
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
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'LUKE')
                %
                if remote_profile_num > 0
                    %
                    [err(kk),txt{kk}] = matremotecmd(remote,'',['cd ',remotelukerootfolder,remotelukebranch,';git pull']);
                    %
                else
                    %
                    initdir = pwd;
                    %
                    [err(kk),txt{kk}] = unix(['cd ',locallukerootfolder,locallukebranch,';git pull']);
                    %
                    cd(initdir);
                    %
                end
                %
                if err(kk) > 0
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the remote project ',remotelukebranch,' (',remote_profile_char,') failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*red',['---> WARNING : Last ''git pull'' of the local project ',locallukebranch,' failed because of a merge conflict for some scripts. Please fix the problem manually.']);disp(' ')                        
                        %
                    end
                    %
                else
                    %
                    if remote_profile_num > 0
                        %
                        cprintf('*green',['---> Last ''git pull'' of the remote project ',remotelukebranch,' (',remote_profile_char,') has been successfully performed.']);disp(' ')
                        %
                    else
                        %
                        cprintf('*green',['---> Last ''git pull'' of the local project ',locallukebranch,' has been successfully performed.']);disp(' ')
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
        cprintf([1,0.5,0],['---> No project defined in sparams.simul.remote.git. Git pull is not performed']);disp(' ')
        %
    end
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
        if err == 0
            %
            cprintf('*green',['---> Last git hash of the remote project ',remotelukebranch,' (',remote_profile_char,') has been successfully generated.']);disp(' ')
            %
        else
            %
            cprintf([1,0.5,0],['---> Last git hash of the remote project ',remotelukebranch,' (',remote_profile_char,') failed : ',txt]);disp(' ')
            %
        end
    else
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project ',remotelukebranch,' (',remote_profile_char,') cannot be generated because luke_root is not defined for the remote machine ',remote.host,'.']);disp(' ')
        %
    end
    %
    [err1,txt1] = matremotecmd(remote,'',['cd ',remotelukerootfolder,'MatRemote/;git rev-parse --verify HEAD > lastgithash.txt']);
    [err2,txt2] = matremotecmd(remote,'',['cd ',remotelukerootfolder,'MatTools/;git rev-parse --verify HEAD > lastgithash.txt']);
    [err3,txt3] = matremotecmd(remote,'',['cd ',remotelukerootfolder,'MatHelp/;git rev-parse --verify HEAD > lastgithash.txt']);
    %
    if err1 ~= 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project MatRemote (',remote_profile_char,') failed : ',txt1]);disp(' ')
        %
    end
    %
    if err2 ~= 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project MatTools (',remote_profile_char,') failed : ',txt2]);disp(' ')
        %
    end
    %
    if err3 ~= 0
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project MatHelp (',remote_profile_char,') failed : ',txt3]);disp(' ')
        %
    end
    %
    if err1 + err2 + err3 == 0
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
            cprintf('*green',['---> Last git hash of the local project ',locallukebranch,' has been successfully generated.']);disp(' ')
            %
        else
            %
            cprintf([1,0.5,0],['---> Last git hash of the local project ',locallukebranch,' failed : ',txt]);disp(' ')
            %
        end
        %
    else
        %
        cprintf([1,0.5,0],['---> Last git hash of the local project ',locallukebranch,' cannot be generated because luke_root is not defined for the local machine.']);disp(' ')
        %
    end
    %
    initdir = pwd;
    cd(locallukerootfolder)
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

