function dispremoteprofiles(dkepath)
%
% displays remote profiles 
%
% INPUTS :
%
%   - dkepath :
%       o structure with field profilestr : read profiles from field
%       o 'script' : read profiles from path script corresponding to local profile
%       o otherwise : load dkepath from getappdata(0) (same as LUKE_PATH.mat)
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
nrem = length(dkepath.profilestr);
%
disp (' ')
info_dke_yp(2,['List of compatible remote profiles available from this computer',sourcestr])
disp(' ')
%
for irem = 1:nrem,
    info_dke_yp(4,['#',num2str(irem),' : ',dkepath.profilestr{irem}]);
end
disp(' ')
