%
% GUI FOR LUKE/C3PO/R5X2
%
clear all
close all
%
dkepath = load_structures_yp('dkepath','','');
workdir = pwd;
%
lukeobj = struct;
infostrs = iluke_info;
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
style.simulfiletitlewidth = 120;
style.shotnumtitlewidth = 120; 
style.shotnumwidth = 80; 
style.titlestrheight = 50;
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
lukeobj.infotext.position = [style.panelsep + style.buthsep,style.panelsep + style.butvsep,style.panelwidth - 2*style.buthsep,style.infopanelheight - 3*style.butvsep - style.titlestrheight];
lukeobj.infostr.position = [style.buthsep,style.infopanelheight - style.titlestrheight - style.butvsep,style.panelwidth - 2*style.buthsep,style.titlestrheight];
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
style.controlstrcorr = style.titlestrheight + style.butvsep;
style.butheightcorr = style.butheight + style.butvsep;
%
style.textheight = 2*style.fontsize;
%
lukeobj.controlstr.position = [style.buthsep,style.controlheight - style.controlstrcorr,style.panelwidth - 2*style.buthsep,style.titlestrheight];
%
% SIMULATION INFO DIMENSIONS
%
lukeobj.tokamaktitle.position = [style.buthsep,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.shotnumtitlewidth,style.textheight];
lukeobj.shotnumtitle.position = [style.buthsep,style.butheight + 2*style.butvsep + style.textheightcorr,style.shotnumtitlewidth,style.textheight];
lukeobj.shotimetitle.position = [style.buthsep,style.butvsep + style.textheightcorr,style.shotnumtitlewidth,style.textheight];
%
lukeobj.tokamak.position = [2*style.buthsep+style.shotnumtitlewidth,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.shotnumwidth,style.textheight];
lukeobj.shotnum.position = [2*style.buthsep+style.shotnumtitlewidth,style.butheight + 2*style.butvsep + style.textheightcorr,style.shotnumwidth,style.textheight];
lukeobj.shotime.position = [2*style.buthsep+style.shotnumtitlewidth,style.butvsep + style.textheightcorr,style.shotnumwidth,style.textheight];
%
lukeobj.exitluke.position = [style.shotnumtitlewidth + style.shotnumwidth + 3*style.buthsep,2*style.butheight + 3*style.butvsep,style.butwidth,style.butheight];
lukeobj.newshot.position = [style.shotnumtitlewidth + style.shotnumwidth + 3*style.buthsep,style.butheight + 2*style.butvsep,style.butwidth,style.butheight];
lukeobj.loadshot.position = [style.shotnumtitlewidth + style.shotnumwidth + style.butwidth + 4*style.buthsep,2*style.butheight + 3*style.butvsep,style.butwidth,style.butheight];
lukeobj.saveshot.position = [style.shotnumtitlewidth + style.shotnumwidth + style.butwidth + 4*style.buthsep,style.butheight + 2*style.butvsep,style.butwidth,style.butheight];
%
style.simulfilewidth = style.panelwidth - style.shotnumtitlewidth - style.shotnumwidth - 8*style.buthsep - 2*style.butwidth;
%
lukeobj.lukeroottitle.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.simulfiletitlewidth,style.textheight];
lukeobj.lukevertitle.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep,style.butheight + 2*style.butvsep + style.textheightcorr,style.simulfiletitlewidth,style.textheight];
lukeobj.simulfiletitle.position = [style.shotnumtitlewidth + style.shotnumwidth + 3*style.buthsep,style.butvsep + style.textheightcorr,2*style.buthsep + 2*style.butwidth,style.textheight];
%
lukeobj.lukeroot.position = [style.panelwidth - style.simulfilewidth + style.simulfiletitlewidth - style.buthsep,2*style.butheight + 3*style.butvsep + style.textheightcorr,style.simulfilewidth - style.simulfiletitlewidth,style.textheight];
lukeobj.lukever.position = [style.panelwidth - style.simulfilewidth + style.simulfiletitlewidth - style.buthsep,style.butheight + 2*style.butvsep + style.textheightcorr,style.simulfilewidth - style.simulfiletitlewidth,style.textheight];
lukeobj.simulfile.position = [style.panelwidth - style.simulfilewidth - 2*style.buthsep,style.butvsep + style.textheightcorr,style.simulfilewidth + style.buthsep,style.textheight];
%
lukeobj.titlestr.position = [style.buthsep,3*style.butheight + 4*style.butvsep,style.panelwidth - 2*style.buthsep,style.titlestrheight];
%
% title column
%
style.controlheightcorr = style.controlheight - style.controlstrcorr;

lukeobj.graph1sel.string = {''};
lukeobj.graph2sel.string = {''};
lukeobj.graph3sel.string = {''};

lukeobj.graph1save.string = 'Save';
lukeobj.graph2save.string = 'Save';
lukeobj.graph3save.string = 'Save';

lukeobj.graph1print.string = 'Print';
lukeobj.graph2print.string = 'Print';
lukeobj.graph3print.string = 'Print';

lukeobj.tokamaktitle.string = 'TOKAMAK       : ';
lukeobj.shotnumtitle.string = 'SHOT NUMBER   : ';
lukeobj.shotimetitle.string = 'SHOT TIME (s) : ';

lukeobj.tokamak.string = '< empty >';
lukeobj.shotnum.string = '< empty >';
lukeobj.shotime.string = '< empty >';

lukeobj.lukeroottitle.string =  'LUKE SOURCE  : ';
lukeobj.lukevertitle.string =   'LUKE VERSION : ';
lukeobj.simulfiletitle.string = 'SIMULATION FILE : ';

lukeobj.lukeroot.string = dkepath.luke_root;
lukeobj.lukever.string = LUKEversion_jd;
lukeobj.simulfile.string = '< not saved >';

lukeobj.titlestr.string = {'SUMMARY'};

lukeobj.exitluke.string = 'Exit';
lukeobj.newshot.string = 'New';
lukeobj.loadshot.string = 'Load';
lukeobj.saveshot.string = 'Save';

lukeobj.controlstr.string = {'CONTROLS'};
lukeobj.infostr.string = {'INFOS'};

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

lukeobj.graph1sel.callback = 'lukeobj.plot1.gindex = get(lukeobj.graph1sel.handle,''Value'') - 1;iluke_update;';
lukeobj.graph2sel.callback = 'lukeobj.plot2.gindex = get(lukeobj.graph2sel.handle,''Value'') - 1;iluke_update;';
lukeobj.graph3sel.callback = 'lukeobj.plot3.gindex = get(lukeobj.graph3sel.handle,''Value'') - 1;iluke_update;';

lukeobj.infotext.string = infostrs.startup;

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

lukeobj.graph1save.handle = uicontrol(lukeobj.plot1.handle,'Style','pushbutton','String',lukeobj.graph1save.string,'Position',lukeobj.graph1save.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.graph1save.state);
lukeobj.graph2save.handle = uicontrol(lukeobj.plot2.handle,'Style','pushbutton','String',lukeobj.graph2save.string,'Position',lukeobj.graph2save.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.graph2save.state);
lukeobj.graph3save.handle = uicontrol(lukeobj.plot3.handle,'Style','pushbutton','String',lukeobj.graph3save.string,'Position',lukeobj.graph3save.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.graph3save.state);

lukeobj.graph1print.handle = uicontrol(lukeobj.plot1.handle,'Style','pushbutton','String',lukeobj.graph1print.string,'Position',lukeobj.graph1print.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.graph1print.state);
lukeobj.graph2print.handle = uicontrol(lukeobj.plot2.handle,'Style','pushbutton','String',lukeobj.graph2print.string,'Position',lukeobj.graph2print.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.graph2print.state);
lukeobj.graph3print.handle = uicontrol(lukeobj.plot3.handle,'Style','pushbutton','String',lukeobj.graph3print.string,'Position',lukeobj.graph3print.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.graph3print.state);

lukeobj.tokamaktitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.tokamaktitle.string,'Position',lukeobj.tokamaktitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotnumtitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotnumtitle.string,'Position',lukeobj.shotnumtitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotimetitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotimetitle.string,'Position',lukeobj.shotimetitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.tokamak.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.tokamak.string,'Position',lukeobj.tokamak.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotnum.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotnum.string,'Position',lukeobj.shotnum.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.shotime.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.shotime.string,'Position',lukeobj.shotime.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.lukeroot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukeroot.string,'Position',lukeobj.lukeroot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.lukever.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukever.string,'Position',lukeobj.lukever.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.simulfile.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.simulfile.string,'Position',lukeobj.simulfile.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.lukeroottitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukeroottitle.string,'Position',lukeobj.lukeroottitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.lukevertitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.lukevertitle.string,'Position',lukeobj.lukevertitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.simulfiletitle.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.simulfiletitle.string,'Position',lukeobj.simulfiletitle.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');

lukeobj.titlestr.handle = uicontrol(lukeobj.titlepanel.handle,'Style','text','String',lukeobj.titlestr.string,'Position',lukeobj.titlestr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'HorizontalAlignment','center');

lukeobj.exitluke.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.exitluke.string,'Position',lukeobj.exitluke.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.exitluke.state,'Callback',lukeobj.exitluke.callback);
lukeobj.newshot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.newshot.string,'Position',lukeobj.newshot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.newshot.state);
lukeobj.loadshot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.loadshot.string,'Position',lukeobj.loadshot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.loadshot.state);
lukeobj.saveshot.handle = uicontrol(lukeobj.titlepanel.handle,'Style','pushbutton','String',lukeobj.saveshot.string,'Position',lukeobj.saveshot.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'Enable',lukeobj.saveshot.state);

%
lukeobj.controlstr.handle = uicontrol(lukeobj.controlpanel.handle,'Style','text','String',lukeobj.controlstr.string,'Position',lukeobj.controlstr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'HorizontalAlignment','center');

lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'data',[1,2,4,5,7:9],'Exp. Data',style.controlheightcorr - style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'equil',[1,3:5,7:9],'Equilibrium',style.controlheightcorr - 2*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'ohm',[1,3:5,7:9],'Ohmic Field',style.controlheightcorr - 3*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'transp',[1,3:5,7:9],'Transport',style.controlheightcorr - 4*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'ripple',[1,3:5,7:9],'Mag. Ripple',style.controlheightcorr - 5*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'wave',[1,3:5,7:9],'RF Waves',style.controlheightcorr - 6*style.butheightcorr,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'luke',[1,6:9],'Fokker-Planck Equation',style.controlheightcorr - 7*style.butheightcorr - style.butvsep,style);
lukeobj = iluke_controls(lukeobj.controlpanel.handle,lukeobj,'r5x2',[1,6:9],'Fast Electron Bremsstrahlung',style.controlheightcorr - 8*style.butheightcorr - 2*style.butvsep,style);

lukeobj.infotext.handle = uicontrol(lukeobj.infopanel.handle,'Style','text','String',lukeobj.infotext.string,'Position',lukeobj.infotext.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize,'HorizontalAlignment','left');
lukeobj.infostr.handle = uicontrol(lukeobj.infopanel.handle,'Style','text','String',lukeobj.infostr.string,'Position',lukeobj.infostr.position,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.titlefontsize,'HorizontalAlignment','center');

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

output = '';
hxr = '';

iluke_update;
