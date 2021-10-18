function sluke_postprocessing(sparams,ii,lukestructs)
%
simul_id = sluke_id(sparams,ii,'simul');
%
if ~exist(['SLUKE_RESULTS/PROC_LUKE_DATA_',simul_id,'.mat'])
    %
    if ~isfield(sparams,'postprocessing')
        %
        data_proc = proc_luke_jd(lukestructs.output);%default value
        %
    else
        %
        if isfield(lukestructs.output,'data_proc')
            %
            data_proc = lukestructs.output.data_proc;%Processed data calculated remotely
            %
        else
            %
            opt = sluke_params_value(sparams.postprocessing,ii);
            %
            data_proc = proc_luke_jd(lukestructs.output,opt);
            %
        end
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
