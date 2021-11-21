
function opt = sluke_ohm(sparams,ii)


if isfield(sparams.kinetics,'opt')
    %
    opt = sluke_params_value(sparams.kinetics.opt,ii);
    %
    if isfield(opt,'proc_remote') 
        %
        if opt.proc_remote == 1
            %
            if opt.save == 0
                %
                opt.save = 2;%just post-processing
                %
            end
            %
            opt.proc = sluke_params_value(sparams.postprocessing,ii);
            %
        end
        %
        opt = rmfield(opt,'proc_remote');%just post-processing
        %
    end
    %
else
    %
    opt = [];
    %
end