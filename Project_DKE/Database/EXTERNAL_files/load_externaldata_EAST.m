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
filename = [workdir,'/','jbdirections_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.equil.jbdirections = fileread(filename);
    external.equil = load([workdir,'/','jbdirections_',shotnum,'_',shotime,'.mat']);
    display([' --> Ip direction is ',external.equil.jbdirections.Ip]);
    display([' --> Bt direction is ',external.equil.jbdirections.Bt]);
else
    error(['The file jbdirections_',shotnum,'_',shotime,'.mat is missing in the directory ',workdir]);
end
%
filename = [workdir,'/g',shotnum,'.',shotime];
%
if exist(filename,'file'),
    external.equil.magnetic.eqdsk = fileread(filename);
    external.equil.shotnum = shotnum;
    external.equil.shotime = shotime;
else
    error(['The file eqdesk g',shotnum,'.',shotime,' is missing in the directory ',workdir]);
end
%
filename = [workdir,'/','profiles_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.equil.prof = load([workdir,'/','profiles_',shotnum,'_',shotime,'.mat']);
else
    error(['The file profiles_',shotnum,'_',shotime,'.mat is missing in the directory ',workdir]);
end
%
filename = [workdir,'/','species_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.equil.prof.species = load([workdir,'/','species_',shotnum,'_',shotime,'.mat']);
else
    error(['The file species_',shotnum,'_',shotime,'.mat is missing in the directory ',workdir]);
end
%
filename = [workdir,'/','LH_antenna_2p45GHz_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.LH.antenna_2p45GHz = load([workdir,'/','LH_antenna_2p45GHz_',shotnum,'_',shotime,'.mat']);
else
    disp(['--> WARNING: The file LH_antenna_2p45GHz_',shotnum,'_',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'/','LH_antenna_4p60GHz_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.LH.antenna_4p60GHz = load([workdir,'/','LH_antenna_4p60GHz_',shotnum,'_',shotime,'.mat']);
else
    disp(['--> WARNING: The file LH_antenna_4p60GHz_',shotnum,'_',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'/','EC_mirror_140GHz_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.wave.EC.mirror_140GHz = load([workdir,'/','EC_mirror_140GHz_',shotnum,'_',shotime,'.mat']);
else
    disp(['--> WARNING: The file EC_mirror_140GHz_',shotnum,'_',shotime,'.mat does not exist in the directory ',workdir]);
end
%
filename = [workdir,'/','vloop_',shotnum,'_',shotime,'.mat'];
%
if exist(filename,'file'),
    external.ohm = load([workdir,'/','vloop_',shotnum,'_',shotime,'.mat']);
else
    disp(['--> WARNING: The file vloop_',shotnum,'_',shotime,'.mat does not exist in the directory ',workdir]);
end
%
if isempty(t1) && isempty(t2),
    external.id = ['EAST_',shotnum,'_',shotime]; 
else
    external.id = ['EAST_',shotnum,'_',shotime,'_',num2str(t1),'_',num2str(t2)];  
end
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
    isnan_jd(external,1),
end
%
