% script make_wavestruct_Scen2_C3PO_EC
%
clear all
clear mex
clear functions
close all
warning('off','all')
pause(1)
%
% *********************** Specify LUKE structures *****************************
%
locid_wavestruct = '_24rays';%wavestruct local ID
path_wavestruct = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'ITER_Scen2_200103121816_430_129';%For plasma equilibrium
path_equil = 'EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_launch = {'NTM_32'};%For plasma equilibrium
paths_launch = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%
% C3PO computing parameters
%
C3POparam = struct;
%
% Display parameters for C3PO
%
C3POdisplay = struct;
%
% Wave parameters for C3PO
%
waveparam.mmode = -1;% cold plasma mode (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1)
waveparam.nd = 4;%Number of transverse distance positions for beamlets
waveparam.nchi = 6;%Number of angular positions for beamlets
%
% Equilibrium parameters C3PO
%
fitparam = struct;
%
% Global parameters for C3PO
%
rayparam = struct;
%
%************************************************************************************************************************************
%
[dkepath,equil,launchs] = load_structures_yp('dkepath',id_dkepath,path_dkepath,'equil',id_equil,path_equil,'launchs',ids_launch,paths_launch);
%
C3POPARAM = load('C3POPARAM_EC.mat','fitparam','rayparam','C3POparam','C3POdisplay','waveparam');
%
fitparam = conc_struct_jd(C3POPARAM.fitparam,fitparam);
rayparam = conc_struct_jd(C3POPARAM.rayparam,rayparam);
C3POparam = conc_struct_jd(C3POPARAM.C3POparam,C3POparam);
C3POdisplay = conc_struct_jd(C3POPARAM.C3POdisplay,C3POdisplay);
waveparam = conc_struct_jd(C3POPARAM.waveparam,waveparam);
%
% wavestruct
%
wavestruct.wavesolver = 'C3PO';
wavestruct.launch = launchs{1};
wavestruct.id = [wavestruct.wavesolver,'_',launchs{1}.id,locid_wavestruct];
wavestruct.waveparam = waveparam;
wavestruct.rayparam = rayparam;
wavestruct.fitequilparam = fitparam;
wavestruct.raydisplay = C3POdisplay;
wavestruct.C3POparam = C3POparam;
%
%************************************************************************************************************************************
%
filename = ['WAVESTRUCT_',equil.id,'_',wavestruct.id,'.mat'];
%
save([path_wavestruct,filename],'wavestruct');
%
