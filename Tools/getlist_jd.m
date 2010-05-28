function filenames = getlist_jd(filepath,filename)
%
% This function gets the list of files of the format 'filename' in the
% directory 'filepath'. 'filename' is a standard file name that can contain
% the character '*' to account for any string.
%
starloc = strfind(filename,'*');
%
if isempty(starloc),
    if exist([filepath,filename],'file'),
        filenames = {filename};
    else
        filenames = {};
    end
else
    %
    filelist = dir(filepath);
    nfiles = length(filelist);
    filenames = cell(1,nfiles);
    istr = ones(1,nfiles);
    %
    for ifile = 1:length(filelist),
        filenames{ifile} = filelist(ifile).name;
    end
    %  
    starloc = [0,starloc,length(filename) + 1];
    %
    for istar = 1:length(starloc)-1;
        %
        str = filename(starloc(istar)+1:starloc(istar+1)-1);
        %
        if isempty(str),
            continue
        end
        %
        nfiles = length(filenames);
        sel = true(1,nfiles);
        %
        for ifile = 1:nfiles,
            %
            istrloc = strfind(filenames{ifile}(istr(ifile):end),str);
            %
            if isempty(istrloc),
                sel(ifile) = false;
                continue
            else
                istr(ifile) = istr(ifile)+(istrloc-1)+length(str);
            end
            %
            if istar == 1 && istrloc(1) ~= 1,% file starts differ
                sel(ifile) = false;
            end
            %
            if istar == length(starloc)-1 && istr(ifile) <= length(filenames{ifile}),% file ends differ
                sel(ifile) = false;
            end
            %
        end
        %
        filenames = filenames(sel);
        istr = istr(sel);
        %
    end           
end
%
