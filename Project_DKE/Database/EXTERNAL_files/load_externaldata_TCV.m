function external = load_externaldata_TCV(external_in,opt_gui)
%
% This function loads data from TCV database
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
    external.workdir = '';
    external.shotnum = 0;
    external.shotime = 0;
    external.t1 = 0;
    external.t2 = 0;
    %
    external.opt_file = false;
    external.liuqe = 1;
    external.launchers = 1:6;
    external.Xte = false;
    external.script = false;
    %
    % description & user halp
    %
    external.info.workdir = 'tmp directory for files saved by ''liuque'' and  ''collect_parameters_for_luke''';
    external.info.shotnum = 'Shot number';
    external.info.shotime = 'Shot time (s)';
    external.info.t1 = 'Minimum time for data averaging (s)';
    external.info.t2 = 'Maximum time for data averaging (s)';
    %
    external.info.opt_file = 'data source : (false) load data from database; (true) load data from existing files';
    external.info.liuqe = 'Option for liuqe version (1,2,3)';
    external.info.launchers = 'List of gyrotrons for ECRH data (1->9)';
    external.info.Xte = 'Te profile : (false) thomson scattering only; (true) renormalize TS profiles with Xte';
    external.info.script = 'generate an equivalent make_external_TCV script : (false) no (true) yes';
    % 
    % expert mode
    %
    external.expert.workdir = 0;
    external.expert.shotnum = 0;
    external.expert.shotime = 0;
    external.expert.t1 = 0;
    external.expert.t2 = 0;
    %
    external.expert.opt_file = 1;
    external.expert.liuqe = 1;
    external.expert.launchers = 1;
    external.expert.Xte = 1;
    external.expert.script = 1;
    %
    % range of values
    %
    external.values.workdir = '';
    external.values.shotnum = [0;Inf];
    external.values.shotime = [0;Inf];
    external.values.t1 = [0;Inf];
    external.values.t2 = [0;Inf];
    %
    external.values.opt_file = {true,false};
    external.values.liuqe = 1:3;
    external.values.launchers = [0;9];
    external.values.Xte = {true,false};
    external.values.script = {true,false};
    %
    return
    %
end
%
if nargin < 2,
    opt_gui = false;
end
%
workdir = external_in.workdir;
shotnum = external_in.shotnum;
shotime = external_in.shotime;
t1 = external_in.t1;
t2 = external_in.t2;
%
opt_file = external_in.opt_file;
liuqe = external_in.liuqe;
launchers = external_in.launchers;
Xte = external_in.Xte;
script = external_in.script;
%
% ******************************************************************
%
external = '';
basestr = 'TCV';
%
eqdsk_path = workdir;
%
eqdsk_str = ['eqdsk.',num2str(shotnum),'t',num2str(shotime,'%6.4f')];
%
data_path = workdir;
%
data_str = ['data_',basestr,'_',num2str(shotnum),'_',num2str(t1),'_',num2str(t2)];
%
launstr = '';
for il = 1:length(launchers),
    launstr = [launstr,'_',num2str(launchers(il))];
end
%
if ~opt_file,
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
    make_eqdsk(shotnum,shotime,workdir,'TCV',liuqe);%call LIUQUE
    %
    data_path = [workdir,'/'];
    data_file = [data_str,launstr,'.mat'];
    %
    collect_parameters_for_luke(shotnum,t1,t2,launchers,[data_path,data_file],Xte);%load shot parameters
    %
else
    %
    eqdsk_file = 'eqdsk.*';
    %
    [eqdsk_file,eqdsk_path] = igetfile_jd(opt_gui,eqdsk_file,'Please select the EQDSK file',[eqdsk_path,eqdsk_str]);
    if eqdsk_file == 0,
        return
    else
        newshotnum = str2double(eqdsk_file(find(eqdsk_file == '.',1,'first')+1:find(eqdsk_file == 't',1,'first')-1));
        if ~isnan(newshotnum) && newshotnum ~= shotnum,
            disp(['Warning : shot number enforced to ',num2str(newshotnum),' by selecting EQDSK file'])
            shotnum = newshotnum;
        end
        %
        newshotime = str2double(eqdsk_file(find(eqdsk_file == 't',1,'first')+1:end));
        if ~isnan(newshotime) && newshotime ~= shotime,
            disp(['Warning : shot time enforced to ',num2str(newshotime),' by selecting EQDSK file'])
            shotime = newshotime;
        end
    end
    %
    data_file = ['data_',basestr,'_',num2str(shotnum),'*.mat'];
    %
    [data_file,data_path] = igetfile_jd(opt_gui,data_file,'Please select the data file',[data_path,data_file]);
    if data_file == 0,
        return
    else
        isep = [find(data_file == '_' ),strfind(data_file,'.mat')];
        %
        if length(isep) >= 5,
            newt1 = str2double(data_file(isep(3)+1:isep(4)-1));
            if ~isnan(newt1) && newt1 ~= t1,
                disp(['Warning : time t1 enforced to ',num2str(newt1),' by selecting data file'])
                t1 = newt1;
            end
            %
            newt2 = str2double(data_file(isep(4)+1:isep(5)-1));
            if ~isnan(newt2) && newt2 ~= t2,
                disp(['Warning : time t2 enforced to ',num2str(newt2),' by selecting data file'])
                t2 = newt2;
            end
            %
            newlaunstr = data_file(isep(5):isep(end)-1);
            if ~strcmp(newlaunstr,launstr),
                disp(['Warning : launchers list enforced to ',newlaunstr,' by selecting data file'])
                launstr = newlaunstr;
            end            
        end
    end
    %
end
%
% return structure external
%
external.basestr = basestr;
external.shotnum = num2str(shotnum);
external.shotime = shotime;
%
external.equil.magnetic.eqdsk_path = eqdsk_path;
external.equil.magnetic.eqdsk_file = eqdsk_file;
%
external.equil.prof = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign','teflag','Ip');
%
external.equil.prof.data_path = data_path;
external.equil.prof.data_file = data_file;
external.wave = load([data_path,data_file],'shot','laun','angles*');
external.ohm = load([data_path,data_file],'shot','vloop');
%
external.id = ['TCV_',external.shotnum,'_',num2str(shotime,'%6.4f'),'_',num2str(t1),'_',num2str(t2),'_L',launstr];
%
if ~opt_file && script,
    % 
    imake_makeexternal_TCV_jd(workdir,external,opt_gui);
    %
end    
%
if isnan_jd(external,0),
    disp('Warning : NaNs were found in the structure ''external'' : ')
end
%


