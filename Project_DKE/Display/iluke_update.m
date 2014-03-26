%script iluke_update

%
% UPDATE STATUS
%

[external,lukeobj.data,cleartags] = iluke_status(external,status.external,lukeobj.data,0,1,cleartags);

%
% manage the data structures based on status.equil, which refers to each shotime
%
% at this point it is necessary that shotimes, status.equil, and equils all have the same dimension.
%
%   - status.equil(it) = -1 : equil & shotime to be removed
%   - status.equil(it) = 0 : equil to be cleared & shotime kept (external not empty)
%   - status.equil(it) = 1 : equil exists & shotime maintained
%   - status.equil(it) = 2 : new shot time & empty equils 
%   - status.equil(it) = 3 : new shot time & full equils 
%
if length(status.equil) ~= length(equils),
    error('Inconsistency between status.equil & equils')
end
if length(status.equil) ~= length(shotimes),
    error('Inconsistency between status.equil & shotimes')
end
%
flag_remove = status.equil == -1;
%
% remove outdated times
%
shotimes(flag_remove) = [];

equils(flag_remove) = [];
ohms(flag_remove) = [];
transpfastes(flag_remove) = [];
ripples(flag_remove) = [];
wavess(flag_remove) = [];
%
wavestructss(flag_remove) = [];
%
jobs(flag_remove) = [];
outputs(flag_remove) = [];
hxrs(flag_remove) = [];

status.equil(flag_remove) = [];
status.ohm(flag_remove) = [];
status.transpfaste(flag_remove) = [];
status.ripple(flag_remove) = [];
status.waves(flag_remove) = [];
status.wavestructs(flag_remove) = [];
status.job(flag_remove) = [];
status.output(flag_remove) = [];
status.hxr(flag_remove) = [];

% delete outdated graphs
flag_remove_g = find(flag_remove) + 2;% +2 for <new>,<all>
for it = 1:length(flag_remove_g),
    %
    ngraphs = length(graphss{flag_remove_g(it)});
    for igraph = ngraphs:-1:1,% sum over graphs
        delete(graphss{flag_remove_g(it)}(igraph).handles);% clear all graph components
    end
    %
end
graphss(flag_remove_g) = [];
cleartags(flag_remove_g) = [];
lukeobj.plot1.gindex(flag_remove_g) = [];
lukeobj.plot2.gindex(flag_remove_g) = [];
lukeobj.plot3.gindex(flag_remove_g) = [];

flag_clear = status.equil == 0;
flag_newempty = status.equil == 2;
flag_newfull = status.equil == 3;

flag_new = flag_newempty | flag_newfull;% new equils
%
if any(diff(flag_new) < 0),
    error('New equils must be added at the end')
end

%
% add new times 
%
nnew = sum(flag_new);%number of new times

ohms(end+1:end+nnew) = {[]};
transpfastes(end+1:end+nnew) = {[]};
ripples(end+1:end+nnew) = {[]};
wavess(end+1:end+nnew) = {{}};
%
wavestructss(end+1:end+nnew) = {{}};
%
jobs(end+1:end+nnew) = {[]};
outputs(end+1:end+nnew) = {[]};
hxrs(end+1:end+nnew) = {[]};

status.ohm(end+1:end+nnew) = 0;
status.transpfaste(end+1:end+nnew) = 0;
status.ripple(end+1:end+nnew) = 0;
status.waves(end+1:end+nnew) = 0;
status.wavestructs(end+1:end+nnew) = 0;
status.job(end+1:end+nnew) = 0;
status.output(end+1:end+nnew) = 0;
status.hxr(end+1:end+nnew) = 0;

graphss(end+1:end+nnew) = graphss(1);% fill with empty structures with memory of fields
cleartags(end+1:end+nnew) = {{}};
lukeobj.plot1.gindex(end+1:end+nnew) = 0;
lukeobj.plot2.gindex(end+1:end+nnew) = 0;
lukeobj.plot3.gindex(end+1:end+nnew) = 0;

%
% structures to be cleared
%
equils(flag_clear) = {[]};
ohms(flag_clear) = {[]};
transpfastes(flag_clear) = {[]};
ripples(flag_clear) = {[]};
wavess(flag_clear) = {{}};
%
wavestructss(flag_clear) = {{}};
%
jobs(flag_clear) = {[]};
outputs(flag_clear) = {[]};
hxrs(flag_clear) = {[]};

flag_clear_g = find(flag_clear) + 2;% +2 for <new>,<all>
cleartags(flag_clear_g) = {'all'};% clear all graphs corresponding to cleared times

status.equil(flag_newempty) = 0;
status.equil(flag_newfull) = 1;

flag_clear = flag_clear | flag_newempty;

status.ohm(flag_clear) = -1;
status.transpfaste(flag_clear) = -1;
status.ripple(flag_clear) = -1;
status.waves(flag_clear) = -1;
status.wavestructs(flag_clear) = -1;
status.job(flag_clear) = -1;
status.output(flag_clear) = -1;
status.hxr(flag_clear) = -1;

%
% sort times removing previous structures if recurrence
%
[shotimes,mask] = unique(shotimes,'last');

ntimes = length(shotimes);

equils = equils(mask);
ohms = ohms(mask);
transpfastes = transpfastes(mask);
ripples = ripples(mask);
wavess = wavess(mask);
%
wavestructss = wavestructss(mask);
%
jobs = jobs(mask);
outputs = outputs(mask);
hxrs = hxrs(mask);

status.equil = status.equil(mask);
status.ohm = status.ohm(mask);
status.transpfaste = status.transpfaste(mask);
status.ripple = status.ripple(mask);
status.waves = status.waves(mask);
status.wavestructs = status.wavestructs(mask);
status.job = status.job(mask);
status.output = status.output(mask);
status.hxr = status.hxr(mask);

status.hxr(status.output < 1) = -1;% synthetic diagnostics need distribution

mask_g = [1,2,2+mask(:).'];% 1,2 for <new>,<all>
graphss = graphss(mask_g);
cleartags = cleartags(mask_g);
lukeobj.plot1.gindex = lukeobj.plot1.gindex(mask_g);
lukeobj.plot2.gindex = lukeobj.plot2.gindex(mask_g);
lukeobj.plot3.gindex = lukeobj.plot3.gindex(mask_g);

clear flag_remove flag_remove_g flag_clear flag_clear_g flag_newempty flag_newfull flag_new nnew mask mask_g

if ntimes == 1 && curtime == 0,
    curtime = 1;
end

if curtime > 0,
    if status.output(curtime) == 0 && isempty(jobs{curtime}),
        lukeobj.runluke.highlight = true;
    else
        lukeobj.runluke.highlight = false;
    end            
else% curtime = 0, treat or display all times at once      
    if all(status.equil == 0),
        lukeobj.equil.make.highlight = true;      
    else
        lukeobj.equil.make.highlight = false;    
    end      
end

%
% UPDATE STATES/STRINGS
%

[equils,lukeobj.equil,cleartags] = iluke_status(equils,status.equil,lukeobj.equil,-1,curtime,cleartags);
[ohms,lukeobj.ohm,cleartags] = iluke_status(ohms,status.ohm,lukeobj.ohm,0,curtime,cleartags);
[transpfastes,lukeobj.transp,cleartags] = iluke_status(transpfastes,status.transpfaste,lukeobj.transp,0,curtime,cleartags);
[ripples,lukeobj.ripple,cleartags] = iluke_status(ripples,status.ripple,lukeobj.ripple,0,curtime,cleartags);
[wavess,lukeobj.wave,cleartags] = iluke_status(wavess,status.waves,lukeobj.wave,0,curtime,cleartags);

[outputs,lukeobj.luke,cleartags] = iluke_status(outputs,status.output,lukeobj.luke,1,curtime,cleartags);
[hxrs,lukeobj.r5x2,cleartags] = iluke_status(hxrs,status.hxr,lukeobj.r5x2,1,curtime,cleartags);

%
% WAVESTRUCTS
%

iluke_update_wavestruct;


if ntimes == 0,
    tokamak = '';
    shotnum = '';
    
    status.data = -1;
    lukeobj = iluke_info(lukeobj,'startup');% info display
    
    lukeobj.data.import.highlight = true;
    lukeobj.equil.make.highlight = false;
else
    lukeobj.data.import.highlight = false;
end


if ~isempty(tokamak),
    lukeobj.tokamak.string = tokamak;
else
    lukeobj.tokamak.string = '< empty >';
end

if ~isempty(shotnum),
    lukeobj.shotnum.string = shotnum;
else
    lukeobj.shotnum.string = '< empty >';
end

lukeobj.shotimes.string = cell(1,ntimes + 2);
lukeobj.shotimes.string{1} = '< new >';
lukeobj.shotimes.string{2} = '< all >';
for it = 1:ntimes,
    lukeobj.shotimes.string{it + 2} = num2str(shotimes(it),'%6.4f');
end

clear it

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
% clear tagged graphs and fix indices 
%
for it = 1:ntimes+2,
    %
    % graphs cannot have two parents
    %
    if lukeobj.plot2.gindex(it) == lukeobj.plot1.gindex(it),
        lukeobj.plot2.gindex(it) = 0;
    end
    if any(lukeobj.plot3.gindex(it) == [lukeobj.plot1.gindex(it),lukeobj.plot2.gindex(it)]),
        lukeobj.plot3.gindex(it) = 0;
    end
    %    
    plotindices = [lukeobj.plot1.gindex(it),lukeobj.plot2.gindex(it),lukeobj.plot3.gindex(it)];
    %
    % clear outdated graphs and make others not visible
    %
    ngraphs = length(graphss{it});
    for igraph = ngraphs:-1:1,
        if any(strcmp(cleartags{it},'all')) || any(strcmp(graphss{it}(igraph).tag,cleartags{it})),
            delete(graphss{it}(igraph).handles)
            graphss{it}(igraph) = [];
            plotindices(plotindices == igraph) = 0;
            plotindices(plotindices > igraph) = plotindices(plotindices > igraph) - 1;
        else
            recset_jd(graphss{it}(igraph).handles,'Visible','off',true)
        end
    end
    %
    lukeobj.plot1.gindex(it) = plotindices(1);
    lukeobj.plot2.gindex(it) = plotindices(2);
    lukeobj.plot3.gindex(it) = plotindices(3);
    % 
    cleartags{it} = {};% cleartags can be purged
    %
end
clear it 

%
% move and/or show selected graphs
%
graphs = graphss{2+curtime};
ngraphs = length(graphs);
graphsel_string = cell(1,ngraphs+1);
graphsel_string{1} = '';
%
plothandles = [lukeobj.plot1.handle,lukeobj.plot2.handle,lukeobj.plot3.handle];
plotindices = [lukeobj.plot1.gindex(2+curtime),lukeobj.plot2.gindex(2+curtime),lukeobj.plot3.gindex(2+curtime)];
%
for igraph = 1:ngraphs,
    graphsel_string{igraph+1} = graphs(igraph).info;
    iplot = find(igraph == plotindices);
    if ~isempty(iplot),
        recset_jd(graphs(igraph).handles,'Parent',plothandles(iplot),false)
        recset_jd(graphs(igraph).handles,'Visible','on',true)
    end
end
%
lukeobj.graph1sel.string = graphsel_string;
lukeobj.graph2sel.string = graphsel_string;
lukeobj.graph3sel.string = graphsel_string;
%
lukeobj.graph1sel.value = 1 + plotindices(1);
lukeobj.graph2sel.value = 1 + plotindices(2);
lukeobj.graph3sel.value = 1 + plotindices(3);
%
clear plothandles plotindices graphsel_string igraph iplot ich graphs ngraphs
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
lukeobj.shotimes.value = 2 + curtime;

iluke_update_state(lukeobj);
