function lukestructs = sluke_launch_sim(sparams,ii,lukestructs,dkepath)

sparams = checkJConsistencyConsitency_InScript(sparams,ii);


if ~sluke_eval_subfield(sparams.simul,ii,'jprofileconsistency','nit',@(nit)nit>1)
    % not sparams.simul.jprofileconsistency.nit > 1 => single simulation
    lukestructs = run_lukert(lukestructs,dkepath);%run C3PO/LUKE locally or remotely
else
    %add sluke.jprofilconsistency.datapath for sluke_jconsistency_(remote_)run
    if ~sluke_eval_subfield(sparams.simul,ii,'jprofileconsistency','datapath',@(x) ~isempty(x))
        sz = size(sparams.machine);
        sparams.simul.jprofileconsistency.datapath =  cell(sz);
        sparams.simul.jprofileconsistency.datapath{ii} = pwd; 
    end
    %load post and needed variable for z0dinput
    post = loadPost_InScript(sparams,ii); 
    loadAllData4Metis_InScript(sparams.discharge.shot,post);
    %Format remote handling
    [remoteCalcAsked,lukestructs,cellmode] = remoteFormatting_InScript(lukestructs,dkepath);
    
    if remoteCalcAsked %remote and/or distributed calculation
        lukestructs = sluke_jconsistency_remote_run(sparams,ii,lukestructs,post,dkepath,cellmode); 
    else %launch the simulation locally   
        lukestructs = sluke_jconsistency_run(sparams,ii,lukestructs,post);
    end
end

end

%-------------------------------------------------------------------------
% InScript Functions
%-------------------------------------------------------------------------
function sparams = checkJConsistencyConsitency_InScript(sparams,ii)
jConsistency  = sluke_eval_subfield(sparams,ii,'simul','jprofileconsistency','nit',@(nit)nit>1); %problems just if nit > 1
LHwavePresent = sluke_eval_subfield(sparams,ii,'rfwaves','enable',@(x) ~isempty(x)&&x ) &&...
    all( sluke_eval_subfield(sparams,ii,'rfwaves','antenna','type',@(tp) strcmp(tp,"LH")) );
if jConsistency && ~LHwavePresent
    cprintf([1,0.5,0],'--> A number of iteration greater than one is prescribed for jprofileconsistency but either no LH or not just LH waves are found in sparams. It is set to 1.\n') %orange
    sparams.simul.jprofileconsistency.nit{ii} = 1;
end
end

function [remoteFlag,lukestructs,cellmode] = remoteFormatting_InScript(lukestructs,dkepath)
if ~iscell(lukestructs) && any(isfield(lukestructs,{'job','output','err'})) ... % job started already
        || isfield(dkepath,'clustermode') && isfield(dkepath.clustermode,'run_lukert') % use of MDCE
    
    cellmode = 0;% flag to return lukestructs in the same wrapper as input
    lukestructs = {lukestructs};% lukestructs must be in cell for distributed or remote calculation
else
    cellmode = 1;
end
remoteFlag = iscell(lukestructs);
end

function loadAllData4Metis_InScript(shot,post)
%list of signals to load, if z0dinput is aviable, do not need most of them
if isempty(post)
    list = {'GHXR3',      'GPROFCHKVSPX%1', 'GPROFILEVSPX', 'GPROFNEFIT', ...
            'GPROFTEFIT', 'SCIONBRAG',      'SDEPLW',       'SHAUTTOR',   ...
            'SPROFIP',    'gbilan%11',      'gbilan',       'gfluxnoy%4', ...
            'gnl',        'gphyb'           'gplasma',      'gptore',     ...
            'gpuifci',    'gqbeli',         'grho',         'gshr',       ...
            'gshtenv',    'sdeb',           'sika1',        'sipmes',     ...
            'sitor',      'snli',           'snmoy',        'spiq',       ...
            'sprad',      'stebrag',        'stibrag',      'szfbrm'};
else
    list = {'GPROFNEFIT', 'GPROFTEFIT'};
end

shotDouble = str2double(shot);

%chek if exist all needed tsbase_shot_signal data 
existAll = 1;
jj = 1;
while jj <= length(list) && existAll
    existAll = remoteUtil_ExistDataSaved("tsbase",shotDouble,list{jj});
    jj = jj+1;
end

if ~existAll    
    % enter this section only it does not all data exists
    
    %load all data through one multiple remote request, save them as single
    %remote request 
    remote_mtsbase(shotDouble,list);
    remoteUtil_mxxx2xxx("mtsbase",shotDouble,list,1);
end 
    
end

function post = loadPost_InScript(sparams,ii)
    post = []; % to catch absence of file/data.
    if sluke_eval_subfield(sparams,ii,'equil','source',@(src)strcmp(src,'file'))
        filePath = formatFilePath_InScript(sparams,ii);
        data = load(filePath);
        if isfield(data,'post') % equilibrium from metis simulations
            post = data.post;
        end 
    end
end

function path = formatFilePath_InScript(sparams,ii)
    equil_file = sparams.equil.file{ii};
        if strcmp(sparams.equil.path{ii},'.')
            equil_path = [pwd,'/'];
        else
            if strcmp(sparams.equil.path{ii}(end),'/')
                equil_path = sparams.equil.path{ii};
            else
                equil_path = [sparams.equil.path{ii},'/'];
            end
        end
        path = [equil_path,equil_file];
end 