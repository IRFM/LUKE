%Script that runs all examples in one pass. May take few hours. Prior to
%run this script, all the *.mat files in the ~/Project_DKE/Database
%directory must be created.
%
% by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
% ---------------------- TScyl Thermal -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Thermal']);
if exist('DKE_RESULTS_TScyl_Thermal_dtn.mat','file') == 0 || forcerun,
   rundke_dtn
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Thermal_dtn skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Thermal']);
if exist('DKE_RESULTS_TScyl_Thermal_res.mat','file') == 0 || forcerun,
   rundke_res
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Thermal_res skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Thermal']);
if exist('DKE_RESULTS_TScyl_Thermal_norm.mat','file') == 0 || forcerun,
   rundke_norm
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Thermal_norm skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Thermal']);
if exist('DKE_RESULTS_TScyl_Thermal_Ti.mat','file') == 0 || forcerun,
   rundke_Ti
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Thermal_Ti skipped because already done !'])      
end
cd ../..
%
% ---------------------- TScyl Ohm -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm']);
if exist('DKE_RESULTS_TScyl_Ohm_dtn.mat','file') == 0 || forcerun,
   rundke_dtn
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_dtn skipped because already done !'])     
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm']);
if exist('DKE_RESULTS_TScyl_Ohm_time.mat','file') == 0 || forcerun,
   rundke_time
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_time skipped because already done !'])     
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm']);
if exist('DKE_RESULTS_TScyl_Ohm_conv.mat','file') == 0 || forcerun,
   rundke_conv
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_conv skipped because already done !'])     
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm']);
if exist('DKE_RESULTS_TScyl_Ohm_betath.mat','file') == 0 || forcerun,
   rundke_betath
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_betath skipped because already done !'])     
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm']);
if exist('DKE_RESULTS_TScyl_Ohm_epsi.mat','file') == 0 || forcerun,
   rundke_epsi
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_epsi skipped because already done !'])     
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm']);
if exist('DKE_RESULTS_TScyl_Ohm_Zi.mat','file') == 0 || forcerun,
   rundke_Zi
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_Zi skipped because already done !'])     
end
cd ../..
%
% ---------------------- TScyl Runaway -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_betath.mat','file') == 0 || forcerun,
   rundke_betath
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_betath skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_dtn.mat','file') == 0 || forcerun,
   rundke_dtn
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_dtn skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_conv.mat','file') == 0 || forcerun,
   rundke_conv
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_conv skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_init.mat','file') == 0 || forcerun,
   rundke_init
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_init. skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_norm.mat','file') == 0 || forcerun,
   rundke_norm
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_norm skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_norm_ss.mat','file') == 0 || forcerun,
   rundke_norm_ss
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_norm_ss skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_time.mat','file') == 0 || forcerun,
   rundke_time
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_time skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway']);
if exist('DKE_RESULTS_TScyl_Runaway_Zi_nobounce.mat','file') == 0 || forcerun,
   rundke_Zi
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_Zi_nobounce skipped because already done !']) 
end
cd ../..
%
% ---------------------- TScyl LH_Karney -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_test.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_test skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_betath.mat','file') == 0 || forcerun,
   rundke_betath
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_betath skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_conv.mat','file') == 0 || forcerun,
   rundke_conv
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_conv skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_time.mat','file') == 0 || forcerun,
   rundke_time
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_time skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_dtn.mat','file') == 0 || forcerun,
   rundke_dtn
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_dtn skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_D0.mat','file') == 0 || forcerun,
   rundke_D0
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_D0 skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_grid.mat','file') == 0 || forcerun,
   rundke_grid
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_grid skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_karney_init.mat','file') == 0 || forcerun,
   rundke_init
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_init skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_Karney']);
if exist('DKE_RESULTS_TScyl_LH_Zi.mat','file') == 0 || forcerun,
   rundke_Zi
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_Zi skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_transp_nobounce']);
if exist('DKE_RESULTS_TScyl_LH_karney_transp_nobounce.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_transp_nobounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_num']);
if exist('DKE_RESULTS_TScyl_LH_karney_num.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_num skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_3D_num']);
if exist('DKE_RESULTS_TScyl_LH_karney_3D_num.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_3D_num skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_3D_splitting']);
if exist('DKE_RESULTS_TScyl_LH_karney_3D_splitting_1.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_3D_splitting skipped because already done !']) 
end
cd ../..
%
% ---------------------- TScirc_e1 -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'Ohm_bounce']);
if exist('DKE_RESULTS_TScirc_e1_Ohm_bounce.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'Ohm_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'Ohm_bounce']);
if exist('DKE_RESULTS_TScirc_e1_Ohm_bounce_val.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'Ohm_bounce_val skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'Runaway_bounce']);
if exist('DKE_RESULTS_TScirc_e1_Runaway_bounce.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'Runaway_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'Runaway_bounce']);
if exist('DKE_RESULTS_TScirc_e1_Runaway_bounce_val.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'Runaway_bounce_val skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'LH_Karney_bounce']);
if exist('DKE_RESULTS_TScirc_e1_LH_bounce.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'LH_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'LH_Karney_bounce']);
if exist('DKE_RESULTS_TScirc_e1_LH_bounce_val.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'LH_bounce_val skipped because already done !']) 
end
cd ../..
%
% ---------------------- JETh77 -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETh77',filesep,'LH_karney_transp_bounce']);
if exist('DKE_RESULTS_JETh77_LH_karney_transp_bounce.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation JETh77',filesep,'LH_karney_transp_bounce skipped because already done !']) 
end
cd ../..
%
% ---------------------- TScirc -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc',filesep,'LH_karney_ripple']);
if exist('DKE_RESULTS_TScirc_LH_karney_ripple.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc',filesep,'LH_karney_ripple skipped because already done !']) 
end
cd ../..
%
% ---------------------- TScirc_peak -----------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_peak',filesep,'LH_karney_ripple']);
if exist('DKE_RESULTS_TScirc_peak_LH_karney_rippleon.mat','file') == 0 || forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_peak',filesep,'LH_karney_ripple skipped because already done !']) 
end
cd ../..
%
