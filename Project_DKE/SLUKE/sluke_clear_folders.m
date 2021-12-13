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
if exist(['SLUKE_RFWAVES/WAVESTRUCTS_',id,'.mat'])
    delete(['SLUKE_RFWAVES/WAVESTRUCTS_',id,'.mat']);
end
%
if sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.method{ii}{kk} == 0
    filename_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
        '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},...
        '_ne_',num2str(sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).optim.ne_guess{ii}{kk}/1e17)];
else
    filename_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
        '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.rfwaves.antenna.(sparams.rfwaves.antenna.type{ii}{kk}).(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},'_ne_optim'];
end
%
if exist(['SLUKE_RFWAVES/ALOHA/Simulations/',filename_aloha,'.mat'])
    delete(['SLUKE_RFWAVES/ALOHA/Simulations/',filename_aloha,'.mat']);
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
