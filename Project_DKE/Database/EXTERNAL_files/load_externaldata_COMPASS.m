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
    external.dt = 0.05;
    %
    % description & user halp
    %
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    external.info.dt = 'time range for data averaging (s)';
    % 
    % expert mode
    %
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    external.expert.dt = 0;
    %
    % range of values
    %
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    external.values.dt1 = [0;Inf];
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
dt = external_in.dt;
%
% ******************************************************************
%
external = '';
basestr = 'COMPASS';
%
if exist('cdb_client','file') == 2,
    data = compass2luke(shotnum);
else
    [filename,pathname] = igetfile_jd(opt_gui,'*.mat',['Please select the COMPASS data file for shot # ',shotnum],'',0);
    %
    if filename ~= 0,
        load([pathname,filename],'data');
    else
        return
    end
end
%
% time average or selection
%
Vloop.t = data.U_loop.time_axis.data/1e3;% s
Vloop.data = data.U_loop.data;% V
%
Ip.t = data.I_plasma.time_axis.data/1e3;% s
Ip.data = data.I_plasma.data;% A
%
Li.t = data.int_inductance.time_axis.data;% s
Li.data = data.int_inductance.data;
%
delta.t = data.triangularity.time_axis.data/1e3;% s
delta.data = data.triangularity.data;
%
psiRZ.t = data.psi.time_axis.data/1e3;% s
psiRZ.data = data.psi.data;% Wb/rad
psiRZ.R = data.psi.axis1.data;% m
psiRZ.Z = data.psi.axis2.data;% m
%
pne.t = data.ne.time_axis.data/1e3;% s
pne.data = data.ne.data;% m^-3
pne.x = data.ne.axis1.data;% m
%
pTe.t = data.te.time_axis.data/1e3;% s
pTe.data = data.te.data/1e3;% keV
pTe.x = data.te.axis1.data;% m
%
% time average or selection
%
dx = dt/(2*sqrt(log(2)));% to set gaussian smoothing of width dt at half height
%
Vloop = smooth_jd(Vloop.t,Vloop.data,dx,shotime);
Ip = smooth_jd(Ip.t,Ip.data,dx,shotime);
Li = smooth_jd(Li.t,Li.data,dx,shotime);
delta = smooth_jd(delta.t,delta.data,dx,shotime);
%
xne = pne.x;
pne = smooth_jd(pne.t,pne.data,dx,shotime);
%
xTe = pTe.x;
pTe = smooth_jd(pTe.t,pTe.data,dx,shotime);
%
it = find(abs(psiRZ.t - shotime) == min(abs(psiRZ.t - shotime)),1,'first');
%
R = psiRZ.R(it,:);
Z = psiRZ.Z(it,:);
psiRZ = reshape(psiRZ.data(it,:,:),[length(R),length(Z)]);
%
% return structure external
%
external.basestr = basestr;
external.shotnum = num2str(shotnum);
external.shotime = shotime;
%
external.ohm.Vloop = Vloop;
%
external.equil.shotnum = external.shotnum;
external.equil.shotime = external.shotime;
%
external.equil.magnetic.Ip = Ip;
external.equil.magnetic.Li = Li;
external.equil.magnetic.delta = delta;
%
external.equil.magnetic.psiRZ = psiRZ;% Wb/rad
external.equil.magnetic.R = R;% m
external.equil.magnetic.Z = Z;% m
%
external.equil.prof.xne = xne;
external.equil.prof.xTe = xTe;
%
external.equil.prof.pne = pne;
external.equil.prof.pTe = pTe;
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


