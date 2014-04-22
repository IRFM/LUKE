function iluke_print(opt,savename,savedir,h)
%
% prints or save handle h
%
newfig = figure;
%
for ich = length(h):-1:1,
    ax(ich) = copyobj(h(ich),newfig);
end
%
red = 1;
lspace = 0.7;
bspace = 0.7;
%
fontsize = 20;
legfontsize = 16;
%
res = 600;
%
fontunits = 'points';
%
fontname = 'Times';
legfontname = 'Times';
%
ch = get(newfig,'children');
%
for ich = 1:length(ch),
    %
    set(ch(ich),'fontunits',fontunits,'fontsize',fontsize,'fontname',fontname);
    %
    if strcmp(get(ch(ich),'tag'),'legend'),% legend
        cch = get(ch(ich),'children');
        for icch = 1:length(cch),
            if strcmp(get(cch(icch),'type'),'text'),
                set(cch(icch),'fontunits',fontunits,'fontsize',legfontsize,'fontname',legfontname);
            end
        end
    elseif isempty(get(ch(ich),'tag')),% axis
        set(get(ch(ich),'xlabel'),'fontunits',fontunits,'fontsize',fontsize,'fontname',fontname);
        set(get(ch(ich),'ylabel'),'fontunits',fontunits,'fontsize',fontsize,'fontname',fontname);
        set(get(ch(ich),'zlabel'),'fontunits',fontunits,'fontsize',fontsize,'fontname',fontname);
        set(get(ch(ich),'title'),'fontunits',fontunits,'fontsize',fontsize,'fontname',fontname);
        %
        resizejd(ch(ich),red,lspace,bspace);
    end        
    %
end
%
drawnow;
%
print_jd(opt,savename,savedir,newfig,res)
%
close(newfig)