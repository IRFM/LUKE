function s = iload_struct_jd(sname,sbase,workdir,opt_gui,opt_multi,opt_id)
%
if nargin < 6,
    opt_id = 1;
end
if nargin < 5,
    opt_multi = 0;
end
if nargin < 4,
    opt_gui = 1;
end
if nargin < 3,
    workdir = pwd;
end
if nargin < 2,
    sbase = '';
end
if nargin < 1,
    error('No structure name specified');
end
%
s = [];
%
if isempty(sbase),
    filestr = '*.mat';
else
    filestr = [sbase,'_*.mat'];
end
%
l_opt = input_dke_yp(['Do you want to load an existing structure ''',sname,''' (y/n)'],'n',{'y','n'});
if strcmp(l_opt,'y'),
    [filename,pathname] = igetfile_jd(opt_gui,filestr,['Please select the ',sbase,' file(s)'],workdir,opt_multi);
    %
    if ~iscell(filename) && all(filename == 0),
        disp('-----> No structure specified.')
    else
        %
        if opt_multi == 0,
            %
            load([pathname,filename],sname);
            eval(['s = ',sname,';']);
            disp(['-----> The structure ''',sname,''' is loaded from file ',pathname,filename])
            s.info.file = [pathname,filename];
            s = checkid(s,opt_id);
            %
        else
            %
            while iscell(filename) || filename ~= 0,
                %
                if iscell(filename) == 0,
                    %
                    load([pathname,filename],sname);
                    eval(['s = [s,{',sname,'}];']);
                    disp(['-----> The structure ''',sname,''' is loaded from file ',pathname,filename])
                    s{end}.info.file = [pathname,filename];
                    s{end} = checkid(s{end},opt_id);
                    %
                else
                    %
                    for ic = 1:length(filename),
                        %
                        load([pathname,filename{ic}],sname);
                        eval(['s = [s,{',sname,'}];']);
                        disp(['-----> The structure ''',sname,''' is loaded from file ',pathname,filename{ic}])
                        s{end}.info.file = [pathname,filename];
                        s{end} = checkid(s{end},opt_id);
                        %
                    end
                end
                %
                [filename,pathname] = igetfile_jd(opt_gui,filestr,['Please select additional ',sbase,' files (cancel if finished)'],workdir,opt_multi);
                %
            end
        end
    end  
end
%
function s = checkid(s,opt_id)
%
if opt_id && ~isfield(s,'id'),
    s.id = input_dke_yp(['Please provide an id for this structure'],'','');
end
%




