%script iluke_update

%
% UPDATE STATUS
%
if isempty(external),
    status.external = 0;
end

if isempty(equil),
    status.equil = 0;
end

if status.equil == 0,
    status.ohm = -1;
    status.transpfaste = -1;
    status.ripple = -1;
    status.waves = -1;
    status.output = -1;
    lukeobj.lukeid.string = '';
    %
    if status.external == 0,
        lukeobj = iluke_info(lukeobj,'startup');% info display
    else
        lukeobj = iluke_info(lukeobj,'data');% info display
    end
end

if isempty(external) && isempty(equil)
    lukeobj.tokamak.string = '< empty >';
    lukeobj.shotnum.string = '< empty >';
    lukeobj.shotime.string = '< empty >';
end

if status.output < 1,
    status.hxr = -1;
else
    status.hxr = 0;
end

%
% UPDATE STATES/STRINGS
%

[external,lukeobj.data,cleartags] = iluke_status(external,status.external,lukeobj.data,0,cleartags);
[equil,lukeobj.equil,cleartags] = iluke_status(equil,status.equil,lukeobj.equil,0,cleartags);
[ohm,lukeobj.ohm,cleartags] = iluke_status(ohm,status.ohm,lukeobj.ohm,0,cleartags);
[transpfaste,lukeobj.transp,cleartags] = iluke_status(transpfaste,status.transpfaste,lukeobj.transp,0,cleartags);
[ripple,lukeobj.ripple,cleartags] = iluke_status(ripple,status.ripple,lukeobj.ripple,0,cleartags);
[waves,lukeobj.wave,cleartags] = iluke_status(waves,status.waves,lukeobj.wave,0,cleartags);

[output,lukeobj.luke,cleartags] = iluke_status(output,status.output,lukeobj.luke,1,cleartags);
[hxr,lukeobj.r5x2,cleartags] = iluke_status(hxr,status.hxr,lukeobj.r5x2,1,cleartags);

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
nrem = length(dkepath.remote);
lukeobj.remote.select.string = cell(1,1 + nrem);
lukeobj.remote.select.string{1} = 'Local interactive calculation';
%
for irem = 1:nrem,
    %
    hoststr = dkepath.remote(irem).host;
    if iscell(hoststr),
        hoststr = hoststr{1};
    end
    if isempty(hoststr),
        hoststr = 'Local batch calculation';
    end
    %
    cmdstr = dkepath.remote(irem).cmd;
    if iscell(cmdstr),
        cmdstr = cmdstr{1};
    end
    cmdstr = cmdstr(1:min([end,find(cmdstr == ' ' | cmdstr == '_',1,'first') - 1]));
    %
    lukeobj.remote.select.string{irem + 1} = [hoststr,' : ',cmdstr];
    %
end
%
clear irem nrem cmdstr hoststr
%
if lukeobj.remote.select.value > 1,
    lukeobj.remote.timeout.state = 'on';
else
    lukeobj.remote.timeout.state = 'off';
end

%
% WAVESTRUCTS
%
iluke_update_wavestruct;

%
% UPDATE OBJECTS
%

iluke_update_state(lukeobj);
