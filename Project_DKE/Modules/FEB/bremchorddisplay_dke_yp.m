function [] = bremchorddisplay_dke_yp(Zbremchord,chordnum_disp,axs,p_opt,filename,font)
%
% This function draws chord positions for bremsstrahlung tomography
%
% INPUTS
%
%       - Zbremchord: Bremsstrahlung diagnostic arrangement data strcuture
%       
% OUTPUTS: none
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
if nargin < 6, 
    font = struct;
end
if nargin < 5, 
    filename = '';
end
if nargin < 4, 
    p_opt = -1;
end
if nargin < 3, 
    axs = [];
end
if nargin < 2, 
    chordnum_disp = [];
end
if nargin < 1, 
    error('Not enough input argument in bremchorddisplay_dke_yp');
end
%
if iscell(Zbremchord),% multiple cameras, iluke
    %
    opt_txt = false;
    %
    ncams = length(Zbremchord);
    sR = cell(1,ncams);
    sZ = cell(1,ncams);
    sphi = cell(1,ncams);    
    for icam = 1:ncams,
        sR{icam} = Zbremchord{icam}.sR;
        sZ{icam} = Zbremchord{icam}.sZ;
        sphi{icam} = Zbremchord{icam}.sphi;
    end
    %
    ptrho = Zbremchord{1}.ptrho;
    xq = Zbremchord{1}.xq;
    xpsin_S = Zbremchord{1}.xpsin_S;
    RR_pol = Zbremchord{1}.RR_pol;
    ZZ_pol = Zbremchord{1}.ZZ_pol;
    HHR_pol = Zbremchord{1}.HHR_pol;
    HHZ_pol = Zbremchord{1}.HHZ_pol;
    VVR_pol = Zbremchord{1}.VVR_pol;
    VVZ_pol = Zbremchord{1}.VVZ_pol;
    ptR = Zbremchord{1}.ptR;
    ptZ = Zbremchord{1}.ptZ;
    BR_pol = Zbremchord{1}.BR_pol;
    BZ_pol = Zbremchord{1}.BZ_pol;
    X_mfl_lcs = Zbremchord{1}.X_mfl_lcs;
    Y_mfl_lcs = Zbremchord{1}.Y_mfl_lcs;
    Z_mfl_lcs = Zbremchord{1}.Z_mfl_lcs;
    BX_mfl_lcs = Zbremchord{1}.BX_mfl_lcs;
    BY_mfl_lcs = Zbremchord{1}.BY_mfl_lcs;
    Ipdir_mfl_lcs = Zbremchord{1}.Ipdir_mfl_lcs;
    Ipdkedir_mfl_lcs = Zbremchord{1}.Ipdkedir_mfl_lcs;
    XX_tor_min = Zbremchord{1}.XX_tor_min;
    YY_tor_min = Zbremchord{1}.YY_tor_min;
    XX_tor = Zbremchord{1}.XX_tor;
    YY_tor = Zbremchord{1}.YY_tor;
    XX_tor_max = Zbremchord{1}.XX_tor_max;
    YY_tor_max = Zbremchord{1}.YY_tor_max;
    VVX = Zbremchord{1}.VVX;
    VVY = Zbremchord{1}.VVY;
    HHX = Zbremchord{1}.HHX;
    HHY = Zbremchord{1}.HHY;
    %
else% unique camera, irunhxr_jd
    %
    opt_txt = true;
    %
    ncams = 1;
    sR = {Zbremchord.sR};
    sZ = {Zbremchord.sZ};
    sphi = {Zbremchord.sphi};
    %
    ptrho = Zbremchord.ptrho;
    xq = Zbremchord.xq;
    xpsin_S = Zbremchord.xpsin_S;
    RR_pol = Zbremchord.RR_pol;
    ZZ_pol = Zbremchord.ZZ_pol;
    HHR_pol = Zbremchord.HHR_pol;
    HHZ_pol = Zbremchord.HHZ_pol;
    VVR_pol = Zbremchord.VVR_pol;
    VVZ_pol = Zbremchord.VVZ_pol;
    ptR = Zbremchord.ptR;
    ptZ = Zbremchord.ptZ;
    BR_pol = Zbremchord.BR_pol;
    BZ_pol = Zbremchord.BZ_pol;
    X_mfl_lcs = Zbremchord.X_mfl_lcs;
    Y_mfl_lcs = Zbremchord.Y_mfl_lcs;
    Z_mfl_lcs = Zbremchord.Z_mfl_lcs;
    BX_mfl_lcs = Zbremchord.BX_mfl_lcs;
    BY_mfl_lcs = Zbremchord.BY_mfl_lcs;
    Ipdir_mfl_lcs = Zbremchord.Ipdir_mfl_lcs;
    Ipdkedir_mfl_lcs = Zbremchord.Ipdkedir_mfl_lcs;
    XX_tor_min = Zbremchord.XX_tor_min;
    YY_tor_min = Zbremchord.YY_tor_min;
    XX_tor = Zbremchord.XX_tor;
    YY_tor = Zbremchord.YY_tor;
    XX_tor_max = Zbremchord.XX_tor_max;
    YY_tor_max = Zbremchord.YY_tor_max;
    VVX = Zbremchord.VVX;
    VVY = Zbremchord.VVY;
    HHX = Zbremchord.HHX;
    HHY = Zbremchord.HHY;
    %
end
%
if isempty(axs),
    red = 0.9;
    lspace = 0.7;
    bspace = 0.5;
    %
    figure('Name','Safety factor');
    ax = gca;
    %
    [ax] = graph1D_jd(ptrho,xq,0,0,'Normalized radius {\rho}','q','Safety factor',NaN,'','','-','none','b',2,font,ax,red,lspace,bspace);drawnow;%Safety factor profile
    print_jd(p_opt,[filename,'_SafetyFactor']);
else
    red = 1;
    lspace = NaN;
    bspace = NaN;
end
%
if isempty(axs),
    figure('Name','Bremsstrahlung tomography (Poloidal view)');
    ax = gca;
    tit = 'Bremsstrahlung tomography (Poloidal view)';
else
    ax = axs(1);
    tit = '';
end
%
for icam = 1:ncams,
    [ax] = graph1D_jd(sR{icam},sZ{icam},0,0,'','','',NaN,'','','-','none','b',2,font,ax);%Poloidal plot
    if ~isempty(chordnum_disp) && ~isnan(chordnum_disp(icam)),
       [ax] = graph1D_jd(sR{icam}(:,chordnum_disp(icam)),sZ{icam}(:,chordnum_disp(icam)),0,0,'','','',NaN,'','','-','none','g',2,font,ax);%Poloidal plot
    end
end
if opt_txt,
    for ichord = 1:size(sR,2),
        if iscell(sR)
            sRc = sR{1}(~isnan(sR{1}(:,ichord)),ichord);
        else
            sRc = sR(~isnan(sR(:,ichord)),ichord);
        end
        if iscell(sZ)
            sZc = sZ{1}(~isnan(sZ{1}(:,ichord)),ichord);
        else
            sZc = sZ(~isnan(sZ(:,ichord)),ichord);
        end
       if ~isempty(sRc) && ~isempty(sZc)
          ht = text(sRc(end),sZc(end),['  #',int2str(ichord)]);set(ht,'fontsize',10);
       end
    end
end
if isempty(axs),
    for ir = 1:length(xpsin_S),
       [ax] = graph1D_jd(RR_pol(ir,:),ZZ_pol(ir,:),0,0,'','','',NaN,'','','-','none','r',1,font,ax);
    end
    graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','none','r',1);
    graph1D_jd(VVR_pol,VVZ_pol,0,0,'','','',NaN,'','','-.','none','r',1);
    graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','none','r',1);
    graph1D_jd(VVR_pol,VVZ_pol,0,0,'','','',NaN,'','','-.','none','r',1); 
    graph1D_jd(ptR,ptZ,0,0,'R (m)','Z (m)',tit,NaN,'','','-','none','r',1,font,ax,red,lspace,bspace);
else
    graph1D_jd(ptR.',ptZ.',0,0,'R (m)','Z (m)',tit,NaN,'','','-','none','r',1,font,ax,red,lspace,bspace);    
end
axis(ax,'equal');drawnow
print_jd(p_opt,[filename,'_PoloidalView']);
%
if isempty(axs),
    figure('Name','Poloidal field');
    quiver(RR_pol,ZZ_pol,BR_pol,BZ_pol);
    axis('equal');
    hold on
    graph1D_jd(ptR,ptZ,0,0,'','','',NaN,'','','-','none','c',1);
    graph1D_jd(HHR_pol,HHZ_pol,0,0,'','','',NaN,'','','-.','none','r',1);
    graph1D_jd(VVR_pol,VVZ_pol,0,0,'X=R (m)','Z (m)','B_{\theta} field (T)',NaN,'','','-.','none','r',1);
    hold off
    print_jd(p_opt,[filename,'_BthetaField']);
end
%
if isempty(axs),
    figure('Name','Bremsstrahlung tomography (Toroidal top view, Z = 0)');
    ax = gca;
    tit = 'Bremsstrahlung tomography (Poloidal view)';
    leg = 'B-field, (Ip: green, Ip-dke: magenta)';
    %
    h = quiver(X_mfl_lcs(1:40:end),Y_mfl_lcs(1:40:end),BX_mfl_lcs(1:40:end),BY_mfl_lcs(1:40:end),0.5);%Magnetic field line direction
    set(h,'Color','k');
    hold on
    sssB = sign(BY_mfl_lcs(1));%sign at phi = 0. if BPHI < 0, sssB < 0, and for BPHI > 0, sssB > 0
    sssIp = sign(Ipdir_mfl_lcs(1));
    sssIpdke = sign(Ipdkedir_mfl_lcs(1));
    h = quiver(X_mfl_lcs(20:40:end),Y_mfl_lcs(20:40:end),sssIp*sssB*BX_mfl_lcs(20:40:end),sssIp*sssB*BY_mfl_lcs(20:40:end),0.5);%Current direction on magnetic field line direction
    set(h,'Color','g');
    h = quiver(X_mfl_lcs(20:40:end),Y_mfl_lcs(20:40:end),sssIpdke*sssB*BX_mfl_lcs(20:40:end),sssIpdke*sssB*BY_mfl_lcs(20:40:end),0.3);%Current direction on magnetic field line direction
    set(h,'Color','m');
else
    ax = axs(2);
    tit = '';
    leg = NaN;
end
%
if isempty(axs),
    graph1D_jd(XX_tor_min,YY_tor_min,0,0,'','','',NaN,'','','-','none','r',2);
    graph1D_jd(XX_tor,YY_tor,0,0,'','','',NaN,'','','-.','none','r',2);
    graph1D_jd(XX_tor_max,YY_tor_max,0,0,'','','',NaN,'','','-','none','r',2);
    graph1D_jd(VVX,VVY,0,0,'','','',NaN,'','','-.','none','r',1);
    graph1D_jd(HHX,HHY,0,0,'','','',NaN,'','','-.','none','r',1);
    i_mfl_lcs = find(Z_mfl_lcs>=0);
    [ax] = graph1D_jd(X_mfl_lcs(1:3:end),Y_mfl_lcs(1:3:end),0,0,'','','',NaN,'','',':','none','k',1,font,ax);%Z < 0 
    [ax] = graph1D_jd(X_mfl_lcs(i_mfl_lcs(1:end-1)),Y_mfl_lcs(i_mfl_lcs(1:end-1)),0,0,'','','',NaN,'','','-','none','k',1,font,ax);%Z >= 0 
    [ax] = graph1D_jd(X_mfl_lcs(i_mfl_lcs(1)),Y_mfl_lcs(i_mfl_lcs(1)),0,0,'X (m)','Y (m)',tit,leg,'','','none','*','k',1,font,ax,red,lspace,bspace);%Z >= 0 
    set(ax,'YDir','rev');%Because the reference is indirect by definition
else
    phi = linspace(0,2*pi,1001);
    nr = size(ptR,1);
    for ir = 1:nr,
        Rmin = min(ptR(ir,:));
        Rmax = max(ptR(ir,:));
        %
        [ax] = graph1D_jd(Rmin*cos(phi),Rmin*sin(phi),0,0,'','','',NaN,'','','-','none','r',1,font,ax);
        if ir < nr,
            [ax] = graph1D_jd(Rmax*cos(phi),Rmax*sin(phi),0,0,'','','',NaN,'','','-','none','r',1,font,ax);
        else
            [ax] = graph1D_jd(Rmax*cos(phi),Rmax*sin(phi),0,0,'X (m)','Y (m)',tit,leg,'','','-','none','r',1,font,ax,red,lspace,bspace);
        end
    end
end
%
for icam = 1:ncams,
    ax = graph1D_jd(sR{icam}.*cos(sphi{icam}),sR{icam}.*sin(sphi{icam}),0,0,'','','',NaN,'','','-','none','b',2,font,ax);
    if ~isempty(chordnum_disp) && ~isnan(chordnum_disp(icam)),
       [ax] = graph1D_jd(sR{icam}(:,chordnum_disp(icam)).*cos(sphi{icam}(:,chordnum_disp(icam))),sR{icam}(:,chordnum_disp(icam)).*sin(sphi{icam}(:,chordnum_disp(icam))),0,0,'','','',NaN,'','','-','none','g',2,font,ax);%Poloidal plot
    end
end
%
axis(ax,'equal')
set(ax,'xtickmode','auto','ytickmode','auto');drawnow
%
print_jd(p_opt,[filename,'_TopView']);
%
if isempty(axs),
    disp('***************************************************************************************************************************************************')
    disp('WARNING: the definitions used in the DKE code, and here crucial for HXR calculations are the following');
    disp('   1) the toroidal frame (R,Z,phi) is direct (phi is positive clockwise when the tokamak is seen from the top)');
    disp('   2) the poloidal frame (r,theta,phi) is direct');
    disp('   3) (psi,s,phi) must be direct : if Ip.phi > 0, then B.theta > 0 and psi > 0, and s.theta > 0 (s as the same direction of theta)');
    disp('   4) the sign of psi is the sign of Ip.phi');
    disp('With the definitions above, if Ip is positive, psi is turned outward, Btheta is counterclockwise poloidally, and s too. The Ampere theorem is OK !');
    disp('The HXR diagnostic arrangement is taking this frame of reference.');
    disp('-----------------------------------------------------------');
    disp(['Sign of Bphi: ',int2str(sssB),' / Sign of Ip: ',int2str(sssIp),' / Sign of Ip_LUKE: ',int2str(sssIpdke)]);
    disp('***************************************************************************************************************************************************')
end

