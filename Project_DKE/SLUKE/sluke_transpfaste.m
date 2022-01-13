function [transpfaste] = sluke_transpfaste(sparams,ii)

transpfaste = {};
%
if ~isfield(sparams.kinetics,'fast_electron_anomalous_transport')
    %
    cprintf([1,0.5,0],'No anomalous radial transport is defined in sparams');disp(' ');
    transpfaste = [];
    return
    %
end
%
transpfaste_id = sluke_id(sparams,ii);
%
if exist(['SLUKE_TRANSPS/TRANSPFASTE_',transpfaste_id,'.mat'])
    %
    load(['SLUKE_TRANSPS/TRANSPFASTE_',transpfaste_id,'.mat']);
    %
else
    %
    if strcmp(sparams.kinetics.fast_electron_anomalous_transport.source{ii},'file')
        %
        transpfaste_file = sparams.kinetics.fast_electron_anomalous_transport.file{ii};
        transpfaste_path = sparams.kinetics.fast_electron_anomalous_transport.path{ii};
        %
        if strcmp(sparams.kinetics.fast_electron_anomalous_transport.path{ii},'.')
            transpfaste_path = [pwd,'/'];
        else
            if strcmp(sparams.kinetics.fast_electron_anomalous_transport.path{ii}(end),'/')
                transpfaste_path = sparams.kinetics.fast_electron_anomalous_transport.path{ii};
            else
                transpfaste_path = [sparams.kinetics.fast_electron_anomalous_transport.path{ii},'/'];
            end
        end
        %
        transpfaste = load([transpfaste_path,transpfaste_file]);
        %
        save(['SLUKE_TRANSPS/TRANSPFASTE_',transpfaste_id,'.mat'],'transpfaste');
        %
    else
        % 
        transpfaste = sluke_params_value(sparams.kinetics.fast_electron_anomalous_transport,ii);
        %
    end
end
    
    