%
% script iluke_run to run and check luke runs
%
if strcmp(action,'lukestart'),
    %
    timedep = 1 - lukeobj.timedep.value;
    %
    if curtime > 0 || timedep,%single time or dependent calculation
        mdce_mode = 0;
    else% independent multi-time calculation
        mdce_mode = lukeobj.dist.select.value - 1;
    end
    %
    remnum = lukeobj.remote.select.value - 1;
    %
    if remnum > 0,
        returnmode = lukeobj.timeout.value;
    else
        returnmode = 0;
    end
    %
    if curtime > 0
        transpmode = transpfastes{curtime};
    elseif strcmp(lukeobj.transp.modify.state,'on'),%all transpfastes are identical
        transpmode = transpfastes{1};
    else
        transpmode = true;% ensure enough memory by default
    end
    %
    dkepath = lukeschedulerparam(dkepath,mdce_mode,remnum,returnmode,transpmode,false);
    %
    opt.backup = 1;% save intermediate results with fluctuations
    %
    if curtime > 0,
        %
        opt.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
        opt.proc = [];% if not empty, structure containing options for proc_luke. In that case, opt.fields = {'data_proc'}.
        %
        lukestructs = struct;
        %
        lukestructs.simul.id = lukeobj.lukeid.string;
        if remnum == 0 && mdce_mode <= 3,% local calculation
            lukestructs.simul.path = workdir;
        else
            lukestructs.simul.path = './';
        end  
        %
        if isfield(equils{curtime},'fluct') && exist([lukestructs.simul.path,'backup_',lukestructs.simul.id,'.mat'],'file'),
            %
            lukeobj = iluke_info(lukeobj,'');% disable info display
            %
            if iselect_jd({'No','Yes'},'Do you want to load backup file and continue simulation ? ',lukeobj.infopanel.handle,style,1) == 2,
                %
                opt.backup = -2;% save intermediate results with fluctuations
                %
            end
            %
            lukeobj = iluke_info(lukeobj,'luke');drawnow;% disable info display
            %
        end
        %
        lukestructs.opt = opt;
        lukestructs.dkedisplay = dkedisplay;
        %
        lukestructs.dkeparam = dkeparams{curtime};
        lukestructs.equil = equils{curtime};
        lukestructs.ohm = ohms{curtime};
        lukestructs.transpfaste = transpfastes{curtime};
        lukestructs.ripple = ripples{curtime};
        lukestructs.waves = wavess{curtime};
        %
    else
        %
        opt.save = 1;% (1): save LUKE_RESULTS or return error (0): return results or error
        opt.proc = struct;% if not empty, structure containing options for proc_luke. In that case, opt.fields = {'data_proc'}.
        %
        if any(status.output == 1),% LUKE is already run for some times
            %
            lukeobj = iluke_info(lukeobj,'');% disable info display
            %
            job_mask = iselect_jd({},'LUKE already run for some times. Select time indides to calculate : ',lukeobj.infopanel.handle,style.editselectstyle,find(status.output == 0),'edit');
            %
            lukeobj = iluke_info(lukeobj,'luke');drawnow;% disable info display
            %
        else
            job_mask = find(status.output == 0);
        end
        %
        nt = length(job_mask);
        %
        lukestructs = cell(1,nt);
        %
        for it = 1:nt,
            lukestructs{it}.simul.id = make_luke_simulid_jd(equils{job_mask(it)},ohms{job_mask(it)},transpfastes{job_mask(it)},ripples{job_mask(it)},wavess{job_mask(it)});
            if remnum == 0 && mdce_mode <= 3,% local calculation
                lukestructs{it}.simul.path = workdir;
            end        
            %
            lukestructs{it}.opt = opt;
            lukestructs{it}.dkedisplay = dkedisplay;
            %
            lukestructs{it}.dkeparam = dkeparams{job_mask(it)};
            lukestructs{it}.equil = equils{job_mask(it)};
            lukestructs{it}.ohm = ohms{job_mask(it)};
            lukestructs{it}.transpfaste = transpfastes{job_mask(it)};
            lukestructs{it}.ripple = ripples{job_mask(it)};
            lukestructs{it}.waves = wavess{job_mask(it)};
        end
    end
    %
    if returnmode == 0,
        lukeobj.lukechecktext.string = 'LUKE started. Please wait for result.';
        iluke_update_state(lukeobj);
    end
    %
    status.data = 2;    
    %
    clear opt
    %
elseif strcmp(action,'runcheck'),
    %
    if curtime > 0,
        %
        lukestructs = struct;
        lukestructs.job = jobs{curtime};
        %
%         remote = jobs{curtime}.remote;
        %
        jobs{curtime} = [];
        status.job(curtime) = 0;
        %
    else
        %
        job_mask = find(status.job > 0);
        nt = length(job_mask);
        %
%         for it = 2:nt,
%             if ~comp_struct_jd(jobs{job_mask(it)}.remote,jobs{job_mask(1)}.remote,0,{},{'host','cmd'}),
%                 error('Not all jobs use the same remote profile. Aborted')
%             end
%         end
%         %
%         remote = jobs{job_mask(1)}.remote;
        %
        lukestructs = cell(1,nt);
        %
        for it = 1:nt,
            if ~isempty(jobs{job_mask(it)})
                lukestructs{it}.job = jobs{job_mask(it)};
                %
                jobs{job_mask(it)} = [];
            end
            status.job(job_mask(it)) = 0;
        end
        %
    end
    %
    returnmode = 1;
%     nrem = length(dkepath.remote);
%     %
%     flag = false(1,nrem);
%     %
%     for irem = 1:nrem,
%         if comp_struct_jd(dkepath.remote(irem),remote,0,{},{'host','cmd'}),
%             flag(irem) = true;
%         end
%     end
%     %
%     if sum(flag) == 0,
%         error('Remote profile from job cannot be found in dkepath. aborted.')
%     elseif sum(flag) > 1,
%         disp('WARNING : more than one remote profile from dkepath found to be compatible with job.remote. First choice selected.')
%     end
    %
    timedep = [];
%     dkepath.remnum = find(flag,1,'first');
%     %
%     lukeobj.remote.select.value = dkepath.remnum + 1;
    %
%     clear flag irem nrem remote
end
%    
% run or check luke
%
set(lukeobj.busy.handle,'Visible','on');drawnow;
%
lukestructs = run_lukert(lukestructs,dkepath,timedep);
%
set(lukeobj.busy.handle,'Visible','off');drawnow;
%
% manange output
%
if curtime > 0,
    if isfield(lukestructs,'job'),
        %
        jobs{curtime} = lukestructs.job;
        status.job(curtime) = 1;
        %
        action = 'lukerun';iluke_callbacks;
        %
    elseif isfield(lukestructs,'err'),
        %
        lukeobj.infotext.string = {'Error running LUKE : ',lukestructs.err};
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %    
    elseif isfield(lukestructs,'output'),
        %
        outputs{curtime} = iluke_output(lukestructs.output);
        %
        status.output(curtime) = 1;
        status.data = 2;
        %
        action = 'lukedisp';iluke_callbacks;
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    end
else
    for it = 1:nt,
        if isfield(lukestructs{it},'job'),
            %
            jobs{job_mask(it)} = lukestructs{it}.job;
            status.job(job_mask(it)) = 1;
            %
        elseif isfield(lukestructs{it},'err'),
            %
            disp(' ')
            disp(['Error running LUKE for shot time ',num2str(shotimes(job_mask(it))),' s : ']);
            disperr_jd(lukestructs{it}.err);
            %    
        elseif isfield(lukestructs{it},'output'),
            %
            outputs{job_mask(it)} = iluke_output(lukestructs{it}.output);
            %
            status.output(job_mask(it)) = 1;
            status.sdiag(:,job_mask(it)) = 1;% enable sdiag for times with distribution
            status.data = 2;
            %
        elseif returnmode == 1 && isfield(lukestructs{1},'job'),% jobs transfered through mdce_remote
            status.job(job_mask(it)) = 1;
        end
    end
    %
    clear job_mask it nt
    %
    if any(status.job > 0),
        action = 'lukerun';iluke_callbacks;
    elseif any(status.output > 0), 
        action = 'lukedisp';iluke_callbacks;
    else
        lukeobj = iluke_info(lukeobj,'text');% enable info display
    end
    %
end
%
clear lukestructs timedep mdce_mode remnum returnmode transpmode
%
    
    






