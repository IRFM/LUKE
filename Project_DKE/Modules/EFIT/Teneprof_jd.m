function [prho,pTe,pne,pTi,pni] = Teneprof_jd(filename,display_mode,p_opt);
%
% This function reads the temperature and density parameters from text
% files in which the columns are respectively the radial position r/a, Te,
% ne, Ti and ni
%
% by J. Decker (jodecke@alum.mit.edu) 11/01/04
%
[prho,pTe,pne,pTi,pni] = textread(filename,'%n%n%n%n%n');
%
if display_mode >= 2,
    %
    style = '-';
    marker = '+';
    color = 'r';
    width = 2;
    siz = 20;
    red = 0.9;
    lspace = 0.7;
    bspace = 0.6;
    tit = [filename];
    %
    figure(7),clf
    %
    xlab = 'r/a';
    ylab = 'T_e (keV)';
    xlim = [0,1];
    ylim = NaN;
    %
    graph1D_jd(prho,pTe/1e3,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[filename,'_Te_rho']);
    %
    figure(8),clf
    %
    ylab = 'n_e (\times 10^{19} m^{-3})';
    %
    graph1D_jd(prho,pne/1e19,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[filename,'_ne_rho']);
    %
    figure(9),clf
    %
    ylab = 'T_i (keV)';
    %
    graph1D_jd(prho,pTi/1e3,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[filename,'_Ti_rho']);
    %
    figure(10),clf
    %
    ylab = 'n_i (\times 10^{19} m^{-3})';
    %
    graph1D_jd(prho,pni/1e19,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[filename,'_ni_rho']);
    %
 end








