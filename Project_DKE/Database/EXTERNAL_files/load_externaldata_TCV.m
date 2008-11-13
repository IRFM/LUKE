function external = load_externaldata_TCV(workdir,shotnum,shotime,t1,t2)
%
% This function loads data from TCV database
%
external = '';
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
eqdsk_path = [workdir,'/'];
%
eqdsk_file = ['eqdsk.',shotnum,'t',shotime];
%
laun = input('Vector of EC launchers to account for (ex: [1,3]) : ');
if isempty(laun) || ~isnumeric(laun) ,
    disp('-----> Invalid entry');
    return
end
%
launstr = '';
for il = 1:length(laun),
    launstr = [launstr,'_',num2str(laun(il))];
end
%
data_path = [workdir,'/'];
data_file = ['data_',basestr,'_',shotnum,'_',num2str(t1),'_',num2str(t2),launstr,'.mat'];
%
collect_parameters_for_luke(str2num(shotnum),t1,t2,laun,[data_path,data_file]);%load dhot parameters
%
% return structure equil
%
external.equil.shotnum = shotnum;
external.equil.shotime = shotime;
external.equil.magnetic.eqdsk_path = eqdsk_path;
external.equil.magnetic.eqdsk_file = eqdsk_file;
%
external.equil.prof = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign');
external.wave = load([data_path,data_file],'shot','laun','angles*');
external.ohm = load([data_path,data_file],'shot','vloop');
%
external.id = ['TCV_',shotnum,'_',shotime,'_L',launstr];
%


