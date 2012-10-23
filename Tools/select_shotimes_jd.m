function [shotimes,isel] = select_shotimes_jd(str_before,str_after,path_simul,shotimes)
%
if nargin < 4,
    shotimes = {};
end
%
if nargin < 3,
    path_simul = './';
end
%
% list shot times
%
matlabfiles = what(path_simul);
dirshotimes = {};
if ~isempty(matlabfiles),
    matfiles = matlabfiles.mat;
    nfiles = length(matfiles);
    nstr = length(str_before);
    for imatfile = 1:nfiles,
        matfile = matfiles{imatfile};
        istr_before = strfind(matfile,str_before);
        istr_after = strfind(matfile,str_after);
        if ~isempty(istr_before) && ~isempty(istr_after),
            dirshotimes = [dirshotimes,matfile(istr_before+nstr:istr_after-1)];
        end
    end
end
%
%dirshotimes = unique(dirshotimes);
[dummy,isel] = unique(str2double(dirshotimes));dirshotimes = dirshotimes(isel);
%
% select shot times
%
if isempty(shotimes),% all shot times
    shotimes = dirshotimes;
    isel = NaN;
elseif iscell(shotimes),
    nshots = length(shotimes);
    isel = zeros(1,nshots);
    for ishotime = 1:nshots,
        if any(strcmp(shotimes{ishotime},dirshotimes))
            isel(ishotime) = 1;
        else
            disp(['WARNING : The data file for shot time ',shotimes{ishotime},' was not found'])
        end
    end
    isel = find(isel);
    shotimes = shotimes(isel); 
    %
else
    nshots = length(dirshotimes);
    iseldir = [];
    for ishotime = 1:nshots,
        t = str2num(dirshotimes{ishotime});
        if t >= shotimes(1) && t <= shotimes(2),
            iseldir = [iseldir,ishotime];
        end
    end
    shotimes = dirshotimes(iseldir);
    isel = NaN;    
end
