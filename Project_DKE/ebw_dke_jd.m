function waveparam = ebw_dke_jd(tokamak,xpsin,ne_ref,lnc_e_ref,theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,...
                xyY_ebw,xyomega_ebw,xynpar_ebw,xydnpar_ebw,xynparmin_ebw,xynparmax_ebw,xyP0_in_ebw,xyfinc_ebw,xythetab_ebw,xyopt_ebw,xyn_ebw);
%
% Creates wave parameters for hot plasma EBWCD calculations based on 
% dispersion code R2D2 results. Note that for now only ideal circular
% concentric FS cases are considered.
%
% by Joan Decker (jodecker@mit.edu) and Yves Peysson (yves.peysson@cea.fr)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
[nr,nb_ebw] = size(xyn_ebw);
%
xytest_maskY_ebw =  ~isnan(xyY_ebw);
xytest_maskomega_ebw =  ~isnan(xyomega_ebw);
xytest_input_ebw = xytest_maskY_ebw + xytest_maskomega_ebw;
%
if xytest_input_ebw ~= ones(nr,nb_ebw)
    error('EBW frequency input not compatible')
end
%
% when only the ratio n.wce/w is given, the EBW frequency is calculated as follows
%
[xyBb_ebw,xyBPb_ebw,xyrb_ebw,xyRb_ebw] = mg_interp_jd(theta,XR,XZ,XBR,XBZ,XBphi,Rp,Zp,xythetab_ebw);
xywceb_ebw = qe*xyBb_ebw/me;
xyomega_ebw(xytest_maskY_ebw) = xyn_ebw(xytest_maskY_ebw).*xywceb_ebw(xytest_maskY_ebw)./xyY_ebw(xytest_maskY_ebw);%EBW wave frequency (GHz)
%
%********** only ideal circular concentric FS
%
xrho = psi2rho_jd(tokamak,xpsin)';
%
for ib = 1:nb_ebw
    somega = num2str(round(xyomega_ebw(1,ib)/(2*pi*1e9)*10));
    if length(somega) == 2
        somega = ['0',somega];
    end
    snpar = num2str(round(xynpar_ebw(1,ib)*100));
    if length(snpar) == 1
        snpar = ['00',snpar];
    elseif length(snpar) == 2
        snpar = ['0',snpar];
    end
    loadstr = ['DISP_',tokamak,'_',somega,'_',snpar,'.mat'];
    %
    if min(xrho == repmat(xrho(1),[nr,1]))
        rho_0 = xrho(1);
    else
        rho_0 = NaN;
    end
    srho_0 = num2str(round(rho_0*1000));
    if length(srho_0) == 1
        srho_0 = ['00',srho_0];
    elseif length(srho_0) == 2
        srho_0 = ['0',srho_0];
    end
    loadseekstr = ['SEEK_',tokamak,'_',snpar,'_',srho_0,'.mat'];
    loadintstr = ['INT_',tokamak,'_',snpar,'.mat'];
    %
    if exist(loadintstr) == 2
        eval(['load ',loadintstr,' xrho_EBW xNperp_EBW x3eps_pmz_EBW xPflow_EBW xPabs_EBW']);
        xMNperp = interp1(xrho_EBW,xNperp_EBW,xrho,'spline');
        xM3eps_pmz = interp1(xrho_EBW,x3eps_pmz_EBW',xrho,'spline');
        xMPflow = interp1(xrho_EBW,xPflow_EBW,xrho,'spline');
        xMPabs = interp1(xrho_EBW,xPabs_EBW,xrho,'spline');       
    elseif exist(loadstr) == 2
        eval(['load ',loadstr,' xrho_EBW xNperp_EBW x3eps_pmz_EBW xPflow_EBW xPabs_EBW']);
        xMNperp = interp1(xrho_EBW,xNperp_EBW,xrho,'spline');
        xM3eps_pmz = interp1(xrho_EBW,x3eps_pmz_EBW',xrho,'spline');
        xMPflow = interp1(xrho_EBW,xPflow_EBW,xrho,'spline');
        xMPabs = interp1(xrho_EBW,xPabs_EBW,xrho,'spline');       
    elseif exist(loadseekstr) == 2
        eval(['load ',loadseekstr,' xrho_EBW xNperp_EBW x3eps_pmz_EBW xPflow_EBW xPabs_EBW omega']);
        xMNperp = interp1(xrho_EBW,xNperp_EBW,xrho,'spline');
        xM3eps_pmz = interp1(xrho_EBW,x3eps_pmz_EBW',xrho,'spline');
        xMPflow = interp1(xrho_EBW,xPflow_EBW,xrho,'spline');
        xMPabs = interp1(xrho_EBW,xPabs_EBW,xrho,'spline');       
    else
        prec = 5e-4;
        xrho_EBW = 0:prec:1;
        nr_EBW = length(xrho_EBW);
        if length(xrho) > 1
            xtheta_EBW = interp1(xrho,xythetab(:,ib),xrho_EBW);
            xnpar_EBW = interp1(xrho,xynpar_ebw(:,ib),xrho_EBW);
            xomega_EBW = interp1(xrho,xyomega_ebw(:,ib),xrho_EBW);
        else
            xtheta_EBW = repmat(xythetab_ebw(:,ib),[1,nr_EBW]);
            xnpar_EBW = repmat(xynpar_ebw(:,ib),[1,nr_EBW]);
            xomega_EBW = repmat(xyomega_ebw(:,ib),[1,nr_EBW]);
        end    
%
        [xrho_out_SX,xMNperp_SX,xM3eps_pmz_SX,...
                xrho_out_EBB,xMNperp_EBB,xM3eps_pmz_EBB,...
                xrho_out_EBW_ft,xMNperp_EBW_ft,xM3eps_pmz_EBW_ft,...
                xrho_out_EBW_ht,xMNperp_EBW_ht,xM3eps_pmz_EBW_ht,xMPflow_EBW_ht,xMPabs_EBW_at] = ...
            disp9_ebw_jd(tokamak,xrho_EBW,xtheta_EBW,xnpar_EBW,xomega_EBW);
%        [xMNperp,xM3eps_pmz] = disp_ebw_jd(tokamak,xrho,xythetab(:,ib),xynpar_ebw(:,ib),xyomega_ebw(:,ib),prec);
        xMNperp = interp1(xrho_out_EBW_ht,xMNperp_EBW_ht,xrho);
        xM3eps_pmz = interp1(xrho_out_EBW_ht,xM3eps_pmz_EBW_ht,xrho);
        xMPflow =  interp1(xrho_out_EBW_ht,xMPflow_EBW_ht,xrho);
        xMPabs =  interp1(xrho_out_EBW_ht,xMPabs_EBW_at,xrho);
    end
    xynperp_ebw(:,ib) = xMNperp;
    xyepolp_ebw(:,ib) = xM3eps_pmz(:,1);  
    xyepolm_ebw(:,ib) = xM3eps_pmz(:,2);  
    xyepolz_ebw(:,ib) = xM3eps_pmz(:,3);  
    xyPflow(:,ib) = xMPflow;
    xyPabs(:,ib) = xMPabs;
end
%
xyabsphi_ebw = abs(2*xyPflow/e0/clum);
%
wpe_ref = sqrt(ne_ref*qe^2/e0/me);
%
xyD0_ebw_ref = xyfinc_ebw.*xyP0_in_ebw./(xyrb_ebw.*xyRb_ebw*me*lnc_e_ref.*xyomega_ebw*wpe_ref^2.*xyabsphi_ebw);
%
waveparam = zeros(nr,nb_ebw,13);
%
waveparam(:,:,1) = xyn_ebw;%RF resonance harmonic     
waveparam(:,:,2) = xyomega_ebw;%RF wave frequency
waveparam(:,:,3) = xyopt_ebw;%Options for Larmor radius effects and/or EBW calc. 
waveparam(:,:,4) = xythetab_ebw;%Poloidal location of RF beam (relevant for bounce_mode > 0 only)    
waveparam(:,:,5) = xyD0_ebw_ref;%RF quasi-linear diffusion coefficient (nhuth_ref*pth_ref^2)
waveparam(:,:,6) = xynparmin_ebw;%Square N// spectrum: Lower limit
waveparam(:,:,7) = xynparmax_ebw;%Square N// spectrum: Upper limit
waveparam(:,:,8) = xynpar_ebw;%Gaussian N// spectrum: peak n//
waveparam(:,:,9) = xydnpar_ebw;%Gaussian N// spectrum: width in n//
waveparam(:,:,10) = xynperp_ebw;%RF wave : n_perp
waveparam(:,:,11) = xyepolp_ebw;%RF wave : polarization plus
waveparam(:,:,12) = xyepolm_ebw;%RF wave : polarization minus
waveparam(:,:,13) = xyepolz_ebw;%RF wave : polarization parallel


