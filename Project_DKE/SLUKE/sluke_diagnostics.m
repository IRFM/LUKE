function sluke_diagnostics(sparams,lukestructs,ii)
%
simul_id = sluke_id(sparams,ii,'simul');
%
% Synthetic diagnostic : fast electron bremsstrahlung (HXR)
%
if ~exist(['SLUKE_DIAGNOSTICS/HXR_RESULTS_',simul_id,'.mat'])
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'DSPX')
        %
        [DSPX.Zbremchord,DSPX.Zbremdiag,DSPX.Zbremplasma,DSPX.equilHXR,DSPX.hxrexp] = sluke_dspx(sparams,lukestructs,ii);
        %
        if ~isempty(DSPX.Zbremchord) && ~isempty(DSPX.Zbremdiag) && ~isempty(DSPX.Zbremplasma) && ~isempty(DSPX.equilHXR)
            %
            save(['SLUKE_DIAGNOSTICS/DSPX_RESULTS_',simul_id,'.mat'],'DSPX');
            %
        else
            %
            disp('WARNING : DSPX calculations from LUKE results failed.')
            %
        end
        %
    elseif isfield(sparams,'diags') && isfield(sparams.diags,'MEHXR')
        %
        [MEHXR.Zbremchord,MEHXR.Zbremdiag,MEHXR.Zbremplasma,MEHXR.equilHXR,MEHXR.hxrexp] = sluke_mehxr(sparams,lukestructs,ii);
        %
        if ~isempty(MEHXR.Zbremchord) && ~isempty(MEHXR.Zbremdiag) && ~isempty(MEHXR.Zbremplasma) && ~isempty(MEHXR.equilHXR)
            %
            save(['SLUKE_DIAGNOSTICS/MEHXR_RESULTS_',simul_id,'.mat'],'MEHXR');
            %
        else
            %
            disp('WARNING : MEHXR calculations from LUKE results failed.')
            %
        end
        %
    end
    %
end