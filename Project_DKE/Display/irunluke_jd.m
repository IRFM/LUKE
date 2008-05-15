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
if nargin < 1,
    basestr = input_dke_yp('Enter a machine name (like ITER, TCV, TS, JET or any name)',' ');
end
%
clc
%
quitmsg = '-----> Run aborted';
warning off
%
isel = 1;
flagscript = 0;
%
status.data = 0;
status.dkepath = 0;
status.dkeparam = 0;
status.equil = 0;
status.waves = 0;
status.ohm = 0;
status.transpfaste = 0;
status.ripple = 0;
status.output = 0;
%
datafile = '';
dkepath = '';
dkeparam = '';
equil = '';
waves = '';
ohm = '';
transpfaste = '';
ripple = '';
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
        statstr.dkeparam = dkeparam.info.file;
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
    if status.ripple == 1,
        statstr.ripple = ripple.id;
    else 
        if ~isempty(ripple),
            disp('The structure ''ripple'' is outdated and cleared.')
            ripple = '';
            ostr = ' outdated.';
        else
            ostr = '';
        end            
        statstr.ripple = ['<',ostr,' The ''ripple'' structure is optional >'];
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
    if ~isempty(ripple),
        id_simul_o = [id_simul_o,'_',ripple.id];
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
    disp(['Magnetic ripple losses : ',statstr.ripple]);
    disp(' ');
    disp(['LUKE output            : ',statstr.output]);
    disp(' ');
    disp('************** MENU **************')
    disp(' ');
    disp('Please select one of the following options:');
    disp(' ');
    disp('[1]   Load existing data file');
    disp('[2]   Save current data in file');
    disp('[3]   Specify work directory');
    if ~flagscript,
        disp('[4]   Activate automatic script generation');
    else
        disp('[4]   Desactivate automatic script generation');
    end
    disp(' ');
    disp('[5]   Load/create LUKE ''dkepath'' structure (All paths)');
    disp('[6]   Load/modify LUKE ''dkeparam'' structure (code parameters)');
    disp('[7]   Load/create LUKE ''equilibrium'' structure');
    disp('[8]   Load/create LUKE ''wave'' structures (RF waves)');
    disp('[9]   Load/create LUKE ''ohm'' structure (Ohmic E-field)');
    disp('[10]  Load/create LUKE ''transpfaste'' structure (Fast electron transport)');
    disp('[11]  Load/create LUKE ''ripple'' structure (Magnetic ripple losses)');
    disp(' ');
    disp('[12]  Display LUKE equilibrium data');
    disp('[13]  Display LUKE RF wave data');
    disp('[14]  Display LUKE results');
    disp(' ');
    disp('[15]  Calculate HXR emission');
    disp(' ');
    disp('[16]  Go to command line')
    disp(' ');
    disp('[0]   Run LUKE');
    disp('[-1]  Exit LUKE');
    disp('[-2]  Exit LUKE, close all figures and removes all variables, globals, functions and MEX links');
    disp(' ');
    %
    isel = input('? [-1] :');
    %
    clc
    %
    if isempty(isel) | ~isnumeric(isel) | ~any(isel == [-2:16]),
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
                    if ~isfield(dkeparam,'info'),%cases that must be updated
                        dkeparam.info.file = [dkeparam_path,dkeparam_file];
                        clear dkeparam_path dkeparam_file
                    end
                    %
					status.data = 1;
					%
				elseif strfind(data_file,'LUKE_RESULTS_'),
					datafile = [data_path,data_file];
					data = load(datafile,'id_simul','dkepath','dkeparam','dkedisplay','equil','waves','ohm','transpfaste','ripple',...
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
					dkeparam.info.file = [data_path,data_file];
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
                        if ~isfield(ohm,'id'),
                            ohm.id = 'OHM';
                        end
						status.ohm = 1;
					end
					%
					if isfield(data,'transpfaste'),
						transpfaste = data.transpfaste;
                        if ~isfield(transpfaste,'id'),
                            transpfaste.id = 'TRANSP';
                        end
						status.transpfaste = 1;
					end
					if isfield(data,'ripple'),
						ripple = data.ripple;
                        if ~isfield(ripple,'id'),
                            ripple.id = 'RIPPLE';
                        end
						status.ripple = 1;
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
            % ACTIVATE OR DESACTIVATE SCRIPT GENERATION
            %
%            flagscript = ~flagscript;
            %
            disp('');
            disp('************** LOAD DATA FILE **************')
            disp('');
            %
            [script_file,script_path] = igetfile_jd(opt_gui,{'SCRIPT_LUKE_*.mat'},'Please select a LUKE script');
            %
            if script_file == 0,
                disp('-----> No LUKE script specified.');
            else
				if strfind(script_file,'SCRIPT_LUKE_'),
					scriptfile = [script_path,script_file];
					load(scriptfile);
					disp(['-----> The data file ',scriptfile,' is loaded.']);
                    %
					status.script = 1;
					%
				elseif strfind(script_file,'SCRIPT_LUKE_'),

				else
					disp('-----> Invalid LUKE script file.');
					continue
				end  
				%
				workdir = data_path;
				%
				setpath_luke_jd(dkepath.luke_root,dkepath);
				%
			end
            %
            
            
            
            
            
            
            
            if ~exist('RUNLUKE.txt'),save RUNLUKE.txt -ascii,end
            
            %
        elseif isel == 5, 
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
        elseif isel == 6,
            %
            % LUKE PARAMETERS
            %
            disp(' ');
            disp('************** LUKE PARAMETERS **************')
            disp(' ');
            %
            newpar = 0;
            param_id = '';
            %
            if status.dkeparam == 1,
                m_opt = input_dke_yp('Do you want to: (0) see/modify LUKE parameters (1) load new parameters',0,[0,1]);
                %
            else
                m_opt = 1;
            end
            %
            if m_opt == 1,
                %
                if status.equil == 1;
                    param_id = equil.id;
                else
                    param_id = basestr;
                end
                %
                if exist([workdir,'DKEPARAM_',param_id,'.mat'],'file'),
                    dkeparam_file = [workdir,'DKEPARAM_',param_id,'.mat'];
                else
                    if strcmp(basestr,'TCV'),
                        dkeparam_file = 'DKEPARAM_EC_RT.mat';
                    else
                        dkeparam_file = 'DKEPARAM_LH_RT.mat';
                    end
                    dkeparam_file = which(dkeparam_file);    
                end
                %
                dkeparam_new = iload_struct_jd('dkeparam','DKEPARAM',dkeparam_file,opt_gui,0,0);
                %
                if ~isempty(dkeparam_new),
                    %
                    dkeparam = dkeparam_new;
                    newpar = 1;
                    %
                    if ~isfield(dkeparam,'rho_S'),
                        dkeparam.rho_S = 20;
                    end
                    %
                    c_opt = input_dke_yp('Do you want to see/modify the LUKE parameters (y/n)','n',{'y','n'});
                    %
                    if strcmp(c_opt,'y'),
                        m_opt = 0;
                    end
                end
                %
                clear dkeparam_new
                %
            end
            %
            if m_opt == 0,
                %
                [dkeparam,mod] = imod_struct_jd(dkeparam,'dkeparam',1);
                %
                if mod == 1,
                    %
                    param.id = input_dke_yp('Please provide an id for the dkeparam structure',param_id);
                    %
                    isave_struct_jd(dkeparam,'dkeparam','DKEPARAM',param.id,workdir,opt_gui)
                    newpar = 1;
                    %
                end
                %
            end
            %
            if newpar == 1,
                status.dkeparam = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 7,
            %
            % EQUILIBRIUM 
            %
            disp(' ');
            disp('************** EQUILIBRIUM **************')
            disp(' ');
            %
            neweq = 0;
            %
            equil_new = iload_struct_jd('equil','EQUIL',workdir,opt_gui);
            %
            if ~isempty(equil_new),
                %
                equil = equil_new;
                neweq = 1;
                %
            else
                equil = imake_equil_jd(workdir,basestr,signs,opt_gui);
                %
                if ~isempty(equil),
                    %
                    disp('-----> The structure ''equil'' is created')
                    %
                    isave_struct_jd(equil,'equil','EQUIL',equil.id,workdir,opt_gui)
                    neweq = 1;
                    %
                end
            end
            %
            clear equil_new
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
        elseif isel == 8,
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
                l_opt = input_dke_yp('Do you want to check existing wave structures (y/n)','n',{'y','n'});
                %
                if strcmp(l_opt,'y'),
                    %
					iw_list = [];
					%
                    for iw = 1:length(waves),
                        w_opt = input_dke_yp(['Do you want to clear the wave structure ',waves{iw}.id,' (y/n)'],'n',{'y','n'});
                        %
                        if strcmp(w_opt,'y'),
                            disp(['-----> The wave structure ',waves{iw}.id,' is cleared.'])
                            %
                            iw_list = [iw_list,iw];
                        else
                            %
                            m_opt = input_dke_yp(['Do you want to see/modify the wave structure ',waves{iw}.id,' (y/n)'],'n',{'y','n'});
                            %
                            if strcmp(m_opt,'y'),
                                %
                                [waves{iw},mod] = imod_struct_jd(waves{iw},'wave',0);
                                %
                                if mod == 1,
                                    isave_struct_jd(waves{iw},'wave',['WAVE_',equil.id],waves{iw}.id,workdir,opt_gui)
                                    newwaves = 1;
                                end   
                            end
                            %
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
            waves_new = iload_struct_jd('wave',['WAVE_',equil.id],workdir,opt_gui,1);
            %
            if ~isempty(waves_new),
                %
                waves = [waves,waves_new];
                newwaves = 1;
                %
            end
            %
            clear waves_new
            %
            l_opt = input_dke_yp('Do you want to build a new structure ''wave'' (y/n)','n',{'y','n'});
            %
            while strcmp(l_opt,'y'),
                %
                wave = imake_wave_jd(workdir,basestr,equil,opt_gui);
                %
                if isempty(wave),
                    %
                    disp('-----> Current structure ''wave'' construction aborted.')
                    %
                    l_opt = input_dke_yp('Do you want to build a new structure ''wave'' (y/n)','n',{'y','n'});
                    %
                    continue
                end
                %
                disp('-----> The structure ''wave'' is created.')
                %
                isave_struct_jd(wave,'wave',['WAVE_',equil.id],wave.id,workdir,opt_gui)
                newwaves = 1;
                %
                waves = [waves,{wave}];
                %
                l_opt = input_dke_yp('Do you want to build a new structure ''wave'' (y/n)','n',{'y','n'});
            end
            %
            if newwaves == 1,
                status.waves = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 9,
            %
            % OHM
            %
            if status.equil == 0;
                disp('-----> An equilibrium structure must exist to create an ''ohm'' structure.');
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
                o_opt = input_dke_yp('Do you want to clear the existing structure ''ohm'' (y/n)','n',{'y','n'});
                %
                if strcmp(o_opt,'y'),
                    disp('-----> The structure ''ohm'' is cleared.')
                    status.ohm = 0;
                    status.output = 0;
                    status.data = 2;
                else
                    continue
                end
                %
            end
            %    
            ohm_new = iload_struct_jd('ohm',['OHM_',equil.id],workdir,opt_gui);
            %
            if ~isempty(ohm_new),
                %
                ohm = ohm_new;
                newohm = 1;
                %
            else
                l_opt = input_dke_yp('Do you want to build a structure ''ohm'' (y/n)','n',{'y','n'});
                %
                if strcmp(l_opt,'y'),
                    %
                    ohm = imake_ohm_jd(basestr,equil);
                    %
                    if ~isempty(ohm),
                        %
                        disp('-----> The structure ''ohm'' is created')
                        %
                        isave_struct_jd(ohm,'ohm',['OHM_',equil.id],ohm.id,workdir,opt_gui)
                        newohm = 1;
                        %
                    end
                end
            end
            %
            clear ohm_new
            %
            if newohm == 1,
                status.ohm = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 10,
            %
            % TRANSPORT
            %
            if status.equil == 0;
                disp('-----> An equilibrium structure must exist to create a ''transpfaste'' structure.');
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
                t_opt = input_dke_yp('Do you want to clear the existing structure ''transpfaste'' (y/n)','n',{'y','n'});
                %
                if strcmp(t_opt,'y'),
                    disp('-----> The structure ''transpfaste'' is cleared.')
                    status.transpfaste = 0;
                    status.output = 0;
                    status.data = 2;
                else
                    %
                    m_opt = input_dke_yp(['Do you want to see/modify the structure ''transpfaste'' (y/n)'],'n',{'y','n'});
                    %
                    if strcmp(m_opt,'y'),
                        %
                        [transpfaste,mod] = imod_struct_jd(transpfaste,'transpfaste',0);
                        %
                        if mod == 1,
                            %
                            isave_struct_jd(transpfaste,'transpfaste',['TRANSP_',equil.id],transpfaste.id,workdir,opt_gui)
                            newtransp = 1;
                            %
                        end  
                    else
                        continue
                    end
                    %
                end
                %
            end
            %
            if newtransp == 0,
                %
                transpfaste_new = iload_struct_jd('transpfaste',['TRANSP_',equil.id],workdir,opt_gui);
                %
                if ~isempty(transpfaste_new),
                    %
                    transpfaste = transpfaste_new;
                    newtransp = 1;
                    %
                else
                    l_opt = input_dke_yp('Do you want to build a structure ''transpfaste'' (y/n)','n',{'y','n'});
                    %
                    if strcmp(l_opt,'y'),
                        %
                        transpfaste = imake_transp_jd(basestr,equil);
                        %
                        if ~isempty(transpfaste),
                            %
                            disp('-----> The structure ''transpfaste'' is created')
                            %
                            isave_struct_jd(transpfaste,'transpfaste',['TRANSP_',equil.id],transpfaste.id,workdir,opt_gui)
                            newtransp = 1;
                            %
                        end
                    end
                end
                %
                clear transpfaste_new
                %
            end
            %
            if newtransp == 1,
                status.transpfaste = 1;
                status.output = 0;
                status.data = 2;
            end
            %
        elseif isel == 11,
            %
            % MAGNETIC RIPPLE LOSSES
            %
            if status.equil == 0;
                disp('-----> An equilibrium structure must exist to create a ''ripple'' structure.');
                continue
            end
            if ~strcmp(basestr,'TS');
                disp('-----> The magnetic ripple calculations is implemented for Tore Supra tokamak only.');
                continue
            end
            %
            disp(' ');
            disp('************** MAGNETIC RIPPLE LOSSES **************')
            disp(' ');
            %
            newripple = 0;
            %
            if ~isempty(ripple),
                t_opt = input_dke_yp('Do you want to clear the existing structure ''ripple'' (y/n)','n',{'y','n'});
                %
                if strcmp(t_opt,'y'),
                    disp('-----> The structure ''ripple'' is cleared.')
                    status.ripple = 0;
                    status.output = 0;
                    status.data = 2;
                else
                    %
                    m_opt = input_dke_yp(['Do you want to see/modify the structure ''ripple'' (y/n)'],'n',{'y','n'});
                    %
                    if strcmp(m_opt,'y'),
                        %
                        [ripple,mod] = imod_struct_jd(ripple,'ripple',0);
                        %
                        if mod == 1,
                            %
                            isave_struct_jd(ripple,'ripple',['RIPPLE_',equil.id],ripple.id,workdir,opt_gui)
                            newripple = 1;
                            %
                        end  
                    else
                        continue
                    end
                    %
                end
                %
            end
            %
            if newripple == 0,
                %
                ripple_new = iload_struct_jd('ripple',['RIPPLE_',equil.id],workdir,opt_gui);
                %
                if ~isempty(ripple_new),
                    %
                    ripple = ripple_new;
                    newripple = 1;
                    %
                else
                    l_opt = input_dke_yp('Do you want to build a structure ''ripple'' (y/n)','n',{'y','n'});
                    %
                    if strcmp(l_opt,'y'),
                        %
                        ripple = imake_ripple_yp(basestr,equil);
                        %
                        if ~isempty(ripple),
                            %
                            disp('-----> The structure ''ripple'' is created')
                            %
                            isave_struct_jd(ripple,'ripple',['RIPPLE_',equil.id],ripple.id,workdir,opt_gui)
                            newripple = 1;
                            %
                        end
                    end
                end
                %
                clear ripple_new
                %
            end
            %
            if newripple == 1,
                status.ripple = 1;
                status.output = 0;
                status.data = 2;
            end
            %      
        elseif isel == 12,
            %
            % DISPLAY LUKE EQUILIBRIUM
            %
            if status.equil == 1,
                equilibrium_jd(equil,NaN,2);
            else
                disp('-----> The equilibrium structure does not exist.');
            end
            %
        elseif isel == 13,
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
        elseif isel == 14,
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
        elseif isel == 15,
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
        elseif isel == 16,
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
            graph1D_jd(output.equilDKE.xrho,output.ZP0.x_rf_fsav*output.mksa.P_ref,0,0,'\rho','P_{RF} (MW/m^3)',['P_{RF} = ',num2str(PRF_tot*1000),' (kW)'],NaN,'','','-','none','r',2);drawnow
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
if isel == -2,
    close all
    clear all    
end
%
disp(' ');
disp('************** EXIT LUKE **************')
disp(' ');
%









