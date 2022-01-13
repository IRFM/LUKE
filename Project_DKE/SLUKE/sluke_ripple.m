function [ripple] = sluke_ripple(sparams,ii)

ripple = {};
%
if ~isfield(sparams.equil,'ripple')
    %
    cprintf([1,0.5,0],'No toroidal magnetic ripple is defined in sparams');disp(' ');
    ripple = [];
    return
    %
end
%
ripple_id = sluke_id(sparams,ii);
%
if strcmp(sparams.machine{ii},'TS') || strcmp(sparams.machine{ii},'WEST')
    %
    if exist(['SLUKE_RIPPLES/ripple_',ripple_id,'.mat'])
        %
        load(['SLUKE_RIPPLES/ripple_',ripple_id,'.mat']);
        %
    else
        %
        if strcmp(sparams.equil.ripple.source{ii},'file')
            %
            ripple_file = sparams.equil.ripple.file{ii};
            ripple_path = sparams.equil.ripple.path{ii};
            %
            if strcmp(sparams.equil.ripple.path{ii},'.')
                ripple_path = [pwd,'/'];
            else
                if strcmp(sparams.equil.ripple.path{ii}(end),'/')
                    ripple_path = sparams.equil.ripple.path{ii};
                else
                    ripple_path = [sparams.equil.ripple.path{ii},'/'];
                end
            end
            %
            ripple = load([ripple_path,ripple_file]);
            %
            save(['SLUKE_RIPPLES/TRANSPFASTE_',ripple_id,'.mat'],'ripple');
            %
        else
            % 
            ripple = sluke_params_value(sparams.equil.ripple,ii);
            %
        end
    end
    %
else
    %
    cprintf(*[1,0.5,0],['No toroidal magnetic ripple is implemented yet for the machine : ',sparams.machine{ii}]);disp(' ');
    %
end
    
    