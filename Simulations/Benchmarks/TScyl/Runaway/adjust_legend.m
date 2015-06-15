boxtrim = 0.85;%1;%
lineshift = 0;
textshift = -0.05;

fch = get(gcf,'children');
leg = fch(1);%legend
%
set(leg,'PlotBoxAspectRatio',[1,boxtrim,1]);

lch = get(leg,'children');

for ich = 2:3:length(lch),
    set(lch(ich),'ydata',get(lch(ich),'ydata') + lineshift),
end
for ich = 3:3:length(lch),
    set(lch(ich),'position',get(lch(ich),'position') + [0,textshift,0]);
end
