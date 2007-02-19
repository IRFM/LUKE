function proc_wave_luke_jd(filename,opt_disp,nr_dep)
%
% This function calculates and display ray properties after LUKE absorption calculations
%
if nargin < 3,
    nr_dep = 20;
end
%
if nargin < 2,
    opt_disp.equil = 0;
    opt_disp.si = 1;
end
%
load([filename,'.mat'],'equil','waves','dke_out','rho_S','ZP0','Zcurr','mksa','equilDKE','gridDKE')
%
pn = gridDKE.pn;
mhu = gridDKE.mhu;
xrho = gridDKE.xrho;
rdke = gridDKE.rdke;
%
clear gridDKE
%
xys = dke_out.xys;
xyP0_2piRp_in = dke_out.xyP0_2piRp_in;
xyP0_2piRp_mod = dke_out.xyP0_2piRp_mod;
xyprop_dke = dke_out.xyprop_dke;
yb = dke_out.yb;
waveparam = dke_out.waveparam;
%
ZXYD_rf = dke_out.ZXYD_rf;
ZXYD_rf_tp = dke_out.ZXYD_rf_tp;
ZXYF_rf_tp = dke_out.ZXYF_rf_tp;
gridindex_rf = dke_out.gridindex_rf;
%
XXfinit = dke_out.XXfinit;
XXf0 = dke_out.XXf0;
%
clear dke_out
%
xmhu0T2 = equilDKE.xmhu0T2;
xdV_2piRp_dke = equilDKE.xdV_2piRp_dke;
%
clear equilDKE
%
xyPabs_rf_dke_fsav_mksa = ZP0.xy_rf_fsav*mksa.P_ref*1e6;%RF power (W)
xJ_rf_dke_fsav_mksa = Zcurr.x_0_fsav*mksa.j_ref*1e6;%Current (A);
betath_ref = mksa.betath_ref;
%
clear mksa ZP0 Zcurr
%
if opt_disp.equil == 1,
    equilibrium_jd(equil,NaN,2);
end
%
[nr,ny] = size(xys);
%
xydV_2piRp_dke = xdV_2piRp_dke'*ones(1,ny);
xydPrf_dke = xyPabs_rf_dke_fsav_mksa.*xydV_2piRp_dke*2*pi*equil.Rp;%power absorbed from each ray within each FS
%
xdrho = diff(rho_S);
xdPrf_dke = sum(xydPrf_dke,2).';
%
xdPdrho = xdPrf_dke./xdrho;
%
zs = raypath_jd(xys,xyprop_dke,yb,1:nr);
zP0_2piRp_mod = raypath_jd(xyP0_2piRp_mod,xyprop_dke,yb,1:nr);
%
rdPdrho_lin = 0;
ibb = 0;
%
for iw = 1:length(waves),
%     wave = waves{iw};
%     color = color_list{iw};
    %
    for ib = 1:length(waves{iw}.rays),
        %
        ibb = ibb + 1;
        %
        ray = waves{iw}.rays{ib};
        ray.srho = psi2rho_jd(equil,ray.spsin);
        ray = radialdampingprofile_jd(equil,ray,nr_dep);
        rdPdrho_lin = rdPdrho_lin + ray.dPnormdrho*ray.P0_2piRp*2*pi*equil.Rp;
        %
        ray.zs = zs{ibb};
        ray.zP0_2piRp_mod = zP0_2piRp_mod{ibb};
        %
        zs_fit = ray.zs;
        zP0_2piRp_mod_fit = ray.zP0_2piRp_mod;
        %
        irep = find(diff(zs_fit) == 0);
        %
        zs_fit(irep+1) = [];
        zP0_2piRp_mod_fit(irep) = (zP0_2piRp_mod_fit(irep) + zP0_2piRp_mod_fit(irep+1))/2;
        zP0_2piRp_mod_fit(irep+1) = [];
        %
        if zs_fit(1) > ray.ss(1),
            zs_fit = [ray.ss(1),zs_fit];
            zP0_2piRp_mod_fit = [ray.zP0_2piRp_mod(1),zP0_2piRp_mod_fit];
        end
        %
        if zs_fit(end) < ray.ss(end),
            zs_fit = [zs_fit,ray.ss(end)];
            zP0_2piRp_mod_fit = [zP0_2piRp_mod_fit,ray.zP0_2piRp_mod(end)];
        end
        %
        ray.sP_2piRp_luke = interp1(zs_fit,zP0_2piRp_mod_fit,ray.ss,'pchip');
        %
        sP_2piRp_luke_norm = ray.sP_2piRp_luke/ray.P0_2piRp;
        delta = (1 - erf(1))/2;
        %
        ray.isabsmin = max(find(sP_2piRp_luke_norm > (1 - delta)));
        ray.isabsmax = max(find(sP_2piRp_luke_norm > delta));
        ray.ismax = max(find(diff(ray.sP_2piRp_luke) == min(diff(ray.sP_2piRp_luke))));
        %
        Pin.dke(iw,ib) = ray.zP0_2piRp_mod(1)*2*pi*equil.Rp;
        Pout.dke(iw,ib) = ray.zP0_2piRp_mod(end)*2*pi*equil.Rp;
        %
        Pin.alpha(iw,ib) = ray.sP_2piRp(1)*2*pi*equil.Rp;
        Pout.alpha(iw,ib) = ray.sP_2piRp(end)*2*pi*equil.Rp;
        %
        ray.absrate_dke = 1 - Pout.dke(iw,ib)/Pin.dke(iw,ib);
        ray.absrate_alpha = 1 - Pout.alpha(iw,ib)/Pin.alpha(iw,ib);
        %
        waves{iw}.rays{ib} = ray;
        %
    end
    %
    absrate.dke(iw) = 1 - sum(Pout.dke(iw,:))./sum(Pin.dke(iw,:));
    absrate.alpha(iw) = 1 - sum(Pout.alpha(iw,:))./sum(Pin.alpha(iw,:));
    %
end
%
rho_dep = ray.rho_dep;
%
close all
%
color_list = {[0,0.75,0],'m'};
%
xlab = '';
ylab = '';
tit = '';
leg = NaN;
xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
style = '-';
style2 = '--';
width = 0.5;
width2 = 2;
marker = 'none';
marker2 = '+';
siz = 20;
red = 0.9;
lspace = 0.7;
bspace = 0.7;
%
color0 = NaN;
color1 = 'r';
color2 = 'b';
color3 = 'g';
color5 = 'k';
%
figure(3);clf
%
xlab = 'r/a';
ylab = 'dP/d\rho';
xlim = NaN;
ylim = NaN;
%
graph1D_jd(xrho,xdPdrho,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color1,width2,siz,gca,red,lspace,bspace);
%graph1D_jd(xrho,xdPdrho_lin,0,0,'','','',leg,xlim,ylim,style,marker,color2,width2,siz);
graph1D_jd(rho_dep,rdPdrho_lin,0,0,'','','',leg,xlim,ylim,style,marker,color2,width2,siz);
%
%
figure(4);clf
%
xlab = 'r/a';
ylab = 'J (MA/m^2)';
xlim = NaN;
ylim = NaN;
%
graph1D_jd(xrho,opt_disp.si*xJ_rf_dke_fsav_mksa,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker2,color1,width2,siz,gca,red,lspace,bspace);
%
%
%
%
xlab = 's';
ylab = 'P(s)';
leg = ['linear';...
       'LUKE  '];
%
leg2 = ['\theta (\times \pi)  ';...
        '6.5/T_e^{1/2}        ';...
        'N_{||}               ';...
        'N_{\perp} (\times 10)'];  
%
delete([filename,'.txt'])
diary([filename,'.txt'])
%
for iw = 1:length(waves),
    %
    disp(['======> Wave # ',num2str(iw)])
    disp([' '])
    %
    disp(['Fraction of power absorbed in linear theory   : ',num2str(100*absrate.alpha(iw)),' %']);
    disp(['Fraction of power absorbed calculated by luke : ',num2str(100*absrate.dke(iw)),' %']);
    disp([' '])
    %
    for ib = 1:length(waves{iw}.rays),
        %
        figure(100*iw + ib)
        %
        ray = waves{iw}.rays{ib};
        %
        %graph1D_jd(wbss{iw,ib},wbsP{iw,ib},0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width2,siz,gca,red,lspace,bspace);
        graph1D_jd(ray.ss,ray.sP_2piRp*2*pi*equil.Rp,0,0,xlab,ylab,tit,NaN,xlim,ylim,style,marker,color1,width2,siz,gca,red,lspace,bspace);
        graph1D_jd(ray.zs,ray.zP0_2piRp_mod*2*pi*equil.Rp,0,0,'','','',leg,xlim,ylim,style,marker2,color2,width2);
        %
        figure(100*iw + 10 + ib)
        %
        locylab = ' ';
        %
        absmask = ray.isabsmin:ray.isabsmax;
        %
        graph1D_jd(ray.ss,[ray.stheta/pi;6.5./sqrt(ray.sTe);ray.sNpar;ray.sNperp/10],0,0,xlab,locylab,tit,leg2,xlim,ylim,style,marker,color0,width2,siz,gca,red,lspace,bspace);          
        graph1D_jd(ray.ss(absmask),[ray.stheta(absmask)/pi;6.5./sqrt(ray.sTe(absmask));ray.sNpar(absmask);ray.sNperp(absmask)/10],0,0,'','','',NaN,xlim,ylim,style2,marker,color5,width2,siz);          
        %
        disp(['-----> Absorption of ray # ',num2str(ib)])
        disp([' '])
        %
        disp(['Fraction of power absorbed in linear theory   : ',num2str(100*ray.absrate_alpha),' %']);
        disp(['Fraction of power absorbed calculated by luke : ',num2str(100*ray.absrate_dke),' %']);
        disp([' '])
        %
        disp(['At the peak of power deposition profile'])
        disp(['--> Npar : ',num2str(ray.sNpar(ray.ismax)),'']);
        disp(['--> Nperp: ',num2str(ray.sNperp(ray.ismax)),'']);
        disp(['--> rho  : ',num2str(ray.srho(ray.ismax)),'']);
        disp(['--> theta: ',num2str(ray.stheta(ray.ismax)/pi),' x pi']);
        %
        disp([' '])
        %
    end
    %
end
%
diary off
%
ir_display = input('radial grid index? ');
%
while ~isempty(ir_display),
    %
    load(filename,'dkeparam','display')
    %
    xyD0_rf_mod = waveparam(:,:,4).*xyP0_2piRp_mod./xyP0_2piRp_in;
    [ZXXD_rf,ZXXF_rf,ZXXD_rf_tp,ZXXF_rf_tp] = raysum_rf_jd_old(dkeparam,ZXYD_rf,ZXYD_rf_tp,ZXYF_rf_tp,xyD0_rf_mod,gridindex_rf);
    %
    [logXfinit_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXfinit(:,:,ir_display)),pn,mhu,display.dp_cyl);%Spherical to cylindrical coordinate transformation
    Xfinit_cyl = exp(logXfinit_cyl);%For accurate representation in figures 
    %
    [logXf0_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(log(XXf0(:,:,ir_display)),pn,mhu,display.dp_cyl);%Spherical to cylindrical coordinate transformation
    Xf0_cyl = exp(logXf0_cyl);%For accurate representation in figures 
    %
    %XDrf = ZXXD_rf.parpar_ij(:,:,ir_display);
    XDrf = ZXXD_rf.pp_ij(:,:,ir_display);
    %
    [XDrf_cyl,ppar_cyl,dppar_cyl,pperp_cyl,dpperp_cyl] = s2c_dke_yp(XDrf,pn,mhu,display.dp_cyl);%Spherical to cylindrical coordinate transformation
    %
    Xppar_cyl = ones(length(pperp_cyl),1)*ppar_cyl(:)';%Grid for the distribution functions only
    Xpperp_cyl = pperp_cyl(:)*ones(1,length(ppar_cyl));
    Xp_cyl = sqrt(Xppar_cyl.*Xppar_cyl + Xpperp_cyl.*Xpperp_cyl);
    %Xmhu_cyl = Xppar_cyl./Xp_cyl;
    %Xgamma_cyl = sqrt(1 + Xp_cyl.*Xp_cyl*betath_ref*betath_ref);
    %Xvpar_cyl = Xppar_cyl./Xgamma_cyl;
    %
    Xf0_cyl = Xf0_cyl.*(Xf0_cyl>0);%Remove negative values
    Xf0_cyl = Xf0_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
    Xf0_cyl(isnan(Xf0_cyl)) = 0;%Remove NaN values
    %
    Xfinit_cyl = Xfinit_cyl.*(Xfinit_cyl>0);%Remove negative values
    Xfinit_cyl = Xfinit_cyl.*(Xp_cyl<max(ppar_cyl));%Remove values above max(ppar)
    Xfinit_cyl(isnan(Xfinit_cyl)) = 0;%Remove NaN values
    %
    XDrf_cyl = XDrf_cyl.*(XDrf_cyl>0);
    XDrf_cyl = XDrf_cyl.*(Xp_cyl<max(ppar_cyl));
    XDrf_cyl(isnan(XDrf_cyl))=0;
    %
    % ---------- 2D distribution f0 -----------
    %
    figure(10),clf
    %
    x1 = ppar_cyl;
    xlab1 = 'p_{||}/p_{Te}';
    xlim1 = [-dkeparam.pnmax_S,dkeparam.pnmax_S];
    x2 = pperp_cyl;
    xlab2 = 'p_{\perp}/p_{Te}';
    xlim2 = [0,dkeparam.pnmax_S];
    leg = ['f_{init}';'f_0     '];
    %
    x9 = x1;
    y9 = sqrt(dkeparam.pnmax_S^2 - x9.^2);
    y1 = Xfinit_cyl;
    y2 = Xf0_cyl;
    %
    graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,betath_ref,[0:0.5:dkeparam.pnmax_S],0,style,color2,width,siz,red,max(max(y1)));
    graph2D_jd(x1,x2,y2','','','',xlim1,xlim2,0,betath_ref,[0:0.5:dkeparam.pnmax_S],0,style,color1,width2,siz,1,max(max(y1)));
    graph1D_jd(x9,y9,0,0,xlab1,xlab2,'2D Distribution function f_0',NaN,xlim1,xlim2,style,marker,color5,width2,siz);
    axis('equal');axis([xlim1,xlim2])
    bounce_ripple_jd(dkeparam.bounce_mode,dkeparam.pnmax_S,xmhu0T2,ir_display,[]);
    %
    figure(11),clf
    %
    y1 = XDrf_cyl;
    cont = 10;[0:ceil(max(max(XDrf_cyl)))];
    %
    graph2D_jd(x1,x2,y1','','','',xlim1,xlim2,0,NaN,cont,0,style,NaN,width2,siz,red);
    graph1D_jd(x9,y9,0,0,xlab1,xlab2,'LH dif. coef. [\nu^{ref}(p_{Te}^{ref})^2]',NaN,xlim1,xlim2,style,marker,color5,width2,siz);
    axis('equal');axis([xlim1,xlim2])
    bounce_ripple_jd(dkeparam.bounce_mode,dkeparam.pnmax_S,xmhu0T2,ir_display,[]);
    colorbar
    %
    figure(10),
    graph2D_jd(x1,x2,y1',xlab1,xlab2,'2D Distribution function f_0',xlim1,xlim2,0,NaN,cont,0,style,color3,width2,siz);
    %
    ir_display = input('radial grid index? ');
end

