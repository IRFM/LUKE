function equil_EFIT_jd(filename,type,display_mode,p_opt,dispname)
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
if nargin < 5
    dispname = filename;
end
method = 'spline';
np = 101;
nt = 65;
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha] = pc_dke_yp;
%
% Reads EFIT eqdsk data
%
efitname = [filename,'.efit'];
[rR,zZ,rzpsin,psia,xpsin,xF,xp,xq,Rv,Zv,Bv,Rp,Zp,Ip] = eqdsk_jd(efitname,display_mode,p_opt,dispname);
%
% Reads EFIT numerical text T and n data
%
[yrho,yTe,yne,yTi,yni] = Teneprof_jd(filename,type,display_mode,p_opt,dispname);
%
[R,Z,dpsindr,dpsindz,ppsin,theta] = rz2pt_jd(rR,zZ,Rp,Zp,rzpsin,np,nt,method,display_mode,p_opt,filename);
%
ppsi = ppsin*psia;
BR = dpsindz*psia./R;
BZ = -dpsindr*psia./R;
%
pF = interp1(xpsin,xF,ppsin,method);
F = repmat(pF',[1,nt]);
%
BPHI = F./R;
%
zZi = [1,1,1,6];
zmi = [1,2,3,12];
fi = [0,1,0];
%
%ftra = [];%Approximate trapped fraction
%HXR = NaN;
%
Rmax = R(np,1);%Major radius where the last close flux-surface crosses the LFS midplane
ap =  Rmax - Rp;%Plasma minor radius on the LFS midplane 
prho = (R(:,1)' - Rp)/ap;
%
if type == 0 | type == 2,
    pTe = interp1(yrho,yTe,prho,method)/1e3;
    pne = interp1(yrho,yne,prho,method);
    pTi = interp1(yrho,yTi,prho,method)/1e3;
    pni = interp1(yrho,yni,prho,method);
    %
    Zimp = zZi(4);
    %
    pnimp = (pne-pni)/(Zimp-1);
    pnH = pni-pnimp;
    %
    pzni = [fi'*pnH;pnimp];
    pzTi = ones(4,1)*pTi;
    %
elseif type == 1,%yrho = sqrt(psin)
    pTe = interp1(yrho.^2,yTe,ppsin,method)/1e3;
    pne = interp1(yrho.^2,yne,ppsin,method);
    pzTi = interp1(yrho.^2,yTi',ppsin,method)'/1e3;
    pzni = interp1(yrho.^2,yni',ppsin,method)';    
end
%
if display_mode == 2 
%
    rx = [-fliplr(prho(2:np)),prho];
    rBR = [fliplr(BR(2:np,(nt+1)/2)'),BR(:,1)'];
    rBZ = [fliplr(BZ(2:np,(nt+1)/2)'),BZ(:,1)'];
    rBPHI = [fliplr(BPHI(2:np,(nt+1)/2)'),BPHI(:,1)'];
    rBP = sqrt(rBR.^2 + rBZ.^2);
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
    graph1D_jd(rx,rBPHI,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,red,lspace,bspace);
    graph1D_jd(rx,rBP,0,0,'','','',NaN,xlim,ylim,style,marker,color2,width);
    graph1D_jd(rx,rB,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color3,width);
    print_jd(p_opt,[filename,'_Bfield']);
end
%
%
%savename = ['EQUIL_',filename,'.mat'];
%
%eval(['save ',savename,' ppsi theta R Z BR BZ BPHI pTe pne pzTi pzni zZi zmi ftra HXR'])
%
% new equil structure
%
equil.id = filename;
equil.zZi = zZi;
equil.zmi = zmi;
equil.theta = theta;
equil.pTe = pTe;
equil.pne = pne;
equil.pzTi = pzTi;
equil.pzni = pzni;
equil.R = R;
equil.Z = Z;
equil.ppsi = ppsi;
equil.BR = BR;
equil.BZ = BZ;
equil.BPHI = BPHI;
%
savename = ['EQUIL_',filename,'.mat'];
eval(['save ',savename,' equil'])
%
return
%
% Verify consistency
%
yp = (yTe.*yne + yTi.*yni)*qe;%pressure from Tene data
%
pp = interp1(xpsin,xp,ppsin,method);
figure(13),clf
%
xlab = 'r/a';
ylab = 'p';
xlim = [0,1];
ylim = NaN;
leg = ['Tene';'EFIT'];
%
graph1D_jd(yrho,yp/1e4,0,0,'','','',NaN,xlim,ylim,style,marker,color1,width,siz,gca,red,lspace,bspace);
graph1D_jd(prho,pp/1e4,0,0,xlab,ylab,tit,leg,xlim,ylim,style,marker,color2,width,siz);
set(gca,'XTick',[0:0.2:1]);
print_jd(p_opt,[filename,'_p_comp']);



