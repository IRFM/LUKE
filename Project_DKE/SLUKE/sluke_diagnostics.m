function sluke_diagnostics(sparams,lukestructs,ii)
%
simul_id = sluke_id(sparams,ii,'simul');
%
% Synthetic diagnostic : fast electron bremsstrahlung in the hard x-ray photon energy range DSPX
%
if ~exist(['SLUKE_DIAGNOSTICS/DSPX_RESULTS_',simul_id,'.mat'])
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'DSPX')
        %
        if ~isfield(sparams.diags.DSPX,'enable') || (isfield(sparams.diags.DSPX,'enable') && sparams.diags.DSPX.enable == 1)
            %
            [DSPX.Zbremchord,DSPX.Zbremdiag,DSPX.Zbremplasma,DSPX.equilHXR,DSPX.hxrexp_averaged] = sluke_dspx(sparams,lukestructs,ii);
            %
            if ~isempty(DSPX.Zbremchord) && ~isempty(DSPX.Zbremdiag) && ~isempty(DSPX.Zbremplasma) && ~isempty(DSPX.equilHXR)
                %
                save(['SLUKE_DIAGNOSTICS/DSPX_RESULTS_',simul_id,'.mat'],'DSPX');
                %
            else
                %
                cprintf('red','WARNING : DSPX calculations from LUKE results failed.');disp(' ');
                %
            end
        else
            %
            cprintf([1,0.5,0],'DSPX calculations are not enabled in sparams');disp(' ');
            %
        end
        %
    end
    %
else
    %
    cprintf('green','DSPX calculations are already done');disp(' ');
    %
end
%
% Synthetic diagnostic : fast electron bremsstrahlung in the hard x-ray photon energy range MEHXR
%
if ~exist(['SLUKE_DIAGNOSTICS/MEHXR_RESULTS_',simul_id,'.mat'])
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'MEHXR')
        %
        if ~isfield(sparams.diags.MEHXR,'enable') || (isfield(sparams.diags.MEHXR,'enable') && sparams.diags.MEHXR.enable == 1)
            %
            [MEHXR.Zbremchord,MEHXR.Zbremdiag,MEHXR.Zbremplasma,MEHXR.equilHXR,MEHXR.hxrexp_averaged] = sluke_mehxr(sparams,lukestructs,ii);
            %
            if ~isempty(MEHXR.Zbremchord) && ~isempty(MEHXR.Zbremdiag) && ~isempty(MEHXR.Zbremplasma) && ~isempty(MEHXR.equilHXR)
                %
                save(['SLUKE_DIAGNOSTICS/MEHXR_RESULTS_',simul_id,'.mat'],'MEHXR');
                %
            else
                %
                cprintf('red','WARNING : MEHXR calculations from LUKE results failed.');disp(' ');
                %
            end
            %
        else
            %
            cprintf([1,0.5,0],'MEHXR calculations are not enabled in sparams');disp(' ');
            %
        end
        %
    end
    %
else
    %
    cprintf('green','MEHXR calculations are already done');disp(' ');
    %
end
%

