%script iluke_update

if isempty(external),
    status.external = 0;
end

if isempty(equil),
    status.equil = 0;
    status.ohm = -1;
    status.transpfaste = -1;
    status.ripple = -1;
    status.waves = -1;
    status.output = -1;
end

if status.output < 1,
    status.hxr = -1;
end

[external,lukeobj.data] = iluke_status(external,status.external,lukeobj.data,0);
[equil,lukeobj.equil] = iluke_status(equil,status.equil,lukeobj.equil,0);
[ohm,lukeobj.ohm] = iluke_status(ohm,status.ohm,lukeobj.ohm,0);
[transpfaste,lukeobj.transp] = iluke_status(transpfaste,status.transpfaste,lukeobj.transp,0);
[ripple,lukeobj.ripple] = iluke_status(ripple,status.ripple,lukeobj.ripple,0);
[waves,lukeobj.wave] = iluke_status(waves,status.waves,lukeobj.wave,0);

[output,lukeobj.luke] = iluke_status(output,status.output,lukeobj.luke,1);
[hxr,lukeobj.r5x2] = iluke_status(hxr,status.hxr,lukeobj.r5x2,1);

set(mainfig.handle,'position',mainfig.position);
%
set(titlepanel.handle,'Position',titlepanel.position);
set(controlpanel.handle,'Position',controlpanel.position);
set(infopanel.handle,'Position',infopanel.position);
%
set(plot1.handle,'Position',plot1.position);
set(plot2.handle,'Position',plot2.position);
set(plot3.handle,'Position',plot3.position);
%
set(tokamaktitle.handle,'String',tokamaktitle.string,'Position',tokamaktitle.position);
set(shotnumtitle.handle,'String',shotnumtitle.string,'Position',shotnumtitle.position);
set(shotimetitle.handle,'String',shotimetitle.string,'Position',shotimetitle.position);

set(tokamak.handle,'String',tokamak.string,'Position',tokamak.position);
set(shotnum.handle,'String',shotnum.string,'Position',shotnum.position);
set(shotime.handle,'String',shotime.string,'Position',shotime.position);

set(lukeroottitle.handle,'String',lukeroottitle.string,'Position',lukeroottitle.position);
set(lukevertitle.handle,'String',lukevertitle.string,'Position',lukevertitle.position);
set(simulfiletitle.handle,'String',simulfiletitle.string,'Position',simulfiletitle.position);

set(lukeroot.handle,'String',lukeroot.string,'Position',lukeroot.position);
set(lukever.handle,'String',lukever.string,'Position',lukever.position);
set(simulfile.handle,'String',simulfile.string,'Position',simulfile.position);

set(titlestr.handle,'String',titlestr.string,'Position',titlestr.position);

set(exitluke.handle,'String',exitluke.string,'Position',exitluke.position,'Enable',exitluke.state,'Callback',exitluke.callback);
set(newshot.handle,'String',newshot.string,'Position',newshot.position,'Enable',newshot.state);
set(loadshot.handle,'String',loadshot.string,'Position',loadshot.position,'Enable',loadshot.state);
set(saveshot.handle,'String',saveshot.string,'Position',saveshot.position,'Enable',saveshot.state);

%
set(controlstr.handle,'String',controlstr.string,'Position',controlstr.position);

iluke_update_state(lukeobj);

% set(lukeobj.data.import.handle,'Enable',lukeobj.data.import.state);
% set(lukeobj.equil.make.handle,'Enable',lukeobj.equil.make.state);
% set(lukeobj.ohm.make.handle,'Enable',lukeobj.ohm.make.state);
% set(lukeobj.transp.make.handle,'Enable',lukeobj.transp.make.state);
% set(lukeobj.ripple.make.handle,'Enable',lukeobj.ripple.make.state);
% set(lukeobj.wave.make.handle,'Enable',lukeobj.wave.make.state);
% 
% set(lukeobj.data.load.handle,'Enable',lukeobj.data.load.state);
% set(lukeobj.equil.load.handle,'Enable',lukeobj.equil.load.state);
% set(lukeobj.ohm.load.handle,'Enable',lukeobj.ohm.load.state);
% set(lukeobj.transp.load.handle,'Enable',lukeobj.transp.load.state);
% set(lukeobj.ripple.load.handle,'Enable',lukeobj.ripple.load.state);
% set(lukeobj.wave.load.handle,'Enable',lukeobj.wave.load.state);
% 
% set(lukeobj.data.save.handle,'Enable',lukeobj.data.save.state);
% set(lukeobj.equil.save.handle,'Enable',lukeobj.equil.save.state);
% set(lukeobj.ohm.save.handle,'Enable',lukeobj.ohm.save.state);
% set(lukeobj.transp.save.handle,'Enable',lukeobj.transp.save.state);
% set(lukeobj.ripple.save.handle,'Enable',lukeobj.ripple.save.state);
% set(lukeobj.wave.save.handle,'Enable',lukeobj.wave.save.state);

% set(lukeobj.luke.run.handle,'Enable',lukeobj.luke.run.state);
% set(lukeobj.r5x2.run.handle,'Enable',lukeobj.r5x2.run.state);

% set(lukeobj.data.clear.handle,'Enable',lukeobj.data.clear.state);
% set(lukeobj.equil.clear.handle,'Enable',lukeobj.equil.clear.state);
% set(lukeobj.ohm.clear.handle,'Enable',lukeobj.ohm.clear.state);
% set(lukeobj.transp.clear.handle,'Enable',lukeobj.transp.clear.state);
% set(lukeobj.ripple.clear.handle,'Enable',lukeobj.ripple.clear.state);
% set(lukeobj.wave.clear.handle,'Enable',lukeobj.wave.clear.state);
% set(lukeobj.luke.clear.handle,'Enable',lukeobj.luke.clear.state);
% set(lukeobj.r5x2.clear.handle,'Enable',lukeobj.r5x2.clear.state);

% set(lukeobj.data.disp.handle,'Enable',lukeobj.data.disp.state);
% set(lukeobj.equil.disp.handle,'Enable',lukeobj.equil.disp.state);
% set(lukeobj.ohm.disp.handle,'Enable',lukeobj.ohm.disp.state);
% set(lukeobj.transp.disp.handle,'Enable',lukeobj.transp.disp.state);
% set(lukeobj.ripple.disp.handle,'Enable',lukeobj.ripple.disp.state);
% set(lukeobj.wave.disp.handle,'Enable',lukeobj.wave.disp.state);
% set(lukeobj.luke.disp.handle,'Enable',lukeobj.luke.disp.state);
% set(lukeobj.r5x2.disp.handle,'Enable',lukeobj.r5x2.disp.state);

% set(lukeobj.data.text.handle,'String',lukeobj.data.text.string);
% set(lukeobj.equil.text.handle,'String',lukeobj.equil.text.string);
% set(lukeobj.ohm.text.handle,'String',lukeobj.ohm.text.string);
% set(lukeobj.transp.text.handle,'String',lukeobj.transp.text.string);
% set(lukeobj.ripple.text.handle,'String',lukeobj.ripple.text.string);
% set(lukeobj.wave.text.handle,'String',lukeobj.wave.text.string);
% set(lukeobj.luke.text.handle,'String',lukeobj.luke.text.string);
% set(lukeobj.r5x2.text.handle,'String',lukeobj.r5x2.text.string,);

set(infotext.handle,'String',infotext.string,'Position',infotext.position);
set(infostr.handle,'String',infostr.string,'Position',infostr.position);

if plot2.gindex == plot1.gindex,
    plot2.gindex = 0;
end
if any(plot3.gindex == [plot1.gindex,plot2.gindex]),
    plot3.gindex = 0;
end
%
plothandles = [plot1.handle,plot2.handle,plot3.handle];
plotindices = [plot1.gindex,plot2.gindex,plot3.gindex];
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
graph1sel.string = graphsel_string;
graph2sel.string = graphsel_string;
graph3sel.string = graphsel_string;
%
graph1sel.value = 1 + plot1.gindex;
graph2sel.value = 1 + plot2.gindex;
graph3sel.value = 1 + plot3.gindex;
%
cleartags = {};
    
set(graph1sel.handle,'String',graph1sel.string,'Position',graph1sel.position,'Value',graph1sel.value);
set(graph2sel.handle,'String',graph2sel.string,'Position',graph2sel.position,'Value',graph2sel.value);
set(graph3sel.handle,'String',graph3sel.string,'Position',graph3sel.position,'Value',graph3sel.value);

set(graph1save.handle,'String',graph1save.string,'Position',graph1save.position);
set(graph2save.handle,'String',graph2save.string,'Position',graph2save.position);
set(graph3save.handle,'String',graph3save.string,'Position',graph3save.position);

set(graph1print.handle,'String',graph1print.string,'Position',graph1print.position);
set(graph2print.handle,'String',graph2print.string,'Position',graph2print.position);
set(graph3print.handle,'String',graph3print.string,'Position',graph3print.position);
