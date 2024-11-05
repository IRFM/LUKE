function [ydate]= remote_tsdate(shotnumber)
%
%LUKE -  Function which load shot date from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%
%   Output:
%
%		ydate: shot date (if only shot number is given, it answers the shot date)
%
%NOTE : data are save in a file place in a folder whose path is defined by the environment variable 'EXPERIMENTAL_TOKAMAK_DATA'. This variable must
%be defined in the startup file startup.m -> setenv('EXPERIMENTAL_TOKAMAK_DATA','**************')
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if ~ismember('mute_remote_tsdate', who('global'))
    mute_remote_tsdate = 0;
else
    global mute_remote_tsdate
end
%
ydate = [];
%
if nargin < 1,
     error('Not enough input argument in remote_tsdate.m');
end
%
datapath = getenv('EXPERIMENTAL_TOKAMAK_DATA');%folder path
%
if isempty(datapath)
    %
    warning('The environment variable EXPERIMENTAL_TOKAMAK_DATA must be set in the startup.m file. Otherwise, data are stored locally')
    %
end
%
if ~exist(datapath)
    %
    mkdir(datapath);
    %
end
%
if exist([datapath,'tsdate_',int2str(shotnumber),'.mat'])
    %
    load([datapath,'tsdate_',int2str(shotnumber),'.mat'],'data');
    %
    ydate = data.ydate;
    %
    return
    %
end
%
remote = remote_cea;
%
if isstruct(remote)
    %
    [err,txt] = unix('hostname');
    txt = deblank(txt);
    %
    if ~isempty(strfind(txt,'partenaires')) || ~isempty(strfind(txt,'intra'))
        %
        [ydate] = tsdate(shotnumber);
        %
    else
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ')
        %
        remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,ydate] = matremote_jd('tsdate',{shotnumber},remote,job);
        %
    end
    %
else
    %
    if isempty(remote)
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    else
        %
        [ydate] = tsdate(shotnumber);
        %
    end
    %
end 
%
if length(ydate) > 10
    %
    ydate = ydate(1:10);%remove possible spurious ending char
    %
end
%
data.ydate = ydate;
%
save([datapath,'tsdate_',int2str(shotnumber),'.mat'],'data');
%
if isempty(ydate)
    %
    disp(['WARNING : tsdate signal of discharge #',int2str(shotnumber),' is empty.'])
    %
end