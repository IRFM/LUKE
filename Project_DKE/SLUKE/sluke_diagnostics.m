function sluke_diagnostics(sparams,lukestructs,ii)
%
simul_id = sluke_id(sparams,ii,'simul');
%
% Synthetic diagnostic : fast electron bremsstrahlung (HXR)
%
if exist(['SLUKE_RESULTS/HXR_RESULTS_',simul_id,'.mat'])
    %
    disp(['WARNING : HXR calculations already done for simulation #',int2str(ii),'. Delete the file SLUKE_RESULTS/HXR_RESULTS_',simul_id,'.mat' and re-launch the simulation to rebuilt HXR data with new parameters.'])
    %
else
    %
    if isfield(sparams,'diagnostics') && isfield(sparams.diagnostics,'HXR')
        %
        [Zbremchord,Zbremdiag,Zbremplasma,equilHXR,hxrexp] = sluke_hxr(sparams,lukestructs,ii);
        %
        if ~isempty(Zbremchord) && ~isempty(Zbremdiag) && ~isempty(Zbremplasma) && ~isempty(equilHXR)
            %
            save(['SLUKE_RESULTS/HXR_RESULTS_',id_simul,'.mat'],'Zbremchord','Zbremdiag','Zbremplasma','equilHXR','hxrexp');%backward compatibility with irunluke_jd
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