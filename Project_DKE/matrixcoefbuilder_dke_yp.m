function [MMXR_f_t,...
          ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,...
		  ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp,ylist_rf,...
		  ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = matrixcoefbuilder_dke_yp(theta,...
          XR,XZ,XBR,XBZ,XBphi,...
          xB0,xR0,xBT0,xBp0,
		  Z3Dgrid,Zmomcoef,Zbouncecoef,...
		  xTe_norm,xne_norm,zZi,zmi,xzni_norm,xzTi_norm,xZeff,xlnc_e,xrnhuth,...
          betath_ref,xepsi_fsav,waveparam,nmax_rf,...
          XXDr,XXVr,...
          XXsource,XXlossripple,...
          xftp_norm,bounce,xnloss,coll_mode,...
          display,store_mode,temppath,coeftype)
%
%   Calculate matrix coefficients for the 3D electron relativistic drift kinetic solver.
%   (collisions, RF, Efield, magnetic ripple losses, anomalous radial transport)
%
%   by Y. Peysson (CEA-DRFC) (yves.peysson@cea.fr) and J. Decker (CEA-DRFC) (joan.decker@cea.fr)
%
if nargin < 70,
    error('Wrong number of input arguments in matrixcoefbuilder_dke_yp')
end
%





display_mode = display(1);
ir_display = display(2);
time_pause = display(3);%Pause delay for figure display (s)
nit_f = nit(1);
nit_g = nit(2);
bounce_mode = bounce(1);
dke_mode = bounce(2);
equil_mode = bounce(3);
xbetath = betath_ref*sqrt(xTe_norm);
%
if bounce_mode == 0,dke_mode = 0;end
if dke_mode == 1,bounce_mode = 1;end
%
testDrVr = sum(sum(sum(abs(XXDr)))) + sum(sum(sum(abs(XXVr))));
if length(rdke) >= 4 & testDrVr > 0,
    radial_mode = 1;
elseif length(rdke) < 4 & testDrVr > 0,
    radial_mode = -1;
elseif testDrVr == 0,
    radial_mode = 0;
end 
%
%************************************************** Simulation parameter display ******************************************************** 
%
if display_mode >=1,
    disp('Drift kinetic matrix calculation parameters: ');
%Momentum dynamics
    if (coll_mode == 0),     disp(['   - Collisions: Relativistic Maxwellian background']);
    elseif (coll_mode == 1), disp(['   - Collisions: High velocity limit']);    
    elseif (coll_mode == 2), disp(['   - Collisions: Linearized relativistic Belaiev-Budker']);
    elseif (coll_mode == 3), disp(['   - Collisions: Non-relativistic Lorentz model']);
    elseif (coll_mode == 4), disp(['   - Collisions: Non-relativistic Maxwellian background']);end
    if (bounce_mode == 0),      disp(['   - No bounce averaging']);
    elseif (bounce_mode == 1),  disp(['   - Bounce averaging + implicit symmetrization in the bounce domain (15 diagonals operator) for f0']);end
    if (dke_mode == 0),       disp(['   - Resolution of the electron Fokker-Planck Equation']);
    elseif (dke_mode == 1),   disp(['   - Resolution of the electron Drift Kinetic Equation']);end
%Spatial dynamics
    if (radial_mode == 1),      disp(['   - Fast electron radial diffusion or pinch']);
    elseif (radial_mode == -1), disp(['   - No fast electron radial diffusion or pinch: radial grid too coarse !']);
    elseif (radial_mode == 0),  disp(['   - No fast electron radial diffusion or pinch']);end
%
    disp(['   - Momentum grid: ',int2str(npn)]);
    disp(['   - Angular grid: ',int2str(nmhu)]);
    disp(['   - Total radial grid: ',int2str(nr)]);
    disp(['   - Effective radial grid: ',int2str(nr_dke)]);
    disp('-------------------------------------------------------------------------------------------------------------------');
end
%
%Radial supermatrix coefficients
%
if strcmp(coeftype,'radialtransp'),
   [MMXR_f_t] = rad_dke_yp(Z3Dgrid,Zbouncecoef,XXDr,XXVr,xR0,xBp0,xB0,bounce_mode,radial_mode,display_mode,temppath);
   return;
end
%
% Collisions flux coefficients 
%
elseif strcmp(coeftype,'collisions'),
   [ZXXD_c,ZXXF_c,ZXXD_c_tp,ZXXF_c_tp,XXfM,XXILor] = coll_dke_jd(Z3Dgrid,Zmomcoef,Zbouncecoef,xTe_norm,xzTi_norm,xne_norm,xzni_norm,betath_ref,zZi,zmi,coll_mode,dke_mode,display_mode,rdke,temppath);
   return;
end
%
% RF wave flux coefficients
%
elseif strcmp(coeftype,'rfwaves'),
%   [ZYXXD_rf,ZYXXF_rf,ZYXXD_rf_tp,ZYXXF_rf_tp,ylist_rf] = ...
%        rfdiff_dke_jd(waveparam,nmax_rf,save_id,temppath,...
%        theta,XR,XZ,XBR,XBZ,XBphi,xB0,Rp,Zp,xqtilde,...
%        XXheaviside,XXheaviside_p,XXheaviside_m,... 
%        Xmhup,Xmhu,Xmhum,Xmhu2p,Xmhu2,Xmhu2m,X1mmhu2p,X1mmhu2,X1mmhu2m,Xdmhumm,Xdmhum,Xdmhu,Xdmhup,Xdmhupp,...
%        Xpnpp,Xpnp,Xpn,Xpnm,Xpnmm,Xdpnmm,Xdpnm,Xdpn,Xdpnp,Xdpnpp,...
%        Xgammapp,Xgammap,Xgamma,Xgammam,Xgammamm,...
%        Xxlambda_p,Xxlambda,Xxlambda_m,...
%        betath_ref,bounce_mode,dke_mode,rdke,display_mode);
%   nb = size(waveparam,2);
   return;
end
%
% Electric field flux coefficients
%
elseif strcmp(coeftype,'efield'),
   [ZXXD_e,ZXXF_e,ZXXD_e_tp,ZXXF_e_tp,xepsi,xEfield_validity] = efield_dke_jd(xepsi_fsav,Z3Dgrid,Zbouncecoef,ZXXF_c,xB0,xBT0,xR0,Rp,bounce_mode,dke_mode,display_mode,rdke,temppath);
   return;
else
   error('Wrong matrix coefficients type in matrixcoefbuilder_dke_yp.m => Valid expressions are: radialtransp,collisions,rfwaves,efield.')
end


