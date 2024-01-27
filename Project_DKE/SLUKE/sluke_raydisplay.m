function raydisplay = sluke_raydisplay(sparams,ii)
%



%
raydisplay_id = sluke_id(sparams,ii);
%
if exist(['SLUKE_RAYDISPLAYS/RAYDISPLAY_',raydisplay_id,'.mat'])
    %
    load(['SLUKE_RAYDISPLAYS/RAYDISPLAY_',raydisplay_id,'.mat']);
    %
else
    %
    if strcmp(sparams.raydisplay.source{ii},'file')
        %
        raydisplay_file = sparams.raydisplay.file{ii};
        raydisplay_path = sparams.raydisplay.path{ii};
        %
        if strcmp(sparams.raydisplay.path{ii},'.')
            raydisplay_path = [pwd,'/'];
        else
            if strcmp(sparams.raydisplay.path{ii}(end),'/')
                raydisplay_path = sparams.raydisplay.path{ii};
            else
                raydisplay_path = [sparams.raydisplay.path{ii},'/'];
            end
        end
        %
        data = load([raydisplay_path,raydisplay_file]);
        %
        if isfield(data,'post') % raydisplay from metis simulations
            %
            [~,~,~,~,~,~,wavestructs] = auto_extract_metisdata_for_luke(data.post,sparams.discharge.tmin{ii},1);
            %
            movefile('before_luke@*','./INPUTS/','f');% move all before_luke* files created by auto_extract_metisdata_for_luke. Files may be overwritten
            %
            fns = fieldnames(sparams.raydisplay);
            %
            for jj = 1:length(fns)
                %
                eval(['source.',fns{jj},' = sparams.raydisplay.',fns{jj},'{',int2str(ii),'};']);
                %
            end
            %
            raydisplay.source = source;
            clear source
            %
            save(['SLUKE_RAYDISPLAYS/RAYDISPLAY_',raydisplay_id,'.mat'],'raydisplay');
            %
        else
            error([]);
        end
        %
    elseif strcmp(sparams.raydisplay.source{ii},'value')
        %
        %
    end
end

    
    
    