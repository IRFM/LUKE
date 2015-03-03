function external = load_externaldata_COMPASS(external_in,opt_gui)
%
% This function loads data from COMPASS database
%
% INPUTS : 
%   - if nargin == 0, return default external_in to be modified interactively in iload_externaldata_jd

%   - external_in : input structure.
%   - opt_gui     : option for GUI within function (interactive mode only)
%       
%
if nargin == 0,
    %
    % default values
    %
    external.shotnum = 0;
    external.shotime = 0;
    %
    % description & user halp
    %
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    % 
    % expert mode
    %
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    %
    % range of values
    %
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    %
    return
    %
end
%
if nargin < 2,
    opt_gui = false;
end
%
shotnum = external_in.shotnum;
shotime = external_in.shotime;
%
% ******************************************************************
%
external = '';
basestr = 'COMPASS';
%
if exist('cdb_client','file') == 2,
    %
    data_out = compass2luke(shotnum);
    %
else
    [filename,pathname] = igetfile_jd(opt_gui,'*.mat',['Please select the COMPASS data file for shot # ',shotnum],'',0);
    %
    if filename ~= 0,
        load([pathname,filename],'data_out');
    else
        disp(' ');disp('--> Read remotely from COMPASS database');disp(' ');
        [remote,profilestr] = load_remoteprofiles_jd('IPP_ABACUS',false,true,'direct',NaN,true);%read remotely from COMPASS database 
        [err_data,~,data_out] = matremote_jd('compass2luke',{shotnum},remote,matstandardjob_jd('runmat'));        
        %
        if err_data ~= 0,
            return
        end
    end
end
%
if shotime == 0,% EFIT time grid reference, if shotime is not specified
    ishotime = round(length(data_out.int_inductance.time_axis.data)/2);
    shotime = data_out.int_inductance.time_axis.data(ishotime);
    disp(' ');disp(['WARNING: The shot time has been enforced to ',num2str(shotime),' (s)']);disp(' ');
else,%nearest value
    ishotime = interp1(data_out.int_inductance.time_axis.data,[1:length(data_out.int_inductance.time_axis.data)],shotime,'nearest')
    shotime = data_out.int_inductance.time_axis.data(ishotime);
    disp(' ');disp(['WARNING: The nearest shot time is ',num2str(shotime),' (s)']);disp(' ');
end
%
% time average or selection
%
Li.t = data_out.int_inductance.time_axis.data(ishotime);% s
Li.data = data_out.int_inductance.data(ishotime);
delta.t = data_out.triangularity.time_axis.data(ishotime)/1e3;% ms -> s
delta.data = data_out.triangularity.data(ishotime);
psiRZ.t = data_out.psi.time_axis.data(ishotime)/1e3;% ms -> s
psiRZ.data = data_out.psi.data(ishotime,:,:);% Wb/rad
psiRZ.R = data_out.psi.axis1.data(ishotime,:);% m 
psiRZ.Z = data_out.psi.axis2.data(ishotime,:);% m
%
pne.t = shotime;
pne.data = interp1(data_out.ne.time_axis.data/1e3,data_out.ne.data,shotime,'linear');% m^-3
pne.x = data_out.ne.axis1.data;% m
pTe.t = shotime;
pTe.data = interp1(data_out.te.time_axis.data/1e3,data_out.te.data/1e3,shotime,'linear');% keV
pTe.x = data_out.te.axis1.data;% m
%
Vloop.t = shotime;
Vloop.data = interp1(data_out.U_loop.time_axis.data/1e3,sgolayfilt(data_out.U_loop.data, 1,min(2*round(length(data_out.U_loop.time_axis.data)/400)-1,10001)),shotime,'linear');% V
%close all,plot(data_out.U_loop.time_axis.data/1e3,data_out.U_loop.data,'b',data_out.U_loop.time_axis.data/1e3,sgolayfilt(data_out.U_loop.data, 1,min(2*round(length(data_out.U_loop.time_axis.data)/400)-1,10001)),'r')
Ip.t = shotime;
Ip.data = interp1(data_out.I_plasma.time_axis.data/1e3,sgolayfilt(data_out.I_plasma.data, 1,min(2*round(length(data_out.I_plasma.time_axis.data)/400)-1,10001)),shotime,'linear');% A
%close all,plot(data_out.I_plasma.time_axis.data/1e3,data_out.I_plasma.data,'b',data_out.I_plasma.time_axis.data/1e3,sgolayfilt(data_out.I_plasma.data, 1,min(2*round(length(data_out.I_plasma.time_axis.data)/400)-1,10001)),'r')
%
% return structure external
%
external.basestr = basestr;
external.shotnum = num2str(shotnum);
external.shotime = shotime;
%
external.ohm.Vloop = Vloop.data;
%
external.equil.shotnum = external.shotnum;
external.equil.shotime = external.shotime;
%
external.equil.magnetic.Ip = Ip.data;
external.equil.magnetic.efit.Li = Li.data;
external.equil.magnetic.efit.delta = delta.data;
%
external.equil.magnetic.efit.psiRZ = reshape(psiRZ.data,[length(psiRZ.R),length(psiRZ.Z)]);% Wb/rad
external.equil.magnetic.efit.R = psiRZ.R;% m
external.equil.magnetic.efit.Z = psiRZ.Z;% m
%
external.equil.prof.xne = pne.x;
external.equil.prof.xTe = pTe.x;
%
external.equil.prof.pne = pne.data;
external.equil.prof.pTe = pTe.data;
%
external.equil.prof.fi = [0,1,0];
external.equil.prof.zZi = [1,1,1,6];
external.equil.prof.zmi = [1,2,3,12];
%
external.id = ['COMPASS_',external.shotnum,'_',num2str(shotime,'%6.4f')];
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
end
%


