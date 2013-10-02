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
            if isfield(import,'equil') && ~isempty(import.equil)
                % 
                % clear current simulation
                %
                status.external = 0;
                status.equil = 0;
                iluke_update;
                %
                % new equil
                %
                equil = import.equil;
                status.equil = 1;
                lukeobj = iluke_equilstrings(lukeobj,equil);
                %
                action = 'equildisp';iluke_callbacks;
                %
                iluke_update;
                %
                if isfield(import,'dkeparam') && ~isempty(import.dkeparam),
                    dkeparam = import.dkeparam;
                end
                if isfield(import,'dkedisplay') && ~isempty(import.dkedisplay),
                    dkedisplay = import.dkedisplay;
                end
                if isfield(import,'ohm') && ~isempty(import.ohm),
                    ohm = import.ohm;
                    status.ohm = 1;
                    %
                    action = 'ohmdisp';iluke_callbacks;
                else
                    status.ohm = 0;                    
                end
                if isfield(import,'transpfaste') && ~isempty(import.transpfaste),
                    transpfaste = import.transpfaste;
                    status.transpfaste = 1;
                    %
                    action = 'transpdisp';iluke_callbacks;
                else
                    status.transpfaste = 0;                    
                end
                if isfield(import,'ripple') && ~isempty(import.ripple),
                    ripple = import.ripple;
                    status.ripple = 1;
                    %
                    action = 'rippledisp';iluke_callbacks;
                else
                    status.ripple = 0;
                end
                if isfield(import,'wavestructs') && ~isempty(import.wavestructs),
                    wavestructs = [wavestructs,import.wavestructs];
                    lukeobj.wavestruct.select.value = length(wavestructs);
                    %
                    action = 'wavemake';iluke_callbacks;
                end                
                status.waves = 0;
                status.output = 0;
            end                          
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
        sbase = 'LUKE_DATA';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'lukeobjmod','dkeparam','dkedisplay','external','equil','ohm','transpfaste','ripple','waves','output','job','hxr','status');
            lukeobj = conc_struct_jd(lukeobj,lukeobjmod);
            iluke_update;
            %
            lukeobj.simulfile.string = filename;%[pathname,filename];
            %
            clear lukeobjmod
            %
        end  
        %
        clear sbase filestr filename pathname
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
        else
            filename = [sbase,'_',make_luke_simulid_jd(equil,ohm,transpfaste,ripple,waves),'.mat'];
        end
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            % select fields to save and remote subfields handle 
            %
            lukeobjmod = selectfields_jd(lukeobj,{'tokamak','shotnum','shotime','data','equil','ohm','transp','ripple','wave','luke','r5x2','param','display'});
            lukeobjmod = rmfields_jd(lukeobjmod,{'handle','position'},1);
            save([pathname,filename],'lukeobjmod','dkeparam','dkedisplay','external','equil','ohm','transpfaste','ripple','waves','output','job','hxr','status');
            %
            lukeobj.simulfile.string = filename;%[pathname,filename];
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
        external = iload_externaldata_jd(dkepath,'',workdir,lukeobj.infopanel.handle,style);
        %
        if isfield(external,'err'),
            lukeobj.infotext.string = {'Error loading external data : ',external.err};
            external = '';
        else
            %
            lukeobj.tokamak.string = external.basestr;
            lukeobj.shotnum.string = external.shotnum;
            lukeobj.shotime.string = external.shotime;
            %
            lukeobj.data.text.string = '< not saved >';
            %
            status.external = 1;
            %
            status.equil = 0;
            %
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'dataload'
        %
        % loading external data
        %
        sbase = 'EXTERNAL';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'external');
            %
            if ~isfield(external,'basestr'),
                ilims = find(external.id == '_');
                external.basestr = external.id(1:ilims(1) - 1);
                external.shotnum = external.id(ilims(1) + 1:ilims(2) - 1);
                external.shotime = external.id(ilims(2) + 1:ilims(3) - 1);
            end
            %
            lukeobj.tokamak.string = external.basestr;
            lukeobj.shotnum.string = external.shotnum;
            lukeobj.shotime.string = external.shotime;
            lukeobj.data.text.string = filename;%[pathname,filename];
            %
            status.external = 1;
            %
            status.equil = 0;
            %
        end  
        %
    case 'datasave'
        %
        % saving external data
        %
        sbase = 'EXTERNAL';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',external.basestr,'_',external.shotnum,'_',external.shotime,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'external');
            %
            lukeobj.data.text.string = filename;%[pathname,filename];
        end  
        %
    case 'dataclear'
        %
        % clearing external data
        %
        external = '';
        status.external = 0;
        %
        status.equil = 0;
        %
    case 'equilmake'
        %
        % creating equilibrium structure
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select.style = style;
        %
        select.idequil = 1;
        select.disp = 1;
        select.print = 1;
        select.comp = 1;
        %
        if isfield(external,'equil'),
            external_equil = external.equil;
        else
            external_equil = '';
        end
        %
        equil = imake_equil_jd(dkepath,lukeobj.tokamak.string,'',external_equil,workdir,lukeobj.infopanel.handle,select);
        %
        if isfield(equil,'err'),
            lukeobj.infotext.string = {'Error creating equil structure : ',equil.err};
            equil = '';
        else
            %
            lukeobj.equil.text.string = '< not saved >';
            %
            status.equil = 1;
            status.ohm = 0;
            status.transpfaste = 0;
            status.ripple = 0;
            status.waves = 0;
            status.output = 0;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'equildisp';iluke_callbacks;
            %
        end
        %
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'equilload'
        %
        % loading equil data
        %
        sbase = 'EQUIL';
        filestr = [sbase,'_*.mat'];
        %
        [filename,pathname] = igetfile_jd(1,filestr,['Please select the ',sbase,' file(s)'],'',0);
        %
        %
        if filename ~= 0,
            %
            load([pathname,filename],'equil');
            %
            lukeobj = iluke_equilstrings(lukeobj,equil);
            %
            lukeobj.equil.text.string = filename;%[pathname,filename];
            %
            status.equil = 1;
            status.ohm = 0;
            status.transpfaste = 0;
            status.ripple = 0;
            status.waves = 0;
            status.output = 0;
            status.data = 2;
            %
            lukeobj.lukeid.string = '';
            %
            action = 'equildisp';iluke_callbacks;
            %
        end  
        %
        clear sbase filestr filename pathname
        %
    case 'equilsave'
        %
        % saving EQUIL structure
        %
        sbase = 'EQUIL';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',equil.id,'.mat'];
        %
        [filename,pathname] = iputfile_jd(1,filestr,['Please provide the ',sbase,' file name'],filename);
        %
        %
        if filename ~= 0,
            %
            save([pathname,filename],'equil');
            %
            lukeobj.equil.text.string = filename;%[pathname,filename];
        end  
        %
    case 'equilclear'
        %
        % clearing equil structure
        %
        equil = '';
        status.equil = 0;
        %
    case 'equildisp'
        %
        % displaying equilibrium data
        %
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
        if isfield(external,'ohm'),
            external_ohm = external.ohm;
        else
            external_ohm = '';
        end
        %
        ohm = imake_ohm_jd(dkepath,lukeobj.tokamak.string,equil,external_ohm,workdir,lukeobj.infopanel.handle,select);
        %
        if isfield(ohm,'err'),
            lukeobj.infotext.string = {'Error creating ohm structure : ',ohm.err};
            ohm = '';
        else
            %
            lukeobj.ohm.text.string = '< not saved >';
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
            %
            lukeobj.lukeid.string = '';
            %
            action = 'ohmdisp';iluke_callbacks;
            %
        end  
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
        ohm = '';
        status.ohm = 0;
        %
        lukeobj.lukeid.string = '';
        %
        lukeobj = iluke_info(lukeobj,'output');% enable info display
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
        %transpfaste = imake_transp_jd(dkepath,lukeobj.tokamak.string,equil,external_transp,workdir,lukeobj.infopanel.handle,select);
        transpfaste = imake_transp_jd(dkepath,lukeobj.tokamak.string,equil,external_transp,workdir,true,select);
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
            %
            lukeobj.lukeid.string = '';
            %
            action = 'transpdisp';iluke_callbacks;
            %
        end  
        %
    case 'transpsave'
        %
        % saving transpfaste structure
        %
        sbase = 'TRANSP';
        filestr = [sbase,'_*.mat'];
        filename = [sbase,'_',equil.id,'_',ohm.id,'.mat'];
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
    case 'wavestructimport'
        %
        % creating wavestruct structure from external
        %
        lukeobj = iluke_info(lukeobj,'');% disable info display
        %
        select = struct;
        select.style = style;
        %
        launchs = imake_launch_jd(dkepath,lukeobj.tokamak.string,equil,external.wave,workdir,lukeobj.infopanel.handle,select);
        %
        for iw = 1:length(launchs);
            %
            wavestructs{end+1} = imake_wavestructs_jd(equil,launchs{iw});
            %
            lukeobj.wavestruct.select.value = length(wavestructs);
            %
        end
        %
        clear select launchs
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
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
        launchs = imake_launch_jd(dkepath,lukeobj.tokamak.string,equil,'',workdir,lukeobj.infopanel.handle,select);
        %
        wavestructs{end+1} = imake_wavestructs_jd(equil,launchs{1});
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
            launchs = imake_launch_jd(dkepath,lukeobj.tokamak.string,equil,spectrum,workdir,lukeobj.infopanel.handle,select);
            %
            if ~isempty(launchs),
                wavestructs{end+1} = imake_wavestructs_jd(equil,launchs{1});
                %   
                ngraphs = length(graphs);
                %
                graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,['spectrum for ',wavestructs{end}.id],'spectrum');
                %
                lukeobj.plot1.gindex = ngraphs + 1;
                %
                lukeobj.wavestruct.select.value = length(wavestructs);
                %
                clear ngraphs
                %
            else
                %
                iluke_cleangraphs(lukeobj.plot1.handle)
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
        wavestructs{iw} = iluke_launchmodify(wavestructs{iw},style);        
        %
        clear iw 
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
        clear iw
        %
    case 'c3postart'
        %
        % running C3PO for current or all wavestructs
        %
        wavesolverparam.clustermode.wave_solver_yp.scheduler.mode = str2double(lukeobj.wsparam.string);
        %
        [newwaves] = wave_distribution_yp(dkepath,wavesolverparam,wavestructs(iw));
        %
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
        lukeobj = iluke_info(lukeobj,'text');% enable info display
        %
    case 'wavemake'%'newwavemake'%
        %
        % show run luke pannel
        %
        lukeobj = iluke_info(lukeobj,'c3po');% enable c3po display
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
        wave = imake_wave_jd(dkepath,lukeobj.tokamak.string,equil,external_wave,workdir,lukeobj.infopanel.handle,select);
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
        nr_dep = 40;
        rho_disp = 0:0.1:1;
        ymask = NaN;
        xvar = 'p';
        %
        graph_wave_jd(equil,waves,nr_dep,opt,rho_disp,ymask,xvar);
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
    case 'lukerun'
        %
        % show run luke pannel
        %
        lukeobj = iluke_info(lukeobj,'luke');% disable info display
        %
        if isempty(job),
            lukeobj.runcheck.visible = 'off';
        end
        %
        if isempty(lukeobj.lukeid.string),
            %
            lukeobj.lukeid.string = make_luke_simulid_jd(equil,ohm,transpfaste,ripple,waves);
            %
        end
        %
    case 'lukeclear'
        %
        % clearing output structure
        %
        job = '';
        %
        status.output = 0;
        %
        lukeobj = iluke_info(lukeobj,'output');% enable info display
        %
    case 'lukedisp'
        %
        % displaying luke data
        %
        lukeobj.plot1.gindex = 0;
        lukeobj.plot2.gindex = 0;
        lukeobj.plot3.gindex = 0;
        %
        cleartags = {'luke'};
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
        graphs(end+1) = iluke_graphs(lukeobj.plot1.handle,2,'RF power profile','luke');
        graphs(end+1) = iluke_graphs(lukeobj.plot2.handle,1,'ohmic power profile','luke');
        graphs(end+1) = iluke_graphs(lukeobj.plot3.handle,1,'current profile','luke');
        %
        lukeobj.plot1.gindex = ngraphs + 1;
        lukeobj.plot2.gindex = ngraphs + 2;
        lukeobj.plot3.gindex = ngraphs + 3;
        %
        lukeobj.infotext.string = output.info.txt;
        %
    case 'lukestart'
        %
        % run luke
        %
        iluke_run;
        %
end
%
clear action
%
iluke_update;
%