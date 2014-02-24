function external = load_externaldata_TCV_MultiTimes(workdir,opt_gui,style)
    %
    % This function loads data from TCV database
    %
    diagnames = {'BT','IP','VLOOP','NE','TE','TI','ZEFF','ZAXIS','ECRH','EQUIL'};
    ndiag = length(diagnames);
    %
    shotdata = iget_datainput_TCV(diagnames,workdir,opt_gui,style);% setup user-defined inputs with GUI or command line
    %
    % put input in form for luke_get_trdata.m
    %
    datainput = struct;
    datainput.shot = shotdata.shotnum;
    if ~isempty(shotdata.times),
        datainput.t = shotdata.times;
    end
    if ~isempty(shotdata.dtmax),
        datainput.dtreslim = shotdata.dtmax;
    end
    if ~isempty(shotdata.outputdir),
        datainput.outputpath = shotdata.outputdir;
    end
    for idiag = 1:ndiag,
        %
        datainput.diag{idiag}.name = diagnames{idiag};
        %
        if strcmp(diagnames{idiag},'ECRH'),
            if ~isempty(shotdata.isel),
                datainput.diag{idiag}.isel = shotdata.isel;
            else
                datainput.diag{idiag}.isel = 1:6;%1:9;%
            end
        end
        %
    end
    %
    dataoutput = luke_get_trdata(datainput);
    %
    % fill external structure fields
    %
    external = struct;
    external.basestr = 'TCV';
    external.shotnum = num2str(shotdata.shotnum);
    %
    % get relevant times  - reference is te
    %
    nshotimes = dataoutput.te.time;
    %
    nshotimes = intersect(nshotimes,dataoutput.ne.time);
    if ~all(isnan(dataoutput.ti.data(:))),
        nshotimes = intersect(nshotimes,dataoutput.ti.time);
    else
        disp('No ti data');        
    end
    nshotimes = intersect(nshotimes,dataoutput.zeff.time);
    nshotimes = intersect(nshotimes,dataoutput.zaxis.time);
    nshotimes = intersect(nshotimes,dataoutput.ip.time);
    nshotimes = intersect(nshotimes,dataoutput.vloop.time);
    %
    for iisel = 1:length(dataoutput.ecrh.isel),
        nshotimes = intersect(nshotimes,dataoutput.ecrh.ang{iisel}.time);
        nshotimes = intersect(nshotimes,dataoutput.ecrh.pow{iisel}.time);
    end
    %
    discnshotimes = setdiff(dataoutput.te.time,nshotimes);
    if ~isempty(discnshotimes),
        disp(['WARNING : ',num2str(length(discnshotimes)),'/',num2str(length(dataoutput.te.time)),' times were discarded as they are missing from some diagnostics']);
    end
    %
    external.nshotimes = nshotimes;
    nt = length(external.nshotimes);
    external.shotimes = cell(1,nt);
    %
    for it = 1:nt,
        shotime = external.nshotimes(it);
        external.shotimes{it} = num2str(shotime,'%6.4f');
        %
        external.equil(it).basestr =  external.basestr;
        external.equil(it).shotnum =  external.shotnum;
        external.equil(it).shotime =  external.shotimes{it};
        %
        eqdsk_file = [dataoutput.equil.data,filesep,'eqdsk.',external.shotnum,'t',external.shotimes{it}];
        if exist(eqdsk_file,'file'),
            external.equil(it).magnetic.eqdsk = fileread(eqdsk_file);% magnetic equilibrium
        else
            error(['File ',eqdsk_file,' could not be found. aborted.']);
        end
        %
        external.equil(it).prof.te = dataprocess(dataoutput.te,'te',shotime);% te
        external.equil(it).prof.ne = dataprocess(dataoutput.ne,'ne',shotime);% ne
        %
        if all(isnan(dataoutput.ti.data(:))),
            external.equil(it).prof.ti = [];
        else
            external.equil(it).prof.ti = dataprocess(dataoutput.ti,'ti',shotime);% ti
        end
        %
        external.equil(it).prof.zeff = dataprocess(dataoutput.zeff,'zeff',shotime);% zeff
        external.equil(it).prof.zaxis = dataprocess(dataoutput.zaxis,'zaxis',shotime);% zaxis
        external.equil(it).prof.ip = dataprocess(dataoutput.ip,'ip',shotime);% ip
        external.equil(it).prof.btsign = dataoutput.btsign.data;% btsign
        external.equil(it).prof.ipsign = dataoutput.ipsign.data;% ipsign
        %
        external.ohm(it).vloop = dataprocess(dataoutput.vloop,'vloop',shotime);% vloop
        %
        external.wave(it).laun = dataoutput.ecrh.isel;
        for iisel = 1:length(dataoutput.ecrh.isel),
            %
            angles = selectfields_jd(dataoutput.ecrh.ang{iisel},{'freq','P1_R','P1_theta','P2_R','P2_d','P1_Z','P2_Z','P3_Z'});% mirrors
            %
            angles.theta = dataprocess(dataoutput.ecrh.ang{iisel},'theta',shotime,'theta');% theta
            angles.phi = dataprocess(dataoutput.ecrh.ang{iisel},'phi',shotime,'phi');% phi
            angles.theta_eff = dataprocess(dataoutput.ecrh.ang{iisel},'theta_eff',shotime,'theta_eff');% theta_eff
            angles.phi_eff = dataprocess(dataoutput.ecrh.ang{iisel},'phi_eff',shotime,'phi_eff');% phi_eff
            %
            angles.P0 = dataprocess(dataoutput.ecrh.pow{iisel},'pow',shotime);% P0
            %
            external.wave(it).angles(iisel) = angles;
            %
        end
        %    
    end
    %
    external.id = ['TCV_',external.shotnum,'_MultiTimes'];
    %
end
%
function dataout = dataprocess(datain,dataname,shotime,fname)
    %
    if nargin < 4,
        fname = 'data';
    end
    %
    itdata = datain.time == shotime;
    if any(itdata),
        if isfield(datain,'rho'),
            dataout = struct;
            dataout.rho = datain.rho;
            dataout.data = datain.(fname)(:,itdata);
        else
            dataout = datain.(fname)(itdata);
        end
    else
        error(['Time ',num2str(shotime),' not found in ',dataname,' data. aborted.']);
    end
    %
end


% 
% 
% 
% 
% 
% 
% 
% 
% if nargin < 7,
%     select = struct;
% elseif ~isstruct(select) && isempty(select),% no user prompt - default options
%     %
%     select.m_opt = 0;
%     select.l_opt = 1;
%     select.laun = 1:6;
%     select.f_opt = 0;
%     select.s_opt = 'n';
%     %
% end
% %
% external = '';
% basestr = 'TCV';
% %
% if ~isfield(select,'m_opt'),
%     select.m_opt = input_dke_yp('Do you want to: (0) load data from database, (1) load data from files',0,[0,1],'',[1,1]);
% end
% %
% eqdsk_path = [workdir,'/'];
% %
% eqdsk_file = ['eqdsk.',shotnum,'t',shotime];
% %
% data_path = [workdir,'/'];
% %
% data_str = ['data_',basestr,'_',shotnum,'_',num2str(t1),'_',num2str(t2)];
% %
% if select.m_opt == 0,
%     %
%     if ~exist('make_eqdsk.m','file'),
%         disp('-----> Access to the TCV database is not granted.');
%         disp('-----> You need the file make_eqdsk.m in the matlab path.');
%         return;
%     end
%     %
%     if ~exist('collect_parameters_for_luke.m','file'),
%         disp('-----> Access to the TCV database is not granted.');
%         disp('-----> You need the file collect_parameters_for_luke.m in the matlab path.');
%         return;
%     end
%     %
%     if ~isfield(select,'l_opt'),
%         select.l_opt = input('Option for liuqe version? (1,2,3) [1] : ');
%     end
%     %
%     if isempty(select.l_opt),
%         select.l_opt = 1;
%     elseif ~isnumeric(select.l_opt) || ~any(select.l_opt == 1:3),
%         return
%     end
%     %
%     make_eqdsk(str2num(shotnum),str2num(shotime),workdir,'TCV',select.l_opt);%call LIUQUE
%     %
%     if ~isfield(select,'laun'),
%         select.laun = input('Vector of EC launchers to account for (ex: [1,3]) : ');
%     end
%     %
%     if isempty(select.laun) || ~isnumeric(select.laun) ,
%         disp('-----> Invalid entry');
%         return
%     end
%     %
%     if ~isfield(select,'f_opt'),
%         select.f_opt = input_dke_yp('Do you want to: (0) load Te from fitted Thomson only, (1) load Te with Xte renormalization',0,[0,1],'',[1,1]);
%     end
%     %
%     launstr = '';
%     for il = 1:length(select.laun),
%         launstr = [launstr,'_',num2str(select.laun(il))];
%     end
%     %
%     data_path = [workdir,'/'];
%     data_file = [data_str,launstr,'.mat'];
%     %
%     collect_parameters_for_luke(str2num(shotnum),t1,t2,select.laun,[data_path,data_file],select.f_opt);%load shot parameters
%     %
% else
%     %
%     [eqdsk_file,eqdsk_path] = igetfile_jd(opt_gui,eqdsk_file,'Please select the EQDSK file',[eqdsk_path,eqdsk_file]);
%     if eqdsk_file == 0,
%         return
%     end
%     %
%     data_file = [data_str,'*.mat'];
%     %
%     [data_file,data_path] = igetfile_jd(opt_gui,data_file,'Please select the data file',[data_path,data_file]);
%     if data_file == 0,
%         return
%     end
%     %
%     i1 = length(data_str);
%     i2 = strfind(data_file,'.mat');
%     %
%     launstr = data_file(i1+1:i2-1);
%     %
% end
% %
% % return structure equil
% %
% external.equil.shotnum = shotnum;
% external.equil.shotime = shotime;
% external.equil.magnetic.eqdsk_path = eqdsk_path;
% external.equil.magnetic.eqdsk_file = eqdsk_file;
% %
% external.equil.prof = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign','teflag','Ip');
% %
% external.equil.prof.data_path = data_path;
% external.equil.prof.data_file = data_file;
% external.wave = load([data_path,data_file],'shot','laun','angles*');
% external.ohm = load([data_path,data_file],'shot','vloop');
% %
% external.id = ['TCV_',shotnum,'_',shotime,'_',num2str(t1),'_',num2str(t2),'_L',launstr];
% %
% if select.m_opt == 0,
%     %
%     if ~isfield(select,'s_opt'),
%         select.s_opt = input_dke_yp('Do you want to generate an equivalent make_external_TCV script? [y/n]','n',{'y','n'},'',[1,1]);
%     end
%     %
%     if select.s_opt == 'y',
%         % 
%         imake_makeexternal_TCV_jd(workdir,external,opt_gui);
%         %
%     end
% end    
% %
% if isnan_jd(external,0),
%     disp('Warning : NaNs were found in the structure ''external'' : ')
%     isnan_jd(external,1),
% end
% %


