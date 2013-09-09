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
            datasave.state = 'on';
            dataclear.state = 'on';
            datadisp.state = 'on';
            %
            tokamak.string = external.basestr;
            shotnum.string = external.shotnum;
            shotime.string = external.shotime;
            %
            datatext.string = '< not saved >';
            %
            infotext.string = datainfo;
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
            datasave.state = 'on';
            dataclear.state = 'on';
            datadisp.state = 'on';
            %
            tokamak.string = external.basestr;
            shotnum.string = external.shotnum;
            shotime.string = external.shotime;
            datatext.string = filename;%[pathname,filename];
            %
            infotext.string = datainfo;
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
            datatext.string = filename;%[pathname,filename];
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
        %
        equil = imake_equil_jd(dkepath,tokamak.string,'',external.equil,workdir,infopanel.handle,select);
        %
        if isfield(equil,'err'),
            infotext.string = {'Error creating equil structure : ',equil.err};
            equil = '';
        else
            equilsave.state = 'on';
            equilclear.state = 'on';
            equildisp.state = 'on';
            %
            datatext.string = '< not saved >';
            %
            infotext.string = equilinfo;
        end
        %
        set(infotext.handle,'visible','on');
        set(infostr.handle,'visible','on');
        %
        iluke_update;
        %
end
%
iluke_update;
%