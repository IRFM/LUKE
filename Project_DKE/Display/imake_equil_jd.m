function equil = imake_equil_jd(dkepath,basestr,signs,external,workdir,opt_gui)
%
% This function interactively builds the equilibrium structure
%
if nargin < 6,
	opt_gui = 1;
end
%
if nargin < 5,
	workdir = pwd;
end
%
if nargin < 4,
	external = '';
end
%
if nargin < 3,
	signs = '';
end
%
equil = '';
Zaxis = 0;
Zeff = NaN;
%
e_opt = 0;
f_opt = 0;
type = NaN;
%
% MAGNETIC EQUILIBRIUM
%
disp(' ')
disp('*********** MAGNETIC EQUILIBRIUM ***********')
disp(' ')
%
if isfield(external,'magnetic'),% magnetic equilibrium from external database?
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(0) use data loaded from the external database \n',...
        '(1) use data from an existing equilibrium file \n',...
        '(2) build the magnetic equilibrium data locally \n'],...
        0,{0,1,2},'Invalid selection');
    %
else
    %
    i_opt = input_dke_yp(['Do you want to :\n',...
        '(1) use data from an existing equilibrium file \n',...
        '(2) build the magnetic equilibrium data locally \n'],...
        1,{1,2},'Invalid selection');
    %
end
% 
if i_opt == 0, % use data from from external database
    %
    shotnum = external.shotnum;
    shotime = external.shotime;
    %
    if strcmp(basestr,'TCV'),
        %
        eqdsk_path = external.magnetic.eqdsk_path;
        eqdsk_file = external.magnetic.eqdsk_file;
        %
        if ~exist([eqdsk_path,eqdsk_file],'file'),
            error(['The file ',eqdsk_path,eqdsk_file,' does not exist. Aborted.'])
        end
        %
        e_opt = -1;% eqdsk equilibrium
        %
    elseif strcmp(basestr,'TS'),
        %
        equil_magnetic_data = external.magnetic;
        %
    elseif strcmp(basestr,'JET'),
        %
        equil_magnetic_data = external.magnetic;
        %
        e_opt = -3;% standard rz -> pt transformation needed
        %
    else
        %
        disp('-----> function not yet implemented for this machine.')
        return
    end
    %
elseif i_opt == 1, % use data from an existing equilibrium file
    %
	d_opt = input_dke_yp('Format of the magnetic equilibrium data, 0 (eqdsk), 1 (itm), (2) (AMR): ',0,{0,1,2},'Invalid option');
    %
    if d_opt == 0,% EQSDK from data file
        %
        % EQSDK file
		%
        [eqdsk_file,eqdsk_path] = igetfile_jd(opt_gui,{'eqdsk*.*';'EQDSK*.*';'*.*'},'Please select the EQDSK file',workdir);
        %
        if eqdsk_file == 0,
            disp('-----> No eqdsk file selected.')            
            return
        end
        %
        it = strfind(eqdsk_file,'t');
        %
        if (~isempty(strfind(eqdsk_file,'EQDSK.')) || ~isempty(strfind(eqdsk_file,'eqdsk.'))) && ~isempty(it),
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
        e_opt = -1;% eqdsk equilibrium
        %
    elseif d_opt == 1,% load ITM
        %
        disp('-----> loading of ITM equilibrium not yet implemented.')
        return
        %
    elseif d_opt == 2,% load AMR
        %
        % AMR equilibrium psi file
        % 
        [amr_psi_file,amr_psi_path] = igetfile_jd(opt_gui,{'m_profs_*_Psi.dat';'*.*'},'Please select the AMR equilibrium file containing the Psi vector',workdir);
        %
        if amr_psi_file == 0,
            disp('-----> No AMR equilibrium file selected.')
            return
        end
        %
        if (strcmp(amr_psi_file(1:8),'m_profs_')),
            it1 = 8 + strfind(amr_psi_file(9:end),'_');
            shotnum = amr_psi_file(9:it1(1)-1);
            it2 = it1(1) + strfind(amr_psi_file(it1+1:end),'_');
            shotime = amr_psi_file(it1(1)+1:it2(1)-1);
        else
            disp('-----> The AMR equilibrium file selected is not valid.')
            return
        end
        %
        e_opt = -2;% AMR equilibrium
        n_opt = 0;
        %
    end
    %
end
%
if e_opt == 0,% equilibrium code to be specified
    %
	e_opt = input_dke_yp('Select magnetic equilibrium solver, 0 (analytic circular concentric), 1 (helena) : ',0,{0,1},'Invalid option');   
    %
end
%
if i_opt == 2, % equilibrium data specified by user
    %
    [equil_magnetic_data,shotnum,shotime] = imake_equil_ideal(e_opt);
    %
end
%
% EQUILIBRIUM PROFILES
%
disp(' ')
disp('*********** EQUILIBRIUM PROFILES ***********')
disp(' ')
%
if e_opt ~= -2,
    if isfield(external,'prof'),% magnetic equilibrium from external database?
        %
        i_opt = input_dke_yp(['Do you want to :\n',...
            '(0) use data loaded from the external database \n',...
            '(1) use data from an existing equilibrium profiles file \n',...
            '(2) build the equilibrium profiles data locally \n'],...
            0,{0,1,2},'Invalid selection');
        %
    else
        %
        i_opt = input_dke_yp(['Do you want to :\n',...
            '(1) use data from an existing equilibrium profiles file \n',...
            '(2) build the equilibrium profiles data locally \n'],...
            1,{1,2},'Invalid selection');
        %
    end
    % 
    if i_opt == 0, % use data from from external database
        %
        equil_prof_data = external.prof;
        %
        if strcmp(basestr,'TCV'),
            %
            type = 1;% TCV data format
            n_opt = 0;
            %
        elseif strcmp(basestr,'TS'),
            %
            n_opt = -1;% ideal equilibrium profiles
            %
        elseif strcmp(basestr,'JET'),
            %
            if isempty(equil_prof_data.pne) || isempty(equil_prof_data.pTe),% fits are necessary
                %
                f_opt = 1;% experimental profiles must be fitted
                n_opt = -1;% ideal equilibrium profiles
                %
            else % fits exist, save data for equil_prof_jd
                %
                type = 1.2;
                n_opt = 0;
                %
            end
        else
            %
            disp('-----> function not yet implemented for this machine.')
            return
        end
        %
    elseif i_opt == 1, % use data from an existing equilibrium file
        %
        n_opt = input_dke_yp(['Option for equilibrium profiles file : \n',...
            '0 (existing data file)\n',...
            '1 (ART profiles)\n',...
            '2 (TORAY profiles)\n',...
            '3 (EVE profiles)\n'],...
            0,{0,1,2,3},'Invalid selection');
        %
        [data_file,data_path] = igetfile_jd(opt_gui,'*.*',['Please select the data file for shot ',shotnum,' at time ',shotime,' :'],eqdsk_path);
        %
        if data_file == 0,
            return
        end
        %
        profname = [data_path,data_file];
        %
        if n_opt == 0,
            %
            if strcmp(basestr,'TCV'),% TCV profile data file
                %
                type = 1;
                %
                equil_prof_data = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign');
                %
            elseif strcmp(basestr,'TS'),% TS profile data file
                %
                type = -1;
                %       
            elseif strcmp(basestr,'ITER'),% ITER Astra profile data
                %
                type = 0.2;
                %
            elseif strcmp(basestr,'EAST'),% EAST ideal profiles from make_profile script
                %
                type = 1.1;
                %
            else
                disp(['-----> profiles data files not treated yet for :',basestr]);
                return 
            end
            %
        elseif n_opt == 1,% profiles from ART output
            %
            type = 1;
            %
            load([data_path,data_file],'ARTsimprof');
            %
            equil_prof_data.rho = ARTsimprof.rho.data.';
            equil_prof_data.ne = ARTsimprof.n.data.'*1e20;
            equil_prof_data.te = ARTsimprof.X.data.';
            equil_prof_data.ti = NaN;
            %
            equil_prof_data.zeff = NaN;
            equil_prof_data.zaxis = NaN;
            %
            equil_prof_data.shot = str2num(data_file(4:8));
            %
        elseif n_opt == 2,% profiles from TORAY output
            %
            disp('-----> profiles data files not treated yet for TORAY output');
            return             
            %
        elseif n_opt == 3,% EVE profiles
            %
            type = 1.3;
            %
        end
        %
    elseif i_opt == 2, % equilibrium profiles data specified by user
        %
        equil_prof_data = imake_equil_ideal;
        %
        n_opt = -1;% ideal equilibrium profiles
        %
    end
end
%
% ************** BUILT EQUILLIBRIUM *****************
%
shotid = [basestr,'_',shotnum,'_',shotime];
%
id_equil = input(['Please provide a name for the equilibrium file [',shotid,'] : '],'s');
if isempty(id_equil),
    id_equil = shotid;
end
%
d_opt = input_dke_yp('Do you want to display the equilibrium','n',{'y','n'},'',[1,1]);
if strcmp(d_opt,'y'),
    display_mode = 2;
else
    display_mode = 1;
end
%
p_opt = input_dke_yp('Option for equilibrium figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
%
dispname = '';
savename = id_equil;
%
if type == 1 && n_opt <= 1,
    %
    ishot = find(equil_prof_data.shot == str2num(shotnum));
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
    prho = equil_prof_data.rho(ishot,:);
    pne = equil_prof_data.ne(ishot,:);
    pTe = equil_prof_data.te(ishot,:);
    %
    if length(equil_prof_data.ti(ishot,:)) == 1 || ...
      input_dke_yp('Do you want to specify Ti manually','n',{'y','n'},'',[1,1]) == 'y';
        %
        TeTi = input_dke_yp('Please provide an estimated value for Te/Ti',6,'','',[1,1]);
        %
        pTi = pTe/TeTi;
    else
        pTi = equil_prof_data.ti(ishot,:);
    end
    %
    pZeff = equil_prof_data.zeff(ishot,:);
    %
    if isscalar(pZeff),%uniform profile
        %
        Zeff = pZeff;
        %
        if isnan(Zeff),
            %
            Zeff = input_dke_yp('No measure of Zeff is available. Please provide an estimated value for Zeff',3,[1;6],'',[1,1]);
            %
        else
            Zeff_new = input(['Confirm Zeff value? [',num2str(Zeff),']: ']);
            %
            if Zeff_new ~= Zeff,
                disp(['-----> WARNING: Zeff value has been changed from ',num2str(Zeff),' to ',num2str(Zeff_new)]);
                Zeff = Zeff_new;
            end
        end
        %
        pZeff = Zeff*ones(size(prho));
        %
    end
    %
    Zaxis = equil_prof_data.zaxis(ishot);
    %
    profname = [id_equil,'.prof'];        
    %
    % sign management as most equilibrium codes do not account for these.
    %
    if ~isstruct(signs) 
		if exist('btsign','var') && exist('ipsign','var'),% note that TCV conventions are opposite to LUKE conventions
        	signs.Bt = - btsign;
        	signs.Ip = - ipsign;
		end
		%
		if isfield(equil_prof_data,'btsign') && isfield(equil_prof_data,'ipsign'),% note that TCV conventions are opposite to LUKE conventions
        	signs.Bt = - equil_prof_data.btsign;
        	signs.Ip = - equil_prof_data.ipsign;
		end		
    end
    %
    save(profname,'prho','pne','pTe','pTi','pZeff','-mat');
    %
elseif type == 1.2 && n_opt == 0,
    %
    Zeff = equil_prof_data.Zeff;
    pspsin = sqrt(equil_prof_data.psin);
    pne = equil_prof_data.pne;
    pTe = equil_prof_data.pTe/1e3;% eV-> keV
    %
    TeTi = input_dke_yp('No data on Ti was found. Please provide an estimated value for Te/Ti',1,'','',[1,1]);
    %
    pTi = pTe/TeTi;
    %
    profname = [id_equil,'.prof'];        
    %
    save(profname,'pspsin','pne','pTe','pTi','Zeff','-mat');          
    %    
end
%
if e_opt >= 0 || e_opt <= -2,
    %
    np = input_dke_yp('Number of equilibrium radial points',101,1:2:1001,'np must be an odd number',[1,1]);
    %
    nt = input_dke_yp('Number of equilibrium poloidal points',65,3:2:1001,'nt must be an odd number',[1,1]);
    %
end
%
if e_opt >= 0,
    %
    % Create ideal magnetic equilibrium
    %
    equil_magnetic.Rp = equil_magnetic_data.Rp;
    equil_magnetic.Zp = equil_magnetic_data.Zp;
    %
    [mpsin,equil_magnetic.psi_apRp,equil_magnetic.theta,equil_magnetic.ptx,equil_magnetic.pty,equil_magnetic.ptBx,equil_magnetic.ptBy,equil_magnetic.ptBPHI,mBpp,mq_Rpap,mj,mmag,Ip_test,mrho,mspsin,mspsinT] = ...
        idealequilcyl_yp(equil_magnetic_data.ap,equil_magnetic_data.Rp,equil_magnetic_data.Zp,equil_magnetic_data.Bt,equil_magnetic_data.Ip,equil_magnetic_data.qmin_Rpap,equil_magnetic_data.eq,equil_magnetic_data.qopt,np,nt);%Cylindrical magnetic equilibrium
    %
elseif e_opt == -1,% (R,Z) to (psi,theta) conversion specific to eqdsk    
    %
    [equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = equil_magnetic_EFIT_jd([eqdsk_path,eqdsk_file],display_mode,p_opt,dispname,savename);
    [np,nt] = size(equil_magnetic.ptx);
    %
    % Correction for the equilibrium offset
    %
    Zp_offset = input(['Vertical equilibrium offset (vacuum) [',num2str(Zaxis),'] : ']);
    if isempty(Zp_offset) || ~isnumeric(Zp_offset),
        Zp_offset = Zaxis;
    end
    equil_magnetic.Zp = equil_magnetic.Zp + Zp_offset;
    %
elseif e_opt == -2,% AMR equilibrium
    %
    [equil_magnetic,equil_prof] = make_equil_AMR_jd(amr_psi_path,shotnum,shotime,display_mode,p_opt,dispname,savename,np,nt);
    %
elseif e_opt == -3,% standard rz -> pt transformation needed
    %
    [equil_magnetic,mrho,mspsin,mspsinT] = equil_magnetic_rz2pt_jd(equil_magnetic_data,display_mode,p_opt,dispname,savename,np,nt);
    %
end
%
if f_opt == 1,% experimental profiles must be fitted
    %
    equil_prof_data = fitprof_ideal_jd(equil_prof_data);
    %
end
%
if n_opt == -1,% Create ideal equilibrium profiles
    %
    [equil_prof_data.prho,equil_prof.pTe,equil_prof.pne,equil_prof.pzTi,equil_prof.pzni,equil_prof.zZi,equil_prof.zmi,equil_prof_data.fi,equil_prof_data.pkin] = ...
        idealprof_yp(equil_prof_data.Zi,equil_prof_data.mi,equil_prof_data.fi,equil_prof_data.Te0,equil_prof_data.Tea,equil_prof_data.eTe1,equil_prof_data.eTe2,equil_prof_data.ne0,equil_prof_data.nea,equil_prof_data.ene1,equil_prof_data.ene2,equil_prof_data.Ti0,equil_prof_data.Tia,equil_prof_data.eTi1,equil_prof_data.eTi2,equil_prof_data.Zeff0,equil_prof_data.Zeffa,equil_prof_data.eZeff,equil_prof_data.xZeff,np);%Profiles
    %
end
%
if e_opt == 1,
    %
    % Use Helena to create an equilibrium
    %
    mj_min = min(mj); 
    if mj_min < 0,%pj must be non-negative. Only the shape is considered and Ip for the total plasma current
        mj = mj - mj_min;
    end
    %
    [equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = equil_magnetic_helmex77_yp(equil_magnetic_data.ap,equil_magnetic_data.Rp,equil_magnetic_data.Zp,equil_magnetic_data.xpoint,equil_magnetic_data.Bt,equil_magnetic_data.Ip,equil_magnetic.psi_apRp*equil_magnetic_data.Rp/equil_magnetic_data.ap,mj,equil_prof_data.pkin,nt,display_mode);
    %
end
%
if n_opt >= 0 &&  e_opt ~= -2,
    %
    equil_prof = equil_prof_jd(profname,type,mrho,mspsin,mspsinT,display_mode,p_opt,dispname,savename,Zeff);
    %
end
%
if exist('mp_magnetic','var'),
    %
    d_opt = input('Do you want to compare the pressure profiles? [y/n] : ','s');
    %
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
        graph1D_jd(mrho,mp_magnetic/1e5,0,0,'','','',{'T_en_e + T_in_i','Equilibrium code'},[0,1],NaN,'-','none','r',2);
        set(gca,'XTick',0:0.2:1);
        print_jd(p_opt,[savename,'_p_comp']);
    end
    %
end
%
% sign management as most equilibrium codes do not account for these.
%
if ~isstruct(signs),
    s_opt = input_dke_yp('Do you want to impose the signs of Bt and Ip [y/n]','n',{'y','n'});
    %
    if strcmp(s_opt,'y'),
        signs.Bt = input_dke_yp('Signs of Bt (positive if clockwise from top)',sign(equil_magnetic.ptBPHI(1,1)),{-1,1});
        signs.Ip = input_dke_yp('Signs of Ip (positive if clockwise from top)',sign(equil_magnetic.psi_apRp(end)),{-1,1});
    else
        signs.Ip = sign(equil_magnetic.psi_apRp(end));
        signs.Bt = sign(equil_magnetic.ptBPHI(1,1));
    end
    %
end
if signs.Ip*equil_magnetic.psi_apRp(end) < 0,
    equil_magnetic.psi_apRp = -equil_magnetic.psi_apRp;
    equil_magnetic.ptBx = -equil_magnetic.ptBx;
    equil_magnetic.ptBy = -equil_magnetic.ptBy;
end
%
if signs.Bt*equil_magnetic.ptBPHI(1,1) < 0,
    equil_magnetic.ptBPHI = -equil_magnetic.ptBPHI;
end
%
% EQUIL structure
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
%
equil.signs = signs;
equil.id = id_equil;
equil.shotnum = shotnum;
equil.shotime = shotime;
%
if e_opt == -1,
    equil.info.eqdsk = [eqdsk_path,eqdsk_file];
elseif e_opt == -2,
    equil.info.datapath = amr_psi_path;
end
%
