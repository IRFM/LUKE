function irunluke_jd(basestr,signs,opt_gui)
    %
    % This script interactively loads the equilibrium, profiles and launching data, and runs LUKE with
    % either C3PO, TORAY or ART ray-tracing data.
    %
    if nargin < 3,
        opt_gui = input_dke_yp('Graphical User Interface mode (yes:1,no:0)',0);
    end
    %
    if nargin < 2,
        signs = '';
    end
    if nargin < 1,
        basestr = input_dke_yp('Enter the machine name \n(such as ''ITER'', ''TCV'', ''TS'', ''JET'', ''COMPASS'', ''SST1'', ''EAST'', ...)',' ');
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
    status.ripple = 0;
    status.external = 0;
    %
    status.output = 0;
    %
    fileids.data = '';
    fileids.dkepath = '';
    fileids.dkeparam = '';
    fileids.equil = '';
    fileids.waves = '';
    fileids.ohm = '';
    fileids.transpfaste = '';
    fileids.ripple = '';
    fileids.external = '';
    %
    paths.data = '';
    paths.dkepath = '';
    paths.dkeparam = '';
    paths.equil = '';
    paths.waves = '';
    paths.ohm = '';
    paths.transpfaste = '';
    paths.ripple = '';
    paths.external = '';
    %
    dkepath = '';
    dkeparam = '';
    equil = '';
    waves = '';
    ohm = '';
    transpfaste = '';
    ripple = '';
    external = '';
    %
    output = '';
    timeid = '';
    %
    workdir = [pwd,'/'];
    %
    while isel >= 0,
        %
        % CLEAR outdated structures and DEFINE STATUS
        %
        if status.data == 1,
            statstr.data = fileids.data;
        elseif status.data == 2,
            statstr.data = [fileids.data,' < data modified, consider a save >'];
        else 
            statstr.data = '< No data yet >';
        end
        %
        statstr.workdir = workdir;
        %
        if status.dkepath == 1,
            if isfield(dkepath,'id'),
                statstr.dkepath = dkepath.id;
            else
                disp('WARNING : the dkepath structure must be updated and the field ''path_id'' chnged to ''id''');
                statstr.dkepath = dkepath.path_id;
            end
        else
            if ~isempty(dkepath),
                disp('The structure ''dkepath'' is outdated and cleared.');
                dkepath = '';
                ostr = ' outdated.';
            else
                ostr = '';
            end            
            statstr.dkepath = ['<',ostr,' Must load/create a structure ''path'' >'];
        end
        %
        if status.dkeparam == 1,
    %         statstr.dkeparam = dkeparam.id;
            if isempty(fileids.dkeparam),
                statstr.dkeparam = ['< dkeparam structure not saved >'];
            else
                statstr.dkeparam = fileids.dkeparam;
            end
        else
            if ~isempty(dkeparam),
                disp('The structure ''dkeparam'' is outdated and cleared.');
                dkeparam = '';
                ostr = ' outdated.';
            else
                ostr = '';
            end            
            statstr.dkeparam = ['<',ostr,' Must load/create a structure ''dkeparam'' >'];
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
            statstr.equil = ['<',ostr,' Must load/create a structure ''equil'' >'];
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
            statstr.waves = ['<',ostr,' The ''wave'' structures are optional >'];
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
        if status.external == 1,
            statstr.external = external.id;
        else 
            if ~isempty(external),
                disp('The structure ''external'' is outdated and cleared.')
                external = '';
                ostr = ' outdated.';
            else
                ostr = '';
            end   
            statstr.external = ['<',ostr,' No data from external database in memory. >'];
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
            if ~isempty(timeid),
                %
                statstr.output = ['< LUKE is currently running under job id ',jobid,' >'];
                %                
            elseif ~isempty(dkepath) && ~isempty(dkeparam) && ~isempty(equil),
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
        disp(' ----------- < LUKE > ----------- ')
        disp(' ');
        disp(['Machine : ',basestr]);
        disp(' ');
        disp('************* STATUS *************')
        disp(' ');
        disp(['LUKE data              : ',statstr.data]);
        disp(['Work directory         : ',statstr.workdir]);
        disp(['LUKE path              : ',statstr.dkepath]);
        disp(['LUKE parameters        : ',statstr.dkeparam]);
        disp(['Equilibrium            : ',statstr.equil]);
        disp(['RF waves               : ',statstr.waves]);
        disp(['Ohmic E-field          : ',statstr.ohm]);
        disp(['Fast electron transport: ',statstr.transpfaste]);
        disp(['Magnetic ripple losses : ',statstr.ripple]);
        disp(' ');
        disp(['LUKE output            : ',statstr.output]);
        disp(['External database      : ',statstr.external]);
        disp(' ');
        disp('************** MENU **************')
        disp(' ');
        disp('Please select one of the following options:');
        disp(' ');
        disp('[1]   Load existing data file');
        disp('[2]   Save current data in file');
        disp('[3]   Specify work directory');
        disp('[4]   Load/clear data from external database');
        disp(' ');
        disp('[5]   Load/create/modify ''dkepath'' structure (LUKE paths)');
        disp('[6]   Load/create/modify ''dkeparam'' structure (LUKE parameters)');
        disp('[7]   Load/create/modify ''equil'' structure (Plasma equilibrium)');
        disp('[8]   Load/create/modify ''wave'' structures (RF waves)');
        disp('[9]   Load/create/modify ''ohm'' structure (Ohmic E-field)');
        disp('[10]  Load/create/modify ''transpfaste'' structure (Fast electron transport)');
        disp('[11]  Load/create/modify ''ripple'' structure (Magnetic ripple losses)');
        disp(' ');
        disp('[12]  Display equilibrium data');
        disp('[13]  Display RF wave data');
        disp('[14]  Display LUKE results');
        disp(' ');
        disp('[15]  Calculate HXR emission');
        disp('[16]  Generate LUKE run script');
        disp(' ');
        disp('[17]  Go to command line')
        disp('[18]  Close all figures')
        disp(' ');
        disp('[0]   Run LUKE or load BATCH LUKE results');
        disp('[-1]  Exit LUKE');
        disp('[-2]  Exit LUKE, close all figures and removes all variables, globals, functions and MEX links');
        disp(' ');
        %
        isel = input('? [-1] :');
        %
        clc
        %
        if isempty(isel) | ~isnumeric(isel) | ~any(isel == [-2:18]),
            isel = -1;
        end
        %
        try
            %
            if isel == 1,
                %
                % LOAD DATA FILE
                %
                if status.data == 2 && input_dke_yp('--> Previous data is not saved. Are you sure you want to load new file (y/n)','n',{'y','n'}) == 'n',
                    continue;
                end
                %
                disp('');
                disp('************** LOAD DATA FILE **************')
                disp('');
                %
                [data_file,data_path] = igetfile_jd(opt_gui,{'LUKE_DATA_*.mat';'LUKE_RESULTS_*.mat';'last_luke@*';'before_luke@*'},'Please select a LUKE data file');
                %
                if data_file == 0,
                    disp('-----> No LUKE data file specified.');
                else
                    %
                    clear fileids paths
                    %
                    if strfind(data_file,'LUKE_DATA_'),
                        %
                        load([data_path,data_file],'basestr','signs','status','fileids','paths','id_simul','timeid','jobid','remote',...
                            'dkepath','dkeparam','dkedisplay','equil','waves','ohm','transpfaste','ripple','output','external');
                        disp(['-----> The data file ',[data_path,data_file],' is loaded.']);
                        %
                        fileids.data = data_file;
                        paths.data = data_path;
                        %
                        if ~isfield(fileids,'dkepath') || (~isempty(fileids.dkepath) && ~exist([paths.dkepath,'PATH_',fileids.dkepath,'.mat'],'file')),
                            fileids.dkepath = '';
                            paths.dkepath = '';
                        end
                        %
                        if ~isfield(fileids,'dkeparam') || (~isempty(fileids.dkeparam) && ~exist([paths.dkeparam,'DKEPARAM_',fileids.dkeparam,'.mat'],'file')),
                            fileids.dkeparam = '';
                            paths.dkeparam = '';
                        end
                        %
                        if ~isfield(fileids,'equil') || (~isempty(fileids.equil) && ~exist([paths.equil,'EQUIL_',fileids.equil,'.mat'],'file')),
                            fileids.equil = '';
                            paths.equil = '';
                        end
                        %
                        if ~isfield(fileids,'waves'),
                            %
                            fileids.waves = '';
                            paths.waves = '';
                            %
                        end
                        for iw = 1:length(waves),
                            if (length(fileids.waves) < iw) || (~isempty(fileids.waves{iw}) && ~exist([paths.waves{iw},'WAVE_',equil.id,'_',fileids.waves{iw},'.mat'],'file')),
                                fileids.waves{iw} = '';
                                paths.waves{iw} = '';
                            end
                        end
                        %
                        if ~isfield(fileids,'ohm') || (~isempty(fileids.ohm) && ~exist([paths.ohm,'OHM_',equil.id,'_',fileids.ohm,'.mat'],'file')),
                            fileids.ohm = '';
                            paths.ohm = '';
                        end
                        %
                        if ~isfield(fileids,'transpfaste') || (~isempty(fileids.transpfaste) && ~exist([paths.transpfaste,'TRANSP_',equil.id,'_',fileids.transpfaste,'.mat'],'file')),
                            fileids.transpfaste = '';
                            paths.transpfaste = '';
                        end
                        %
                        if ~isfield(fileids,'ripple') || (~isempty(fileids.ripple) && ~exist([paths.ripple,'RIPPLE_',equil.id,'_',fileids.ripple,'.mat'],'file')),
                            fileids.ripple = '';
                            paths.ripple = '';
                        end
                        %
                        if ~isfield(status,'ripple'),
                            status.ripple = 0;
                        end
                        %
                        if ~isfield(fileids,'external') || (~isempty(fileids.external) && ~exist([paths.external,'EXTERNAL_',fileids.external,'.mat'],'file')),
                            fileids.external = '';
                            paths.external = '';
                        end
                        %
                        if ~isfield(status,'external'),
                            status.external = 0;
                        end
                        %
                        status.data = 1;
                        %
                    elseif strfind(data_file,'LUKE_RESULTS_'),
                        %
                        data = load([data_path,data_file],'basestr','id_simul','rho_S','id_dkepath','path_dkepath','id_dkeparam','path_dkeparam',...
                            'id_equil','path_equil','ids_wave','paths_wave','id_ohm','path_ohm','id_transpfaste','path_transpfaste','id_ripple','path_ripple',...
                            'dkepath','dkeparam','dkedisplay','equil','waves','ohm','transpfaste','ripple',...
                            'Znorm','Zcurr','ZP0','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource');
                        disp(['-----> The data file ',[data_path,data_file],' is loaded.']);
                        %
                        if isfield(data,'basestr'),
                            basestr = data.basestr;
                        else
                            basestr = data_file(14:12 + find(data_file(14:end) == '_',1,'first'));
                            basestr = input_dke_yp('Please enter the tokamak name',basestr);
                        end
                        %
                        fileids.data = data_file;
                        paths.data = data_path;
                        %
                        id_simul = data.id_simul;
                        %
                        if isfield(data,'id_dkepath') && ~isempty(data.id_dkepath) && exist([data.path_dkepath,'PATH_',data.id_dkepath,'.mat'],'file'),
                            fileids.dkepath = data.id_dkepath;
                            paths.dkepath = data.path_dkepath;
                        else
                            fileids.dkepath = '';
                            paths.dkepath = '';
                        end
                        %
                        if isfield(data,'id_dkeparam') && ~isempty(data.id_dkeparam) && exist([data.path_dkeparam,'DKEPARAM_',data.id_dkeparam,'.mat'],'file'),
                            fileids.dkeparam = data.id_dkeparam;
                            paths.dkeparam = data.path_dkeparam;
                        else
                            fileids.dkeparam = '';
                            paths.dkeparam = '';
                        end
                        %
                        if ~isfield(data,'path_equil'),
                            data.path_equil = '';
                        end
                        %
                        if isfield(data,'id_equil') && ~isempty(data.id_equil) && exist([data.path_equil,'EQUIL_',data.id_equil,'.mat'],'file'),
                            fileids.equil = data.id_equil;
                            paths.equil = data.path_equil;
                        else
                            fileids.equil = '';
                            paths.equil = '';
                        end
                        %
                        if ~isfield(data,'waves'),
                            if isfield(data.dke_out,'waves'),
                                data.waves = data.dke_out.waves;
                            else
                                data.waves = '';
                            end
                        end
                        %
                        for iw = 1:length(data.waves),
                            if isfield(data,'ids_wave') && ~isempty(data.ids_wave{iw}) && exist([data.paths_wave{iw},'WAVE_',data.ids_wave{iw},'.mat'],'file'),
                                fileids.waves{iw} = data.ids_wave{iw};
                                paths.waves{iw} = data.paths_wave{iw};
                            else
                                fileids.waves{iw} = '';
                                paths.waves{iw} = '';
                            end
                        end
                        %
                        if ~isfield(data,'ohm'),
                            data.ohm = '';
                        end
                        %
                        if isfield(data,'id_ohm') && ~isempty(data.id_ohm) && exist([data.path_ohm,'OHM_',data.id_ohm,'.mat'],'file'),
                            fileids.ohm = data.id_ohm;
                            paths.ohm = data.path_ohm;
                        else
                            fileids.ohm = '';
                            paths.ohm = '';
                        end
                        %
                        if ~isfield(data,'transpfaste'),
                            data.transpfaste = '';
                        end
                        %
                        if isfield(data,'id_transpfaste') && ~isempty(data.id_transpfaste) && exist([data.path_transpfaste,'TRANSP_',data.id_transpfaste,'.mat'],'file'),
                            fileids.transpfaste = data.id_transpfaste;
                            paths.transpfaste = data.path_transpfaste;
                        else
                            fileids.transpfaste = '';
                            paths.transpfaste = '';
                        end
                        %
                        if ~isfield(data,'ripple'),
                            data.ripple = '';
                        end
                        %
                        if isfield(data,'id_ripple') && ~isempty(data.id_ripple) && exist([data.path_ripple,'RIPPLE_',data.id_ripple,'.mat'],'file'),
                            fileids.ripple = data.id_ripple;
                            paths.ripple = data.path_ripple;
                        else
                            fileids.ripple = '';
                            paths.ripple = '';
                        end
                        %
                        fileids.external = '';
                        paths.external = '';
                        %
                        dkepath = data.dkepath;
                        dkeparam = data.dkeparam;
                        dkedisplay = data.dkedisplay;
                        equil = data.equil;
                        waves = data.waves;
                        ohm = data.ohm;
                        transpfaste = data.transpfaste;
                        ripple = data.ripple;
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
                        if ~isfield(dkeparam,'rho_S') && isfield(data,'rho_S'),
                            dkeparam.rho_S = data.rho_S;
                        end
                        %
                        if ~isempty(waves),
                            status.waves = 1;
                        end                    
                        %
                        if ~isempty(ohm),
                            status.ohm = 1;
                            if ~isfield(ohm,'id'),
                                ohm.id = 'OHM';
                            end
                        end                    
                        %
                        if ~isempty(transpfaste),
                            status.transpfaste = 1;
                            if ~isfield(transpfaste,'id'),
                                transpfaste.id = 'TRANSP';
                            end
                        end                    
                        %
                        if ~isempty(ripple),
                            status.ripple = 1;
                            if ~isfield(ripple,'id'),
                                ripple.id = 'RIPPLE';
                            end
                        end                    
                        %
                        timeid = '';
                        %
                        status.external = 0;
                        status.data = 2;
                        %
                        clear data
                        %
                    elseif strfind(data_file,'last_luke@'),
                        %
                        data = load([data_path,data_file],'par','tokamak','dkepath','dkeparam','dkedisplay','equil','ohm','transpfaste','ripple',...
                            'Znorm_RF','Zcurr_RF','ZP0_RF','dke_out','radialDKE','equilDKE','momentumDKE','gridDKE','Zmomcoef','Zbouncecoef','Zmripple','mksa','XXsinksource');
                        %
                        if isfield(data,'tokamak'),
                            basestr = data.tokamak;
                        end
                        %
                        fileids.data = data_file;
                        paths.data = data_path;
                        %
                        disp(['-----> The data file ',fileids.data,' is loaded.']);
                        %
                        output.Znorm = data.Znorm_RF;
                        output.Zcurr = data.Zcurr_RF;
                        output.ZP0 = data.ZP0_RF;
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
                        dkepath = data.dkepath;
                        dkeparam = data.dkeparam;
                        dkedisplay = data.dkedisplay;
                        equil = data.equil;
                        ohm = data.ohm;
                        transpfaste = data.transpfaste;
                        ripple = data.ripple;
                        %
                        waves = output.dke_out.waves;
                        %
                        if ~isfield(dkeparam,'rho_S') && isfield(data.par,'rho_S'),
                            dkeparam.rho_S = data.par.rho_S;
                        end
                        %
                        fileids.dkepath = '';
                        fileids.dkeparam = '';
                        fileids.equil = '';
                        fileids.ohm = '';
                        fileids.transpfaste = '';
                        fileids.ripple = '';
                        fileids.external = '';
                        %
                        paths.dkepath = '';
                        paths.dkeparam = '';
                        paths.equil = '';
                        paths.ohm = '';
                        paths.transpfaste = '';
                        paths.ripple = '';
                        paths.external = '';
                        %
                        for iw = 1:length(waves),
                            fileids.waves{iw} = '';
                            paths.waves{iw} = '';
                        end
                        %
                        id_simul = output.dke_out.simul.id;
                        %
                        if ~isempty(waves),
                            status.waves = 1;
                        end                    
                        %
                        if ~isempty(ohm),
                            status.ohm = 1;
                            if ~isfield(ohm,'id'),
                                ohm.id = 'OHM';
                            end
                        end                    
                        %
                        if ~isempty(transpfaste),
                            status.transpfaste = 1;
                            if ~isfield(transpfaste,'id'),
                                transpfaste.id = 'TRANSP';
                            end
                        end                    
                        %
                        if ~isempty(ripple),
                            status.ripple = 1;
                            if ~isfield(ripple,'id'),
                                ripple.id = 'RIPPLE';
                            end
                        end                    
                        %
                        timeid = '';
                        %
                        status.external = 0;
                        status.data = 2;
                        %
                        clear data
                        %
                    elseif strfind(data_file,'before_luke@'),
                        %
                        data = load([data_path,data_file],'par','dkepath','dkeparam','dkedisplay','equil','ohm','transpfaste','ripple','wavestructs');
                        %
                        fileids.data = data_file;
                        paths.data = data_path;
                        %
                        disp(['-----> The data file ',fileids.data,' is loaded.']);
                        %
                        output = '';
                        %
                        status.dkeparam = 1;
                        status.dkepath = 1;
                        status.equil = 1;
                        status.output = 0;
                        %
                        dkepath = data.dkepath;
                        dkeparam = data.dkeparam;
                        dkedisplay = data.dkedisplay;
                        equil = data.equil;
                        ohm = data.ohm;
                        transpfaste = data.transpfaste;
                        ripple = data.ripple;
                        %
                        waves = '';
                        %
                        if ~isfield(dkeparam,'rho_S') && isfield(data.par,'rho_S'),
                            dkeparam.rho_S = data.par.rho_S;
                        end
                        %
                        fileids.dkepath = '';
                        fileids.dkeparam = '';
                        fileids.equil = '';
                        fileids.ohm = '';
                        fileids.waves = '';
                        fileids.transpfaste = '';
                        fileids.ripple = '';
                        fileids.external = '';
                        %
                        paths.dkepath = '';
                        paths.dkeparam = '';
                        paths.equil = '';
                        paths.ohm = '';
                        paths.waves = '';                       
                        paths.transpfaste = '';
                        paths.ripple = '';
                        paths.external = '';
                        %
                        status.waves = 0;
                        %
                        if ~isempty(ohm),
                            status.ohm = 1;
                            if ~isfield(ohm,'id'),
                                ohm.id = 'OHM';
                            end
                        end                    
                        %
                        if ~isempty(transpfaste),
                            status.transpfaste = 1;
                            if ~isfield(transpfaste,'id'),
                                transpfaste.id = 'TRANSP';
                            end
                        end                    
                        %
                        if ~isempty(ripple),
                            status.ripple = 1;
                            if ~isfield(ripple,'id'),
                                ripple.id = 'RIPPLE';
                            end
                        end                    
                        %
                        external.id = ['wavestructs : ',num2str(length(data.wavestructs)),' waves'];
                        external.wave.wavestructs = data.wavestructs;
                        %
                        status.external = 1;
                        status.data = 2;
                        %
                        timeid = '';
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
                    if ~isempty(fileids.dkepath) && exist([paths.dkepath,'PATH_',fileids.dkepath,'.mat'],'file'),
                        %
                        dkepath = load_structures_yp('dkepath',fileids.dkepath,paths.dkepath);
                        %
                    else
                        %
                        status.dkepath = 0;
                        %
                        [dkepath,paths,fileids,status] = imake_dkepath_jd(basestr,workdir,dkepath,paths,fileids,status,opt_gui);
                        %
                    end
                    %
                    if ~strcmp(workdir,[pwd,'/']) && input_dke_yp('Do you want to move to the source directory (y/n)','y',{'y','n'}) == 'y',
                        cd(workdir);
                    end
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
                [data_file,data_path] = iputfile_jd(opt_gui,'LUKE_DATA_*.mat','Please provide a LUKE data file name',[workdir,'LUKE_DATA_',id_simul_o,'.mat']);
                %
                if data_file == 0,
                    disp('-----> No LUKE data file specified.');
                else
                    newdatafile = [data_path,data_file];
                    if ~isempty(fileids.data) & ~strcmp([paths.data,fileids.data],newdatafile),
                        c_opt = input('The data file name has changed. Do you want to keep old data file (y/n)? [n] : ','s');
                        if ~strcmp(c_opt,'y'),
                            delete([paths.data,fileids.data])
                            disp(['-----> The file ',[paths.data,fileids.data],' has been deleted']);
                        end
                    end
                    %
                    fileids.data = data_file;
                    paths.data = data_path;
                    %
                    save(newdatafile);
                    disp(['-----> The data are saved in file ',newdatafile,'.']);
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
                %
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
                            fileids.data = '';
                        end
                        % 
                    end
                    %
                    workdir = newworkdir;
                    %
                end
                %
                if ~strcmp(workdir,[pwd,'/']) && input_dke_yp('Do you want to move to the working directory (y/n)','y',{'y','n'}) == 'y',
                    cd(workdir);
                end
                %
            elseif isel == 4,
                %
                % LOAD DATA FROM EXTERNAL DATABASE
                %
                disp(' ');
                disp('************** EXTERNAL DATA **************')
                disp(' ');
                %
                % treatment of the external structure
                %
                smakecmd = 'iload_externaldata_jd';
                %
                [external,paths.external,fileids.external,newstruct] = ...
                    imake_struct_jd(dkepath,external,'external',paths.external,fileids.external,'',basestr,smakecmd,NaN,status.external,'EXTERNAL',workdir,'',opt_gui,0,0,1,0);
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(external),
                        status.external = 1;
                    else
                        status.external = 0;
                    end
                    status.equil = 0;
                    status.waves = 0;
                    status.ohm = 0;
                    status.transpfaste = 0;
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd
                %
            elseif isel == 5, 
                %
                % PATH
                %
                disp(' ');
                disp('************** LUKE PATH **************')
                disp(' ');
                %
                [dkepath,paths,fileids,status] = imake_dkepath_jd(basestr,workdir,dkepath,paths,fileids,status,opt_gui);
                %
            elseif isel == 6,
                %
                % LUKE PARAMETERS
                %
                disp(' ');
                disp('************** LUKE PARAMETERS **************')
                disp(' ');
                %
                % determine default DKEPARAM file 
                %
                if status.equil == 1;
                    param_id = equil.id;
                else
                    param_id = basestr;
                end
                dkeparam_file = ['DKEPARAM_',param_id,'.mat'];
                if exist([workdir,dkeparam_file],'file'),
                    dkeparam_default = [workdir,dkeparam_file];
                else
                    %
                    dkeparam_file = '';
                    locfiles = what(workdir);
                    for ifile = 1:length(locfiles.mat),
                        if strfind(locfiles.mat{ifile},'DKEPARAM_'),
                            dkeparam_file = locfiles.mat{ifile};
                            break
                        end
                    end
                    %
                    if ~isempty(dkeparam_file),
                        dkeparam_default = [workdir,dkeparam_file];
                    else
                        %
                        if strcmp(basestr,'TCV'),
                            dkeparam_file = 'DKEPARAM_EC_RT.mat';
                        else
                            dkeparam_file = 'DKEPARAM_LH_RT.mat';
                        end
                        dkeparam_default = which(dkeparam_file);    
                    end
                end
                %
                % treatment of the dkeparam structure
                %
                smakecmd = '';
                %
                [dkeparam,paths.dkeparam,fileids.dkeparam,newstruct] = ...
                    imake_struct_jd(dkepath,dkeparam,'dkeparam',paths.dkeparam,fileids.dkeparam,equil,basestr,smakecmd,'',status.dkeparam,'DKEPARAM',workdir,dkeparam_default,opt_gui,0,1,1,0);
                %
                if ~isempty(dkeparam) && ~isfield(dkeparam,'rho_S'),
                    dkeparam.rho_S = 20;
                end
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(dkeparam),
                        status.dkeparam = 1;
                    else
                        status.dkeparam = 0;
                    end
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd dkeparam_default param_id dkeparam_file locfiles ifile
                %
            elseif isel == 7,
                %
                % EQUILIBRIUM 
                %
                disp(' ');
                disp('************** EQUILIBRIUM **************')
                disp(' ');
                %
                % treatment of the equil structure
                %
                smakecmd = 'imake_equil_jd';
                %
                [equil,paths.equil,fileids.equil,newstruct] = ...
                    imake_struct_jd(dkepath,equil,'equil',paths.equil,fileids.equil,signs,basestr,smakecmd,external,status.equil,'EQUIL',workdir,'',opt_gui,0,0,1,0);
                %
                if isempty(equil)
                    signs = [];
                elseif isfield(equil,'signs'),
                    signs = equil.signs;
                end
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(equil),
                        status.equil = 1;
                    else
                        status.equil = 0;
                    end
                    status.waves = 0;
                    status.ohm = 0;
                    status.transpfaste = 0;
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd
                %
            elseif isel == 8,
                %
                % WAVES
                %
                disp(' ');
                disp('************** WAVES **************')
                disp(' ');
                %
                % treatment of the waves structure
                %
                smakecmd = 'imake_wave_jd';
                %
                [waves,paths.waves,fileids.waves,newstruct] = ...
                    imake_struct_jd(dkepath,waves,'wave',paths.waves,fileids.waves,equil,basestr,smakecmd,external,status.waves,'WAVE',workdir,'',opt_gui,1,1,0);
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(waves),
                        status.waves = 1;
                    else
                        status.waves = 0;
                    end
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd
                %
            elseif isel == 9,
                %
                % OHM
                %
                disp(' ');
                disp('************** OHM **************')
                disp(' ');
                %
                % treatment of the ohm structure
                %
                smakecmd = 'imake_ohm_jd';
                %
                [ohm,paths.ohm,fileids.ohm,newstruct] = ...
                    imake_struct_jd(dkepath,ohm,'ohm',paths.ohm,fileids.ohm,equil,basestr,smakecmd,external,status.ohm,'OHM',workdir,'',opt_gui,0,1,1);
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(ohm),
                        status.ohm = 1;
                    else
                        status.ohm = 0;
                    end
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd
                %
            elseif isel == 10,
                %
                % TRANSPORT
                %
                disp(' ');
                disp('************** FAST ELECTRON TRANSPORT **************')
                disp(' ');
                %
                % treatment of the transpfaste structure
                %
                smakecmd = 'imake_transp_jd';
                %
                [transpfaste,paths.transpfaste,fileids.transpfaste,newstruct] = ...
                    imake_struct_jd(dkepath,transpfaste,'transpfaste',paths.transpfaste,fileids.transpfaste,equil,basestr,smakecmd,external,status.transpfaste,'TRANSP',workdir,'',opt_gui,0,1,1);
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(transpfaste),
                        status.transpfaste = 1;
                    else
                        status.transpfaste = 0;
                    end
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd
                %
            elseif isel == 11,
                %
                % MAGNETIC RIPPLE LOSSES
                %
                disp(' ');
                disp('************** MAGNETIC RIPPLE LOSSES **************')
                disp(' ');
                %
                if ~strcmp(basestr,'TS');
                    disp('-----> The magnetic ripple calculations is implemented for Tore Supra tokamak only.');
                    continue
                end
                %
                % treatment of the ripple structure
                %
                smakecmd = 'imake_ripple_yp';
                %
                [ripple,paths.ripple,fileids.ripple,newstruct] = ...
                    imake_struct_jd(dkepath,ripple,'ripple',paths.ripple,fileids.ripple,equil,basestr,smakecmd,external,status.ripple,'RIPPLE',workdir,'',opt_gui,0,1,1);
                %
                % structure interdependences
                %
                if newstruct == 1,
                    if ~isempty(ripple),
                        status.ripple = 1;
                    else
                        status.ripple = 0;
                    end
                    status.output = 0;
                    status.data = 2;
                end
                %
                clear newstruct smakecmd
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
                    nw = length(waves);
                    %
                    for iw = 1:nw
                        %
                        if isfield(waves{iw},'rayinit'),
                            rayinits{iw} = waves{iw}.rayinit;
                            %
                            if isfield (waves{iw}.rayinit,'launch'),
                                launchs{iw} = waves{iw}.rayinit.launch;
                            elseif isfield(waves{iw},'launch'),
                                launchs{iw} = waves{iw}.launch;
                            else
                                launchs{iw} = '';
                            end
                        else
                            rayinits{iw} = '';
                            launchs{iw} = '';
                        end
                        %
                    end
                    %
                    w_list = input_dke_yp('List of waves to display',1:nw,[1;nw],'');
                    %
                    p_opt = input_dke_yp('Option for output figures : -1 (nothing), 0 (print), 1 (print and save), 2 (save)',-1,-1:2,'',[1,1]);
                    g_opt.abs_max = input_dke_yp('Option for ray trajectories : 0 (full trajectory), 1 (cut when damped)',0,0:1,'',[1,1]);
                    %
                    %xvaropt = input_dke_yp('Option for rho definition : 0 (geometric), 1 (poloidal flux), 2 (toroidal flux)',0,0:2,'',[1,1]);
                    xvar = input_dke_yp('Option for rho definition : ''g'' (geometric), ''p'' (poloidal flux), ''t'' (toroidal flux), ''v'' (volumic rho)','g',{'g','p','t','v'},'',[1,1]);
                    %
                    g_opt.print = p_opt;
                    g_opt.TeNpar = 1;
                    nr_dep = 40;
                    rho_disp = 0:0.1:1;
                    ymask = NaN;
                    %
                    graph_wave_jd(equil,waves(w_list),rayinits(w_list),launchs(w_list),nr_dep,g_opt,rho_disp,ymask,xvar);
                    %
                    clear rayinits nw
                    %
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
                    data_proc = proc_luke_jd(output,ir_display,p_opt,dp_cyl,pnmax);
                    %
                    opt.procsave = input_dke_yp('Do you want to save the processed data','y',{'y','n'},'',[1,1]);
                    %
                    if opt.procsave == 'y',
                        %
                        [proc_file,proc_path] = iputfile_jd(opt_gui,'PROC_LUKE_DATA_*.mat','Please provide a LUKE PROC data file name',[workdir,'PROC_LUKE_DATA_',id_simul_o,'.mat']);
                        %
                        if proc_file == 0,
                            disp('-----> No PROC_LUKE data file specified.');
                        else
                            %
                            save([proc_path,proc_file],'data_proc');
                            disp(['-----> The proc data are saved in file ',proc_path,proc_file,'.']);
                            %
                        end                      
                    end
                    %
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
                irunhxr_jd(opt_gui,workdir,basestr,output,external,id_simul,equil,dkeparam,dkedisplay);
                %
            elseif isel == 16,
                %
                % GENERATE LUKE RUN SCRIPT
                %
                imake_rundke_jd(paths,fileids,status,dkeparam.rho_S,workdir,id_simul_o,opt_gui);
                %
            elseif isel == 17,
                %
                disp('-----> Type ''return'' to return to menu');    
                disp('-----> Type ''dbquit'' to abort run and leave workspace.');
                disp(' ');
                keyboard
                % 
            elseif isel == 18,
                %
                close all;    
                % 
            elseif isel == 0,
                %
                % CHECK IF THERE IS A BATCH RUN OF LUKE
                %
                if ~isempty(timeid) && input_dke_yp(['-----> There is a pending remote LUKE batch run.\n',...
                        'Do you want to check the run (y/n)'],'y',{'y','n'}) == 'y',
                    %
                    sd  = pwd;
                    cd(workdir);
                    %
                    output = getluke_remote_jd(timeid,jobid,remote);
                    %
                    cd(sd);
                    %
                    if isempty(output),
                        disp(['Remote LUKE still running under job id ',jobid,' ...'])
                    elseif isfield(output,'err'),
                        disp('Remote LUKE run failed, aborted.')
                        timeid = '';
                        output = '';
                        status.data = 2;
                    else
                        timeid = '';
                        %
                        status.output = 1;
                        status.data = 2;            
                    end
                    %
                    continue
                    %
                end                    
                %
                % RUN LUKE
                %    
                if isempty(dkepath) || isempty(dkeparam) || isempty(equil),
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
                if ~isfield(dkeparam,'clustermode'),
                    dkeparam.clustermode.coll_dke_jd.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
                    dkeparam.clustermode.coll_dke_jd.timeout = 200;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
                    dkeparam.clustermode.coll_dke_jd.size = 4;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
                    dkeparam.clustermode.eecoll_dke_jd.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
                    dkeparam.clustermode.eecoll_dke_jd.timeout = 200;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
                    dkeparam.clustermode.eecoll_dke_jd.size = 4;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
                end
                %
                dkeparam.psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
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
    % 			if strfind(dkepath.hostname,'crpppc'),
    % 				c_opt = input('Option for running LUKE? 0 (on local computer), 1 (on pleiades2) [0] : ');
    %             	if isempty(c_opt) | ~isnumeric(c_opt) | ~any(c_opt == [0,1]),
    %                 	c_opt = 0;
    %             	end
    % 				if c_opt == 1,
    % 					[dummy,logname] = unix('whoami');
    % 					logname(logname == 10) = [];
    % 					if strfind(logname,'decker'),
    % 						logname = 'jdecker';
    % 					end
    % 					if strfind(logname,'curchod'),
    % 						logname = 'lcurchod';
    % 					end
    % 				end
                %
                if isfield(dkepath,'remote') && ~isempty(dkepath.remote),
                    nrem = length(dkepath.remote);
                    remstr = 'Option for running LUKE :\n0 : local session \n';
                    for irem = 1:nrem,
                        remstr = [remstr,num2str(irem),' : batch run on ',dkepath.remote(irem).host,':',dkepath.remote(irem).luke_root,'\n'];
                    end
                    %
                    c_opt = input_dke_yp(remstr,0,0:nrem);
                else
                    c_opt = 0;
                end
                %
                disp(' ');
                disp('************** RUN LUKE **************')
                disp(' ');
                %
                if c_opt > 0,
                    %
                    remote = dkepath.remote(c_opt);
                    %
                    luke_input.id_simul = id_simul;
                    luke_input.dkeparam = dkeparam;
                    luke_input.dkedisplay = dkedisplay;
                    luke_input.equil = equil;
                    luke_input.waves = waves;
                    luke_input.ohm = ohm;
                    luke_input.transpfaste = transpfaste;
                    luke_input.ripple = ripple;
                    %
                    [timeid,jobid] = runluke_remote_jd(luke_input,remote);
                    %
                    w_opt = input_dke_yp(['Waiting for remote LUKE results... enter time out (minutes)'...
                        '\n(enter 0 to load results later)'],60,[0:7*24*60]);
                    %
                    tic
                    %
                    output = '';
                    status.output = 0;
                    status.data = 2;
                    %
                    while isempty(output) && toc/60 < w_opt,
                        %
                        pause(60);
                        %
                        disp(['Still running , elapsed time (minutes) ',num2str(round(toc/60)),'/',num2str(w_opt)])
                        %
                        output = getluke_remote_jd(timeid,jobid,remote);
                        %
                    end
                    %
                    if isempty(output),
                        disp(['Stop waiting , elapsed time (minutes) ',num2str(round(toc/60)),'/',num2str(w_opt)])
                    elseif isfield(output,'err'),
                        disp('Remote LUKE run failed, aborted.')
                        timeid = '';
                        output = '';
                    else
                        timeid = '';
                        %
                        status.output = 1;
                    end
                    %
                else
                    %
                    [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,[],waves,dkeparam.psin_S,dkeparam.rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0);
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
                    status.output = 1;
                    status.data = 2;
                    %
                end
                %
            elseif isel < 0 && status.data == 2,
                if input_dke_yp('--> Data is not saved. Are you sure you want to quit LUKE (y/n)','n',{'y','n'}) == 'n',
                    isel = 1;
                end
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
end
%
function [dkepath,paths,fileids,status] = imake_dkepath_jd(basestr,workdir,dkepath,paths,fileids,status,opt_gui)
	%
	% determine default DKEPARAM file 
	%
	dkepath_default = which('PATH_LOCAL.mat');
	%
	% treatment of the dkepath structure
	%
	smakecmd = '';
	%
	[dkepath,paths.dkepath,fileids.dkepath,newstruct] = ...
		imake_struct_jd(dkepath,dkepath,'dkepath',paths.dkepath,fileids.dkepath,'',basestr,smakecmd,'',status.dkepath,'PATH',workdir,dkepath_default,opt_gui,0,0,1,0);
	%
	% structure interdependences
	%
	if newstruct == 1,
		if ~isempty(dkepath),
			%
			status.dkepath = 1;
			%
			dkepath = load_structures_yp('dkepath',fileids.dkepath,paths.dkepath);
			%
		else
			status.dkepath = 0;
		end
		%status.output = 0;
		%status.data = 2;
	end
	%
	%clear newstruct smakecmd dkepath_default
    %
end






