function equil = imake_equil_jd(basestr,signs,workdir,opt_gui)
%
% This function interactively builds the equilibrium structure
%
if nargin < 4,
	opt_gui = 1;
end
%
if nargin < 3,
	workdir = pwd;
end
%
if nargin < 2,
	signs = '';
end
%
equil = '';
Zaxis = 0;
Zeff = NaN;
eqdsk_opt = 0;
%
% MAGNETIC EQUILIBRIUM
%
n_opt = input_dke_yp('Load existing (0) or built new (1) magnetic equilibrium : ',1,{0,1},'Invalid selection');
%
if n_opt == 0, % Load existing equilibrium
    %
	e_opt = input_dke_yp('Format of the magnetic equilibrium data, 0 (eqdsk), 1 (itm): ',0,{0,1},'Invalid option');
    %
    if e_opt == 0,% EQSDK from data file
        %
        % EQSDK file
        % 
        eqdsk_opt = 1;
		%
        [eqdsk_file,eqdsk_path] = igetfile_jd(opt_gui,{'eqdsk*.*';'EQDSK*.*';'*.*'},'Please select the EQDSK file',workdir);
        %
        if eqdsk_file == 0,
            return
        end
        %
        it = strfind(eqdsk_file,'t');
        %
        if (~isempty(strfind(eqdsk_file,'EQDSK.')) | ~isempty(strfind(eqdsk_file,'eqdsk.'))) & ~isempty(it),
            shotnum = eqdsk_file(7:it-1);
            shotime = eqdsk_file(it+1:end);
        else
            shotnum = '0';
            shotime = '0';
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
    elseif e_opt == 1,% load ITM
        %
        disp('ITM equilibrium loading not yet implemented.')
        return
    end
elseif n_opt == 1,
	%
	e_opt = input_dke_yp('Select magnetic equilibrium solver, 0 (liuque), 1 (helena): ',0,{0,1},'Invalid option');
	%
    if e_opt == 0,% LIUQUE
        %
        eqdsk_opt = 1;
        %
        shotnum = input(['Please provide the shot number : '],'s');
        if isempty(shotnum),
            return
        end
        %
        shotime = input('Please provide the shot time : ');
        if isempty(shotime),
            return
        end
        %
        shotime = num2str(shotime,'%6.4f');
        %
        l_opt = input('Option for liuqe version? (1,2,3) [1] : ');
        if isempty(l_opt),
            l_opt = 1;
        elseif ~isnumeric(l_opt) | ~any(l_opt == [1:3]),
            return
        end
        %
        make_eqdsk(str2num(shotnum),str2num(shotime),workdir,basestr,l_opt);%call LIUQUE
        %
        eqdsk_path = [workdir,'/'];
        %
        eqdsk_file = ['eqdsk.',shotnum,'t',shotime];
        %
    elseif e_opt == 1, % HELENA Equilibrium 
		%  
        shotnum = input(['Please provide the shot number : '],'s');
        if isempty(shotnum),
            return
        end
        %
        shotime = input('Please provide the shot time : ');
        if isempty(shotime),
            return
        end
        %
        t1 = input('Averaging of profiles data, initial time : ');
        if isempty(t1) | ~isnumeric(t1) ,
            disp('-----> Invalid time');
            return
        end
        %
        t2 = input('Averaging of profiles data, final time : ');
        if isempty(t1) | ~isnumeric(t1) ,
            disp('-----> Invalid time');
            return
        end
        %
        shotime = num2str(shotime,'%6.4f');
        %
        data_path = [workdir,'/'];
        data_file = ['data_',basestr,'_',shotnum,'_',num2str(t1),'_',num2str(t2),'.mat'];
        %
        [equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = make_helmex77(shotnum,shotime,t1,t2,basestr,[data_path,data_file]);%call HELENA (helmex77)
        %
        if ~exist('equil_magnetic'),
            disp('-----> Equilibrium creation failed');
            return;
        end
    end
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
dispname = '';
savename = id_equil;
%
if eqdsk_opt == 1,%(R,Z) to (psi,theta) conversion specific to eqdsk
    %
    % file name
    %
    [equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = equil_magnetic_EFIT_jd([eqdsk_path,eqdsk_file],display_mode,p_opt,dispname,savename);
    %
end
%
% PROFILES
%
if strcmp(basestr,'TCV'),% TCV profile data
    %
    n_opt = input('Option for equilibrium profiles? 0 (existing data file), 1 (TCV database), 2 (ART profiles), 3 (TORAY profiles) [0] : ');
    if isempty(n_opt),
        n_opt = 0;
    end
    if ~isnumeric(n_opt) | ~any(n_opt == [0,1,2,3]),
        disp('-----> Invalid profiles option');
        return
    end
    %
	if n_opt <= 2,
		%
		type = 1;
		%
		if n_opt == 0,% profiles from data file
			%
			[data_file,data_path] = igetfile_jd(opt_gui,'*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],eqdsk_path);
			%
			if data_file == 0,
				return
			end
			%
			load([data_path,data_file],'t1','t2','laun');
			%
			data = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign');
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
			data = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign');
			%
		elseif n_opt == 2,% profiles from ART output
			%
			[data_file,data_path] = igetfile_jd(opt_gui,'*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],eqdsk_path);
			%
			if data_file == 0,
				return
			end
			%
			load([data_path,data_file],'ARTsimprof');
			%
			data.rho = ARTsimprof.rho.data.';
			data.ne = ARTsimprof.n.data.'*1e20;
			data.te = ARTsimprof.X.data.';
			data.ti = NaN;
			%
			data.zeff = NaN;
			data.zaxis = NaN;
			%
			data.shot = str2num(data_file(4:8));
			%
		end
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
		%
		if isnan(Zeff),
			Zeff = input('No measure of Zeff is available. Please provide an estimated value for Zeff [1] : ');
			if isempty(Zeff) | ~isnumeric(Zeff) | Zeff < 1 | Zeff > 6,
				disp('Zeff = 1 enforced');
				Zeff = 1;
			end
		end
		%
		Zaxis = data.zaxis(ishot);
		%
		profname = [id_equil,'.prof'];
		save(profname,'prho','pne','pTe','pTi','Zeff','-mat');
		%
		% sign management as most equilibrium codes do not account for these.
		%
		if ~isstruct(signs) & exist('btsign') & exist('ipsign'),% note that TCV conventions are opposite to LUKE conventions
			signs.Bt = - btsign;
			signs.Ip = - ipsign;
		end
		%
	elseif n_opt == 3,
		%
		[data_file,data_path] = igetfile_jd(opt_gui,'*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],eqdsk_path);
		%
		if data_file == 0,
			return
		end
		%
		profname = [data_path,data_file];
		%
	end
	%
elseif strcmp(basestr,'ITER'),% ITER Astra profile data
    %
    profname = [id_equil,'.prof'];
    type = 0.2;
    %
    [data_file,data_path] = igetfile_jd(profname,['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],eqdsk_path);
    %
    profname = [data_path,data_file];
    %
    if data_file == 0,
        return
    end
    %
elseif strcmp(basestr,'TS'),% TS profile data
	%
	type = -1;
	profname = [data_path,data_file];
	%
else
    %
    disp(['-----> profiles data not implemented yet for :',basestr]);
    return    
    %
end
%
equil_prof = equil_prof_jd(profname,type,mrho,mspsin,mspsinT,display_mode,p_opt,dispname,savename,Zeff);
%
d_opt = input('Do you want to compare the pressure profiles? [y/n] : ','s');
if strcmp(d_opt,'y'),
    %
    % Verify consistency on pressure between profiles and EFIT
    %
    qe = pc_dke_yp;
    %
    mp_profiles = (equil_prof.pTe.*equil_prof.pne + sum(equil_prof.pzTi.*equil_prof.pzni,1))*qe*1e3;%pressure from Tene data
    %
    figure(14),clf
    %
    graph1D_jd(mrho,mp_profiles/1e5,0,0,'r/a','p (Bar)','',NaN,[0,1],NaN,'-','none','b',2,20,gca,0.9,0.7,0.7);
    graph1D_jd(mrho,mp_magnetic*qe*1e3/1e5,0,0,'','','',{'T_en_e + T_in_i','Equilibrium code'},[0,1],NaN,'-','none','r',2);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_p_comp']);
end
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
% sign management as most equilibrium codes do not account for these.
%
if isstruct(signs),
	if signs.Ip*equil_magnetic.psi_apRp(end) < 0,
		equil_magnetic.psi_apRp = -equil_magnetic.psi_apRp;
		equil_magnetic.ptBx = -equil_magnetic.ptBx;
		equil_magnetic.ptBy = -equil_magnetic.ptBy;
	end
	%
	if signs.Bt*equil_magnetic.ptBPHI(1,1) < 0,
		equil_magnetic.ptBPHI = -equil_magnetic.ptBPHI;
	end
end
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
%
equil.id = id_equil;
equil.info.gen = 'Built with imake_equil_jd';
if e_opt == 0,
    equil.info.eqdsk = [eqdsk_path,eqdsk_file];
    equil.info.shotnum = shotnum;
    equil.info.shotime = shotime;
end
if strcmp(basestr,'TCV'),
    delete(profname);
    equil.info.data = [data_path,data_file];
    if n_opt < 2,
        equil.info.t1 = t1;
        equil.info.t2 = t2;
        equil.info.laun = laun;
    end
elseif strcmp(basestr,'ITER'),
    equil.info.data = [data_path,data_file];
elseif strcmp(basestr,'TS'),
    equil.info.shotnum = shotnum;
    equil.info.shotime = shotime;
    equil.info.data = [data_path,data_file];
end
%
