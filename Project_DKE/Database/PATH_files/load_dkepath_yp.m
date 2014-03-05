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
        disp(['Warning : path from profile ',PathFileNames{ifile},'.m could not be loaded because of the following error :',err.message]);
        continue
    end
    %
    disp(['Path from profile ',PathFileNames{ifile},'.m successfully loaded'])
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
    disp('Warning : no local path profile found. Default path profile selected')
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
            disp(['Warning : user ',username,' not found on machine ',dkepath.hostname,'; selecting profile from default user ',dkepath.default])
            username = dkepath.default;
        else
            error(['Warning : user ',username,' not found on machine ',dkepath.hostname,'; no default user specified.'])
        end
    end
    %
    % select user profile number if applicable
    %
    if length(dkepath.(username)) > 1,
        disp(' ');
        isel = input_dke_yp(['Please select one of the profiles numbers for user : ',username,' (1 => ',num2str(length(dkepath.(username))),') '],1,1:length(dkepath.(username)));
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
    disp(['PATH Profile #',num2str(isel),' for user ',username,' from file ',PathFileNames{ifiles(iflag)},' selected for machine(s) : ',machinestr]);
    %
end


