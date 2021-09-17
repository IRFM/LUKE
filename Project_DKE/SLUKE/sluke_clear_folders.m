function sluke_clear_folders(sparams,ii)
%
%LUKE - Clear folders locally for a reset of sluke simulations
%
%   Input: none
%
%   Output: 
%
%       success_out : success if (1) or failure is (0). In the latter, have
%       a look to messages
%       messages : structure of folder creation messages
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
warning off
%
delete(['SLUKE_RESULTS/LUKE_DATA_',sluke_id(sparams,ii,'simul'),'.mat']);
delete(['SLUKE_RESULTS/PROC_LUKE_DATA_',sluke_id(sparams,ii,'simul'),'.mat']);
%
delete(['SLUKE_EQUILS/EQUIL_',sluke_id(sparams,ii,'equil'),'.mat']);
%
delete(['SLUKE_OHMS/OHM_',sluke_id(sparams,ii,'ohm'),'.mat']);
%
delete(['SLUKE_KINETICS/DKEPARAM_',sluke_id(sparams,ii,'dkeparam'),'.mat']);
%
%delete(['SLUKE_RFWAVES/RAYPARAM_',sluke_id(sparams,ii,'rayparam'),'.mat']);
%
delete(['SLUKE_KINETICS/DKEDISPLAY_',sluke_id(sparams,ii,'dkedisplay'),'.mat']);
%
delete(['SLUKE_EQUILS/FITEQUIL_',sluke_id(sparams,ii,'fit'),'.mat']);
%
delete(['SLUKE_EQUILCONSISTENCIES/EQUILCONSISTENCY_',sluke_id(sparams,ii,'equilconsistency'),'.mat']);
%
warning on
%