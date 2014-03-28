function s = iluke_controls(h,s,sname,list,titlestring,vertpos,style)

fieldnames = {'title','import','make','modify','load','save','run','clear','reset','test','disp','text'};
strings = {titlestring,'Import','New','Modify','Load','Save','Run','Clear','Reset','Test','Disp',''};
styles = {'Text','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','pushbutton','Text'};
%
butwidthcorr = style.butwidth + style.buthsep;
titlewidthcorr = style.buthsep + (style.titlewidth + style.buthsep);
infowidth = style.panelwidth - titlewidthcorr - 5*butwidthcorr - style.buthsep;
%
s.(sname) = struct;
for ilist = 1:length(list),
    if ~isempty(list{ilist}),
        fname = list{ilist};
        s.(sname).(fname) = struct;
        %
        ifield = find(strcmp(fieldnames,fname));
        %
        if ~isempty(ifield),
            fstyle = styles{ifield};
            fstring = strings{ifield};
        else
            fstyle = 'pushbutton';
            fstring = fname;
        end            
        positionindex = ilist;
        %
        if positionindex == 1,%title
            next = find(~strcmp(list(2:end),''),1,'first') - 1;% number of button space occupied by title
            fposition = [style.buthsep,vertpos + style.textheightcorr,style.titlewidth + next*butwidthcorr,style.textheight];
        elseif positionindex == 7,%text
            next = 6 - find(~strcmp(list(1:end-1),''),1,'last');% number of button space occupied by title
            fposition = [titlewidthcorr + (positionindex - 2 - next)*butwidthcorr,vertpos + style.textheightcorr,infowidth +  next*butwidthcorr,style.textheight];
        else %pushbutton
            fposition = [titlewidthcorr + (positionindex - 2)*butwidthcorr,vertpos,style.butwidth,style.butheight];
        end
        %
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



