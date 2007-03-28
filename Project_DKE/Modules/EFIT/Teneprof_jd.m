function [prho,pspsin,pspsinT,pTe,pne,pzTi,pzni,zZi,zmi] = Teneprof_jd(filename,type,display_mode,p_opt,Zeff,dispname,savename);
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
%
prho = [];
pspsin = [];
pspsinT = [];
%
if type == 0,%ascii
    [prho,pTe,pne,pTi,pni] = textread(filename,'%n%n%n%n%n');
elseif type == 0.1,
    [psi,pTe,pne,pZeff] = textread(filename,'%n%n%n%n');    
elseif type == 1,%.mat
    eval(['load -mat ',filename,' prho pTe pne pTi Zeff']);
elseif type == 2,%ascii - 203040
    [prho,pTi,pTe,pni,pne] = textread(filename,'%n%n%n%n%n');
elseif type == 3,%ascii formatted (CMOD)
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
    fclose(fid);
    clear fid s t d
    %
    pne = pne*1e19;
    pTi = pTe*2/3;
    pspsinT = linspace(0,1,length(pne));
    %
elseif type == 3.1,%ascii formatted (CMOD)
    pne = [];
    pTe = [];
    fid = fopen(filename);
    s = 0;
    while isempty(s) | s ~= -1,
        s = fgetl(fid);
        if isempty(findstr(s,'Density')),
            continue
        else
            s = fgetl(fid);
            s = fgetl(fid);
            while ~isempty(s),
                d = sscanf(s,'%f').';
                pne = [pne,d];
                s = fgetl(fid);
            end
            break
        end
    end
    while isempty(s) | s ~= -1,
        s = fgetl(fid);
        if isempty(findstr(s,'genray')),
            continue
        else
            s = fgetl(fid);
            s = fgetl(fid);
            while s ~= -1,
                d = sscanf(s,'%f');
                pTe = [pTe,d(1)];                    
                s = fgetl(fid);
            end
            break
        end
    end
    fclose(fid);
    clear fid s d
    %
    pTi = pTe*2/3;
    pspsinT = linspace(0,1,length(pne));
    %
elseif type == 4,%ascii formatted (ITER)
    pspsinT = [];
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
        pspsinT = [pspsinT,d(1)];        
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
        pzni = [pni;pne*d(3)];
        s = fgetl(fid);
    end
    fclose(fid);
    clear fid s d
    %
    pne = pne*1e19;
    pzni = pni*1e19;
    pTe = pTe;
    pTi = pTi;
    %
    clear pzni % ion densities recalculated from Zeff
    fi = [0,0.5,0.5];
end
%
if type < 4,
    %
    zZi = [1,1,1,6];
    zmi = [1,2,3,12];
    fi = [0,1,0];
    %
end
%
nz = length(zZi);
%
if type == 0 | type == 2,
    %
    pTe = pTe/1e3;
    pTi = pTi/1e3;
    %
    Zimp = zZi(4);
    %
    pnimp = (pne-pni)/(Zimp-1);
    pnH = pni-pnimp;
    %
    pzni = [fi'*pnH;pnimp];
    pzTi = ones(nz,1)*pTi;
    %
elseif type == 0.1,
    %
    fi = [0,0.5,0.5];
    %
    pTe = pTe.';
    pTi = pTe;
    pne = pne.'*1e19;
    pZeff = pZeff.';
    psi = psi.';
    %
    Zimp = zZi(4);
    %
    pnH = pne.*(zZi(4) - pZeff)/(zZi(4) - 1);
    pnZ = pne.*(pZeff - 1)/zZi(4)/(zZi(4) - 1);
    pzni = [fi.'*pnH;pnZ];
    pzTi = ones(nz,1)*pTi;
    %
    pspsin = sqrt(psi);
    %
elseif type == 1,
    %
    pTe = pTe/1e3;
    pTi = pTi/1e3;
    %
    %pzni = pni;
    pzTi = pTi;
    %
    pspsin = prho;
    prho = [];
    %
end
if type == 1 | type>= 3,
    %
    pnH = pne*(zZi(4) - Zeff)/(zZi(4) - 1);
    pnZ = pne*(Zeff - 1)/zZi(4)/(zZi(4) - 1);
    pzni = [fi.'*pnH;pnZ];
    pzTi = ones(nz,1)*pTi;
    %
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
    if ~isempty(prho),
        xlab = '\rho';
        pdisp = prho;
    elseif ~isempty(pspsin)
        xlab = '\psi_n^{1/2}';
        pdisp = pspsin;
    elseif ~isempty(pspsinT)
        xlab = '\psi_{nT}^{1/2}';
        pdisp = pspsinT;
    end        
    %
    figure(8),clf
    %
    ylab = 'T_e (keV)';
    xlim = [0,1];
    ylim = NaN;
    %
    graph1D_jd(pdisp,pTe,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_Te_rho']);
    %
    figure(9),clf
    %
    ylab = 'n_e (\times 10^{19} m^{-3})';
    %
    graph1D_jd(pdisp,pne/1e19,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_ne_rho']);
    %
    figure(10),clf
    %
    ylab = 'T_i (keV)';
    %
    graph1D_jd(pdisp,pzTi,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_Ti_rho']);
    %
    figure(11),clf
    %
    ylab = 'n_i (\times 10^{19} m^{-3})';
    %
    graph1D_jd(pdisp,pzni/1e19,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color,width,siz,gca,red,lspace,bspace);
    set(gca,'XTick',[0:0.2:1]);
    set(gca,'ylim',[0,max(get(gca,'ylim'))])
    print_jd(p_opt,[savename,'_ni_rho']);
    %
 end








