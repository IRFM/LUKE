%
% GUI FOR LUKE/C3PO/R5X2
%
clear all
close all
%
dkepath = load_structures_yp('dkepath','','');
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
graphwidth = 400;
graphheight = 300;
%
simulfiletitlewidth = 140;
shotnumtitlewidth = 120; 
shotnumwidth = 80; 
titlestrheight = 30;
%
titlewidth = 105;
butheight = 25;%40;% height of button
butwidth = 60;%80;% width of button
buthsep = 10;% horizontal separation between buttons
butvsep = 10;% vertical separation between buttons
%
fontname = 'Liberation Mono';%get(0,'FixedWidthFontName');%'fixedwidth';% font type
fontsize = 10;% font size
titlefontsize = 2*fontsize;
%
infotext.string = {'','To get started :',...
                      '==============  ','',...
    '- "Load" Existing simulation                                       ','',...
    '- "Import" Exp. data to import from database                  ',...
    '- "Load" Exp. data to load from existing EXTERNAL file     ',...
    '- "New" Equilibrium to create equilibrium or import EQDSK file',...
    '- "Load" Equilibrium  to load from existing EQUIL file         '};
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
panelwidth = figbasewidth - graphwidth;
%
titleheight = 2*butheight + 4*butvsep + titlestrheight;
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
plot1.position = [panelwidth + 2*panelsep,2*graphheight + 3*panelsep,graphwidth,graphheight];
plot2.position = [panelwidth + 2*panelsep,graphheight + 2*panelsep,graphwidth,graphheight];
plot3.position = [panelwidth + 2*panelsep,panelsep,graphwidth,graphheight];
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
tokamaktitle.position = [buthsep,2*textheight + butvsep + textheightcorr,shotnumtitlewidth,textheight];
shotnumtitle.position = [buthsep,textheight + butvsep + textheightcorr,shotnumtitlewidth,textheight];
shotimetitle.position = [buthsep,butvsep + textheightcorr,shotnumtitlewidth,textheight];
%
tokamak.position = [2*buthsep+shotnumtitlewidth,2*textheight + butvsep + textheightcorr,shotnumwidth,textheight];
shotnum.position = [2*buthsep+shotnumtitlewidth,textheight + butvsep + textheightcorr,shotnumwidth,textheight];
shotime.position = [2*buthsep+shotnumtitlewidth,butvsep + textheightcorr,shotnumwidth,textheight];
%
exitluke.position = [shotnumtitlewidth + shotnumwidth + 3*buthsep,butheight + 2*butvsep,butwidth,butheight];
newshot.position = [shotnumtitlewidth + shotnumwidth + 3*buthsep,butvsep,butwidth,butheight];
loadshot.position = [shotnumtitlewidth + shotnumwidth + butwidth + 4*buthsep,butheight + 2*butvsep,butwidth,butheight];
saveshot.position = [shotnumtitlewidth + shotnumwidth + butwidth + 4*buthsep,butvsep,butwidth,butheight];
%
simulfilewidth = panelwidth - shotnumtitlewidth - shotnumwidth - simulfiletitlewidth - 7*buthsep - 2*butwidth;
%
lukeroottitle.position = [panelwidth - simulfilewidth - simulfiletitlewidth - 2*buthsep,2*textheight + butvsep + textheightcorr,simulfiletitlewidth,textheight];
lukevertitle.position = [panelwidth - simulfilewidth - simulfiletitlewidth - 2*buthsep,textheight + butvsep + textheightcorr,simulfiletitlewidth,textheight];
simulfiletitle.position = [panelwidth - simulfilewidth - simulfiletitlewidth - 2*buthsep,butvsep + textheightcorr,simulfiletitlewidth,textheight];
%
lukeroot.position = [panelwidth - simulfilewidth - buthsep,2*textheight + butvsep + textheightcorr,simulfilewidth,textheight];
lukever.position = [panelwidth - simulfilewidth - buthsep,textheight + butvsep + textheightcorr,simulfilewidth,textheight];
simulfile.position = [panelwidth - simulfilewidth - buthsep,butvsep + textheightcorr,simulfilewidth,textheight];
%
titlestr.position = [buthsep,2*butheight + 3*butvsep,panelwidth - 2*buthsep,titlestrheight];
%
% title column
%
controlheightcorr = controlheight - controlstrcorr;
%
datatitle.position = [buthsep,controlheightcorr - butheightcorr + textheightcorr,titlewidth,textheight];
equiltitle.position = [buthsep,controlheightcorr - 2*butheightcorr + textheightcorr,titlewidth,textheight];
ohmtitle.position = [buthsep,controlheightcorr - 3*butheightcorr + textheightcorr,titlewidth,textheight];
transptitle.position = [buthsep,controlheightcorr - 4*butheightcorr + textheightcorr,titlewidth,textheight];
rippletitle.position = [buthsep,controlheightcorr - 5*butheightcorr + textheightcorr,titlewidth,textheight];
wavetitle.position = [buthsep,controlheightcorr - 6*butheightcorr + textheightcorr,titlewidth,textheight];
luketitle.position = [buthsep,controlheightcorr - 7*butheightcorr - butvsep + textheightcorr,titlewidthcorr + butwidthcorr + butwidth,textheight];
r5x2title.position = [buthsep,controlheightcorr - 8*butheightcorr - 2*butvsep + textheightcorr,titlewidthcorr + butwidthcorr + butwidth,textheight];
%
% create column
%
datamake.position = [titlewidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
equilmake.position = [titlewidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
ohmmake.position = [titlewidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
transpmake.position = [titlewidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
ripplemake.position = [titlewidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
wavemake.position = [titlewidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
%
% load column
%
dataload.position = [titlewidthcorr + butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
equilload.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
ohmload.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
transpload.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
rippleload.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
waveload.position = [titlewidthcorr + butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
%
% save column
%
datasave.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
equilsave.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
ohmsave.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
transpsave.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
ripplesave.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
wavesave.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
%
lukerun.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep,butwidth,butheight];
r5x2run.position = [titlewidthcorr + 2*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep,butwidth,butheight];
%
% clear column
%
dataclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
equilclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
ohmclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
transpclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
rippleclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
waveclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
lukeclear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep,butwidth,butheight];
r5x2clear.position = [titlewidthcorr + 3*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep,butwidth,butheight];
%
% disp column
%
datadisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - butheightcorr,butwidth,butheight];
equildisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 2*butheightcorr,butwidth,butheight];
ohmdisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 3*butheightcorr,butwidth,butheight];
transpdisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 4*butheightcorr,butwidth,butheight];
rippledisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 5*butheightcorr,butwidth,butheight];
wavedisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 6*butheightcorr,butwidth,butheight];
lukedisp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep,butwidth,butheight];
r5x2disp.position = [titlewidthcorr + 4*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep,butwidth,butheight];
%
% info column
%
datatext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - butheightcorr + textheightcorr,infowidth,textheight];
equiltext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 2*butheightcorr + textheightcorr,infowidth,textheight];
ohmtext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 3*butheightcorr + textheightcorr,infowidth,textheight];
transptext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 4*butheightcorr + textheightcorr,infowidth,textheight];
rippletext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 5*butheightcorr + textheightcorr,infowidth,textheight];
wavetext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 6*butheightcorr + textheightcorr,infowidth,textheight];
luketext.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 7*butheightcorr - butvsep + textheightcorr,infowidth,textheight];
r5x2text.position = [titlewidthcorr + 5*butwidthcorr,controlheightcorr - 8*butheightcorr - 2*butvsep + textheightcorr,infowidth,textheight];
%


tokamaktitle.string = 'TOKAMAK       : ';
shotnumtitle.string = 'SHOT NUMBER   : ';
shotimetitle.string = 'SHOT TIME (s) : ';

tokamak.string = '< empty >';
shotnum.string = '< empty >';
shotime.string = '< empty >';

lukeroottitle.string =  'LUKE VERSION    : ';
lukevertitle.string =   'MATLAB VERSION  : ';
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

datatitle.string = 'Exp. Data';
equiltitle.string = 'Equilibrium';
ohmtitle.string = 'Ohmic Field';
transptitle.string = 'Transport';
rippletitle.string = 'Mag. Ripple';
wavetitle.string = 'RF Waves';
luketitle.string = 'Fokker-Planck Equation';
r5x2title.string = 'Fast Electron Bremsstrahlung';

datamake.string = 'Import';%'Create';
equilmake.string = 'New';%'Create';
ohmmake.string = 'New';%'Create';
transpmake.string = 'New';%'Create';
ripplemake.string = 'New';%'Create';
wavemake.string = 'New';%'Create';

dataload.string = 'Load';
equilload.string = 'Load';
ohmload.string = 'Load';
transpload.string = 'Load';
rippleload.string = 'Load';
waveload.string = 'Load';

datasave.string = 'Save';
equilsave.string = 'Save';
ohmsave.string = 'Save';
transpsave.string = 'Save';
ripplesave.string = 'Save';
wavesave.string = 'Save';

lukerun.string = 'Run';
r5x2run.string = 'Run';

dataclear.string = 'Clear';
equilclear.string = 'Clear';
ohmclear.string = 'Clear';
transpclear.string = 'Clear';
rippleclear.string = 'Clear';
waveclear.string = 'Clear';
lukeclear.string = 'Clear';
r5x2clear.string = 'Clear';

datadisp.string = 'Disp';%'Display';
equildisp.string = 'Disp';%'Display';
ohmdisp.string = 'Disp';%'Display';
transpdisp.string = 'Disp';%'Display';
rippledisp.string = 'Disp';%'Display';
wavedisp.string = 'Disp';%'Display';
lukedisp.string = 'Disp';
r5x2disp.string = 'Disp';

datatext.string = '< empty >';
equiltext.string = '< empty >';
ohmtext.string = '< empty >';
transptext.string = '< empty >';
rippletext.string = '< empty >';
wavetext.string = '< empty >';
luketext.string = '< empty >';
r5x2text.string = '< empty >';

exitluke.state = 'on';
newshot.state = 'on';
loadshot.state = 'on';
saveshot.state = 'on';

datamake.state = 'on';
equilmake.state = 'on';
ohmmake.state = 'off';
transpmake.state = 'off';
ripplemake.state = 'off';
wavemake.state = 'off';

dataload.state = 'on';
equilload.state = 'on';
ohmload.state = 'off';
transpload.state = 'off';
rippleload.state = 'off';
waveload.state = 'off';

datasave.state = 'off';
equilsave.state = 'off';
ohmsave.state = 'off';
transpsave.state = 'off';
ripplesave.state = 'off';
wavesave.state = 'off';

lukerun.state = 'off';
r5x2run.state = 'off';

dataclear.state = 'off';
equilclear.state = 'off';
ohmclear.state = 'off';
transpclear.state = 'off';
rippleclear.state = 'off';
waveclear.state = 'off';
lukeclear.state = 'off';
r5x2clear.state = 'off';

datadisp.state = 'off';
equildisp.state = 'off';
ohmdisp.state = 'off';
transpdisp.state = 'off';
rippledisp.state = 'off';
wavedisp.state = 'off';
lukedisp.state = 'off';
r5x2disp.state = 'off';

%

exitluke.callback = 'close(mainfig.handle)';
%
datamake.callback = 'action = ''datamake'';iluke_callbacks;';
datasave.callback = 'action = ''datasave'';iluke_callbacks;';
dataload.callback = 'action = ''dataload'';iluke_callbacks;';

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

tokamaktitle.handle = uicontrol(titlepanel.handle,'Style','text','String',tokamaktitle.string,'Position',tokamaktitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
shotnumtitle.handle = uicontrol(titlepanel.handle,'Style','text','String',shotnumtitle.string,'Position',shotnumtitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
shotimetitle.handle = uicontrol(titlepanel.handle,'Style','text','String',shotimetitle.string,'Position',shotimetitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');

tokamak.handle = uicontrol(titlepanel.handle,'Style','text','String',tokamak.string,'Position',tokamak.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
shotnum.handle = uicontrol(titlepanel.handle,'Style','text','String',shotnum.string,'Position',shotnum.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
shotime.handle = uicontrol(titlepanel.handle,'Style','text','String',shotime.string,'Position',shotime.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');

lukeroot.handle = uicontrol(titlepanel.handle,'Style','text','String',lukeroot.string,'Position',lukeroot.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
lukever.handle = uicontrol(titlepanel.handle,'Style','text','String',lukever.string,'Position',lukever.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
simulfile.handle = uicontrol(titlepanel.handle,'Style','text','String',simulfile.string,'Position',simulfile.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');

lukeroottitle.handle = uicontrol(titlepanel.handle,'Style','text','String',lukeroottitle.string,'Position',lukeroottitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
lukevertitle.handle = uicontrol(titlepanel.handle,'Style','text','String',lukevertitle.string,'Position',lukevertitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
simulfiletitle.handle = uicontrol(titlepanel.handle,'Style','text','String',simulfiletitle.string,'Position',simulfiletitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');

titlestr.handle = uicontrol(titlepanel.handle,'Style','text','String',titlestr.string,'Position',titlestr.position,'FontName',fontname,'FontSize',titlefontsize,'HorizontalAlignment','center');

exitluke.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',exitluke.string,'Position',exitluke.position,'FontName',fontname,'FontSize',fontsize,'Enable',exitluke.state,'Callback',exitluke.callback);
newshot.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',newshot.string,'Position',newshot.position,'FontName',fontname,'FontSize',fontsize,'Enable',newshot.state);
loadshot.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',loadshot.string,'Position',loadshot.position,'FontName',fontname,'FontSize',fontsize,'Enable',loadshot.state);
saveshot.handle = uicontrol(titlepanel.handle,'Style','pushbutton','String',saveshot.string,'Position',saveshot.position,'FontName',fontname,'FontSize',fontsize,'Enable',saveshot.state);

%
controlstr.handle = uicontrol(controlpanel.handle,'Style','text','String',controlstr.string,'Position',controlstr.position,'FontName',fontname,'FontSize',titlefontsize,'HorizontalAlignment','center');

datatitle.handle = uicontrol(controlpanel.handle,'Style','text','String',datatitle.string,'Position',datatitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
equiltitle.handle = uicontrol(controlpanel.handle,'Style','text','String',equiltitle.string,'Position',equiltitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
ohmtitle.handle = uicontrol(controlpanel.handle,'Style','text','String',ohmtitle.string,'Position',ohmtitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
transptitle.handle = uicontrol(controlpanel.handle,'Style','text','String',transptitle.string,'Position',transptitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
rippletitle.handle = uicontrol(controlpanel.handle,'Style','text','String',rippletitle.string,'Position',rippletitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
wavetitle.handle = uicontrol(controlpanel.handle,'Style','text','String',wavetitle.string,'Position',wavetitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
luketitle.handle = uicontrol(controlpanel.handle,'Style','text','String',luketitle.string,'Position',luketitle.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');
r5x2title.handle = uicontrol(controlpanel.handle,'Style','text','String',r5x2title.string,'Position',r5x2title.position,'FontName',fontname,'FontSize',fontsize,'HorizontalAlignment','left');

datamake.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',datamake.string,'Position',datamake.position,'FontName',fontname,'FontSize',fontsize,'Enable',datamake.state,'Callback',datamake.callback);
equilmake.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',equilmake.string,'Position',equilmake.position,'FontName',fontname,'FontSize',fontsize,'Enable',equilmake.state);
ohmmake.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ohmmake.string,'Position',ohmmake.position,'FontName',fontname,'FontSize',fontsize,'Enable',ohmmake.state);
transpmake.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',transpmake.string,'Position',transpmake.position,'FontName',fontname,'FontSize',fontsize,'Enable',transpmake.state);
ripplemake.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ripplemake.string,'Position',ripplemake.position,'FontName',fontname,'FontSize',fontsize,'Enable',ripplemake.state);
wavemake.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',wavemake.string,'Position',wavemake.position,'FontName',fontname,'FontSize',fontsize,'Enable',wavemake.state);

dataload.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',dataload.string,'Position',dataload.position,'FontName',fontname,'FontSize',fontsize,'Enable',dataload.state,'Callback',dataload.callback);
equilload.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',equilload.string,'Position',equilload.position,'FontName',fontname,'FontSize',fontsize,'Enable',equilload.state);
ohmload.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ohmload.string,'Position',ohmload.position,'FontName',fontname,'FontSize',fontsize,'Enable',ohmload.state);
transpload.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',transpload.string,'Position',transpload.position,'FontName',fontname,'FontSize',fontsize,'Enable',transpload.state);
rippleload.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',rippleload.string,'Position',rippleload.position,'FontName',fontname,'FontSize',fontsize,'Enable',rippleload.state);
waveload.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',waveload.string,'Position',waveload.position,'FontName',fontname,'FontSize',fontsize,'Enable',waveload.state);

datasave.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',datasave.string,'Position',datasave.position,'FontName',fontname,'FontSize',fontsize,'Enable',datasave.state,'Callback',datasave.callback);
equilsave.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',equilsave.string,'Position',equilsave.position,'FontName',fontname,'FontSize',fontsize,'Enable',equilsave.state);
ohmsave.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ohmsave.string,'Position',ohmsave.position,'FontName',fontname,'FontSize',fontsize,'Enable',ohmsave.state);
transpsave.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',transpsave.string,'Position',transpsave.position,'FontName',fontname,'FontSize',fontsize,'Enable',transpsave.state);
ripplesave.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ripplesave.string,'Position',ripplesave.position,'FontName',fontname,'FontSize',fontsize,'Enable',ripplesave.state);
wavesave.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',wavesave.string,'Position',wavesave.position,'FontName',fontname,'FontSize',fontsize,'Enable',wavesave.state);

lukerun.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukerun.string,'Position',lukerun.position,'FontName',fontname,'FontSize',fontsize,'Enable',lukerun.state);
r5x2run.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',r5x2run.string,'Position',r5x2run.position,'FontName',fontname,'FontSize',fontsize,'Enable',r5x2run.state);

dataclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',dataclear.string,'Position',dataclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',dataclear.state);
equilclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',equilclear.string,'Position',equilclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',equilclear.state);
ohmclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ohmclear.string,'Position',ohmclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',ohmclear.state);
transpclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',transpclear.string,'Position',transpclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',transpclear.state);
rippleclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',rippleclear.string,'Position',rippleclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',rippleclear.state);
waveclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',waveclear.string,'Position',waveclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',waveclear.state);
lukeclear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukeclear.string,'Position',lukeclear.position,'FontName',fontname,'FontSize',fontsize,'Enable',lukeclear.state);
r5x2clear.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',r5x2clear.string,'Position',r5x2clear.position,'FontName',fontname,'FontSize',fontsize,'Enable',r5x2clear.state);

datadisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',datadisp.string,'Position',datadisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',datadisp.state);
equildisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',equildisp.string,'Position',equildisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',equildisp.state);
ohmdisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',ohmdisp.string,'Position',ohmdisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',ohmdisp.state);
transpdisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',transpdisp.string,'Position',transpdisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',transpdisp.state);
rippledisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',rippledisp.string,'Position',rippledisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',rippledisp.state);
wavedisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',wavedisp.string,'Position',wavedisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',wavedisp.state);
lukedisp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',lukedisp.string,'Position',lukedisp.position,'FontName',fontname,'FontSize',fontsize,'Enable',lukedisp.state);
r5x2disp.handle = uicontrol(controlpanel.handle,'Style','pushbutton','String',r5x2disp.string,'Position',r5x2disp.position,'FontName',fontname,'FontSize',fontsize,'Enable',r5x2disp.state);

datatext.handle = uicontrol(controlpanel.handle,'Style','text','String',datatext.string,'Position',datatext.position,'FontName',fontname,'FontSize',fontsize);
equiltext.handle = uicontrol(controlpanel.handle,'Style','text','String',equiltext.string,'Position',equiltext.position,'FontName',fontname,'FontSize',fontsize);
ohmtext.handle = uicontrol(controlpanel.handle,'Style','text','String',ohmtext.string,'Position',ohmtext.position,'FontName',fontname,'FontSize',fontsize);
transptext.handle = uicontrol(controlpanel.handle,'Style','text','String',transptext.string,'Position',transptext.position,'FontName',fontname,'FontSize',fontsize);
rippletext.handle = uicontrol(controlpanel.handle,'Style','text','String',rippletext.string,'Position',rippletext.position,'FontName',fontname,'FontSize',fontsize);
wavetext.handle = uicontrol(controlpanel.handle,'Style','text','String',wavetext.string,'Position',wavetext.position,'FontName',fontname,'FontSize',fontsize);
luketext.handle = uicontrol(controlpanel.handle,'Style','text','String',luketext.string,'Position',luketext.position,'FontName',fontname,'FontSize',fontsize);
r5x2text.handle = uicontrol(controlpanel.handle,'Style','text','String',r5x2text.string,'Position',r5x2text.position,'FontName',fontname,'FontSize',fontsize);

infotext.handle = uicontrol(infopanel.handle,'Style','text','String',infotext.string,'Position',infotext.position,'FontName',fontname,'FontSize',fontsize);
infostr.handle = uicontrol(infopanel.handle,'Style','text','String',infostr.string,'Position',infostr.position,'FontName',fontname,'FontSize',titlefontsize,'HorizontalAlignment','center');


