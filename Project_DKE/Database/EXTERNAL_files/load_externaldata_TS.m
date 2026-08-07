% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function external = load_externaldata_TS(external_in,opt_gui)
%
% This function loads data from TS database
%
if nargin == 0
    %
    % default values
    %
    external.shotnum = 0;
    external.shotime = 0;
    external.t1 = 0;
    external.t2 = 0;
    %
    % description & user halp
    %
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    external.info.t1 = '';
    external.info.t2 = '';
    % 
    % expert mode
    %
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    external.expert.t1 = 0;
    external.expert.t2 = 0;
    %
    % range of values
    %
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    external.values.t1 = [0;Inf];
    external.values.t2 = [0;Inf];
    %
    return
    %
end
%
%
shotnum = external_in.shotnum;
shotime = external_in.shotime;
t1 = external_in.t1;
t2 = external_in.t2;
%
if nargin < 2,
    opt_gui = false;
end
%
if isempty(t1) || isempty(t2)
    t1 = shotime;
    t2 = shotime;
end
%
external = '';
basestr = 'TS';
%
if exist('remote_tsbase','file') ~= 2,
    disp('-----> Access to the TS database is not granted.')
    disp('-----> You need remote_tsbase.m script for access to TS tokamak database.');
    return;
end
%
% Since tprof tool is no more supported, METIS is used as interface to load data from TS database and process missing data. Post is then read by LUKE
%
%[post,tprofok] = autoTSmetis(shot,gas,time,filename,tprofonoff)
% shot = shot number [5877,48361]
% gas  = 1 = D & 2 = He, if isempty or missing switch to automatic selection.
% time = time slices for calculation. If isempty or missing, use default time slices vector of METIS. If is scalar, compute steady state solution for this selected time.
% filename = optionnal file name in which METIS data are saved (without extension .mat).
%tprofonoff = optional control of TPROF use. If = 0, METIS will run without TPROF profiles even if some TPROF run exist.
%
%post = standard METIS data structure
%tprofok = flag set to 1 if TPROF data are used
%
[post,tprofok] = remote_autoTSmetis(shotnum);
%
[dkeparam,dkedisplay,equil,ohm,transpfaste,ripple,wavestructs] = auto_extract_metisdata_for_luke(post,shotime);
%
%if ~isfield(dkeparam,'rho_S') && isfield(data,'par') && isfield(data.par,'rho_S'),
%    dkeparam.rho_S = par.rho_S;
%end
%     
external.basestr = basestr;
external.shotnum = shotnum;
external.shotime = shotime;
external.t1 = t1;
external.t2 = t2;
%
external.post = post;%METIS data
external.tprofok = tprofok;%METIS data
%
external.equil = equil;
external.equil.shotnum = shotnum;
external.equil.shotime = shotime;
if isfield(equil,'ADAS') && length(equil.ADAS) >0
    save(['EQUIL_TS_',int2str(shotnum),'_',num2str(shotime),'_ADAS'],'equil');
else
    save(['EQUIL_TS_',int2str(shotnum),'_',num2str(shotime)],'equil');
end
%
external.dkeparam = dkeparam;
%
external.dkedisplay = dkedisplay;
%
external.ohm = ohm;
%
external.transpfaste = transpfaste;
%
external.ripple = ripple;
%
external.wave.wavestructs = wavestructs;
%
% Load LH wave parameters for ALOHA calculations
%
[flag_LH,LH] = load_LH_tsbase_yp(basestr,shotnum,shotime,t1,t2);
%
if flag_LH
    external.wave.LH = LH;
    disp(['''LH'' data have been well loaded for shot #',int2str(shotnum),'.']);
else
    disp(['WARNING: ''LH'' data have not been loaded for shot #',int2str(shotnum),'.']);
end
%
if flag_LH
    external.id = ['TS_',int2str(shotnum),'_',int2str(shotime),'_ALOHA'];
else
    external.id = ['TS_',int2str(shotnum),'_',int2str(shotime)];
end
%


