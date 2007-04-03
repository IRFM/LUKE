%Script that runs all examples in one pass. May take few hours. Prior to
%run this script, all the *.mat files in the ~/Project_DKE/Database
%directory must be created.
%
% by Yves Peysson (CEA/DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Thermal']);
if exist('DKE_RESULTS_TScyl_Thermal.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Thermal skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Ohm_Zi']);
if exist('DKE_RESULTS_TScyl_Ohm_Zi.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Ohm_Zi skipped because already done !'])     
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway_Zi_nobounce']);
if exist('DKE_RESULTS_TScyl_Runaway_Zi_nobounce.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_Zi_nobounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'Runaway_particle_loss']);
if exist('DKE_RESULTS_TScyl_Runaway_particle_loss.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'Runaway_particle_loss skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_Zi_D0']);
if exist('DKE_RESULTS_TScyl_LH_karney_Zi_D0.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_Zi_D0 skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_transp_nobounce']);
if exist('DKE_RESULTS_TScyl_LH_karney_transp_nobounce.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_transp_nobounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_num']);
if exist('DKE_RESULTS_TScyl_LH_karney_num.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_num skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScyl',filesep,'LH_karney_3D_num']);
if exist('DKE_RESULTS_TScyl_LH_karney_3D_num.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScyl',filesep,'LH_karney_3D_num skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_peak',filesep,'LH_karney_ripple']);
if exist('DKE_RESULTS_TScirc_peak_LH_karney_ripple.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_peak',filesep,'LH_karney_ripple skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'Ohm_bounce']);
if exist('DKE_RESULTS_TScirc_e1_Ohm_bounce.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'Ohm_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc_e1',filesep,'Runaway_bounce']);
if exist('DKE_RESULTS_TScirc_e1_Runaway_bounce.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc_e1',filesep,'Runaway_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc',filesep,'LH_karney_transp_bounce_nomag']);
if exist('DKE_RESULTS_TScirc_LH_karney_transp_bounce_nomag.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc',filesep,'LH_karney_transp_bounce_nomag skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['TScirc',filesep,'LH_karney_transp_bounce']);
if exist('DKE_RESULTS_TScirc_LH_karney_transp_bounce.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation TScirc',filesep,'LH_karney_transp_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETh77',filesep,'LH_karney_transp_bounce_nomag']);
if exist('DKE_RESULTS_JETh77_LH_karney_transp_bounce_nomag.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation JETh77',filesep,'LH_karney_transp_bounce_nomag skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETh77',filesep,'LH_karney_transp_bounce']);
if exist('DKE_RESULTS_JETh77_LH_karney_transp_bounce.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation JETh77',filesep,'LH_karney_transp_bounce skipped because already done !']) 
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETh77',filesep,'Zero_test']);
if exist('DKE_RESULTS_JETh77_Zero_test.mat') == 0 | forcerun,
   rundke
else
   info_dke_yp(2,['Simulation JETh77',filesep,'Zero_test skipped because already done !']) 
end
cd ../..
