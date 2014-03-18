%
% script iluke_run to run and check luke runs
%
if lukeobj.remote.timeout.value == 1,
    dkepath.remtimout = 0;
else
    dkepath.remtimout = 60*24;
end
%
dkepath.rempause = 1;
dkepath.debugmode = 0;
dkepath.clean = 2;
%
if strcmp(action,'lukestart'),
    %
    timedep = 1 - lukeobj.timedep.value;
    dkepath.remnum = lukeobj.remote.select.value - 1;
    %
    if curtime > 0,
        %
        opt.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
        opt.proc = [];% if not empty, structure containing options for proc_luke. In that case, opt.fields = {'data_proc'}.
        %
        lukestructs = struct;
        %
        lukestructs.simul.id = lukeobj.lukeid.string;
        if dkepath.remnum == 0,% local calculation
            lukestructs.simul.path = workdir;
        end        
        %
        lukestructs.opt = opt;
        lukestructs.dkeparam = dkeparam;
        lukestructs.dkedisplay = dkedisplay;
        %
        lukestructs.equil = equils{curtime};
        lukestructs.ohm = ohms{curtime};
        lukestructs.transpfaste = transpfastes{curtime};
        lukestructs.ripple = ripples{curtime};
        lukestructs.waves = wavess{curtime};
        %
    else
        %
        opt.save = -1;% (1): save LUKE_RESULTS or return error (0): return results or error
        opt.savepath = [workdir,'LUKE_files',filesep];% (1): save LUKE_RESULTS or return error (0): return results or error
        opt.proc = struct;% if not empty, structure containing options for proc_luke. In that case, opt.fields = {'data_proc'}.
        %
        if any(status.output),% LUKE is already run for some times
            %
            lukeobj = iluke_info(lukeobj,'');% disable info display
            %
            job_mask = iselect_jd({},'LUKE already run for some times. Select time incides to calculate : ',lukeobj.infopanel.handle,style.editselectstyle,find(status.output == 0),'edit');
            %
            lukeobj = iluke_info(lukeobj,'luke');drawnow;% disable info display
            %
        else
            job_mask = 1:ntimes;
        end
        %
        nt = length(job_mask);
        %
        lukestructs = cell(1,nt);
        %
        for it = 1:nt,
            lukestructs{it}.simul.id = make_luke_simulid_jd(equils{job_mask(it)},ohms{job_mask(it)},transpfastes{job_mask(it)},ripples{job_mask(it)},wavess{job_mask(it)});
            if dkepath.remnum == 0,% local calculation
                lukestructs{it}.simul.path = workdir;
            end        
            %
            lukestructs{it}.opt = opt;
            lukestructs{it}.dkeparam = dkeparam;
            lukestructs{it}.dkedisplay = dkedisplay;
            %
            lukestructs{it}.equil = equils{job_mask(it)};
            lukestructs{it}.ohm = ohms{job_mask(it)};
            lukestructs{it}.transpfaste = transpfastes{job_mask(it)};
            lukestructs{it}.ripple = ripples{job_mask(it)};
            lukestructs{it}.waves = wavess{job_mask(it)};
        end
    end
    %
    if dkepath.remnum == 0 || dkepath.remtimout > 0,
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
        remote = jobs{curtime}.remote;
        %
        jobs{curtime} = [];
        status.job(curtime) = 0;
        %
    else
        %
        job_mask = find(status.job > 0);
        nt = length(job_mask);
        %
        for it = 2:nt,
            if ~comp_struct_jd(jobs{job_mask(it)}.remote,jobs{job_mask(1)}.remote,0,{},{'host','cmd'}),
                error('Not all jobs use the same remote profile. Aborted')
            end
        end
        %
        remote = jobs{job_mask(1)}.remote;
        %
        lukestructs = cell(1,nt);
        %
        for it = 1:nt
            lukestructs{it}.job = jobs{job_mask(it)};
            %
            jobs{job_mask(it)} = [];
            status.job(job_mask(it)) = 0;
        end
        %
    end
    %
    nrem = length(dkepath.remote);
    %
    flag = false(1,nrem);
    %
    for irem = 1:nrem,
        if comp_struct_jd(dkepath.remote(irem),remote,0,{},{'host','cmd'}),
            flag(irem) = true;
        end
    end
    %
    if sum(flag) == 0,
        error('Remote profile from job cannot be found in dkepath. aborted.')
    elseif sum(flag) > 1,
        disp('WARNING : more than one remote profile from dkepath found to be compatible with job.remote. First choice selected.')
    end
    %
    timedep = [];
    dkepath.remnum = find(flag,1,'first');
    %
    lukeobj.remote.select.value = dkepath.remnum + 1;
    %
    clear flag irem nrem remote
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
            status.data = 2;
            %
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
clear lukestructs timedep
%
    
    






