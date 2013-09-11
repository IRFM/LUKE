%
% GUI FOR LUKE/C3PO/R5X2
%
clear all
close all
%
dkepath = load_structures_yp('dkepath','','');
workdir = pwd;
%
% -------------------------------------------------------------------------
%
% ILUKE DIMENSIONS and INITIALIZATION
%
panelsep = 5;
%
figbaseheight = 900;
figbasewidth = 1200;
%
plotwidth = 340;
plotheight = 300;
%
graphwidth = 272;
graphheight = 204;
%
simulfiletitlewidth = 120;
shotnumtitlewidth = 120; 
shotnumwidth = 80; 
titlestrheight = 50;
%
titlewidth = 105;
butheight = 25;%40;% height of button
butwidth = 60;%80;% width of button
buthsep = 10;% horizontal separation between buttons
butvsep = 10;% vertical separation between buttons
%
fontname = 'Liberation Mono';%get(0,'FixedWidthFontName');%'fixedwidth';% font type
fontsize = 14;% font size
titlefontsize = 2*fontsize;
%
infotext.string = {'',...
    '            To get started :',...
    '            ==============','',...
    '    - "Load" Existing simulation','',...
    '    - "Import" Exp. data to import from database',...
    '    - "Load" Exp. data to load from existing EXTERNAL file',...
    '    - "New" Equilibrium to create equilibrium or import EQDSK file',...
    '    - "Load" Equilibrium  to load from existing EQUIL file'};
%
% -------------------------------------------------------------------------
%
% FIGURE DIMENSIONS
%
figwidth = figbasewidth + 3*panelsep;
figheight = figbaseheight + 4*panelsep;
%
screensize = get(0,'MonitorPositions');
%
figleft = fix((screensize(3) - figwidth)/2);
figbottom = fix((screensize(4) - figheight)/2);
%
if figleft < 0 || figbottom < 0,
    error(['The screen resolution must be at least ',num2str(figwidth),' x ',num2str(figheight)])
end
%
mainfig.position = [figleft,figbottom,figwidth,figheight];
%
% PANELS DIMENSIONS
%
panelwidth = figbasewidth - plotwidth;
%
titleheight = 3*butheight + 5*butvsep + titlestrheight;
%
controlpaneltop = figbaseheight - titleheight + 2*panelsep;% top position of button group
controlheight = 8*butheight + 12*butvsep + titlestrheight;
controlpanelbottom = controlpaneltop - controlheight;% top position of button group
%
infopanelheight = controlpanelbottom - 2*panelsep;
%
titlepanel.position = [panelsep,figbaseheight - titleheight + 3*panelsep,panelwidth,titleheight];
controlpanel.position = [panelsep,controlpanelbottom,panelwidth,controlheight];
infopanel.position = [panelsep,panelsep,panelwidth,infopanelheight];
%
infotext.position = [panelsep + buthsep,panelsep + butvsep,panelwidth - 2*buthsep,infopanelheight - 3*butvsep - titlestrheight];
infostr.position = [buthsep,infopanelheight - titlestrheight - butvsep,panelwidth - 2*buthsep,titlestrheight];
%
plot1.position = [panelwidth + 2*panelsep,2*plotheight + 3*panelsep,plotwidth,plotheight];
plot2.position = [panelwidth + 2*panelsep,plotheight + 2*panelsep,plotwidth,plotheight];
plot3.position = [panelwidth + 2*panelsep,panelsep,plotwidth,plotheight];
%
% GRAPHS DIMENSIONS
%
graph_position = [plotwidth - buthsep - graphwidth,plotheight - 2*butvsep - fontsize - butheight - graphheight,graphwidth,graphheight];  
gsel_position = [buthsep,plotheight - butvsep - butheight,plotwidth - 4*buthsep - 2*butwidth,butheight];
gsave_position = [plotwidth - 2*buthsep - 2*butwidth,plotheight - butvsep - butheight,butwidth,butheight];
gprint_position = [plotwidth - buthsep - butwidth,plotheight - butvsep - butheight,butwidth,butheight];
%
% graph1.position = graph_position;
% graph2.position = graph_position;
% graph3.position = graph_position;
%
graph1sel.position = gsel_position;
graph2sel.position = gsel_position;
graph3sel.position = gsel_position;
%
graph1save.position = gsave_position;
graph2save.position = gsave_position;
graph3save.position = gsave_position;
%
graph1print.position = gprint_position;
graph2print.position = gprint_position;
graph3print.position = gprint_position;
%
% CONTROLS DIMENSIONS
%
textheightcorr = (butheight - 3*fontsize)/2;% correction to center text within button
controlstrcorr = titlestrheight + butvsep;
butheightcorr = butheight + butvsep;
butwidthcorr = butwidth + buthsep;
titlewidthcorr = buthsep + (titlewidth + buthsep);
%
textheight = 2*fontsize;
infowidth = panelwidth - titlewidthcorr - 5*butwidthcorr - buthsep;
%
controlstr.position = [buthsep,controlheight - controlstrcorr,panelwidth - 2*buthsep,titlestrheight];
%
% SIMULATION INFO DIMENSIONS
%
tokamaktitle.position = [buthsep,2*butheight + 3*butvsep + textheightcorr,shotnumtitlewidth,textheight];
shotnumtitle.position = [buthsep,butheight + 2*butvsep + textheightcorr,shotnumtitlewidth,textheight];
shotimetitle.position = [buthsep,butvsep + textheightcorr,shotnumtitlewidth,textheight];
%
tokamak.position = [2*buthsep+shotnumtitlewidth,2*butheight + 3*butvsep + textheightcorr,shotnumwidth,textheight];
shotnum.position = [2*buthsep+shotnumtitlewidth,butheight + 2*butvsep + textheightcorr,shotnumwidth,textheight];
shotime.position = [2*buthsep+shotnumtitlewidth,butvsep + textheightcorr,shotnumwidth,textheight];
%
exitluke.position = [shotnumtitlewidth + shotnumwidth + 3*buthsep,2*butheight + 3*butvsep,butwidth,butheight];
newshot.position = [shotnumtitlewidth + shotnumwidth + 3*buthsep,butheight + 2*butvsep,butwidth,butheight];
loadshot.position = [shotnumtitlewidth + shotnumwidth + butwidth + 4*buthsep,2*butheight + 3*butvsep,butwidth,butheight];
saveshot.position = [shotnumtitlewidth + shotnumwidth + butwidth + 4*buthsep,butheight + 2*butvsep,butwidth,butheight];
%
simulfilewidth = panelwidth - shotnumtitlewidth - shotnumwidth - 8*buthsep - 2*butwidth;
%
lukeroottitle.position = [panelwidth - simulfilewidth - 2*buthsep,2*butheight + 3*butvsep + textheightcorr,simulfiletitlewidth,textheight];
lukevertitle.position = [panelwidth - simulfilewidth - 2*buthsep,butheight + 2*butvsep + textheightcorr,simulfiletitlewidth,textheight];
simulfiletitle.position = [shotnumtitlewidth + shotnumwidth + 3*buthsep,butvsep + textheightcorr,2*buthsep + 2*butwidth,textheight];
%
lukeroot.position = [panelwidth - simulfilewidth + simulfiletitlewidth - buthsep,2*butheight + 3*butvsep + textheightcorr,simulfilewidth - simulfiletitlewidth,textheight];
lukever.position = [panelwidth - simulfilewidth + simulfiletitlewidth - buthsep,butheight + 2*butvsep + textheightcorr,simulfilewidth - simulfiletitlewidth,textheight];
simulfile.position = [panelwidth - simulfilewidth - 2*buthsep,butvsep + textheightcorr,simulfilewidth + buthsep,textheight];
%
titlestr.position = [buthsep,3*butheight + 4*butvsep,panelwidth - 2*buthsep,titlestrheight];
%
% title column
%
controlheightcorr = controlheight - controlstrcorr;
%
lukeobj.data.title.position = [buthsep,controlheightcorr - butheightcorr + textheightcorr,titlewidth,textheight];
lukeobj.equil.title.position = [buthsep,controlheightcorr - 2*butheightcorr + textheightcorr,titlewidth,textheight];
lukeobj.ohm.title.position = [buthsep,controlheightcorr - 3*butheightcorr + textheightcorr,titlewidth,textheight];
lukeobj.transp.title.position = [buthsep,controlheightcorr - 4*butheightcorr + textheightcorr,titlewidth,textheight];
lukeobj.ripple.title.position = [buthsep,controlheightcorr - 5*butheightcorr + textheightcorr,titlewidth,textheight];
lukeobj.wave.title.position = [buthsep,controlheightcorr - 6*butheightcorr + textheightcorr,titlewidth,textheight];
lukeobj.luke.title.position = [buthsep,controlheightcorr - 7*butheightcorr - butvsep + textheightcorr,titlewidthcorr + butwidthcorr + butwidth,textheight];
lukeobj.r5x2.title.position = [buthsep,controlheightcorr - 8*butheightcorr - 2*butvsep + textheightcorr,titlewidthcorr + butwidthcorr + butwidth,textheight];
%
% create column
%
lukeobj.data.import.position = [titlewidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
%
lukeobj.equil.make.position = [titlewidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
lukeobj.ohm.make.position = [titlewidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
lukeobj.transp.make.position = [titlewidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
lukeobj.ripple.make.position = [titlewidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
lukeobj.wave.make.position = [titlewidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
%
% load column
%
lukeobj.data.load.position = [titlewidthcorr + butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
lukeobj.equil.load.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
lukeobj.ohm.load.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
lukeobj.transp.load.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
lukeobj.ripple.load.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
lukeobj.wave.load.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
%
% save column
%
lukeobj.data.save.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
lukeobj.equil.save.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
lukeobj.ohm.save.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
lukeobj.transp.save.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
lukeobj.ripple.save.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
lukeobj.wave.save.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
%
lukeobj.luke.run.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep,butwidth,butheight];
lukeobj.r5x2.run.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep,butwidth,butheight];
%
% clear column
%
lukeobj.data.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
lukeobj.equil.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
lukeobj.ohm.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
lukeobj.transp.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
lukeobj.ripple.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
lukeobj.wave.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
lukeobj.luke.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep,butwidth,butheight];
lukeobj.r5x2.clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep,butwidth,butheight];
%
% disp column
%
lukeobj.data.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
lukeobj.equil.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
lukeobj.ohm.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
lukeobj.transp.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
lukeobj.ripple.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
lukeobj.wave.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
lukeobj.luke.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep,butwidth,butheight];
lukeobj.r5x2.disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep,butwidth,butheight];
%
% info column
%
lukeobj.data.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - butheightcorr + textheightcorr,infowidth,textheight];
lukeobj.equil.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 2*butheightcorr + textheightcorr,infowidth,textheight];
lukeobj.ohm.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 3*butheightcorr + textheightcorr,infowidth,textheight];
lukeobj.transp.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 4*butheightcorr + textheightcorr,infowidth,textheight];
lukeobj.ripple.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 5*butheightcorr + textheightcorr,infowidth,textheight];
lukeobj.wave.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 6*butheightcorr + textheightcorr,infowidth,textheight];
lukeobj.luke.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep + textheightcorr,infowidth,textheight];
lukeobj.r5x2.text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep + textheightcorr,infowidth,textheight];

graph1sel.string = {''};
graph2sel.string = {''};
graph3sel.string = {''};

graph1save.string = 'Save';
graph2save.string = 'Save';
graph3save.string = 'Save';

graph1print.string = 'Print';
graph2print.string = 'Print';
graph3print.string = 'Print';

tokamaktitle.string = 'TOKAMAK       : ';
shotnumtitle.string = 'SHOT NUMBER   : ';
shotimetitle.string = 'SHOT TIME (s) : ';

tokamak.string = '< empty >';
shotnum.string = '< empty >';
shotime.string = '< empty >';

lukeroottitle.string =  'LUKE SOURCE  : ';
lukevertitle.string =   'LUKE VERSION : ';
simulfiletitle.string = 'SIMULATION FILE : ';

lukeroot.string = dkepath.luke_root;
lukever.string = LUKEversion_jd;
simulfile.string = '< not saved >';

titlestr.string = {'SUMMARY'};

exitluke.string = 'Exit';
newshot.string = 'New';
loadshot.string = 'Load';
saveshot.string = 'Save';

controlstr.string = {'CONTROLS'};
infostr.string = {'INFOS'};

lukeobj.data.title.string = 'Exp. Data';
lukeobj.equil.title.string = 'Equilibrium';
lukeobj.ohm.title.string = 'Ohmic Field';
lukeobj.transp.title.string = 'Transport';
lukeobj.ripple.title.string = 'Mag. Ripple';
lukeobj.wave.title.string = 'RF Waves';
lukeobj.luke.title.string = 'Fokker-Planck Equation';
lukeobj.r5x2.title.string = 'Fast Electron Bremsstrahlung';

lukeobj.data.import.string = 'Import';%'Create';
%
lukeobj.equil.make.string = 'New';%'Create';
lukeobj.ohm.make.string = 'New';%'Create';
lukeobj.transp.make.string = 'New';%'Create';
lukeobj.ripple.make.string = 'New';%'Create';
lukeobj.wave.make.string = 'New';%'Create';

lukeobj.data.load.string = 'Load';
lukeobj.equil.load.string = 'Load';
lukeobj.ohm.load.string = 'Load';
lukeobj.transp.load.string = 'Load';
lukeobj.ripple.load.string = 'Load';
lukeobj.wave.load.string = 'Load';

lukeobj.data.save.string = 'Save';
lukeobj.equil.save.string = 'Save';
lukeobj.ohm.save.string = 'Save';
lukeobj.transp.save.string = 'Save';
lukeobj.ripple.save.string = 'Save';
lukeobj.wave.save.string = 'Save';

lukeobj.luke.run.string = 'Run';
lukeobj.r5x2.run.string = 'Run';

lukeobj.data.clear.string = 'Clear';
lukeobj.equil.clear.string = 'Clear';
lukeobj.ohm.clear.string = 'Clear';
lukeobj.transp.clear.string = 'Clear';
lukeobj.ripple.clear.string = 'Clear';
lukeobj.wave.clear.string = 'Clear';
lukeobj.luke.clear.string = 'Clear';
lukeobj.r5x2.clear.string = 'Clear';

lukeobj.data.disp.string = 'Disp';%'Display';
lukeobj.equil.disp.string = 'Disp';%'Display';
lukeobj.ohm.disp.string = 'Disp';%'Display';
lukeobj.transp.disp.string = 'Disp';%'Display';
lukeobj.ripple.disp.string = 'Disp';%'Display';
lukeobj.wave.disp.string = 'Disp';%'Display';
lukeobj.luke.disp.string = 'Disp';
lukeobj.r5x2.disp.string = 'Disp';

graph1save.state = 'on';
graph2save.state = 'on';
graph3save.state = 'on';

graph1print.state = 'on';
graph2print.state = 'on';
graph3print.state = 'on';

exitluke.state = 'on';
newshot.state = 'on';
loadshot.state = 'on';
saveshot.state = 'on';

%

exitluke.callback = 'close(mainfig.handle)';
%
lukeobj.data.import.callback = 'action = ''datamake'';iluke_callbacks;';
lukeobj.data.save.callback = 'action = ''datasave'';iluke_callbacks;';
lukeobj.data.load.callback = 'action = ''dataload'';iluke_callbacks;';
%
lukeobj.equil.make.callback = 'action = ''equilmake'';iluke_callbacks;';
lukeobj.equil.save.callback = 'action = ''equilsave'';iluke_callbacks;';
lukeobj.equil.load.callback = 'action = ''equilload'';iluke_callbacks;';
lukeobj.equil.disp.callback = 'action = ''equildisp'';iluke_callbacks;';
%
graph1sel.callback = 'plot1.gindex = get(graph1sel.handle,''Value'') - 1;iluke_update;';
graph2sel.callback = 'plot2.gindex = get(graph2sel.handle,''Value'') - 1;iluke_update;';
graph3sel.callback = 'plot3.gindex = get(graph3sel.handle,''Value'') - 1;iluke_update;';
%
%exitluke.data = struct;

%
% CREATE GUI
%

mainfig.handle = figure('name','iLUKE','visible','on','menubar','none','numbertitle','off','resize','off','position',mainfig.position,'toolbar','none','units','pixels');

%  Initialization tasks

titlepanel.handle = uipanel('Parent',mainfig.handle,'Title','','units','pixels','Position',titlepanel.position);
controlpanel.handle = uipanel('Parent',mainfig.handle,'Title','','units','pixels','Position',controlpanel.position);
infopanel.handle = uipanel('Parent',mainfig.handle,'Title','','units','pixels','Position',infopanel.position);
%
plot1.handle = uipanel('Parent',mainfig.handle,'Title','','units','pixels','Position',plot1.position);
plot2.handle = uipanel('Parent',mainfig.handle,'Title','','units','pixels','Position',plot2.position);
plot3.handle = uipanel('Parent',mainfig.handle,'Title','','units','pixels','Position',plot3.position);
%
% graph1.handle = axes('Parent',plot1.handle,'units','pixels','Position',graph1.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
% graph2.handle = axes('Parent',plot2.handle,'units','pixels','Position',graph2.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
% graph3.handle = axes('Parent',plot3.handle,'units','pixels','Position',graph3.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

graph1sel.handle = uicontrol(plot1.handle,'Style','popupmenu','String',graph1sel.string,'Position',graph1sel.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',graph1sel.callback);
graph2sel.handle = uicontrol(plot2.handle,'Style','popupmenu','String',graph2sel.string,'Position',graph2sel.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',graph2sel.callback);
graph3sel.handle = uicontrol(plot3.handle,'Style','popupmenu','String',graph3sel.string,'Position',graph3sel.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',graph3sel.callback);

graph1save.handle = uicontrol(plot1.handle,'Style','pushbutton','String',graph1save.string,'Position',graph1save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',graph1save.state);
graph2save.handle = uicontrol(plot2.handle,'Style','pushbutton','String',graph2save.string,'Position',graph2save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',graph2save.state);
graph3save.handle = uicontrol(plot3.handle,'Style','pushbutton','String',graph3save.string,'Position',graph3save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',graph3save.state);

graph1print.handle = uicontrol(plot1.handle,'Style','pushbutton','String',graph1print.string,'Position',graph1print.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',graph1print.state);
graph2print.handle = uicontrol(plot2.handle,'Style','pushbutton','String',graph2print.string,'Position',graph2print.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',graph2print.state);
graph3print.handle = uicontrol(plot3.handle,'Style','pushbutton','String',graph3print.string,'Position',graph3print.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',graph3print.state);

tokamaktitle.handle = uicontrol(titlepanel.handle,'Style','text','String',tokamaktitle.string,'Position',tokamaktitle.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
shotnumtitle.handle = uicontrol(titlepanel.handle,'Style','text','String',shotnumtitle.string,'Position',shotnumtitle.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
shotimetitle.handle = uicontrol(titlepanel.handle,'Style','text','String',shotimetitle.string,'Position',shotimetitle.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');

tokamak.handle = uicontrol(titlepanel.handle,'Style','text','String',tokamak.string,'Position',tokamak.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
shotnum.handle = uicontrol(titlepanel.handle,'Style','text','String',shotnum.string,'Position',shotnum.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
shotime.handle = uicontrol(titlepanel.handle,'Style','text','String',shotime.string,'Position',shotime.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');

lukeroot.handle = uicontrol(titlepanel.handle,'Style','text','String',lukeroot.string,'Position',lukeroot.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukever.handle = uicontrol(titlepanel.handle,'Style','text','String',lukever.string,'Position',lukever.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
simulfile.handle = uicontrol(titlepanel.handle,'Style','text','String',simulfile.string,'Position',simulfile.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');

lukeroottitle.handle = uicontrol(titlepanel.handle,'Style','text','String',lukeroottitle.string,'Position',lukeroottitle.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukevertitle.handle = uicontrol(titlepanel.handle,'Style','text','String',lukevertitle.string,'Position',lukevertitle.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
simulfiletitle.handle = uicontrol(titlepanel.handle,'Style','text','String',simulfiletitle.string,'Position',simulfiletitle.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');

titlestr.handle = uicontrol(titlepanel.handle,'Style','text','String',titlestr.string,'Position',titlestr.position,'FontName',fontname,'FontUnits','pixels','FontSize',titlefontsize,'HorizontalAlignment','center');

exitluke.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',exitluke.string,'Position',exitluke.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',exitluke.state,'Callback',exitluke.callback);
newshot.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',newshot.string,'Position',newshot.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',newshot.state);
loadshot.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',loadshot.string,'Position',loadshot.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',loadshot.state);
saveshot.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',saveshot.string,'Position',saveshot.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Enable',saveshot.state);

%
controlstr.handle = uicontrol(controlpanel.handle,'Style','text','String',controlstr.string,'Position',controlstr.position,'FontName',fontname,'FontUnits','pixels','FontSize',titlefontsize,'HorizontalAlignment','center');

lukeobj.data.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.data.title.string,'Position',lukeobj.data.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.equil.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.equil.title.string,'Position',lukeobj.equil.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.ohm.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.ohm.title.string,'Position',lukeobj.ohm.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.transp.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.transp.title.string,'Position',lukeobj.transp.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.ripple.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.ripple.title.string,'Position',lukeobj.ripple.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.wave.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.wave.title.string,'Position',lukeobj.wave.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.luke.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.luke.title.string,'Position',lukeobj.luke.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
lukeobj.r5x2.title.handle = uicontrol(controlpanel.handle,'Style','text','String',lukeobj.r5x2.title.string,'Position',lukeobj.r5x2.title.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');

lukeobj.data.import.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.data.import.string,'Position',lukeobj.data.import.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.data.import.callback);

lukeobj.equil.make.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.equil.make.string,'Position',lukeobj.equil.make.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.equil.make.callback);
lukeobj.ohm.make.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ohm.make.string,'Position',lukeobj.ohm.make.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.transp.make.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.transp.make.string,'Position',lukeobj.transp.make.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ripple.make.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ripple.make.string,'Position',lukeobj.ripple.make.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.wave.make.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.wave.make.string,'Position',lukeobj.wave.make.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

lukeobj.data.load.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.data.load.string,'Position',lukeobj.data.load.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.data.load.callback);
lukeobj.equil.load.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.equil.load.string,'Position',lukeobj.equil.load.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.equil.load.callback);
lukeobj.ohm.load.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ohm.load.string,'Position',lukeobj.ohm.load.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.transp.load.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.transp.load.string,'Position',lukeobj.transp.load.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ripple.load.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ripple.load.string,'Position',lukeobj.ripple.load.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.wave.load.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.wave.load.string,'Position',lukeobj.wave.load.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

lukeobj.data.save.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.data.save.string,'Position',lukeobj.data.save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.data.save.callback);
lukeobj.equil.save.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.equil.save.string,'Position',lukeobj.equil.save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.equil.save.callback);
lukeobj.ohm.save.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ohm.save.string,'Position',lukeobj.ohm.save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.transp.save.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.transp.save.string,'Position',lukeobj.transp.save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ripple.save.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ripple.save.string,'Position',lukeobj.ripple.save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.wave.save.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.wave.save.string,'Position',lukeobj.wave.save.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

lukeobj.luke.run.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.luke.run.string,'Position',lukeobj.luke.run.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.r5x2.run.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.r5x2.run.string,'Position',lukeobj.r5x2.run.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

lukeobj.data.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.data.clear.string,'Position',lukeobj.data.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.equil.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.equil.clear.string,'Position',lukeobj.equil.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ohm.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ohm.clear.string,'Position',lukeobj.ohm.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.transp.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.transp.clear.string,'Position',lukeobj.transp.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ripple.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ripple.clear.string,'Position',lukeobj.ripple.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.wave.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.wave.clear.string,'Position',lukeobj.wave.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.luke.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.luke.clear.string,'Position',lukeobj.luke.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.r5x2.clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.r5x2.clear.string,'Position',lukeobj.r5x2.clear.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

lukeobj.data.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.data.disp.string,'Position',lukeobj.data.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.equil.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.equil.disp.string,'Position',lukeobj.equil.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'Callback',lukeobj.equil.disp.callback);
lukeobj.ohm.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ohm.disp.string,'Position',lukeobj.ohm.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.transp.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.transp.disp.string,'Position',lukeobj.transp.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ripple.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.ripple.disp.string,'Position',lukeobj.ripple.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.wave.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.wave.disp.string,'Position',lukeobj.wave.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.luke.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.luke.disp.string,'Position',lukeobj.luke.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.r5x2.disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeobj.r5x2.disp.string,'Position',lukeobj.r5x2.disp.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

lukeobj.data.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.data.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.equil.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.equil.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ohm.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.ohm.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.transp.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.transp.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.ripple.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.ripple.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.wave.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.wave.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.luke.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.luke.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);
lukeobj.r5x2.text.handle = uicontrol(controlpanel.handle,'Style','text','Position',lukeobj.r5x2.text.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize);

infotext.handle = uicontrol(infopanel.handle,'Style','text','String',infotext.string,'Position',infotext.position,'FontName',fontname,'FontUnits','pixels','FontSize',fontsize,'HorizontalAlignment','left');
infostr.handle = uicontrol(infopanel.handle,'Style','text','String',infostr.string,'Position',infostr.position,'FontName',fontname,'FontUnits','pixels','FontSize',titlefontsize,'HorizontalAlignment','center');

style.fontname = fontname;
style.fontsize = fontsize;
style.titlefontsize = titlefontsize;
style.butheight = butheight;
style.butwidth = butwidth;
style.buthsep = buthsep;
style.butvsep = butvsep;
style.butheight = butheight;

graphs = struct;
graphs.handles = [];
graphs.info = '';
graphs.tag = '';
graphs(1) = [];% empty structure but keep memory of fields

plot1.gindex = 0;
plot2.gindex = 0;
plot3.gindex = 0;

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
