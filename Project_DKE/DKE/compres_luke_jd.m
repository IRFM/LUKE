function compres_luke_jd(ids_equil,ids_wave,leg,si,opt_rho)
%
% compares results from a list of runs 
%
if nargin < 5,
    opt_rho = 0;
end
if nargin < 4,
    si = 1;
end
%
color = {'r','b',[0,0.75,0]};
%
Nl = length(ids_wave);
%
filename = 'res_comp.log';
delete(filename);
diary(filename);
%
load(['DKE_RESULTS_',ids_equil{1},'_',ids_wave{1}],'dke_out')
%
disp(['Simulation id: ',dke_out.simul.id]);
disp(['Simulation date: ',timeid_jd(dke_out.simul.timeid)]);
disp(['User id: ',dke_out.simul.userid]);
disp(['LUKE Version: ',dke_out.simul.LUKEversion]);
disp(' ');
%
for il = 1:Nl,
    if length(ids_equil) == 1,
        load(['DKE_RESULTS_',ids_equil{1},'_',ids_wave{il}],'Zcurr','ZP0','mksa','equilDKE','Zbouncecoef');
        str = ['EQUIL ',ids_equil{1},'; WAVE ',ids_wave{il},': '];
    else
        load(['DKE_RESULTS_',ids_equil{il},'_',ids_wave{il}],'Zcurr','ZP0','mksa','equilDKE','Zbouncecoef');
        str = ['EQUIL ',ids_equil{il},'; WAVE ',ids_wave{il},': '];
    end   
    %
    if opt_rho == 0,
        xrho{il} = equilDKE.xrho;
    elseif opt_rho == 1,
        xrho{il} = sqrt(equilDKE.xpsin);  
    elseif opt_rho == 2,
        xq_h = (Zbouncecoef.xq(1:end-1) + Zbouncecoef.xq(2:end))/2;
        xdpsin = diff(equilDKE.xpsin);
        xpsinT = [0,cumsum(xq_h.*xdpsin)]/sum(xq_h.*xdpsin);
        xrho{il} = sqrt(xpsinT);  
    end
    %
    xJ{il} = Zcurr.x_0_fsav*mksa.j_ref;
    xP{il} = ZP0.x_rf_fsav.'*mksa.P_ref;
    xdA{il} = equilDKE.xdA_dke;
    if isfield(equilDKE,'xdV_dke'),
        xdV{il} = equilDKE.xdV_dke;
    else
        xdV{il} = equilDKE.xdV_2piRp_dke*2*pi*equilDKE.Rp;
    end
    %
    Itot(il) = sum(xJ{il}.*xdA{il});
    Ptot(il) = sum(xP{il}.*xdV{il});
    %
    Itotstr = num2str(si*Itot(il));
    %
    leg_I(il,:) = ['I_{LH} = ',Itotstr(1:min(4,length(Itotstr))),' MA'];
    %
    disp([str,'I = ',num2str(Itot(il)),' MA;  P = ',num2str(Ptot(il)),' MW'])
    %
end  
%
diary off
%
clear Zcurr ZP0 mksa equilDKE
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
xlab = 'r/a';
ylab = 'S_{LH} (MW/m^3)';
xlim = [0,1];
ylim = NaN;
%
for il = 1:Nl-1,
    graph1D_jd(xrho{il},xP{il},0,0,'','','',NaN,xlim,ylim,style,marker,color{il},width2,siz);
end
graph1D_jd(xrho{Nl},xP{Nl},0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color{Nl},width2,siz,gca,red,lspace,bspace);
%grid off
set(gca,'xtick',[0:0.2:1])
%
figure(2);clf
%
xlab = 'r/a';
ylab = 'J_{LH} (MA/m^2)';
xlim = [0,1];
ylim = NaN;
%
for il = 1:Nl-1,
    graph1D_jd(xrho{il},si*xJ{il},0,0,'','','',NaN,xlim,ylim,style,marker,color{il},width2,siz);
end
graph1D_jd(xrho{Nl},si*xJ{Nl},0,0,xlab,ylab,tit,leg_I,xlim,ylim,style,marker,color{Nl},width2,siz,gca,red,lspace,bspace);
%grid off
set(gca,'xtick',[0:0.2:1])
