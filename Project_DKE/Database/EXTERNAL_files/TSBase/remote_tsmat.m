function [yout1,yout2,yout3,yout4,yout5]= remote_tsmat(shotnumber,signal)
%
%LUKE -  Function which load signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		signal : type of signal (ex: 'gphyb')
%
%   Output:
%
%       yout1: signal vector 1 
%       yout2: signal vector 2 (may be time vector)
%       yout3: signal vector 3 (may be time vector or empty)
%       yout4: signal vector 4 (may be time vector or empty)
%       yout5: signal vector 5 (may be time vector or empty)
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
yout1 = [];
yout2 = [];
yout3 = [];
yout4 = [];
yout5 = [];
%
if nargin < 2,
     error('Not enough input argument in remote_tsmat.m');
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
signal = lower(signal);%enforce lower case
%
if exist([datapath,'tsmat_data_',int2str(shotnumber),'_',signal,'.mat'])
    %
    load([datapath,'tsmat_data_',int2str(shotnumber),'_',signal,'.mat'],'data');
    %
    yout1 = data.yout1;
    yout2 = data.yout2;
    yout3 = data.yout3;
    yout4 = data.yout4;
    yout5 = data.yout5;
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
        [yout1,yout2,yout3,yout4,yout5] = tsmat(shotnumber,signal);
        %
    else
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
        %
        remote.matver.matdef = remote.matver.mat913;%enforce Matlab R2013b for tsbase only
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,yout1,yout2,yout3,yout4,yout5] = matremote_jd('tsmat',{shotnumber,signal},remote,job);
        %
    end
else
    %
     if isempty(remote)
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    else
        %
        [yout1,yout2,yout3,yout4,yout5] = tsmat(shotnumber,signal);
        %
    end
    %
end 
%
data.yout1 = yout1;
data.yout2 = yout2;
data.yout3 = yout3;
data.yout4 = yout4;
data.yout5 = yout5;
%
save([datapath,'tsmat_data_',int2str(shotnumber),'_',signal,'.mat'],'data');
%
if isempty(yout1)
    %
    disp(['WARNING : tsmat signal ''',signal,''' for discharge #',int2str(shotnumber),' is empty.'])
    %
end
