function equil = imake_equil_jd(workdir,basestr)
%
% This function interactively builds the equilibrium structure
%
equil = '';
Zaxis = 0;
%
% MAGNETIC EQUILIBRIUM
%
e_opt = input('Option for magnetic equilibrium contruction? 0 (eqdsk), 1 (helena) [0] : ');
if isempty(e_opt),
    e_opt = 0;
end
if ~isnumeric(e_opt) | ~any(e_opt == [0,1]),
    disp('-----> Invalid equilibrium option');
    return
end
%
if e_opt == 0, % EQSDK equilibrium
    %
    % EQSDK file
    %   
    n_opt = input('Option for EQSDK equilibrium 0 (existing EQSDK file), 1 (build EQSDK) [1] : ');
    if isempty(n_opt),
        n_opt = 1;
    end
    if ~isnumeric(n_opt) | ~any(n_opt == [0,1]),
        disp('-----> Invalid option');
        return
    end
    %
    if n_opt == 0,% EQSDK from data file
        %
        [eqdsk_file,eqdsk_path] = uigetfile('EQDSK*.*','Please select the EQDSK file');
        %
        if eqdsk_file == 0,
            return
        end
        %
        if strfind(eqdsk_file,'EQDSK.'),
            it = strfind(eqdsk_file,'t');
            if ~isempty(it),
                shotnum = eqdsk_file(7:it-1);
                shotime = eqdsk_file(it+1:end);
            end
        end
        %
        shotnum_new = input(['Please provide the shot number [',shotnum,'] : '],'s');
        if ~isempty(shotnum_new),
            shotnum = shotnum_new;
        elseif isempty(shotnum),
            shotnum = '0';
        end
        %
        shotime_new = input(['Please provide the shot time [',shotime,'] : '],'s');
        if ~isempty(shotime_new),
            shotime = shotime_new;
        elseif isempty(shotime),
            shotime = '0';
        end
        %
    elseif n_opt == 1,% build EQSDK
        %
        shotnum = input(['Please provide the shot number : '],'s');
        if isempty(shotnum),
            return
        end
        %
        shotime = input(['Please provide the shot time : '],'s');
        if isempty(shotime),
            return
        end
        %
        strc = '.0000';
        shotime = [shotime,strc(1:end-length(shotime) + 1)];
        %
        l_opt = input('Option for liuqe version? (1,2,3) [1] : ');
        if isempty(l_opt),
            l_opt = 1;
        elseif ~isnumeric(l_opt) | ~any(l_opt == [1:3]),
            return
        end
        %
        [varargout]=make_eqdsk(str2num(shotnum),str2num(shotime),workdir,basestr,l_opt);
        %
        eqdsk_path = [workdir,'/'];
        %
        eqdsk_file = ['eqdsk.',shotnum,'t',shotime];
        %
    end    
    %
    shotid = [basestr,'_',shotnum,'_',shotime];
    %
    id_equil = input(['Please provide a name for the equilibrium file [',shotid,'] : '],'s');
    if isempty(id_equil),
        id_equil = shotid;
    end
    %
    d_opt = input('Do you want to display the equilibrium? [y/n] : ','s');
    if strcmp(d_opt,'y'),
        display_mode = 2;
    else
        display_mode = 1;
    end
    %
    p_opt = input('Option for equilibrium figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
    if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
        p_opt = -1;
    end
    %
    % file name
    %
    dispname = '';
    savename = id_equil;
    %
    [equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = equil_magnetic_EFIT_jd([eqdsk_path,eqdsk_file],display_mode,p_opt,dispname,savename);
    %
elseif e_opt == 1, % HELENA Equilibrium 
    disp('-----> HELENA magnetic equilibrium not yet operational in LUKE');
    return
end
%
% PROFILES
%
if strcmp(basestr,'TCV'),% TCV profile data
    %
    type = 1;
    %
    n_opt = input('Option for equilibrium profiles? 0 (existing data file), 1 (TCV database) [0] : ');
    if isempty(n_opt),
        n_opt = 0;
    end
    if ~isnumeric(n_opt) | ~any(n_opt == [0,1]),
        disp('-----> Invalid profiles option');
        return
    end
    %
    if n_opt == 0,% profiles from data file
        %
        [data_file,data_path] = uigetfile('*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],eqdsk_path);
        %
        if data_file == 0,
            return
        end
        %
    elseif n_opt == 1,% profiles from TCV database
        %
        t1 = input('Averaging of TCV data, initial time : ');
        if isempty(t1) | ~isnumeric(t1) ,
            disp('-----> Invalid time');
            return
        end
        t2 = input('Averaging of TCV data, final time : ');
        if isempty(t1) | ~isnumeric(t1) ,
            disp('-----> Invalid time');
            return
        end
        %
        laun = input('Vector of EC launchers to account for (ex: [1,3]) : ');
        if isempty(laun) | ~isnumeric(laun) ,
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
        collect_parameters_for_luke(str2num(shotnum),t1,t2,laun,[data_path,data_file])
        %
    end
    %
    data = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis');
    %
    ishot = find(data.shot == str2num(shotnum));
    %
    if isempty(ishot),
        disp(['-----> Profiles data not found for shot :',shotnum]);
        return
    end
    %
    if length(ishot) > 1,
        disp(['-----> WARNING : Several entries are found for shot :',shotnum,', first entry selected']);
        ishot = ishot(1);
    end
    %
    prho = data.rho(ishot,:);
    pne = data.ne(ishot,:);
    pTe = data.te(ishot,:);
    %
    if length(data.ti(ishot,:)) == 1,
        disp(['-----> No ion temperature specified, Ti=Te/6 enforced.']);
        pTi = pTe/6;
    else
        pTi = data.ti(ishot,:);
    end
    %
    Zeff = data.zeff(ishot);
    Zaxis = data.zaxis(ishot);
    %
    profname = [id_equil,'.prof'];
    save(profname,'prho','pne','pTe','pTi','Zeff','-mat');
    %
else
    %
    disp(['-----> profiles data not implemented yet for :',basestr]);
    return    
    %
end
%
equil_prof = equil_prof_jd(id_equil,type,mrho,mspsin,mspsinT,display_mode,p_opt,dispname,savename,Zeff);
delete(profname);
%
% EQUIL structure
%
%
% Correction for the equilibrium offset
%
Zp_offset = input(['Vertical equilibrium offset (vacuum) [',num2str(Zaxis),'] : ']);
if isempty(Zp_offset) | ~isnumeric(Zp_offset),
    Zp_offset = Zaxis;
end
equil_magnetic.Zp = equil_magnetic.Zp + Zp_offset;
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
equil.id = id_equil;
equil.info.gen = 'Built with imake_equil_jd';
if e_opt == 0,
    equil.info.eqdsk = [eqdsk_path,eqdsk_file];
    equil.info.shotnum = shotnum;
    equil.info.shotime = shotime;
end
if strcmp(basestr,'TCV'),
    equil.info.data = [data_path,data_file];
    equil.info.t1 = t1;
    equil.info.t2 = t2;
end
%
