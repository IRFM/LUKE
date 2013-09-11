% callbacks script for iluke

datainfo = {'','Next step :',...
               '=========  ','',...
    '- "New" Equilibrium to create equilibrium from EXTERNAL structure'};

switch action
        %
    case 'datamake'
        %
        % importing external data
        %
        external = iload_externaldata_jd(dkepath);
        %
        if isfield(external,'err'),
            infotext.string = {'Error loading external data : ',external.err};
            external = '';
        else
            %
            tokamak.string = external.basestr;
            shotnum.string = external.shotnum;
            shotime.string = external.shotime;
            %
            lukeobj.data.text.string = '< not saved >';
            %
            infotext.string = datainfo;
            %
            status.external = 1;
            %
        end
        %
        iluke_update;
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
            tokamak.string = external.basestr;
            shotnum.string = external.shotnum;
            shotime.string = external.shotime;
            lukeobj.data.text.string = filename;%[pathname,filename];
            %
            infotext.string = datainfo;
            %
            status.external = 1;
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
    case 'equilmake'
        %
        % creating equilibrium structure
        %
        set(infotext.handle,'visible','off');
        set(infostr.handle,'visible','off');
        %
        select.style = style;
        %
        select.idequil = 1;
        select.disp = 1;
        select.print = 1;
        select.comp = 1;
        %
        equil = imake_equil_jd(dkepath,tokamak.string,'',external.equil,workdir,infopanel.handle,select);
        %
        if isfield(equil,'err'),
            infotext.string = {'Error creating equil structure : ',equil.err};
            equil = '';
        else
            %
            lukeobj.equil.text.string = '< not saved >';
            %
            infotext.string = equil.info.txt;
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
        set(infotext.handle,'visible','on');
        set(infostr.handle,'visible','on');
        %
    case 'equilload'
        %
        % loading external data
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
            tokamak.string = equil.tokamak;
            shotnum.string = equil.shotnum;
            shotime.string = equil.shotime;
            lukeobj.equil.text.string = filename;%[pathname,filename];
            %
            infotext.string = equil.info.txt;
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
    case 'equildisp'
        %
        % displaying equilibrium data
        %
        plot1.gindex = 0;
        plot2.gindex = 0;
        plot3.gindex = 0;
        %
        cleartags = {'equil'};
        %
        iluke_update;% initialize display
        %
        newgraph1_handle = axes('Parent',plot1.handle,'units','pixels','Position',graph_position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);% create new graphic objects with requested characteristics
        newgraph2_handle = axes('Parent',plot2.handle,'units','pixels','Position',graph_position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
        newgraph3_handle = axes('Parent',plot3.handle,'units','pixels','Position',graph_position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize); 
        %
        equilibrium_jd(equil,NaN,3,'linear',10,[newgraph1_handle,newgraph2_handle,newgraph3_handle],style);
        %   
        ngraphs = length(graphs);
        %
        graphs(end+1) = iluke_graphs(plot1.handle,1,'magnetic equilibrium','equil');
        graphs(end+1) = iluke_graphs(plot2.handle,2,'temperature and density','equil');% includes legend
        graphs(end+1) = iluke_graphs(plot3.handle,1,'effective charge','equil');
        %
        plot1.gindex = ngraphs + 1;
        plot2.gindex = ngraphs + 2;
        plot3.gindex = ngraphs + 3;
        %
end
%
iluke_update;
%