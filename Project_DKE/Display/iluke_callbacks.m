% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
                load([pathname,filename],'lukeobjmod','dkeparams','dkedisplay','external','equils','ohms','transpfastes','ripples','wavess','fluctparams','wavestructss','wavestructids','outputs','jobs','sdiags','hxr','status','tokamak','shotnum','shotimes');
                lukeobj = conc_struct_jd(lukeobj,lukeobjmod);
                %
                iluke_updateoldsimul;
                %
                if length(shotimes) == 1,% only one time
                    curtime = 1;        
                elseif length(shotimes) > 1,% more than one time
                    curtime = 0; 
                else% no time
                    curtime = -1; 
                end
                %
                iluke_initgraphs;% to initialize graphs according to loaded data
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
                    if sum(status.job > 0) == 1,% job started for one time only
                        curtime = find(status.job > 0);
                        iluke_update;
                    end
                    %
                    lukeobj.timeout.value = 1;
                    action = 'lukerun';iluke_callbacks;
                else
                    lukeobj = iluke_info(lukeobj,'');% disable info display
                end
                %
            else
                dataloaded = load([pathname,filename]);
                %
                % recent LUKE_RESULTS_*.mat file with lukestructs
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
            lukeobjmod = selectfields_jd(lukeobj,{'tokamak','shotnum','shotimes','data','equil','ohm','transp','ripple','wave','fluct','wavestruct','luke','sdiag','param','lukeid','timedep'});
            lukeobjmod = rmfields_jd(lukeobjmod,{'handle','position'},1);
            save([pathname,filename],'lukeobjmod','dkeparams','dkedisplay','external','equils','ohms','transpfastes','ripples','wavess','fluctparams','wavestructss','wavestructids','outputs','jobs','sdiags','hxr','status','tokamak','shotnum','shotimes');
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
                equils(1,flag_shotimes) = newequil.';
                %
                status.equil(:,flag_shotimes) = 1;
                status.ohm(:,flag_shotimes) = 0;
                status.transpfaste(:,flag_shotimes) = 0;
                status.ripple(:,flag_shotimes) = 0;
                status.waves(:,flag_shotimes) = 0;
                status.wavestructs(:,flag_shotimes) = 0;
                status.output(:,flag_shotimes) = 0;
                %
            elseif length(flag_shotimes) == 1,% replace or fill an existing time
                %
                equils{1,flag_shotimes} = newequil;
                %
                status.equil(:,flag_shotimes) = 1;
                status.ohm(:,flag_shotimes) = 0;
                status.transpfaste(:,flag_shotimes) = 0;
                status.ripple(:,flag_shotimes) = 0;
                status.waves(:,flag_shotimes) = 0;
                status.wavestructs(:,flag_shotimes) = 0;
                status.output(:,flag_shotimes) = 0;
                %
            else% new time
                %
                equils{1,end+1} = newequil;
                status.equil(:,end+1) = 3;
                shotimes(1,end+1) = equil.shotime;
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
        if ischar(filenames),
            filenames = {filenames};
        end
        %
        nt = length(filenames);
        %
        for it = 1:nt,
            %
            load([pathname,filenames{it}],'equil');
            %
            equil = iluke_equilcorr(equil);
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
                    filenames = {filename};
                else
                    savetimes = [];
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
                curtime = 0;
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
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'equil'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
        %
        if curtime > 0,
            %
            equilibrium_jd(equils{curtime},NaN,3,'linear',10,[newgraph1_handle,newgraph2_handle,newgraph3_handle],style);
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,1,'magnetic equilibrium','equil',curtime);
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,2,'temperature and density','equil',curtime);% includes legend
            graphs(3) = iluke_graphs(lukeobj.plot3.handle,1,'effective charge','equil',curtime);
            %
            if isfield(equils{curtime},'info') && isfield(equils{curtime}.info,'txt'),
                lukeobj.infotext.string = equils{curtime}.info.txt;
            else
                lukeobj.infotext.string = '';
            end
            %
            lukeobj = iluke_info(lukeobj,'text');% enable info display
            %
        else
            %
            luke_disp_equils_mt(equils,1,newgraph1_handle,style)
            luke_disp_equils_mt(equils,2,newgraph2_handle,style)
            luke_disp_equils_mt(equils,3,newgraph3_handle,style)
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,2,'temperature and density','equil');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,2,'magnetic field and current','equil');% includes legend
            graphs(3) = iluke_graphs(lukeobj.plot3.handle,2,'plasma shape','equil');
            %
        end
        %   
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+3) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        lukeobj.plot3.gindex(it_g) = ngraphs + 3;
        %
        clear it_g ngraphs newgraph1_handle newgraph2_handle newgraph3_handle  
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
            action = 'ohmdisp';iluke_callbacks;
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
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'ohm'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        if curtime > 1
            %
            graph_ohm_jd(equils{curtime},ohms{curtime},[newgraph1_handle,newgraph2_handle],style);
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,1,'loop voltage','ohm');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,1,'critical field','ohm');
            %
            if isfield(ohms{curtime},'info') && isfield(ohms{curtime}.info,'txt'),
                lukeobj.infotext.string = ohms{curtime}.info.txt;
            else
                lukeobj.infotext.string = '';
            end
            %
            lukeobj = iluke_info(lukeobj,'text');% enable info display
            %
        else
            %
            luke_disp_ohms_mt(equils(status.ohm == 1),ohms(status.ohm == 1),[newgraph1_handle,newgraph2_handle],style)
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,2,'center and edge loop voltage','ohm');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,2,'center and edge critical field','ohm');
            %
        end
        %   
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+2) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        %
        clear it_g ngraphs newgraph1_handle
        %
    case 'transpmake'
        %
        % creating transpfaste structure
        %
        % This section anticipates future transport modeling - disabled for now
        % 
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        %
        if isfield(external,'transpfaste'),% include data from external structure if available
            %
            if curtime == 0,% treat all times from external structure if available
                flag_calc = find(status.transpfaste >= 0);
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
            external_transp = external.transpfaste(flag_external);
            nt = length(external_transp);
            %
            for it = 1:nt,
                 external_transp(it).equil = equils{flag_shotimes(it)};% for distributed computing
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
            external_transp = [];% no external structure
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
%             [flag,newtranspfaste] = mdce_run('imake_transp_jd',{dkepath,tokamak,'','',workdir,lukeobj.infopanel.handle,select},4,external_transp,dkecluster);
            [flag,newtranspfaste] = mdce_run('imake_transp_jd',{dkepath,tokamak,'','',workdir,true,select},4,external_transp,dkecluster);
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            clear mdce_mode dkecluster flag 
            %            
        elseif length(flag_shotimes) == 1% treat one time 
            %
%             newtranspfaste = imake_transp_jd(dkepath,tokamak,equils{flag_shotimes},external_transp,workdir,lukeobj.infopanel.handle,select);
            newtranspfaste = imake_transp_jd(dkepath,tokamak,equils{flag_shotimes},external_transp,workdir,true,select);
            %
        else
            newtranspfaste = [];
        end
        %
        if isfield(newtranspfaste,'err'),
            lukeobj.infotext.string = {'Error creating structure(s) ''transpfaste'' : ',newtranspfaste.err};
        elseif ~isempty(newtranspfaste),
            %
            if length(flag_shotimes) > 1,% more than one time - case with curtime == 0 and external data with multiple times
                %
                transpfastes(flag_shotimes) = newtranspfaste.';
                %
            elseif length(flag_shotimes) == 1,% replace or fill an existing time
                %
                transpfastes{flag_shotimes} = newtranspfaste;
                %
            end
            %
            status.transpfaste(flag_shotimes) = 1;
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'transpdisp';iluke_callbacks;
            %
            clear flag_shotimes
            %
        end
        %
        clear select newtranspfastes external_transp
%         %
%         select.table = 1;
%         %
%         %newtranspfaste = imake_transp_jd('','','','','',lukeobj.infopanel.handle,select);
%         newtranspfaste = imake_transp_jd('','','','','',true,select);
%         %
%         if isfield(transpfaste,'err'),
%             lukeobj.infotext.string = {'Error creating transpfaste structure : ',transpfaste.err};
%             transpfaste = '';
%         else
%             %
%             lukeobj.transp.text.string = '< not saved >';
%             %
%             status.transpfaste = 1;
%             status.data = 2;
%             %
%             lukeobj.lukeid.string = '';
%             %
%             action = 'transpdisp';iluke_callbacks;
%             %
%         end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'transpmodify'
        %
        % modifying transport parameters
        %
        if curtime > 0,
            transpfaste = transpfastes{curtime};
        else
            transpfaste = transpfastes{1};
        end  
        %
        if isfield(transpfaste,'orig'),
            orig = transpfaste.orig;
        else
            orig = transpfaste;
        end
        %
        [transpfaste,mod] = imod_struct_jd(transpfaste,'transpfaste',1,true,struct,style);
        %
        if any(mod),
            %
            if curtime > 0,
                transpfastes{curtime} = transpfaste;
                %
                transpfastes{curtime}.orig = orig;
            else
                for it = 1:ntimes,
                    transpfastes{it} = transpfaste;
                    %
                    transpfastes{it}.orig = orig;
                end
                %
                clear it
            end
            %
            status.data = 2;
            %
        end
        %
        clear transpfaste orig mod
        %
    case 'transpload'
        %
        % loading transport parameters
        %
        sbase = 'TRANSP';
        filestr = [sbase,'_*.mat'];
        %
        if curtime > 0,
            transp_id = transpfastes{curtime}.id;
        else
            transp_id = transpfastes{1}.id;
        end
        pathname = fileparts(which(['TRANSP_',transp_id,'.mat']));
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],pathname,0);
        %
        if filename ~= 0,
            %
            load([pathname,filename],'transpfaste');
            %
            if curtime > 0,
                transpfastes{curtime} = transpfaste;
            else
                for it = 1:ntimes,
                    transpfastes{it} = transpfaste;
                end
                %
                clear it
            end
        end  
        %
        action = 'transpdisp';iluke_callbacks;
        %
        clear sbase filestr filename pathname transpfaste transp_id
        %
    case 'transpsave'
        %
        % saving transport parameters
        %
        if curtime > 0,
            transpfaste = transpfastes{curtime};
        else
            transpfaste = transpfastes{1};
        end  
        %
        sbase = 'TRANSP';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',transpfaste.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'transpfaste');
            %
        end  
        %
        clear transpfaste sbase filestr filename pathname 
        %
     case 'transpreset'
        %
        % resetting transport parameters
        %
        if curtime > 0,
            transpfastes{curtime} = transpfastes{curtime}.orig;
        else
            for it = 1:ntimes,
                transpfastes{it} = transpfastes{it}.orig;
            end
            %
            clear it
        end
        %
    case 'transpdisp'
        %
        % displaying transpfaste data
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'transpfaste'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        if curtime > 1,
            %
            graph_transp_jd(equils{curtime},transpfastes{curtime},[newgraph1_handle,newgraph2_handle],style);
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,1,'radial diffusion','transpfaste');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,1,'radial pinch','transpfaste');% includes legend
            %
            if isfield(transpfastes{curtime},'info') && isfield(transpfastes{curtime}.info,'txt'),
                lukeobj.infotext.string = transpfastes{curtime}.info.txt;
            else
                lukeobj.infotext.string = '';
            end
            %
            lukeobj = iluke_info(lukeobj,'text');% enable info display
            %
        else
            %
            clear it_g newgraph1_handle newgraph2_handle action           
            %
            error('Not yet implemented')
            %
        end
        %   
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+2) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        %
        clear it_g ngraphs newgraph1_handle newgraph2_handle 
        %        
    case 'fluctmodify'
        %
        % modify fluct parameters
        %
        if curtime > 0,
            fluctparam = fluctparams{curtime};
        else
            fluctparam = fluctparams{1};
        end  
        %
        if isfield(fluctparam,'orig'),
            orig = fluctparam.orig;
        else
            orig = fluctparam;
        end
        %
        [fluctparam,mod] = imod_struct_jd(fluctparam,'fluctparam',1,true,struct,style);
        %
        if any(mod),
            %
            if curtime > 0,
                fluctparams{curtime} = fluctparam;
                fluctparams{curtime}.orig = orig;
                status.fluct(curtime) = 2;%recalculate equil
                status.waves(curtime) = 0;%waves are outdated
            else
                for it = 1:ntimes,
                    fluctparams{it} = fluctparam;
                    fluctparams{it}.orig = orig;
                    status.fluct(it) = 2;%recalculate equil
                    status.waves(it) = 0;%waves are outdated
                end
                %
                clear it
            end
            %
            if isfield(fluctparam,'id')
                lukeobj.fluct.text.string = fluctparam.id;
            else
                lukeobj.fluct.text.string = '< not saved >';
            end
            %
            status.data = 2;
            %
        end
        %
        clear fluctparam orig mod
        %        
    case 'fluctload'
        %
        % loading fluct parameters
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        sbase = 'FLUCT';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        if filename ~= 0,
            %
            data = load([pathname,filename],'fluctparam');
            %
            if ~isfield(data.fluctparam,'itnmax'),
                itnmax = iselect_jd({},...
                    'Number of fluctuating states',...
                    lukeobj.infopanel.handle,style.editselectstyle,300,'edit');
%                     'Do you want to specify the number of fluctuating states (for statistics), i.e. [300]? Enter [0] to calculate from dkeparam.tn.',...
%                     lukeobj.infopanel.handle,style.editselectstyle,300,'edit');
                if itnmax > 0,
                    data.fluctparam.itnmax = itnmax;
                end
                clear itnmax
            end
            %
            if curtime > 0,
                fluctparams{curtime} = data.fluctparam;
                status.fluct(curtime) = 2;%recalculate equil
                status.waves(curtime) = 0;%waves are outdated
            else
                for it = 1:ntimes,
                    fluctparams{it} = data.fluctparam;
                    status.fluct(it) = 2;%recalculate equil
                    status.waves(it) = 0;%waves are outdated
                end
                %
                clear it
            end
            %
            if isfield(data.fluctparam,'id')
                lukeobj.fluct.text.string = data.fluctparam.id;
            else
                lukeobj.fluct.text.string = filename;%[pathname,filename];
            end
            %
            status.data = 2;
            %
            clear data
            %
        end  
        %
        clear sbase filestr filename pathname
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %
    case 'wavestructimport'
        %
        % creating wavestruct structure from external
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        iluke_wavestructsimport;
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
        if curtime > 0,
            %
            flag_shotimes = curtime;
            %
            launchs{1} = imake_launch_jd(dkepath,tokamak,equils{curtime},'',workdir,lukeobj.infopanel.handle,select);
            %
        else
            %
            flag_shotimes = find(status.equil == 1);
            %
            clear flag_calc flag_calctimes
            %
            signs.ip = sign(equils{1}.psi_apRp(end));
            signs.b0 = sign(equils{1}.ptBPHI(1,1));
            %
            launchs{1} = imake_launch_jd(dkepath,tokamak,signs,'',workdir,lukeobj.infopanel.handle,select);
            %
            launchs = repmat(launchs,[1,length(flag_shotimes)]);
            %
            clear signs
            %
        end           
        %
        iluke_newwavestructs;% update wavestructs, status and wavestructids
        %
        clear select launchs flag_shotimes
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
        % clearing wavestruct structure (s)
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        if curtime == 0,
            iw_curtime = 1:length(wavestructids);
            opt_continue = iselect_jd({'No','Yes'},['Clear all ''wavestruct'' structures labeled ',lukeobj.wavestruct.select.string{lukeobj.wavestruct.select.value},' ? '],lukeobj.infopanel.handle,style,1) - 1;
        else
            iw_curtime = find(status.wavestructs(:,curtime) == 1);
            opt_continue = 1;
        end
        %
        iw = iw_curtime(lukeobj.wavestruct.select.value);% current index in wavestructss
        %
        if opt_continue,
            %
            status.data = 2;
            %
            if curtime == 0,
                status.wavestructs(iw,:) = 0;
            else
                status.wavestructs(iw,curtime) = 0;
            end
            %
        end
        %
        clear opt_continue iw_curtime iw
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable info display
        %        
    case 'anglesmodify'
        %
        % modifying angles data
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        if curtime == 0,
            iw_curtime = 1:length(wavestructids);
        else
            iw_curtime = find(status.wavestructs(:,curtime) == 1);
        end
        iw = iw_curtime(lukeobj.wavestruct.select.value);% current index in wavestructss
        %
        angles = wavestructss{iw,curtime}.launch.angles;
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
            launchs{1}{1} = imake_launch_angles_TCV_jd(rmfield(angles,{'frequency_GHz','P0_kW','theta_deg','phi_deg','P1_theta_deg'}));
            %
            flag_shotimes = curtime;
            %
            iluke_newwavestructs;
            %
            clear launchs flag_shotimes
            %
        end
        %
        clear iw_curtime iw angles orig mod 
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
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
        [wavestructss{iw,curtime},mod] = iluke_launchmodify(wavestructss{iw,curtime},style);        
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
        % creating wavestruct structure from launch file
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        sbase = 'LAUNCH';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file'],'',0);
        %
        %
        if filename ~= 0,
            %
            data = load([pathname,filename],'launch');
            %
            if curtime > 0,
                flag_shotimes = curtime;
            else
                flag_shotimes = find(status.equil == 1);
            end
            %
            launchs = repmat({{data.launch}},[1,length(flag_shotimes)]);
            %
            iluke_newwavestructs;% update wavestructs, status and wavestructids
            %
            clear data launchs flag_shotimes
            %
        end  
        %
        clear sbase filestr filename pathname
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %
    case 'launchsave'
        %
        % saving angles structure
        %
        iw_curtime = find(status.wavestructs(:,curtime) == 1);
        iw = iw_curtime(lukeobj.wavestruct.select.value);% current index in wavestructss
        %
        launch = wavestructss{iw,curtime}.launch;
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
        clear iw_curtime iw launch sbase filestr filename pathname 
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
        if curtime > 0,
            iw_curtime = find(status.wavestructs(:,curtime) == 1);
            iw = iw_curtime(lukeobj.wavestruct.select.value);% current index in wavestructss
            %
            rtparam = selectfields_jd(wavestructss{iw,curtime},{'rtparam','rayparam','waveparam','fitparam','C3POparam','C3POdisplay'});
            if isfield(wavestructss{iw,curtime},'orig'),
                orig = wavestructss{iw,curtime}.orig;
            else
                orig = rtparam;
            end
        else
            iw = lukeobj.wavestruct.select.value;
            itlist = find(status.wavestructs(iw,:) == 1);% list of times
            rtparam = selectfields_jd(wavestructss{iw,itlist(1)},{'rtparam','rayparam','waveparam','fitparam','C3POparam','C3POdisplay'});
            if isfield(wavestructss{iw,itlist(1)},'orig'),
                orig = wavestructss{iw,itlist(1)}.orig;
            else
                orig = rtparam;
            end
        end
        %
        [rtparam,mod] = imod_struct_jd(rtparam,'rtparam',1,lukeobj.infopanel.handle,struct,style);
        %
        if any(mod),
            %
            if curtime > 0,
                wavestructss{iw,curtime}.rayparam = rtparam.rayparam;
                wavestructss{iw,curtime}.waveparam = rtparam.waveparam;
                wavestructss{iw,curtime}.fitparam = rtparam.fitparam;
                wavestructss{iw,curtime}.C3POparam = rtparam.C3POparam;
                wavestructss{iw,curtime}.C3POdisplay = rtparam.C3POdisplay;
                wavestructss{iw,curtime}.rtparam = '< not saved >';
                %
                wavestructss{iw,curtime}.orig = orig;
            else
                for it = itlist,
                    wavestructss{iw,it}.rayparam = rtparam.rayparam;
                    wavestructss{iw,it}.waveparam = rtparam.waveparam;
                    wavestructss{iw,it}.fitparam = rtparam.fitparam;
                    wavestructss{iw,it}.C3POparam = rtparam.C3POparam;
                    wavestructss{iw,it}.C3POdisplay = rtparam.C3POdisplay;
                    wavestructss{iw,it}.rtparam = '< not saved >';
                    %
                    wavestructss{iw,it}.orig = orig;
                end
                %
                clear it itlist iwlist
            end
            %
            status.data = 2;
            %
        end
        %
        clear iw rtparam orig mod
        %
        action = 'wavemake';iluke_callbacks;
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
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
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
        iw_curtime = find(status.wavestructs(:,curtime) == 1);
        iw = iw_curtime(lukeobj.wavestruct.select.value);% current index in wavestructss
        %
        if isfield(wavestructss{iw,curtime}.launch,'angles') && isfield(wavestructss{iw,curtime}.launch.angles,'orig'),
            wavestructss{iw,curtime}.launch.angles = rmfield(wavestructss{iw,curtime}.launch.angles,'orig');
        end
        %
        if isfield(wavestructss{iw,curtime}.launch,'orig'),
            wavestructss{iw,curtime}.launch = rmfield(wavestructss{iw,curtime}.launch,'orig');
        end
        %
        [newwavestruct,flag_Zp] = wave_optim_jd(dkepath,wavestructss{iw,curtime},select);
        %
        if flag_Zp || ~comp_struct_jd(newwavestruct,wavestructss{iw,curtime},0),
            status.data = 2;
        end
        %
        wavestructss{iw,curtime} = newwavestruct;
        status.wavestructs(iw,curtime) = 1;
        %
        if flag_Zp,% Zp was changed, all waves and other existing wavestructs are cleared
            %
            equils{curtime}.Zp = wavestructss{iw,curtime}.equil.Zp;
            %
            status.waves(curtime) = 0;
            status.output(curtime) = 0;
            status.wavestructs([1:iw-1,iw+1:end],curtime) = 0;
            %
            lukeobj.lukeid.string = '';
        end     
        %
        clear iw_curtime iw newwavestructs flag_Zp newgraph1_handle newgraph2_handle newgraph3_handle opt select
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
        %
    case 'c3postart'
        %
        % running C3PO for current or all wavestructs
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        calc_mask = zeros(size(status.wavestructs));
        %
        if curtime > 0,
            %
            iw_curtime = find(status.wavestructs(:,curtime) == 1);
            %
            calc_mask(iw_curtime(iw),curtime) = 1;
            %
            clear iw_curtime
            %
        else% treat all shot times
            %
            if ~isscalar(iw),% treat all wavestructs
                %
                calc_mask(status.wavestructs == 1) = 1;
                %
            else% treat only wavestructs with  wavestruct.id = wavestruct.select.string{iw};
                %
                calc_mask(iw,status.wavestructs(iw,:) == 1) = 1;
                %
            end
            %
        end
        %
        mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',lukeobj.infopanel.handle,style.distselectstyle,1,'popupmenu') - 1;
        %
        if mdce_mode > 2,
            mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
        end
        %
        wavesolverparam.clustermode.wave_solver_yp.scheduler.mode = mdce_mode;
        %
        set(lukeobj.busy.handle,'Visible','on');drawnow;
        [newwaves,it_flag,itn_flag] = iluke_wave_jd(dkepath,equils,wavestructss,calc_mask,wavesolverparam);
        set(lukeobj.busy.handle,'Visible','off');drawnow;
        %
        if ~isempty(newwaves),
            %
            for iiw = 1:length(it_flag),
                %
                if itn_flag(iiw) == 0,% to fluctuations for this time
                    wavess{it_flag(iiw)}{end+1} = newwaves{iiw};
                else
                    if (length(wavess{it_flag(iiw)}) < itn_flag(iiw)) || ~iscell(wavess{it_flag(iiw)}{itn_flag(iiw)}),
                        wavess{it_flag(iiw)}{itn_flag(iiw)} = {};
                    end
                    wavess{it_flag(iiw)}{itn_flag(iiw)}{end+1} = newwaves{iiw};
                end
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
        if isnumeric(filenames) || isempty(filenames),
            filenames = {};
            pathnames = {};
        elseif ~iscell(filenames),
            filenames = {filenames};
            pathnames = {pathnames};
        elseif ~iscell(pathnames),
            pathnames = repmat({pathnames},[1,length(filenames)]);
        end
        %
        % list of equil ids for identifications
        %
        equilids = cell(1,ntimes);
        for it=1:ntimes,
            if status.equil(it) == 1,
                equilids{it} = equils{it}.id;
            else
                equilids{it} = '';
            end
        end
        %
        % load new waves and identify equilibrium
        %
        for iw = 1:length(filenames),
            load([pathnames{iw},filenames{iw}],'wave');
            %
            it = strcmp(equilids,wave.equil_id);
            %
            if isempty(it),
                disp(['WARNING : wave with id ',wave.id,' cannot be identified with any existing equilibrium. Discarded.'])
            else
                if length(it) > 1,
                    disp(['WARNING : wave with id ',wave.id,' identified with more than one existing equilibrium. First match enforced.'])
                    it = it(1);
                end
                %
                wavess{it}{end+1} = wave;
                %
                status.waves(it) = 1;
                status.data = 2;
                %
                lukeobj.lukeid.string = '';
            end
        end
        %
        clear sbase filestr filenames pathnames equilids it iw 
        %
    case 'wavesave'
        %
        % saving WAVE structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        % loading external data
        %
        if curtime == 0,
            opt_continue = iselect_jd({'No','Yes'},'Save each structure ''wave'' separately and automatically ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            sbase = 'WAVE';
            %
            if curtime == 0,
                %
                pathname = workdir;
                %
                for it = 1:ntimes,
                    for iw = 1:length(wavess{it}),
                        wave = wavess{it}{iw};
                        filename = [sbase,'_',equils{it}.id,'_',wave.id,'.mat'];
                        %
                        save([pathname,filename],'wave');
                        wavess{it}{iw}.pathname = pathname;
                        wavess{it}{iw}.filename = filename;
                    end
                end
                %
                clear it
                %
            else
                %
                filestr = [sbase,'_*.mat'];
                %
                nw = length(wavess{curtime});
                if nw > 1,
                    titletext = 'Select the wave structure to save:';   
                    s = cell(1,nw);
                    for iw = 1:nw,
                        s{iw} = ['Wave # ',num2str(iw),' : ',wavess{curtime}{iw}.id];
                    end
                    %    
                    iw = iselect_jd(s,titletext,lukeobj.infopanel.handle,style,1);
                else
                    iw = 1;
                end
                %
                wave = wavess{curtime}{iw};
                % 
                filename = [sbase,'_',equils{curtime}.id,'_',wave.id,'.mat'];
                %
                [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
                %
                if filename ~= 0,
                    save([pathname,filename],'wave');
                    wavess{curtime}{iw}.pathname = pathname;
                    wavess{curtime}{iw}.filename = filename;
                end  
                %
                clear filestr nw titletext s 
                %
            end
            %
            clear sbase filename pathname wave iw
            %
        end
        %
        clear opt_continue
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'waveclear'
        %
        % clearing wave structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        if curtime == 0,
            opt_continue = iselect_jd({'No','Yes'},'Clear all ''wave'' structures ? ',lukeobj.infopanel.handle,style,1) - 1;
        else
            opt_continue = 1;
        end
        %
        if opt_continue,
            %
            if curtime == 0,
                if any(status.waves == 1),
                    status.data = 2;
                    lukeobj.lukeid.string = '';
                end
                status.waves(:) = 0;
            else
                %
                titletext = 'Select the wave structure(s) to clear:';   
                nw = length(wavess{curtime});
                s = cell(1,nw);
                for iw = 1:nw,
                    s{iw} = ['Wave # ',num2str(iw),' : ',wavess{curtime}{iw}.id];
                end
                %    
                iw = iselect_jd(s,titletext,lukeobj.infopanel.handle,style,1,'listbox');
                %
                wavess{curtime}(iw) = [];
                if isempty(wavess{curtime}),
                    status.waves(curtime) = 0;
                end
                %
                if ~isempty(iw),
                    status.data = 2;
                    lukeobj.lukeid.string = '';
                end
                %
                clear titletext nw s iw
            end
            %
        end
        %
        clear opt_continue
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'wavedisp'
        %
        % displaying wave data
        %
        %
        lukeobj = iluke_info(lukeobj,'');% enable info display
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'waves'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        newgraph3_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
        %
        if curtime > 0,
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
            waves = wavess{curtime};
            %
            if status.fluct(curtime) <= 0,% no fluctuations
                %
                titletext = 'Select the wave structure(s) to plot :';   
                nw = length(waves);
                s = cell(1,nw);
                for iw = 1:nw,
                    s{iw} = ['Wave # ',num2str(iw),' : ',waves{iw}.id];
                end
                %    
                iw = iselect_jd(s,titletext,lukeobj.infopanel.handle,style,1,'listbox');
                %
                clear s nw titletext
                %
                if length(iw) == 1,% single wave, can be subdivided for plotting
                    wave = waves{iw};
                    nrays = length(wave.rays);
                    if nrays > 1 && iselect_jd({'No','Yes'},'Do you want to subdivide the rays into groups for plotting ? ',lukeobj.infopanel.handle,style,1) == 2,
                        %
                        raygroups = iselect_jd({},...
                            ['Please select groups of rays in the list 1->',num2str(nrays),'. Ex : {1:',num2str(fix(nrays/2)),',',num2str(fix(nrays/2)+1),':',num2str(nrays),'} '],...
                            lukeobj.infopanel.handle,style.editselectstyle,{1:nrays},'edit');
                        %
                        nwaves = length(raygroups);
                        waves = cell(1,nwaves);
                        for iw = 1:nwaves,
                            waves{iw} = wave;
                            waves{iw}.id = [waves{iw}.id,'_',num2str(iw)];
                            waves{iw}.rays = waves{iw}.rays(raygroups{iw});
                        end
                        %
                        clear nwaves iw
                    end
                    %
                    clear wave nrays 
                else
                    waves = waves(iw); 
                end
                %
                lukeobj.wave.text.string = [num2str(length(wavess{curtime})),' wave structure(s)'];
                lukeobj.infotext.string = iluke_waveinfo(wavess{curtime});
                %
            else% with fluctuations
                %
                titletext = 'Select the wave structure to plot :';   
                nw = length(waves{1});
                s = cell(1,nw);
                for iw = 1:nw,
                    is1 = max(strfind(waves{1}{iw},'WAVE_'));%wavess contains wave files 
                    is2 = strfind(waves{1}{iw},'_itn_1.mat') - 1;
                    s{iw} = ['Wave # ',num2str(iw),' : ',waves{1}{iw}(is1:is2)];
                end
                %    
                iw = iselect_jd(s,titletext,lukeobj.infopanel.handle,style,1,'buttongroup');
                %
                clear s nw titletext
                %
                itn_list = iselect_jd({},'Select fluctuations states to show',...
                    lukeobj.infopanel.handle,style.editselectstyle,[1,2,3],'edit');
                %
                % load selected waves
                %
                ntn = length(itn_list);
                newwaves = cell(1,ntn);
                for itn = 1:ntn,
                    data = load(waves{itn_list(itn)}{iw},'wave');
                    newwaves{itn} = data.wave;
                end
                waves = newwaves;
                %
                lukeobj.wave.text.string = [num2str(length(wavess{curtime}{1})),' wave structure(s)'];
                lukeobj.infotext.string = iluke_waveinfo(wavess{curtime});
            end
            %
            graph_wave_jd(equils{curtime},waves,opt.nr_dep,opt,opt.rho_disp,opt.ymask,opt.xvar);
            %
            clear waves
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,1,'poloidal view','waves');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,1,'top view','waves');% includes legend
            graphs(3) = iluke_graphs(lukeobj.plot3.handle,1,'linear damping','waves');% includes legend
            %
        else
            %
            mask_disp = status.fluct <= 0;%select times without fluctuations
            %
            newgraph4_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
            newgraph5_handle = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
            %
            set(lukeobj.busy.handle,'Visible','on');drawnow;
            %
            wave_disp_outputs_mt(wavess(mask_disp),shotimes(mask_disp),style,[newgraph1_handle,newgraph2_handle,newgraph3_handle,newgraph4_handle,newgraph5_handle]);
            %
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,2,'poloidal angle','waves');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,2,'toroidal angle','waves');% includes legend
            graphs(3:5) = iluke_graphs(lukeobj.plot3.handle,{[3,6],[2,5],[1,4]},{'wave power','fraction of power absorbed','linear power deposition'},'waves');% includes legend
            %
            clear newgraph4_handle newgraph5_handle 
            %
        end
        %   
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+length(graphs)) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        lukeobj.plot3.gindex(it_g) = ngraphs + 3;
        %
        clear it_g ngraphs newgraph1_handle newgraph2_handle newgraph3_handle  
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
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
            if status.job(curtime) == 0,
                lukeobj.runcheck.visible = 'off';
                lukeobj.lukechecktext.string = '';
            else
                lukeobj.runcheck.visible = 'on';
                lukeobj.lukechecktext.string = 'LUKE Job in progress';
            end
            %
            lukeobj.lukeidtitle.visible = 'on';
            lukeobj.lukeid.visible = 'on';
            lukeobj.lukeid.string = make_luke_simulid_jd(equils{curtime},ohms{curtime},transpfastes{curtime},ripples{curtime},wavess{curtime});
        end
        %
    case 'lukeexport'
        %
        % exporting LUKE output
        %
        sbase = 'LUKE_OUTPUT';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',outputs{curtime}.data_proc.simul.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        if filename ~= 0,
            %
            soutput.data_proc = outputs{curtime}.data_proc;
            %
            if isfield(outputs{curtime},'dke_out'),
                soutput.f = outputs{curtime}.dke_out.XXf0{end};
                soutput.pn = outputs{curtime}.momentumDKE.pn;
                soutput.mhu = outputs{curtime}.momentumDKE.mhu;
                soutput.xrhoG = outputs{curtime}.data_proc.radial.xrhoG;
                soutput.xrhoP = outputs{curtime}.data_proc.radial.xrhoP;
                soutput.xrhoT = outputs{curtime}.data_proc.radial.xrhoT;
                soutput.xrhoV = outputs{curtime}.data_proc.radial.xrhoV;
                soutput.betath_ref = outputs{curtime}.mksa.betath_ref;
                soutput.ne_ref = outputs{curtime}.mksa.ne_ref;
                soutput.xmhuT = sqrt(outputs{curtime}.gridDKE.xmhubounce2);
                %
                soutput.info.data_proc = 'structure summarizing results with simulation parameters, scalar outputs, radial profiles, etc';
                soutput.info.f = '3D distribution function f(pn,mhu,xrho)';
                soutput.info.pn = 'momentum grid normalized to pT = betath_ref*mc';
                soutput.info.mhu = 'pitch angle grid';
                soutput.info.xrhoG = 'radial grid, rho=r(:,theta=0)/r(lcfs,theta=0)';
                soutput.info.xrhoP = 'radial grid, rho=sqrt(normalized poloidal flux)';
                soutput.info.xrhoT = 'radial grid, rho=sqrt(normalized toroidal flux)';
                soutput.info.xrhoV = 'radial grid, rho=sqrt(normalized volume)';
                soutput.info.betath_ref = 'sqrt(Te/mc2)';
                soutput.info.ne_ref = 'n(r) = <f>*ne_ref';
                soutput.info.xmhuT = 'trapped-passing boundary';
            end
            %
            save([pathname,filename],'-struct','soutput');
            %
        end  
        %
        clear sbase filestr filename pathname soutput
        %
    case 'lukeclear'
        %
        % clearing output structure
        %
        jobs(:) = {[]};
        %
        status.output(:) = 0;
        status.data = 2;
        %
        lukeobj = iluke_info(lukeobj,'output');% enable info display
        %
    case 'lukedisp'
        %
        % displaying luke data
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'output'};
        %
        iluke_update;% initialize display
        %
        axs(1) = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        axs(2) = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(5) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize); 
        axs(4) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(3) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        if curtime > 0,
            %
            opt.gui = lukeobj.infopanel.handle;
            opt.style = style;
            opt.save = 0;
            opt.nr_dep = 0;
            opt.spec = 0;
            opt.peak = 'y';
            opt.wave = 'y';
            opt.rho = 't'; 
            opt.blist = [];
            opt.diaryname = '';
            opt.peakmode = 1;
            %
            opt.axs = axs;
            opt.font = style;
            %
            [outputs{curtime}.data_proc,ir_display] = proc_luke_jd(outputs{curtime},NaN,-1,0.1,[],'',opt);
            %
            clear opt
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,2,'RF power profile','output');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,1,'ohmic power profile','output');
            %
            if ir_display > 0,
                graphs(3:5) = iluke_graphs(lukeobj.plot3.handle,{[3],[1,5],[2,4]},{'current profile',['f1D ir ',num2str(ir_display)],['f2D ir ',num2str(ir_display)]},'output');
            else
                graphs(3) = iluke_graphs(lukeobj.plot3.handle,{1},{'current profile'},'output');
                delete(axs(4:5));
            end
            %
            if isfield(outputs{curtime},'info') && isfield(outputs{curtime}.info,'txt'),
                lukeobj.infotext.string = outputs{curtime}.info.txt;
            else
                lukeobj.infotext.string = '';
            end
            %
            lukeobj = iluke_info(lukeobj,'text');% enable info display
            %
        else
            %
            [outputs,nw] = luke_disp_outputs_mt(equils,outputs,style,axs);
            %
            graphs(1) = iluke_graphs(lukeobj.plot1.handle,2,'Current','output');
            graphs(2) = iluke_graphs(lukeobj.plot2.handle,2,'Power','output');
            if nw > 0,% RF wave
                graphs(3:4) = iluke_graphs(lukeobj.plot3.handle,{[1,4],[2,3]},{'RF power deposition','RF power absorption'},'output');
                delete(axs(5));
            else
                delete(axs(3:5));
            end
            %
            clear nw
        end
        %   
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+length(graphs)) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        if length(graphs) > 2,
            lukeobj.plot3.gindex(it_g) = ngraphs + 3;
        end
        %
        clear it_g ngraphs axs
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'lukefluct'
        %
        % displaying luke fluct data
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'fluct'};
        %
        iluke_update;% initialize display
        %
        axs(1) = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        axs(2) = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(3) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(4) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(5) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        opt.style = style;
        opt.axs = axs;
        opt.font = style;
        %
        fluct_display.mode = 2;
        fluct_display.evol = 0;
        fluct_display.stat = 0;
        %
        backup_file = [workdir,filesep,'backup_',make_luke_simulid_jd(equils{curtime},ohms{curtime},transpfastes{curtime},ripples{curtime},wavess{curtime}),'.mat'];
        %
        set(lukeobj.busy.handle,'Visible','on');drawnow;
        %
        fproc_fluctn_jd(backup_file,fluct_display,'',NaN,opt);%Zfluct_out = %outputs{curtime}.data_proc
        %
        set(lukeobj.busy.handle,'Visible','off');drawnow;
        %
        clear opt fluct_display backup_file
        %
        graphs(1) = iluke_graphs(lukeobj.plot1.handle,2,'current evolution','fluct');
        graphs(2) = iluke_graphs(lukeobj.plot2.handle,2,'current location','fluct');
        graphs(3:5) = iluke_graphs(lukeobj.plot3.handle,{[3,6],[1,4],[2,5]},{'power location','current profile','power profile'},'fluct');
        %
%         if isfield(outputs{curtime},'info') && isfield(outputs{curtime}.info,'txt'),
%             lukeobj.infotext.string = outputs{curtime}.info.txt;
%         else
            lukeobj.infotext.string = '';
%         end
        %
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+length(graphs)) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        lukeobj.plot3.gindex(it_g) = ngraphs + 3;
        %
        clear it_g ngraphs axs
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'parammodify'
        %
        % modifying luke parameters
        %
        if curtime > 0,
            dkeparam = dkeparams{curtime};
        else
            dkeparam = dkeparams{1};
        end  
        %
        if isfield(dkeparam,'orig'),
            orig = dkeparam.orig;
        else
            orig = dkeparam;
        end
        %
        [dkeparam,mod] = imod_struct_jd(dkeparam,'dkeparam',1,true,struct,style);
        %
        if any(mod),
            %
            if curtime > 0,
                dkeparams{curtime} = dkeparam;
                %
                dkeparams{curtime}.orig = orig;
            else
                for it = 1:ntimes,
                    dkeparams{it} = dkeparam;
                    %
                    dkeparams{it}.orig = orig;
                end
                %
                clear it
            end
            %
            status.data = 2;
            %
        end
        %
        clear dkeparam orig mod
        %
    case 'paramload'
        %
        % loading luke parameters
        %
        sbase = 'DKEPARAM';
        filestr = [sbase,'_*.mat'];
        %
        if curtime > 0,
            dkeparam_id = dkeparams{curtime}.id;
        else
            dkeparam_id = dkeparams{1}.id;
        end
        pathname = fileparts(which(['DKEPARAM_',dkeparam_id,'.mat']));
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],pathname,0);
        %
        if filename ~= 0,
            %
            load([pathname,filename],'dkeparam');
            %
            if curtime > 0,
                dkeparams{curtime} = dkeparam;
            else
                for it = 1:ntimes,
                    dkeparams{it} = dkeparam;
                end
                %
                clear it
            end
        end  
        %
        clear sbase filestr filename pathname dkeparam
        %
    case 'paramsave'
        %
        % saving luke parameters
        %
        if curtime > 0,
            dkeparam = dkeparams{curtime};
        else
            dkeparam = dkeparams{1};
        end  
        %
        sbase = 'DKEPARAM';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',dkeparam.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'dkeparam','-v7.3');
            %
        end  
        %
        clear dkeparam sbase filestr filename pathname 
        %
    case 'paramreset'
        %
        % resetting luke parameters
        %
        if curtime > 0,
            dkeparams{curtime} = dkeparams{curtime}.orig;
        else
            for it = 1:ntimes,
                dkeparams{it} = dkeparams{it}.orig;
            end
            %
            clear it
        end
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
    case 'sdiagFEB'
        %
        % fast electron bremsstrahlung pannel
        %
        lukeobj = iluke_info(lukeobj,'r5x2');% disable info display
        %
    case 'hxrcamimport'
        %
        % fast electron bremsstrahlung camera parameters
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        iluke_hxrcamimport; 
        %
        lukeobj.hxrcam.select.value = 1;
        %
        lukeobj = iluke_info(lukeobj,'r5x2');% disable info display
        %
    case 'hxrcamdisp'
        %
        % fast electron bremsstrahlung camera display
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'hxrcam'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        equilibrium_jd(equils{curtime},NaN,3+1i,'linear',10,[newgraph1_handle,newgraph2_handle],style);
        %
        if lukeobj.hxrcam.select.value == 1,
            icams = 1:length(hxr.cam);
        else
            icams = lukeobj.hxrcam.select.value - 1;
        end
        %
        xlim = [min(equils{curtime}.ptx(end,:)),max(equils{curtime}.ptx(end,:))];
        ylim = [min(equils{curtime}.pty(end,:)),max(equils{curtime}.pty(end,:))];
        %
        iluke_hxrcamdisp(hxr.cam(icams),xlim,ylim,equils{curtime}.Rp,equils{curtime}.Zp,[newgraph1_handle,newgraph2_handle],style)
        %
        if length(icams) == 1,
            camstr = ['Cam #',num2str(hxr.cam{icams}.camnum)];
        else
            camstr = 'All Cams';
        end            
        %
        graphs(1) = iluke_graphs(lukeobj.plot1.handle,1,[camstr,' HXR Chords, Poloidal view'],'hxrcam');
        graphs(2) = iluke_graphs(lukeobj.plot2.handle,1,[camstr,' HXR Chords, Toroidal view'],'hxrcam');
        %   
        ngraphs = length(graphss{it_g});
        %
        graphss{it_g}(end+1:end+length(graphs)) = graphs;
        %
        lukeobj.plot1.gindex(it_g) = ngraphs + 1;
        lukeobj.plot2.gindex(it_g) = ngraphs + 2;
        %
        clear it_g xlim ylim icams ngraphs graphs newgraph1_handle newgraph2_handle
        %
    case 'hxrparammodify'
        %
        % fast electron bremsstrahlung computing parameters
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        hxr.param = conc_struct_jd(imod_struct_jd(rmfield(hxr.param,{'kmin','kmax'}),'hxrparam',1,lukeobj.infopanel.handle,struct,style),selectfields_jd(hxr.param,{'kmin','kmax'}));
        %
        lukeobj = iluke_info(lukeobj,'r5x2');% disable info display
        %
    case 'hxrexpimport'
        %
        % fast electron bremsstrahlung experimental data
        %
        hxr.exp = iluke_hxrexpimport(external.hxr); 
        %
    case 'hxrexpclear'
        %
        % fast electron bremsstrahlung experimental data
        %
        hxr.exp = ''; 
        %
    case 'hxrexpdisp'
        %
        % fast electron bremsstrahlung experimental data
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'hxrexp'};
        %
        iluke_update;% initialize display
        %
        axs(1) = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        axs(2) = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(3) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        ic = lukeobj.hxrcam.select.value - 1;% selected camera
        ichord = lukeobj.hxrchord.select.value - 1;% selected chord
        ibin = lukeobj.hxrbin.select.value - 1;% selected energy bin
        %
        if curtime == 0,
            hxrtimes = shotimes;
        else
            hxrtimes = shotimes(curtime);
        end
        %
        [nobj,graphids] = iluke_hxrexpdisp(hxr,struct,hxrtimes,ic,ichord,ibin,axs,style);
        %
        for iplot = 1:3,
            if nobj(iplot) > 0,
                plotstr = ['plot',num2str(iplot)];
                graphss{it_g}(end+1) = iluke_graphs(lukeobj.(plotstr).handle,nobj(iplot),graphids{iplot},'hxrexp');
                lukeobj.(plotstr).gindex(it_g) = length(graphss{it_g});
            else
                delete(axs(iplot));
            end
        end
        %
        clear it_g ic ichord ibin nobj graphids iplot axs
        %
    case 'hxrbremrun'
        %
        % run r5x2
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        select.p_opt = -1;
        select.d_opt = 'n';
        select.n_opt = -1;
        select.t_opt = 0;
        %
        dkedisplay.fhxr = false;% do not save distribution in R5X2
        %
        if curtime == 0,% treat all times with LUKE distribution calculated
            flag_shotimes = find(status.sdiag(1,:) >= 1);
        elseif curtime > 0 && status.sdiag(1,curtime) >= 1,% select one time from external structure if available
            flag_shotimes = curtime;
        else
            flag_shotimes = [];% no action
        end
        %
        ncalc = length(flag_shotimes);
        %
        if ncalc > 1,% more than one time
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
            [flag,equilHXR,radialHXR,Zbremplasma] = mdce_run('irunhxr_jd',{lukeobj.infopanel.handle,workdir,tokamak,'',hxr,'','','',dkedisplay,select},4,outputs(flag_shotimes),dkecluster);
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            clear mdce_mode dkecluster flag 
            %            
        elseif ncalc == 1% treat one time 
            %
            [equilHXR,radialHXR,Zbremplasma] = irunhxr_jd(lukeobj.infopanel.handle,workdir,tokamak,outputs{flag_shotimes},hxr,'','','',dkedisplay,select);
            %
        else
            equilHXR = [];
            radialHXR = [];
            Zbremplasma = [];
        end
        %
        if isfield(equilHXR,'err'),
            lukeobj.infotext.string = {'Error creating structure(s) ''hxr.brem'' : ',equilHXR.err};
        elseif ~isempty(equilHXR),
            %
            if ncalc > 1,% more than one time
                %
                for icalc = 1:ncalc,
                    sdiags{1,flag_shotimes(icalc)}.equilHXR = equilHXR{icalc};
                    sdiags{1,flag_shotimes(icalc)}.radialHXR = radialHXR{icalc};
                    sdiags{1,flag_shotimes(icalc)}.Zbremplasma = Zbremplasma{icalc};
                end
                %
                clear icalc
                %
            elseif ncalc == 1,% replace or fill an existing time
                %
                sdiags{1,flag_shotimes}.equilHXR = equilHXR;
                sdiags{1,flag_shotimes}.radialHXR = radialHXR;
                sdiags{1,flag_shotimes}.Zbremplasma = Zbremplasma;
                %
            end
            %
            status.sdiag(1,flag_shotimes) = 2;
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            clear flag_shotimes ncalc
            %
        end
        %
        clear select equilHXR radialHXR Zbremplasma
        %
        lukeobj = iluke_info(lukeobj,'r5x2');% enable info display
        %
        %iluke_r5x2;
        %
    case 'hxrbremdisp'
        %
        % fast electron bremsstrahlung calculated data
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'hxrbrem'};
        %
        iluke_update;% initialize display
        %
        axs(1) = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        axs(2) = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(3) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
%         ic = lukeobj.hxrcam.select.value - 1;% selected camera
%         ichord = lukeobj.hxrchord.select.value - 1;% selected chord
        ir = lukeobj.hxrrho.select.value - 1;% selected radial position
        it = lukeobj.hxrtheta.select.value - 1;% selected poloidal position
        idir = lukeobj.hxrdir.select.value - 1;% selected direction of emission
        ikphot = lukeobj.hxrkphot.select.value - 1;% selected photon energy
        %
        if curtime == 0,
            ihxrtimes = status.sdiag(1,:) >= 2;
        else
            ihxrtimes = curtime;
        end
        %
        select.style = style;
        select.dir = lukeobj.hxrdir.select.string;
        %
        [nobj,graphids] = iluke_hxrbremdisp(shotimes(ihxrtimes),sdiags(1,ihxrtimes),ikphot,ir,it,idir,axs,select);
        %
        for iplot = 1:3,
            if nobj(iplot) > 0,
                plotstr = ['plot',num2str(iplot)];
                graphss{it_g}(end+1) = iluke_graphs(lukeobj.(plotstr).handle,nobj(iplot),graphids{iplot},'hxrbrem');
                lukeobj.(plotstr).gindex(it_g) = length(graphss{it_g});
            else
                delete(axs(iplot));
            end
        end
        %
        clear it_g ic ichord ibin nobj graphids iplot axs select
        %
    case 'hxrdiagrun'
        %
        % run r5x2
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        select.p_opt = -1;
        select.d_opt = 'n';
        select.s_opt = 'n';
        select.n_opt = -1;
        select.t_opt = 0;
        %
        if curtime == 0,% treat all times with LUKE distribution calculated
            flag_shotimes = find(status.sdiag(1,:) >= 2);
        elseif curtime > 0 && status.sdiag(1,curtime) >= 2,% select one time from external structure if available
            flag_shotimes = curtime;
        else
            flag_shotimes = [];% no action
        end
        %
        ncalc = length(flag_shotimes);
        %
        if ncalc > 1,% more than one time
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
            [flag,Zbremchord,Zbremplasma,Zbremdiag] = mdce_run('irunhxr_jd',{lukeobj.infopanel.handle,workdir,tokamak,'',hxr,'','','',dkedisplay,select},4,sdiags(1,flag_shotimes),dkecluster);
            set(lukeobj.busy.handle,'Visible','off');drawnow;
            %
            clear mdce_mode dkecluster flag 
            %            
        elseif ncalc == 1% treat one time 
            %
            [Zbremchord,Zbremplasma,Zbremdiag] = irunhxr_jd(lukeobj.infopanel.handle,workdir,tokamak,sdiags{1,flag_shotimes},hxr,'','','',dkedisplay,select);
            %
        else
            Zbremchord = [];
            Zbremplasma = [];
            Zbremdiag = [];
        end
        %
        if isfield(Zbremchord,'err'),
            lukeobj.infotext.string = {'Error creating structure(s) ''hxr.diag'' : ',Zbremchord.err};
        elseif ~isempty(Zbremchord),
            %
            if ncalc > 1,% more than one time
                %
                for icalc = 1:ncalc,
                    sdiags{1,flag_shotimes(icalc)}.Zbremchord = Zbremchord{icalc};
                    sdiags{1,flag_shotimes(icalc)}.Zbremplasma = Zbremplasma{icalc};
                    sdiags{1,flag_shotimes(icalc)}.Zbremdiag = Zbremdiag{icalc};
                end
                %
            elseif ncalc == 1,% replace or fill an existing time
                %
                sdiags{1,flag_shotimes}.Zbremchord = Zbremchord;
                sdiags{1,flag_shotimes}.Zbremplasma = Zbremplasma;
                sdiags{1,flag_shotimes}.Zbremdiag = Zbremdiag;
                %
            end
            %
            status.sdiag(1,flag_shotimes) = 3;
            %
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            clear flag_shotimes ncalc 
            %
        end
        %
        clear select Zbremchord Zbremplasma Zbremdiag
        %
        lukeobj = iluke_info(lukeobj,'r5x2');% enable info display
        %
        %iluke_r5x2;
        %
    case 'hxrdiagdisp'
        %
        % fast electron bremsstrahlung experimental vs LUKE 
        %
        it_g = 2 + curtime;%<new>,<all>,...
        %
        lukeobj.plot1.gindex(it_g) = 0;
        lukeobj.plot2.gindex(it_g) = 0;
        lukeobj.plot3.gindex(it_g) = 0;
        %
        cleartags{it_g} = {'hxrdiag'};
        %
        iluke_update;% initialize display
        %
        axs(1) = axes('Parent',lukeobj.plot1.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);% create new graphic objects with requested characteristics
        axs(2) = axes('Parent',lukeobj.plot2.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        axs(3) = axes('Parent',lukeobj.plot3.handle,'units','pixels','Position',style.graph_position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        %
        ic = lukeobj.hxrcam.select.value - 1;% selected camera
        ichord = lukeobj.hxrchord.select.value - 1;% selected chord
        ibin = lukeobj.hxrbin.select.value - 1;% selected energy bin
        %
        if curtime == 0,
            ihxrtimes = status.sdiag(1,:) >= 3;
        else
            ihxrtimes = curtime;
        end
        %
        if curtime == 0,
            hxrtimes = shotimes;
        else
            hxrtimes = shotimes(curtime);
        end
        %
        [nobj,graphids] = iluke_hxrexpdisp(hxr,sdiags(1,ihxrtimes),shotimes(ihxrtimes),ic,ichord,ibin,axs,style);
        %
        for iplot = 1:3,
            if nobj(iplot) > 0,
                plotstr = ['plot',num2str(iplot)];
                graphss{it_g}(end+1) = iluke_graphs(lukeobj.(plotstr).handle,nobj(iplot),graphids{iplot},'hxrdiag');
                lukeobj.(plotstr).gindex(it_g) = length(graphss{it_g});
            else
                delete(axs(iplot));
            end
        end
        %
        clear it_g ic ichord ibin nobj graphids iplot axs
        %
    case 'savegraphs'
        %
        % save graphs
        %
        if curtime > 0,
            shotimestr = num2str(shotimes(curtime),'%6.4f');
        else
            shotimestr = '_MultiTimes';
        end
        %
        iluke_print(2,['Fig_',tokamak,'_',shotnum,'_',shotimestr,' ',lukeobj.(['graph',igraph,'sel']).string{lukeobj.(['graph',igraph,'sel']).value}],'figures/',graphss{2+curtime}(lukeobj.(['plot',igraph]).gindex(2+curtime)).handles);
        %
        clear igraph
        %    
    case 'cleargraphs'
        %
        % clear all graphs
        %
        cleartags(:) = {{'all'}};% clear graphss
        %
        iluke_update
        %
        for h = [lukeobj.plot1.handle,lukeobj.plot2.handle,lukeobj.plot3.handle],
            ch = get(h,'children');
            if length(ch) > 3,
                disp('WARNING : some graphs were not deleted by cleartags. Clearing enforced.')
                delete(ch(1:end-3));% keep handles for plot list, print & save
            end
        end        
        %
        clear h ch
        %
end
%
clear action
%
iluke_update;
%