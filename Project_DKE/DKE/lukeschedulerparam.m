function dkepath = lukeschedulerparam(dkepath,mdce_mode,remnum,returnmode,transpmode,opt_gui,style)
%
% this function creates a standar scheduler structure in dkepath.clustermode.run_lukert 
% for LUKE remote and/or distributed computing
%
% INPUTS : 
%       - mdce_mode : calculation distribution mode 
%           o [] (default) : prompt for choice
%           o -length(remote),...,-2,-1 : remcomputing on the remote cluster dkepath.remote(-mdce_mode)
%           o 0 : sequential calculation
%           o 1 : use of jobcomputing
%           o 2 : use of parcomputing (parfor)
%           o 3 : remcomputing on the local cluster
%
%       - remnum : remote calculation mode
%           o [] (default) : prompt for choice
%           o 0 : local calculation
%           o 1 : calculation transfered to remote cluster dkepath.remote(remnum)
%
%       - returnmode
%           o [] (default) : prompt for choice
%           o 0 : wait for result
%           o 1 : return hand after starting calculation (valid only if remnum > 0 or mode < 0)
%
%       - transpmode : (struct) fast electron transport structure, (true) fast electron transport included or (false) not included
%           o struct : fast electron transport structure tested to see if transport is truly included
%           o false (default) : fast electron transport not included 
%               => 7 GB memory default calculation
%           o true : fast electron transport included 
%               => 14 GB memory default calculation
%
%       - opt_gui : option for selection prompt
%           o false (default) : command line selection
%           o true : new GUI selection
%           o handle : existing GUI selection
%
%       - style : style structure for GUI selection (see iselect_jd)
%           o struct (default) : default specification
%
if ~ismember('mute_lukeschedulerparam', who('global'))
    mute_lukeschedulerparam = 0;
else
    global mute_lukeschedulerparam
end
%
if nargin < 7,
    style = struct;% no fast electron transport
end
if nargin < 6,
    opt_gui = false;% no fast electron transport
end
if nargin < 5,
    transpmode = false;% no fast electron transport
end
if nargin < 4,
    returnmode = [];% prompt for choice
end
if nargin < 3,
    remnum = [];% prompt for choice
end
if nargin < 2,
    mdce_mode = [];% prompt for choice
end
if nargin < 1 || isempty(dkepath) || any(~isfield(dkepath,{'remote','distprofiles','remprofiles'})),
    dkepath = load_structures_yp('dkepath','','');
end
%
nrem = length(dkepath.remote);
%
% initial selection
%
if isfield(dkepath,'clustermode') && isfield(dkepath.clustermode,'run_lukert') && isfield(dkepath.clustermode.run_lukert,'scheduler'),
    scheduler = dkepath.clustermode.run_lukert.scheduler;
else
    scheduler = struct;
end
%
if isempty(mdce_mode),
    if isfield(scheduler,'mode') && isscalar(scheduler.mode) && isnumeric(scheduler.mode) && any(scheduler.mode == -nrem:2),
        mdce_mode = scheduler.mode;
        if mdce_mode < 0,
            mdce_mode = 2 - mdce_mode;
        end
    else
        mdce_mode = 0;
    end
    mdce_mode = iselect_jd(dkepath.distprofiles,'Distribution of calc. : ',opt_gui,style,1 + mdce_mode,'popupmenu') - 1;
    if mdce_mode > 2,
        mdce_mode = 2 - mdce_mode;%use of remcomputing with negative mdce_mode
    end
elseif ~isscalar(mdce_mode) || ~isnumeric(mdce_mode) || ~any(mdce_mode == -nrem:3),
    disp('WARNING : invalid choice entered for mdce_mode. Sequential mode enforced.');
    mdce_mode = 0;
end
%
if isempty(remnum),
    if isfield(scheduler,'remnum') && isscalar(scheduler.remnum) && isnumeric(scheduler.remnum) && any(scheduler.remnum == 0:nrem),
        remnum = scheduler.remnum;
    else
        remnum = 0;
    end
    remnum = iselect_jd(dkepath.remprofiles,'Where do you want to run LUKE ?',opt_gui,style,1 + remnum,'popupmenu') - 1;
elseif ~isscalar(remnum) || ~isnumeric(remnum) || ~any(remnum == 0:nrem),
    disp('WARNING : invalid choice entered for remnum. Local calculation enforced.');
    remnum = 0;
end
%
if isempty(returnmode) && (mdce_mode < 0 || remnum > 0),
    if isfield(scheduler,'remtimout') && scheduler.remtimout == 0,
        waitstr = 'n';
    else
        waitstr = 'y';
    end
    returnmode = input_dke_yp('Do you want to wait for results (y/n)',waitstr,{'y','n'}) == 'n';
elseif isempty(returnmode) || (remnum == 0 && mdce_mode >= 0),
    returnmode = false;
end
if ~isscalar(returnmode) || (~islogical(returnmode) && (~isnumeric(returnmode) || ~any(returnmode == 0:1))),
    disp('WARNING : invalid choice entered for returnmode. Waiting for results.');
    returnmode = false;
elseif returnmode && mdce_mode > 0 && remnum == 0,
    disp('WARNING : returnmode enforced to ''off'' for local distributed calculation with mdce_mode == 1,2.');
    returnmode = false;
end
%
if isstruct(transpmode),% transpmode is transpfaste
    if (isfield(transpmode,'Dr0') &&  transpmode.Dr0 > 0) || (isfield(transpmode,'Vr0') &&  transpmode.Vr0 ~= 0),
        transpmode = true;
    else
        transpmode = false;
    end
elseif isempty(transpmode),
    transpmode = false;
elseif ~isscalar(transpmode) || (~islogical(transpmode) && (~isnumeric(transpmode) || ~any(transpmode == 0:1))),
    disp('WARNING : invalid choice entered for transpmode. transpmode == false enforced.');
    transpmode = false;
end
%
dkepath.clustermode.run_lukert.scheduler.mode = mdce_mode;
dkepath.clustermode.run_lukert.scheduler.remnum = remnum;
if returnmode,
    dkepath.clustermode.run_lukert.scheduler.remtimout = 0;
else
    dkepath.clustermode.run_lukert.scheduler.remtimout = 60*24;% (minutes) 24 hours default limit
end    
if(isfield(dkepath,'luke_memory') && ~isempty(dkepath.luke_memory))
    dkepath.clustermode.run_lukert.scheduler.memory = dkepath.luke_memory;
else
    if transpmode,
        dkepath.clustermode.run_lukert.scheduler.memory = 14000;% (mb) 14 GB default memory with fast electron transport
    else
        dkepath.clustermode.run_lukert.scheduler.memory = 7000;% (mb) 7 GB default memory without fast electron transport
    end
end
%
dkepath.clustermode.run_lukert.scheduler.walltime = 24;% (hours) 24 hours default limit, corresponds to remtimout for direct modes
dkepath.clustermode.run_lukert.scheduler.enforce = 0+2i;% three MDCE attempts, no seq switch
%
if mute_lukeschedulerparam == 0
    if dkepath.clustermode.run_lukert.scheduler.remnum > 0,
        if strcmp(dkepath.remote(dkepath.clustermode.run_lukert.scheduler.remnum).scheduler,'torque') | strcmp(dkepath.remote(dkepath.clustermode.run_lukert.scheduler.remnum).scheduler,'pbs'),
            queuemode = input_dke_yp('Do you want to see queuing parameters for ''torque'' or ''pbs'' schedulers (y/n)','n',{'y','n'}) == 'y';
            if queuemode,
                %
                disp('----------------------------- default queue parameters ----------------------------')
                disp(' ')
                disp(dkepath.remote(dkepath.clustermode.run_lukert.scheduler.remnum).queue);
                disp('-----------------------------------------------------------------------------------');
                disp('WARNING: the queue parameters may be changed in remote profiles (MatRemote toolbox)');
                disp('-----------------------------------------------------------------------------------');
            end
        end  
    end
end