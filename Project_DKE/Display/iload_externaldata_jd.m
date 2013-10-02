function external = iload_externaldata_jd(dkepath,basestr,workdir,opt_gui,style)
    %
    % This function loads data from external database
    %
    if nargin < 5,
        style = struct;
    end
    if nargin < 4,
        opt_gui = true;
    end
    %
    external = '';
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
        shotnum = input_dke_yp('Shot number','');
        %
        t1 = input_dke_yp('Averaging of shot data, initial time (leave empty if unused)','','','');
        if ~isempty(t1),
            t2 = input_dke_yp('Averaging of shot data, final time','','','');
            if isempty(t2), t1 = '';end
        else
            t2 = '';
        end
        %
        if isnumeric(t1) && isnumeric(t2),
            shotime = input_dke_yp('Shot time)',(t1 + t2)/2,'','',[1,1]);
            %
            shotime = num2str(shotime,'%6.4f');
        else
            shotime = input_dke_yp('Shot time','','','');
        end
        %
        external = feval(fname,workdir,shotnum,shotime,t1,t2,opt_gui);
        %
    else
        %
        basestrs = find_externalbases_jd(dkepath.luke_root);
        %
        if isempty(basestrs),
            external.err = 'No function found to import from database';
            return
        end
        %
        external.basestr = 'TS';
        external.shotnum = 0;
        external.shotime = 0;
        external.t1 = 0;
        external.t2 = 0;
        external.values.basestr = basestrs;
        %
        external = imod_struct_jd(external,'external',0,opt_gui,external,style);
        %
        external.shotnum = num2str(external.shotnum);
        external.shotime = num2str(external.shotime,'%6.4f');
        %
        if isempty(external.basestr),
            external.err = 'No valid tokamak selected.';
            return
        end
        %
        external = conc_struct_jd(external,feval(['load_externaldata_',external.basestr],pwd,external.shotnum,external.shotime,external.t1,external.t2,1,''));
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