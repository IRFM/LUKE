function s = iluke_controls(h,s,sname,list,titlestring,vertpos,style)

fieldnames = {'title','import','make','load','save','run','clear','disp','text'};
strings = {titlestring,'Import','New','Load','Save','Run','Clear','Disp',''};
styles = {'Text','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','Text'};
positionindices = [1,2,2,3,4,4,5,6,7];
%
s.(sname) = struct;
for ilist = 1:length(list),
    s.(sname).(fieldnames{list(ilist)}) = struct;
end
%
butwidthcorr = style.butwidth + style.buthsep;
titlewidthcorr = style.buthsep + (style.titlewidth + style.buthsep);
infowidth = style.panelwidth - titlewidthcorr - 5*butwidthcorr - style.buthsep;
%
for ifield = 1:length(fieldnames),
    %
    fname = fieldnames{ifield};
    fstyle = styles{ifield};
    fstring = strings{ifield};
    positionindex = positionindices(ifield);
    %
    if positionindex == 1,%title
        if ~isfield(s.(sname),'run'),% mode = 0
            fposition = [style.buthsep,vertpos + style.textheightcorr,style.titlewidth,style.textheight];
        else % mode = 1
            fposition = [style.buthsep,vertpos + style.textheightcorr,titlewidthcorr + butwidthcorr + style.butwidth,style.textheight];
        end
    elseif positionindex == 7,%text
        fposition = [titlewidthcorr + (positionindex - 2)*butwidthcorr,vertpos + style.textheightcorr,infowidth,style.textheight];
    else %pushbutton
        fposition = [titlewidthcorr + (positionindex - 2)*butwidthcorr,vertpos,style.butwidth,style.butheight];
    end
    %
    if isfield(s.(sname),fname),
        s.(sname).(fname).handle = uicontrol(h,'Style',fstyle,'String',fstring,'Position',fposition,'FontName',style.fontname,'FontUnits','pixels','FontSize',style.fontsize);
        if strcmp(fstyle,'pushbutton'),
            set(s.(sname).(fname).handle,'Callback',['action = ''',sname,fname,''';iluke_callbacks;']);
        end
        if positionindex == 1,
            set(s.(sname).(fname).handle,'HorizontalAlignment','left');
        end
    end
    %
end



