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
    if status.external == 0,
        lukeobj.infotext.string = infostrs.startup;
    else
        lukeobj.infotext.string = infostrs.data;
    end
end

if status.output < 1,
    status.hxr = -1;
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
lukeobj.graph1sel.value = 1 + lukeobj.plot1.gindex;
lukeobj.graph2sel.value = 1 + lukeobj.plot2.gindex;
lukeobj.graph3sel.value = 1 + lukeobj.plot3.gindex;
%
cleartags = {};
    
%
% UPDATE OBJECTS
%

iluke_update_state(lukeobj);
