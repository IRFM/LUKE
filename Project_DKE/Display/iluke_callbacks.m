% callbacks script for iluke

switch action
    %
    case 'datamake'
        %
        % importing external data
        %
        external = iload_externaldata_jd(dkepath);
        %
        if isfield(external,'err'),
            infotext.string = {'Error laoding external data : ',external.err};
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
end
%
iluke_update;
%