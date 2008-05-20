function [selectname,pathname] = iputfile_jd(opt_gui,filterspec,message,presel);
%
if nargin < 4,
    presel = '';
end
%
if nargin < 3,
    message = 'Please select a file';
end
%
if nargin < 2,
    filterspec = '*';
end
%
if nargin < 1,
    opt_gui = 1;
end
%
if opt_gui == 1,
    %
    [selectname,pathname] = uiputfile(filterspec,message,presel);
    %
else
    %
    if ~isempty(presel),
        %
        if exist(presel,'dir'),
            pathname = presel;
            filename = '';
        else
            %
            ipath = max(find(presel(1:end-1) == '/'));
            %
            if isempty(ipath),
                pathname = [pwd,'/'];
                ipath = 0;
            else
                pathname = presel(1:ipath);
            end
            %
            filename = presel(ipath+1:end);
            %
            if ~exist(presel,'file') & ~exist(pathname,'dir'),
                %
                disp(['WARNING : the directory ''',pathname,''' does not exist.'])
                %
                pathname = [pwd,'/'];
                %
            end
            %
        end
        %
    else
        pathname = [pwd,'/'];
        filename = '';        
    end
    %
    spec = {};
    %
    if ~isempty(filterspec),
        if iscell(filterspec),
            filterspec = filterspec(:,1);
        else
            filterspec = {filterspec};
        end
        %
        iispec = 0;
        iistr = 1;
        for ispec = 1:length(filterspec),
            if iistr == 1,
                iispec = iispec + 1;
            end
            %
            istar = [0,find(filterspec{ispec} == '*'),length(filterspec{ispec})+1];
            %
            iistr = 0;
            for istr = 1:length(istar)-1,
                if istar(istr) + 1 <= istar(istr+1) - 1,
                    iistr = iistr + 1;
                    spec{iispec}{iistr} = filterspec{ispec}(istar(istr) + 1:istar(istr+1) - 1);
                end
            end
        end
    end
    %
    selectname = '';
    %
    while isempty(selectname);
        %
        files = dir(pathname);
        %
        isel = 0;
        select = {};
        %
        for ifile = 1:length(files),
            if files(ifile).isdir == 0,
                %
                sel = 1;
                %
                for ispec = 1:length(spec),
                    %
                    sel = 1;
                    %
                    for istr = length(spec{iispec}):-1:1,
                        istar = length(files(ifile).name) + 1;
                        istar = strfind(files(ifile).name(1:istar-1),spec{iispec}{istr});
                        if isempty(istar),
                            sel = 0;
                            break
                        end
                    end
                    %
                    if sel == 1,
                        break
                    end
                    %
                end                           
                %    
                if sel == 1,
                    select = [select,files(ifile).name];
                    if strcmp(files(ifile).name,filename),
                        isel = length(select);
                    end
                end
                %
            end
        end
        %
        disp(' ');
        %
        disp(['-----> Provide a file name in the directory ''',pathname,''' :'])
        %    
        if ~isempty(select),
            %
            disp(' ');
            %
            disp(['    -----> or overwrite one of the following existing files :']);
            %
            disp(' ');
            %
        end
        %
        for ifile = 1:length(select),
            disp(['[',num2str(ifile),'] : ',select{ifile}])
        end
        %
        disp(' ');
        disp('[0] Change directory');
        disp(' ');
        disp('[-1] Cancel');
        disp(' ');
        %
        if isel > 0,
            isel_new = input(['? [',num2str(isel),'] : '],'s');
        elseif ~isempty(filename),
            isel_new = input(['? [',filename,'] : '],'s');
        else
            isel_new = input(['? [-1] : '],'s');
        end
        %
        if ~isempty(str2num(isel_new)),
            isel_new = str2num(isel_new);
        end
        %
        if isempty(isel_new),
            if isel > 0,
                isel_new = isel;
            elseif ~isempty(filename),
                isel_new = filename;
            else
                isel_new = -1;
            end
        end
        %
        if ischar(isel_new),
            %
            selectname = isel_new;
            %
        elseif isel_new == -1,%cancel operation
            %
            selectname = 0;
            %
        elseif isel_new == 0,%change directory
            %
            pathname_new = igetdir_jd(0,message,pathname);
            %
            if pathname_new ~= 0,
                pathname = pathname_new;
            end
            %
        else
            if isnumeric(isel_new) & length(isel_new) == 1 & any(isel_new == 1:length(select));
                %
                selectname = select{isel_new};
                %
            else
                disp(['-----> Invalid option']);
            end
        end
        %
    end
end
        
