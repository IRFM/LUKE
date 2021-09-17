function sluke_diagnostics(sparams,lukestructs,ii)
%
simul_id = sluke_id(sparams,ii,'simul');
%
% Synthetic diagnostic : fast electron bremsstrahlung (HXR)
%
if ~exist(['SLUKE_DIAGNOSTICS/HXR_RESULTS_',simul_id,'.mat'])
    %
    if isfield(sparams,'diags') && isfield(sparams.diags,'hxr')
        %
        [Zbremchord,Zbremdiag,Zbremplasma,equilHXR,hxrexp] = sluke_hxr(sparams,lukestructs,ii);
        %
        if ~isempty(Zbremchord) && ~isempty(Zbremdiag) && ~isempty(Zbremplasma) && ~isempty(equilHXR)
            %
            save(['SLUKE_DIAGNOSTICS/HXR_RESULTS_',simul_id,'.mat'],'Zbremchord','Zbremdiag','Zbremplasma','equilHXR','hxrexp');%backward compatibility with irunluke_jd
            %
        else
            %
            disp('WARNING : HXR calculations from LUKE results failed.')
            %
        end
        %
    end
    %
end