function equil = sluke_equil(sparams,ii)
%



%
equil_id = sluke_id(sparams,ii,'equil');
%
if exist(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'])
    %
    load(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat']);
    %
else
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
            [~,~,equil,~,~,~,~] = auto_extract_metisdata_for_luke(data.post,sparams.discharge.tmin{ii});
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.equil.source);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.equil.source.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            source.comment = sparams.equil.comment{ii};
            %
            equil.source = source;
            clear source
            %
            save(['SLUKE_EQUILS/EQUIL_',equil_id,'.mat'],'equil');
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.equil.source.method{ii},'value')
        %
        %
    end
end

    
    
    