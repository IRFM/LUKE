% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function aftime = fproc_runaway_time(alpha_list,frac_list,tn,trfrac,mksa,method,id_simul,p_opt,ylim,ytick,ylimsec,yticksec,ialpha_disp)
%
nalpha = length(alpha_list);
nfrac = length(frac_list);
%
aftime = NaN(nalpha,nfrac);
for ifrac = 1:nfrac,
    for ialpha = 1:nalpha,
        mask = ~isnan(trfrac(:,ialpha)) & ~isinf(trfrac(:,ialpha)) & diff([0;trfrac(:,ialpha)]) > 0;
        if sum(mask) < 2,
            continue
        else
            aftime(ialpha,ifrac) = interp1(trfrac(mask,ialpha),tn(mask),frac_list(ifrac),method);
        end
    end
end
%
figure(1),clf
%
xlab = 'E/E_c';
ylab = 't/\tau_c';
xlim = [0,max(alpha_list)];
tit = '';
siz = 20+14i;
colors = {'b',[0,0.5,0],'r'};
%
for ifrac = 1:nfrac-1,
    graph1D_jd(alpha_list,aftime(:,ifrac),0,1,'','','',NaN,xlim,ylim,'-','none',colors{1+rem(ifrac,length(colors))},0.5,siz);
    if ~isnan(ialpha_disp),
        text(alpha_list(ialpha_disp),aftime(ialpha_disp,ifrac),['n_r/n = 10^{',num2str(log10(frac_list(ifrac))),'}'],'fontsize',14);
    end
end
graph1D_jd(alpha_list,aftime(:,nfrac),0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none',colors{1+rem(nfrac,length(colors))},0.5,siz,gca,0.9,0.7,0.7);
if ~isnan(ialpha_disp),
    text(alpha_list(ialpha_disp),aftime(ialpha_disp,nfrac),['n_r/n = 10^{',num2str(log10(frac_list(nfrac))),'}'],'fontsize',14);
end
%
if ~isnan(ytick),
    set(gca,'ytick',ytick)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(2),clf
%
xlab = 'E/E_c';
ylab = 't (s)';
xlim = [0,max(alpha_list)];
tit = '';
siz = 20+14i;
colors = {'b',[0,0.5,0],'r'};
%
aftimesec = aftime/mksa.nhu_ref;
%
for ifrac = 1:nfrac-1,
    graph1D_jd(alpha_list,aftimesec(:,ifrac),0,1,'','','',NaN,xlim,ylimsec,'-','none',colors{1+rem(ifrac,length(colors))},0.5,siz);
    if ~isnan(ialpha_disp),
        text(alpha_list(ialpha_disp),aftimesec(ialpha_disp,ifrac),['n_r/n = 10^{',num2str(log10(frac_list(ifrac))),'}'],'fontsize',14);
    end
end
graph1D_jd(alpha_list,aftimesec(:,nfrac),0,1,xlab,ylab,tit,NaN,xlim,ylimsec,'-','none',colors{1+rem(nfrac,length(colors))},0.5,siz,gca,0.9,0.7,0.7);
if ~isnan(ialpha_disp),
    text(alpha_list(ialpha_disp),aftimesec(ialpha_disp,nfrac),['n_r/n = 10^{',num2str(log10(frac_list(nfrac))),'}'],'fontsize',14);
end
%
if ~isnan(yticksec),
    set(gca,'ytick',yticksec)
end
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(p_opt,['fig_',id_simul,'_norm'],'./figures',1)
print_jd(p_opt,['fig_',id_simul,'_sec'],'./figures',2)
%
