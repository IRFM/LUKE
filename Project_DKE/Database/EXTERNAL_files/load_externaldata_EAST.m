function external = load_externaldata_EAST(workdir,shotnum,shotime,t1,t2,opt_gui,dummy)
%
% This function loads data from EAST database
%
external = '';
%
%m_opt = input_dke_yp('Do you want to: (0) load data from database, (1) load data from files',0,[0,1],'',[1,1]);
%
if ~ischar(shotnum),shotnum = num2str(shotnum);end
if ~ischar(shotime),
    shotime = num2str(round(shotime));
else
    if ~isempty(strfind(shotime,'.')),
        shotime = shotime(1:strfind(shotime,'.')-1);
    end
end
%
while 1,
    if length(shotime) < 6,%six digits in EAST
        shotime = ['0',shotime];
    else
        break;
    end
end
%
external.equil = load([workdir,'/','jbdirections_',shotnum,'_',shotime,'.mat']);
display([' --> Ip direction is ',external.equil.jbdirections.Ip]);
display([' --> Bt direction is ',external.equil.jbdirections.Bt]);
%
external.equil.shotnum = shotnum;
external.equil.shotime = shotime;
%
external.equil.magnetic.eqdsk_path = [workdir,'/'];
external.equil.magnetic.eqdsk_file = ['g',shotnum,'.',shotime];;
%
external.equil.prof = load([workdir,'/','profiles_',shotnum,'_',shotime,'.mat']);
external.equil.prof.species = load([workdir,'/','species_',shotnum,'_',shotime,'.mat']);
%
if exist([workdir,'/','LH_antenna_2p45GHz_',shotnum,'_',shotime,'.mat']),external.wave.LH.antenna_2p45GHz = load([workdir,'/','LH_antenna_2p45GHz_',shotnum,'_',shotime,'.mat']);end
if exist([workdir,'/','LH_antenna_4p60GHz_',shotnum,'_',shotime,'.mat']),external.wave.LH.antenna_4p60GHz = load([workdir,'/','LH_antenna_4p60GHz_',shotnum,'_',shotime,'.mat']);end
%
if exist([workdir,'/','EC_mirror_140GHz_',shotnum,'_',shotime,'.mat']),external.wave.EC.mirror_140GHz = load([workdir,'/','EC_mirror_140GHz_',shotnum,'_',shotime,'.mat']);end
%
if exist([workdir,'/','vloop_',shotnum,'_',shotime,'.mat']),external.ohm = load([workdir,'/','vloop_',shotnum,'_',shotime,'.mat']);end
%
external.id = ['EAST_',shotnum,'_',shotime,'_',num2str(t1),'_',num2str(t2)];   
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
    isnan_jd(external,1),
end
%

