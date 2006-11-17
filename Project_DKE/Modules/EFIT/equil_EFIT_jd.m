function equil_EFIT_jd(filename,type,display_mode,p_opt,dispname,savename,Zeff)
%
% This function reads the equilibrium parameters from eqdsk files created
% by EFIT and saved in the formatted text file "filename.efit", as well as
% the temperature and density parameters from the (fully numerical) text
% file "filename". It creates a DKE equilibrium file "EQUIL_filename.mat"
%
%	INPUTS:
%
%		- filename: equilibrium data and save name
%		- type: profile data type:(0) for ascii; (1) for .mat
%		- display_mode: option for figure display
%		- p_opt: option for printing
%
% by J. Decker (jodecke@alum.mit.edu) 11/01/04
%
if nargin < 7,% & type == 3
    Zeff = NaN;
end
if nargin < 6,
    savename = filename;
end
if nargin < 5,
    dispname = filename;
end
method = 'spline';%'linear';
nt = 65;
%
% Reads EFIT eqdsk data
%
efitname = [filename,'.efit'];
[x,y,xypsin,psia,psin,pF,pp,pq,Rp,Zp] = eqdsk_jd(efitname,display_mode,p_opt,dispname,savename);
%
% Reads EFIT numerical text T and n data
%
profname = [filename,'.prof'];
[yrho,yspsin,yspsinT,yTe,yne,yzTi,yzni,zZi,zmi] = Teneprof_jd(profname,type,display_mode,p_opt,Zeff,dispname,savename);
%
[ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,psin,nt,method,display_mode,p_opt,savename);
%
np = length(psin);
ap = ptx(np,1);%Plasma minor radius on the LFS midplane
psi_apRp = psin*psia*ap/Rp;%The poloidal flux coordinate is normalized by the aspect ratio 
ptR = Rp + ptx;
ptBx = ptdpsindy*psia./ptR;
ptBy = -ptdpsindx*psia./ptR;
%
% Warning: The PHI direction in the equil structure is such that
% (x,y,phi) and (r,theta,phi) are right-handed systems. This is likely
% the opposite direction from the EFIT PHI coordinate. However, 
% because EFIT does not give any indication concerning the direction
% of the toroidal current (as psi is always minimum on the axis in EFIT)
% it is necessary to check both the direction of BPHI and the sign of 
% psia. These can be adjusted retrospectively in the equil structure.
%
ptF = repmat(pF.',[1,nt]);
%
ptBPHI = ptF./ptR;
%
prho = ptx(:,1).'/ap;
%
pq_h = (pq(1:end-1) + pq(2:end))/2;
pdpsin = diff(psin);
ppsiT = [0,cumsum(pq_h.*pdpsin)];
pspsinT = sqrt(ppsiT/ppsiT(end));
%
pspsin = sqrt(psin);
%
if ~isempty(yrho),% profiles given on rho grid
    pTe = interp1(yrho,yTe,prho,method);
    pne = interp1(yrho,yne,prho,method);
    pzTi = interp1(yrho,yzTi.',prho,method).';
    pzni = interp1(yrho,yzni.',prho,method).';
    %
elseif ~isempty(yspsin),% profiles given on poloidal flux based grid
    pTe = interp1(yspsin,yTe,pspsin,method);
    pne = interp1(yspsin,yne,pspsin,method);
    pzTi = interp1(yspsin,yzTi.',pspsin,method).';
    pzni = interp1(yspsin,yzni.',pspsin,method).'; 
    %
elseif ~isempty(yspsinT),% profiles given on toroidal flux based grid
    pTe = interp1(yspsinT,yTe,pspsinT,method);
    pne = interp1(yspsinT,yne,pspsinT,method);
    pzTi = interp1(yspsinT,yzTi.',pspsinT,method).';
    pzni = interp1(yspsinT,yzni.',pspsinT,method).';    
    %
end
%
if display_mode == 2, 
%
    rx = [-fliplr(prho(2:np)),prho];
    rBx = [fliplr(ptBx(2:np,(nt+1)/2)'),ptBx(:,1)'];
    rBy = [fliplr(ptBy(2:np,(nt+1)/2)'),ptBy(:,1)'];
    rBPHI = [fliplr(ptBPHI(2:np,(nt+1)/2)'),ptBPHI(:,1)'];
    rBP = sqrt(rBx.^2 + rBy.^2);
    rB = sqrt(rBP.^2 + rBPHI.^2);
%
    style = '-';
    marker = 'none';
    color1 = 'r';
    color2 = 'b';
    color3 = 'k';
    width = 2;
    siz = 20;
    red = 0.9;
    lspace = 0.7;
    bspace = 0.6;
    tit = [dispname];
    %
    figure(12),clf
    %
    xlab = 'r/a';
    ylab = 'B(T)';
    xlim = [-1,1];
    ylim = NaN;
    leg = ['B_T';'B_P';'B  '];
%
    graph1D_jd(rx,abs(rBPHI),0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,red,lspace,bspace);
    graph1D_jd(rx,rBP,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width);
    graph1D_jd(rx,rB,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width);
    print_jd(p_opt,[savename,'_Bfield']);
end
%
ptx(:,65) = ptx(:,1);
pty(:,65) = pty(:,1);
ptBx(:,65) = ptBx(:,1);
ptBy(:,65) = ptBy(:,1);
ptBPHI(:,65) = ptBPHI(:,1);
%
% equil structure
%
equil.id = savename;
equil.zZi = zZi;
equil.zmi = zmi;
equil.psi_apRp = psi_apRp;
equil.theta = theta;
equil.pTe = pTe;
equil.pne = pne;
equil.pzTi = pzTi;
equil.pzni = pzni;
equil.ptx = ptx;
equil.pty = pty;
equil.ptBx = ptBx;
equil.ptBy = ptBy;
equil.ptBPHI = ptBPHI;
equil.Rp = Rp;
equil.Zp = Zp;
%
eval(['save EQUIL_',savename,' equil'])
%
% Verify consistency on pressure between profiles and EFIT
%
if display_mode == 2, 
    qe = pc_dke_yp;
    %
    yp = (yTe.*yne + sum(yzTi.*yzni,1))*qe*1e3;%pressure from Tene data
    %
    figure(13),clf
    %
    if ~isempty(yrho),
        xlab = '\rho';
        pdisp = prho;
        ydisp = yrho;
    elseif ~isempty(yspsin)
        xlab = '\psi_n^{1/2}';
        pdisp = pspsin;
        ydisp = yspsin;
    elseif ~isempty(yspsinT)
        xlab = '\psi_{nT}^{1/2}';
        pdisp = pspsinT;
        ydisp = yspsinT;
    end  
    %
    ylab = 'p (hPa)';
    xlim = [0,1];
    ylim = NaN;
    leg = ['T_en_e + T_in_i';
           'EFIT           '];
    %
    graph1D_jd(ydisp,yp/1e5,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,red,lspace,bspace);
    graph1D_jd(pdisp,pp/1e5,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color2,width,siz);
    set(gca,'XTick',[0:0.2:1]);
    print_jd(p_opt,[savename,'_p_comp']);
end



