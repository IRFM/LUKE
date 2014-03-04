% callbacks script for iluke

switch action
        %
    case 'redmine'
        %
        % Open the web page of redmine for LUKE
        %      
        redmine_LUKE;
        %
     case 'help'
        %
        % Open the on-line help of LUKE
        %      
        doc_LUKE;
        %
    case 'workdir'
        %
        % changing working directory
        %
        [pathname] = igetdir_jd(1,['Please select the working directory'],workdir);
        %
        if pathname ~= 0,
            %
            workdir = pathname;
            %
        end  
        %
        clear pathname
        %
    case 'import'
        %
        % importing from METIS or CRONOS simulation
        %
        sbase = 'before_luke@';
        filestr = [sbase,'*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the METIS/CRONOS ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            import = load([pathname,filename],'dkeparam','dkedisplay','equil','ohm','transpfaste','ripple','wavestructs');
            %
            iluke_import;
            curtime = 1;
            %
            clear import
            %
        end  
        %
        clear sbase filestr filename pathname
        %
        %
    case 'loadshot'
        %
        % loading simulation
        %
        filestr = 'LUKE_*.mat';
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the LUKE_DATA_*.mat or  LUKE_RESULTS_*.mat file'],'',0);
        %
        if filename ~= 0,
            %
            if ~isempty(fieldnames(load([pathname,filename],'lukeobjmod'))),
                %
                % iluke made LUKE_DATA_*.mat file
                %
                load([pathname,filename],'lukeobjmod','dkeparam','dkedisplay','external','equils','ohms','transpfastes','ripples','wavess','wavestructss','outputs','jobs','hxrs','status','tokamak','shotnum','shotimes');
                lukeobj = conc_struct_jd(lukeobj,lukeobjmod);
                %
                if length(shotimes) == 1,% only one time
                    curtime = 1;        
                elseif length(shotimes) > 1,% more than one time
                    curtime = 0; 
                else% no time
                    curtime = -1; 
                end
                %
                iluke_update;
                %
                lukeobj.simulfile.string = filename;%[pathname,filename];
                %
                status.data = 1;
                %
                clear lukeobjmod
                %
                if any(status.job > 0),
                    lukeobj.remote.timeout.value = 1;
                    action = 'lukerun';iluke_callbacks;
                else
                    lukeobj = iluke_info(lukeobj,'');% disable info display
                end
                %
            else
                dataloaded = load([pathname,filename]);
                %
                % recent LUKE_RESULTS_*.mat file with lukestructq
                %
                if isfield(dataloaded,'lukestructs'),
                    %
                    import = dataloaded.lukestructs;
                    %
                    iluke_import;
                    %
                    clear import
                    %
                end                    
                %
                clear dataloaded
                %
            end
            %
            workdir = pathname;
            %
        end  
        %
        clear filestr filename pathname
        %
    case 'saveshot'
        %
        % saving simulation
        %
        sbase = 'LUKE_DATA';
        filestr = [sbase,'_*.mat'];
        %
        if ~isempty(lukeobj.lukeid.string),
            filename = [sbase,'_',lukeobj.lukeid.string,'.mat'];
        elseif ntimes == 0,
            filename = [sbase,'.mat'];
        elseif ntimes == 1 && ~isempty(equils{1}),
            filename = [sbase,'_',make_luke_simulid_jd(equils{1},ohms{1},transpfastes{1},ripples{1},wavess{1}),'.mat'];
        elseif ntimes == 1
            filename = [sbase,'_',tokamak,'_',shotnum,'_',lukeobj.shotimes.string{3},'.mat'];
        else
            filename = [sbase,'_',tokamak,'_',shotnum,'_MultiTimes.mat'];
        end
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            % select fields to save and remote subfields handle 
            %
            lukeobjmod = selectfields_jd(lukeobj,{'tokamak','shotnum','shotime','shotimes','data','equil','ohm','transp','ripple','wave','wavestruct','luke','r5x2','param','display','lukeid'});
            lukeobjmod = rmfields_jd(lukeobjmod,{'handle','position'},1);
            save([pathname,filename],'lukeobjmod','dkeparam','dkedisplay','external','equils','ohms','transpfastes','ripples','wavess','wavestructss','outputs','jobs','hxrs','status','tokamak','shotnum','shotimes');
            %
            lukeobj.simulfile.string = filename;%[pathname,filename];
            %
            status.data = 1;
            %
            clear lukeobjmod
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'dataimport'
        %
        % importing external data
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        if status.data == 2,
            opt_continue = iselect_jd({'No','Yes'},'This action will erase unsaved data. Do you want to continue ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            newexternal = iload_externaldata_jd(dkepath,'',workdir,lukeobj.infopanel.handle,style);
            %
            if isfield(newexternal,'err'),
                lukeobj.infotext.string = {'Error loading external data : ',newexternal.err};
            else
                %
                external = newexternal;
                status.external = 1;
                tokamak = external.basestr;
                shotnum = external.shotnum;                
                %
                status.equil(:) = -1;
                %
                if isfield(external,'shotimes'),
                    external.times = external.shotimes;
                    curtime = 0; 
                elseif isfield(external,'shotime'),
                    external.times = external.shotime;
                    curtime = 1;
                else
                    error('shot time information missing from structure ''external''');
                end                    
                ntimes = length(external.times);
                shotimes(end+1:end+ntimes) = external.times;
                %
                status.equil(end+1:end+ntimes) = 2;
                equils(1,end+1:end+ntimes) = {[]};
                %
            end
            %
            clear newexternal
            %
        end
        %
        clear opt_continue
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'dataload'
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        % loading external data
        %
        if status.data == 2,
            opt_continue = iselect_jd({'No','Yes'},'This action will erase unsaved data. Do you want to continue ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            sbase = 'EXTERNAL';
            filestr = [sbase,'_*.mat'];
            %
            [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
            %
            if filename ~= 0,
                %
                load([pathname,filename],'external');
                %
                status.external = 1;
                tokamak = external.basestr;
                shotnum = external.shotnum;   
                %
                status.equil(:) = -1;
                %
                external.pathname = pathname;
                external.filename = filename;
                %
                if isfield(external,'shotimes'),
                    external.times = external.shotimes;
                    curtime = 0; 
                elseif isfield(external,'shotime'),
                    external.times = external.shotime;
                    curtime = 1;
                else
                    error('shot time information missing from structure ''external''');
                end                    
                ntimes = length(external.times);
                shotimes(end+1:end+ntimes) = external.times;
                %
                status.equil(end+1:end+ntimes) = 2;
                equils(1,end+1:end+ntimes) = {[]};
                %
            end  
            %
            clear sbase filestr filename pathname
            %
        end
        %
        clear opt_continue
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'datasave'
        %
        % saving external data
        %
        sbase = 'EXTERNAL';
        filestr = [sbase,'_*.mat'];
        if isfield(external,'shotimes'),
            shotimestr = 'MultiTimes';
        elseif isfield(external,'shotime'),
            shotimestr = num2str(external.shotime,'%6.4f');
        end
        filename = [sbase,'_',external.basestr,'_',external.shotnum,'_',shotimestr,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        if filename ~= 0,
            %
            save([pathname,filename],'external');
            %
            lukeobj.data.text.string = filename;%[pathname,filename];
        end  
        %
        clear sbase filestr filename pathname shotimestr
        %
    case 'dataclear'
        %
        % clearing external data
        %
        status.external = 0;
        status.equil(:) = -1;
        %
    case 'equilmake'
        %
        % creating equilibrium structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select = struct;
        %
        select.style = style;
        %
        select.idequil = 1;
        select.disp = 1;
        select.print = 1;
        select.comp = 1;
        select.consist = 1;
        %
        if isfield(external,'equil'),% include data from external structure if available
            %
            if curtime == 0,% treat all times from external structure if available
                [~,flag_shotimes,flag_external] = intersect(shotimes,external.times);
            elseif curtime > 0,% select one time from external structure if available
                flag_external = find(external.times == shotimes(curtime));
                flag_shotimes = curtime;
            else
                flag_external = [];% no action
                flag_shotimes = [];% no action
            end
            %
            external_equil = external.equil(flag_external);
            %
            clear flag_external
            %
        else
            %
            if curtime < 1,% new equil
                flag_shotimes = [];
            else% replace existing
                flag_shotimes = curtime;
            end
            %
            external_equil = [];% no external structure
            %
        end
        %
        if length(external_equil) > 1,% more than one time - case with curtime == 0 and external data with multiple times
            %
            mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
            %
            if mdce_mode > 2,
                mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
            end
            %
            dkecluster = clustermode_luke(mdce_mode,'',dkepath);%MatLab distributed computing environment
            %
            select.i_opt = 0;
            %
            set(lukeobj.busy.handle,'Visible','on');drawnow;
            [flag,newequil] = mdce_run('imake_equil_jd',{dkepath,tokamak,'','',workdir,lukeobj.infopanel.handle,select},4,external_equil,dkecluster);
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            clear mdce_mode dkecluster flag 
            %            
        else% treat one time 
            %
            select.busyhandle = lukeobj.busy.handle;
            %    
            newequil = imake_equil_jd(dkepath,tokamak,'',external_equil,workdir,lukeobj.infopanel.handle,select);
            %
        end
        %
        if isfield(newequil,'err'),
            lukeobj.infotext.string = {'Error creating equil structure(s) : ',newequil.err};
        else
            %
            if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
                %
                equils(flag_shotimes) = newequil.';
                %
                status.equil(flag_shotimes) = 1;
                status.ohm(flag_shotimes) = 0;
                status.transpfaste(flag_shotimes) = 0;
                status.ripple(flag_shotimes) = 0;
                status.waves(flag_shotimes) = 0;
                status.wavestructs(flag_shotimes) = 0;
                status.output(flag_shotimes) = 0;
                %
            elseif length(flag_shotimes) == 1,% replace or fill an existing time
                %
                equils{flag_shotimes} = newequil;
                %
                status.equil(flag_shotimes) = 1;
                status.ohm(flag_shotimes) = 0;
                status.transpfaste(flag_shotimes) = 0;
                status.ripple(flag_shotimes) = 0;
                status.waves(flag_shotimes) = 0;
                status.wavestructs(flag_shotimes) = 0;
                status.output(flag_shotimes) = 0;
                %
            else% new time
                %
                equils{end+1} = newequil;
                status.equil(end+1) = 3;
                shotimes(end+1) = equil.shotime;
                %
                curtime = length(shotimes);
                %
            end
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'equildisp';iluke_callbacks;
            %
            clear flag_shotimes
            %
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
        clear select newequil external_equil
        %
    case 'equilload'
        %
        % loading equil data
        %
        % if tokamak & shotnum are already specified (from external or existing equil), 
        % it is required that times are loaded for the same tokamak & shotnum. 
        % equils are added toor repacing existing shotimes
        %
        sbase = 'EQUIL';
        %
        if ~isempty(tokamak),
            filestr = [sbase,'_',tokamak];
        else
            filestr = sbase;
        end
        %
        if ~isempty(shotnum),
            filestr = [filestr,'_',shotnum,'_*.mat'];
        else
            filestr = [filestr,'_*.mat'];
        end
        %
        [filenames,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',1);
        %
        nt = length(filenames);
        %
        for it = 1:nt,
            %
            load([pathname,filenames{it}],'equil');
            %
            if ~isempty(tokamak) && ~strcmp(tokamak,equil.tokamak),% shotimes are added to the same machine and shot number
                continue
            elseif isempty(tokamak)
                tokamak = equil.tokamak;
            end
            if ~isempty(shotnum) && ~strcmp(shotnum,equil.shotnum),
                continue
            elseif isempty(shotnum)
                shotnum = equil.shotnum;
            end
            %
            equil.filename = filenames{it};
            equil.pathnames = pathname;
            %
            equils{end+1} = equil;
            status.equil(end+1) = 3;
            shotimes(end+1) = equil.shotime;
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
        end  
        %
        if nt > 1,
            curtime = 0;
        elseif nt == 1,
            curtime = length(shotimes);
        end
        %
        action = 'equildisp';iluke_callbacks;
        %
        clear sbase filestr filenames pathname it nt equil
        %
    case 'equilsave'
        %
        % saving EQUIL structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        % loading external data
        %
        if curtime == 0,
            opt_continue = iselect_jd({'No','Yes'},'Save each structure ''equil'' separately and automatically ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            sbase = 'EQUIL';
            %
            if curtime == 0,
                %
                savetimes = find(status.equil == 1);
                nt = length(savetimes);
                filenames = cell(1,nt);
                for it = 1:nt,
                    filenames{it} = [sbase,'_',equils{it}.id,'.mat'];
                end
                pathname = workdir;
                %
            elseif curtime > 0 && status.equil(curtime) == 1,
                %
                filestr = [sbase,'_*.mat'];
                %
                filename = [sbase,'_',equils{curtime}.id,'.mat'];
                %
                [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
                %
                if filename ~= 0,
                    savetimes = curtime;
                else
                    savetimes = [];
                    filenames = {filename};
                end
                %
            else
                savetimes = [];
            end
            %
            nt = length(savetimes);
            %
            for it = 1:nt,
                %
                equil = equils{savetimes(it)};
                save([pathname,filenames{it}],'equil');
                %
                equils{savetimes(it)}.pathname = pathname;%[pathname,filename];
                equils{savetimes(it)}.filename = filenames{it};%[pathname,filename];
            end  
            %
            clear sbase filestr filename filenames pathname nt it equil savetimes
            %
        end
        %
        clear opt_continue
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'equilclear'
        %
        % clearing equil structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        % loading external data
        %
        if curtime == 0,
            opt_continue = iselect_jd({'No','Yes'},'Clear all ''equil'' structures ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            if curtime == 0,
                cleartimes = find(status.equil == 1);
            elseif curtime > 0 && status.equil(curtime) == 1,
                cleartimes = curtime;
                curtime = curtime - 1;
            else
                cleartimes = [];
            end
            %
            nt = length(cleartimes);
            for it = 1:nt,
                %
                if (~isempty(external) && isfield(external,'shotimes') && any(external.shotimes == shotimes(cleartimes(it))))...
                || (~isempty(external) && isfield(external,'shotime') && external.shotime == shotimes(cleartimes(it))),
                    status.equil(cleartimes(it)) = 0;% keep time in shotimes
                else
                    status.equil(cleartimes(it)) = -1;% remove time from shotimes
                end
                %
                status.data = 2;
                %
                lukeobj.lukeid.string = '';
                %
            end
            %
            clear cleartimes it nt 
            %
        end
        %
        clear opt_continue
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'equildisp'
        %
        % displaying equilibrium data
        %
        if curtime > 1,
            lukeobj.plot1.gindex = 0;
            lukeobj.plot2.gindex = 0;
            lukeobj.plot3.gindex = 0;
            %
            cleartags = {'equil'};
            %
            iluke_update;% initialize display
            %
            newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
            newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
            %
            equilibrium_jd(equil,NaN,3,'linear',10,[newgraph1_handle,newgraph2_handle,newgraph3_handle],style);
            %   
            ngraphs = length(graphs);
            %
            graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,1,'magnetic equilibrium','equil');
            graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,2,'temperature and density','equil');% includes legend
            graphs(end+1) = iluke_graphs(lukeobj.plot3.handle,1,'effective charge','equil');
            %
            lukeobj.plot1.gindex = ngraphs + 1;
            lukeobj.plot2.gindex = ngraphs + 2;
            lukeobj.plot3.gindex = ngraphs + 3;
            %
            if isfield(equil,'info') && isfield(equil.info,'txt'),
                lukeobj.infotext.string = equil.info.txt;
            else
                lukeobj.infotext.string = '';
            end
            %
            lukeobj = iluke_info(lukeobj,'text');% enable info display
            %
            clear ngraphs newgraph1_handle newgraph2_handle newgraph3_handle  
            %
        else
            %
            lukeobj.plot1.gindex = 0;
            lukeobj.plot2.gindex = 0;
            lukeobj.plot3.gindex = 0;
            %
            cleartags = {'equils'};
            %
            iluke_update;% initialize display
            %
            newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
            newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
            %
            luke_disp_equils_mt(equils,1,newgraph1_handle,style)
            luke_disp_equils_mt(equils,2,newgraph2_handle,style)
            luke_disp_equils_mt(equils,3,newgraph3_handle,style)
            %   
            ngraphs = length(graphs);
            %
            graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,'temperature and density','equils');
            graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,2,'magnetic field and current','equils');% includes legend
            graphs(end+1) = iluke_graphs(lukeobj.plot3.handle,2,'plasma shape','equils');
            %
            lukeobj.plot1.gindex = ngraphs + 1;
            lukeobj.plot2.gindex = ngraphs + 2;
            lukeobj.plot3.gindex = ngraphs + 3;
            %
            clear ngraphs newgraph1_handle newgraph2_handle newgraph3_handle  
            %
        end
        %
    case 'ohmmake'
        %
        % creating ohmic structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        %
        select.idohm = 1;
        %
        if isfield(external,'ohm'),% include data from external structure if available
            %
            if curtime == 0,% treat all times from external structure if available
                flag_calc = find(status.ohm >= 0);
                [~,flag_calctimes,flag_external] = intersect(shotimes(flag_calc),external.times);
                flag_shotimes = flag_calc(flag_calctimes);
            elseif curtime > 0,% select one time from external structure if available
                flag_external = find(external.times == shotimes(curtime));
                flag_shotimes = curtime;
            else
                flag_external = [];% no action
                flag_shotimes = [];% no action
            end
            %
            external_ohm = external.ohm(flag_external);
            nt = length(external_ohm);
            %
            for it = 1:nt,
                 external_ohm(it).equil = equils{flag_shotimes(it)};% for distributed computing
            end
            %
            clear flag_external flag_calc flag_calctimes it nt
            %
        else
            %
            if curtime < 1,% no action
                flag_shotimes = [];
            else% replace existing
                flag_shotimes = curtime;
            end
            %
            external_ohm = [];% no external structure
            %
        end
        %
        if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
            %
            mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
            %
            if mdce_mode > 2,
                mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
            end
            %
            dkecluster = clustermode_luke(mdce_mode,'',dkepath);%MatLab distributed computing environment
            %
            select.i_opt = 0;
            %
            set(lukeobj.busy.handle,'Visible','on');drawnow;
            [flag,newohm] = mdce_run('imake_ohm_jd',{dkepath,tokamak,'','',workdir,lukeobj.infopanel.handle,select},4,external_ohm,dkecluster);
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            clear mdce_mode dkecluster flag 
            %            
        elseif length(flag_shotimes) == 1% treat one time 
            %
            newohm = imake_ohm_jd(dkepath,tokamak,equils{flag_shotimes},external_ohm,workdir,lukeobj.infopanel.handle,select);
            %
        else
            newohm = [];
        end
        %
        if isfield(newohm,'err'),
            lukeobj.infotext.string = {'Error creating structure(s) ''ohm'' : ',newohm.err};
        elseif ~isempty(newohm),
            %
            if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
                %
                ohms(flag_shotimes) = newohm.';
                %
            elseif length(flag_shotimes) == 1,% replace or fill an existing time
                %
                ohms{flag_shotimes} = newohm;
                %
            end
            %
            status.ohm(flag_shotimes) = 1;
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            if curtime > 0,
                action = 'ohmdisp';iluke_callbacks;
            end
            %
            clear flag_shotimes
            %
        end
        %
        clear select newohm external_ohm
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'ohmload'
        %
        % loading ohm data
        %
        sbase = 'OHM';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'ohm');
            %
            lukeobj.ohm.text.string = filename;%[pathname,filename];
            %
            status.ohm = 1;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'ohmdisp';iluke_callbacks;
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'ohmsave'
        %
        % saving OHM structure
        %
        sbase = 'OHM';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',equil.id,'_',ohm.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'ohm');
            %
            lukeobj.ohm.text.string = filename;%[pathname,filename];
        end  
        %
    case 'ohmclear'
        %
        % clearing ohm structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        % loading external data
        %
        if curtime == 0,
            opt_continue = iselect_jd({'No','Yes'},'Clear all ''ohm'' structures ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            if curtime == 0,
                cleartimes = find(status.ohm == 1);
            elseif curtime > 0 && status.ohm(curtime) == 1,
                cleartimes = curtime;
            else
                cleartimes = [];
            end
            %
            nt = length(cleartimes);
            for it = 1:nt,
                %
                status.ohm(cleartimes(it)) = 0;% clear structure
                %
                status.data = 2;
                %
                lukeobj.lukeid.string = '';
                %
            end
            %
            clear cleartimes it nt 
            %
        end
        %
        clear opt_continue
        %
    case 'ohmdisp'
        %
        % displaying ohm data
        %
        lukeobj.plot1.gindex = 0;
        %
        cleartags = {'ohm'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        %
        graph_ohm_jd(equil,ohm,newgraph1_handle,style);
        %   
        ngraphs = length(graphs);
        %
        graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,1,'loop voltage','ohm');
        %
        lukeobj.plot1.gindex = ngraphs + 1;
        %
        if isfield(ohm,'info') && isfield(ohm.info,'txt'),
            lukeobj.infotext.string = ohm.info.txt;
        else
            lukeobj.infotext.string = '';
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
        clear ngraphs newgraph1_handle 
        %
    case 'transpmake'
        %
        % creating transpfaste structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        %
        select.table = 1;
        %
        if isfield(external,'transpfaste'),
            external_transp = external.transpfaste;
        else
            external_transp = '';
        end
        %
        %transpfaste = imake_transp_jd(dkepath,tokamak,equil,external_transp,workdir,lukeobj.infopanel.handle,select);
        transpfaste = imake_transp_jd(dkepath,tokamak,equil,external_transp,workdir,true,select);
        %
        if isfield(transpfaste,'err'),
            lukeobj.infotext.string = {'Error creating transpfaste structure : ',transpfaste.err};
            transpfaste = '';
        else
            %
            lukeobj.transp.text.string = '< not saved >';
            %
            status.transpfaste = 1;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'transpdisp';iluke_callbacks;
            %
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'transpload'
        %
        % loading transpfaste data
        %
        sbase = 'TRANSP';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'transpfaste');
            %
            lukeobj.transp.text.string = filename;%[pathname,filename];
            %
            status.transpfaste = 1;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'transpdisp';iluke_callbacks;
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'transpsave'
        %
        % saving transpfaste structure
        %
        sbase = 'TRANSP';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',equil.id,'_',transpfaste.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'transpfaste');
            %
            lukeobj.transp.text.string = filename;%[pathname,filename];
        end  
        %
    case 'transpclear'
        %
        % clearing transpfaste structure
        %
        transpfaste = '';
        status.transpfaste = 0;
        status.data = 2;
        %
        lukeobj.lukeid.string = '';
        %
        lukeobj = iluke_info(lukeobj,'output');% enable info display
        %
    case 'transpdisp'
        %
        % displaying ohm data
        %
        lukeobj.plot1.gindex = 0;
        lukeobj.plot2.gindex = 0;
        %
        cleartags = {'transpfaste'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        graph_transp_jd(equil,transpfaste,[newgraph1_handle,newgraph2_handle],style);
        %   
        ngraphs = length(graphs);
        %
        graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,1,'radial diffusion','transpfaste');
        graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,1,'radial pinch','transpfaste');% includes legend
        %
        lukeobj.plot1.gindex = ngraphs + 1;
        lukeobj.plot2.gindex = ngraphs + 2;
        %
        if isfield(transpfaste,'info') && isfield(transpfaste.info,'txt'),
            lukeobj.infotext.string = transpfaste.info.txt;
        else
            lukeobj.infotext.string = '';
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
        clear ngraphs newgraph1_handle newgraph2_handle 
        %
    case 'wavestructimport'
        %
        % creating wavestruct structure from external
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select = struct;
        select.style = style;
        %
        if isfield(external,'wave'),% include data from external structure if available
            if curtime == 0,% treat all times from external structure if available
                flag_calc = find(status.wavestructs >= 0);
                [~,flag_calctimes,flag_external] = intersect(shotimes(flag_calc),external.times);
                flag_shotimes = flag_calc(flag_calctimes);
            elseif curtime > 0,% select one time from external structure if available
                flag_external = find(external.times == shotimes(curtime));
                flag_shotimes = curtime;
            else
                flag_external = [];% no action
                flag_shotimes = [];% no action
            end
            %
            external_wave = external.wave(flag_external);
            nt = length(external_wave);
            %
            for it = 1:nt,
                 external_wave(it).equil = equils{flag_shotimes(it)};% for distributed computing
            end
            %
            clear flag_calc flag_calctimes it nt
            %
        else
            %
            if curtime < 1,% no action
                flag_shotimes = [];
            else% replace existing
                flag_shotimes = curtime;
            end
            %
            external_wave = [];% no external structure
            %
        end 
        %
        if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
            %
            mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
            %
            if mdce_mode > 2,
                mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
            end
            %
            dkecluster = clustermode_luke(mdce_mode,'',dkepath);%MatLab distributed computing environment
            %
            set(lukeobj.busy.handle,'Visible','on');drawnow;
            [flag,launchs] = mdce_run('imake_launch_jd',{dkepath,tokamak,'','',workdir,lukeobj.infopanel.handle,select},4,external_wave,dkecluster);
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            clear mdce_mode dkecluster flag 
            %            
        elseif length(flag_shotimes) == 1% treat one time 
            %
            launchs = imake_launch_jd(dkepath,tokamak,equils{flag_shotimes},external_wave,workdir,lukeobj.infopanel.handle,select);
            %
        else
            launchs = [];
        end
        %
        if isfield(launchs,'err'),
            lukeobj.infotext.string = {'Error creating structure(s) ''launchs'' : ',launchs.err};
        elseif ~isempty(launchs),
            %
            if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
                %
                nt = length(flag_shotimes);
                for it = 1:nt,
                    for iw = 1:length(launchs{it});
                        wavestructss{flag_shotimes(it)}{end+1} = imake_wavestructs_jd(equils{flag_shotimes(it)},launchs{it}{iw});
                    end
                end
                %
            elseif length(flag_shotimes) == 1,% replace or fill an existing time
                %
                for iw = 1:length(launchs);
                    wavestructss{flag_shotimes}{end+1} = imake_wavestructs_jd(equils{flag_shotimes},launchs{iw});
                end
                %
            end
            %
            lukeobj.wavestruct.select.value = 1;
            %
            status.wavestructs(flag_shotimes) = 1;
            %
            status.data = 2;
            %
            clear flag_shotimes
            %
        end
        %
        clear select launchs external_wave
        %
        action = 'wavemake';iluke_callbacks;
        %
    case 'wavestructmake'
        %
        % creating wavestruct structure from scratch
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select = struct;
        select.style = style;
        %
        launchs = imake_launch_jd(dkepath,tokamak,equil,'',workdir,lukeobj.infopanel.handle,select);
        %
        wavestructs{end+1} = imake_wavestructs_jd(equil,launchs{1});
        %
        status.data = 2;
        %
        lukeobj.wavestruct.select.value = length(wavestructs);
        %
        clear select launchs
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %
    case 'wavestructload'
        %
        % loading wavestruct data
        %
        sbase = 'WAVESTRUCT';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'wavestruct');
            %
            if isfield(wavestruct.launch,'aloha'),
                wavestruct.launch.spectrum = wavestruct.launch.aloha;
                wavestruct.launch = rmfield(wavestruct.launch,'aloha');
            end
            %
            if ~isfield(wavestruct,'equil'),
                wavestruct.equil = equil;
            end
            %
            wavestructs{end+1} = wavestruct;
            %
            lukeobj.wavestruct.select.value = length(wavestructs);
            %
            status.data = 2;
            %
            clear wavestruct
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'wavestructsave'
        %
        % saving wavestruct structure
        %
        wavestruct = wavestructs{lukeobj.wavestruct.select.value};
        %
        sbase = 'WAVESTRUCT';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',equil.id,'_',wavestruct.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'wavestruct');
            %
        end  
        %
        clear wavestruct sbase filestr filename pathname
        %
    case 'wavestructclear'
        %
        % creating wavestruct structure from external
        %
        wavestructs(lukeobj.wavestruct.select.value) = [];
        lukeobj.wavestruct.select.value = length(wavestructs);
        %  
        status.data = 2;
        %        
    case 'anglesmodify'
        %
        % modifying angles data
        %
        %lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        iw = lukeobj.wavestruct.select.value;
        %
        angles = wavestructs{iw}.launch.angles;
        if isfield(angles,'orig'),
            orig = angles.orig;
            angles = rmfield(angles,'orig');
        else
            orig = angles;
        end
        %
        angles.frequency_GHz = angles.freq/1e9;
        angles.P0_kW = angles.P0/1e3;
        angles.theta_deg = angles.theta*180/pi;
        angles.phi_deg = angles.phi*180/pi;
        angles.P1_theta_deg = angles.P1_theta*180/pi;
        %
        [angles,mod] = imod_struct_jd(rmfield(angles,{'freq','P0','theta','phi','P1_theta'}),'angles',1,true,struct,style);%lukeobj.infopanel.handle
        %
        if any(mod),
            angles.freq = angles.frequency_GHz*1e9;
            angles.P0 = angles.P0_kW*1e3;
            angles.theta = angles.theta_deg*pi/180;
            angles.phi = angles.phi_deg*pi/180;
            angles.P1_theta = angles.P1_theta_deg*pi/180;
            %
            angles.orig = orig;
            %
            wavestructs{iw}.launch = imake_launch_angles_TCV_jd(rmfield(angles,{'frequency_GHz','P0_kW','theta_deg','phi_deg','P1_theta_deg'}));
            wavestructs{iw}.id = [wavestructs{iw}.wavesolver,'_',wavestructs{iw}.launch.id];
            %
            status.data = 2;
            %
        end
        %
        clear iw angles orig mod
        %
        %lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %        
    case 'anglesload'
        %
        % loading angles data
        %
        sbase = 'ANGLES';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'angles');
            %
            wavestructs{end+1} = imake_wavestructs_jd(equil,imake_launch_angles_TCV_jd(angles));
            %
            lukeobj.wavestruct.select.value = length(wavestructs);
            %
            status.data = 2;
            %
            clear angles
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'anglessave'
        %
        % saving angles structure
        %
        angles = wavestructs{lukeobj.wavestruct.select.value}.launch.angles;
        %
        sbase = 'ANGLES';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',angles.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'angles');
            %
        end  
        %
        clear angles sbase filestr filename pathname 
        %
    case 'anglesreset'
        %
        % resetting angles data
        %
        iw = lukeobj.wavestruct.select.value;
        %
        wavestructs{iw}.launch = imake_launch_angles_TCV_jd(wavestructs{iw}.launch.angles.orig);
        wavestructs{iw}.id = [wavestructs{iw}.wavesolver,'_',wavestructs{iw}.launch.id];
        %
        status.data = 2;
        %
        clear iw
        %
    case 'spectrummodify'
        %
        % modifying spectrum data
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        iw = lukeobj.wavestruct.select.value;
        %
        wavestruct = wavestructs{iw};
        wavestructs(iw) = [];
        %
        lukeobj.wavestruct.select.value = length(wavestructs);
        %
        iluke_update;% to clear older spectrum figures 
        %
        if isfield(wavestruct.launch.spectrum,'orig'),
            wavestruct.launch.spectrum = rmfield(wavestruct.launch.spectrum,'orig');
        end
        %
        wavestruct.launch.spectrum.orig = wavestruct.launch.spectrum;
        %
        lukeobj.plot1.gindex = 0;
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Visible','off');% create new graphic objects with requested characteristics
        %
        select = struct;
        select.style = style;
        select.axs = newgraph1_handle;
        select.inter = 1;% interactive mode
        select.opt_gui = lukeobj.infopanel.handle;
        select.mode = 2;% display mode
        %
        signs.ip = sign(equil.psi_apRp(end));
        signs.b0 = sign(equil.ptBPHI(1,1));
        %
        [wavestruct.launch.bNpar0,wavestruct.launch.bdNpar0,wavestruct.launch.bPlhtot,wavestruct.launch.spectrum.param_tor,wavestruct.launch.spectrum.param_pol] = ...
            iproc_spectrum_jd(wavestruct.launch.spectrum,select,signs);
        %
        if wavestruct.launch.spectrum.param_pol.opt_ny == 1,
            wavestruct.launch.rZ0 = mean(wavestruct.launch.rZ0);
        end
        %
        % wavestruct.launch.id = make_launchid_jd(wavestruct.launch);
        %
        % wavestruct.id = [wavestruct.wavesolver,'_',wavestruct.launch.id];
        %
        wavestructs{end+1} = wavestruct;
        %
        status.data = 2;
        %   
        ngraphs = length(graphs);
        %
        graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,['spectrum for ',wavestructs{end}.id],'spectrum');
        %
        lukeobj.plot1.gindex = ngraphs + 1;
        %
        lukeobj.wavestruct.select.value = length(wavestructs);
        %
        clear iw newgraph1_handle specparam select signs wavestruct ngraphs
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %        
    case 'spectrumload'
        %
        % loading spectrum data
        %
        filestr = {'*.mat'};
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the LH spectrum file(s)'],'',0);
        %
        if filename ~= 0,
            %
            spectrum = load([pathname,filename]);
            %
            spectrum.id = filename;
            if any(strfind(spectrum.id,'.mat')),
                spectrum.id = spectrum.id(1:end-4);
            end
            %
            lukeobj = iluke_info(lukeobj,'');% disable info display
            %
            lukeobj.plot1.gindex = 0;
            %lukeobj.plot2.gindex = 0;
            %
            iluke_update;% initialize display
            %
            newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Visible','off');% create new graphic objects with requested characteristics
            %newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Visible','off');% create new graphic objects with requested characteristics
            %
            select = struct;
            select.style = style;
            select.tail = false;
            select.axs = [newgraph1_handle];
            select.inter = 0;% non interactive mode
            select.mode = 2;% display mode
            %
            launchs = imake_launch_jd(dkepath,tokamak,equil,spectrum,workdir,lukeobj.infopanel.handle,select);
            %
            if ~isempty(launchs),
                wavestructs{end+1} = imake_wavestructs_jd(equil,launchs{1});
                %   
                ngraphs = length(graphs);
                %
                graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,[1,2],['spectrum for ',wavestructs{end}.id],'spectrum');
                %
                lukeobj.plot1.gindex = ngraphs + 1;
                %
                lukeobj.wavestruct.select.value = length(wavestructs);
                %
                status.data = 2;
                %
                clear ngraphs
                %
            else
                %
                delete(newgraph1_handle);
                %
            end
            %
            clear spectrum select newgraph1_handle launchs
            %
            lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
            %
        end  
        %
        clear filestr filename pathname
        %
    case 'spectrumsave'
        %
        % saving spectrum structure
        %
        spectrum = wavestructs{lukeobj.wavestruct.select.value}.launch.spectrum;
        %
        sbase = 'SPECTRUM';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',angles.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'spectrum');
            %
        end  
        %
        clear spectrum sbase filestr filename pathname 
        %
    case 'spectrumreset'
        %
        % resetting spectrum data
        %
        %
        iw = lukeobj.wavestruct.select.value;
        %
        wavestruct = wavestructs{iw};
        wavestructs(iw) = [];
        %
        wavestruct.launch.spectrum = wavestruct.launch.spectrum.orig;
        %
        lukeobj.plot1.gindex = 0;
        %
        iluke_update;% to clear older spectrum figures 
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Visible','off');% create new graphic objects with requested characteristics
        %
        select = struct;
        select.style = style;
        select.axs = newgraph1_handle;
        select.inter = 0;% interactive mode
        select.opt_gui = lukeobj.infopanel.handle;
        select.mode = 2;% display mode
        %
        select.opt_ny = wavestruct.launch.spectrum.param_pol.opt_ny;
        %
        signs.ip = sign(equil.psi_apRp(end));
        signs.b0 = sign(equil.ptBPHI(1,1));
        %
        [wavestruct.launch.bNpar0,wavestruct.launch.bdNpar0,wavestruct.launch.bPlhtot,wavestruct.launch.spectrum.param_tor,wavestruct.launch.spectrum.param_pol] = ...
            iproc_spectrum_jd(wavestruct.launch.spectrum,select,signs);
        %
        if wavestruct.launch.spectrum.param_pol.opt_ny == 1,
            wavestruct.launch.rZ0 = mean(wavestruct.launch.rZ0);
        end
        %
        % wavestruct.launch.id = make_launchid_jd(wavestruct.launch);
        %
        % wavestruct.id = [wavestruct.wavesolver,'_',wavestruct.launch.id];
        %
        wavestructs{end+1} = wavestruct;
        %
        status.data = 2;
        %   
        ngraphs = length(graphs);
        %
        graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,['spectrum for ',wavestructs{end}.id],'spectrum');
        %
        lukeobj.plot1.gindex = ngraphs + 1;
        %
        lukeobj.wavestruct.select.value = length(wavestructs);
        %
        clear iw newgraph1_handle specparam select signs wavestruct ngraphs
        %
    case 'launchmodify'
        %
        % modifying launch data
        %
        %lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        iw = lukeobj.wavestruct.select.value;
        %        
        [wavestructs{iw},mod] = iluke_launchmodify(wavestructs{iw},style);        
        %
        if mod,
            status.data = 2;
        end
        %
        clear iw mod
        %
        %lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %        
    case 'launchload'
        %
        % loading angles data
        %
        sbase = 'LAUNCH';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'launch');
            %
            wavestructs{end+1} = imake_wavestructs_jd(equil,launch);
            %
            lukeobj.wavestruct.select.value = length(wavestructs);
            %
            status.data = 2;
            %
            clear launch
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'launchsave'
        %
        % saving angles structure
        %
        launch = wavestructs{lukeobj.wavestruct.select.value}.launch;
        %
        sbase = 'LAUNCH';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',launch.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'launch');
            %
        end  
        %
        clear launch sbase filestr filename pathname 
        %
    case 'launchreset'
        %
        % resetting launch data
        %
        iw = lukeobj.wavestruct.select.value;
        %
        wavestructs{iw}.launch = wavestructs{iw}.launch.orig;
        wavestructs{iw}.id = [wavestructs{iw}.wavesolver,'_',wavestructs{iw}.launch.id];
        %
        status.data = 2;
        %
        clear iw
        %
    case 'c3poparammodify'
        %
        % modifying c3po parameters
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        iw = lukeobj.wavestruct.select.value;
        %
        rtparam = selectfields_jd(wavestructs{iw},{'rtparam','rayparam','waveparam','fitparam','C3POparam','C3POdisplay'});
        if isfield(wavestructs{iw},'orig'),
            orig = wavestructs{iw}.orig;
        else
            orig = rtparam;
        end
        %
        [rtparam,mod] = imod_struct_jd(rtparam,'rtparam',1,lukeobj.infopanel.handle,struct,style);
        %
        if any(mod),
            %
            wavestructs{iw}.rayparam = rtparam.rayparam;
            wavestructs{iw}.waveparam = rtparam.waveparam;
            wavestructs{iw}.fitparam = rtparam.fitparam;
            wavestructs{iw}.C3POparam = rtparam.C3POparam;
            wavestructs{iw}.C3POdisplay = rtparam.C3POdisplay;
            wavestructs{iw}.rtparam = '< not saved >';
            %
            wavestructs{iw}.orig = orig;
            %
            status.data = 2;
            %
        end
        %
        clear iw rtparam orig mod
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %        
    case 'c3poparamload'
        %
        % loading c3po parameters
        %
        sbase = 'C3POPARAM';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        if filename ~= 0,
            %
            iw = lukeobj.wavestruct.select.value;
            %
            rtparam = load([pathname,filename],'rayparam','waveparam','fitparam','C3POparam','C3POdisplay');
            %
            wavestructs{iw}.rayparam = rtparam.rayparam;
            wavestructs{iw}.waveparam = rtparam.waveparam;
            wavestructs{iw}.fitparam = rtparam.fitparam;
            wavestructs{iw}.C3POparam = rtparam.C3POparam;
            wavestructs{iw}.C3POdisplay = rtparam.C3POdisplay;
            wavestructs{iw}.rtparam = filename;
            %
            if isfield(wavestructs{iw},'orig'),
                wavestructs{iw} = rmfield(wavestructs{iw},'orig');
            end
            %
            lukeobj.c3poparam.text.string = filename;%[pathname,filename];
            %
            status.data = 2;
            %
            clear iw rtparam
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'c3poparamsave'
        %
        % saving c3po parameters
        %
        iw = lukeobj.wavestruct.select.value;
        %
        rtparam = selectfields_jd(wavestructs{iw},{'rtparam','rayparam','waveparam','fitparam','C3POparam','C3POdisplay'});
        %
        sbase = 'C3POPARAM';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',wavestructs{iw}.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'-struct','rtparam');
            %
            lukeobj.c3poparam.text.string = filename;%[pathname,filename];
            %
        end  
        %
        clear iw rtparam sbase filestr filename pathname 
        %
    case 'c3poparamreset'
        %
        % resetting c3po parameters
        %
        iw = lukeobj.wavestruct.select.value;
        %
        wavestructs{iw}.rayparam = wavestructs{iw}.orig.rayparam;
        wavestructs{iw}.waveparam = wavestructs{iw}.orig.waveparam;
        wavestructs{iw}.fitparam = wavestructs{iw}.orig.fitparam;
        wavestructs{iw}.C3POparam = wavestructs{iw}.orig.C3POparam;
        wavestructs{iw}.C3POdisplay = wavestructs{iw}.orig.C3POdisplay;
        wavestructs{iw}.rtparam = wavestructs{iw}.orig.rtparam;
        %
        wavestructs{iw} = rmfield(wavestructs{iw},'orig');
        %
        status.data = 2;
        %
        clear iw
        %
    case 'c3pooptim'
        %
        % optimize Bt, Zp & launching angles to deposit power in target area
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        lukeobj.plot1.gindex = 0;
        lukeobj.plot2.gindex = 0;
        lukeobj.plot3.gindex = 0;
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        opt.vessel_opt = 'n';
        opt.abs_max = 0;
        opt.mode = 'n';
        opt.print = -1;
        opt.TeNpar = 1;
        opt.nospec = 1;
        %
        opt.nr_dep = 40;
        opt.rho_disp = 0:0.1:1;
        opt.ymask = NaN;
        opt.xvar = 'p';
        %
        opt.axs = [newgraph1_handle,newgraph2_handle,newgraph3_handle];
        opt.font = style;
        %
        select = struct;
        select.style = style;
        select.opt_gui = lukeobj.infopanel.handle;
        select.opt = opt;
        select.busyhandle = lukeobj.busy.handle;
        %
        iw = lukeobj.wavestruct.select.value;
        %
        if isfield(wavestructs{iw}.launch.angles,'orig'),
            wavestructs{iw}.launch.angles = rmfield(wavestructs{iw}.launch.angles,'orig');
        end
        %
        [newwavestruct,flag_Zp] = wave_optim_jd(dkepath,wavestructs{iw},select);
        %
        if flag_Zp || ~comp_struct_jd(newwavestruct,wavestructs{iw},0),
            status.data = 2;
        end
        %
        wavestructs{iw} = newwavestruct;
        %
        if flag_Zp,% Zp was changed, all waves and other existing wavestructs are cleared
            %
            equil.Zp = wavestructs{iw}.equil.Zp;
            status.output = 0;
            %
            wavestructs([1:iw-1,iw+1:end]) = [];
            lukeobj.wavestruct.select.value = 1;
            %
            if ~isempty(waves),
                waves = '';
                status.waves = 0;
                lukeobj.lukeid.string = '';
            end
        end     
        %
        clear iw newwavestructs flag_Zp newgraph1_handle newgraph2_handle newgraph3_handle opt select
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %
    case 'c3postart'
        %
        % running C3PO for current or all wavestructs
        %
        if curtime > 0,
            %
            wavestructs = wavestructss{curtime}(iw);
            it_flag = curtime;
            %
            mdce_mode = str2double(lukeobj.wsparam.string);
            %
        else% treat all shot times
            %
            wavestructs = {};
            it_flag = [];
            %
            if ~isscalar(iw) || length(lukeobj.wavestruct.select.string) == 1,% treat all wavestructs
                %
                for it=1:ntimes,
                    wavestructs = [wavestructs,wavestructss{it}];
                    it_flag = [it_flag,it*ones(1,length(wavestructss{it}))];
                end
                %
            else% treat only wavestructs with  wavestruct.id = wavestruct.select.string{iw};
                %
                for it=1:ntimes,
                    for iiw = 1:length(wavestructss{it}),
                        if strcmp(wavestructss{it}{iiw},lukeobj.wavestruct.select.string{iw}.id),                            
                            wavestructs = [wavestructs,wavestructss{it}{iiw}];
                            it_flag = [it_flag,it];
                        end
                    end
                end
            end
            %
            mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
            %
            if mdce_mode > 2,
                mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
            end
            %
        end
        %
        wavesolverparam.clustermode.wave_solver_yp.scheduler.mode = mdce_mode;
        %
        set(lukeobj.busy.handle,'Visible','on');drawnow;
        [newwaves] = wave_distribution_yp(dkepath,wavesolverparam,wavestructs);
        set(lukeobj.busy.handle,'Visible','off');drawnow;
        %
        if ~isempty(newwaves),
            %
            for iiw = 1:length(wavestructs),
                %
                wavess{it_flag(iiw)}{end+1} = newwaves{iiw};
                %
                status.waves(it_flag(iiw)) = 1;
                %
            end
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            if curtime > 0,
                action = 'wavedisp';iluke_callbacks;
            end
            %
        end
        %
        clear wavestructs it_flag mdce_mode newwaves wavesolverparam
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'wavemake'%'newwavemake'%
        %
        % show run luke pannel
        %
        if curtime > 0,
            lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        else
            lukeobj = iluke_info(lukeobj,'c3po_MultiTimes');% enable c3po display
        end
        %
    case 'oldwavemake'%'wavemake'%
        %
        % creating wave structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        %
        if isfield(external,'wave'),
            external_wave = external.wave;
        else
            external_wave = '';
        end
        %
        wave = imake_wave_jd(dkepath,tokamak,equil,external_wave,workdir,lukeobj.infopanel.handle,select);
        %
        if isfield(wave,'err'),
            lukeobj.infotext.string = {'Error creating wave structure : ',wave.err};
            wave = '';
        end
        %
        if ~isempty(wave),
            if isempty(waves),
                waves = {wave};
            else
                waves = [waves,wave];
            end
            %
            status.waves = 1;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'wavedisp';iluke_callbacks;
            %
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'waveload'
        %
        % loading wave data
        %
        sbase = 'WAVE';
        filestr = [sbase,'_*.mat'];
        %
        [filenames,pathnames] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',1);
        %
        newwaves = {};
        %
        if filenames ~= 0,
            %
            if ~iscell(filenames),
                load([pathnames,filenames],'wave');
                newwaves = [newwaves,wave];
            else
                for iw = 1:length(filenames),
                    load([pathnames{iw},filenames{iw}],'wave');
                    newwaves = [newwaves,wave];
                end
            end
        end
        %
        if ~isempty(newwaves),
            if isempty(waves),
                waves = newwaves;
            else
                waves = [waves,newwaves];
            end
            %
            status.waves = 1;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'wavedisp';iluke_callbacks;
            %
        end
        %
    case 'wavesave'
        %
        % saving wave structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        sbase = 'WAVE';
        filestr = [sbase,'_*.mat'];
        %
        titletext = 'Select the wave structure to save:';   
        nw = length(waves);
        s = cell(1,nw);
        for iw = 1:nw,
            s{iw} = ['Wave # ',num2str(iw),' : ',waves{iw}.id];
        end
        %    
        iw = iselect_jd(s,titletext,lukeobj.infopanel.handle,style,1);
        %
        wave = waves{iw};
        % 
        filename = [sbase,'_',equil.id,'_',wave.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'wave');
            %
        end  
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'waveclear'
        %
        % clearing wave structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        titletext = 'Select the wave structure to clear:';   
        nw = length(waves);
        s = cell(1,nw);
        for iw = 1:nw,
            s{iw} = ['Wave # ',num2str(iw),' : ',waves{iw}.id];
        end
        %    
        iw = iselect_jd(s,titletext,lukeobj.infopanel.handle,style,1);
        %
        waves(iw) = [];
        if isempty(waves),
            status.waves = 0;
        end
        %
        status.data = 2;
        %
        if ~isempty(iw),
            lukeobj.lukeid.string = '';
        end
        %
        if ~isempty(waves),
            lukeobj.wave.text.string = [num2str(length(waves)),' wave structure(s)'];
            lukeobj.infotext.string = iluke_waveinfo(waves);
        else
            lukeobj = iluke_info(lukeobj,'output');% enable info display            
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'wavedisp'
        %
        % displaying wave data
        %
        lukeobj.plot1.gindex = 0;
        lukeobj.plot2.gindex = 0;
        lukeobj.plot3.gindex = 0;
        %
        cleartags = {'waves'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        opt.vessel_opt = 'n';
        opt.abs_max = 0;
        opt.mode = 'n';
        opt.print = -1;
        opt.TeNpar = 1;
        opt.nospec = 1;
        %
        opt.axs = [newgraph1_handle,newgraph2_handle,newgraph3_handle];
        opt.font = style;
        %
        opt.nr_dep = 40;
        opt.rho_disp = 0:0.1:1;
        opt.ymask = NaN;
        opt.xvar = 'p';
        %
        graph_wave_jd(equil,waves,opt.nr_dep,opt,opt.rho_disp,opt.ymask,opt.xvar);
        %   
        ngraphs = length(graphs);
        %
        graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,1,'poloidal view','waves');
        graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,1,'top view','waves');% includes legend
        graphs(end+1) = iluke_graphs(lukeobj.plot3.handle,1,'linear damping','waves');% includes legend
        %
        lukeobj.plot1.gindex = ngraphs + 1;
        lukeobj.plot2.gindex = ngraphs + 2;
        lukeobj.plot3.gindex = ngraphs + 3;
        %
        lukeobj.wave.text.string = [num2str(length(waves)),' wave structure(s)'];
        lukeobj.infotext.string = iluke_waveinfo(waves);
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
        clear ngraphs newgraph1_handle newgraph2_handle newgraph3_handle opt
        %
    case 'lukerun'
        %
        % show run luke pannel
        %
        lukeobj = iluke_info(lukeobj,'luke');% disable info display
        %
        if curtime == 0,
            if ~any(status.job > 0),
                lukeobj.runcheck.visible = 'off';
                lukeobj.lukechecktext.string = '';
            else
                lukeobj.runcheck.visible = 'on';
                lukeobj.lukechecktext.string = ['Number of LUKE jobs started : ',num2str(sum(status.job > 0))];
            end
            %
            lukeobj.lukeidtitle.visible = 'off';
            lukeobj.lukeid.visible = 'off';
            lukeobj.lukeid.string = '';
        elseif curtime > 0,
            if ~any(status.job > 0),
                lukeobj.runcheck.visible = 'off';
                lukeobj.lukechecktext.string = '';
            else
                lukeobj.runcheck.visible = 'on';
                lukeobj.lukechecktext.string = ['Number of LUKE jobs started under job ID ',job.id];
            end
            %
            lukeobj.lukeidtitle.visible = 'on';
            lukeobj.lukeid.visible = 'on';
            lukeobj.lukeid.string = make_luke_simulid_jd(equils{curtime},ohms{curtime},transpfastes{curtime},ripples{curtime},wavess{curtime});
        end
        %
    case 'lukeclear'
        %
        % clearing output structure
        %
        job = '';
        %
        status.output = 0;
        status.data = 2;
        %
        lukeobj = iluke_info(lukeobj,'output');% enable info display
        %
    case 'lukedisp'
        %
        % displaying luke data
        %
        if curtime > 0,
            lukeobj.plot1.gindex = 0;
            lukeobj.plot2.gindex = 0;
            lukeobj.plot3.gindex = 0;
            %
            cleartags = {'output'};
            %
            iluke_update;% initialize display
            %
            newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
            newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            %
            opt.save = 0;
            opt.nr_dep = 0;
            opt.spec = 0;
            opt.peak = 'n';
            opt.wave = 'n';
            opt.rho = 't'; 
            opt.blist = [];
            opt.diaryname = '';
            opt.peakmode = 1;
            %
            opt.axs = [newgraph1_handle,newgraph2_handle,newgraph3_handle];
            opt.font = style;
            %
            proc_luke_jd(output,0,-1,0.1,NaN,'',opt);
            %   
            ngraphs = length(graphs);
            %
            graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,'RF power profile','output');
            graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,1,'ohmic power profile','output');
            graphs(end+1) = iluke_graphs(lukeobj.plot3.handle,1,'current profile','output');
            %
            lukeobj.plot1.gindex = ngraphs + 1;
            lukeobj.plot2.gindex = ngraphs + 2;
            lukeobj.plot3.gindex = ngraphs + 3;
            %
            if isfield(output,'info') && isfield(output.info,'txt'),
                lukeobj.infotext.string = output.info.txt;
            else
                lukeobj.infotext.string = '';
            end
            %
        else%
            %
            lukeobj.plot1.gindex = 0;
            lukeobj.plot2.gindex = 0;
            lukeobj.plot3.gindex = 0;
            %
            cleartags = {'outputs'};
            %
            iluke_update;% initialize display
            %
            newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
            newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            newgraph4_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
            %
            outputs = luke_disp_outputs_mt(equils,outputs,style,[newgraph1_handle,newgraph2_handle,newgraph3_handle,newgraph4_handle]);
            %   
            ngraphs = length(graphs);
            %
            graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,'Current','outputs');
            graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,2,'Power','outputs');
            graphs(end+1:end+2) = iluke_graphs(lukeobj.plot3.handle,{[2,4],[1,3]},{'RF power absorption','RF power deposition'},'outputs');
            %
            lukeobj.plot1.gindex = ngraphs + 1;
            lukeobj.plot2.gindex = ngraphs + 2;
            lukeobj.plot3.gindex = ngraphs + 3;
            %
        end  
        %
        clear ngraphs newgraph1_handle newgraph2_handle newgraph3_handle newgraph4_handle  
        %
    case 'lukestart'
        %
        % run luke
        %
        iluke_run;
        %
    case 'runcheck'
        %
        % run check
        %
        iluke_run;
        %       
    case 'cleargraphs'
        %
        % run check
        %
        for h = [lukeobj.plot1.handle,lukeobj.plot2.handle,lukeobj.plot3.handle],
            ch = get(h,'children');
            delete(ch(1:end-3));% keep handles for plot list, print & save
        end
        %
        graphs = struct;
        graphs.handles = [];
        graphs.info = '';
        graphs.tag = '';
        graphs(1) = [];% empty structure but keep memory of fields
        %
        lukeobj.plot1.gindex = 0;
        lukeobj.plot2.gindex = 0;
        lukeobj.plot3.gindex = 0;
        %       
        lukeobj.graph1sel.string = {''};
        lukeobj.graph2sel.string = {''};
        lukeobj.graph3sel.string = {''};
        %
        clear h ch
        %
end
%
clear action
%
iluke_update;
%