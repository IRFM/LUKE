% callbacks script for iluke

switch action
        %
    case 'dataimport'
        %
        % importing external data
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
            lukeobj.infotext.string = infostrs.data;
            %
            status.external = 1;
            %
            status.equil = 0;
            %
        end
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
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
            lukeobj.infotext.string = infostrs.data;
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
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
            lukeobj.infotext.string = equil.info.txt;
            %
            status.equil = 1;
            status.ohm = 0;
            status.transpfaste = 0;
            status.ripple = 0;
            status.waves = 0;
            status.output = 0;
            status.data = 2;
            %
        end
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
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
            lukeobj.tokamak.string = equil.tokamak;
            lukeobj.shotnum.string = equil.shotnum;
            lukeobj.shotime.string = equil.shotime;
            lukeobj.equil.text.string = filename;%[pathname,filename];
            %
            lukeobj.infotext.string = equil.info.txt;
            %
            status.equil = 1;
            status.ohm = 0;
            status.transpfaste = 0;
            status.ripple = 0;
            status.waves = 0;
            status.output = 0;
            status.data = 2;
        end  
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
    case 'ohmmake'
        %
        % creating ohmic structure
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
            lukeobj.infotext.string = ohm.info.txt;
            %
            status.ohm = 1;
            status.data = 2;
            %
        end
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
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
            lukeobj.infotext.string = ohm.info.txt;
            %
            status.ohm = 1;
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
    case 'transpmake'
        %
        % creating transpfaste structure
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
            lukeobj.infotext.string = transpfaste.info.txt;
            %
            status.transpfaste = 1;
            status.data = 2;
            %
        end
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
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
            lukeobj.infotext.string = transpfaste.info.txt;
            %
            status.transpfaste = 1;
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
    case 'wavemake'
        %
        % creating wave structure
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
        end
        %
        if ~isempty(waves),
            lukeobj.wave.text.string = [num2str(length(waves)),' wave structures'];
            lukeobj.infotext.string = iluke_waveinfo(waves);
        end
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
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
        end
        %
        if ~isempty(waves),
            lukeobj.wave.text.string = [num2str(length(waves)),' wave structures'];
            lukeobj.infotext.string = iluke_waveinfo(waves);
        end
        %
    case 'wavesave'
        %
        % saving wave structure
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
        %
    case 'waveclear'
        %
        % clearing wave structure
        %
        set(lukeobj.infotext.handle,'visible','off');
        set(lukeobj.infostr.handle,'visible','off');
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
        lukeobj.infotext.string = iluke_waveinfo(waves);
        %
        set(lukeobj.infotext.handle,'visible','on');
        set(lukeobj.infostr.handle,'visible','on');
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
end
%
iluke_update;
%