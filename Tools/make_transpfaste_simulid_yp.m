function locid_simul = make_transpfaste_simulid_yp(transpfaste)
%
% This function creates a standard id string from transpfaste parameters
%
if isstruct(transpfaste) && ~isempty(fieldnames(transpfaste)),
    if transpfaste.Dr_model == 1,
        locid_simul = 'EM';
    else
        locid_simul = 'ES';
    end
    %
    if transpfaste.Dr0 == 0 & transpfaste.Vr0 == 0
        locid_simul = '';
    else
        locid_simul = [locid_simul,'_Dr0_',num2str(transpfaste.Dr0),'_pDr_',num2str(transpfaste.pDr),'_Vr0_',num2str(transpfaste.Vr0),'_pVr_',num2str(transpfaste.pVr),'_vparmin_',num2str(transpfaste.vparmin),'_normref_',num2str(transpfaste.norm_ref)];
    end
    %
else
    locid_simul = '';
end
