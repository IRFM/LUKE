function [prho,pTe,pne,pTi,pni,zZi,zmi,fi] = Teneprof_jd(filename,type,display_mode,p_opt,dispname,savename);
%
% This function reads the temperature and density parameters from text or
% binary files in which the columns are respectively the radial position r/a, Te,
% ne, Ti and ni
%
% by J. Decker (jodecke@alum.mit.edu) 11/01/04
%
if nargin < 6
    savename = filename;
end
if nargin < 5
    dispname = filename;
end
if type == 0%ascii
    [prho,pTe,pne,pTi,pni] = textread(filename,'%n%n%n%n%n');
elseif type == 1%.mat
    eval(['load ',filename,' prho pTe pne pTi pni']);
    zZi = [1,1,1,6];
    zmi = [1,2,3,12];
elseif type == 2%ascii - 203040
    [prho,pTi,pTe,pni,pne] = textread(filename,'%n%n%n%n%n');
    zZi = [1,1,1,6];
    zmi = [1,2,3,12];
elseif type == 3%ascii formatted (CMOD)
    pne = [];
    pTe = [];
    fid = fopen(filename);
    s = 0;
    t = 0;
    while isempty(s) | s ~= -1,
        s = fgetl(fid);
        if isempty(findstr(s,'genray')),
            continue
        else
            t = t + 1;
            s = fgetl(fid);
            s = fgetl(fid);
            while isempty(s) | s ~= -1,
                d = sscanf(s,'%f');
                if isempty(d),
                    break
                elseif t == 1,
                    pne = [pne,d(1)];
                elseif t == 2, 
                    pTe = [pTe,d(1)];                    
                end
                s = fgetl(fid);
            end
        end
    end
    
    pne = pne*1e19;
    pTe = pTe*1e3;
    pTi = pTe*2/3;
    pni = pne;
    prho = linspace(0,1,length(pne));
    zZi = [1,1,1,6];
    zmi = [1,2,3,12];    
    fclose(fid);
elseif type == 4%ascii formatted (ITER)
    prho = [];
    pne = [];
    pTe = [];
    pTi = [];
    pni = [];
    zZi = [];
    zmi = [];
    fid = fopen(filename);
    s = fgetl(fid);
    while ~isempty(s),
        d = sscanf(s,'%f %f %f %f');
        prho = [prho,d(1)];        
        pne = [pne,d(2)];
        pTe = [pTe,d(3)];
        pTi = [pTi,d(4)];
        s = fgetl(fid);
    end
    s = fgetl(fid);
    while s ~= -1,
        d = sscanf(s,'%f %f %f');
        zZi = [zZi,d(1)];
        zmi = [zmi,d(2)];
        pni = [pni;pne*d(3)];
        s = fgetl(fid);
    end
    pne = pne*1e19;
    pni = pni*1e19;
    pTe = pTe*1e3;
    pTi = pTi*1e3;
    fclose(fid);
    
    fi = [0,0.5,0.5];
end
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
    tit = [dispname];
    %
    figure(8),clf
    %
    if type == 0,
        xlab = '\rho';
    else
        xlab = '\psi_n^{1/2}';
    end    
    ylab = 'T_e (keV)';
    xlim = [0,1];
    ylim = NaN;
    %
    graph1D_jd(prho,pTe/1e3,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_Te_rho']);
    %
    figure(9),clf
    %
    ylab = 'n_e (\times 10^{19} m^{-3})';
    %
    graph1D_jd(prho,pne/1e19,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_ne_rho']);
    %
    figure(10),clf
    %
    ylab = 'T_i (keV)';
    %
    graph1D_jd(prho,pTi/1e3,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_Ti_rho']);
    %
    figure(11),clf
    %
    ylab = 'n_i (\times 10^{19} m^{-3})';
    %
    graph1D_jd(prho,pni/1e19,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_ni_rho']);
    %
 end








