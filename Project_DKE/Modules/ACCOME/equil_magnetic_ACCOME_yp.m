function [equil_magnetic,prho,psin] = equil_magnetic_ACCOME_yp(filename,jbdirections,display_mode,p_opt,dispname,savename)
%
% This function reads and returns the magnetic equilibrium parameters from files created by ACCOME or EQDSK for the COMPASS czech tokamak
%
%	INPUTS:
%
%		- filename: equilibrium data and save name
%       - jbdirections: current and toroidal B-fields directions (jbdirections.Ip, jbdirections.Bt = 'clockwise' or 'anti-clockwise')
%           default: empty
%		- display_mode: option for figure display
%		- p_opt: option for printing
%
%	OUTPUTS:
%
%		- equil_magnetic: magnetic equilibrium [struct]
%       - prho: normalized minor radius [1,nr]
%		- psin: normalized poloidal flux [1,nr]
%
% by Y. Peysson (yves.peysson@cea.fr, CEA/IRFM) and J. Decker (joan.decker@cea.fr, CEA/IRFM)
%
if nargin < 6,
    dispname = filename;
end
%
if nargin < 5,
    dispname = filename;
end
%
if nargin < 4,
    p_opt = -1;
end
%
if nargin < 3,
    display_mode = 0;
end
%
if nargin < 2,
    jbdirections = [];
end
%
method = 'spline';%'linear';
nt = 65;
%
% Reads ACCOME data
%
if exist([filename,'.bfield'],'file'),
    disp(' ---> ACCOME toroidal MHD equilibrium file format found.');
    [x,y,xypsin,psia,rpsin,xyBPHI,xyBR,xyBZ,Rp,Zp] = accome_yp([filename,'.bfield'],display_mode,p_opt,dispname,savename);
elseif exist([filename,'.eqdsk'],'file'),
    disp(' ---> EQDSK toroidal MHD equilibrium file format found.');
    [x,y,xypsin,psia,rpsin,rF,rp,rq,Rp,Zp,Ip,Rv,Zv,Bv,rFdFdpsi,rdpdpsi] = eqdsk_jd([filename,'.eqdsk'],display_mode,p_opt,dispname,savename);
else
    error(' ---> Unknown toroidal MHD equilibrium file format found.')
end
%
if ~isempty(jbdirections),
    %
    if strcmp(jbdirections.Ip,'clockwise')
        if psia > 0,
            if exist('xyBR','var') && exist('xyBZ','var')
                if xyBR(end,end-1) < 0 && xyBZ(end,end-1) > 0
                    disp(' ---> The input magnetic equilibrium is consistent with Ip clockwise: LUKE signs convention)')
                else
                    error('Signs of psia, xyBR, xyBZ in the input magnetic equilibrium are inconsistent')
                end
            end 
        else
           psia = -psia; 
           disp(' ---> WARNING: psia positive enforced, Ip positive enforced (clockwise: LUKE signs convention)') 
            if exist('xyBR','var') && exist('xyBZ','var')
                if xyBR(end,end-1) > 0 && xyBZ(end,end-1) < 0
                    xyBR = - xyBR;
                    xyBZ = - xyBZ;
                else
                    error('Signs of psia, xyBR, xyBZ in the input magnetic equilibrium are inconsistent')
                end
            end
        end
    else
        if psia < 0,
            if exist('xyBR','var') && exist('xyBZ','var')
                if xyBR(end,end-1) > 0 && xyBZ(end,end-1) < 0
                    disp(' ---> The input magnetic equilibrium is consistent with Ip anti-clockwise: LUKE signs convention)')
                else
                    error('Signs of psia, xyBR, xyBZ in the input magnetic equilibrium are inconsistent')
                end
            end 
        else
           psia = -psia; 
           disp(' ---> WARNING: psia negtaive enforced, Ip negative enforced (counter-clockwise: LUKE signs convention)') 
            if exist('xyBR','var') && exist('xyBZ','var')
                if xyBR(end,end-1) < 0 && xyBZ(end,end-1) > 0
                    xyBR = - xyBR;
                    xyBZ = - xyBZ;
                else
                    error('Signs of psia, xyBR, xyBZ in the input magnetic equilibrium are inconsistent')
                end
            end
        end     
    end
    %
    if exist('Ip','var'),Ip = abs(Ip)*sign(psia);end
    %
    if strcmp(jbdirections.Bt,'clockwise'),
        disp(' ---> WARNING: BPHI positive enforced (clockwise: LUKE signs convention)')
        if exist('xyBPHI','var'), xyBPHI = abs(xyBPHI);end
        if exist('rF','var'),rF = abs(rF);end 
    else
        disp(' ---> WARNING: BPHI negative enforced (counter-clockwise: LUKE signs convention)')
        if exist('xyBPHI','var'), xyBPHI = -abs(xyBPHI);end
        if exist('rF','var'),rF = -abs(rF);end
    end
    %
else
	disp(' ---> WARNING: LUKE signs conventions not enforced for Ip and Bt, check carefully the data consistency in ''equil'' structure.')
end
%
% Transforms on a (psi,theta) grid
%
[ptx,pty,ptdpsindx,ptdpsindy,psin,theta] = rz2pt_jd(x,y,xypsin,rpsin,nt,method,display_mode,p_opt,savename);
%
if exist('xyBPHI','var');
    ptBPHI = griddata(x,y,xyBPHI',ptx,pty);
end
%
np = length(psin);
ap = ptx(np,1);%Plasma minor radius on the LFS midplane
psi_apRp = psin*psia*ap/Rp;%The poloidal flux coordinate is normalized by the aspect ratio 
ptR = Rp + ptx;
%
% Note that in DKE we have B = F.gradphi + gradphi x gradpsi.
%
%WARNING: not very accurate because psi grid provided by ACCOME seems to be noisy in the vicinity of the plasma center
%
if ~exist('xyBR','var') || ~exist('xyBZ','var') || isempty(xyBR) || isempty(xyBZ),
    %
	ptBx = -ptdpsindy*psia./ptR;
	ptBy = +ptdpsindx*psia./ptR;
    %
    ptF = repmat(rF.',[1,nt]);
    ptBPHI = ptF./ptR;
    %
    if exist([filename,'.bfield'],'file'),
        disp('***********************************************************************************************************');
        disp('WARNING: The BR and BZ magnetic field components are not given explicitely by ACCOME (not in the source file)');
        disp('         BR and BZ are calculated from the derivatives of the poloidal magnetic flux.');
        disp('         BR and BZ are likely not very accurate in the vicinity of the magnetic axis.');
        disp('         It is recommanded to re-create if possible an ACCOME source file for LUKE.');
        disp('***********************************************************************************************************');
    end
else
    ptBx = griddata(x,y,xyBR',ptx,pty);
	ptBy = griddata(x,y,xyBZ',ptx,pty);
end
%
ptBP = sqrt(ptBx.^2 +ptBy.^2);
ptB = sqrt(ptBP.^2 + ptBPHI.^2);
%
prho = ptx(:,1).'/ap;
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
    figure('Name','Poloidal and toroidal magnetic fields'),clf
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
%
    figure('Name','Total magnetic fields'),clf
    graph1D_jd(theta,ptB(2,:),0,0,'','','',NaN,'','',style,marker,'b',width);hold on
    plot(theta,ptB([2:end],:))
    legend(['r/a = ',num2str(prho(2))])
    axis([0,2*pi,0,ceil(max(max(ptB([2:end],:)))*10)/10])
    xlabel('\theta (rd)'),ylabel('B(T)'),title([dispname])
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
equil_magnetic.psi_apRp = psi_apRp;
equil_magnetic.theta = theta;
equil_magnetic.ptx = ptx;
equil_magnetic.pty = pty;
equil_magnetic.ptBx = ptBx;
equil_magnetic.ptBy = ptBy;
equil_magnetic.ptBPHI = ptBPHI;
equil_magnetic.Rp = Rp;
equil_magnetic.Zp = Zp;
%
if exist([filename,'.eqdsk'],'file'),
    equil_magnetic.eqdsk.x = x;
    equil_magnetic.eqdsk.y = y;
    equil_magnetic.eqdsk.xypsin = xypsin;
    equil_magnetic.eqdsk.psia = psia;
    equil_magnetic.eqdsk.psin = psin;
    equil_magnetic.eqdsk.pF = rF;
    equil_magnetic.eqdsk.pp = rp;
    equil_magnetic.eqdsk.pq = rq;
    equil_magnetic.eqdsk.Rp = Rp;
    equil_magnetic.eqdsk.Zp = Zp;  
    equil_magnetic.eqdsk.Ip = Ip;  
    equil_magnetic.eqdsk.Rv = Rv;  
    equil_magnetic.eqdsk.Zv = Zv;  
    equil_magnetic.eqdsk.Bv = Bv;  
    equil_magnetic.eqdsk.pFdFdpsi = rFdFdpsi;  
    equil_magnetic.eqdsk.pdpdpsi = rdpdpsi;  
end
%
