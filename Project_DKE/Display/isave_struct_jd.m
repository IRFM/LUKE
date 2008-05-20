function [spath,sfile] = isave_struct_jd(s,sname,sbase,sid,workdir,opt_gui)
%
if nargin < 6,
    opt_gui = 1;
end
if nargin < 5,
    workdir = pwd;
end
if nargin < 5,
    sid = '';
end
if nargin < 3,
    sbase = '';
end
if nargin < 2,
    error('No structure name specified');
end
%
if isempty(sbase),
    filestr = '*.mat';
else
    filestr = [sbase,'_*.mat'];
end
%
sfile = '';
spath = '';
%
s_opt = input_dke_yp(['Do you want to save the structure ''',sname,''' separately (y/n)'],'n',{'y','n'});
if strcmp(s_opt,'y'),
    sd = pwd;
    cd(workdir);
    %
    if ~isempty(sbase) && ~isempty(sid),
        filename = [sbase,'_',sid,'.mat'];
    elseif ~isempty(sbase) && isempty(sid),
        filename = [sbase,'.mat'];
    elseif isempty(sbase) && ~isempty(sid),
        filename = [sid,'.mat'];
    else
        filename = '';
    end
    %
    [filename,pathname] = iputfile_jd(opt_gui,filestr,['Please provide the ',sbase,' file name'],filename);
    %
    if filename == 0,
        disp(['-----> No file name specified, ''',sname,''' structure not saved.'])
    else
        %
        eval([sname,' = s;'])
        save([pathname,filename],sname);
        disp(['-----> The structure ''',sname,''' is saved in file ',pathname,filename])
        %
        sfile = filename;
        spath = pathname;
    end  
    cd(sd);
end
