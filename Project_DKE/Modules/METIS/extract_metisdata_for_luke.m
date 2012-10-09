function extract_metisdata_for_luke(post)
%
time = post.profil0d.temps;
nt = length(time);
tmask = NaN(1,nt);
for it = 1:nt,
    tmask(it) = find(abs((post.zerod.temps - time(it))/(time(it)+eps)) < 10*eps,1,'first');
end
%
figure,clf
%
figtit = 'METIS time grid';
%
set(gcf,'name',figtit)
%
xlab = 'METIS time';
ylab = 'LUKE time';
xlim = [0,ceil(max(time))];
ylim = xlim;
tit = 'Select LUKE times and click outside the graphs to exit';
leg = NaN;
%
plhdisp = post.zerod.plh(tmask)*0.9*ylim(2)/max(post.zerod.plh);
tdisp = zeros(1,nt);
%
graph1D_jd(time,plhdisp,0,0,'','','',NaN,xlim,ylim,'-','none','g',0.5,20+14i);
graph1D_jd(time,tdisp,0,0,xlab,ylab,tit,leg,xlim,ylim,'none','+','b',2,20+14i,gca,0.9,0.5,0.5);
%
[t,dummy] = ginput(1);
%
itsel = [];
%
while t >= xlim(1) && t <= xlim(2),
    %
    it = find(abs(time - t) == min(abs(time - t)),1,'first');
    tdisp(it) = time(it);
    itsel = tdisp > 0;
    %
    clf,
    %
    graph1D_jd(time,plhdisp,0,0,'','','',NaN,xlim,ylim,'-','none','g',0.5,20+14i);
    graph1D_jd(time(itsel),tdisp(itsel),0,0,'','','',NaN,xlim,ylim,'none','o','r',2,20+14i);
    graph1D_jd(time(~itsel),tdisp(~itsel),0,0,xlab,ylab,tit,leg,xlim,ylim,'none','+','b',2,20+14i,gca,0.9,0.5,0.5);
    %
    [t,dummy] = ginput(1);
    %
end
%
tsel2 = input_dke_yp('You can enter additional times for LUKE calculations',[],[xlim(1);xlim(2)]);
nt2 = length(tsel2);
itsel2 = NaN(1,nt2);
for it = 1:nt2,
    it2 = find(abs(time - tsel2(it)) == min(abs(time - tsel2(it))),1,'first');
    itsel2(it) = it2;
end
%
itsel = unique([find(itsel),itsel2]);
%
post.z0dinput.option.luke_mode = 2;%save before LUKE calculation
%
post.z0dinput.option.luke_helena = input_dke_yp('You you want to \n (0) use metis equilibrium\n (1) use helena to recalculate the equilibrium\n (2) load an existing equilibrium\n ?',0,0:2);
post.z0dinput.option.bsigne = input_dke_yp('Direction of the toroidal magnetic field viewed from top\n (1) clockwise\n (-1) anti-clockwise\n ',1,[-1,1]);
%
for it = itsel,
    metis2luke(post,it,1);
end




    