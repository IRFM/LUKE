function dkepath = load_dkepath_yp
%
%	Load LUKE paths & profile of the local machine
%
%	Output:
%
%       - dkepath: local path structure
%
%   Warning: none
%
% By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%

%
% List all path files from PATH_files directory
%
PathsDir = fileparts(which(mfilename));
%
PathsDirContents = dir([PathsDir,filesep,'path_*m']);
npathfiles = length(PathsDirContents);
PathFileNames = cell(1,npathfiles);
for ifile = 1:npathfiles,
    PathFileNames{ifile} = PathsDirContents(ifile).name(1:end-2);
end
%
% Load all path files and select local path profile according to hostname
%
lochostname = hostname_jd;
%
dkepaths = cell(1,npathfiles);
flag = false(1,npathfiles);
%
for ifile = 1:npathfiles,
    %
    try
        dkepaths{ifile} = feval(PathFileNames{ifile});
    catch err
        dkepaths{ifile} = err.message;
        continue
    end
    %
    if ~iscell(dkepaths{ifile}.hostname),% case of single hostname in path profile
        hostnames = {dkepaths{ifile}.hostname};
    else% multiple profiles on the same filesystem
        hostnames = dkepaths{ifile}.hostname;
    end
    %
    for ihost = 1:length(hostnames),
        if any(strfind(lochostname,hostnames{ihost})),% local cluster,
            %
            flag(ifile) = true;
            break
            %
        end
    end
    %
end
%
if ~any(flag),
    %
    disp(' ');
    disp('Warning : no local path profile found. Here is the list of tested profiles :')
    disp(' ');
    %
    for ifile = 1:npathfiles,
        if isstruct(dkepaths{ifile}),
            disp(['Profile from ',PathFileNames{ifile},'.m successfully loaded.'])
        else
            disp(['Error loading profile from ',PathFileNames{ifile},'.m : ',dkepaths{ifile}])
        end
    end
    disp(' ');
    disp('Default path profile selected')
    %
    dkepath = default_path_profile;
else  
    %
    % select path profile
    %
    ifiles = find(flag);
    %
    if sum(flag) > 1,
        disp(' ');
        iflag = iselect_jd(PathFileNames(flag),'Warning : more than one local path profile found. Please select one of the following profiles :',false);
    else
        iflag = 1;
    end
    %
    dkepath = dkepaths{ifiles(iflag)};
    %
    % select user name
    %
    username = getenv('USER');
    %
    if ~isfield(dkepath,username),%user not listed in local profile
        if isfield(dkepath,'default'),
            disp(['Warning : user ',username,' not found in file ',PathFileNames{ifiles(iflag)},'.m; selecting profile from default user ',dkepath.default])
            username = dkepath.default;
        else
            error(['Warning : user ',username,' not found in file ',PathFileNames{ifiles(iflag)},'.m; no default user specified.'])
        end
    end
    %
    % select user profile number if applicable
    %
    nusers = length(dkepath.(username));
    if nusers > 1,
        disp(' ');
        disp(['A total of ',num2str(nusers),' profiles are defined for user ',username,' in file ',PathFileNames{ifiles(iflag)},'.m']);
        disp(' ');
        isel = input_dke_yp(['Please check the file ',PathFileNames{ifiles(iflag)},'.m and select one of the profiles (1 => ',num2str(nusers),') '],1,1:nusers);
    else
        isel = 1;
    end
    %
    dkepath.(username) = dkepath.(username)(isel);
    %
    dkepath = conc_struct_jd(selectfields_jd(dkepath,{'hostname','machine','computer'}),dkepath.(username));
    %
    if iscell(dkepath.machine),%case of multiple machines on the same filesystem
        nhost = length(dkepath.machine);
        flag = false(1,nhost);
        for ihost = 1:nhost,
            if isfield(dkepath,dkepath.machine{ihost}),% meaning the machine 'dkepath.machine{ihost}' is referenced for user 'username'
                flag(ihost) = true;
            end
        end
        %
        dkepath.hostname = dkepath.hostname(flag);
        dkepath.machine = dkepath.machine(flag);
        %
    end
    %
    % if no remote profile
    %
    if ~isfield(dkepath,'remote'),
        dkepath.remote = [];
    end
    %
    if iscell(dkepath.machine),
        machinestr = dkepath.machine{1};
        for ihost = 2:length(dkepath.machine),
            machinestr = [machinestr,', ',dkepath.machine{ihost}];
        end
    else
        machinestr = dkepath.machine;
    end
    %
    disp(' ');
    disp(['PATH Profile #',num2str(isel),' for user ',username,' from file ',PathFileNames{ifiles(iflag)},'.m selected for machine(s) : ',machinestr]);
    %
end


