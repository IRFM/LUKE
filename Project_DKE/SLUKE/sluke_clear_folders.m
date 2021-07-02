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
delete(['SLUKE_RESULTS/LUKE_DATA_',sluke_id(sparams,ii,'simul'),'.mat']);
%
delete(['SLUKE_EQUILS/EQUIL_',sluke_id(sparams,ii,'equil'),'.mat']);
%
delete(['SLUKE_OHMS/OHM_',sluke_id(sparams,ii,'ohm'),'.mat']);
%
