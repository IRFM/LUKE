function external = load_externaldata_TCV(workdir,shotnum,shotime,t1,t2,opt_gui)
%
% This function loads data from TCV database
%
external = '';
basestr = 'TCV';
%
m_opt = input_dke_yp('Do you want to: (0) load data from database, (1) load data from files',0,[0,1],'',[1,1]);
%
eqdsk_path = [workdir,'/'];
%
eqdsk_file = ['eqdsk.',shotnum,'t',shotime];
%
data_path = [workdir,'/'];
%
data_str = ['data_',basestr,'_',shotnum,'_',num2str(t1),'_',num2str(t2)];
%
if m_opt == 0,
    %
    if ~exist('make_eqdsk.m','file'),
        disp('-----> Access to the TCV database is not granted.');
        disp('-----> You need the file make_eqdsk.m in the matlab path.');
        return;
    end
    %
    if ~exist('collect_parameters_for_luke.m','file'),
        disp('-----> Access to the TCV database is not granted.');
        disp('-----> You need the file collect_parameters_for_luke.m in the matlab path.');
        return;
    end
    %
    l_opt = input('Option for liuqe version? (1,2,3) [1] : ');
    if isempty(l_opt),
        l_opt = 1;
    elseif ~isnumeric(l_opt) || ~any(l_opt == 1:3),
        return
    end
    %
    make_eqdsk(str2num(shotnum),str2num(shotime),workdir,'TCV',l_opt);%call LIUQUE
    %
    laun = input('Vector of EC launchers to account for (ex: [1,3]) : ');
    if isempty(laun) || ~isnumeric(laun) ,
        disp('-----> Invalid entry');
        return
    end
    %
    f_opt = input_dke_yp('Do you want to: (0) load Te from fitted Thomson only, (1) load Te with Xte renormalization',0,[0,1],'',[1,1]);
    %
    launstr = '';
    for il = 1:length(laun),
        launstr = [launstr,'_',num2str(laun(il))];
    end
    %
    data_path = [workdir,'/'];
    data_file = [data_str,launstr,'.mat'];
    %
    collect_parameters_for_luke(str2num(shotnum),t1,t2,laun,[data_path,data_file],f_opt);%load dhot parameters
    %
else
    %
    [eqdsk_file,eqdsk_path] = igetfile_jd(opt_gui,eqdsk_file,'Please select the EQDSK file',[eqdsk_path,eqdsk_file]);
    if eqdsk_file == 0,
        return
    end
    %
    data_file = [data_str,'*.mat'];
    %
    [data_file,data_path] = igetfile_jd(opt_gui,data_file,'Please select the data file',[data_path,data_file]);
    if data_file == 0,
        return
    end
    %
    i1 = length(data_str);
    i2 = strfind(data_file,'.mat');
    %
    launstr = data_file(i1+1:i2-1);
    %
end
%
% return structure equil
%
external.equil.shotnum = shotnum;
external.equil.shotime = shotime;
external.equil.magnetic.eqdsk_path = eqdsk_path;
external.equil.magnetic.eqdsk_file = eqdsk_file;
%
external.equil.prof = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign','teflag');
external.equil.prof.data_path = data_path;
external.equil.prof.data_file = data_file;
external.wave = load([data_path,data_file],'shot','laun','angles*');
external.ohm = load([data_path,data_file],'shot','vloop');
%
external.id = ['TCV_',shotnum,'_',shotime,'_',num2str(t1),'_',num2str(t2),'_L',launstr];
%
if m_opt == 0,
    %
    s_opt = input_dke_yp('Do you want to generate an equivalent make_external_TCV script? [y/n]','n',{'y','n'},'',[1,1]);
    %
    if s_opt == 'y',
        % 
        imake_makeexternal_TCV_jd(workdir,external,opt_gui);
        %
    end
end    
%


