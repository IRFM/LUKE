%
clear all
close all
%
%select = [1,2,3];
select = [1,2];
%
%list = {'19Z_2','20Z_2','21Z_2'};
%leglist = ['N_{||} = 1.9';'N_{||} = 2.0';'N_{||} = 2.1'];
list = {'19Z_2','conv_19Z_2'};
leglist = ['N_{||} = 1.9 old ';'N_{||} = 1.9 conv'];
%
color = {'r','b',[0,0.75,0]};
%
Nl = length(select);
leg = leglist(select,:);
%
for il = 1:Nl,
    load(['DKE_RESULTS_ITER_Scen4_',list{select(il)}]);
    %
    xrho_P{select(il)} = sqrt(gridDKE.xpsin);  
    xJ{il} = Zcurr.x_0_fsav*mksa.j_ref;
    xP{il} = ZP0.x_rf_fsav.'*mksa.P_ref;
    xdA{il} = equilDKE.xdA_dke;
    if isfield(equilDKE,'xdV_dke'),
        xdV{il} = equilDKE.xdV_dke;
    else
        xdV{il} = equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp;
    end
    %
    Itot(il) = sum(xJ{il}.*xdA{il})
    Ptot(il) = sum(xP{il}.*xdV{il})
    %
    Itotstr = num2str(Itot(il));
    %
    leg_I(il,:) = ['I_{LH} = ',Itotstr(1:min(4,length(Itotstr))),' MA'];
    %
end    
%
xlab = '';
ylab = '';
tit = '';
xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
style = '-';
width = 0.5;
width2 = 2;
marker = 'none';
siz = 20;
red = 0.9;
lspace = 0.7;
bspace = 0.7;
%
color1 = 'r';
color2 = 'b';
%
figure(1);clf
%
xlab = 'rho';
ylab = 'S_{LH} (MW/m^3)';
xlim = [0,1];
ylim = NaN;
%
for il = 1:Nl-1,
    graph1D_jd(xrho_P{il},xP{il},0,0,'','','',NaN,xlim,ylim,style,marker,color{select(il)},width2,siz);
end
graph1D_jd(xrho_P{Nl},xP{Nl},0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color{select(Nl)},width2,siz,gca,red,lspace,bspace);
grid off
set(gca,'xtick',[0:0.2:1])
%
figure(2);clf
%
xlab = 'rho';
ylab = 'J_{LH} (MA/m^2)';
xlim = [0,1];
ylim = NaN;
%
for il = 1:Nl-1,
    graph1D_jd(xrho_P{il},xJ{il},0,0,'','','',NaN,xlim,ylim,style,marker,color{select(il)},width2,siz);
end
graph1D_jd(xrho_P{Nl},xJ{Nl},0,0,xlab,ylab,tit,leg_I,xlim,ylim,style,marker,color{select(Nl)},width2,siz,gca,red,lspace,bspace);
grid off
set(gca,'xtick',[0:0.2:1])
    