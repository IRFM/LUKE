function sluke_git(sparams,ii)
%
[dkepath] = sluke_dkepath(sparams,ii);
%
remote_profile_num = sluke_remote_profile(sparams,ii,0,1);
%
remote = dkepath.remote(remote_profile_num);
%
jj = strfind(remote.env.luke_root,'/');
remotelukebranch = remote.env.luke_root(jj(end-1)+1:jj(end)-1);
remotelukerootfolder = remote.env.luke_root(1:jj(end-1));
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
                [txt{kk},err(kk)] = matremotessh(remote,['cd ',remotelukerootfolder,'MatRemote;git pull']);
                %
                if err(kk) > 0
                    %
                    cprintf([1,0.5,0],['---> Last ''git pull'' of the remote project MatRemote failed : ',txt{kk}]);disp(' ')
                    %
                else
                    %
                    cprintf('*green',['---> Last ''git pull'' of the remote project MatRemote has been successfully performed.']);disp(' ')
                    %
                end
                if displaymode
                    %
                    disp(txt{kk});
                    %
                end
                kk = kk + 1;
            end
            %
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'MatTools')
                %
                [txt{kk},err(kk)] = matremotessh(remote,['cd ',remotelukerootfolder,'MatTools;git pull']);
                %
                if err(kk) > 0
                    %
                    cprintf([1,0.5,0],['---> Last ''git pull'' of the remote project MatTools failed : ',txt{kk}]);disp(' ')
                    %
                else
                    %
                    cprintf('*green',['---> Last ''git pull'' of the remote project MatTools has been successfully performed.']);disp(' ')
                    %
                end
                if displaymode
                    %
                    disp(txt{kk});
                    %
                end
                %
                kk = kk + 1;
            end
            %
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'MatHelp')
                %
                [txt{kk},err(kk)] = matremotessh(remote,['cd ',remotelukerootfolder,'MatHelp;git pull']);
                %
                if err(kk) > 0
                    %
                    cprintf([1,0.5,0],['---> Last ''git pull'' of the remote project MatHelp failed : ',txt{kk}]);disp(' ')
                    %
                else
                    %
                    cprintf('*green',['---> Last ''git pull'' of the remote project MatHelp has been successfully performed.']);disp(' ')
                    %
                end
                if displaymode 
                  %
                    disp(txt{kk});
                    %    
                end
                %
                kk = kk + 1;
            end
            %
            if strcmp(sparams.simul.remote.git.projects{ii}{jj},'LUKE') == 1
                %
                [txt{kk},err(kk)] = matremotessh(remote,['cd ',remotelukerootfolder,remotelukebranch,';git pull']);
                %
                if err(kk) > 0
                    %
                    cprintf([1,0.5,0],['---> Last ''git pull'' of the remote project ',remotelukebranch,' failed : ',txt{kk}]);disp(' ')
                    %
                else
                    %
                    cprintf('*green',['---> Last ''git pull'' of the remote project ',remotelukebranch,' has been successfully performed.']);disp(' ')
                    %
                end
                if displaymode 
                	%
                    disp(txt{kk});
                    %    
                end
                %
                kk = kk + 1;
                %
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
if isfield(remote,'env') && isfield(remote.env,'luke_root') && ~isempty(remote.env.luke_root) %active LUKE 
    %
    [txt,err] = matremotessh(remote,['cd ',remote.env.luke_root,';git rev-parse --verify HEAD > lastgithash.txt']);
    %
    if err == 0
        %
        cprintf('*green',['---> Last git hash of the remote project ',remotelukebranch,' has been successfully generated.']);disp(' ')
        %
    else
        %
        cprintf([1,0.5,0],['---> Last git hash of the remote project ',remotelukebranch,' failed : ',txt]);disp(' ')
        %
    end
    %
else
    %
    cprintf([1,0.5,0],['---> Last git hash of the remote project ',remotelukebranch,' cannot be generated because luke_root is not defined for the remote machine ',remote.host,'.']);disp(' ')
    %
end
%
[txt1,err1] = matremotessh(remote,['cd ',remotelukerootfolder,'MatRemote/;git rev-parse --verify HEAD > lastgithash.txt']);
[txt2,err2] = matremotessh(remote,['cd ',remotelukerootfolder,'MatTools/;git rev-parse --verify HEAD > lastgithash.txt']);
[txt3,err3] = matremotessh(remote,['cd ',remotelukerootfolder,'MatHelp/;git rev-parse --verify HEAD > lastgithash.txt']);
%
if err1 ~= 0
    %
    cprintf([1,0.5,0],['---> Last git hash of the remote project MatRemote failed : ',txt1]);disp(' ')
    %
end
%
if err2 ~= 0
    %
    cprintf([1,0.5,0],['---> Last git hash of the remote project MatTools failed : ',txt2]);disp(' ')
    %
end
%
if err3 ~= 0
    %
    cprintf([1,0.5,0],['---> Last git hash of the remote project MatHelp failed : ',txt3]);disp(' ')
    %
end
%
