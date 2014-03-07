function [MatToolspath,MatRemotepath] = LUKE_startup_jd
    %
    % This function creates or mofifies a startup file to include LUKE paths
    %
    % By Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) and Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr)
    %
    MatRemotepath = '';
    %
    % -------------------------------------------------------------
    % verify that the MatRemote and MatTools toolboxes 
    % are available on the local machine
    % select active directory if there is more than one
    % -------------------------------------------------------------
    %
    %
    MatToolspath = findandselect_jd('MatTools','d',false);
    disp(' ');
    if isempty(MatToolspath),
        disp('Aborting startup setup.')
        return
    else
        disp(['--> following toolbox selected : ',MatToolspath])
    end
    %
    MatRemotepath = findandselect_jd('MatRemote','d',false);
    disp(' ');
    if isempty(MatRemotepath),
        disp('Aborting startup setup.')
        return
    else
        disp(['--> following toolbox selected : ',MatRemotepath])
    end
    %
    % -------------------------------------------------------------
    %                   locate & select LUKE installations
    % -------------------------------------------------------------
    %
    LUKEpaths = findandselect_jd('install_LUKE.m','f',true,true,'Which LUKE distributions do you want to include in the startup choice list?');
    %
    nLUKEpaths = length(LUKEpaths);
    disp(' ');
    if isempty(LUKEpaths),
        disp('Aborting startup setup.')
        return
    else
        disp('--> following LUKE versions selected : ')
        for iLUKEpath = 1:nLUKEpaths,
            disp([' - ',LUKEpaths{iLUKEpath}]);
        end
    end
    %
    % -------------------------------------------------------------
    %                   locate startup.m file
    % -------------------------------------------------------------
    %
    pathforstartup = fileparts(which('startup.m'));% find existing startup.m file
    disp(' ');
    if isempty(pathforstartup),
        pathforstartup = getenv('HOME');% choose home folder to find or create startup.m file
    end
    %
    startupfile = [pathforstartup,filesep,'startup.m'];
    %
    if ~exist(startupfile,'file'),
        disp(['File startup.m created in folder ',pathforstartup,filesep])
    else
        disp(['File ',startupfile,' selected.'])
    end
    %
    % -------------------------------------------------------------
    %               find or create startup_LUKE.m
    % -------------------------------------------------------------
    %
    startup_LUKE_files = which('startup_LUKE.m','-all');
    nfiles = length(startup_LUKE_files);
    %
    if nfiles > 0,% existing startup_LUKE.m file found on the matlab path
        %
        startup_LUKEfile = startup_LUKE_files{1};% first file on the matlab path
        startup_LUKEpath = fileparts(startup_LUKEfile);
        %
        disp(' ');
        if strcmp(pathforstartup,startup_LUKEpath),% startup_LUKE.m found in the same location as startup.m
            disp('A startup_LUKE.m file have been found in the same location as startup.m.');
        else% startup_LUKE.m found in a different location
            disp(['A startup_LUKE.m file have been found at the following location : ',startup_LUKEpath]);
        end
        opt = input('It will be replaced by a new one. Are you sure you want to proceed? (y/n) [y] ? ','s');
        if isempty(opt),
            opt = 'y';
        end
        %
        if ~strcmp(opt,'y'),
            disp(' ');
            disp('Operation aborted. Please setup startup file manually.');
            return
        end
        %
        if ~strcmp(pathforstartup,startup_LUKEpath),
            disp('Please ensure manually that the file ',startup_LUKEfile,' will be in the matlab path upon startup.')
        end
        %
        if nfiles > 1,% other startup_LUKE.m found on the matlab path
            disp(' ');
            disp('Additional startup_LUKE.m file have been found in the following locations on the matlab path :');
            disp(' ');
            %
            for ifile = 2:nfiles,
                disp(startup_LUKE_files{ifile});
            end
            %
            disp(' ');
            disp(['Please ensure that these additional startup_LUKE.m files will be below the file ',startup_LUKEfile,' on the matlab path']);
            disp(' ');
            %
        end
    else
        startup_LUKEfile = [pathforstartup,filesep,'startup_LUKE.m'];% startup_LUKE.m file created at the same location as startup.m
    end
    %
    % test that startup_LUKE.m can be created or overwritten
    %
    fid = fopen(startup_LUKEfile,'w');  
    %
    if fid == -1,
        disp('Warning : Cannot create startup_LUKE.m, permission denied. Please setup startup file manually.');
        return
    else
        fclose(fid);
    end
    %
    if nfiles > 0,% delete existing startup_LUKE.m file
        delete(startup_LUKEfile)
    end
    %
    disp('---------------------------------------------------------')
    disp(' ');
    %
    diary(startup_LUKEfile),% create startup_LUKE.m
    %
    disp('function startup_LUKE');
    disp('%');
    disp('% Setup paths to MatRemote and MatTools toolboxes');
    disp('%');
    disp(['matremote_path = ''',MatRemotepath,''';']);% change if needed');
    disp(['mattools_path = ''',MatToolspath,''';']);% change if needed');
    disp('%');
    disp('addpath(matremote_path);% MatRemote toolbox');
    disp('addpath([matremote_path,filesep,''Profiles'']);% remote profiles');
    disp('addpath([matremote_path,filesep,''Bridge'']);% remote profiles');
    disp('addpath(mattools_path);% MatTools toolbox');
    disp('%');
    disp('lukeversions = {...');
    for ifile = 1:nLUKEpaths,
        disp(['   ''',LUKEpaths{ifile},filesep,''',...']);
    end
    disp('   };');
    disp('%');
    disp('setappdata(0,''lukeversions'',lukeversions)');
    disp('%');
    disp('select_LUKE = getenv(''select_LUKE'');');
    disp('%');
    disp('if strcmp(getenv(''select_LUKE''),''yes''),');
    disp('    %');
    disp('    select_LUKE_jd(lukeversions)');
    disp('    %');
    disp('elseif ~isempty(select_LUKE),');
    disp('    %');
    disp('    select_LUKE_jd(select_LUKE)');
    disp('    %');
    disp('else');
    disp('    %');
    disp('    disp('' '');');
    disp('    disp(''To set LUKE paths type "select_LUKE_jd;"'')');
    disp('    disp('' '');');
    disp('    %');
    disp('end');
    disp('%');
    %
    diary off
    disp(' ');
    disp('---------------------------------------------------------')
    %
    % -------------------------------------------------------------
    %       check or add call to startup_LUKE in startup.m
    % -------------------------------------------------------------
    %
    flag = 0;
    %
    if exist(startupfile,'file'),%startup.m file already exist
        %
        % check if call to startup_LUKE is implemented in startup.m
        %
        filestr = fileread(startupfile);
        %
        if strfind(filestr,'startup_LUKE'),
            disp(' ');
            disp('Call to startup_LUKE already implemented in startup.m');
            %
        else
            %
            % test that startup.m can be written into
            % 
            fid = fopen(startupfile,'r+');  
            if fid == -1,
                disp('Warning : Cannot write to startup.m, permission denied. Please setup startup file manually.');
                flag = 2;
            else
                fclose(fid);
                flag = 1;
            end
            %
        end
    else    
        %
        % test that startup.m can be created
        %
        fid = fopen(startupfile,'w');  
        %
        if fid == -1,
            disp('Warning : Cannot create startup.m, permission denied. Please setup startup file manually.');
            flag = 2;
        else
            fclose(fid);
            flag = 1;
        end
        %
    end
    %
    if flag == 1,
        %
        % add call to startup_LUKE a the end of startup.m
        %
        diary(startupfile)
        %
        disp('%')
        disp('startup_LUKE;% set up path to LUKE as well as the toolboxes MatRemote and MatTools')
        disp('%')
        %
        diary off
        %
    end
    %
end
%
%
function foundpaths = findandselect_jd(pathname,pathtype,multi,optlocal,message)
    %
    % This function searches for the file(s) (pathtype == 'f') or folder(s) (pathtype == 'd') named 'pathname' in the home directory. 
    % if multi = true, can select more than one instances
    % if optlocal == true, put local folder first if in the list
    % use 'message' for selection, or default message if left empty
    %
    if multi,
        foundpaths = {};
    else
        foundpaths = '';
    end
    %
    [res,foundpathstr] = unix(['find ',getenv('HOME'),' -type ',pathtype,' -name "',pathname,'"']);
    %
    if foundpathstr(1) == 10,
        foundpathstr = foundpathstr(2:end);%remove possible initial EoF
    end
    %
    ieof = [0,find(foundpathstr == 10)];
    %
    nfoundpaths = length(ieof) - 1;
    %
    foundpaths = cell(1,nfoundpaths);
    flag = false(1,nfoundpaths);
    %
    for ifoundpath = 1:nfoundpaths,
        foundpaths{ifoundpath} = foundpathstr(ieof(ifoundpath) + 1:ieof(ifoundpath + 1) - 1);% char -> cell
        %
        if pathtype == 'f',% file
            if exist(foundpaths{ifoundpath},'file'),% to test it is a valid path (reject "Permission denied", etc)
                flag(ifoundpath) = true;
                foundpaths{ifoundpath} = fileparts(foundpaths{ifoundpath});
            end
        elseif pathtype == 'd',% directory
            if exist(foundpaths{ifoundpath},'dir'),% to test it is a valid path (reject "Permission denied", etc)
                flag(ifoundpath) = true;
            end            
        end
    end  
    %
    foundpaths = foundpaths(flag);
    nfoundpaths = length(foundpaths);
    %
    if nfoundpaths == 0,
        disp([pathname,' not found on the local machine. Please download before starting LUKE install again.'])
        return
    end
    %
    if nargin > 3 && optlocal,
        %
        localpath = fileparts(which(mfilename));% local version
        %
        foundpaths = [{localpath},foundpaths(~strcmp(foundpaths,localpath))];% move local version to first position in list   
        %
    end        
    %
    if nfoundpaths > 1,
        %
        ipath = [];
        %
        while isempty(ipath),
            if nargin < 4 || isempty(message),
                if multi,
                    message = ['Please select one or more version(s) of ',pathname,' :'];
                else
                    message = ['Please select a version of ',pathname,' :'];
                end
            end
            %   
            disp(' ');
            disp(message)
            if multi,
                disp('---> Enter array of choices (ex : [1,2,4]), or simply return to include entire list');
            end
            disp(' ');
            %
            for ifoundpath = 1:nfoundpaths,
                disp(['[',num2str(ifoundpath),'] : ',foundpaths{ifoundpath}])
            end
            %
            disp(' ');
            if multi,
                selection = input(' ? : ');
            else
                selection = input(' ? default : [1] : ');
            end
            %
            if multi,
                if isempty(selection),
                    ipath = 1:nfoundpaths;
                elseif isnumeric(selection) && all(sum(repmat(selection(:),[1,nfoundpaths]) == repmat(1:nfoundpaths,[length(selection(:)),1]),2) == ones(length(selection(:)),1)),
                    ipath = selection(:).';
                else
                    disp('Invalid choice.')
                end
            else
                if isempty(selection),
                    ipath = 1;
                elseif isnumeric(selection) && isscalar(selection) && any(selection == 1:nfoundpaths),
                    ipath = selection;
                else
                    disp('Invalid choice.')
                end
            end                    
        end
        %
    else
        ipath = 1;
    end
    %
    if multi,
        foundpaths = foundpaths(ipath);
    else
        foundpaths = foundpaths{ipath};
    end
    %
end
%

