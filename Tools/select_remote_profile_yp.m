function remnum = select_remote_profile_yp(remprofile,dkepath)
% LUKE - Select a remote profile if available by a chain of char 
%
%	Select a remote profile if available by a chain of char 
%
%	Input:
%
%       - remprofile: chain of caracter that allows to identify the remote
%       - dkepath: structure for the paths
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat)
%
%	Output:
%
%       - remnum : selected remote number [1,1]
%
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
if nargin == 0, 
    remprofile = '';
    dkepath = '';
end
%
if nargin == 1, 
    dkepath = '';
end
%
if isempty(dkepath) || ~isstruct(dkepath),
    dkepath = load_structures_yp('dkepath','','');
end
%
if ~isempty(remprofile),
    %
    if strfind(remprofile,'local'),
         remnum = 0;%local calculation
    else
        %
        remlist = [];
        %
        for irem = 1:length(dkepath.remote),
            if strfind(dkepath.remote(irem).host,remprofile),
                remlist = [remlist,irem];
            end
        end
        %
        if isempty(remlist),
            disp(['WARNING: no remote profile for ''',remprofile,'''']);
            disp(['---> Interactive choice enforced for choosing the remote profile']);
            remlist = [];
        end
        %
    end
else
    remlist = [];
end
%
if exist('remlist','var')
    %
    flag_remote = check_remote_yp(dkepath,remlist,0,'');
    %
    if ~isempty(find([1:length(flag_remote)].*flag_remote > 0)),
        if isempty(remlist), remlist = 1:length(flag_remote);end
        remnum = remlist(input_dke_yp('Please identify the profile to be used for the simulation.',find(remlist.*flag_remote > 0),find(remlist.*flag_remote > 0)));
    else
        remnum = 0;%local calculation
        disp('WARNING: Local calculation enforced.');
    end
end