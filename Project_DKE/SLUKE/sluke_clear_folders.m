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
id = sluke_id(sparams,ii);
%
if exist(['SLUKE_RESULTS/LUKE_DATA_',id,'.mat'])
    delete(['SLUKE_RESULTS/LUKE_DATA_',id,'.mat']);
end
%
if exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',id,'.mat'])
    delete(['SLUKE_RESULTS/PROC_LUKE_DATA_',id,'.mat']);
end
%
if exist(['SLUKE_EQUILS/EQUIL_',id,'.mat'])
	delete(['SLUKE_EQUILS/EQUIL_',id,'.mat']);
end
if exist(['SLUKE_EQUILS/FITEQUIL_',id,'.mat'])
    delete(['SLUKE_EQUILS/FITEQUIL_',id,'.mat']);
end
if exist(['SLUKE_EQUILS/EQUILCONSISTENCY_',id,'.mat'])
    delete(['SLUKE_EQUILS/EQUILCONSISTENCY_',id,'.mat']);
end
%
if exist(['SLUKE_OHMS/OHM_',id,'.mat'])
    delete(['SLUKE_OHMS/OHM_',id,'.mat']);
end
%
if exist(['SLUKE_KINETICS/DKEPARAM_',id,'.mat'])
    delete(['SLUKE_KINETICS/DKEPARAM_',id,'.mat']);
end
%
if exist(['SLUKE_KINETICS/DKEDISPLAY_',id,'.mat'])
    delete(['SLUKE_KINETICS/DKEDISPLAY_',id,'.mat']);
end
%
if isfield(sparams,'diags')
    %
    fn = fieldnames(sparams.diags);
    %
    for jj = 1:length(fn)
        %
        if exist(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRPARAM_',id,'.mat'])
            delete(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRPARAM_',id,'.mat']);
        end
        %
        if exist(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRSPEC_',id,'.mat'])
            delete(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRSPEC_',id,'.mat']);
        end
        %
        if exist(['SLUKE_DIAGNOSTICS/',fn{jj},'_RESULTS_',id,'.mat'])
            delete(['SLUKE_DIAGNOSTICS/',fn{jj},'_RESULTS_',id,'.mat']);
        end
        %
    end
    %
end
%
