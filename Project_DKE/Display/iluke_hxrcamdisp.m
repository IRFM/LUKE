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
function iluke_hxrcamdisp(hxrcams,xlim,ylim,Rp,Zp,axs,style)
%
ncams = length(hxrcams);
%
ns = 1000;
%
colors = {'b',[0,0.5,0],'m','c','y'};
%
Rmax_hxr = NaN(1,ncams);
Zmax_hxr = NaN(1,ncams);
%
for icam = 1:ncams,
    %
    cam = hxrcams{icam};
    %
    Rmax_hxr(icam) = cam.R_hxr(1);
    Zmax_hxr(icam) = cam.Z_hxr(1);    
    %
    smax = 4*Rp;
    %
    s = linspace(-smax,smax,2*ns+1);
    %
    [~,~,syx,syy,syz] = raypath_prop_jd(Rp,cam.R_hxr - Rp,cam.Z_hxr - Zp,0,cam.alpha_hxr,cam.beta_hxr,s);
    %
    syr = sqrt(syx.^2 + syy.^2);% distance to plasma center
    %
    syR = Rp + syx;
    syphi = -syz/Rp;% minus sign for LUKE convention
    %
    is = ns+1;% focal point
    %
    dir = sign(syr(is + 1,1) - syr(is,1));
    %
    if dir < 0,% forward direction,
        smask = is:2*ns+1;
    else% backward direction,
        smask = is:-1:1;
    end
    %
    syx = syx(smask,:);
    syy = syy(smask,:);
    syR = syR(smask,:);
    syphi = syphi(smask,:);
    %
    for iy = 1:size(syx,2),
        smask = find(syx(:,iy) < xlim(1),1,'first'):ns+1; 
        %
        syx(smask,iy) = NaN;
        syy(smask,iy) = NaN;
        syR(smask,iy) = NaN;
        syphi(smask,iy) = NaN;
    end        
    %
    graph1D_jd(syx,syy,0,0,'','','',NaN,NaN,NaN,'-','none',colors{icam},0.5,style,axs(1));
    graph1D_jd(syR.*cos(syphi),syR.*sin(syphi),0,0,'','','',NaN,NaN,NaN,'-','none',colors{icam},0.5,style,axs(2));
    %
    if cam.selectedchord > 0,
        graph1D_jd(syx(:,cam.selectedchord),syy(:,cam.selectedchord),0,0,'','','',NaN,NaN,NaN,'-','none','k',2,style,axs(1));
        graph1D_jd(syR(:,cam.selectedchord).*cos(syphi(:,cam.selectedchord)),syR(:,cam.selectedchord).*sin(syphi(:,cam.selectedchord)),0,0,'','','',NaN,NaN,NaN,'-','none','k',2,style,axs(2));
    end
    %
end
%
xlim = [xlim(1),max([xlim(2),Rmax_hxr - Rp])];
ylim = [min([ylim(1),Zmax_hxr - Zp]),max([ylim(2),Zmax_hxr - Zp])];
Rmax = Rp + xlim(2);
%
set(axs(1),'xlim',xlim,'ylim',ylim);drawnow;
set(axs(2),'xlim',[-Rmax,Rmax],'ylim',[-Rmax,Rmax]);drawnow;
%
