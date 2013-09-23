%
% GUI FOR LUKE/C3PO/R5X2
%
clear all
close all
%
[dkepath,dkeparam,dkedisplay] = load_structures_yp('dkepath','','','dkeparam','RT','','dkedisplay','NO_DISPLAY','');
workdir = pwd;
%
lukeobj = struct;
%
% -------------------------------------------------------------------------
%
% ILUKE DIMENSIONS and INITIALIZATION
%
style.panelsep = 5;
%
style.figbaseheight = 900;
style.figbasewidth = 1200;
%
style.plotwidth = 340;
style.plotheight = 300;
%
style.graphwidth = 272;
style.graphheight = 204;
%
style.titlestrwidth = 150;
%
style.simulfiletitlewidth = 120;
style.shotnumtitlewidth = 120; 
style.shotnumwidth = 80; 
style.titlestrheight = 50;
style.workdirtitlecorr = 4;
%
style.titlewidth = 105;
style.butheight = 25;%40;% height of button
style.butwidth = 60;%80;% width of button
style.buthsep = 10;% horizontal separation between buttons
style.butvsep = 10;% vertical separation between buttons
%
style.fontname = 'Liberation Mono';%get(0,'FixedWidthFontName');%'fixedwidth';% font type
style.fontsize = 14;% font size
style.titlefontsize = 2*style.fontsize;
%
% -------------------------------------------------------------------------
%
% FIGURE DIMENSIONS
%
style.figwidth = style.figbasewidth + 3*style.panelsep;
style.figheight = style.figbaseheight + 4*style.panelsep;
%
style.screensize = get(0,'MonitorPositions');
%
style.figleft = fix((style.screensize(3) - style.figwidth)/2);
style.figbottom = fix((style.screensize(4) - style.figheight)/2);
%
if style.figleft < 0 || style.figbottom < 0,
    error(['The screen resolution must be at least ',num2str(style.figwidth),' x ',num2str(style.figheight)])
end
%
lukeobj.mainfig.position = [style.figleft,style.figbottom,style.figwidth,style.figheight];
%
% PANELS DIMENSIONS
%
style.panelwidth = style.figbasewidth - style.plotwidth;
%
style.titleheight = 3*style.butheight + 5*style.butvsep + style.titlestrheight;
%
style.controlpaneltop = style.figbaseheight - style.titleheight + 2*style.panelsep;% top position of button group
style.controlheight = 8*style.butheight + 12*style.butvsep + style.titlestrheight;
style.controlpanelbottom = style.controlpaneltop - style.controlheight;% top position of button group
%
style.infopanelheight = style.controlpanelbottom - 2*style.panelsep;
%
lukeobj.titlepanel.position = [style.panelsep,style.figbaseheight - style.titleheight + 3*style.panelsep,style.panelwidth,style.titleheight];
lukeobj.controlpanel.position = [style.panelsep,style.controlpanelbottom,style.panelwidth,style.controlheight];
lukeobj.infopanel.position = [style.panelsep,style.panelsep,style.panelwidth,style.infopanelheight];
%
style.panelstrcorr = style.titlestrheight + style.butvsep;
%
style.controlheightcorr = style.controlheight - style.panelstrcorr;
style.infoheightcorr = style.infopanelheight - style.panelstrcorr;
%
lukeobj.infotext.position = [style.panelsep + style.buthsep,style.panelsep + style.butvsep,style.panelwidth - 2*style.buthsep,style.infopanelheight - 3*style.butvsep - style.titlestrheight];
lukeobj.infostr.position = [style.buthsep,style.infoheightcorr,style.panelwidth - 2*style.buthsep,style.titlestrheight];
%
lukeobj.plot1.position = [style.panelwidth + 2*style.panelsep,2*style.plotheight + 3*style.panelsep,style.plotwidth,style.plotheight];
lukeobj.plot2.position = [style.panelwidth + 2*style.panelsep,style.plotheight + 2*style.panelsep,style.plotwidth,style.plotheight];
lukeobj.plot3.position = [style.panelwidth + 2*style.panelsep,style.panelsep,style.plotwidth,style.plotheight];
%
% GRAPHS DIMENSIONS
%
style.graph_position = [style.plotwidth - style.buthsep - style.graphwidth,style.plotheight - 2*style.butvsep - style.fontsize - style.butheight - style.graphheight,style.graphwidth,style.graphheight];  
style.gsel_position = [style.buthsep,style.plotheight - style.butvsep - style.butheight,style.plotwidth - 4*style.buthsep - 2*style.butwidth,style.butheight];
style.gsave_position = [style.plotwidth - 2*style.buthsep - 2*style.butwidth,style.plotheight - style.butvsep - style.butheight,style.butwidth,style.butheight];
style.gprint_position = [style.plotwidth - style.buthsep - style.butwidth,style.plotheight - style.butvsep - style.butheight,style.butwidth,style.butheight];
%
lukeobj.graph1sel.position = style.gsel_position;
lukeobj.graph2sel.position = style.gsel_position;
lukeobj.graph3sel.position = style.gsel_position;
%
lukeobj.graph1save.position = style.gsave_position;
lukeobj.graph2save.position = style.gsave_position;
lukeobj.graph3save.position = style.gsave_position;
%
lukeobj.graph1print.position = style.gprint_position;
lukeobj.graph2print.position = style.gprint_position;
lukeobj.graph3print.position = style.gprint_position;
%
% CONTROLS DIMENSIONS
%
style.textheightcorr = (style.butheight - 3*style.fontsize)/2;% correction to center text within button
style.butheightcorr = style.butheight + style.butvsep;
%
style.textheight = 2*style.fontsize;
%
lukeobj.controlstr.position = [style.buthsep,style.controlheightcorr,style.panelwidth - 2*style.buthsep,style.titlestrheight];
%
% SIMULATION INFO DIMENSIONS
%
lukeobj.lukevertitle.position = [style.buthsep,style.titleheight - style.butheight - style.butvsep + style.textheightcorr,style.simulfiletitlewidth,style.textheight];
lukeobj.lukever.position = [2*style.buthsep + style.shotnumtitlewidth,style.titleheight - style.butheight - style.butvsep + style.textheightcorr,style.shotnumwidth + style.buthsep + style.butwidth,style.textheight];
%
lukeobj.tokamaktitle.position = [style.buthsep,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.shotnumtitlewidth,style.textheight];
lukeobj.shotnumtitle.position = [style.buthsep,style.butheight + 2*style.butvsep + style.textheightcorr,style.shotnumtitlewidth,style.textheight];
lukeobj.shotimetitle.position = [style.buthsep,style.butvsep + style.textheightcorr,style.shotnumtitlewidth,style.textheight];
%
lukeobj.tokamak.position = [2*style.buthsep + style.shotnumtitlewidth,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.shotnumwidth,style.textheight];
lukeobj.shotnum.position = [2*style.buthsep + style.shotnumtitlewidth,style.butheight + 2*style.butvsep + style.textheightcorr,style.shotnumwidth,style.textheight];
lukeobj.shotime.position = [2*style.buthsep + style.shotnumtitlewidth,style.butvsep + style.textheightcorr,style.shotnumwidth,style.textheight];
%
lukeobj.exitluke.position = [style.shotnumtitlewidth + style.shotnumwidth + 3*style.buthsep,2*style.butheight + 3*style.butvsep,style.butwidth,style.butheight];
lukeobj.newshot.position = [style.shotnumtitlewidth + style.shotnumwidth + 3*style.buthsep,style.butheight + 2*style.butvsep,style.butwidth,style.butheight];
lukeobj.loadshot.position = [style.shotnumtitlewidth + style.shotnumwidth + style.butwidth + 4*style.buthsep,2*style.butheight + 3*style.butvsep,style.butwidth,style.butheight];
lukeobj.saveshot.position = [style.shotnumtitlewidth + style.shotnumwidth + style.butwidth + 4*style.buthsep,style.butheight + 2*style.butvsep,style.butwidth,style.butheight];
%
style.simulfilewidth = style.panelwidth - style.shotnumtitlewidth - style.shotnumwidth - 8*style.buthsep - 2*style.butwidth;
%
lukeobj.lukeroottitle.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.simulfiletitlewidth,style.textheight];
%lukeobj.workdirtitlestr.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep,style.butheight + 2*style.butvsep + style.textheightcorr,style.simulfiletitlewidth,style.textheight];
lukeobj.workdirtitle.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep - style.workdirtitlecorr,style.butheight + 2*style.butvsep,style.simulfiletitlewidth + style.workdirtitlecorr,style.butheight];
lukeobj.simulfiletitle.position = [style.shotnumtitlewidth + style.shotnumwidth + 3*style.buthsep,style.butvsep + style.textheightcorr,2*style.buthsep + 2*style.butwidth,style.textheight];
%
lukeobj.lukeroot.position = [style.panelwidth - style.simulfilewidth + style.simulfiletitlewidth - style.buthsep,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.simulfilewidth - style.simulfiletitlewidth,style.textheight];
lukeobj.workdir.position = [style.panelwidth - style.simulfilewidth + style.simulfiletitlewidth - style.buthsep,style.butheight + 2*style.butvsep + style.textheightcorr,style.simulfilewidth - style.simulfiletitlewidth,style.textheight];
lukeobj.simulfile.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep,style.butvsep + style.textheightcorr,style.simulfilewidth + style.buthsep,style.textheight];
%
lukeobj.titlestr.position = [(style.panelwidth - style.titlestrwidth)/2,3*style.butheight + 4*style.butvsep,style.titlestrwidth,style.titlestrheight];
lukeobj.documentation.position = [style.panelwidth - 2*style.buthsep - 2*style.butwidth,style.titleheight - style.butheight - style.butvsep,style.buthsep + 2*style.butwidth,style.butheight];
%
% LUKE RUN PANEL DIMENSIONS
%
lukeobj.runluke.position = [style.buthsep,style.infoheightcorr - 6*style.butheightcorr,2*style.titlewidth,2*style.butheight];
lukeobj.lukeidtitle.position = [2*style.titlewidth + 2*style.buthsep,style.infoheightcorr - 6*style.butheightcorr + style.butvsep + style.textheightcorr,style.titlewidth,style.butheight];
lukeobj.lukeid.position = [3*style.titlewidth + 3*style.buthsep,style.infoheightcorr - 6*style.butheightcorr + style.butvsep,style.panelwidth - 3*style.titlewidth - 4*style.buthsep,style.butheight];
lukeobj.runcheck.position = [style.buthsep,style.infoheightcorr - 8*style.butheightcorr,2*style.titlewidth,2*style.butheight];

%
% title column
%

lukeobj.graph1sel.string = {''};
lukeobj.graph2sel.string = {''};
lukeobj.graph3sel.string = {''};

lukeobj.graph1save.string = 'Save';
lukeobj.graph2save.string = 'Save';
lukeobj.graph3save.string = 'Save';

lukeobj.graph1print.string = 'Print';
lukeobj.graph2print.string = 'Print';
lukeobj.graph3print.string = 'Print';

lukeobj.lukevertitle.string = 'LUKE VERSION  : ';
lukeobj.tokamaktitle.string = 'TOKAMAK       : ';
lukeobj.shotnumtitle.string = 'SHOT NUMBER   : ';
lukeobj.shotimetitle.string = 'SHOT TIME (s) : ';

lukeobj.lukever.string = LUKEversion_jd;
lukeobj.tokamak.string = '< empty >';
lukeobj.shotnum.string = '< empty >';
lukeobj.shotime.string = '< empty >';

lukeobj.lukeroottitle.string =   'LUKE SOURCE : ';
%lukeobj.workdirtitlestr.string = '            : ';
lukeobj.workdirtitle.string =    'WORK DIRECT.: ';

lukeobj.simulfiletitle.string = 'SIMULATION FILE : ';

lukeobj.lukeroot.string = dkepath.luke_root;
lukeobj.simulfile.string = '< not saved >';

lukeobj.titlestr.string = {'SUMMARY'};
lukeobj.documentation.string = 'LUKE DOC & HELP';

lukeobj.exitluke.string = 'Exit';
lukeobj.newshot.string = 'New';
lukeobj.loadshot.string = 'Load';
lukeobj.saveshot.string = 'Save';

lukeobj.controlstr.string = {'CONTROLS'};

lukeobj.runluke.string = 'LUKE START';
lukeobj.lukeidtitle.string = 'Run ID';
lukeobj.runcheck.string = 'CHECK RUN';

lukeobj.runc3po.string = 'C3PO START CURRENT';
lukeobj.runc3poall.string = 'C3PO START ALL';
lukeobj.wsparamtitle.string = 'Distributed computing mode for C3PO';
lukeobj.wsparam.string = '0';

lukeobj.graph1save.state = 'on';
lukeobj.graph2save.state = 'on';
lukeobj.graph3save.state = 'on';

lukeobj.graph1print.state = 'on';
lukeobj.graph2print.state = 'on';
lukeobj.graph3print.state = 'on';

lukeobj.exitluke.state = 'on';
lukeobj.newshot.state = 'on';
lukeobj.loadshot.state = 'on';
lukeobj.saveshot.state = 'on';

lukeobj.exitluke.callback = 'close(lukeobj.mainfig.handle)';
lukeobj.newshot.callback = 'status.external = 0;status.equil = 0;iluke_update;';
lukeobj.loadshot.callback = 'action = ''loadshot'';iluke_callbacks;';
lukeobj.saveshot.callback = 'action = ''saveshot'';iluke_callbacks;';
lukeobj.workdirtitle.callback = 'action = ''workdir'';iluke_callbacks;';
lukeobj.documentation.callback = 'action = ''documentation'';iluke_callbacks;';

lukeobj.graph1sel.callback = 'lukeobj.plot1.gindex = get(lukeobj.graph1sel.handle,''Value'') - 1;iluke_update;';
lukeobj.graph2sel.callback = 'lukeobj.plot2.gindex = get(lukeobj.graph2sel.handle,''Value'') - 1;iluke_update;';
lukeobj.graph3sel.callback = 'lukeobj.plot3.gindex = get(lukeobj.graph3sel.handle,''Value'') - 1;iluke_update;';

lukeobj.graph1save.callback = 'iluke_print(2,[''Fig_'',lukeobj.tokamak.string,''_'',lukeobj.shotnum.string,''_'',lukeobj.shotime.string,'' '',lukeobj.graph1sel.string{lukeobj.graph1sel.value}],''figures/'',graphs(lukeobj.plot1.gindex).handles);';
lukeobj.graph2save.callback = 'iluke_print(2,[''Fig_'',lukeobj.tokamak.string,''_'',lukeobj.shotnum.string,''_'',lukeobj.shotime.string,'' '',lukeobj.graph2sel.string{lukeobj.graph2sel.value}],''figures/'',graphs(lukeobj.plot2.gindex).handles);';
lukeobj.graph3save.callback = 'iluke_print(2,[''Fig_'',lukeobj.tokamak.string,''_'',lukeobj.shotnum.string,''_'',lukeobj.shotime.string,'' '',lukeobj.graph3sel.string{lukeobj.graph3sel.value}],''figures/'',graphs(lukeobj.plot3.gindex).handles);';

lukeobj.graph1print.callback = 'iluke_print(0,'','',graphs(lukeobj.plot1.gindex).handles);';
lukeobj.graph2print.callback = 'iluke_print(0,'','',graphs(lukeobj.plot2.gindex).handles);';
lukeobj.graph3print.callback = 'iluke_print(0,'','',graphs(lukeobj.plot3.gindex).handles);';

lukeobj.runluke.callback = 'action = ''lukestart'';iluke_callbacks;';
lukeobj.lukeid.callback = 'lukeobj.lukeid.string = get(lukeobj.lukeid.handle,''String'');iluke_update;';
lukeobj.runcheck.callback = 'action = ''runcheck'';iluke_callbacks;';

lukeobj.runc3po.callback = 'iw = lukeobj.wavestruct.select.value;action = ''c3postart'';iluke_callbacks;clear iw;';
lukeobj.runc3poall.callback = 'iw = 1:length(wavestructs);action = ''c3postart'';iluke_callbacks;clear iw;';
lukeobj.wsparam.callback = 'lukeobj.wsparam.string = get(lukeobj.wsparam.handle,''String'');iluke_update;';

%
% CREATE GUI
%

lukeobj.mainfig.handle = figure('name','iLUKE','visible','on','menubar','none','numbertitle','off','resize','off','position',lukeobj.mainfig.position,'toolbar','none','units','pixels');

%  Initialization tasks

lukeobj.titlepanel.handle = uipanel('Parent',lukeobj.mainfig.handle,'Title','','units','pixels','Position',lukeobj.titlepanel.position);
lukeobj.controlpanel.handle = uipanel('Parent',lukeobj.mainfig.handle,'Title','','units','pixels','Position',lukeobj.controlpanel.position);
lukeobj.infopanel.handle = uipanel('Parent',lukeobj.mainfig.handle,'Title','','units','pixels','Position',lukeobj.infopanel.position);

lukeobj.plot1.handle = uipanel('Parent',lukeobj.mainfig.handle,'Title','','units','pixels','Position',lukeobj.plot1.position);
lukeobj.plot2.handle = uipanel('Parent',lukeobj.mainfig.handle,'Title','','units','pixels','Position',lukeobj.plot2.position);
lukeobj.plot3.handle = uipanel('Parent',lukeobj.mainfig.handle,'Title','','units','pixels','Position',lukeobj.plot3.position);

lukeobj.graph1sel.handle = uicontrol(lukeobj.plot1.handle,'Style','popupmenu','String',lukeobj.graph1sel.string,'Position',lukeobj.graph1sel.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph1sel.callback);
lukeobj.graph2sel.handle = uicontrol(lukeobj.plot2.handle,'Style','popupmenu','String',lukeobj.graph2sel.string,'Position',lukeobj.graph2sel.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph2sel.callback);
lukeobj.graph3sel.handle = uicontrol(lukeobj.plot3.handle,'Style','popupmenu','String',lukeobj.graph3sel.string,'Position',lukeobj.graph3sel.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph3sel.callback);

lukeobj.graph1save.handle = uicontrol(lukeobj.plot1.handle,'Style','pushbutton','String',lukeobj.graph1save.string,'Position',lukeobj.graph1save.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph1save.callback);
lukeobj.graph2save.handle = uicontrol(lukeobj.plot2.handle,'Style','pushbutton','String',lukeobj.graph2save.string,'Position',lukeobj.graph2save.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph2save.callback);
lukeobj.graph3save.handle = uicontrol(lukeobj.plot3.handle,'Style','pushbutton','String',lukeobj.graph3save.string,'Position',lukeobj.graph3save.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph3save.callback);

lukeobj.graph1print.handle = uicontrol(lukeobj.plot1.handle,'Style','pushbutton','String',lukeobj.graph1print.string,'Position',lukeobj.graph1print.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph1print.callback);
lukeobj.graph2print.handle = uicontrol(lukeobj.plot2.handle,'Style','pushbutton','String',lukeobj.graph2print.string,'Position',lukeobj.graph2print.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph2print.callback);
lukeobj.graph3print.handle = uicontrol(lukeobj.plot3.handle,'Style','pushbutton','String',lukeobj.graph3print.string,'Position',lukeobj.graph3print.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.graph3print.callback);

lukeobj.tokamaktitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.tokamaktitle.string,'Position',lukeobj.tokamaktitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotnumtitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotnumtitle.string,'Position',lukeobj.shotnumtitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotimetitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotimetitle.string,'Position',lukeobj.shotimetitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.tokamak.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.tokamak.string,'Position',lukeobj.tokamak.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotnum.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotnum.string,'Position',lukeobj.shotnum.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotime.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotime.string,'Position',lukeobj.shotime.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.lukeroot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukeroot.string,'Position',lukeobj.lukeroot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.lukever.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukever.string,'Position',lukeobj.lukever.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.workdir.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','Position',lukeobj.workdir.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.simulfile.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.simulfile.string,'Position',lukeobj.simulfile.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.lukeroottitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukeroottitle.string,'Position',lukeobj.lukeroottitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
%lukeobj.workdirtitlestr.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.workdirtitlestr.string,'Position',lukeobj.workdirtitlestr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.lukevertitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukevertitle.string,'Position',lukeobj.lukevertitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.simulfiletitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.simulfiletitle.string,'Position',lukeobj.simulfiletitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.titlestr.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.titlestr.string,'Position',lukeobj.titlestr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'HorizontalAlignment','center');
lukeobj.documentation.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.documentation.string,'Position',lukeobj.documentation.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.documentation.callback);

lukeobj.exitluke.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.exitluke.string,'Position',lukeobj.exitluke.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.exitluke.callback);
lukeobj.newshot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.newshot.string,'Position',lukeobj.newshot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.newshot.callback);
lukeobj.loadshot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.loadshot.string,'Position',lukeobj.loadshot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.loadshot.callback);
lukeobj.saveshot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.saveshot.string,'Position',lukeobj.saveshot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.saveshot.callback);
lukeobj.workdirtitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.workdirtitle.string,'Position',lukeobj.workdirtitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left','Callback',lukeobj.workdirtitle.callback);

%
lukeobj.controlstr.handle = uicontrol(lukeobj.controlpanel.handle,'Style','text','String',lukeobj.controlstr.string,'Position',lukeobj.controlstr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'HorizontalAlignment','center');

lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'data',{'title','import','load','save','clear','disp','text'},'Exp. Data',style.controlheightcorr - style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'equil',{'title','make','load','save','clear','disp','text'},'Equilibrium',style.controlheightcorr - 2*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'ohm',{'title','make','load','save','clear','disp','text'},'Ohmic Field',style.controlheightcorr - 3*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'transp',{'title','make','load','save','clear','disp','text'},'Transport',style.controlheightcorr - 4*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'ripple',{'title','make','load','save','clear','disp','text'},'Mag. Ripple',style.controlheightcorr - 5*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'wave',{'title','make','load','save','clear','disp','text'},'RF Waves',style.controlheightcorr - 6*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'luke',{'title','','','run','clear','disp','text'},'Fokker-Planck Equation',style.controlheightcorr - 7*style.butheightcorr - style.butvsep,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'r5x2',{'title','','','run','clear','disp','text'},'Fast Electron Bremsstrahlung',style.controlheightcorr - 8*style.butheightcorr - 2*style.butvsep,style);

lukeobj.infotext.handle = uicontrol(lukeobj.infopanel.handle,'Style','text','Position',lukeobj.infotext.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.infostr.handle = uicontrol(lukeobj.infopanel.handle,'Style','text','Position',lukeobj.infostr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'HorizontalAlignment','center');

%
% RUN LUKE PANEL
%
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'param',{'title','modify','load','save','clear','','text'},'Parameters',style.infoheightcorr - style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'display',{'title','modify','load','save','clear','','text'},'Display',style.infoheightcorr - 2*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'remote',{'title','make','load','save','test','',''},'Server',style.infoheightcorr - 3*style.butheightcorr,style);

lukeobj.remote.select.position = [style.titlewidth + 6*style.buthsep + 4*style.butwidth,style.infoheightcorr - 3*style.butheightcorr,style.panelwidth - style.titlewidth - 7*style.buthsep - 4*style.butwidth,style.butheight];
lukeobj.remote.timeout.position = [style.buthsep,style.infoheightcorr - 4*style.butheightcorr,style.panelwidth - 2*style.buthsep,style.butheight];

lukeobj.remote.select.callback = 'lukeobj.remote.select.value = get(lukeobj.remote.select.handle,''Value'');iluke_update;';
lukeobj.remote.timeout.callback = 'lukeobj.remote.timeout.value = get(lukeobj.remote.timeout.handle,''Value'');iluke_update;';

lukeobj.remote.select.handle = uicontrol(lukeobj.infopanel.handle,'Style','popupmenu','Position',lukeobj.remote.select.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.remote.select.callback);
lukeobj.remote.timeout.handle = uicontrol(lukeobj.infopanel.handle,'Style','checkbox','Position',lukeobj.remote.timeout.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.remote.timeout.callback);
lukeobj.runluke.handle = uicontrol(lukeobj.infopanel.handle,'Style','pushbutton','String',lukeobj.runluke.string,'Position',lukeobj.runluke.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'Callback',lukeobj.runluke.callback);
lukeobj.lukeidtitle.handle = uicontrol(lukeobj.infopanel.handle,'Style','text','String',lukeobj.lukeidtitle.string,'Position',lukeobj.lukeidtitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.lukeid.handle = uicontrol(lukeobj.infopanel.handle,'Style','edit','Position',lukeobj.lukeid.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.lukeid.callback);
lukeobj.runcheck.handle = uicontrol(lukeobj.infopanel.handle,'Style','pushbutton','String',lukeobj.runcheck.string,'Position',lukeobj.runcheck.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'Callback',lukeobj.runcheck.callback);

lukeobj.param.text.string = dkeparam.id;
lukeobj.display.text.string = dkedisplay.id;
lukeobj.remote.timeout.string = ' Check box to return hand to iluke after submitting job';

lukeobj.remote.select.value = 1;
lukeobj.remote.timeout.value = 0;

%
% RUN C3PO PANEL
%
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'wavestruct',{'title','import','make','load','save','clear',''},'Structures',style.infoheightcorr - style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'angles',{'title','modify','load','save','reset','','text'},'EC Angles',style.infoheightcorr - 2*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'spectrum',{'title','modify','load','save','reset','','text'},'LH Spectrum',style.infoheightcorr - 3*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'launch',{'title','modify','load','save','reset','','text'},'Launch',style.infoheightcorr - 4*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.infopanel.handle,lukeobj,'c3poparam',{'title','modify','load','save','reset','','text'},'Parameters',style.infoheightcorr - 5*style.butheightcorr,style);

set(lukeobj.angles.text.handle,'HorizontalAlignment','left');
set(lukeobj.spectrum.text.handle,'HorizontalAlignment','left');
set(lukeobj.launch.text.handle,'HorizontalAlignment','left');
set(lukeobj.c3poparam.text.handle,'HorizontalAlignment','left');

lukeobj.wavestruct.select.position = [style.titlewidth + 7*style.buthsep + 5*style.butwidth,style.infoheightcorr - style.butheightcorr,style.panelwidth - style.titlewidth - 8*style.buthsep - 5*style.butwidth,style.butheight];
lukeobj.runc3po.position = [style.buthsep,style.infoheightcorr - 8*style.butheightcorr,style.panelwidth/2 - 2*style.buthsep,2*style.butheight];
lukeobj.runc3poall.position = [style.panelwidth/2 + style.buthsep,style.infoheightcorr - 8*style.butheightcorr,style.panelwidth/2 - 2*style.buthsep,2*style.butheight];
lukeobj.wsparamtitle.position = [style.buthsep,style.infoheightcorr - 6*style.butheightcorr + style.textheightcorr,style.titlewidth + 4*(style.butwidth + style.buthsep),style.butheight];
lukeobj.wsparam.position = [style.titlewidth + 4*style.butwidth + 6*style.buthsep,style.infoheightcorr - 6*style.butheightcorr,style.butwidth,style.butheight];

lukeobj.wavestruct.select.callback = 'lukeobj.wavestruct.select.value = get(lukeobj.wavestruct.select.handle,''Value'');iluke_update;';

lukeobj.wavestruct.select.handle = uicontrol(lukeobj.infopanel.handle,'Style','popupmenu','Position',lukeobj.wavestruct.select.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.wavestruct.select.callback);
lukeobj.runc3po.handle = uicontrol(lukeobj.infopanel.handle,'Style','pushbutton','String',lukeobj.runc3po.string,'Position',lukeobj.runc3po.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'Callback',lukeobj.runc3po.callback);
lukeobj.runc3poall.handle = uicontrol(lukeobj.infopanel.handle,'Style','pushbutton','String',lukeobj.runc3poall.string,'Position',lukeobj.runc3poall.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'Callback',lukeobj.runc3poall.callback);
lukeobj.wsparamtitle.handle = uicontrol(lukeobj.infopanel.handle,'Style','text','String',lukeobj.wsparamtitle.string,'Position',lukeobj.wsparamtitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.wsparam.handle = uicontrol(lukeobj.infopanel.handle,'Style','edit','String',lukeobj.wsparam.string,'Position',lukeobj.wsparam.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Callback',lukeobj.wsparam.callback);

lukeobj = iluke_info(lukeobj,'startup');% info display

graphs = struct;
graphs.handles = [];
graphs.info = '';
graphs.tag = '';
graphs(1) = [];% empty structure but keep memory of fields

lukeobj.plot1.gindex = 0;
lukeobj.plot2.gindex = 0;
lukeobj.plot3.gindex = 0;

cleartags = {};

status.external = 0;

external = '';
equil = '';
ohm = '';
transpfaste = '';
ripple = '';
waves = '';

wavestructs = {};

job = '';
output = '';
hxr = '';

iluke_update;
