function sluke_clear_folders(sparams,ii,filename)
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
if nargin < 3
    %
    filename = '';
    %
end
%
id = sluke_id(sparams,ii);
%
if (strcmp(filename,'LUKE_STAMP') || isempty(filename)) && exist(['SLUKE_STAMPS/LUKE_STAMP_',id,'.mat'])
    delete(['SLUKE_STAMPS/LUKE_STAMP_',id,'.mat']);
    cprintf('*black',['SLUKE_STAMPS/LUKE_STAMP_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'LUKE_RESULTS') || isempty(filename)) && exist(['SLUKE_TEMP/LUKE_RESULTS_',id,'.mat'])
    delete(['SLUKE_TEMP/LUKE_RESULTS_',id,'.mat']);
    cprintf('*black',['SLUKE_TEMP/LUKE_RESULTS_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'waves') || isempty(filename)) && exist(['SLUKE_TEMP/waves_',id,'.mat'])
    delete(['SLUKE_TEMP/waves_',id,'.mat']);
    cprintf('*black',['SLUKE_TEMP/waves_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'LUKE_DATA') || isempty(filename)) && exist(['SLUKE_RESULTS/LUKE_DATA_',id,'.mat'])
    delete(['SLUKE_RESULTS/LUKE_DATA_',id,'.mat']);
    cprintf('*black',['SLUKE_RESULTS/LUKE_DATA_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'PROC_LUKE_DATA') || isempty(filename)) && exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',id,'.mat'])
    delete(['SLUKE_RESULTS/PROC_LUKE_DATA_',id,'.mat']);
    cprintf('*black',['SLUKE_RESULTS/PROC_LUKE_DATA_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'EQUIL') || isempty(filename)) && exist(['SLUKE_EQUILS/EQUIL_',id,'.mat'])
	delete(['SLUKE_EQUILS/EQUIL_',id,'.mat']);
    cprintf('*black',['SLUKE_EQUILS/EQUIL_',id,'.mat is deleted']);disp(' ')
end
if (strcmp(filename,'EQUIL') || isempty(filename)) && exist(['SLUKE_EQUILS/FITEQUIL_',id,'.mat'])
    delete(['SLUKE_EQUILS/FITEQUIL_',id,'.mat']);
    cprintf('*black',['SLUKE_EQUILS/FITEQUIL_',id,'.mat is deleted']);disp(' ')
end
if (strcmp(filename,'EQUIL') || isempty(filename)) && exist(['SLUKE_EQUILS/EQUILCONSISTENCY_',id,'.mat'])
    delete(['SLUKE_EQUILS/EQUILCONSISTENCY_',id,'.mat']);
    cprintf('*black',['SLUKE_EQUILS/EQUILCONSISTENCY_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'OHM') || isempty(filename)) &&  exist(['SLUKE_OHMS/OHM_',id,'.mat'])
    delete(['SLUKE_OHMS/OHM_',id,'.mat']);
    cprintf('*black',['SLUKE_OHMS/OHM_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'DKEPARAM') || isempty(filename)) && exist(['SLUKE_KINETICS/DKEPARAM_',id,'.mat'])
    delete(['SLUKE_KINETICS/DKEPARAM_',id,'.mat']);
    cprintf('*black',['SLUKE_KINETICS/DKEPARAM_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'DKEDISPLAY') || isempty(filename)) && exist(['SLUKE_KINETICS/DKEDISPLAY_',id,'.mat'])
    delete(['SLUKE_KINETICS/DKEDISPLAY_',id,'.mat']);
    cprintf('*black',['SLUKE_KINETICS/DKEDISPLAY_',id,'.mat is deleted']);disp(' ')
end
%
if (strcmp(filename,'WAVESTRUCTS') || isempty(filename)) && exist(['SLUKE_RFWAVES/WAVESTRUCTS_',id,'.mat'])
    delete(['SLUKE_RFWAVES/WAVESTRUCTS_',id,'.mat']);
    cprintf('*black',['SLUKE_RFWAVES/WAVESTRUCTS_',id,'.mat is deleted']);disp(' ')
end
%
if isfield(sparams,'rfwaves') && isfield(sparams.rfwaves,'antenna') && isfield(sparams.rfwaves.antenna,'type') && ~isempty(sparams.rfwaves.antenna.type)
    for kk = 1:length(sparams.rfwaves.antenna.type{ii})
        %
        if strcmp(sparams.rfwaves.antenna.type{ii}{kk},'LH')
            %
            if sparams.rfwaves.antenna.LH.(sparams.rfwaves.antenna.code{ii}{kk}).optim.method{ii}{kk} == 0
                filename_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                    '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.rfwaves.antenna.LH.(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},...
                    '_ne_',num2str(sparams.rfwaves.antenna.LH.(sparams.rfwaves.antenna.code{ii}{kk}).optim.ne_guess{ii}{kk}/1e17)];
            else
                filename_aloha = [sparams.machine{ii},'_',sparams.discharge.shot{ii},'_',num2str(sparams.discharge.tmin{ii}),...
                    '_',num2str(sparams.discharge.tmax{ii}),'_ALOHA_',sparams.rfwaves.antenna.LH.(sparams.rfwaves.antenna.code{ii}{kk}).port{ii}{kk},'_ne_optim'];
            end
            %
            if (strcmp(filename,'ANTENNA') || isempty(filename)) && exist(['SLUKE_RFWAVES/ALOHA/Simulations/',filename_aloha,'.mat'])
                delete(['SLUKE_RFWAVES/ALOHA/Simulations/',filename_aloha,'.mat']);
                cprintf('*black',['SLUKE_RFWAVES/ALOHA/Simulations/',filename_aloha,'.mat is deleted']);disp(' ')
            end
            %
        end
        %
    end
    %
end
%
if isfield(sparams,'diags')
    %
    fn = fieldnames(sparams.diags);
    %
    for jj = 1:length(fn)
        %
        if (strcmp(filename,'HXRPARAM') || isempty(filename)) && exist(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRPARAM_',id,'.mat'])
            delete(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRPARAM_',id,'.mat']);
            cprintf('*black',['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRPARAM_',id,'.mat is deleted']);disp(' ')
        end
        %
        if (strcmp(filename,'HXRSPEC') || isempty(filename)) && exist(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRSPEC_',id,'.mat'])
            delete(['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRSPEC_',id,'.mat']);
            cprintf('*black',['SLUKE_DIAGNOSTICS/',fn{jj},'_HXRSPEC_',id,'.mat is deleted']);disp(' ')
        end
        %
        if (strcmp(filename,'DIAG_RESULTS') || isempty(filename)) && exist(['SLUKE_DIAGNOSTICS/',fn{jj},'_RESULTS_',id,'.mat'])
            delete(['SLUKE_DIAGNOSTICS/',fn{jj},'_RESULTS_',id,'.mat']);
            cprintf('*black',['SLUKE_DIAGNOSTICS/',fn{jj},'_RESULTS_',id,'.mat is deleted']);disp(' ')
        end
        %
    end
    %
end
%
