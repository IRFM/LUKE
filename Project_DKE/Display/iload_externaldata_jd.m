function external = iload_externaldata_jd(dkepath,basestr,workdir,opt_gui,style)
    %
    % This function loads data from external database
    %
    % Note : the structure 'external' must have the following fields
    %
    %   - basestr (string) : name of the tomakak
    %   - shotnum (string) : shot number
    %
    % either
    %   - shotime (scalar) : shot time (s)
    % or 
    %   - shotimes (scalar array) : shot times (s)
    %
    % external data grouped according to the corresponding CPO, such as
    %   - equil (struct)
    %   - wave (struct)
    %   - ohm (struct)
    %   - transpfaste (struct)
    %   - ripple (struct)
    %   - hxr (struct)     
    %
    if nargin < 5,
        style = struct;
    end
    if nargin < 4,
        opt_gui = true;
    end
    if ~isfield(style,'distselectstyle'),
        style.distselectstyle = style;
    end
    %
    external = [];
    %
    % select remote profile for calculation
    %
    remnum = iselect_jd(dkepath.remprofiles,'Select local or remote location for database quest',opt_gui,style.distselectstyle,1,'popupmenu') - 1;
    %
    if remnum == 0,
        remote = [];
    else
        remote = dkepath.remote(remnum);
    end
    %
    % load_externaldata file selection
    %
    if nargin > 1 && ~isempty(basestr),% from irunluke
        %
        fname = ['load_externaldata_',basestr];
        %
        if ~exist(fname,'file'),
            %
            disp(['-----> Database access is not implemented for ',basestr]);
            return;    
            %
        end    
        %
    else% from iluke
        %
        basestrs = find_externalbases_jd(dkepath.luke_root);
        %
        if isempty(basestrs),
            external.err = 'No function found to import from database';
            return
        end
        %
        LUKE_EXTERNAL = getenv('LUKE_EXTERNAL');
        ibasestr = find(strcmp(basestrs,LUKE_EXTERNAL));
        %
        if isempty(ibasestr),% defautl is TS
            ibasestr = find(strcmp(basestrs,'TS'));
        end
        %
        style.butwidth = 150;
        baseselect = iselect_jd(basestrs,'Select tokamak (and eventually database function)',opt_gui,style,ibasestr,'popupmenu');
        basestr = basestrs{baseselect};
        %
        fname = ['load_externaldata_',basestr];
        %
    end
    %
    iMultiTimes = strfind(basestr,'MultiTimes');
    %
    % multitimes case only valid for TCV for now... not yet part of generalized process
    %
    if ~any(iMultiTimes),% select one time
        %
        % get input arguments for file load_externaldata
        % 
        external_in = feval(fname);% call to load_externaldata with no arguments returns requested options from the function
        %
        % user-modified options
        %
        external_in = imod_struct_jd(external_in,'external',0,boolean(opt_gui),external_in,style);
        %
        [err,external_out] = matremote_jd(fname,{external_in,opt_gui},remote);
        %
        if isempty(err),
            external = external_out;
        end
        %
    else
        %
        external = feval(fname,pwd,opt_gui,style,remote);
        %
    end
end
%
function basestrs = find_externalbases_jd(luke_root)
    %
    datadir = [luke_root,'Project_DKE/Database/EXTERNAL_files/'];
    %
    datafiles = dir(datadir);
    %
    strtofind = 'load_externaldata_';
    %
    basestrs = {};
    %
    for iname = 1:length(datafiles),
        if length(datafiles(iname).name) > length(strtofind) && strcmp(datafiles(iname).name(1:length(strtofind)),strtofind) && strcmp(datafiles(iname).name(end-1:end),'.m'),
            basestrs = [basestrs,datafiles(iname).name(length(strtofind)+1:end-2)];
        end
    end    
    %
end
%