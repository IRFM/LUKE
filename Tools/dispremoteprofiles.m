function [indexlist,profile_list] = dispremoteprofiles(dkepath,type,display_mode)
%
% displays remote profiles 
%
% INPUTS :
%
%   - dkepath :
%       o structure with field profilestr : read profiles from field
%       o 'script' : read profiles from path script corresponding to local profile
%       o otherwise : load dkepath from getappdata(0) (same as LUKE_PATH.mat)
%       o display_mode : display results or not in command window
%
if nargin >= 1 && isfield(dkepath,'profilestr');
    sourcestr = ' (from structure ''dkepath'')';
elseif nargin >= 1 && ischar(dkepath) && strcmp(dkepath,'script'),
    [dkepath,SelectedPathFileName] = load_dkepath_yp(1);
    dkepath = update_remote_jd(dkepath,NaN,0,0);
    sourcestr = [' (from ''',SelectedPathFileName,''')'];
elseif isappdata(0,'dkepath'),
    dkepath = getappdata(0,'dkepath');
    sourcestr = ' (from ''getappdata(0)'')';
else
    disp('WARNING : Cannot retrieve remote profiles')
    return
end
%
if nargin == 0
    type = '';
end
%
if nargin <= 3 && strcmp(type,'scheduler')
    %
    jj = 1;
    %
    for ii = 1:length(dkepath.profilestr)
        %
        if isempty(strfind(dkepath.profilestr{ii},'direct'))
            %
            profile_list{jj} = dkepath.profilestr{ii};
            indexlist(jj) = ii;
            jj = jj + 1;
            %
        end
        %
    end
    %
    nrem = jj - 1;
else
    nrem = length(dkepath.profilestr);
    profile_list = dkepath.profilestr;
    indexlist = [1:nrem];
end
%
if nargin < 3
    %
    display_mode = 1;
    %
end
%
if display_mode
    disp (' ')
    info_dke_yp(2,['List of compatible remote profiles available from this computer',sourcestr])
    disp(' ')
end
%
indexlist = [0,indexlist];
profile_list = [{'local calculations'},profile_list];
%
if display_mode
    disp('------------------------------------')
    info_dke_yp(4,'#0 : local calculations');
    disp('------------------------------------')
end
%
nrem = nrem + 1;
if display_mode
    for irem = 2:nrem,
        info_dke_yp(4,['#',num2str(indexlist(irem)),' : ',profile_list{irem}]);
    end
end
disp(' ')

