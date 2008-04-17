function irunluke_jd(basestr,signs,opt_gui)
%
% This script interactively loads the equilibrium, profiles and launching data, and runs LUKE with
% either C3PO, TORAY or ART ray-tracing data.
%
if nargin < 3,
    opt_gui = 1;
end
%
if nargin < 2,
    signs = '';
end
%
clc
%
quitmsg = '-----> Run aborted';
warning off
%
isel = 1;
%
status.data = 0;
status.dkepath = 0;
status.dkeparam = 0;
status.equil = 0;
status.waves = 0;
status.ohm = 0;
status.transpfaste = 0;
status.output = 0;
%
datafile = '';
dkepath = '';
dkeparam = '';
equil = '';
waves = '';
ohm = '';
transpfaste = '';
output = '';
%
workdir = [pwd,'/'];
%
while isel >= 0,
    %
    % CLEAR outdated structures and DEFINE STATUS
    %
    if status.data == 1,
        statstr.data = datafile;
    elseif status.data == 2,
        statstr.data = [datafile,' < data modified, consider a save >'];
    else 
        statstr.data = '< No data yet >';
    end
    %
    statstr.workdir = workdir;
    %
    if status.dkepath == 1,
        statstr.dkepath = [dkepath_path,dkepath_file];
    else
        if ~isempty(dkepath),
            disp('The structure ''dkepath'' is outdated and cleared.');
            dkepath = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.dkepath = ['<',ostr,' Must load path structure >'];
    end
    %
    if status.dkeparam == 1,
        statstr.dkeparam = [dkeparam_path,dkeparam_file];
    else
        if ~isempty(dkeparam),
            disp('The structure ''dkeparam'' is outdated and cleared.');
            dkeparam = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.dkeparam = ['<',ostr,' Must load dkeparam structure >'];
    end
    %
    if status.equil == 1,
        statstr.equil = equil.id;
    else 
        if ~isempty(equil),
            disp('The structure ''equil'' is outdated and cleared.')
            equil = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.equil = ['<',ostr,' Must load/create equilibrium structure >'];
    end
    %
    if status.waves == 1,
        statstr.waves = waves{1}.id;
        for iw = 2:length(waves),
            statstr.waves = [statstr.waves,'; ',waves{iw}.id];
        end
    else 
        if ~isempty(waves),
            disp('The structure ''waves'' is outdated and cleared.')
            waves = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.waves = ['<',ostr,' The ''waves'' structure is optional >'];
    end
    %
    if status.ohm == 1,
        statstr.ohm = ohm.id;
    else 
        if ~isempty(ohm),
            disp('The structure ''ohm'' is outdated and cleared.')
            ohm = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.ohm = ['<',ostr,' The ''ohm'' structure is optional >'];
    end
    %
    if status.transpfaste == 1,
        statstr.transpfaste = transpfaste.id;
    else 
        if ~isempty(transpfaste),
            disp('The structure ''transpfaste'' is outdated and cleared.')
            transpfaste = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.transpfaste = ['<',ostr,' The ''transpfaste'' structure is optional >'];
    end
    %
    if status.output == 1,
        statstr.output = id_simul;
    else 
        if ~isempty(output),
            disp('The structure ''output'' is outdated and cleared.')
            output = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end   
        %
        if ~isempty(dkepath) & ~isempty(dkeparam) & ~isempty(equil),
            %
            statstr.output = ['<',ostr,' You can start LUKE now. >'];
            %
        else
            %
            statstr.output = ['<',ostr,' First build required structures. >'];
            %
        end
    end
    %
    if ~isempty(equil),
        id_simul_o = equil.id;
    else
        id_simul_o = basestr;
    end
    for iw = 1:length(waves),
        id_simul_o = [id_simul_o,'_',waves{iw}.id];
    end
    if ~isempty(ohm),
        id_simul_o = [id_simul_o,'_',ohm.id];
    end
    if ~isempty(transpfaste),
        id_simul_o = [id_simul_o,'_',transpfaste.id];
    end
    %
    % MAIN MENU
    %
    disp(' ');
    disp(' ');
    disp('************* STATUS *************')
    disp(' ');
    disp(['LUKE data              : ',statstr.data]);
    disp(['Work directory         : ',statstr.workdir]);
    disp(['LUKE PATH              : ',statstr.dkepath]);
    disp(['LUKE parameters        : ',statstr.dkeparam]);
    disp(['Equilibrium            : ',statstr.equil]);
    disp(['RF waves               : ',statstr.waves]);
    disp(['Ohmic E-field          : ',statstr.ohm]);
    disp(['Fast electron transport: ',statstr.transpfaste]);
    disp(' ');
    disp(['LUKE output            : ',statstr.output]);
    disp(' ');
    disp('************** MENU **************')
    disp(' ');
    disp('Please select one of the following options:');
    disp(' ');
    disp('[1]  Load existing data file');
    disp('[2]  Save current data in file');
    disp('[3]  Specify work directory');
    disp('[4]  Load/create LUKE PATH structure');
    disp('[5]  Load/modify LUKE parameters');
    disp('[6]  Load/create LUKE equilibrium structure');
    disp('[7]  Load/create LUKE wave structures (RF waves)');
    disp('[8]  Load/create LUKE ohm structure (Ohmic E-field)');
    disp('[9]  Load/create LUKE transpfaste structure (Fast electron transport)');
    disp(' ');
    disp('[10] Display LUKE equilibrium data');
    disp('[11] Display LUKE RF wave data');
    disp('[12] Display LUKE results');
    disp('[13] Calculate HXR emission');
    disp(' ');
    disp('[14] Go to command line')
    disp(' ');
    disp('[0]  Run LUKE');
    disp('[-1] Exit LUKE');
    disp(' ');
    %
    isel = input('? [-1] :');
    %
    clc
    %
    if isempty(isel) | ~isnumeric(isel) | ~any(isel == [-1:14]),
        isel = -1;
    end
    %
    try
        %
        if isel == 1,
            %
            % LOAD DATA FILE
            %
            disp('');
            disp('************** LOAD DATA FILE **************')
            disp('');
            %
            [data_file,data_path] = igetfile_jd(opt_gui,{'LUKE_DATA_*.mat';'LUKE_RESULTS_*.mat'},'Please select a LUKE data file');
            %
            if data_file == 0,
                disp('-----> No LUKE data file specified.');
            else
				if strfind(data_file,'LUKE_DATA_'),
					datafile = [data_path,data_file];
					load(datafile);
					disp(['-----> The data file ',datafile,' is loaded.']);
					%
					status.data = 1;
					%
				elseif strfind(data_file,'LUKE_RESULTS_'),
					datafile = [data_path,data_file];
					data = load(datafile,'id_simul','dkepath','dkeparam','dkedisplay','equil','waves','ohm','transpfaste',...
						'Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource');
					disp(['-----> The data file ',datafile,' is loaded.']);
					%
					id_simul = data.id_simul;
					%
					dkepath = data.dkepath;
					dkepath_path = data_path;
					dkepath_file = data_file;
					%
					dkeparam = data.dkeparam;
					dkeparam_path = data_path;
					dkeparam_file = data_file;
					%
					dkedisplay = data.dkedisplay;
					%
					equil = data.equil;
					%
					output.Znorm = data.Znorm;
					output.Zcurr = data.Zcurr;
					output.ZP0 = data.ZP0;
					output.dke_out = data.dke_out;
					output.radialDKE = data.radialDKE;
					output.equilDKE = data.equilDKE;
					output.momentumDKE = data.momentumDKE;
					output.gridDKE = data.gridDKE;
					output.Zmomcoef = data.Zmomcoef;
					output.Zbouncecoef = data.Zbouncecoef;
					output.Zmripple = data.Zmripple;
					output.mksa = data.mksa;
					output.XXsinksource = data.XXsinksource;  
					%
					status.dkeparam = 1;
					status.dkepath = 1;
					status.equil = 1;
					status.output = 1;
					%
					if isfield(data,'waves'),
						waves = data.waves;
						status.waves = 1;
					end
					%
					if isfield(data,'ohm'),
						ohm = data.ohm;
						status.ohm = 1;
					end
					%
					if isfield(data,'transpfaste'),
						transpfaste = data.transpfaste;
						status.transpfaste = 1;
					end
					%
					status.data = 2;
					%
					clear data
					%
				else
					disp('-----> Invalid LUKE data file.');
					continue
				end  
				%
				workdir = data_path;
				%
				setpath_luke_jd(dkepath.luke_root,dkepath);
				%
			end
            %
        elseif isel == 2,
            %
            % SAVE DATA FILE
            %
            disp(' ');
            disp('************** SAVE DATA FILE **************')
            disp(' ');
            %
            sd = pwd;
            cd(workdir);
            %
            [data_file,data_path] = iputfile_jd(opt_gui,'LUKE_DATA_*.mat','Please provide select a LUKE data file name',[workdir,'LUKE_DATA_',id_simul_o,'.mat']);
            %
            if data_file == 0,
                disp('-----> No LUKE data file specified.');
            else
                newdatafile = [data_path,data_file];
                if ~isempty(datafile) & ~strcmp(datafile,newdatafile),
                    c_opt = input('The data file name has changed. Do you want to keep old data file (y/n)? [n] : ','s');
                    if ~strcmp(c_opt,'y'),
                        delete(datafile)
                        disp(['-----> The file ',datafile,' has been deleted']);
                    end
                end
                %
                datafile = newdatafile;
                %
                save(datafile);
                disp(['-----> The data are saved in file ',datafile,'.']);
                %
                workdir = data_path;
                status.data = 1;
            end  
            %
            cd(sd);
            %
        elseif isel == 3,
            %
            % WORKING DIRECTORY
            %
            disp(' ');
            disp('************** WORK DIRECTORY **************')
            disp(' ');
            newworkdir = igetdir_jd(opt_gui,'Please select the work directory',workdir); 
            %
            if newworkdir == 0,
                disp('-----> No work directory specified.');
            else
                %
                if ~strcmp(newworkdir,workdir) 
                    disp(['-----> The working directory is : ',newworkdir]);
                    %
                    if status.data >= 1,
                        disp('-----> The working directory has changed, consider saving data.');
                        datafile = '';
                    end
                    % 
                end
                %
                workdir = newworkdir;
                %
            end
            %
        elseif isel == 4,
            %
            % PATH
            %
            id_dkepath = 'LOCAL';%For all paths used by DKE solver
            dkepath_file = which('PATH_LOCAL.mat');%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
            %
            [dkepath_file,dkepath_path] = igetfile_jd(opt_gui,'PATH_*.mat','Please select the PATH file containing dkepath',dkepath_file);
            if dkepath_file == 0,
                disp('-----> No LUKE PATH file specified.')
            else
                %
                id_dkepath = dkepath_file(6:end-4);
                %
                dkepath = load_structures_yp('dkepath',id_dkepath,dkepath_path);
                %
                status.output = 0;
                status.dkepath = 1;
                status.data = 2;
                %                
            end
            %
        elseif isel == 5,
            %
            % LUKE PARAMETERS
            %
            disp(' ');
            disp('************** LUKE PARAMETERS **************')
            disp(' ');
            %
            newpar = 0;
            %
            if status.equil == 1;
                param_id = equil.id;
            else
                param_id = basestr;
            end
            %
            if exist([workdir,'/DKEPARAM_',param_id,'.mat']),
                dkeparam_file = [workdir,'/DKEPARAM_',param_id,'.mat'];
            else
                if strcmp(basestr,'TCV'),
                    dkeparam_file = 'DKEPARAM_EC_RT.mat';
                else
                    dkeparam_file = 'DKEPARAM_LH_RT.mat';
                end
                dkeparam_file = which(dkeparam_file);    
            end
            %
            [dkeparam_file,dkeparam_path] = igetfile_jd(opt_gui,'DKEPARAM_*.mat',['Please select the dkeparam default parameters file'],dkeparam_file);
            %
            if dkeparam_file == 0,
                disp('-----> No LUKE parameters structure specified.')
            else
                %
                load([dkeparam_path,dkeparam_file],'dkeparam');
                disp('-----> The dkeparam structure is loaded')
                %
                newpar = 1;
                %
                if ~isfield(dkeparam,'rho_S'),
                    dkeparam.rho_S = 20;
                end
                %
                c_opt = input('Do you want to see/modify the LUKE parameters (y/n)? [n] : ','s');
                if strcmp(c_opt,'y'),
                    dkeparam,
                    %
                    fname = input('Name of dkeparam field to modify (press enter if finished): ','s');
                    while fname ~= 0,
                        %
                        if isfield(dkeparam,fname),
                            eval(['f_val_o = dkeparam.',fname,';']);
                            if isnumeric(f_val_o),
                                f_val_o_s = num2str(f_val_o);
                            else
                                f_val_o_s =f_val_o;
                            end
                            f_val = input(['Provide value for field ',fname,' [',f_val_o_s,'] : ']);
                            if isempty(f_val),
                                f_val = f_val_o;
                            end
                            eval(['dkeparam.',fname,' = f_val;']);
                        end
                        %
                        fname = input('Name of dkeparam field to modify (press enter if finished): ','s');
                    end
                    %
                    s_opt = input('Do you want to save the dkeparam structure separately (y/n)? [n] : ','s');
                    if strcmp(s_opt,'y'),
                        sd = pwd;
                        cd(workdir);
                        [save_file,save_path] = iputfile_jd(opt_gui,['DKEPARAM_',param_id,'*.mat'],'Please provide the DKEPARAM file name',['DKEPARAM_',param_id,'.mat']);
                        %
                        if save_file == 0,
                            disp('-----> No file name specified, dkeparam structure not saved.')
                        else
                            save([save_path,save_file],'dkeparam');
                            disp('-----> The dkeparam structure is saved')
                        end
                        cd(sd);
                    end 
                    %
                end
            end
            %
            if newpar == 1,
                status.dkeparam = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 6,
            %
            % EQUILIBRIUM 
            %
            disp(' ');
            disp('************** EQUILIBRIUM **************')
            disp(' ');
            %
            neweq = 0;
            %
            l_opt = input('Do you want to load an existing LUKE equilibrium (y/n)? [n] : ','s');
            if strcmp(l_opt,'y'),
                [equil_file,equil_path] = igetfile_jd(opt_gui,'EQUIL_*.mat','Please select the EQUIL file',workdir);
                %
                if equil_file == 0,
                    disp('-----> No equilibrium structure specified.')
                else
                    %
                    load([equil_path,equil_file],'equil');
                    disp('-----> The equilibrium structure is loaded')
                    %
                    neweq = 1;
                    %
                end  
                %
            else
                equil = imake_equil_jd(workdir,basestr,signs,opt_gui);
                %
                if ~isempty(equil),
                    %
                    disp('-----> The equilibrium structure is created')
                    %
                    e_opt = input('Do you want to save the equilibrium structure separately (y/n)? [n] : ','s');
                    if strcmp(e_opt,'y'),
                        sd = pwd;
                        cd(workdir);
                        [equil_file,equil_path] = iputfile_jd(opt_gui,'EQUIL_*.mat','Please provide the EQUIL file name',['EQUIL_',equil.id,'.mat']);
                        %
                        if equil_file == 0,
                            disp('-----> No file name specified, equilibrium structure not saved.')
                        else
                            save([equil_path,equil_file],'equil');
                            disp('-----> The equilibrium structure is saved')
                        end
                        cd(sd);
                    end
                    %
                    neweq = 1;
                    %
                end
            end
            %
            if neweq == 1,
                status.equil = 1;
                status.waves = 0;
                status.ohm = 0;
                status.transp = 0;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 7,
            %
            % WAVES
            %
            if status.equil == 0;
                disp('-----> An equilibrium structure must exist to create wave structures.');
                continue
            end
            %
            disp(' ');
            disp('************** WAVES **************')
            disp(' ');
            %
            newwaves = 0;
            %
            if ~isempty(waves),
                l_opt = input('Do you want to check existing wave structures (y/n)? [n] : ','s');
                %
                if strcmp(l_opt,'y'),
                    %
					iw_list = [];
					%
                    for iw = 1:length(waves),
                        w_opt = input(['Do you want to clear the wave structure ',waves{iw}.id,' (y/n)? [n] : '],'s');
                        %
                        if strcmp(w_opt,'y'),
                            disp(['-----> The wave structure ',waves{iw}.id,' is cleared.'])
                            %
                            iw_list = [iw_list,iw];
                        end
                    end
					%
					if ~isempty(iw_list),
						%
						waves(iw_list) = [];
						%
						status.output = 0;
						status.data = 2;
					end
					%
                    if isempty(waves)
                        status.waves = 0;
                    end
                    %
                end
                %
            end
            %
            l_opt = input('Do you want to load existing WAVE structures (y/n)? [n] : ','s');
            if strcmp(l_opt,'y'),
                %
                [wave_file,wave_path] = igetfile_jd(opt_gui,['WAVE_',equil.id,'_*.mat'],'Please select the WAVE files',workdir,1);
                %
                if ~iscell(wave_file) & wave_file == 0,
                    disp('-----> No wave structure specified.')
                else  
                    %
                    newwaves = 1;
                    %
                    while iscell(wave_file) | wave_file ~= 0,
                        %
                        if iscell(wave_file) == 0,
                                load([wave_path,wave_file],'wave');
                                waves = [waves,{wave}];
                                disp(['-----> The wave structure :',wave_path,wave_file,' is loaded'])
                        else
                            %
                            for iw = 1:length(wave_file),
                                load([wave_path,wave_file{iw}],'wave');
                                waves = [waves,{wave}];
                                disp(['-----> The wave structure :',wave_path,wave_file{iw},' is loaded'])
                            end
                        end
                        %
                %         w_opt = input('Do you want to plot the wave data (y/n)? [n] : ','s');
                %         if strcmp(w_opt,'y'),
                %             graph_wave_jd();
                %         end
                        %
                        [wave_file,wave_path] = igetfile_jd(opt_gui,['WAVE_',equil.id,'_*.mat'],'Load additional WAVE files (cancel if finished)',workdir,1);
                        %
                    end
                end
                %
                clear wave wave_file wave_path
                %
            end
            %
            l_opt = input('Do you want to build a new WAVE structures (y/n)? [n] : ','s');
            %
            while strcmp(l_opt,'y'),
                %
                wave = imake_wave_jd(workdir,basestr,equil,opt_gui);
                %
                if isempty(wave),
                    disp('-----> Current wave structure construction aborted')
                    %
                    l_opt = input('Do you want to build a new WAVE structures (y/n)? [n] : ','s');
                    %
                    continue
                end
                %
                disp('-----> The wave structure is created')
                %
                newwaves = 1;
                %
                w_opt = input('Do you want to save the wave structure separately (y/n)? [n] : ','s');
                if strcmp(w_opt,'y'),
                    sd = pwd;
                    cd(workdir);
                    [wave_file,wave_path] = iputfile_jd(opt_gui,['WAVE_',equil.id,'*.mat'],'Please provide the WAVE file name',['WAVE_',equil.id,'_',wave.id,'.mat']);
                    %
                    if wave_file == 0,
                        disp('-----> No file name specified, wave structure not saved.')
                    else
                        save([wave_path,wave_file],'wave');
                        disp('-----> The wave structure is saved')
                    end
                    cd(sd);
                end
                %
                waves = [waves,{wave}];
                %
                l_opt = input('Do you want to build a new WAVE structures (y/n)? [n] : ','s');
            end
            %
            if newwaves == 1,
                status.waves = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 8,
            %
            % OHM
            %
            if status.equil == 0;
                disp('-----> An equilibrium structure must exist to create an ohm structure.');
                continue
            end
            %
            disp(' ');
            disp('************** OHM **************')
            disp(' ');
            %
            newohm = 0;
            %
            if ~isempty(ohm),
                o_opt = input('Do you want to clear the existing OHM structures (y/n)? [n] : ','s');
                %
                if strcmp(o_opt,'y'),
                    disp('-----> The ohm structure is cleared.')
                    status.ohm = 0;
                    status.output = 0;
                    status.data = 2;
                end
                %
            end
            %    
            o_opt = input('Do you want to load an existing OHM structures (y/n)? [n] : ','s');
            %
            if strcmp(o_opt,'y'),
                %
                [ohm_file,ohm_path] = igetfile_jd(opt_gui,['OHM_',equil.id,'_*.mat'],'Please select the OHM file',workdir);
                %
                if ohm_file == 0,
                    disp('-----> No ohm structure specified.')
                else
                    %
                    load([ohm_path,ohm_file],'ohm');
                    disp(['-----> The ohm structure :',ohm_path,ohm_file,' is loaded'])
                    %
                    newohm = 1;
                    %
                end  
            else
                %
                l_opt = input('Do you want to build a OHM structure (y/n)? [n] : ','s');
                %
                if strcmp(l_opt,'y'),
                    %
                    ohm = imake_ohm_jd(basestr,equil);
                    %
                    if ~isempty(ohm),
                        %
                        disp('-----> The ohm structure is created')
                        %
                        newohm = 1;
                        %
                        o_opt = input('Do you want to save the ohm structure separately (y/n)? [n] : ','s');
                        if strcmp(o_opt,'y'),
                            sd = pwd;
                            cd(workdir);
                            [ohm_file,ohm_path] = iputfile_jd(opt_gui,['OHM_',equil.id,'*.mat'],'Please provide the OHM file name',['OHM_',equil.id,'_',ohm.id,'.mat']);
                            %
                            if ohm_file == 0,
                                disp('-----> No file name specified, ohm structure not saved.')
                            else
                                save([ohm_path,ohm_file],'ohm');
                                disp('-----> The ohm structure is saved')
                            end
                            cd(sd);
                        end
                    end
                    %
                end
            end
            %
            if newohm == 1,
                status.ohm = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 9,
            %
            % TRANSPORT parameters
            %
            if status.equil == 0;
                disp('-----> An equilibrium structure must exist to create a transp structure.');
                continue
            end
            %
            disp(' ');
            disp('************** FAST ELECTRON TRANSPORT **************')
            disp(' ');
            %
            newtransp = 0;
            %
            if ~isempty(transpfaste),
                t_opt = input('Do you want to clear the existing transp structures (y/n)? [n] : ','s');
                %
                if strcmp(t_opt,'y'),
                    disp('-----> The transp structure is cleared.')
                    status.transpfaste = 0;
                    status.output = 0;
                    status.data = 2;
                end
                %
            end
            %
            t_opt = input('Do you want to load an existing TRANSP structures (y/n)? [n] : ','s');
            if strcmp(t_opt,'y'),
                %
                [transp_file,transp_path] = igetfile_jd(opt_gui,['TRANSP_',equil.id,'_*.mat'],'Please select the TRANSP file',workdir);
                %
                if transp_file == 0,
                    disp('-----> No transp structure specified.')
                else
                    %
                    load([transp_path,transp_file],'transpfaste');
                    disp(['-----> The transpfaste structure :',transp_path,transp_file,' is loaded'])
                    %
                    newtransp = 1;
                    %
                end  
                %
            else
                %
                l_opt = input('Do you want to build a TRANSP structure (y/n)? [n] : ','s');
                %
                if strcmp(l_opt,'y'),
                    %
                    transpfaste = imake_transp_jd(basestr,equil);
                    %
                    if ~isempty(transpfaste),
                        %
                        disp('-----> The transpfaste structure is created')
                        %
                        newtransp = 1;
                        %
                        t_opt = input('Do you want to save the transpfaste structure (y/n)? [n] : ','s');
                        if strcmp(t_opt,'y'),
                            sd = pwd;
                            cd(workdir);
                            [transp_file,transp_path] = iputfile_jd(opt_gui,['TRANSP_',equil.id,'*.mat'],'Please provide the OHM file name',['TRANSP_',equil.id,'_',transpfaste.id,'.mat']);
                            %
                            if transp_file == 0,
                                disp('-----> No file name specified, transpfaste structure not saved.')
                            else
                                save([transp_path,transp_file],'transpfaste');
                                disp('-----> The transpfaste structure is saved')
                            end
                            cd(sd);
                        end
                        %
                    end
                end
            end
            %
            if newtransp == 1,
                status.transpfaste = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 10,
            %
            % DISPLAY LUKE EQUILIBRIUM
            %
            if status.equil == 1,
                equilibrium_jd(equil,NaN,2);
            else
                disp('-----> The equilibrium structure does not exist.');
            end
            %
        elseif isel == 11,
            %
            % DISPLAY WAVE DATA
            %
            if status.waves == 1,
                %
                p_opt = input('Option for output figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
                if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
                    p_opt = -1;
                end
                %
                g_opt.print = p_opt;
                g_opt.TeNpar = 0;
                g_opt.abs_max = 1;
                nr_dep = 40;
                %
                graph_wave_jd(equil,waves,'','',nr_dep,g_opt);
            else
                disp('-----> The equilibrium structure does not exist.');
            end
            %
        elseif isel == 12,
            %
            % DISPLAY LUKE RESULTS
            %
            if status.output == 1,
                %
                ir_display = input(['Index of flux-surface for distribution (1-',num2str(length(output.equilDKE.xrho)),', 0 to skip) ? [0] : ']);
                if isempty(ir_display) | ~isnumeric(ir_display) | ir_display > length(output.equilDKE.xrho),
                    ir_display = 0;
                end
                %
                pnmax = input(['Maximum value of p/pT for display: (-1) auto, (0) grid, or specify (0-',num2str(dkeparam.pnmax_S),')? [0] : ']);
                if isempty(pnmax),
					pnmax = 0;
				end
				%
				if ~isnumeric(pnmax) | (~any(pnmax == [0,-1]) & (pnmax < 0 | pnmax > dkeparam.pnmax_S)),
                    disp('-----> Invalid choice.');
					continue
                end
                %
				if pnmax == -1,
					pnmax = NaN;
				elseif pnmax == 0,
					pnmax = dkeparam.pnmax_S;
				end
				%
                p_opt = input('Option for output figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
                if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
                    p_opt = -1;
                end
                %
				dp_cyl = 0.1;
				%
                sd = pwd;
                cd(workdir)
                proc_luke_jd(output,ir_display,p_opt,dp_cyl,pnmax);
                cd(sd);
            else
                disp('-----> The output structure does not exist.');
            end
            %
        elseif isel == 13,
            %
            % CALCULATE HXR EMISSION
            %
            if status.output == 0;
                disp('-----> First run LUKE!');
                continue
            end
            %
            irunhxr_jd(workdir,basestr,'',id_simul,equil,dkeparam,dkedisplay,output);
            %
        elseif isel == 14,
            %
            disp('-----> Type ''return'' to return to menu');    
            disp('-----> Type ''dbquit'' to abort run and leave workspace.');
            disp(' ');
            keyboard
            %
        elseif isel == 0,
            %
            % RUN LUKE
            %    
            if isempty(dkepath) | isempty(dkeparam) | isempty(equil),
                disp('-----> the structures dkepath, dkeparam and equil must exist to run LUKE.');
                continue
            end       
            %
            % DISPLAY
            %
            dkedisplay_file = 'DISPLAY_PARTIAL_VISUAL.mat';
            dkedisplay_file = which(dkedisplay_file);
            if isempty(dkedisplay_file),
                disp(quitmsg)
                return
            end
            load(dkedisplay_file,'dkedisplay');
            %
            display_mode = input('Option for run evolution display: 0 (none), 1 (partial), 2 (full) [0] : ');
            if isempty(display_mode) | ~isnumeric(display_mode) | ~any(display_mode == [0,1,2]),
                display_mode = 0;
            end
            dkedisplay.display_mode = display_mode; 
            %
    %     %
    %     % OTHER RUN PARAMETERS
    %     %
    %     rho_S = input('Please specify the radial grid: \nautomatic (provide number of points) \nmanual (vector of points from 0 to 1) \n[20] : ');
    %     if isempty(rho_S),
    %         rho_S = 20;
    %     end
    %     if ~isnumeric(rho_S),
    %         disp('-----> Invalid radial grid specification');
    %         return
    %     end
            %
            psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
            %
            p_opt = input('Option for output figures? -1 (nothing), 0 (print), 1 (print and save), 2 (save) [-1] : ');
            if isempty(p_opt) | ~isnumeric(p_opt) | ~any(p_opt == [0,1,2]),
                p_opt = -1;
            end
            %
            if exist('dmumpsmex');%MUMPSMEX
                dkeparam.invproc = -2;
            end
            %
            id_simul = input(['Please provide a name for the run [',id_simul_o,'] : '],'s');
            if isempty(id_simul),
                id_simul = id_simul_o;
            end
            %
            ripple = '';
            %
            disp(' ');
            disp('************** RUN LUKE **************')
            disp(' ');
            %
            [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,[],waves,psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0);
            %
            output.Znorm = Znorm;
            output.Zcurr = Zcurr;
            output.ZP0 = ZP0;
            output.dke_out = dke_out;
            output.radialDKE = radialDKE;
            output.equilDKE = equilDKE;
            output.momentumDKE = momentumDKE;
            output.gridDKE = gridDKE;
            output.Zmomcoef = Zmomcoef;
            output.Zbouncecoef = Zbouncecoef;
            output.Zmripple = Zmripple;
            output.mksa = mksa;
            output.XXsinksource = XXsinksource;  
            %
            clear Znorm Zcurr ZP0 dke_out radialDKE equilDKE momentumDKE gridDKE Zmomcoef Zbouncecoef Zmripple mksa XXsinksource
            %	    
            % GRAPHIC OUTPUT
            %
            scocurr = sign(equil.psi_apRp(end))*sign(equil.ptBPHI(1,1));
            %
            I_tot = sum(output.Zcurr.x_0_fsav.*output.equilDKE.xdA_dke*output.mksa.j_ref*scocurr);
            figure('Name','Current profile'),
            graph1D_jd(output.equilDKE.xrho,output.Zcurr.x_0_fsav*output.mksa.j_ref*scocurr,0,0,'\rho','J_{tot} (MA/m^2)',['I_{tot} = ',num2str(I_tot*1000),' (kA)'],NaN,'','','-','none','r',2);drawnow
            print_jd(p_opt,[id_simul,'_Curr']);
            %
            PRF_tot = sum(output.ZP0.x_rf_fsav.*output.equilDKE.xdV_2piRp_dke(:)*output.mksa.P_ref*2*pi*output.equilDKE.Rp);
            figure('Name','RF Power'),
            graph1D_jd(output.equilDKE.xrho,output.ZP0.x_rf_fsav*output.mksa.P_ref,0,0,'\rho','P_{LH} (MW/m^3)',['P_{RF} = ',num2str(PRF_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
            print_jd(p_opt,[id_simul,'_RF_Power']);
            %
            POHM_tot = sum(output.ZP0.x_e_fsav.*output.equilDKE.xdV_2piRp_dke*output.mksa.P_ref*2*pi*output.equilDKE.Rp);
            figure('Name','Ohmic Power'),
            graph1D_jd(output.equilDKE.xrho,output.ZP0.x_e_fsav*output.mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',['P_{OHM} = ',num2str(POHM_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
            print_jd(p_opt,[id_simul,'_Ohm']);
            %
            status.output = 1;
            status.data = 2;
            %
        end
        %
    catch
        %
        disp('The action was cancelled due to the following error:')
        disp(' ');
        lsterr = lasterror;
        disp(lsterr.message);
        for il = 1:length(lsterr.stack),
            disp(['In ',lsterr.stack(il).file,' at line ',num2str(lsterr.stack(il).line)]);
        end
        %
    end
end
%
disp(' ');
disp('************** EXIT LUKE **************')
disp(' ');
%









