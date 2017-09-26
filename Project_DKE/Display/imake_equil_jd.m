function equil = imake_equil_jd(dkepath,basestr,signs,external,workdir,opt_gui,select)
%
% This function interactively builds the equilibrium structure
%
if nargin < 7,
	select = struct;
end
%
if nargin < 6,
	opt_gui = true;
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
if ~isfield(select,'style'),
    select.style = struct;
end
%
select.style.textwidth = 420;
%
eqdsk_path = './';
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
if isfield(select,'i_opt'),
    i_opt = select.i_opt;
elseif isfield(external,'magnetic'),% magnetic equilibrium from external database?
    %
    titletext = 'For the MAGNETIC equilibrium :';      
    s = {'Use data loaded from the external database',...
         'Use data from an existing equilibrium file',...
         'Build the magnetic equilibrium data locally'};
    %    
    i_opt = iselect_jd(s,titletext,opt_gui,select.style,1) - 1;
    %
else
    %
    titletext = 'For the MAGNETIC equilibrium :';      
    s = {'Use data from an existing equilibrium file',...
              'Build the magnetic equilibrium data locally'};
    %    
    i_opt = iselect_jd(s,titletext,opt_gui,select.style,1);
    %
end
% 
if i_opt == 0, % use data from from external database
    %
    shotnum = external.shotnum;
    shotime = external.shotime;
    if ischar(shotime),
        shotimestr = shotime;
        shotime = str2double(shotimestr);
    else
        shotimestr = num2str(shotime,'%6.4f');
    end
    %
    if strcmp(basestr,'TCV') || strcmp(basestr,'EAST') || strcmp(basestr,'HL2A') || strcmp(basestr,'CMOD'),
        %
        if isfield(external.magnetic,'eqdsk'),
            %
            eqdsk = external.magnetic.eqdsk;
            %
        elseif isfield(external.magnetic,'eqdsk_path') && isfield(external.magnetic,'eqdsk_file')
            %
            eqdsk_path = external.magnetic.eqdsk_path;
            eqdsk_file = external.magnetic.eqdsk_file;
            %
            if ~exist(eqdsk_path,'dir'),
                disp(['WARNING : The directory ',eqdsk_path,' does not exist. local directory enforced.'])
                eqdsk_path = './';
            end
            if ~exist([eqdsk_path,eqdsk_file],'file'),
                error(['The file ',eqdsk_path,eqdsk_file,' does not exist. Aborted.'])
            end
            %
            eqdsk = fileread([eqdsk_path,eqdsk_file]);
            %
        end
        %
        e_opt = -1;% eqdsk equilibrium
        %
    elseif strcmp(basestr,'TS'),
        %
        equil_magnetic_data = external.magnetic;
        %
    elseif strcmp(basestr,'COMPASS'),
        %
        equil_magnetic_data = external.magnetic;
        %
        eqdsk.nnx = length(external.magnetic.efit.R);
        eqdsk.nny = length(external.magnetic.efit.Z);
        eqdsk.nnr = length(external.magnetic.efit.psi_n);
        
        eqdsk.xbox = external.magnetic.efit.R(end) - external.magnetic.efit.R(1);% horizontal full-width of the rectangle on which poloidal flux values are given
        eqdsk.ybox = abs(external.magnetic.efit.Z(end) - external.magnetic.efit.Z(1));% vertical full-width of the rectangle on which poloidal flux values are given
        eqdsk.Rv = external.magnetic.efit.R_geom_axis;% nominal major radius of the torus
        eqdsk.Rmin = external.magnetic.efit.R(1);% major radius of the inner edge of the box of rectangular grid
        eqdsk.Zv = 0;% vertical shift of the rectangular box midplane
        %
        eqdsk.Rp = external.magnetic.efit.R_mag_axis;% major radius of magnetic axis
        eqdsk.Zp = external.magnetic.efit.Z_mag_axis;% vertical height of magnetic axis
        eqdsk.psip = external.magnetic.efit.psi_mag_axis;% poloidal flux function value at the magnetic axis 
        eqdsk.psia = external.magnetic.efit.psi_lcfs;% poloidal flux function value at the last closed flux surface (touching the limiter or the separatrix)
        eqdsk.Bv = external.magnetic.efit.B_vac_R_geom*external.magnetic.efit.R_geom_axis/external.magnetic.efit.R_mag_axis;% vacuum toroidal magnetic field at radmaj
        %
        eqdsk.Ip = external.magnetic.efit.Ip;% toroidal current
        %
        eqdsk.rF = external.magnetic.efit.RBphi.';% R*BPHI  at nnr equispaced points in psi from psimag to psilim.
        eqdsk.rp = external.magnetic.efit.p_stat;% pressure values at the same points
        eqdsk.rFdFdpsi = external.magnetic.efit.FFprime;% ffpsiar_prime, [i.e., d f/d (psi)] at the same points
        eqdsk.rdpdpsi = external.magnetic.efit.pprime_static;% p_prime [i.e., d prar/d (psi)] at the same points
        %
        eqdsk.xypsi = external.magnetic.efit.psi_RZ;% psi values on the nnr * nnz equispaced grid
        %
        eqdsk.rq = external.magnetic.efit.q.'; % safety factor q on the equispaced psi grid
        %
        e_opt = -1;% efit equilibrium
        %
    elseif strcmp(basestr,'JET'),
        %
        equil_magnetic_data = external.magnetic;
        %
        e_opt = -3;% standard rz -> pt transformation needed
        %
    elseif strcmp(basestr,'AUG'),
        %
        equil_magnetic_data = external.magnetic;
        %
        e_opt = -4;% standard rz -> pt transformation needed
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
        eqdsk = fileread([eqdsk_path,eqdsk_file]);
        %
        it = strfind(eqdsk_file,'t');
        %
        if (~isempty(strfind(eqdsk_file,'EQDSK.')) || ~isempty(strfind(eqdsk_file,'eqdsk.'))) && ~isempty(it),
            shotnum = eqdsk_file(7:it-1);
            shotimestr = eqdsk_file(it+1:end);
        else
            shotnum = '0';
            shotimestr = '0';
        end
        %
        shotnum_new = input(['Please provide the shot number [',shotnum,'] : '],'s');
        if ~isempty(shotnum_new),
            shotnum = shotnum_new;
        elseif isempty(shotnum),
            shotnum = '0';
        end
        %
        shotime_new = input(['Please provide the shot time [',shotimestr,'] : '],'s');
        if ~isempty(shotime_new),
            shotimestr = shotime_new;
        elseif isempty(shotimestr),
            shotimestr = '0';
        end
        %
        shotime = str2double(shotimestr);
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
            shotimestr = amr_psi_file(it1(1)+1:it2(1)-1);
        else
            disp('-----> The AMR equilibrium file selected is not valid.')
            return
        end
        %
        e_opt = -2;% AMR equilibrium
        n_opt = 0;
        %
        shotime = str2double(shotimestr);
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
    [equil_magnetic_data,shotnum,shotimestr] = imake_equil_ideal(e_opt);
    %
    shotime = str2double(shotimestr);
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
    if isfield(select,'i_opt'),
        i_opt = select.i_opt;
    elseif isfield(external,'prof'),% magnetic equilibrium from external database?
        %
        titletext = 'For the equilibrium PROFILES:';      
        s = {'Use data loaded from the external database',...
             'Use data from an existing equilibrium profiles file',...
             'Build the equilibrium profiles data locally'};
        %    
        i_opt = iselect_jd(s,titletext,opt_gui,select.style,1) - 1;
        %
    else
        %
        titletext = 'For the equilibrium PROFILES:';      
        s = {'Use data from an existing equilibrium profiles file',...
             'Build the equilibrium profiles data locally'};
        %    
        i_opt = iselect_jd(s,titletext,opt_gui,select.style,1);
        %
    end
    % 
    if i_opt == 0, % use data from from external database
        %
        equil_prof_data = external.prof;
        %
        if strcmp(basestr,'TCV'),
            %
            if isfield(equil_prof_data,'shot'),
                type = 1;% TCV collect_parameters_for_luke data format
            else
                type = -2;% TCV MultiTimes database function
                %
                datamod.Zaxis = equil_prof_data.zaxis;
                Ip = - equil_prof_data.ip;
                signs.Bt = - equil_prof_data.btsign;
                signs.Ip = - equil_prof_data.ipsign;
                %
                profname = rmfield(equil_prof_data,{'zaxis','ip','btsign','ipsign'});
                %
            end
            %
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
        elseif strcmp(basestr,'EAST') || strcmp(basestr,'HL2A'),
            %
            type = 1.4;%EAST or HL2A data format
            n_opt = 0;
            %
        elseif strcmp(basestr,'COMPASS'),
            %
            type = 1.6;%COMPASS data format
            n_opt = 0;
            %
        elseif strcmp(basestr,'AUG'),
            %
            type = -2;
            profname = equil_prof_data;
            n_opt = 0;
            %
            if isfield(equil_prof_data,'Ip')
                Ip = equil_prof_data.Ip;
            end
            %
            signs = struct;
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
        [data_file,data_path] = igetfile_jd(opt_gui,'*.*',['Please select the data file for shot ',shotnum,' at time ',shotimestr,' :'],eqdsk_path);
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
                equil_prof_data = load([data_path,data_file],'shot','rho','ne','te','ti','zeff','zaxis','btsign','ipsign','Ip');
                %
            elseif strcmp(basestr,'TS'),% TS profile data file
                %
                type = -1;
                %       
            elseif strcmp(basestr,'ITER'),% ITER Astra profile data
                %
                type = 0.2;
                %
            elseif strcmp(basestr,'EAST') || strcmp(basestr,'HL2A'),% EAST or HL2A profile data
                %
                type = 1.4;
                %
            elseif strcmp(basestr,'COMPASS'),% COMPASS profile data
                %
                type = 1.6;
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
% ************** BUILT EQUILIBRIUM *****************
%
shotid = [basestr,'_',shotnum,'_',shotimestr];
%
if ~isfield(select,'idequil') || ~select.idequil 
    id_equil = input(['Please provide a name for the equilibrium file [',shotid,'] : '],'s');
else
    id_equil = '';
end
%
if isempty(id_equil),
    id_equil = shotid;
end
%
if (~isfield(select,'disp') || ~select.disp) && strcmp(input_dke_yp('Do you want to display the equilibrium','n',{'y','n'},'',[1,1]),'y'),
    display_mode = 2;
else
    display_mode = 1;
end
%
if (~isfield(select,'print') || ~select.print)
    p_opt = input_dke_yp('Option for equilibrium figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
else
    p_opt = -1;
end
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
    datamod.Zaxis = equil_prof_data.zaxis(ishot);
    %
    if any(isnan(equil_prof_data.ti(ishot,:))), 
        datamod.TeTiratio = 6;
    end
    %
    if isscalar(equil_prof_data.zeff(ishot,:)),
        if ~isnan(equil_prof_data.zeff(ishot,:)),
            datamod.Zeff = equil_prof_data.zeff(ishot,:);
        else
            datamod.Zeff = 3;
        end
    end
    %
    if isfield(equil_prof_data,'Ip') 
        datamod.Ip = - equil_prof_data.Ip(ishot)/1e6;
    else
        datamod.Ip = NaN;
    end
    %
    s = struct;
    %
    s.expert.Zaxis = 0;
    s.expert.TeTiratio = 0;
    s.expert.Zeff = 0;    
    s.expert.Ip = 0;    
    %
    datamod = imod_struct_jd(datamod,'equil.data',1,opt_gui,s,select.style);
    %
    if isfield(datamod,'TeTiratio')%constant Te/Ti ratio
        pTi = pTe/datamod.TeTiratio;
    else
        pTi = equil_prof_data.ti(ishot,:);
    end
    %
    if isfield(datamod,'Zeff'),%uniform profile
        pZeff = datamod.Zeff*ones(size(prho));
    else
        pZeff = equil_prof_data.zeff(ishot,:);
    end
    %
    Ip = datamod.Ip*1e6;
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
elseif type == 1.4 && n_opt == 0,%EAST or HL2A
    %
    profname = [id_equil,'.prof'];
    %
    Zeff = equil_prof_data.species.Zeff;
    TeTi = equil_prof_data.TeTi;
    frac_H = equil_prof_data.species.frac_H;
    frac_D = equil_prof_data.species.frac_D;
    Zimp = equil_prof_data.species.Zimp;
    Aimp = equil_prof_data.species.Aimp;
    %
    if isfield(external,'thomson') == 1 & isfield('equil_prof_data.','rho') == 1,
        thomson_mode = input_dke_yp('Do you want to calculate Te and ne profiles from raw Thomson scattering measurements','n',{'y','n'},'',[1,1]),'y');
    elseif isfield(external,'thomson') == 1 & isfield('equil_prof_data.','rho') == 0,
        thomson_mode = 1;
    elseif isfield(external.equil,'thomson') == 0 & isfield('equil_prof_data.','rho') == 1,
        thomson_mode = 0;
    end
    %
    if thomson_mode == 1
        save(profname,'frac_H','frac_D','Zimp','Aimp','Zeff','-mat');
    else
        prho = equil_prof_data.rho;
        pne = equil_prof_data.ne;
        pTe = equil_prof_data.Te;
        pTi = pTe/TeTi;
        %
        save(profname,'prho','pne','pTe','pTi','frac_H','frac_D','Zimp','Aimp','Zeff','-mat');
        %
    end
    %
    % sign management as most equilibrium codes do not account for these.
    %
    if ~isstruct(signs) 
		if isfield(external,'jbdirections'),
            if strcmp(external.jbdirections.Ip,'clockwise')
                signs.Ip = 1;
            else
                signs.Ip = -1;
            end
            %
            if strcmp(external.jbdirections.Bt,'clockwise')
                signs.Bt = 1;
            else
                signs.Bt = -1;
            end
        end
    end
    %
elseif type == 1.6 && n_opt == 0,%COMPASS
    %
    profname = [id_equil,'.prof'];
    %
    pspsin = equil_prof_data.pspsin;
    pne = equil_prof_data.pne.';
    pTe = equil_prof_data.pTe.';
    pTi = equil_prof_data.pTi.';
    Zeff = equil_prof_data.Zeff;
    zZi = equil_prof_data.zZi;
    zmi = equil_prof_data.zmi;
    fi = equil_prof_data.fi;
    %
    save(profname,'pspsin','pne','pTe','pTi','Zeff','zZi','zmi','fi','-mat');
    %
end
%
if e_opt >= 0 || (e_opt <= -2 && e_opt >= -3),
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
    if isfield(select,'busyhandle'),
        set(select.busyhandle,'Visible','on');drawnow;
    end
    [equil_magnetic,mrho,mspsin,mspsinT,mp_magnetic] = equil_magnetic_EFIT_jd(eqdsk,display_mode,p_opt,dispname,savename);
    %
    if isfield(select,'busyhandle'),
        set(select.busyhandle,'Visible','off');drawnow;
    end
    %
    [np,nt] = size(equil_magnetic.ptx);
    %
    % Correction for the equilibrium offset
    %
    if ~exist('datamod','var'),
        Zp_offset = iselect_jd({},'Vertical equilibrium offset (vacuum)',opt_gui,select.style,Zaxis,'edit');
        if isempty(Zp_offset) || ~isnumeric(Zp_offset),
            Zp_offset = Zaxis;
        end
        equil_magnetic.Zp = equil_magnetic.Zp + Zp_offset;
        %
    else
        equil_magnetic.Zp = datamod.Zaxis;
    end
    %
elseif e_opt == -2,% AMR equilibrium
    %
    [equil_magnetic,equil_prof] = make_equil_AMR_jd(amr_psi_path,shotnum,shotimestr,display_mode,p_opt,dispname,savename,np,nt);
    %
elseif e_opt == -3,% standard rz -> pt transformation needed
    %
    [equil_magnetic,mrho,mspsin,mspsinT] = equil_magnetic_rz2pt_jd(equil_magnetic_data,display_mode,p_opt,dispname,savename,np,nt);
    %
elseif e_opt == -4,% standard rz -> pt transformation needed
    %
    [equil_magnetic,mrho,mspsin] = equil_magnetic_AUG_jd(equil_magnetic_data);
    mspsinT = [];
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
    if strcmp(basestr,'EAST') & thomson_mode == 1
        %
        equil_magnetic_nete = EAST_thomson_scattering_Tene_fit(equil_magnetic,external.thomson.prof.R_ts,external.thomson.prof.Z_ts,external.thomson.prof.Te_ts,external.thomson.prof.dTe_ts,external.thomson.prof.ne_ts,external.thomson.prof.dne_ts,display_mode-1);%Add Te and ne profiles from Thomson scattering
        %
        prho = mrho;
        pTe = equil_magnetic_nete.pTe';
        pne = equil_magnetic_nete.pne';
        %
        pTi = pTe/TeTi;
        %
        save([savename,'.prof'],'prho','pne','pTe','pTi','-append');
        %
    end
    %
    equil_prof = equil_prof_jd(profname,type,mrho,mspsin,mspsinT,display_mode,p_opt,dispname,savename,Zeff);
    %
end
%
if exist('mp_magnetic','var'),
    %
    if (~isfield(select,'comp') || ~select.comp) && strcmp(input_dke_yp('Do you want to compare the pressure profiles','n',{'y','n'},'',[1,1]),'y'),
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
        signs = struct;
    end
end
if ~isfield(signs,'Ip'),
    signs.Ip = sign(equil_magnetic.psi_apRp(end));
end
if ~isfield(signs,'Bt'),
    signs.Bt = sign(equil_magnetic.ptBPHI(1,1));
end
%
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
equil.tokamak = basestr;
equil.shotnum = shotnum;
equil.shotime = shotime;
%
if exist('Ip','var'),
	equil.ip = Ip;
else
	equil.ip = NaN;
end
%
if e_opt == -1 && exist('eqdsk_file','var'),
    equil.info.eqdsk = [eqdsk_path,eqdsk_file];
elseif e_opt == -2,
    equil.info.datapath = amr_psi_path;
end
%
%
if (~isfield(select,'consist') || ~select.consist) && strcmp(input_dke_yp('Do you want to check the equilibrium consistency','n',{'y','n'},'',[1,1]),'y'),
    equil = equilconsistency_yp(equil,'',1);
end
%
equil.info.txt = {...
    ['Plasma major radius (m)               : ',num2str(equil.Rp)],...
    ['Plasma vertical position (m)          : ',num2str(equil.Zp)],...
    ['Plasma minor radius (m)               : ',num2str(equil.ptx(end,1))],...
    ['Magnetic field on axis (T)            : ',num2str(equil.ptBPHI(1,1))],...
    ['Poloidal flux on LCFS (W)             : ',num2str(equil.psi_apRp(end)*2*pi*equil.Rp/equil.ptx(end,1))],...
    ['Plasma current (MA)                   : ',num2str(equil.ip/1e6)],...
    ['Central electron temperature (keV)    : ',num2str(equil.pTe(1))],...
    ['Central electron density (10^19 m^-3) : ',num2str(equil.pne(1)/1e19)]};
%



