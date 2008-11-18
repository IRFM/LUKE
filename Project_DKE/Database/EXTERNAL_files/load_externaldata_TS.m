function external = load_externaldata_TS(workdir,shotnum,shotime,t1,t2)
%
% This function loads data from TS database
%
external = '';
basestr = 'TS';
%
addpath('/usr/local/sources_lib/matlab6');
%
if exist('tsbase','file') ~= 3,
    disp('-----> Access to the TS database is not granted.')
    disp('-----> You need the mex file tsbase in the matlab path.');
    return;
end
%
% circular equilibrium
%
xpoint(1) = 1;%Vertical position of the top X point
xpoint(2) = 0;%Horizontal position of the top X point
xpoint(3) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
xpoint(4) = 0;%Angle between the separatrix and the horizontal plane for the top X point (degree)
xpoint(5) = 1;%Vertical position of the bottom X point (always positive value)
xpoint(6) = 0;%Horizontal position of the bottom X point
xpoint(7) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
xpoint(8) = 0;%Angle between the separatrix and the horizontal plane for the bottom X point (degree)
%
while 1,
    certif_tprof = input_dke_yp('Enter a certification for ''tprof'' data: (-1) exit, 0 (no certification), 1, 2, 3, 4',0,{-1,0,1,2,3,4},'Invalid selection');
    if certif_tprof == -1,
        return
    end
    %
    [flag,ap,Rp,Zp,Bt,Ip,qmin,eq,qopt,Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,vloop] = load_tprof_tsbase_yp(shotnum,certif_tprof,str2num(shotime),t1,t2,basestr);
    if isempty(ap),%tprof data are not documented for this shot and this certification
        disp(['WARNING: ''tprof'' data do not exist for shot #',shotnum,' and certification ',int2str(certif_tprof),'. Please try another certification or exit.']);
        disp('WARNING: Contact T. Aniel or the CDIV for creating missing tprof data');
    else
        break
    end
end
%
while 1,
    certif_thyb = input_dke_yp('Enter a certification for ''thyb'' data: (-1) exit, 0 (no certification), 1, 2, 3, 4',0,{-1,0,1,2,3,4},'Invalid selection');
    if certif_thyb == -1,
        clear('LH');
        break
    end
    %
    [flag_LH,LH] = load_LH_tsbase_yp(shotnum,certif_thyb,str2num(shotime),t1,t2,basestr);
    if isempty(LH) || ~flag_LH,%thyb data are not documented for this shot and this certification
        disp(['WARNING: No ''thyb'' data do not exist for shot #',shotnum,' and certification ',int2str(certif_thyb),'. Please try another certification or exit.']);
    else        
        break
    end
end		
%
while 1,
    certif_tfce = input_dke_yp('Enter a certification for ''tfce'' data: (-1) exit, 0 (no certification), 1, 2, 3, 4',0,{-1,0,1,2,3,4},'Invalid selection');
    if certif_tfce == -1,
        clear('EC');
        break
    end
    %
    [flag_EC,EC] = load_EC_tsbase_yp(shotnum,certif_tfce,str2num(shotime),t1,t2,basestr);
    if isempty(EC) || ~flag_EC,,%tfce data are not documented for this shot and this certification
        disp(['WARNING: No ''tfce'' data do not exist for shot #',shotnum,' and certification ',int2str(certif_tfce),'. Please try another certification or exit.']);
    else
        break
    end
end		
%
% Data saved for irunluke
%
external.equil.shotnum = shotnum;
external.equil.shotime = shotime;
%
external.equil.magnetic.ap = ap;
external.equil.magnetic.Rp = Rp;
external.equil.magnetic.Zp = Zp;
external.equil.magnetic.Ip = Ip;
external.equil.magnetic.Bt = Bt;
external.equil.magnetic.qopt = qopt;
external.equil.magnetic.qmin_Rpap = qmin*Rp/ap;
external.equil.magnetic.eq = eq;
%
external.equil.magnetic.xpoint = xpoint;
%
external.equil.prof.Zi = Zi;
external.equil.prof.mi = mi;
external.equil.prof.fi = fi;
external.equil.prof.Te0 = Te0;
external.equil.prof.Tea = Tea;
external.equil.prof.eTe1 = eTe1;
external.equil.prof.eTe2 = eTe2;
external.equil.prof.ne0 = ne0;
external.equil.prof.nea = nea;
external.equil.prof.ene1 = ene1;
external.equil.prof.ene2 = ene2;
external.equil.prof.Ti0 = Ti0;
external.equil.prof.Tia = Tia;
external.equil.prof.eTi1 = eTi1;
external.equil.prof.eTi2 = eTi2;
external.equil.prof.Zeff0 = Zeff0;
external.equil.prof.Zeffa = Zeffa;
external.equil.prof.eZeff = eZeff;
external.equil.prof.xZeff = xZeff;
%
external.ohm.vloop = vloop;
%
if flag_LH,
    external.wave.LH = LH;
end
%
if flag_EC,
    external.wave.EC = EC;
end
%
external.id = ['TS_',shotnum,'_',shotime,'_',num2str(certif_tprof),'_',num2str(certif_thyb),'_',num2str(certif_tfce)];

