function lukecvsupdate(dkepath,debugmode)
%
% This function updates LUKE and associated toolboxes remotely for the profiles stored
% in dkepath
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%
if nargin == 0,
    dkepath = '';
    debugmode = 0;  
elseif nargin == 1,
    debugmode = 0;  
end
%
if isempty(dkepath)
    dkepath = load_structures_yp('dkepath','','');
end
%
nrem = length(dkepath.remote);
%
disp (' ')
info_dke_yp(2,'List of remote profiles available :')
disp(' ')
%
iirem = 1;
%
for irem = 1:nrem-1,
    flag = 0;
    host0 = dkepath.remote(irem).host;
    for jrem = irem+1:nrem,
        host1 = dkepath.remote(jrem).host;
        scheduler = dkepath.remote(jrem).scheduler;
        if strcmp(host0,host1) && strcmp(scheduler,'direct'),
            remote_index(iirem) = jrem;
            iirem = iirem + 1;
            flag = 1;
            break
        end 
    end
    %
    if flag == 0, 
        remote_index(iirem) = irem;
        iirem = iirem + 1;
    end
end
%
remote_index = sort(unique(remote_index));

for irem = 1:length(remote_index),
    info_dke_yp(4,['#',num2str(irem),' : ',dkepath.profilestr{remote_index(irem)}]);
end
disp(' ')
%  
remlist = input_dke_yp('Please identify profiles to be updated',1:length(remote_index),[1;length(remote_index)]);
disp(' ')
%
remote = dkepath.remote(remote_index(remlist));
%
remote.debugmode = debugmode;
%
% ----------------------------
%
remotefunctions = {'select_LUKE_jd.m','load_remoteprofiles_jd.m','luke_root'};% update MatTools, MatRemote, and LUKE
%
display_mode = 3;% show detailed results
%
exclude = {'.mat','~','.mexa64','.mexglx','.mexmaci64','.o','.DS_Store'};
%
remotecvsupdate(remote,remotefunctions,display_mode,exclude)
%