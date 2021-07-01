function equils = sluke_equil(sparams)
%
for ii = 1:length(sparams.machine)
    %
    if strcmp(sparams.equil.source.method{ii},'code')
        %
        %
    elseif strcmp(sparams.equil.source.method{ii},'file')
        %
        equil_file = sparams.equil.source.file{ii};
        equil_path = sparams.equil.source.path{ii};
        %
        if strcmp(sparams.equil.source.path{ii},'.')
            equil_path = [pwd,'/'];
        else
            if strcmp(sparams.equil.source.path{ii}(end),'/')
                equil_path = sparams.equil.source.path{ii};
            else
                equil_path = [sparams.equil.source.path{ii},'/'];
            end
        end
        %
        data = load([equil_path,equil_file]);
        %
        if isfield(data,'post') % equilibrium from metis simulations
            %
            [~,~,equils{ii},~,~,~,~] = auto_extract_metisdata_for_luke(data.post,sparams.discharge.tmin{ii});
            %
        end
        %
    elseif strcmp(sparams.equil.source.method{ii},'value')
        %
        %
    end
end
    
    
    