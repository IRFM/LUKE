function [selectname,pathname] = igetfile_jd(opt_gui,filterspec,message,presel,multiselect);
%
if nargin < 5,
    multiselect = 0;
end
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
    if multiselect == 0;
        %
        [selectname,pathname] = uigetfile(filterspec,message,presel);
        %
    else
        %
        [selectname,pathname] = uigetfile(filterspec,message,presel,'MultiSelect','on');
        %
    end
else
    %
    if ~isempty(presel),
        %
        if exist(presel,'dir'),
            pathname = presel;
            if pathname(end) ~= filesep,
                pathname = [pathname,filesep];
            end
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
            if ~exist(presel,'file'),
                if ~exist(pathname,'dir'),
                    %
                    disp(['WARNING : the directory ''',pathname,''' does not exist.'])
                    %
                    pathname = [pwd,'/'];
                    filename = '';
                    %
                else
                    %
                    disp(['WARNING : the file ''',filename,''' does not exist in directory ''',pathname,'''.'])
                    %
                    filename = '';
                    %
                end
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
            if iistr >= 1,
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
        disp(' ');
        %
        disp(message);
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
                    istar = length(files(ifile).name) + 1;
                    %
                    for istr = length(spec{ispec}):-1:1,
                        istar = strfind(files(ifile).name(1:istar-1),spec{ispec}{istr});
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
        if isempty(select),
            %
            disp(' ');
            disp(['-----> No file with requested format in the directory ''',pathname,''' :'])
            %
            isel_new = 0;
            %
        else                             
            %
            disp(' ');
            %
            if multiselect == 0;
                disp(['-----> Select a file from this list in the directory ''',pathname,''' :']);
            else
                disp(['-----> Select files from this list in the directory ''',pathname,''' :']);
            end
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
        isel_new = input(['? [',num2str(isel),'] : ']);
        %
        if isempty(isel_new),
            isel_new = isel;
        end
        %
        if isel_new == -1,%cancel operation
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
            if multiselect == 0 & isnumeric(isel_new) & length(isel_new) == 1 & any(isel_new == 1:length(select));
                %
                selectname = select{isel_new};
                %
            elseif multiselect == 1 & isnumeric(isel_new) & all(sum(isel_new(:)*(1./[1:length(select)]) == ones(length(isel_new),length(select)),2)),
                for iisel = 1:length(isel_new),
                    selectname{iisel} = select{isel_new(iisel)};
                end
            else
                disp(['-----> Invalid option']);
            end
        end
        %
    end
end
        
