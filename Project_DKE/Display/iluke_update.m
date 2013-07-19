%script iluke_update


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
set(simulfile.handle,'String',simulfile.string,'Position',simulfile.position);
set(titlestr.handle,'String',titlestr.string,'Position',titlestr.position);

set(exitluke.handle,'String',exitluke.string,'Position',exitluke.position,'Enable',exitluke.state,'Callback',exitluke.callback);
set(newshot.handle,'String',newshot.string,'Position',newshot.position,'Enable',newshot.state);
set(loadshot.handle,'String',loadshot.string,'Position',loadshot.position,'Enable',loadshot.state);
set(saveshot.handle,'String',saveshot.string,'Position',saveshot.position,'Enable',saveshot.state);

%
set(controlstr.handle,'String',controlstr.string,'Position',controlstr.position);

set(datatitle.handle,'String',datatitle.string,'Position',datatitle.position);
set(equiltitle.handle,'String',equiltitle.string,'Position',equiltitle.position);
set(ohmtitle.handle,'String',ohmtitle.string,'Position',ohmtitle.position);
set(transptitle.handle,'String',transptitle.string,'Position',transptitle.position);
set(rippletitle.handle,'String',rippletitle.string,'Position',rippletitle.position);
set(wavetitle.handle,'String',wavetitle.string,'Position',wavetitle.position);
set(luketitle.handle,'String',luketitle.string,'Position',luketitle.position);
set(r5x2title.handle,'String',r5x2title.string,'Position',r5x2title.position);

set(datamake.handle,'String',datamake.string,'Position',datamake.position,'Enable',datamake.state,'Callback',datamake.callback);
set(equilmake.handle,'String',equilmake.string,'Position',equilmake.position,'Enable',equilmake.state);
set(ohmmake.handle,'String',ohmmake.string,'Position',ohmmake.position,'Enable',ohmmake.state);
set(transpmake.handle,'String',transpmake.string,'Position',transpmake.position,'Enable',transpmake.state);
set(ripplemake.handle,'String',ripplemake.string,'Position',ripplemake.position,'Enable',ripplemake.state);
set(wavemake.handle,'String',wavemake.string,'Position',wavemake.position,'Enable',wavemake.state);

set(dataload.handle,'String',dataload.string,'Position',dataload.position,'Enable',dataload.state,'Callback',dataload.callback);
set(equilload.handle,'String',equilload.string,'Position',equilload.position,'Enable',equilload.state);
set(ohmload.handle,'String',ohmload.string,'Position',ohmload.position,'Enable',ohmload.state);
set(transpload.handle,'String',transpload.string,'Position',transpload.position,'Enable',transpload.state);
set(rippleload.handle,'String',rippleload.string,'Position',rippleload.position,'Enable',rippleload.state);
set(waveload.handle,'String',waveload.string,'Position',waveload.position,'Enable',waveload.state);

set(datasave.handle,'String',datasave.string,'Position',datasave.position,'Enable',datasave.state,'Callback',datasave.callback);
set(equilsave.handle,'String',equilsave.string,'Position',equilsave.position,'Enable',equilsave.state);
set(ohmsave.handle,'String',ohmsave.string,'Position',ohmsave.position,'Enable',ohmsave.state);
set(transpsave.handle,'String',transpsave.string,'Position',transpsave.position,'Enable',transpsave.state);
set(ripplesave.handle,'String',ripplesave.string,'Position',ripplesave.position,'Enable',ripplesave.state);
set(wavesave.handle,'String',wavesave.string,'Position',wavesave.position,'Enable',wavesave.state);

set(lukerun.handle,'String',lukerun.string,'Position',lukerun.position,'Enable',lukerun.state);
set(r5x2run.handle,'String',r5x2run.string,'Position',r5x2run.position,'Enable',r5x2run.state);

set(dataclear.handle,'String',dataclear.string,'Position',dataclear.position,'Enable',dataclear.state);
set(equilclear.handle,'String',equilclear.string,'Position',equilclear.position,'Enable',equilclear.state);
set(ohmclear.handle,'String',ohmclear.string,'Position',ohmclear.position,'Enable',ohmclear.state);
set(transpclear.handle,'String',transpclear.string,'Position',transpclear.position,'Enable',transpclear.state);
set(rippleclear.handle,'String',rippleclear.string,'Position',rippleclear.position,'Enable',rippleclear.state);
set(waveclear.handle,'String',waveclear.string,'Position',waveclear.position,'Enable',waveclear.state);
set(lukeclear.handle,'String',lukeclear.string,'Position',lukeclear.position,'Enable',lukeclear.state);
set(r5x2clear.handle,'String',r5x2clear.string,'Position',r5x2clear.position,'Enable',r5x2clear.state);

set(datadisp.handle,'String',datadisp.string,'Position',datadisp.position,'Enable',datadisp.state);
set(equildisp.handle,'String',equildisp.string,'Position',equildisp.position,'Enable',equildisp.state);
set(ohmdisp.handle,'String',ohmdisp.string,'Position',ohmdisp.position,'Enable',ohmdisp.state);
set(transpdisp.handle,'String',transpdisp.string,'Position',transpdisp.position,'Enable',transpdisp.state);
set(rippledisp.handle,'String',rippledisp.string,'Position',rippledisp.position,'Enable',rippledisp.state);
set(wavedisp.handle,'String',wavedisp.string,'Position',wavedisp.position,'Enable',wavedisp.state);
set(lukedisp.handle,'String',lukedisp.string,'Position',lukedisp.position,'Enable',lukedisp.state);
set(r5x2disp.handle,'String',r5x2disp.string,'Position',r5x2disp.position,'Enable',r5x2disp.state);

set(datatext.handle,'String',datatext.string,'Position',datatext.position);
set(equiltext.handle,'String',equiltext.string,'Position',equiltext.position);
set(ohmtext.handle,'String',ohmtext.string,'Position',ohmtext.position);
set(transptext.handle,'String',transptext.string,'Position',transptext.position);
set(rippletext.handle,'String',rippletext.string,'Position',rippletext.position);
set(wavetext.handle,'String',wavetext.string,'Position',wavetext.position);
set(luketext.handle,'String',luketext.string,'Position',luketext.position);
set(r5x2text.handle,'String',r5x2text.string,'Position',r5x2text.position);

set(infotext.handle,'String',infotext.string,'Position',infotext.position);
set(infostr.handle,'String',infostr.string,'Position',infostr.position);
