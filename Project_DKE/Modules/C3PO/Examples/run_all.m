%Script that runs all C3PO examples in one pass. 
%
% by Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA-IRFM, joan.decker@cea.fr)
%
allforcerun = 0;%force run of all case
%
% --------------------------- JETlike -------------------------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETlike',filesep,'EQUIL']);
if exist('EQUIL_JETliketest.mat','file') == 0 || forcerun || allforcerun,
   make_equil_JETliketest
else
   info_dke_yp(2,['Calculation in JETlike',filesep,'EQUIL skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETlike',filesep,'WAVE']);
if exist('WAVE_JETliketest_JETliketest2p0.mat','file') == 0 || forcerun || allforcerun,
   make_wave_JETliketest
else
   info_dke_yp(2,['Calculation in JETlike',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['JETlike',filesep,'WAVE']);
if exist('WAVE_JETliketest_JETliketest1p8.mat','file') == 0 || forcerun || allforcerun,
   make_wave_JETliketest_bis
else
   info_dke_yp(2,['Calculation in JETlike',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
% ----------------------------- PLT ---------------------------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['PLT',filesep,'EQUIL']);
if exist('EQUIL_PLTtest.mat','file') == 0 || forcerun || allforcerun,
   make_equil_PLTtest
else
   info_dke_yp(2,['Calculation in PLT',filesep,'EQUIL skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['PLT',filesep,'WAVE']);
if exist('WAVE_PLTtest_PLTtest.mat','file') == 0 || forcerun || allforcerun,
   make_wave_PLTtest
else
   info_dke_yp(2,['Calculation in PLT',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
% ---------------------------- RTtest -------------------------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RTtest',filesep,'EQUIL']);
if exist('EQUIL_RTtest.mat','file') == 0 || forcerun || allforcerun,
   make_equil_RTtest
else
   info_dke_yp(2,['Calculation in RTtest',filesep,'EQUIL skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RTtest',filesep,'EQUIL']);
if exist('EQUIL_RTtest_vacuum.mat','file') == 0 || forcerun || allforcerun,
   make_equil_RTtest_vacuum
else
   info_dke_yp(2,['Calculation in RTtest',filesep,'EQUIL skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RTtest',filesep,'WAVE']);
if exist('WAVE_RTtest_RTtest.mat','file') == 0 || forcerun || allforcerun,
   make_wave_RTtest
else
   info_dke_yp(2,['Calculation in RTtest',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RTtest',filesep,'WAVE']);
if exist('WAVE_RTtest_vacuum_RTtest_straight.mat','file') == 0 || forcerun || allforcerun,
   info_dke_yp(2,['TODO: RT calculations do not stop with file make_wave_RTtest_straight. To be corrected.']) 
   %make_wave_RTtest_straight
else
   info_dke_yp(2,['Calculation in RTtest',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
% --------------------------- VERSATOR2 -----------------------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['VERSATOR2',filesep,'EQUIL']);
if exist('EQUIL_VERSATOR2test.mat','file') == 0 || forcerun || allforcerun,
   make_equil_VERSATOR2test
else
   info_dke_yp(2,['Calculation in VERSATOR2',filesep,'EQUIL skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['VERSATOR2',filesep,'WAVE']);
if exist('WAVE_VERSATOR2test_VERSATOR2test.mat','file') == 0 || forcerun || allforcerun,
   make_wave_VERSATOR2test
else
   info_dke_yp(2,['Calculation in VERSATOR2',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
% ------------------------------ RFP --------------------------------------
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RFP',filesep,'EQUIL']);
if exist('EQUIL_RFP.mat','file') == 0 || forcerun || allforcerun,
   make_equil_RFP
else
   info_dke_yp(2,['Calculation in RFP',filesep,'EQUIL skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RFP',filesep,'WAVE']);
if exist('RAYINIT_RFP_LH.mat','file') == 0 || forcerun || allforcerun,
   make_rayinit_RFP
else
   info_dke_yp(2,['Calculation in RFP',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
forcerun = 0;%(1) Force all simulations even if they have already been done and overwrite existing results
cd(['RFP',filesep,'WAVE']);
if exist('WAVE_RFP_RFP_LH.mat','file') == 0 || forcerun || allforcerun,
   make_wave_RFP
else
   info_dke_yp(2,['Calculation in RFP',filesep,'WAVE skipped because already done !'])      
end
cd ../..
%
