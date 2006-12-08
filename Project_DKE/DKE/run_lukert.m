function [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,wavestructs,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,transpfaste,ripple,XXf0_in,XXsinksource_in)
%
% Ray-tracing + quasilinear kinetic calculations using LUKE. Tool for implementation in other calculation packages.
%
% by 	Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
%
%
%Ray-tracing calculations
%
for iw = 1:length(wavestructs),
   if strcmp(wavestructs{iw}.wavesolver,'C3PO'),% C3P0 ray tracing
		rayinits{iw} = main_rayinit_launch_jd(equil,wavestructs{iw}.launch);
	   wave = main_C3PO_jd(wavestructs{iw}.id_wave,equil,rayinits{iw},wavestructs{iw}.waveparam,wavestructs{iw}.fitequilparam,wavestructs{iw}.rayparam,wavestructs{iw}.raydisplay);%Ray calculations
      waves{iw} = wave_process_jd(equil,wave,dkeparam.n_rf_list);%Wave processing and relativistic linear damping
   else
	   error('This ray-tracing is not yet linked to LUKE !')
   end
end
%
% 3-D relativistic bounce averaged quasilinear kinetic calculations (LUKE)
%
if dkeparam.rt_mode == 1,
%
% Case with sdNpar given by the waves structure (usualy constant along ray propagation)
%
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
% Case with sdNpar proportional to sNpar (in waves structure)
%
elseif dkeparam.rt_mode == 2,
   for ib=1:length(waves{1}.rays),
   	waves{1}.rays{ib}.sdNpar = waves{1}.rays{ib}.sNpar*waves{1}.rays{ib}.sdNpar(1)/waves{1}.rays{ib}.sNpar(1);
   end
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
% Case of optimized sdNpar proportional to sNpar (in waves structure) so that the CD efficiency is maximed.
%
elseif dkeparam.rt_mode == 3,
   [equilDKE_Fourier] = equilibrium_jd(equil);
%
%waves{1}.opt_disp = 0;
%
   for ib = 1:length(waves{1}.rays),
      waves{1}.rays{ib} = rayprocess_jd(waves{1}.rays{ib},equilDKE_Fourier,waves{1}.opt_disp,waves{1}.omega_rf,dkeparam.n_rf_list,'spline');
   end
%
   waves{1}.opt_disp = 0;
%
   dNpar_fac = 0.15;
   dNpar_step = 0.025;
%
   opt_fac = 0;
   eta = 0;
   firststep = 1;
%
   while opt_fac == 0,
%
      eta_old = eta;
%
      for ib = 1:length(waves{1}.rays),
         waves{1}.rays{ib}.sdNpar = waves{1}.rays{ib}.sNpar*dNpar_fac;
      end
%
      dNstr = num2str(dNpar_fac);
%
      for is=1:length(dNstr),if dNstr(is) == '.',dNstr(is) = 'p';end,end
      eval(['diary ',path_simul,'DKE_DIARY_',id_equil,'_',id_simul,'_',dNstr(1:min(4,length(dNstr))),'.txt']);
%
      [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
%
      eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'_',dNstr(1:min(4,length(dNstr))),'.mat']);
%
      diary off
%
% CD efficiency (A/W)
%
      Prf = sum(ZP0.x_rf_fsav(:).*equilDKE.xdV_2piRp_dke(:)*2*pi*equilDKE.Rp*mksa.P_ref);
      Itot = sum(Zcurr.x_tot_fsav(:).*equilDKE.xdA_dke(:)*abs(mksa.j_ref));
      eta = abs(Itot/Prf);
% 
% density of power absorbed (normalized) 
%
      if dkeparam.dke_mode >= 1,
         xyPabs_rf_dke_fsav = ZP0.xy_rf_fsav + ZP0.xy_rf_tp_fsav + ZP0.xy_rf_g_fsav; % flux-surface averaged density of absorbed power.
       else
         xyPabs_rf_dke_fsav = ZP0.xy_rf_fsav; % flux-surface averaged density of absorbed power.
       end	    
% 
% density of power absorbed (MKSA) 
%
       xyPabs_rf_dke_fsav_mksa = xyPabs_rf_dke_fsav*mksa.P_ref*1e6;%RF power (W)
%
% absorption coefficient (1/m)
%
       xyD0_rf = dke_out.waveparam(:,:,4).*dke_out.xyP0_2piRp_mod./dke_out.xyP0_2piRp_in;
%
       xyD0_rf(xyD0_rf == 0) = eps;
%
       xyalphaphi = xyPabs_rf_dke_fsav_mksa./xyD0_rf./dke_out.waveparam(:,:,1)/mksa.wmabs2;%absorption coefficient
%
% absorption coefficient along the rays
%
       zs = raypath_jd(dke_out.xys,dke_out.xyprop_dke,dke_out.yb,gridDKE.rdke);
       zalphaphi = raypath_jd(xyalphaphi,dke_out.xyprop_dke,dke_out.yb,gridDKE.rdke);
%
       for ib = 1:length(waves{1}.rays),
          zind = find(diff(zs{ib}) == 0);
          zs{ib}(zind + 1) = zs{ib}(zind + 1)+1000*eps;
%
          waves{1}.rays{ib}.salphaphi_lin = interp1(zs{ib},zalphaphi{ib},waves{1}.rays{ib}.ss,'linear',0);   
       end
%
       if eta > eta_old,
%
          dNpar_fac = dNpar_fac + dNpar_step;
%
          if eta_old > 0,
             firststep = 0;
           end
%
       elseif firststep == 1,
%
          dNpar_step = - dNpar_step
          dNpar_fac = dNpar_fac + 2*dNpar_step;
          firststep = 0;
       else
%
          opt_fac = 1;
          dNpar_fac = dNpar_fac - dNpar_step;
%
       end
   end
%
   eval(['diary ',path_simul,'DKE_DIARY_',id_equil,'_',id_simul,'.txt']);
%
   for ib = 1:length(waves{1}.rays),
      waves{1}.rays{ib}.sdNpar = waves{1}.rays{ib}.sNpar*dNpar_fac;
   end
%
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,XXf0_in,XXsinksource_in);
end
%