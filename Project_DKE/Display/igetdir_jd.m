function [selectpath] = igetdir_jd(opt_gui,message,presel);
%
if opt_gui == 1,
    %
    selectpath = uigetdir(presel,message);
    selectpath = [selectpath,'/'];
    %
else
    %
    if ~isempty(presel),
        %
        if exist(presel,'dir'),
            pathname = presel;
        else
            %
            disp(['WARNING : the directory ''',pathname,''' does not exist.'])
            %
            pathname = [pwd,'/'];
            %
        end
        %
    else
        pathname = [pwd,'/'];
    end
    %
    selectpath = '';
    %
    while isempty(selectpath);
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
            if files(ifile).isdir == 1 & ~strcmp(files(ifile).name,'CVS'),
                %
                select = [select,files(ifile).name];
                %
                if strcmp(files(ifile).name,'.'),
                    isel_loc = length(select);
                elseif strcmp(files(ifile).name,'..'),
                    isel_back = length(select);
                end
                %
            end
        end
        %
        select_tmp = select;
        select_tmp([isel_loc,isel_back]) = [];
        select = [select([isel_loc,isel_back]),select_tmp];
        isel_loc = 1;
        isel_back = 2;
        %
        disp(' ');
        %
        disp(['-----> Select a subdirectory in the directory ''',pathname,''' :']);
        %
        disp(' ');
        %
        for ifile = 1:length(select),
            disp(['[',num2str(ifile),'] : ',select{ifile}])
        end
        %
        disp(' ');
        disp('[0] Create directory');
        disp(' ');
        disp('[-1] Cancel');
        disp(' ');
        %
        isel_new = input(['? [',num2str(isel_loc),'] : ']);
        %
        if isempty(isel_new),
            isel_new = isel_loc;
        end
        %
        if isel_new == -1,%cancel operation
            %
            selectpath = 0;
            %
        elseif isel_new == 0,%create directory
            %
            newdirname = input('-----> Name of new directory : ','s');
            %
            if ~isempty(newdirname),
                %
                mkdir([pathname,newdirname])%
                pathname = [pathname,newdirname,'/'];
            end
            %
        elseif isel_new == isel_back,%back one directory
            %
            pathname = pathname(1:max([1,find(pathname(1:end-1) == '/')]));
            %
        elseif isel_new == isel_loc,%this directory
            %
            selectpath = pathname;
            %
        else
            if isnumeric(isel) & length(isel) == 1 & any(isel_new == 1:length(select));
                %
                pathname = [pathname,select{isel_new},'/'];
                %
            else
                disp(['-----> Invalid option']);
            end
        end
        %
    end
end
        
