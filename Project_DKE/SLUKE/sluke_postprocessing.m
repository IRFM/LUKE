function sluke_postprocessing(sparams,lukestructs,ii)
%
simul_id = sluke_id(sparams,ii,'simul');
%
if exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
    %
    disp(['WARNING : post-processing already done for simulation #',int2str(ii),'. Delete the file SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat and launch the simulation to rebuilt the post-processing data with new parameters.'])
    %
else
    %
    if ~isfield(sparams,'postprocessing')
        %
        %
        disp(['WARNING : default post-processing options are used for simulation #',int2str(ii)])
        %
        data_proc = proc_luke_jd(lukestructs.output);
        %
    else
        %
        data_proc = proc_luke_jd(lukestructs.output,sparams.postprocessing.ir_display{ii},sparams.postprocessing.p_opt{ii},sparams.postprocessing.dp_cyl{ii},sparams.postprocessing.pnmax{ii},sparams.postprocessing.subtitle{ii},sparams.postprocessing.opt{ii});
        %
    end
    %
    if ~isempty(data_proc)
        %
        save(['SLUKE_RESULTS/PROC_LUKE_DATA_',id_simul,'.mat'],'data_proc');
        disp(['--> post-processing calculations for simulation #',int2str(ii),' have been saved.'])
        %
    else
        %
        disp('WARNING : Post-processing of LUKE results failed !')
        %
    end
    %
end
