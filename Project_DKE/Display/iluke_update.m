%script iluke_update

%
% UPDATE STATUS
%

if isempty(external),
    status.external = 0;
end

[external,lukeobj.data,cleartags] = iluke_status(external,status.external,lukeobj.data,0,cleartags);

if isscalar(status.equil) && status.equil == -1,
    %
    % new external structure : update structures, statuses, and lukeobj.shotimes.string
    %
    % Note : a new (or cleared) external structure is the only way to modify ntimes
    %
    if isfield(external,'shotime'),% one time external data
        lukeobj.shotimes.string = [lukeobj.shotimes.string(1),external.shotime];
        curtime = 1;
    elseif isfield(external,'shotimes'),% multi times external data
        lukeobj.shotimes.string = [lukeobj.shotimes.string(1),external.shotimes];
        curtime = 0;
    elseif isempty(external),% empty external data
        lukeobj.shotimes.string = [lukeobj.shotimes.string(1),'< empty >'];
        curtime = 1;
    else
        error('status of structure ''external'' cannot be identified')
    end
    %
    ntimes = length(lukeobj.shotimes.string) - 1;
    %
    equils = repmat({[]},[1,ntimes]);
    ohms = repmat({[]},[1,ntimes]);
    transpfastes = repmat({[]},[1,ntimes]);
    ripples = repmat({[]},[1,ntimes]);
    wavess = repmat({{}},[1,ntimes]);
    %
    wavestructss = repmat({{}},[1,ntimes]);
    %
    jobs = repmat({[]},[1,ntimes]);
    outputs = repmat({[]},[1,ntimes]);
    hxrs = repmat({[]},[1,ntimes]);
    %
    status.equil = zeros(1,ntimes);
    %
    status.ohm = -ones(1,ntimes);
    status.transpfaste = -ones(1,ntimes);
    status.ripple = -ones(1,ntimes);
    status.waves = -ones(1,ntimes);
    status.wavestructs = -ones(1,ntimes);
    status.output = -ones(1,ntimes);
    status.hxr = -ones(1,ntimes);
    %
    if ~isempty(external),
        lukeobj.tokamak.string = external.basestr;
        lukeobj.shotnum.string = external.shotnum;
    end    
    %
else    
    ntimes = length(equils);
end

if curtime > 0,

    if isempty(equils{curtime}),
        status.equil(curtime) = 0;
    end

    if status.equil(curtime) == 0,
        status.ohm(curtime) = -1;
        status.transpfaste(curtime) = -1;
        status.ripple(curtime) = -1;
        status.waves(curtime) = -1;
        status.wavestructs(curtime) = -1;
        %wavestructs{curtime} = {};
        status.output(curtime) = -1;
        lukeobj.lukeid.string{curtime} = '';
        %
        lukeobj = iluke_info(lukeobj,'data');% info display
        %
        lukeobj.equil.make.highlight = true;      
    else
        lukeobj.equil.make.highlight = false;    
    end

    if status.output(curtime) < 1,
        status.hxr(curtime) = -1;
    else
        status.hxr(curtime) = 0;
    end
    
    if status.output(curtime) == 0 && isempty(jobs{curtime}),
        lukeobj.runluke.highlight = true;
    else
        lukeobj.runluke.highlight = false;
    end    
    
    shotimestr = lukeobj.shotimes.string{1 + curtime};
   
    %
    % UPDATE STATES/STRINGS
    %

    [equils{curtime},lukeobj.equil,cleartags] = iluke_status(equils{curtime},status.equil(curtime),lukeobj.equil,0,cleartags);
    [ohms{curtime},lukeobj.ohm,cleartags] = iluke_status(ohms{curtime},status.ohm(curtime),lukeobj.ohm,0,cleartags);
    [transpfastes{curtime},lukeobj.transp,cleartags] = iluke_status(transpfastes{curtime},status.transpfaste(curtime),lukeobj.transp,0,cleartags);
    [ripples{curtime},lukeobj.ripple,cleartags] = iluke_status(ripples{curtime},status.ripple(curtime),lukeobj.ripple,0,cleartags);
    [wavess{curtime},lukeobj.wave,cleartags] = iluke_status(wavess{curtime},status.waves(curtime),lukeobj.wave,0,cleartags);

    [outputs{curtime},lukeobj.luke,cleartags] = iluke_status(outputs{curtime},status.output(curtime),lukeobj.luke,1,cleartags);
    [hxrs{curtime},lukeobj.r5x2,cleartags] = iluke_status(hxrs{curtime},status.hxr(curtime),lukeobj.r5x2,1,cleartags);
    
    %
    % WAVESTRUCTS
    %

    iluke_update_wavestruct;
    
else% curtime = 0, treat or display all times at once  
    
    if all(status.equil == 0),
        lukeobj.equil.make.highlight = true;      
    else
        lukeobj.equil.make.highlight = false;    
    end
    
    shotimestr = 'MultiTimes';
    
    [equils,lukeobj.equil,cleartags] = iluke_status(equils,status.equil,lukeobj.equil,0,cleartags);
    [ohms,lukeobj.ohm,cleartags] = iluke_status(ohms,status.ohm,lukeobj.ohm,0,cleartags);
    [transpfastes,lukeobj.transp,cleartags] = iluke_status(transpfastes,status.transpfaste,lukeobj.transp,0,cleartags);
    [ripples,lukeobj.ripple,cleartags] = iluke_status(ripples,status.ripple,lukeobj.ripple,0,cleartags);
    [wavess,lukeobj.wave,cleartags] = iluke_status(wavess,status.waves,lukeobj.wave,0,cleartags);

    [outputs,lukeobj.luke,cleartags] = iluke_status(outputs,status.output,lukeobj.luke,1,cleartags);
    [hxrs,lukeobj.r5x2,cleartags] = iluke_status(hxrs,status.hxr,lukeobj.r5x2,1,cleartags);
    
end

if status.external == 0 && all(status.equil == 0),
    lukeobj.tokamak.string = '< empty >';
    lukeobj.shotnum.string = '< empty >';
    
    curtime = 1;% current time of work : (0) none or all, or index in shotimes
    
    status.data = -1;
    lukeobj = iluke_info(lukeobj,'startup');% info display
    
    lukeobj.data.import.highlight = true;
    lukeobj.equil.make.highlight = false;
else
    lukeobj.data.import.highlight = false;
end

if status.data == -1,
    lukeobj.simulfile.string = '< no data >';
elseif status.data == 0,
    lukeobj.simulfile.string = '< not saved >';
elseif status.data == 2,
    lukeobj.simulfile.string = '< outdated >';
end

%
% SPECIFIC CASES
%

iluke_manage;

%
% UPDATE GRAPHS & LISTS
%

%
% graphs cannot have two parents
%
if lukeobj.plot2.gindex == lukeobj.plot1.gindex,
    lukeobj.plot2.gindex = 0;
end
if any(lukeobj.plot3.gindex == [lukeobj.plot1.gindex,lukeobj.plot2.gindex]),
    lukeobj.plot3.gindex = 0;
end
%
plothandles = [lukeobj.plot1.handle,lukeobj.plot2.handle,lukeobj.plot3.handle];
plotindices = [lukeobj.plot1.gindex,lukeobj.plot2.gindex,lukeobj.plot3.gindex];
%
% clear outdated graphs
%
ngraphs = length(graphs);
for igraph = ngraphs:-1:1,
    if any(strcmp(graphs(igraph).tag,cleartags)),
        for ich = 1:length(graphs(igraph).handles),
            delete(graphs(igraph).handles(ich))
        end
        graphs(igraph) = [];
        plotindices(plotindices == igraph) = 0;
        plotindices(plotindices > igraph) = plotindices(plotindices > igraph) - 1;
    end
end
%
lukeobj.plot1.gindex = plotindices(1);
lukeobj.plot2.gindex = plotindices(2);
lukeobj.plot3.gindex = plotindices(3);
%
% move and/or show selected graphs
%
ngraphs = length(graphs);
graphsel_string = cell(1,ngraphs+1);
graphsel_string{1} = '';
%
for igraph = 1:ngraphs,
    graphsel_string{igraph+1} = graphs(igraph).info;
    iplot = find(igraph == plotindices);
    for ich = 1:length(graphs(igraph).handles),
        if isempty(iplot),
            recset_jd(graphs(igraph).handles(ich),'Visible','off')
        else
            set(graphs(igraph).handles(ich),'Parent',plothandles(iplot))
            recset_jd(graphs(igraph).handles(ich),'Visible','on')
        end
    end
end
%
lukeobj.graph1sel.string = graphsel_string;
lukeobj.graph2sel.string = graphsel_string;
lukeobj.graph3sel.string = graphsel_string;
%
clear plothandles plotindices graphsel_string igraph iplot ich ngraphs
%
lukeobj.graph1sel.value = 1 + lukeobj.plot1.gindex;
lukeobj.graph2sel.value = 1 + lukeobj.plot2.gindex;
lukeobj.graph3sel.value = 1 + lukeobj.plot3.gindex;
%
cleartags = {};
%
if lukeobj.plot1.gindex > 0,
    lukeobj.graph1save.state = 'on';
    lukeobj.graph1print.state = 'on';
else
    lukeobj.graph1save.state = 'off';
    lukeobj.graph1print.state = 'off';
end    
if lukeobj.plot2.gindex > 0,
    lukeobj.graph2save.state = 'on';
    lukeobj.graph2print.state = 'on';
else
    lukeobj.graph2save.state = 'off';
    lukeobj.graph2print.state = 'off';
end    
if lukeobj.plot3.gindex > 0,
    lukeobj.graph3save.state = 'on';
    lukeobj.graph3print.state = 'on';
else
    lukeobj.graph3save.state = 'off';
    lukeobj.graph3print.state = 'off';
end    
%
% REMOTE
%
if lukeobj.remote.select.value > 1,
    lukeobj.remote.timeout.state = 'on';
else
    lukeobj.remote.timeout.state = 'off';
end

%
% WORKDIR
%
cd(workdir)
lukeobj.workdir.string = workdir;

%
% UPDATE OBJECTS
%
lukeobj.shotimes.value = 1 + curtime;

iluke_update_state(lukeobj);
