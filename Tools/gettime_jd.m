function filetime = gettime_jd(filename,filepath,test)
%
% This function returns a comparison-ready modification time for the input
% file in the input directory
%
if nargin < 3,
    test = false;
end
%
if nargin < 2,
    filepath = './';
end
%
files = dir(filepath);
filetime = 0;
%
for ifile = 1:length(files),
    if strcmp(files(ifile).name,filename),
        if isfield(files(ifile),'datenum'),
            filetime = files(ifile).datenum;
        else
            filetime = datenum(files(ifile).date);
        end
        return
    end
end
%
if test,
    error('The source file was not found')
end
