function sluke_postprocessing(sparams,ii,lukestructs)
%
simul_id = sluke_id(sparams,ii,'simul');
%
if ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
    %
    if ~isfield(sparams,'postprocessing')
        %
        data_proc = proc_luke_jd(lukestructs.output);
        %
    else
        %
        data_proc = proc_luke_jd(lukestructs.output,sluke_params_value(sparams.postprocessing.ir_display,ii),sparams.postprocessing.ir_display.p_opt{ii},sparams.postprocessing.dp_cyl{ii});
        %
    end
    %
    if ~isempty(data_proc)
        %
        save(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'],'data_proc');
        %
    else
        %
        disp('WARNING : Post-processing of LUKE results failed !')
        %
    end
    %
end
